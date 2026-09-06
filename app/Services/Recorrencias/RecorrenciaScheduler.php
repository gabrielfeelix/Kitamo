<?php

namespace App\Services\Recorrencias;

use App\Models\RecorrenciaGrupo;
use Carbon\CarbonImmutable;

class RecorrenciaScheduler
{
    /**
     * Próxima data da recorrência.
     *
     * Recorrências mensais preservam o dia de origem (`$anchorDay`). Encadear
     * addMonthNoOverflow a partir da data anterior degrada o dia de forma
     * permanente: uma conta do dia 31 vira 28 ao passar por fevereiro e nunca
     * mais volta para 31.
     */
    public function nextDate(CarbonImmutable $from, RecorrenciaGrupo $grupo, ?int $anchorDay = null): CarbonImmutable
    {
        $dia = $anchorDay ?? $from->day;

        return match ($grupo->periodicidade) {
            'mensal' => $this->addMonthsKeepingDay($from, 1, $dia),
            'quinzenal' => $from->addDays(15),
            'a_cada_x_meses' => $this->addMonthsKeepingDay($from, max(1, (int) ($grupo->intervalo_meses ?? 1)), $dia),
            'a_cada_x_dias' => $from->addDays(max(1, (int) ($grupo->intervalo_dias ?? 1))),
            default => $this->addMonthsKeepingDay($from, 1, $dia),
        };
    }

    /**
     * Avança N meses tentando manter o dia de origem. Em meses curtos usa o
     * último dia disponível, mas sem perder a âncora nos meses seguintes.
     */
    private function addMonthsKeepingDay(CarbonImmutable $from, int $months, int $anchorDay): CarbonImmutable
    {
        $target = $from->startOfMonth()->addMonthsNoOverflow($months);

        return $target->setDay(min($anchorDay, (int) $target->daysInMonth));
    }

    public function isActiveOn(RecorrenciaGrupo $grupo, CarbonImmutable $date): bool
    {
        if (!$grupo->is_active) {
            return false;
        }

        if ($grupo->data_fim && $date->greaterThan(CarbonImmutable::parse($grupo->data_fim))) {
            return false;
        }

        return true;
    }
}
