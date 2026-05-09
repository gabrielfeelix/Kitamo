<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Account;
use App\Models\Transaction;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TransactionController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $filters = $request->validate([
            'kind' => ['nullable', 'in:expense,income'],
            'from' => ['nullable', 'date'],
            'to' => ['nullable', 'date'],
            'limit' => ['nullable', 'integer', 'min:1', 'max:500'],
        ]);

        $query = Transaction::query()
            ->where('user_id', $request->user()->id)
            ->orderByDesc('transaction_date')
            ->orderByDesc('id');

        if (! empty($filters['kind'])) {
            $query->where('kind', $filters['kind']);
        }
        if (! empty($filters['from'])) {
            $query->where('transaction_date', '>=', $filters['from']);
        }
        if (! empty($filters['to'])) {
            $query->where('transaction_date', '<=', $filters['to']);
        }

        $limit = $filters['limit'] ?? 100;
        $transactions = $query->limit($limit)->get()->map(fn (Transaction $t) => $this->shape($t));

        return response()->json(['transactions' => $transactions]);
    }

    public function show(Request $request, Transaction $transaction): JsonResponse
    {
        $this->authorizeTransaction($request, $transaction);
        return response()->json(['transaction' => $this->shape($transaction)]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'account_id' => ['required', 'integer', 'exists:accounts,id'],
            'category_id' => ['nullable', 'integer', 'exists:categories,id'],
            'kind' => ['required', 'in:expense,income'],
            'status' => ['nullable', 'in:paid,pending,received'],
            'amount' => ['required', 'numeric', 'min:0'],
            'description' => ['required', 'string', 'max:255'],
            'notes' => ['nullable', 'string', 'max:500'],
            'transaction_date' => ['required', 'date'],
            'priority' => ['nullable', 'boolean'],
        ]);

        $account = Account::where('id', $data['account_id'])
            ->where('user_id', $request->user()->id)
            ->firstOrFail();

        $transaction = Transaction::create([
            ...$data,
            'user_id' => $request->user()->id,
            'status' => $data['status'] ?? ($data['kind'] === 'income' ? 'received' : 'paid'),
            'priority' => $data['priority'] ?? false,
            'is_recurring' => false,
            'is_parcelado' => false,
        ]);

        $this->updateAccountBalance($account, $data['kind'], (float) $data['amount']);

        return response()->json(['transaction' => $this->shape($transaction)], 201);
    }

    public function update(Request $request, Transaction $transaction): JsonResponse
    {
        $this->authorizeTransaction($request, $transaction);

        $data = $request->validate([
            'category_id' => ['nullable', 'integer', 'exists:categories,id'],
            'status' => ['sometimes', 'in:paid,pending,received'],
            'amount' => ['sometimes', 'numeric', 'min:0'],
            'description' => ['sometimes', 'string', 'max:255'],
            'notes' => ['nullable', 'string', 'max:500'],
            'transaction_date' => ['sometimes', 'date'],
            'priority' => ['sometimes', 'boolean'],
        ]);

        $transaction->update($data);

        return response()->json(['transaction' => $this->shape($transaction->fresh())]);
    }

    public function destroy(Request $request, Transaction $transaction): JsonResponse
    {
        $this->authorizeTransaction($request, $transaction);

        $account = $transaction->account;
        $reverseKind = $transaction->kind === 'income' ? 'expense' : 'income';
        $amount = (float) $transaction->amount;

        $transaction->delete();

        if ($account) {
            $this->updateAccountBalance($account, $reverseKind, $amount);
        }

        return response()->json(['ok' => true]);
    }

    private function authorizeTransaction(Request $request, Transaction $transaction): void
    {
        abort_if($transaction->user_id !== $request->user()->id, 404);
    }

    private function updateAccountBalance(Account $account, string $kind, float $amount): void
    {
        $delta = $kind === 'income' ? $amount : -$amount;
        $account->current_balance = (float) $account->current_balance + $delta;
        $account->save();
    }

    private function shape(Transaction $t): array
    {
        return [
            'id' => $t->id,
            'account_id' => $t->account_id,
            'category_id' => $t->category_id,
            'kind' => $t->kind,
            'status' => $t->status,
            'amount' => (float) $t->amount,
            'description' => $t->description,
            'notes' => $t->notes,
            'transaction_date' => $t->transaction_date instanceof Carbon
                ? $t->transaction_date->format('Y-m-d')
                : $t->transaction_date,
            'priority' => (bool) $t->priority,
            'is_recurring' => (bool) $t->is_recurring,
            'is_parcelado' => (bool) $t->is_parcelado,
            'parcela_atual' => $t->parcela_atual,
            'parcela_total' => $t->parcela_total,
        ];
    }
}
