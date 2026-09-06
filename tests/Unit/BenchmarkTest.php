<?php

namespace Tests\Unit;

use App\Support\Benchmark;
use PHPUnit\Framework\TestCase;

class BenchmarkTest extends TestCase
{
    public function test_acumula_o_cdi_diario_ao_longo_do_periodo(): void
    {
        // 0,05% ao dia por 21 dias úteis ≈ 1,0556% no mês.
        $acumulado = Benchmark::acumular(0.05, 21);

        $this->assertEqualsWithDelta(1.0556, $acumulado, 0.001);
    }

    public function test_periodo_zerado_nao_rende_nada(): void
    {
        $this->assertSame(0.0, Benchmark::acumular(0.05, 0));
    }

    public function test_taxa_zero_nao_rende_nada(): void
    {
        $this->assertSame(0.0, Benchmark::acumular(0.0, 21));
    }

    public function test_dias_uteis_aproximados_a_partir_de_dias_corridos(): void
    {
        // ~21 dias úteis num mês de 30 dias corridos.
        $this->assertSame(21, Benchmark::diasUteis(30));
        $this->assertSame(252, Benchmark::diasUteis(365));
        $this->assertSame(0, Benchmark::diasUteis(0));
    }

    public function test_compara_rentabilidade_com_o_benchmark(): void
    {
        // Rendeu 2% enquanto o CDI fez 1% => 200% do CDI.
        $this->assertSame(200.0, Benchmark::percentualDoBenchmark(2.0, 1.0));
    }

    public function test_benchmark_zerado_nao_divide_por_zero(): void
    {
        $this->assertNull(Benchmark::percentualDoBenchmark(2.0, 0.0));
    }

    public function test_rendimento_negativo_contra_benchmark_positivo(): void
    {
        // Perdeu dinheiro enquanto o CDI subiu: percentual negativo é a
        // verdade, não um caso a esconder.
        $this->assertSame(-50.0, Benchmark::percentualDoBenchmark(-0.5, 1.0));
    }
}
