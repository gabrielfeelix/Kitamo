<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Account;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AccountController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $accounts = Account::query()
            ->where('user_id', $request->user()->id)
            ->where(function ($q) {
                $q->where('is_archived', false)->orWhereNull('is_archived');
            })
            ->orderByDesc('is_primary')
            ->orderBy('name')
            ->get()
            ->map(fn (Account $a) => $this->shape($a));

        return response()->json(['accounts' => $accounts]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'type' => ['required', 'string', 'max:60'],
            'institution' => ['nullable', 'string', 'max:120'],
            'bank_account_type' => ['nullable', 'in:corrente,poupanca,salario'],
            'initial_balance' => ['nullable', 'numeric'],
            'current_balance' => ['nullable', 'numeric'],
            'credit_limit' => ['nullable', 'numeric'],
            'closing_day' => ['nullable', 'integer', 'min:1', 'max:31'],
            'due_day' => ['nullable', 'integer', 'min:1', 'max:31'],
            'color' => ['nullable', 'string', 'max:20'],
            'icon' => ['nullable', 'string', 'max:60'],
            'is_primary' => ['nullable', 'boolean'],
        ]);

        $account = Account::create([
            ...$data,
            'user_id' => $request->user()->id,
            'initial_balance' => $data['initial_balance'] ?? 0,
            'current_balance' => $data['current_balance'] ?? ($data['initial_balance'] ?? 0),
            'incluir_soma' => true,
        ]);

        return response()->json(['account' => $this->shape($account)], 201);
    }

    public function update(Request $request, Account $account): JsonResponse
    {
        $this->authorizeAccount($request, $account);

        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:120'],
            'institution' => ['nullable', 'string', 'max:120'],
            'current_balance' => ['sometimes', 'numeric'],
            'credit_limit' => ['nullable', 'numeric'],
            'closing_day' => ['nullable', 'integer', 'min:1', 'max:31'],
            'due_day' => ['nullable', 'integer', 'min:1', 'max:31'],
            'color' => ['nullable', 'string', 'max:20'],
            'icon' => ['nullable', 'string', 'max:60'],
            'is_primary' => ['sometimes', 'boolean'],
            'incluir_soma' => ['sometimes', 'boolean'],
        ]);

        $account->update($data);

        return response()->json(['account' => $this->shape($account->fresh())]);
    }

    public function destroy(Request $request, Account $account): JsonResponse
    {
        $this->authorizeAccount($request, $account);

        $account->update(['is_archived' => true]);

        return response()->json(['ok' => true]);
    }

    private function authorizeAccount(Request $request, Account $account): void
    {
        abort_if($account->user_id !== $request->user()->id, 404);
    }

    private function shape(Account $a): array
    {
        return [
            'id' => $a->id,
            'name' => $a->name,
            'type' => $a->type,
            'institution' => $a->institution,
            'bank_account_type' => $a->bank_account_type,
            'initial_balance' => (float) $a->initial_balance,
            'current_balance' => (float) $a->current_balance,
            'credit_limit' => $a->credit_limit !== null ? (float) $a->credit_limit : null,
            'closing_day' => $a->closing_day,
            'due_day' => $a->due_day,
            'incluir_soma' => (bool) $a->incluir_soma,
            'is_primary' => (bool) $a->is_primary,
            'color' => $a->color,
            'icon' => $a->icon,
        ];
    }
}
