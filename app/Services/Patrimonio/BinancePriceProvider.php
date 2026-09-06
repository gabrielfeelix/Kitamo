<?php

namespace App\Services\Patrimonio;

use Throwable;

/**
 * Cotação de cripto pela API pública da Binance (data-api.binance.vision):
 * sem chave, sem cadastro e sem cláusula de uso pessoal — por isso é a única
 * fonte automática de renda variável legítima para um SaaS pago.
 *
 * (Finnhub e CoinGecko têm tier grátis, mas restrito a uso pessoal; usar num
 * produto pago seria violação de contrato, não só limite técnico.)
 *
 * O fetcher é injetado para manter o teste fora da rede.
 */
class BinancePriceProvider implements PriceProvider
{
    /** @var callable(string): ?float */
    private $fetcher;

    public function __construct(?callable $fetcher = null)
    {
        $this->fetcher = $fetcher ?? fn (string $ticker) => $this->buscarNaBinance($ticker);
    }

    public function precoAtual(string $ticker, ?float $ultimoPrecoConhecido): ?float
    {
        try {
            $preco = ($this->fetcher)($ticker);
        } catch (Throwable) {
            // Rede fora, DNS quebrado, rate limit: mantém o que já se sabia.
            return $ultimoPrecoConhecido;
        }

        if ($preco === null || $preco <= 0) {
            return $ultimoPrecoConhecido;
        }

        return (float) $preco;
    }

    public function fonte(): string
    {
        return 'binance';
    }

    private function buscarNaBinance(string $ticker): ?float
    {
        $symbol = strtoupper($ticker) . 'USDT';
        $url = 'https://data-api.binance.vision/api/v3/ticker/price?symbol=' . urlencode($symbol);

        $response = @file_get_contents($url, false, stream_context_create([
            'http' => ['timeout' => 5, 'ignore_errors' => true],
        ]));

        if ($response === false) {
            return null;
        }

        $payload = json_decode($response, true);

        return isset($payload['price']) ? (float) $payload['price'] : null;
    }
}
