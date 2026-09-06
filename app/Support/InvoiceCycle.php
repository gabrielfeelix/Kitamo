<?php

namespace App\Support;

use Carbon\Carbon;

/**
 * Fonte única de verdade do ciclo de fatura de cartão de crédito.
 *
 * Convenção: a "fatura de <mês>" é o ciclo cujas compras o usuário fez
 * naquele mês — a mesma nomenclatura do extrato do banco.
 *
 * Um ciclo vai de (closing_day do mês anterior + 1) até closing_day, e cada
 * mês do calendário mapeia para exatamente um ciclo. Não pode haver mês
 * pulado nem ciclo repetido: toda data pertence a uma, e só uma, fatura.
 */
class InvoiceCycle
{
    /**
     * Até que dia do mês o fechamento é considerado "cedo" — nesse caso as
     * compras do mês pertencem ao ciclo que fecha no mês seguinte.
     */
    private const FECHAMENTO_CEDO = 5;

    /**
     * @return array{start: Carbon, end: Carbon}
     */
    public static function forMonth(?int $closingDay, int $year, int $monthIndex): array
    {
        $monthStart = Carbon::create($year, $monthIndex + 1, 1)->startOfDay();
        $closingDayRaw = (int) ($closingDay ?? 0);

        // Sem dia de fechamento definido: o ciclo é o próprio mês corrido.
        if ($closingDayRaw <= 0) {
            return [
                'start' => $monthStart->copy(),
                'end' => $monthStart->copy()->endOfMonth()->endOfDay(),
            ];
        }

        // Deslocamento fixo de meses entre o mês da compra e o fechamento que
        // a encerra. Cartão que fecha cedo no mês (até o dia 5) só encerra as
        // compras daquele mês no fechamento seguinte (+1); os demais fecham no
        // próprio mês.
        //
        // O deslocamento é CONSTANTE por cartão — é isso que garante que meses
        // consecutivos gerem ciclos consecutivos. Uma heurística que dependa do
        // tamanho do mês (ex.: comparar com daysInMonth/2) muda de decisão em
        // fevereiro e produz meses pulados e faturas duplicadas.
        $offsetMeses = $closingDayRaw <= self::FECHAMENTO_CEDO ? 1 : 0;

        $anchor = $monthStart->copy()->addMonthsNoOverflow($offsetMeses);
        $end = self::closingDate($closingDayRaw, $anchor->year, $anchor->month);

        $prevAnchor = $anchor->copy()->subMonthNoOverflow();
        $prevClosing = self::closingDate($closingDayRaw, $prevAnchor->year, $prevAnchor->month);
        $start = $prevClosing->copy()->addDay()->startOfDay();

        return [
            'start' => $start,
            'end' => $end,
        ];
    }

    /**
     * Data de fechamento em um mês, respeitando meses curtos: closing_day 31
     * em fevereiro fecha em 28 (ou 29), sem transbordar para março.
     */
    private static function closingDate(int $closingDay, int $year, int $month): Carbon
    {
        $anchor = Carbon::create($year, $month, 1);
        $day = min($closingDay, (int) $anchor->daysInMonth);

        return Carbon::create($year, $month, $day)->endOfDay();
    }
}
