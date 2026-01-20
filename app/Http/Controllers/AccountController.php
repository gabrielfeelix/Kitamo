<?php

namespace App\Http\Controllers;

use App\Models\Account;
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
            'color' => ['nullable', 'string', 'max:20'],
            'initial_balance' => ['nullable', 'numeric', 'min:0'],
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
        $account->save();

        return response()->json([
            'account' => app(KitamoBootstrap::class)->account($account),
        ]);
    }

    public function destroy(Request $request, Account $account): JsonResponse
    {
        $user = $request->user();
        abort_unless((int) $account->user_id === (int) $user->id, 404);

        $account->delete();

        return response()->json(['ok' => true]);
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
        $endOfMonth = $startOfMonth->copy()->endOfMonth();

        $accounts = Account::where('user_id', $user->id)
            ->where('type', '!=', 'credit_card')
            ->get();

        $result = $accounts->map(function (Account $account) use ($startOfMonth, $endOfMonth, $user) {
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
                ];
            }

            // Get all transactions for this account in this month
            $transactions = $account->transactions()
                ->where('user_id', $user->id)
                ->whereBetween('transaction_date', [$startOfMonth, $endOfMonth])
                ->whereIn('status', ['paid', 'received'])
                ->get();

            // Calculate balance at end of month
            $balanceAtMonth = $account->initial_balance;
            
            // Get all transactions before the start of the month
            $transactionsBefore = $account->transactions()
                ->where('user_id', $user->id)
                ->where('transaction_date', '<', $startOfMonth)
                ->whereIn('status', ['paid', 'received'])
                ->get();

            foreach ($transactionsBefore as $transaction) {
                if ($transaction->kind === 'income') {
                    $balanceAtMonth += $transaction->amount;
                } else {
                    $balanceAtMonth -= $transaction->amount;
                }
            }

            // Apply transactions for this month
            foreach ($transactions as $transaction) {
                if ($transaction->kind === 'income') {
                    $balanceAtMonth += $transaction->amount;
                } else {
                    $balanceAtMonth -= $transaction->amount;
                }
            }

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
                'subtitle' => $account->type === 'wallet' ? 'Dinheiro físico' : ($account->type === 'bank' ? 'Corrente' : 'Conta'),
            ];
        });

        return response()->json([
            'accounts' => $result->values(),
        ]);
    }
}
