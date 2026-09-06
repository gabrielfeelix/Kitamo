<?php

namespace Tests\Unit;

use App\Support\InvoiceCycle;
use PHPUnit\Framework\TestCase;

class InvoiceCycleTest extends TestCase
{
    /**
     * A garantia central: percorrendo meses consecutivos, cada ciclo começa
     * exatamente um dia depois do fim do anterior. Sem lacuna (compra que não
     * cai em fatura nenhuma) e sem sobreposição (compra cobrada duas vezes).
     */
    public function test_ciclos_sao_continuos_para_todo_dia_de_fechamento(): void
    {
        for ($closingDay = 1; $closingDay <= 31; $closingDay++) {
            $anterior = null;

            // 24 meses corridos, atravessando dois fevereiros e viradas de ano.
            for ($offset = 0; $offset < 24; $offset++) {
                $year = 2025 + intdiv($offset, 12);
                $monthIndex = $offset % 12;

                $ciclo = InvoiceCycle::forMonth($closingDay, $year, $monthIndex);

                $this->assertTrue(
                    $ciclo['start']->lessThanOrEqualTo($ciclo['end']),
                    "closing_day $closingDay, {$year}-" . ($monthIndex + 1) . ": início depois do fim"
                );

                if ($anterior !== null) {
                    $esperado = $anterior['end']->copy()->addDay()->startOfDay();

                    $this->assertEquals(
                        $esperado->toDateString(),
                        $ciclo['start']->toDateString(),
                        "closing_day $closingDay: descontinuidade em {$year}-" . ($monthIndex + 1)
                            . ". Ciclo anterior terminou em {$anterior['end']->toDateString()}, "
                            . "este começa em {$ciclo['start']->toDateString()}"
                    );
                }

                $anterior = $ciclo;
            }
        }
    }

    /**
     * Nenhum mês pode ser pulado: 24 meses consecutivos devem produzir 24
     * ciclos distintos.
     */
    public function test_meses_consecutivos_geram_ciclos_distintos(): void
    {
        foreach ([1, 2, 13, 14, 15, 20, 28, 30, 31] as $closingDay) {
            $vistos = [];

            for ($offset = 0; $offset < 24; $offset++) {
                $year = 2025 + intdiv($offset, 12);
                $monthIndex = $offset % 12;
                $ciclo = InvoiceCycle::forMonth($closingDay, $year, $monthIndex);
                $chave = $ciclo['start']->toDateString() . '..' . $ciclo['end']->toDateString();

                $this->assertNotContains(
                    $chave,
                    $vistos,
                    "closing_day $closingDay: ciclo $chave repetido — fatura cobrada duas vezes"
                );

                $vistos[] = $chave;
            }
        }
    }

    /**
     * Fevereiro não pode fazer o dia de fechamento degradar permanentemente:
     * closing_day 31 volta a fechar em 31 em março.
     */
    public function test_fechamento_nao_degrada_apos_mes_curto(): void
    {
        $marco = InvoiceCycle::forMonth(31, 2026, 2); // índice 2 = março

        $this->assertSame(31, $marco['end']->day, 'closing_day 31 degradou após fevereiro');
    }

    /** Os cartões reais do usuário. */
    public function test_cartoes_reais(): void
    {
        // Nubank Gold: fecha 28. Compras de setembro/2026.
        $nubank = InvoiceCycle::forMonth(28, 2026, 8);
        $this->assertSame('2026-08-29', $nubank['start']->toDateString());
        $this->assertSame('2026-09-28', $nubank['end']->toDateString());

        // Mercado Pago: fecha 2 (cedo no mês), então as compras de setembro
        // só fecham em 02/10 — a "fatura de setembro" no extrato do banco.
        $mp = InvoiceCycle::forMonth(2, 2026, 8);
        $this->assertSame('2026-09-03', $mp['start']->toDateString());
        $this->assertSame('2026-10-02', $mp['end']->toDateString());
    }
}
