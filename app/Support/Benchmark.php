<?php

namespace App\Support;

/**
 * Comparação com indexadores. Serve para responder a pergunta que o número
 * absoluto não responde: "rendeu bem?".
 *
 * Puro, como Patrimonio e InvoiceCycle: recebe números, devolve números.
 */
class Benchmark
{
    /** Dias úteis num ano, convenção do mercado brasileiro. */
    private const DIAS_UTEIS_ANO = 252;

    /**
     * Juro composto de uma taxa diária ao longo de N dias úteis.
     * Devolve o acumulado em percentual — 1.0556 significa +1,0556%.
     *
     * O CDI da série 12 do BCB já vem como percentual ao dia (0,05166),
     * por isso a divisão por 100 aqui.
     */
    public static function acumular(float $taxaDiariaPercentual, int $diasUteis): float
    {
        if ($diasUteis <= 0 || $taxaDiariaPercentual <= 0) {
            return 0.0;
        }

        $fator = (1 + ($taxaDiariaPercentual / 100)) ** $diasUteis;

        return ($fator - 1) * 100;
    }

    /**
     * Converte dias corridos em dias úteis aproximados (252/365).
     *
     * É aproximação de propósito: o calendário de feriados da B3 mudaria a
     * conta em fração de ponto percentual e exigiria manutenção anual, sem
     * alterar a leitura que o usuário faz — "rendi acima ou abaixo do CDI".
     */
    public static function diasUteis(int $diasCorridos): int
    {
        if ($diasCorridos <= 0) {
            return 0;
        }

        return (int) round($diasCorridos * (self::DIAS_UTEIS_ANO / 365));
    }

    /**
     * Quanto o rendimento representa do benchmark, em percentual.
     * 200 = rendeu o dobro do CDI. 85 = ficou abaixo.
     *
     * Devolve null quando o benchmark é zero ou negativo: não há divisão
     * possível, e exibir qualquer número ali seria inventar informação.
     */
    public static function percentualDoBenchmark(float $rentabilidade, float $benchmark): ?float
    {
        if ($benchmark <= 0) {
            return null;
        }

        return round(($rentabilidade / $benchmark) * 100, 2);
    }
}
