<?php

namespace App\Services\Patrimonio;

use Throwable;

/**
 * Indexadores do Banco Central (série SGS): CDI, SELIC, IPCA. Open data
 * oficial, sem chave e sem restrição de uso comercial — é a fonte correta
 * para estimar rendimento de CDB e Tesouro.
 *
 * Aqui o "ticker" é o código da série: CDI = 12, SELIC = 432, IPCA = 433.
 *
 * Nota operacional: desde março/2025 filtros de data são obrigatórios em
 * consultas grandes, e pedir mais de ~10 anos devolve HTTP 500. Este provider
 * busca só o último valor, então não esbarra nisso.
 */
class BcbPriceProvider implements PriceProvider
{
    public const SERIE_CDI = '12';
    public const SERIE_SELIC = '432';
    public const SERIE_IPCA = '433';

    /** @var callable(string): ?float */
    private $fetcher;

    public function __construct(?callable $fetcher = null)
    {
        $this->fetcher = $fetcher ?? fn (string $serie) => $this->buscarNoBcb($serie);
    }

    public function precoAtual(string $ticker, ?float $ultimoPrecoConhecido): ?float
    {
        try {
            $valor = ($this->fetcher)($ticker);
        } catch (Throwable) {
            return $ultimoPrecoConhecido;
        }

        if ($valor === null || $valor <= 0) {
            return $ultimoPrecoConhecido;
        }

        return (float) $valor;
    }

    public function fonte(): string
    {
        return 'bcb';
    }

    private function buscarNoBcb(string $serie): ?float
    {
        $url = sprintf(
            'https://api.bcb.gov.br/dados/serie/bcdata.sgs.%s/dados/ultimos/1?formato=json',
            urlencode($serie),
        );

        $response = @file_get_contents($url, false, stream_context_create([
            'http' => ['timeout' => 5, 'ignore_errors' => true],
        ]));

        if ($response === false) {
            return null;
        }

        $payload = json_decode($response, true);

        if (!is_array($payload) || $payload === []) {
            return null;
        }

        $ultimo = end($payload);

        return isset($ultimo['valor']) ? (float) $ultimo['valor'] : null;
    }
}
