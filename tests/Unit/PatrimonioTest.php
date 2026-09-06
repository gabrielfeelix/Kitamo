<?php

namespace Tests\Unit;

use App\Support\Patrimonio;
use PHPUnit\Framework\TestCase;

class PatrimonioTest extends TestCase
{
    public function test_rendimento_e_valor_atual_menos_capital_investido(): void
    {
        $movimentos = [
            ['kind' => 'aporte', 'amount' => 1000.00],
            ['kind' => 'aporte', 'amount' => 500.00],
        ];

        // Aportou 1500, hoje vale 1600 => rendeu 100.
        $this->assertSame(100.0, Patrimonio::rendimento(1600.00, $movimentos));
    }

    public function test_resgate_reduz_o_capital_investido(): void
    {
        $movimentos = [
            ['kind' => 'aporte', 'amount' => 1000.00],
            ['kind' => 'resgate', 'amount' => 400.00],
        ];

        // Capital investido = 600. Vale 650 => rendeu 50.
        $this->assertSame(600.0, Patrimonio::totalAportado($movimentos));
        $this->assertSame(50.0, Patrimonio::rendimento(650.00, $movimentos));
    }

    public function test_rendimento_negativo_quando_a_posicao_perde_valor(): void
    {
        $movimentos = [['kind' => 'aporte', 'amount' => 1000.00]];

        // Prejuízo é informação legítima: não pode ser zerado nem virar módulo.
        $this->assertSame(-250.0, Patrimonio::rendimento(750.00, $movimentos));
    }

    public function test_posicao_sem_movimentos_nao_divide_por_zero(): void
    {
        $this->assertSame(0.0, Patrimonio::totalAportado([]));
        $this->assertSame(0.0, Patrimonio::rentabilidadePercentual(500.00, []));
    }

    public function test_rentabilidade_percentual_sobre_o_capital_investido(): void
    {
        $movimentos = [['kind' => 'aporte', 'amount' => 2000.00]];

        // 2000 -> 2200 = +10%
        $this->assertSame(10.0, Patrimonio::rentabilidadePercentual(2200.00, $movimentos));
    }

    public function test_capital_investido_negativo_nao_gera_percentual_absurdo(): void
    {
        // Resgatou mais do que aportou (lucro já realizado): percentual não faz
        // sentido matemático aqui, então é 0 em vez de um número enganoso.
        $movimentos = [
            ['kind' => 'aporte', 'amount' => 100.00],
            ['kind' => 'resgate', 'amount' => 300.00],
        ];

        $this->assertSame(0.0, Patrimonio::rentabilidadePercentual(50.00, $movimentos));
    }

    public function test_patrimonio_total_soma_contas_e_investimentos(): void
    {
        $this->assertSame(
            5628.47,
            Patrimonio::total(saldoEmContas: 4000.00, valorInvestido: 1628.47),
        );
    }

    public function test_patrimonio_total_aceita_saldo_negativo_em_conta(): void
    {
        // Conta no vermelho reduz o patrimônio — não pode ser ignorada.
        $this->assertSame(
            628.47,
            Patrimonio::total(saldoEmContas: -1000.00, valorInvestido: 1628.47),
        );
    }
}
