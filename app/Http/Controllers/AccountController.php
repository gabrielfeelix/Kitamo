<?php

namespace App\Http\Controllers;

use App\Models\Account;
use App\Models\Transferencia;
use App\Support\KitamoBootstrap;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Carbon\Carbon;

class AccountController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        $user = $request->user();

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'type' => ['required', 'in:wallet,bank,card,credit_card'],
            'icon' => ['nullable', 'string', 'max:64'],
            'institution' => ['nullable', 'string', 'max:255'],
            'bank_account_type' => ['nullable', 'in:corrente,poupanca,salario'],
            'color' => ['nullable', 'string', 'max:20'],
            'initial_balance' => ['nullable', 'numeric', 'min:0'],
            'credit_limit' => ['nullable', 'numeric', 'min:0'],
            'closing_day' => ['nullable', 'integer', 'min:1', 'max:31'],
            'due_day' => ['nullable', 'integer', 'min:1', 'max:31'],
            'incluir_soma' => ['nullable', 'boolean'],
            'is_primary' => ['nullable', 'boolean'],
        ]);

        $type = $data['type'] === 'card' ? 'credit_card' : $data['type'];
        $initialBalance = (float) ($data['initial_balance'] ?? 0);

        $account = Account::create([
            'user_id' => $user->id,
            'name' => $data['name'],
            'type' => $type,
            'icon' => $data['icon'] ?? null,
            'institution' => $data['institution'] ?? null,
            'bank_account_type' => $data['bank_account_type'] ?? null,
            'color' => $data['color'] ?? null,
            'initial_balance' => $initialBalance,
            'current_balance' => $initialBalance,
            'credit_limit' => $data['credit_limit'] ?? null,
            'closing_day' => $data['closing_day'] ?? null,
            'due_day' => $data['due_day'] ?? null,
            'incluir_soma' => $data['incluir_soma'] ?? true,
            'is_primary' => $data['is_primary'] ?? false,
        ]);

        return response()->json([
            'account' => app(KitamoBootstrap::class)->account($account),
        ]);
    }

    public function update(Request $request, Account $account): JsonResponse
    {
        $user = $request->user();
        abort_unless((int) $account->user_id === (int) $user->id, 404);

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'type' => ['required', 'in:wallet,bank,card,credit_card'],
            'icon' => ['nullable', 'string', 'max:64'],
            'institution' => ['nullable', 'string', 'max:255'],
            'bank_account_type' => ['nullable', 'in:corrente,poupanca,salario'],
            'color' => ['nullable', 'string', 'max:20'],
            'initial_balance' => ['nullable', 'numeric', 'min:0'],
            'current_balance' => ['nullable', 'numeric'],
            'credit_limit' => ['nullable', 'numeric', 'min:0'],
            'closing_day' => ['nullable', 'integer', 'min:1', 'max:31'],
            'due_day' => ['nullable', 'integer', 'min:1', 'max:31'],
            'incluir_soma' => ['nullable', 'boolean'],
            'is_primary' => ['nullable', 'boolean'],
        ]);

        $type = $data['type'] === 'card' ? 'credit_card' : $data['type'];

        $account->fill([
            'name' => $data['name'],
            'type' => $type,
            'icon' => $data['icon'] ?? null,
            'institution' => array_key_exists('institution', $data) ? ($data['institution'] ?: null) : $account->institution,
            'bank_account_type' => array_key_exists('bank_account_type', $data) ? ($data['bank_account_type'] ?: null) : $account->bank_account_type,
            'color' => $data['color'] ?? $account->color,
            'credit_limit' => $data['credit_limit'] ?? $account->credit_limit,
            'closing_day' => $data['closing_day'] ?? $account->closing_day,
            'due_day' => $data['due_day'] ?? $account->due_day,
            'incluir_soma' => array_key_exists('incluir_soma', $data) ? $data['incluir_soma'] : $account->incluir_soma,
            'is_primary' => array_key_exists('is_primary', $data) ? $data['is_primary'] : $account->is_primary,
        ]);
        if (array_key_exists('initial_balance', $data)) {
            $account->initial_balance = $data['initial_balance'];
        }
        if (array_key_exists('current_balance', $data)) {
            $account->current_balance = $data['current_balance'];
        }
        $account->save();

        return response()->json([
            'account' => app(KitamoBootstrap::class)->account($account),
        ]);
    }

    public function destroy(Request $request, Account $account): JsonResponse
    {
        $user = $request->user();
        abort_unless((int) $account->user_id === (int) $user->id, 404);

        $transactionsCount = $account->transactions()->count();
        $transferenciasSaida = Transferencia::query()
            ->where('user_id', $user->id)
            ->where('conta_origem_id', $account->id)
            ->count();
        $transferenciasEntrada = Transferencia::query()
            ->where('user_id', $user->id)
            ->where('conta_destino_id', $account->id)
            ->count();

        $account->delete();

        return response()->json([
            'ok' => true,
            'deleted' => [
                'transactions' => $transactionsCount,
                'transferencias_saida' => $transferenciasSaida,
                'transferencias_entrada' => $transferenciasEntrada,
            ],
        ]);
    }

    public function getByMonth(Request $request): JsonResponse
    {
        $user = $request->user();
        
        $data = $request->validate([
            'year' => ['required', 'integer', 'min:2020', 'max:2099'],
            'month' => ['required', 'integer', 'min:0', 'max:11'],
        ]);

        $year = (int) $data['year'];
        $month = (int) $data['month'];

        // Get the first and last day of the month
        $startOfMonth = Carbon::create($year, $month + 1, 1)->startOfDay();
        $endOfMonth = $startOfMonth->copy()->endOfMonth()->endOfDay();
        $now = Carbon::now();

        $currentMonthStart = $now->copy()->startOfMonth();
        $mode = $startOfMonth->isSameMonth($now)
            ? 'current'
            : ($startOfMonth->lessThan($currentMonthStart) ? 'past' : 'future');

        $accounts = Account::where('user_id', $user->id)
            ->where('type', '!=', 'credit_card')
            ->get();

        $result = $accounts->map(function (Account $account) use ($startOfMonth, $endOfMonth, $user, $mode, $now) {
            $accountCreatedAt = $account->created_at ? Carbon::parse($account->created_at) : null;
            if ($accountCreatedAt && $accountCreatedAt->greaterThan($endOfMonth)) {
                return [
                    'id' => $account->id,
                    'name' => $account->name,
                    'type' => $account->type,
                    'icon' => $account->icon,
                    'color' => $account->color,
                    'current_balance' => 0.0,
                    'initial_balance' => (float) $account->initial_balance,
                    'credit_limit' => $account->credit_limit,
                    'closing_day' => $account->closing_day,
                    'due_day' => $account->due_day,
                    'subtitle' => $account->type === 'wallet' ? 'Dinheiro físico' : ($account->type === 'bank' ? 'Corrente' : 'Conta'),
                    'has_data' => false,
                    'balance_kind' => 'none',
                ];
            }

            if ($mode === 'current') {
                return [
                    'id' => $account->id,
                    'name' => $account->name,
                    'type' => $account->type,
                    'icon' => $account->icon,
                    'color' => $account->color,
                    'current_balance' => (float) ($account->current_balance ?? 0),
                    'initial_balance' => (float) $account->initial_balance,
                    'credit_limit' => $account->credit_limit,
                    'closing_day' => $account->closing_day,
                    'due_day' => $account->due_day,
                    'subtitle' => $account->type === 'wallet' ? 'Dinheiro físico' : ($account->type === 'bank' ? 'Saldo atual' : 'Conta'),
                    'has_data' => true,
                    'balance_kind' => 'real',
                ];
            }

            // Get all transactions for this account in this month
            if ($mode === 'past') {
                $startDate = $startOfMonth->toDateString();
                $endDate = $endOfMonth->toDateString();

                $transferStart = $startOfMonth->toDateTimeString();
                $transferEnd = $endOfMonth->toDateTimeString();

                $incomeBefore = (float) $account->transactions()
                    ->where('user_id', $user->id)
                    ->where('kind', 'income')
                    ->where('status', 'received')
                    ->whereNotNull('data_pagamento')
                    ->where('data_pagamento', '<', $transferStart)
                    ->sum('amount');

                $incomeBeforeFallback = (float) $account->transactions()
                    ->where('user_id', $user->id)
                    ->where('kind', 'income')
                    ->where('status', 'received')
                    ->whereNull('data_pagamento')
                    ->where('transaction_date', '<', $startDate)
                    ->sum('amount');

                $expenseBefore = (float) $account->transactions()
                    ->where('user_id', $user->id)
                    ->where('kind', 'expense')
                    ->where('status', 'paid')
                    ->whereNotNull('data_pagamento')
                    ->where('data_pagamento', '<', $transferStart)
                    ->sum('amount');

                $expenseBeforeFallback = (float) $account->transactions()
                    ->where('user_id', $user->id)
                    ->where('kind', 'expense')
                    ->where('status', 'paid')
                    ->whereNull('data_pagamento')
                    ->where('transaction_date', '<', $startDate)
                    ->sum('amount');

                $incomeMonth = (float) $account->transactions()
                    ->where('user_id', $user->id)
                    ->where('kind', 'income')
                    ->where('status', 'received')
                    ->whereNotNull('data_pagamento')
                    ->whereBetween('data_pagamento', [$transferStart, $transferEnd])
                    ->sum('amount');

                $incomeMonthFallback = (float) $account->transactions()
                    ->where('user_id', $user->id)
                    ->where('kind', 'income')
                    ->where('status', 'received')
                    ->whereNull('data_pagamento')
                    ->whereBetween('transaction_date', [$startDate, $endDate])
                    ->sum('amount');

                $expenseMonth = (float) $account->transactions()
                    ->where('user_id', $user->id)
                    ->where('kind', 'expense')
                    ->where('status', 'paid')
                    ->whereNotNull('data_pagamento')
                    ->whereBetween('data_pagamento', [$transferStart, $transferEnd])
                    ->sum('amount');

                $expenseMonthFallback = (float) $account->transactions()
                    ->where('user_id', $user->id)
                    ->where('kind', 'expense')
                    ->where('status', 'paid')
                    ->whereNull('data_pagamento')
                    ->whereBetween('transaction_date', [$startDate, $endDate])
                    ->sum('amount');

                $incomingTransfersBefore = (float) Transferencia::query()
                    ->where('user_id', $user->id)
                    ->where('conta_destino_id', $account->id)
                    ->where('transferido_em', '<', $transferStart)
                    ->sum('valor');

                $outgoingTransfersBefore = (float) Transferencia::query()
                    ->where('user_id', $user->id)
                    ->where('conta_origem_id', $account->id)
                    ->where('transferido_em', '<', $transferStart)
                    ->sum('valor');

                $incomingTransfersMonth = (float) Transferencia::query()
                    ->where('user_id', $user->id)
                    ->where('conta_destino_id', $account->id)
                    ->whereBetween('transferido_em', [$transferStart, $transferEnd])
                    ->sum('valor');

                $outgoingTransfersMonth = (float) Transferencia::query()
                    ->where('user_id', $user->id)
                    ->where('conta_origem_id', $account->id)
                    ->whereBetween('transferido_em', [$transferStart, $transferEnd])
                    ->sum('valor');

                $balanceAtMonth = (float) $account->initial_balance
                    + ($incomeBefore + $incomeBeforeFallback)
                    - ($expenseBefore + $expenseBeforeFallback)
                    + $incomingTransfersBefore
                    - $outgoingTransfersBefore
                    + ($incomeMonth + $incomeMonthFallback)
                    - ($expenseMonth + $expenseMonthFallback)
                    + $incomingTransfersMonth
                    - $outgoingTransfersMonth;

                return [
                    'id' => $account->id,
                    'name' => $account->name,
                    'type' => $account->type,
                    'icon' => $account->icon,
                    'color' => $account->color,
                    'current_balance' => (float) $balanceAtMonth,
                    'initial_balance' => (float) $account->initial_balance,
                    'credit_limit' => $account->credit_limit,
                    'closing_day' => $account->closing_day,
                    'due_day' => $account->due_day,
                    'subtitle' => $account->type === 'wallet' ? 'Fechamento do mês' : 'Fechamento do mês',
                    'has_data' => true,
                    'balance_kind' => 'closing',
                ];
            }

            $projectionBase = (float) ($account->current_balance ?? 0);
            $futureTransactions = $account->transactions()
                ->where('user_id', $user->id)
                ->where('transaction_date', '>', $now->toDateString())
                ->whereBetween('transaction_date', [$startOfMonth->toDateString(), $endOfMonth->toDateString()])
                ->where('status', 'pending')
                ->get();

            foreach ($futureTransactions as $transaction) {
                $projectionBase += $transaction->kind === 'income' ? (float) $transaction->amount : -(float) $transaction->amount;
            }

            return [
                'id' => $account->id,
                'name' => $account->name,
                'type' => $account->type,
                'icon' => $account->icon,
                'color' => $account->color,
                'current_balance' => (float) $projectionBase,
                'initial_balance' => (float) $account->initial_balance,
                'credit_limit' => $account->credit_limit,
                'closing_day' => $account->closing_day,
                'due_day' => $account->due_day,
                'subtitle' => $account->type === 'wallet' ? 'Projeção' : 'Projeção',
                'has_data' => true,
                'balance_kind' => 'projection',
            ];
        });

        return response()->json([
            'mode' => $mode,
            'accounts' => $result->values(),
        ]);
    }
}
