<?php

namespace App\Http\Controllers;

use App\Models\Account;
use App\Models\Category;
use App\Models\Transaction;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CreditCardController extends Controller
{
    private function invoicePeriod(Account $cartao, int $year, int $monthIndex): array
    {
        $closingDayRaw = (int) ($cartao->closing_day ?? 0);

        $monthStart = Carbon::create($year, $monthIndex + 1, 1)->startOfDay();
        $monthDays = (int) $monthStart->daysInMonth;
        $closingDayThisMonth = $closingDayRaw > 0 ? min($closingDayRaw, $monthDays) : 0;

        if ($closingDayThisMonth <= 0) {
            return [
                'start' => $monthStart->copy(),
                'end' => $monthStart->copy()->endOfMonth()->endOfDay(),
            ];
        }

        $end = Carbon::create($year, $monthIndex + 1, $closingDayThisMonth)->endOfDay();

        $prevMonth = $monthStart->copy()->subMonthNoOverflow();
        $prevMonthDays = (int) $prevMonth->daysInMonth;

        if ($closingDayRaw >= $prevMonthDays) {
            $start = $monthStart->copy();
        } else {
            $startDay = $closingDayRaw + 1;
            $start = Carbon::create($prevMonth->year, $prevMonth->month, $startDay)->startOfDay();
        }

        return [
            'start' => $start,
            'end' => $end,
        ];
    }

    public function index(Request $request)
    {
        $user = $request->user();

        $cartoes = Account::query()
            ->where('user_id', $user->id)
            ->where('type', 'credit_card')
            ->orderBy('id', 'desc')
            ->get()
            ->map(fn (Account $account) => [
                'id' => (string) $account->id,
                'nome' => $account->name,
                'bandeira' => ($account->card_brand ?: 'visa'),
                'limite' => (float) ($account->credit_limit ?? 0),
                'limite_usado' => (float) ($account->current_balance ?? 0),
                'dia_fechamento' => (int) ($account->closing_day ?? 10),
                'dia_vencimento' => (int) ($account->due_day ?? 17),
                'cor' => ($account->color ?: '#8B5CF6'),
            ]);

        return response()->json([
            'cartoes' => $cartoes,
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'nome' => ['required', 'string', 'max:50'],
            'bandeira' => ['nullable', 'string', 'max:30'],
            'limite' => ['required', 'numeric', 'min:0'],
            'dia_fechamento' => ['required', 'integer', 'min:1', 'max:31'],
            'dia_vencimento' => ['required', 'integer', 'min:1', 'max:31'],
            'cor' => ['nullable', 'string', 'max:20'],
            'icone' => ['nullable', 'string', 'max:50'],
            'is_primary' => ['nullable', 'boolean'],
        ]);

        $account = Account::create([
            'user_id' => $request->user()->id,
            'name' => $data['nome'],
            'type' => 'credit_card',
            'icon' => $data['icone'] ?? 'credit-card',
            'color' => $data['cor'] ?? '#8B5CF6',
            'card_brand' => $data['bandeira'] ?? 'visa',
            'initial_balance' => 0,
            'current_balance' => 0,
            'credit_limit' => $data['limite'],
            'closing_day' => $data['dia_fechamento'],
            'due_day' => $data['dia_vencimento'],
            'is_primary' => $data['is_primary'] ?? false,
        ]);

        return response()->json([
            'id' => (string) $account->id,
        ], 201);
    }

    public function update(Request $request, Account $cartao)
    {
        abort_unless($request->user()->id === $cartao->user_id, 403);
        abort_unless($cartao->type === 'credit_card', 404);

        $data = $request->validate([
            'nome' => ['sometimes', 'required', 'string', 'max:50'],
            'bandeira' => ['nullable', 'string', 'max:30'],
            'limite' => ['sometimes', 'required', 'numeric', 'min:0'],
            'dia_fechamento' => ['sometimes', 'required', 'integer', 'min:1', 'max:31'],
            'dia_vencimento' => ['sometimes', 'required', 'integer', 'min:1', 'max:31'],
            'cor' => ['nullable', 'string', 'max:20'],
            'icone' => ['nullable', 'string', 'max:50'],
            'is_primary' => ['nullable', 'boolean'],
        ]);

        $cartao->fill([
            'name' => $data['nome'] ?? $cartao->name,
            'credit_limit' => array_key_exists('limite', $data) ? $data['limite'] : $cartao->credit_limit,
            'closing_day' => array_key_exists('dia_fechamento', $data) ? $data['dia_fechamento'] : $cartao->closing_day,
            'due_day' => array_key_exists('dia_vencimento', $data) ? $data['dia_vencimento'] : $cartao->due_day,
            'icon' => $data['icone'] ?? $cartao->icon,
            'color' => $data['cor'] ?? $cartao->color,
            'card_brand' => $data['bandeira'] ?? $cartao->card_brand,
            'is_primary' => array_key_exists('is_primary', $data) ? $data['is_primary'] : $cartao->is_primary,
        ]);
        $cartao->save();

        return response()->json(['ok' => true]);
    }

    public function destroy(Request $request, Account $cartao)
    {
        abort_unless($request->user()->id === $cartao->user_id, 403);
        abort_unless($cartao->type === 'credit_card', 404);

        $userId = $request->user()->id;
        $today = Carbon::today()->toDateString();

        $totalTransactions = (int) Transaction::query()
            ->where('user_id', $userId)
            ->where('account_id', $cartao->id)
            ->count();

        $parcelasPendentes = (int) Transaction::query()
            ->where('user_id', $userId)
            ->where('account_id', $cartao->id)
            ->whereNotNull('parcelamento_grupo_id')
            ->where('status', 'pending')
            ->where('transaction_date', '>', $today)
            ->count();

        $comprasPendentes = (int) Transaction::query()
            ->where('user_id', $userId)
            ->where('account_id', $cartao->id)
            ->where('kind', 'expense')
            ->where('status', 'pending')
            ->count();

        $cartao->delete();

        return response()->json([
            'ok' => true,
            'deleted' => [
                'transactions' => $totalTransactions,
                'compras_pendentes' => $comprasPendentes,
                'parcelas_pendentes_futuras' => $parcelasPendentes,
            ],
        ]);
    }

    public function getByMonth(Request $request)
    {
        $user = $request->user();

        $data = $request->validate([
            'year' => ['required', 'integer', 'min:2020', 'max:2099'],
            'month' => ['required', 'integer', 'min:0', 'max:11'],
        ]);

        $year = (int) $data['year'];
        $month = (int) $data['month'];

        $creditCards = Account::where('user_id', $user->id)
            ->where('type', 'credit_card')
            ->get();

        $result = $creditCards->map(function (Account $account) use ($year, $month, $user) {
            $period = $this->invoicePeriod($account, $year, $month);
            $start = $period['start'];
            $end = $period['end'];

            $accountCreatedAt = $account->created_at ? Carbon::parse($account->created_at) : null;
            if ($accountCreatedAt && $accountCreatedAt->greaterThan($end)) {
                $balanceUsed = 0.0;
            } else {
                $expenseSum = (float) Transaction::query()
                    ->where('user_id', $user->id)
                    ->where('account_id', $account->id)
                    ->where('kind', 'expense')
                    ->whereBetween('transaction_date', [$start, $end])
                    ->where('status', 'pending')
                    ->sum('amount');

                $incomeSum = (float) Transaction::query()
                    ->where('user_id', $user->id)
                    ->where('account_id', $account->id)
                    ->where('kind', 'income')
                    ->whereBetween('transaction_date', [$start, $end])
                    ->whereIn('status', ['received'])
                    ->sum('amount');

                $balanceUsed = max(0.0, $expenseSum - $incomeSum);
            }

            return [
                'id' => (string) $account->id,
                'nome' => $account->name,
                'bandeira' => $account->card_brand ?: 'visa',
                'limite' => (float) ($account->credit_limit ?? 0),
                'limite_usado' => $balanceUsed,
                'dia_fechamento' => (int) ($account->closing_day ?? 10),
                'dia_vencimento' => (int) ($account->due_day ?? 17),
                'cor' => $account->color ?: '#8B5CF6',
                'is_primary' => (bool) $account->is_primary,
            ];
        });

        return response()->json([
            'cartoes' => $result->values(),
        ]);
    }

    public function payInvoice(Request $request, Account $cartao): JsonResponse
    {
        $user = $request->user();
        abort_unless((int) $cartao->user_id === (int) $user->id, 404);
        abort_unless($cartao->type === 'credit_card', 404);

        $data = $request->validate([
            'year' => ['required', 'integer', 'min:2020', 'max:2099'],
            'month' => ['required', 'integer', 'min:0', 'max:11'],
            'pay_account' => ['required', 'string', 'max:255'],
        ]);

        $year = (int) $data['year'];
        $month = (int) $data['month'];
        $payAccountName = trim((string) $data['pay_account']);

        $payAccount = Account::query()
            ->where('user_id', $user->id)
            ->where('type', '!=', 'credit_card')
            ->where('name', $payAccountName)
            ->first();

        if (!$payAccount) {
            return response()->json(['message' => 'Conta para pagamento inválida.'], 422);
        }

        $period = $this->invoicePeriod($cartao, $year, $month);
        $start = $period['start'];
        $end = $period['end'];

        $invoiceQuery = Transaction::query()
            ->where('user_id', $user->id)
            ->where('account_id', $cartao->id)
            ->where('kind', 'expense')
            ->whereBetween('transaction_date', [$start, $end])
            ->where('status', 'pending');

        $invoiceTotal = (float) $invoiceQuery->sum('amount');

        if ($invoiceTotal <= 0) {
            return response()->json([
                'paid' => true,
                'amount' => 0,
            ]);
        }

        if ((float) ($payAccount->current_balance ?? 0) < $invoiceTotal) {
            return response()->json(['message' => 'Saldo insuficiente.'], 422);
        }

        $category = Category::query()->firstOrCreate(
            [
                'user_id' => $user->id,
                'name' => 'Fatura do cartão',
                'type' => 'expense',
            ],
            [
                'is_default' => false,
                'color' => '#EF4444',
                'icon' => 'card',
            ],
        );

        Transaction::create([
            'user_id' => $user->id,
            'account_id' => $payAccount->id,
            'category_id' => $category->id,
            'kind' => 'expense',
            'status' => 'paid',
            'amount' => $invoiceTotal,
            'moeda' => $payAccount->moeda ?? 'BRL',
            'description' => sprintf('Pagamento de fatura - %s', $cartao->name),
            'transaction_date' => now()->toDateString(),
            'priority' => false,
            'is_recurring' => false,
            'is_parcelado' => false,
            'data_pagamento' => now(),
            'tags' => [],
        ]);

        $payAccount->current_balance = (float) ($payAccount->current_balance ?? 0) - $invoiceTotal;
        $payAccount->save();

        $invoiceQuery->update([
            'status' => 'paid',
            'data_pagamento' => now(),
        ]);

        return response()->json([
            'paid' => true,
            'amount' => $invoiceTotal,
        ]);
    }
}
