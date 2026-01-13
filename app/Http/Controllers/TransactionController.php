<?php

namespace App\Http\Controllers;

use App\Models\Account;
use App\Models\Category;
use App\Models\Transaction;
use App\Support\KitamoBootstrap;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TransactionController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        $user = $request->user();

        $data = $request->validate([
            'kind' => ['required', 'in:income,expense'],
            'amount' => ['required', 'numeric', 'min:0.01'],
            'description' => ['required', 'string', 'max:255'],
            'category' => ['nullable', 'string', 'max:255'],
            'account' => ['nullable', 'string', 'max:255'],
            'dateKind' => ['nullable', 'in:today,other'],
            'dateOther' => ['nullable', 'date'],
            'isPaid' => ['nullable', 'boolean'],
            'isInstallment' => ['nullable', 'boolean'],
            'installmentCount' => ['nullable', 'integer', 'min:1', 'max:99'],
            'tags' => ['nullable', 'array'],
            'tags.*' => ['string', 'max:50'],
        ]);

        $accountName = trim($data['account'] ?? 'Carteira');
        $account = Account::firstOrCreate(
            ['user_id' => $user->id, 'name' => $accountName],
            ['type' => 'wallet', 'initial_balance' => 0, 'current_balance' => 0]
        );

        $categoryName = trim($data['category'] ?? 'Outros');
        $category = Category::firstOrCreate(
            ['user_id' => $user->id, 'name' => $categoryName, 'type' => $data['kind']],
            ['is_default' => false]
        );

        $date = ($data['dateKind'] ?? 'today') === 'other' && !empty($data['dateOther'])
            ? $data['dateOther']
            : now()->toDateString();

        $status = $data['kind'] === 'income'
            ? 'received'
            : (!empty($data['isPaid']) ? 'paid' : 'pending');

        $installmentLabel = null;
        $installmentIndex = null;
        $installmentTotal = null;

        if (!empty($data['isInstallment']) && !empty($data['installmentCount']) && $data['installmentCount'] > 1) {
            $installmentIndex = 1;
            $installmentTotal = (int) $data['installmentCount'];
            $installmentLabel = "Parcela {$installmentIndex}/{$installmentTotal}";
        }

        $transaction = Transaction::create([
            'user_id' => $user->id,
            'account_id' => $account->id,
            'category_id' => $category->id,
            'kind' => $data['kind'],
            'status' => $status,
            'amount' => $data['amount'],
            'description' => $data['description'],
            'transaction_date' => $date,
            'priority' => false,
            'installment_label' => $installmentLabel,
            'installment_index' => $installmentIndex,
            'installment_total' => $installmentTotal,
            'is_recurring' => false,
            'tags' => $data['tags'] ?? [],
        ]);

        $this->applyBalanceAdjustment($account, $transaction, 1);

        return response()->json([
            'entry' => app(KitamoBootstrap::class)->entry($transaction->load(['category', 'account'])),
        ]);
    }

    public function update(Request $request, Transaction $transaction): JsonResponse
    {
        $user = $request->user();
        if ($transaction->user_id !== $user->id) {
            abort(404);
        }

        $data = $request->validate([
            'kind' => ['required', 'in:income,expense'],
            'amount' => ['required', 'numeric', 'min:0.01'],
            'description' => ['required', 'string', 'max:255'],
            'category' => ['nullable', 'string', 'max:255'],
            'account' => ['nullable', 'string', 'max:255'],
            'dateKind' => ['nullable', 'in:today,other'],
            'dateOther' => ['nullable', 'date'],
            'isPaid' => ['nullable', 'boolean'],
            'isInstallment' => ['nullable', 'boolean'],
            'installmentCount' => ['nullable', 'integer', 'min:1', 'max:99'],
            'tags' => ['nullable', 'array'],
            'tags.*' => ['string', 'max:50'],
        ]);

        $this->applyBalanceAdjustment($transaction->account, $transaction, -1);

        $accountName = trim($data['account'] ?? $transaction->account?->name ?? 'Carteira');
        $account = Account::firstOrCreate(
            ['user_id' => $user->id, 'name' => $accountName],
            ['type' => 'wallet', 'initial_balance' => 0, 'current_balance' => 0]
        );

        $categoryName = trim($data['category'] ?? $transaction->category?->name ?? 'Outros');
        $category = Category::firstOrCreate(
            ['user_id' => $user->id, 'name' => $categoryName, 'type' => $data['kind']],
            ['is_default' => false]
        );

        $date = ($data['dateKind'] ?? 'today') === 'other' && !empty($data['dateOther'])
            ? $data['dateOther']
            : now()->toDateString();

        $status = $data['kind'] === 'income'
            ? 'received'
            : (!empty($data['isPaid']) ? 'paid' : 'pending');

        $installmentLabel = null;
        $installmentIndex = null;
        $installmentTotal = null;

        if (!empty($data['isInstallment']) && !empty($data['installmentCount']) && $data['installmentCount'] > 1) {
            $installmentIndex = 1;
            $installmentTotal = (int) $data['installmentCount'];
            $installmentLabel = "Parcela {$installmentIndex}/{$installmentTotal}";
        }

        $transaction->update([
            'account_id' => $account->id,
            'category_id' => $category->id,
            'kind' => $data['kind'],
            'status' => $status,
            'amount' => $data['amount'],
            'description' => $data['description'],
            'transaction_date' => $date,
            'installment_label' => $installmentLabel,
            'installment_index' => $installmentIndex,
            'installment_total' => $installmentTotal,
            'tags' => $data['tags'] ?? [],
        ]);

        $transaction->refresh();
        $this->applyBalanceAdjustment($transaction->account, $transaction, 1);

        return response()->json([
            'entry' => app(KitamoBootstrap::class)->entry($transaction->load(['category', 'account'])),
        ]);
    }

    public function destroy(Request $request, Transaction $transaction): JsonResponse
    {
        $user = $request->user();
        if ($transaction->user_id !== $user->id) {
            abort(404);
        }

        $this->applyBalanceAdjustment($transaction->account, $transaction, -1);
        $transaction->delete();

        return response()->json(['ok' => true]);
    }

    private function applyBalanceAdjustment(?Account $account, Transaction $transaction, int $direction): void
    {
        if (!$account) {
            return;
        }

        $isEffective = in_array($transaction->status, ['paid', 'received'], true);
        if (!$isEffective) {
            return;
        }

        $amount = (float) $transaction->amount;
        $delta = $transaction->kind === 'income' ? $amount : -$amount;
        $account->current_balance = ($account->current_balance ?? 0) + ($delta * $direction);
        $account->save();
    }
}
