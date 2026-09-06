<?php

namespace App\Console\Commands;

use App\Models\RecorrenciaGrupo;
use App\Models\Transaction;
use App\Services\Recorrencias\RecorrenciaScheduler;
use Carbon\CarbonImmutable;
use Illuminate\Console\Command;

class GerarProximasRecorrencias extends Command
{
    protected $signature = 'recorrencias:gerar-proximas {--months=12 : Quantos meses garantir no futuro}';

    protected $description = 'Gera transações futuras para recorrências ativas (até 12 meses).';

    public function handle(RecorrenciaScheduler $scheduler): int
    {
        $months = max(1, (int) $this->option('months'));
        $today = CarbonImmutable::today();
        $target = $today->addMonthsNoOverflow($months);

        $grupos = RecorrenciaGrupo::query()
            ->where('is_active', true)
            ->where(function ($q) use ($today) {
                $q->whereNull('data_fim')->orWhere('data_fim', '>=', $today->toDateString());
            })
            ->get();

        $created = 0;

        foreach ($grupos as $grupo) {
            $lastDate = Transaction::query()
                ->where('recorrencia_grupo_id', $grupo->id)
                ->max('transaction_date');

            $cursor = $lastDate
                ? CarbonImmutable::parse($lastDate)
                : CarbonImmutable::parse($grupo->data_inicio);

            while ($cursor->lessThan($target)) {
                $cursor = $scheduler->nextDate($cursor, $grupo, (int) \Carbon\CarbonImmutable::parse($grupo->data_inicio)->day);
                if (!$scheduler->isActiveOn($grupo, $cursor)) {
                    break;
                }

                $exists = Transaction::query()
                    ->where('recorrencia_grupo_id', $grupo->id)
                    ->whereDate('transaction_date', $cursor->toDateString())
                    ->exists();

                if ($exists) {
                    continue;
                }

                Transaction::create([
                    'user_id' => $grupo->user_id,
                    'account_id' => $grupo->account_id,
                    'category_id' => $grupo->category_id,
                    'kind' => $grupo->kind,
                    'status' => 'pending',
                    'amount' => $grupo->amount,
                    'description' => $grupo->descricao,
                    'transaction_date' => $cursor->toDateString(),
                    'priority' => false,
                    'installment_label' => null,
                    'installment_index' => null,
                    'installment_total' => null,
                    'is_recurring' => true,
                    'recurrence_interval' => $grupo->periodicidade,
                    'next_run_at' => null,
                    'recurrence_end_at' => $grupo->data_fim,
                    'recorrencia_grupo_id' => $grupo->id,
                    'tags' => $grupo->tags ?? [],
                ]);

                $created++;
            }
        }

        $this->info("OK: {$created} transações recorrentes criadas.");

        return self::SUCCESS;
    }
}

