<?php

namespace App\Services;

use App\Models\Divida;
use App\Models\PerfilFinanceiro;
use Carbon\CarbonImmutable;

/**
 * O número da tela inicial: "pra quitar até janeiro, seu diário é R$ 23".
 * Spec §3.1.
 *
 * Determinístico, sem LLM:
 *
 *   renda_mensal − contas_fixas − parcelas_do_mês = sobra_mensal
 *   diário = sobra_mensal / dias_do_mês
 *
 * A regra que não pode ser quebrada: quando a sobra é negativa o app não
 * esconde e não mostra "R$ 0". Ele diz quanto falta. Um diário de R$ 0
 * fingiria que dá pra viver sem gastar nada — e a pessoa endividada já
 * sabe que não dá.
 */
class DiarioService
{
    /**
     * @return array{
     *   diario: float,
     *   sobra_mensal: float,
     *   renda_mensal: float,
     *   contas_fixas: float,
     *   parcelas_do_mes: float,
     *   dias_no_mes: int,
     *   fecha: bool,
     *   falta_por_mes: float,
     *   quitacao_em: ?string,
     *   quitacao_label: ?string,
     *   tem_dividas: bool,
     * }
     */
    public function calcular(int $userId, ?CarbonImmutable $referencia = null): array
    {
        $hoje = $referencia?->startOfDay() ?? CarbonImmutable::today();

        $perfil = PerfilFinanceiro::query()->where('user_id', $userId)->first();

        $renda = (float) ($perfil?->renda_mensal ?? 0);
        $fixas = (float) ($perfil?->contas_fixas_estimadas ?? 0);

        $dividas = Divida::query()
            ->where('user_id', $userId)
            ->emAberto()
            ->get();

        $parcelas = $this->parcelasDoMes($dividas);

        $sobra = round($renda - $fixas - $parcelas, 2);
        $diasNoMes = $hoje->daysInMonth;

        $fecha = $sobra > 0;

        $quitacao = $this->previsaoQuitacao($dividas, $hoje);

        return [
            'diario' => $fecha ? round($sobra / $diasNoMes, 2) : 0.0,
            'sobra_mensal' => $sobra,
            'renda_mensal' => round($renda, 2),
            'contas_fixas' => round($fixas, 2),
            'parcelas_do_mes' => round($parcelas, 2),
            'dias_no_mes' => $diasNoMes,
            'fecha' => $fecha,
            // Quanto falta por mês para a conta fechar. Zero quando fecha.
            'falta_por_mes' => $fecha ? 0.0 : round(abs($sobra), 2),
            'quitacao_em' => $quitacao?->toDateString(),
            'quitacao_label' => $quitacao ? $this->rotularMes($quitacao) : null,
            'tem_dividas' => $dividas->isNotEmpty(),
        ];
    }

    /**
     * Soma das parcelas que caem no mês. Uma dívida só entra se ainda tem
     * parcela restante — dívida quitada não pesa no diário.
     *
     * @param \Illuminate\Support\Collection<int, Divida> $dividas
     */
    private function parcelasDoMes($dividas): float
    {
        return (float) $dividas
            ->filter(fn (Divida $d) => $d->parcelas_restantes > 0)
            ->sum(fn (Divida $d) => (float) $d->valor_parcela);
    }

    /**
     * A data de quitação é a mais tardia entre as dívidas (spec §3.1):
     * o app só promete "livre" quando a última parcela cair.
     *
     * @param \Illuminate\Support\Collection<int, Divida> $dividas
     */
    private function previsaoQuitacao($dividas, CarbonImmutable $hoje): ?CarbonImmutable
    {
        $datas = $dividas
            ->map(fn (Divida $d) => $d->previsaoQuitacao($hoje))
            ->filter()
            ->values();

        if ($datas->isEmpty()) {
            return null;
        }

        return $datas->sortDesc()->first();
    }

    /** "janeiro", ou "janeiro de 2028" quando não é o ano corrente nem o próximo. */
    private function rotularMes(CarbonImmutable $data): string
    {
        $meses = [
            1 => 'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
            'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
        ];

        $nome = $meses[(int) $data->month];

        return $data->year > CarbonImmutable::today()->year + 1
            ? "{$nome} de {$data->year}"
            : $nome;
    }
}
