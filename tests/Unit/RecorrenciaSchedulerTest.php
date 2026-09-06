<?php

namespace Tests\Unit;

use App\Models\RecorrenciaGrupo;
use App\Services\Recorrencias\RecorrenciaScheduler;
use Carbon\CarbonImmutable;
use PHPUnit\Framework\TestCase;

class RecorrenciaSchedulerTest extends TestCase
{
    private function grupo(string $periodicidade, ?int $meses = null): RecorrenciaGrupo
    {
        $grupo = new RecorrenciaGrupo();
        $grupo->periodicidade = $periodicidade;
        $grupo->intervalo_meses = $meses;

        return $grupo;
    }

    /**
     * Uma conta que vence dia 31 não pode virar dia 28 permanentemente só
     * porque passou por fevereiro.
     */
    public function test_dia_31_nao_degrada_apos_fevereiro(): void
    {
        $scheduler = new RecorrenciaScheduler();
        $grupo = $this->grupo('mensal');

        $cursor = CarbonImmutable::create(2026, 1, 31);
        $dias = [];

        for ($i = 0; $i < 6; $i++) {
            $cursor = $scheduler->nextDate($cursor, $grupo, 31);
            $dias[] = $cursor->day;
        }

        // fev(28) mar(31) abr(30) mai(31) jun(30) jul(31)
        $this->assertSame([28, 31, 30, 31, 30, 31], $dias);
    }

    /** Dia 30 se comporta igual: cede em fevereiro, volta depois. */
    public function test_dia_30_volta_apos_fevereiro(): void
    {
        $scheduler = new RecorrenciaScheduler();
        $grupo = $this->grupo('mensal');

        $cursor = CarbonImmutable::create(2026, 1, 30);
        $dias = [];

        for ($i = 0; $i < 4; $i++) {
            $cursor = $scheduler->nextDate($cursor, $grupo, 30);
            $dias[] = $cursor->day;
        }

        $this->assertSame([28, 30, 30, 30], $dias);
    }

    /** Datas que não esbarram em mês curto seguem inalteradas. */
    public function test_dia_comum_permanece_estavel(): void
    {
        $scheduler = new RecorrenciaScheduler();
        $grupo = $this->grupo('mensal');

        $cursor = CarbonImmutable::create(2026, 1, 15);

        for ($i = 0; $i < 12; $i++) {
            $cursor = $scheduler->nextDate($cursor, $grupo, 15);
            $this->assertSame(15, $cursor->day);
        }
    }

    /** A cada N meses também preserva a âncora. */
    public function test_intervalo_de_meses_preserva_ancora(): void
    {
        $scheduler = new RecorrenciaScheduler();
        $grupo = $this->grupo('a_cada_x_meses', 2);

        $cursor = CarbonImmutable::create(2025, 12, 31);
        $cursor = $scheduler->nextDate($cursor, $grupo, 31); // fev/2026
        $this->assertSame(28, $cursor->day);

        $cursor = $scheduler->nextDate($cursor, $grupo, 31); // abr/2026
        $this->assertSame(30, $cursor->day);

        $cursor = $scheduler->nextDate($cursor, $grupo, 31); // jun/2026
        $this->assertSame(30, $cursor->day);
    }
}
