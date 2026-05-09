<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Account;
use App\Models\Transaction;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class TransferController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'from_account_id' => ['required', 'integer', 'different:to_account_id', 'exists:accounts,id'],
            'to_account_id' => ['required', 'integer', 'exists:accounts,id'],
            'amount' => ['required', 'numeric', 'min:0.01'],
            'transaction_date' => ['required', 'date'],
            'notes' => ['nullable', 'string', 'max:500'],
        ]);

        $userId = $request->user()->id;

        $from = Account::where('id', $data['from_account_id'])->where('user_id', $userId)->first();
        $to = Account::where('id', $data['to_account_id'])->where('user_id', $userId)->first();

        if (! $from || ! $to) {
            throw ValidationException::withMessages([
                'account' => ['Conta não encontrada.'],
            ]);
        }

        $amount = (float) $data['amount'];
        $groupId = (string) Str::uuid();
        $description = sprintf('Transferência %s → %s', $from->name, $to->name);

        DB::transaction(function () use ($userId, $from, $to, $amount, $data, $groupId, $description) {
            Transaction::create([
                'user_id' => $userId,
                'account_id' => $from->id,
                'category_id' => null,
                'kind' => 'expense',
                'status' => 'paid',
                'amount' => $amount,
                'description' => $description,
                'transaction_date' => $data['transaction_date'],
                'notes' => $data['notes'] ?? "Transferência (saída) [grupo:{$groupId}]",
                'priority' => false,
                'is_recurring' => false,
                'is_parcelado' => false,
            ]);

            Transaction::create([
                'user_id' => $userId,
                'account_id' => $to->id,
                'category_id' => null,
                'kind' => 'income',
                'status' => 'received',
                'amount' => $amount,
                'description' => $description,
                'transaction_date' => $data['transaction_date'],
                'notes' => $data['notes'] ?? "Transferência (entrada) [grupo:{$groupId}]",
                'priority' => false,
                'is_recurring' => false,
                'is_parcelado' => false,
            ]);

            $from->current_balance = (float) $from->current_balance - $amount;
            $from->save();

            $to->current_balance = (float) $to->current_balance + $amount;
            $to->save();
        });

        return response()->json(['ok' => true], 201);
    }
}
