<?php

namespace App\Services;

use App\Models\Account;
use App\Models\Divida;
use App\Models\PerfilFinanceiro;
use Carbon\CarbonImmutable;
use Illuminate\Support\Collection;

/**
 * O horizonte: a planilha do Breno, mas falando. Spec §3.2.
 *
 * Duas diferenças em relação a uma projeção comum, e as duas são o produto:
 *
 * 1. Cada linha tem nome. Não "4 · R$ 1.534" mas "dia 4 · parcela do
 *    Nubank · R$ 1.534".
 * 2. Toda cor vem com motivo. Vermelho sem explicação é só um susto; o que
 *    ajuda é "a parcela do dia 4 cai antes do salário do dia 6".
 *
 * As cores são os estados de docs/DESIGN-KITAMO.md: tranquilo, atencao,
 * aperto. Nomes de estado, não de emoção — a tela decide como pintar.
 */
class HorizonteService
{
    public const TRANQUILO = 'tranquilo';
    public const ATENCAO = 'atencao';
    public const APERTO = 'aperto';

    /**
     * Um mês, dia a dia.
     *
     * @return array{
     *   mes: string,
     *   dias: array<int, array{
     *     data: string, dia: int, saldo: float, estado: string,
     *     motivo: ?string, lancamentos: array<int, array{nome:string, valor:float, tipo:string}>
     *   }>,
     *   primeiro_dia_apertado: ?string,
     *   saldo_final: float,
     * }
     */
    public function mes(int $userId, ?CarbonImmutable $referencia = null): array
    {
        $ref = ($referencia ?? CarbonImmutable::today())->startOfMonth();

        $perfil = PerfilFinanceiro::query()->where('user_id', $userId)->first();
        $dividas = Divida::query()->where('user_id', $userId)->emAberto()->get();

        $saldo = $this->saldoInicial($userId);
        $diarioEstimado = (float) ($perfil?->gasto_diario_estimado ?? 0);

        $dias = [];
        $primeiroApertado = null;

        for ($d = 1; $d <= $ref->daysInMonth; $d++) {
            $dia = $ref->setDay($d);

            $lancamentos = $this->lancamentosDoDia($dia, $perfil, $dividas);

            foreach ($lancamentos as $l) {
                $saldo += $l['tipo'] === 'entrada' ? $l['valor'] : -$l['valor'];
            }

            // O gasto do dia a dia também consome saldo, senão a projeção
            // mostraria um mês folgado que não existe.
            $saldo -= $diarioEstimado;

            $saldo = round($saldo, 2);
            $estado = $this->estado($saldo);

            if ($estado === self::APERTO && $primeiroApertado === null) {
                $primeiroApertado = $dia->toDateString();
            }

            $dias[] = [
                'data' => $dia->toDateString(),
                'dia' => $d,
                'saldo' => $saldo,
                'estado' => $estado,
                'motivo' => $this->motivo($estado, $lancamentos, $dia, $perfil),
                'lancamentos' => $lancamentos,
            ];
        }

        return [
            'mes' => $ref->format('Y-m'),
            'dias' => $dias,
            'primeiro_dia_apertado' => $primeiroApertado,
            'saldo_final' => $saldo,
        ];
    }

    /**
     * Doze meses em colunas. É onde a pessoa vê a dívida acabando.
     *
     * @return array<int, array{
     *   mes: string, label: string, saldo_final: float, estado: string,
     *   parcelas: float, tem_divida: bool
     * }>
     */
    public function doze(int $userId, ?CarbonImmutable $referencia = null): array
    {
        $ref = ($referencia ?? CarbonImmutable::today())->startOfMonth();

        $perfil = PerfilFinanceiro::query()->where('user_id', $userId)->first();
        $dividas = Divida::query()->where('user_id', $userId)->emAberto()->get();

        $renda = (float) ($perfil?->renda_mensal ?? 0);
        $fixas = (float) ($perfil?->contas_fixas_estimadas ?? 0);
        $diario = (float) ($perfil?->gasto_diario_estimado ?? 0);

        $saldo = $this->saldoInicial($userId);
        $meses = [];

        for ($i = 0; $i < 12; $i++) {
            $mes = $ref->addMonthsNoOverflow($i);

            // Uma dívida só pesa enquanto tiver parcela naquele mês.
            $parcelas = (float) $dividas
                ->filter(fn (Divida $d) => $i < $d->parcelas_restantes)
                ->sum(fn (Divida $d) => (float) $d->valor_parcela);

            $saldo = round($saldo + $renda - $fixas - $parcelas - ($diario * $mes->daysInMonth), 2);

            $meses[] = [
                'mes' => $mes->format('Y-m'),
                'label' => $this->rotuloCurto($mes),
                'saldo_final' => $saldo,
                'estado' => $this->estado($saldo),
                'parcelas' => round($parcelas, 2),
                'tem_divida' => $parcelas > 0,
            ];
        }

        return $meses;
    }

    /**
     * @param Collection<int, Divida> $dividas
     * @return array<int, array{nome:string, valor:float, tipo:string}>
     */
    private function lancamentosDoDia(
        CarbonImmutable $dia,
        ?PerfilFinanceiro $perfil,
        Collection $dividas
    ): array {
        $itens = [];

        if ($perfil && $perfil->dia_renda && $this->caiNesteDia((int) $perfil->dia_renda, $dia)) {
            $itens[] = [
                'nome' => 'salário',
                'valor' => (float) $perfil->renda_mensal,
                'tipo' => 'entrada',
            ];
        }

        foreach ($dividas as $divida) {
            if ($divida->parcelas_restantes > 0 && $this->caiNesteDia($divida->dia_vencimento, $dia)) {
                $itens[] = [
                    'nome' => "parcela do {$divida->nome}",
                    'valor' => (float) $divida->valor_parcela,
                    'tipo' => 'saida',
                ];
            }
        }

        return $itens;
    }

    /**
     * Um vencimento dia 31 precisa cair no último dia dos meses curtos,
     * senão simplesmente não aparece em fevereiro — e a parcela some da
     * projeção justo no mês mais apertado.
     */
    private function caiNesteDia(int $diaAlvo, CarbonImmutable $dia): bool
    {
        return $dia->day === min($diaAlvo, $dia->daysInMonth);
    }

    private function estado(float $saldo): string
    {
        if ($saldo < 0) {
            return self::APERTO;
        }

        // Abaixo de R$ 100 ainda não é vermelho, mas avisar cedo é o ponto
        // do horizonte: dá tempo de agir antes de estourar.
        return $saldo < 100 ? self::ATENCAO : self::TRANQUILO;
    }

    /**
     * A frase que acompanha a cor. Só existe quando há o que explicar —
     * dia tranquilo não precisa de legenda.
     *
     * @param array<int, array{nome:string, valor:float, tipo:string}> $lancamentos
     */
    private function motivo(
        string $estado,
        array $lancamentos,
        CarbonImmutable $dia,
        ?PerfilFinanceiro $perfil
    ): ?string {
        if ($estado === self::TRANQUILO) {
            return null;
        }

        $saidas = array_values(array_filter($lancamentos, fn ($l) => $l['tipo'] === 'saida'));

        if ($saidas !== []) {
            $nome = $saidas[0]['nome'];

            // O caso que custou R$ 1.674 ao Gabriel em 12 meses: a parcela
            // vence antes de a renda cair.
            if ($perfil?->dia_renda && $dia->day < (int) $perfil->dia_renda) {
                return "a {$nome} cai antes do salário do dia {$perfil->dia_renda}";
            }

            return "aqui sai a {$nome}";
        }

        return $estado === self::APERTO
            ? 'o saldo fica negativo neste dia'
            : 'o saldo fica baixo neste dia';
    }

    private function saldoInicial(int $userId): float
    {
        return (float) Account::query()
            ->where('user_id', $userId)
            ->includedInNetWorth()
            ->sum('current_balance');
    }

    private function rotuloCurto(CarbonImmutable $data): string
    {
        $meses = [1 => 'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
                  'jul', 'ago', 'set', 'out', 'nov', 'dez'];

        return $meses[(int) $data->month] . '/' . $data->format('y');
    }
}
