<?php

namespace App\Http\Controllers;

use App\Models\Goal;
use App\Models\GoalDeposit;
use App\Support\KitamoBootstrap;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GoalDepositController extends Controller
{
    public function store(Request $request, Goal $goal): JsonResponse
    {
        $user = $request->user();
        if ($goal->user_id !== $user->id) {
            abort(404);
        }

        $data = $request->validate([
            'amount' => ['required', 'numeric', 'min:0.01'],
            'title' => ['nullable', 'string', 'max:255'],
            'subtitle' => ['nullable', 'string', 'max:255'],
            'deposited_at' => ['nullable', 'date'],
            'account_id' => ['nullable', 'integer', 'exists:accounts,id'],
        ]);

        // Creditar a meta e debitar a conta precisam acontecer juntos. O front
        // fazia duas chamadas independentes com catch vazio: se a segunda
        // falhasse, a meta era creditada e o dinheiro nunca saía da conta.
        $deposit = \DB::transaction(function () use ($goal, $data, $user) {
            $deposit = GoalDeposit::create([
                'goal_id' => $goal->id,
                'title' => $data['title'] ?? 'Depósito',
                'subtitle' => $data['subtitle'] ?? null,
                'amount' => $data['amount'],
                'deposited_at' => $data['deposited_at'] ?? now(),
            ]);

            $goal->current_amount = ($goal->current_amount ?? 0) + $deposit->amount;
            $goal->save();

            if (! empty($data['account_id'])) {
                $account = \App\Models\Account::query()
                    ->where('id', $data['account_id'])
                    ->where('user_id', $user->id)
                    ->lockForUpdate()
                    ->firstOrFail();

                \App\Models\Transaction::create([
                    'user_id' => $user->id,
                    'account_id' => $account->id,
                    'kind' => 'expense',
                    'status' => 'paid',
                    'amount' => $data['amount'],
                    'description' => 'Depósito meta: ' . $goal->title,
                    'transaction_date' => $data['deposited_at'] ?? now()->toDateString(),
                    'priority' => false,
                    'is_recurring' => false,
                    'is_parcelado' => false,
                ]);

                $account->current_balance = (float) $account->current_balance - (float) $data['amount'];
                $account->save();
            }

            return $deposit;
        });

        return response()->json([
            'goal' => app(KitamoBootstrap::class)->goal($goal->load('deposits')),
        ]);
    }
}
