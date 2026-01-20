<?php

namespace App\Services;

use App\Models\Account;
use App\Models\RecorrenciaGrupo;
use App\Models\Transaction;
use App\Services\Recorrencias\RecorrenciaScheduler;
use Carbon\CarbonImmutable;

class ProjecaoService
{
    public function __construct(
        private readonly RecorrenciaScheduler $scheduler,
    ) {
    }

    public function calcularProjecao30Dias(int $userId): array
    {
        $today = CarbonImmutable::today();
        $end = $today->addDays(30);

        $cashAccountIds = $this->cashAccountIds($userId);

        $saldoAtual = (float) Account::query()
            ->where('user_id', $userId)
            ->includedInNetWorth()
            ->sum('current_balance');

        $transacoes = Transaction::query()
            ->where('user_id', $userId)
            ->where('status', 'pending')
            ->whereIn('account_id', $cashAccountIds)
            ->whereBetween('transaction_date', [$today->toDateString(), $end->toDateString()])
            ->orderBy('transaction_date', 'asc')
            ->get(['id', 'account_id', 'kind', 'amount', 'transaction_date', 'recorrencia_grupo_id']);

        $extrasRecorrencias = $this->simularRecorrenciasNaoCriadas($userId, $today, $end);
        $extrasPorConta = $this->groupExtrasByAccount($extrasRecorrencias);
        $pagamentosFaturaCartao = $this->simularPagamentosFaturaCartao($userId, $today, $end, $extrasPorConta);

        $porDia = [];
        foreach ($transacoes as $t) {
            $key = CarbonImmutable::parse($t->transaction_date)->toDateString();
            $porDia[$key][] = ['kind' => $t->kind, 'amount' => (float) $t->amount];
        }
        foreach ($extrasRecorrencias as $extra) {
            if (!in_array($extra['account_id'], $cashAccountIds, true)) {
                continue;
            }
            $porDia[$extra['date']][] = ['kind' => $extra['kind'], 'amount' => (float) $extra['amount']];
        }
        foreach ($pagamentosFaturaCartao as $payment) {
            $porDia[$payment['date']][] = ['kind' => 'expense', 'amount' => (float) $payment['amount']];
        }

        $projecaoDiaria = [];
        $saldoProjetado = $saldoAtual;
        $primeiroDiaNegativo = null;

        for ($i = 0; $i <= 30; $i++) {
            $dia = $today->addDays($i);
            $key = $dia->toDateString();

            foreach (($porDia[$key] ?? []) as $item) {
                if ($item['kind'] === 'income') {
                    $saldoProjetado += $item['amount'];
                } else {
                    $saldoProjetado -= $item['amount'];
                }
            }

            $projecaoDiaria[] = [
                'data' => $key,
                'saldo' => round($saldoProjetado, 2),
            ];

            if ($saldoProjetado < 0 && $primeiroDiaNegativo === null) {
                $primeiroDiaNegativo = $dia->format('d/m');
            }
        }

        $alerta = null;
        if ($primeiroDiaNegativo !== null) {
            $alerta = [
                'tipo' => 'negativo',
                'mensagem' => "Cuidado! No ritmo atual, seu saldo ficará negativo dia {$primeiroDiaNegativo}",
            ];
        }

        return [
            'projecao_diaria' => $projecaoDiaria,
            'saldo_dia_30' => round($saldoProjetado, 2),
            'primeiro_dia_negativo' => $primeiroDiaNegativo,
            'alerta' => $alerta,
        ];
    }

    public function gerarInsights(int $userId): array
    {
        $today = CarbonImmutable::today();
        $inicioMes = $today->startOfMonth();
        $fimMes = $today->endOfMonth();

        $cashAccountIds = $this->cashAccountIds($userId);

        $projecao = $this->calcularProjecao30Dias($userId);
        $primeiroDiaNegativo = $projecao['primeiro_dia_negativo'];

        $diasPassados = max(1, $today->diffInDays($inicioMes) + 1);

        $totalDespesasMes = (float) Transaction::query()
            ->where('user_id', $userId)
            ->where('kind', 'expense')
            ->where('status', 'paid')
            ->whereBetween('data_pagamento', [$inicioMes->startOfDay(), $today->endOfDay()])
            ->sum('amount');

        $mediaGastoDiario = $diasPassados > 0 ? ($totalDespesasMes / $diasPassados) : 0.0;

        $diasRestantes = max(0, $today->diffInDays($fimMes));
        $gastoProjetado = $mediaGastoDiario * $diasRestantes;

        $receitasPendentes = (float) Transaction::query()
            ->where('user_id', $userId)
            ->where('kind', 'income')
            ->where('status', 'pending')
            ->whereIn('account_id', $cashAccountIds)
            ->whereBetween('transaction_date', [$today->toDateString(), $fimMes->toDateString()])
            ->sum('amount');

        $saldoAtual = (float) Account::query()
            ->where('user_id', $userId)
            ->includedInNetWorth()
            ->sum('current_balance');

        $extrasRecorrenciasMes = $this->simularRecorrenciasNaoCriadas($userId, $today, $fimMes);
        $extrasRecorrenciasMesCash = array_values(array_filter(
            $extrasRecorrenciasMes,
            fn (array $extra) => in_array($extra['account_id'], $cashAccountIds, true),
        ));

        $receitasRecorrenciasMes = array_sum(array_map(
            fn (array $extra) => $extra['kind'] === 'income' ? (float) $extra['amount'] : 0.0,
            $extrasRecorrenciasMesCash,
        ));
        $despesasRecorrenciasMes = array_sum(array_map(
            fn (array $extra) => $extra['kind'] === 'expense' ? (float) $extra['amount'] : 0.0,
            $extrasRecorrenciasMesCash,
        ));

        $despesasPendentesMes = (float) Transaction::query()
            ->where('user_id', $userId)
            ->where('kind', 'expense')
            ->where('status', 'pending')
            ->whereIn('account_id', $cashAccountIds)
            ->whereBetween('transaction_date', [$today->toDateString(), $fimMes->toDateString()])
            ->sum('amount');

        $extrasPorContaMes = $this->groupExtrasByAccount($extrasRecorrenciasMes);
        $pagamentosFaturaCartaoMes = $this->simularPagamentosFaturaCartao($userId, $today, $fimMes, $extrasPorContaMes);
        $totalFaturasMes = array_sum(array_map(fn (array $p) => (float) $p['amount'], $pagamentosFaturaCartaoMes));

        $saldoFinalEstimado = $saldoAtual
            + $receitasPendentes
            + $receitasRecorrenciasMes
            - ($despesasPendentesMes + $despesasRecorrenciasMes + $totalFaturasMes);

        $insights = [];

        if ($primeiroDiaNegativo) {
            $insights[] = [
                'tipo' => 'alerta',
                'icone' => 'alert-triangle',
                'cor' => 'red',
                'titulo' => 'Atenção ao saldo!',
                'mensagem' => "No ritmo atual, seu saldo ficará negativo dia {$primeiroDiaNegativo}",
            ];
        } elseif ($saldoFinalEstimado > 0) {
            $margem = round($saldoFinalEstimado, 2);
            $insights[] = [
                'tipo' => 'positivo',
                'icone' => 'check-circle',
                'cor' => 'green',
                'titulo' => 'Tá tranquilo!',
                'mensagem' => "Você pode gastar até R$ {$margem} até o fim do mês",
            ];
        } else {
            $deficit = abs(round($saldoFinalEstimado, 2));
            $insights[] = [
                'tipo' => 'atencao',
                'icone' => 'alert-circle',
                'cor' => 'yellow',
                'titulo' => 'Atenção!',
                'mensagem' => "Você está R$ {$deficit} acima do que tem disponível para este mês",
            ];
        }

        $mesPassado = $today->subMonthNoOverflow();
        $totalDespesasMesPassado = (float) Transaction::query()
            ->where('user_id', $userId)
            ->where('kind', 'expense')
            ->where('status', 'paid')
            ->whereBetween('data_pagamento', [$mesPassado->startOfMonth()->startOfDay(), $mesPassado->endOfMonth()->endOfDay()])
            ->sum('amount');

        if ($totalDespesasMes > 0 && $totalDespesasMesPassado > 0) {
            $variacao = (($totalDespesasMes - $totalDespesasMesPassado) / $totalDespesasMesPassado) * 100;
            $variacaoFormatada = (int) round(abs($variacao));

            if ($variacao > 10) {
                $insights[] = [
                    'tipo' => 'info',
                    'icone' => 'trending-up',
                    'cor' => 'red',
                    'titulo' => "Você gastou {$variacaoFormatada}% a mais que o mês passado",
                    'mensagem' => "Suas despesas aumentaram. Revise seus gastos em 'Análise'",
                ];
            } elseif ($variacao < -10) {
                $insights[] = [
                    'tipo' => 'positivo',
                    'icone' => 'trending-down',
                    'cor' => 'green',
                    'titulo' => "Você economizou {$variacaoFormatada}% em relação ao mês passado",
                    'mensagem' => 'Continue assim! Suas finanças estão melhorando',
                ];
            }
        }

        return [
            'insights' => $insights,
            'metricas' => [
                'media_gasto_diario' => round($mediaGastoDiario, 2),
                'gasto_projetado_mes' => round($gastoProjetado, 2),
                'saldo_final_estimado' => round($saldoFinalEstimado, 2),
            ],
        ];
    }

    private function simularRecorrenciasNaoCriadas(int $userId, CarbonImmutable $start, CarbonImmutable $end): array
    {
        $grupos = RecorrenciaGrupo::query()
            ->where('user_id', $userId)
            ->where('is_active', true)
            ->where(function ($q) use ($start) {
                $q->whereNull('data_fim')->orWhere('data_fim', '>=', $start->toDateString());
            })
            ->get();

        if ($grupos->isEmpty()) {
            return [];
        }

        $existing = Transaction::query()
            ->where('user_id', $userId)
            ->whereNotNull('recorrencia_grupo_id')
            ->whereBetween('transaction_date', [$start->toDateString(), $end->toDateString()])
            ->get(['recorrencia_grupo_id', 'transaction_date'])
            ->groupBy('recorrencia_grupo_id')
            ->map(fn ($items) => $items->map(fn ($i) => CarbonImmutable::parse($i->transaction_date)->toDateString())->all())
            ->all();

        $extras = [];

        foreach ($grupos as $grupo) {
            $knownDates = $existing[$grupo->id] ?? [];

            $cursor = CarbonImmutable::parse($grupo->data_inicio);
            if ($cursor->lessThan($start)) {
                while ($cursor->lessThan($start)) {
                    $cursor = $this->scheduler->nextDate($cursor, $grupo);
                    if (!$this->scheduler->isActiveOn($grupo, $cursor)) {
                        break;
                    }
                }
            }

            while ($cursor->lessThanOrEqualTo($end) && $this->scheduler->isActiveOn($grupo, $cursor)) {
                $key = $cursor->toDateString();
                if ($cursor->greaterThanOrEqualTo($start) && !in_array($key, $knownDates, true)) {
                    $extras[] = [
                        'date' => $key,
                        'account_id' => (string) $grupo->account_id,
                        'kind' => $grupo->kind,
                        'amount' => (float) $grupo->amount,
                    ];
                }
                $cursor = $this->scheduler->nextDate($cursor, $grupo);
            }
        }

        return $extras;
    }

    private function cashAccountIds(int $userId): array
    {
        return Account::query()
            ->where('user_id', $userId)
            ->includedInNetWorth()
            ->pluck('id')
            ->map(fn ($id) => (string) $id)
            ->all();
    }

    /**
     * @param array<int, array{date:string, account_id:string, kind:string, amount:float}> $extras
     * @return array<string, array<int, array{date:string, kind:string, amount:float}>>
     */
    private function groupExtrasByAccount(array $extras): array
    {
        $by = [];
        foreach ($extras as $extra) {
            $accountId = (string) $extra['account_id'];
            $by[$accountId][] = [
                'date' => $extra['date'],
                'kind' => $extra['kind'],
                'amount' => (float) $extra['amount'],
            ];
        }
        return $by;
    }

    /**
     * Simula pagamentos de fatura de cartões de crédito como saída no fluxo de caixa,
     * considerando o due_day (vencimento) e o closing_day (fechamento).
     *
     * @param array<string, array<int, array{date:string, kind:string, amount:float}>> $extrasPorConta
     * @return array<int, array{date:string, amount:float}>
     */
    private function simularPagamentosFaturaCartao(int $userId, CarbonImmutable $start, CarbonImmutable $end, array $extrasPorConta): array
    {
        $cartoes = Account::query()
            ->where('user_id', $userId)
            ->where('type', 'credit_card')
            ->get(['id', 'closing_day', 'due_day', 'created_at']);

        if ($cartoes->isEmpty()) {
            return [];
        }

        $monthCursor = $start->startOfMonth()->subMonthNoOverflow();
        $monthEnd = $end->startOfMonth()->addMonthNoOverflow();

        $payments = [];

        while ($monthCursor->lessThanOrEqualTo($monthEnd)) {
            foreach ($cartoes as $cartao) {
                $dueDayRaw = (int) ($cartao->due_day ?? 0);
                if ($dueDayRaw <= 0) {
                    continue;
                }

                $dueDate = $this->clampDay($monthCursor, $dueDayRaw)->startOfDay();
                if ($dueDate->lessThan($start) || $dueDate->greaterThan($end)) {
                    continue;
                }

                $refMonth = $this->invoiceReferenceMonthForDue($cartao, $monthCursor);
                $period = $this->invoicePeriodForMonth($cartao, $refMonth);

                $accountCreatedAt = $cartao->created_at ? CarbonImmutable::parse($cartao->created_at) : null;
                if ($accountCreatedAt && $accountCreatedAt->greaterThan($period['end'])) {
                    continue;
                }

                $expenseSum = (float) Transaction::query()
                    ->where('user_id', $userId)
                    ->where('account_id', $cartao->id)
                    ->where('kind', 'expense')
                    ->where('status', 'pending')
                    ->whereBetween('transaction_date', [$period['start']->toDateString(), $period['end']->toDateString()])
                    ->sum('amount');

                $incomeSum = (float) Transaction::query()
                    ->where('user_id', $userId)
                    ->where('account_id', $cartao->id)
                    ->where('kind', 'income')
                    ->whereIn('status', ['received'])
                    ->whereBetween('transaction_date', [$period['start']->toDateString(), $period['end']->toDateString()])
                    ->sum('amount');

                $extras = $extrasPorConta[(string) $cartao->id] ?? [];
                $extraExpense = 0.0;
                $extraIncome = 0.0;
                foreach ($extras as $extra) {
                    $d = CarbonImmutable::parse($extra['date']);
                    if ($d->lessThan($period['start']) || $d->greaterThan($period['end'])) {
                        continue;
                    }
                    if ($extra['kind'] === 'income') {
                        $extraIncome += (float) $extra['amount'];
                    } else {
                        $extraExpense += (float) $extra['amount'];
                    }
                }

                $invoiceTotal = max(0.0, ($expenseSum + $extraExpense) - ($incomeSum + $extraIncome));
                if ($invoiceTotal <= 0) {
                    continue;
                }

                $key = $dueDate->toDateString();
                $payments[$key] = ($payments[$key] ?? 0.0) + $invoiceTotal;
            }

            $monthCursor = $monthCursor->addMonthNoOverflow();
        }

        ksort($payments);

        return array_map(
            fn (string $date, float $amount) => ['date' => $date, 'amount' => round($amount, 2)],
            array_keys($payments),
            array_values($payments),
        );
    }

    private function invoiceReferenceMonthForDue(Account $cartao, CarbonImmutable $dueMonth): CarbonImmutable
    {
        $closingDay = (int) ($cartao->closing_day ?? 0);
        $dueDay = (int) ($cartao->due_day ?? 0);

        if ($closingDay > 0 && $dueDay > 0 && $dueDay <= $closingDay) {
            return $dueMonth->subMonthNoOverflow();
        }

        return $dueMonth;
    }

    /**
     * @return array{start:CarbonImmutable, end:CarbonImmutable}
     */
    private function invoicePeriodForMonth(Account $cartao, CarbonImmutable $refMonth): array
    {
        $closingDayRaw = (int) ($cartao->closing_day ?? 0);
        $monthStart = $refMonth->startOfMonth()->startOfDay();
        $monthDays = (int) $monthStart->daysInMonth;
        $closingDayThisMonth = $closingDayRaw > 0 ? min($closingDayRaw, $monthDays) : 0;

        if ($closingDayThisMonth <= 0) {
            return [
                'start' => $monthStart,
                'end' => $monthStart->endOfMonth()->endOfDay(),
            ];
        }

        $end = $monthStart->setDay($closingDayThisMonth)->endOfDay();
        $prevMonth = $monthStart->subMonthNoOverflow();
        $prevMonthDays = (int) $prevMonth->daysInMonth;

        if ($closingDayRaw >= $prevMonthDays) {
            $start = $monthStart;
        } else {
            $startDay = $closingDayRaw + 1;
            $start = $prevMonth->setDay($startDay)->startOfDay();
        }

        return ['start' => $start, 'end' => $end];
    }

    private function clampDay(CarbonImmutable $monthStart, int $day): CarbonImmutable
    {
        $safeDay = min(max(1, $day), (int) $monthStart->daysInMonth);
        return $monthStart->startOfMonth()->setDay($safeDay);
    }
}
