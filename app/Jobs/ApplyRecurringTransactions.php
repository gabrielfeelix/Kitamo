<?php

namespace App\Jobs;

use App\Models\RecurringTransaction;
use App\Models\Transaction;
use Carbon\Carbon;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class ApplyRecurringTransactions implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function handle(): void
    {
        $today = Carbon::today();

        RecurringTransaction::query()
            ->where('is_active', true)
            ->whereDate('next_run_at', '<=', $today)
            ->orderBy('next_run_at')
            ->chunkById(100, function ($recurring) use ($today) {
                foreach ($recurring as $item) {
                    Transaction::create([
                        'user_id' => $item->user_id,
                        'account_id' => $item->account_id,
                        'category_id' => $item->category_id,
                        'kind' => $item->kind,
                        'status' => $item->kind === 'income' ? 'received' : 'pending',
                        'amount' => $item->amount,
                        'description' => $item->description,
                        'transaction_date' => $item->next_run_at,
                        'data_pagamento' => $item->kind === 'income' ? now() : null,
                        'tags' => $item->tags,
                    ]);

                    $nextRun = $this->nextDate($item->next_run_at, $item->frequency);

                    if ($item->end_at && $nextRun->greaterThan($item->end_at)) {
                        $item->forceFill(['is_active' => false])->save();
                        continue;
                    }

                    $item->forceFill(['next_run_at' => $nextRun])->save();
                }
            });
    }

    private function nextDate($date, string $interval): Carbon
    {
        $base = Carbon::parse($date);

        return match ($interval) {
            'daily' => $base->addDay(),
            'weekly' => $base->addWeek(),
            'monthly' => $base->addMonthNoOverflow(),
            'yearly' => $base->addYear(),
            default => $base->addMonthNoOverflow(),
        };
    }
}
