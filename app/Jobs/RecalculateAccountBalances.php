<?php

namespace App\Jobs;

use App\Models\Account;
use App\Support\InvoiceCycle;
use App\Models\Transferencia;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class RecalculateAccountBalances implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function handle(): void
    {
        Account::query()
            ->cashLike()
            ->chunkById(100, function ($accounts) {
            foreach ($accounts as $account) {
                $income = $account->transactions()
                    ->where('kind', 'income')
                    ->where('status', 'received')
                    ->sum('amount');

                $expense = $account->transactions()
                    ->where('kind', 'expense')
                    ->where('status', 'paid')
                    ->sum('amount');

                $incomingTransfers = (float) Transferencia::query()
                    ->where('user_id', $account->user_id)
                    ->where('conta_destino_id', $account->id)
                    ->sum('valor');

                $outgoingTransfers = (float) Transferencia::query()
                    ->where('user_id', $account->user_id)
                    ->where('conta_origem_id', $account->id)
                    ->sum('valor');

                $balance = (float) $account->initial_balance
                    + (float) $income
                    - (float) $expense
                    + $incomingTransfers
                    - $outgoingTransfers;

                $account->forceFill([
                    'current_balance' => $balance,
                ])->save();
            }
        });

        // cashLike() exclui cartões de crédito, então eles nunca eram
        // recalculados: qualquer divergência no saldo ficava permanente.
        // Para cartão, o saldo é a dívida em aberto derivada das transações.
        Account::query()
            ->where('type', 'credit_card')
            ->chunkById(100, function ($accounts) {
                foreach ($accounts as $account) {
                    $account->forceFill([
                        'current_balance' => InvoiceCycle::outstandingDebt((int) $account->id),
                    ])->save();
                }
            });
    }
}
