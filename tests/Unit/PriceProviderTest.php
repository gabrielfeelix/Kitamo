<?php

namespace Tests\Unit;

use App\Services\Patrimonio\BinancePriceProvider;
use App\Services\Patrimonio\ManualPriceProvider;
use PHPUnit\Framework\TestCase;

class PriceProviderTest extends TestCase
{
    public function test_manual_sempre_devolve_o_valor_informado_pelo_usuario(): void
    {
        $provider = new ManualPriceProvider();

        $this->assertSame('manual', $provider->fonte());
        $this->assertSame(1628.47, $provider->precoAtual('QUALQUER', 1628.47));
    }

    public function test_binance_devolve_o_preco_quando_a_api_responde(): void
    {
        $provider = new BinancePriceProvider(fn (string $ticker) => 79944.00);

        $this->assertSame('binance', $provider->fonte());
        $this->assertSame(79944.00, $provider->precoAtual('BTC', null));
    }

    public function test_falha_da_api_preserva_o_ultimo_preco_conhecido(): void
    {
        // A garantia central do módulo: rede fora do ar não pode zerar posição.
        $provider = new BinancePriceProvider(function (string $ticker) {
            throw new \RuntimeException('connection refused');
        });

        $this->assertSame(75000.00, $provider->precoAtual('BTC', 75000.00));
    }

    public function test_api_devolvendo_nulo_tambem_preserva_o_ultimo_preco(): void
    {
        $provider = new BinancePriceProvider(fn (string $ticker) => null);

        $this->assertSame(75000.00, $provider->precoAtual('BTC', 75000.00));
    }

    public function test_preco_invalido_nao_contamina_a_posicao(): void
    {
        // Zero ou negativo vindo da API é dado corrompido, não preço.
        $provider = new BinancePriceProvider(fn (string $ticker) => 0.0);

        $this->assertSame(75000.00, $provider->precoAtual('BTC', 75000.00));
    }

    public function test_preco_negativo_tambem_e_rejeitado(): void
    {
        $provider = new BinancePriceProvider(fn (string $ticker) => -12.5);

        $this->assertSame(75000.00, $provider->precoAtual('BTC', 75000.00));
    }

    public function test_sem_preco_anterior_e_com_falha_devolve_nulo(): void
    {
        $provider = new BinancePriceProvider(fn (string $ticker) => null);

        $this->assertNull($provider->precoAtual('BTC', null));
    }
}
