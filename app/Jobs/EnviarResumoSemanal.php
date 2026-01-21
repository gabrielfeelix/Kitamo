<?php

namespace App\Jobs;

use App\Models\Category;
use App\Models\KitamoNotification;
use App\Models\Transaction;
use App\Models\User;
use Carbon\CarbonImmutable;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class EnviarResumoSemanal implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function handle(): void
    {
        $start = CarbonImmutable::now()->subWeek()->startOfWeek();
        $end = CarbonImmutable::now()->subWeek()->endOfWeek();

        User::query()
            ->where('notif_resumo_semanal', true)
            ->chunkById(200, function ($users) use ($start, $end) {
                foreach ($users as $user) {
                    $totalDespesas = (float) Transaction::query()
                        ->where('user_id', $user->id)
                        ->where('kind', 'expense')
                        ->where('status', 'paid')
                        ->whereBetween('data_pagamento', [$start->toDateTimeString(), $end->toDateTimeString()])
                        ->sum('amount');

                    $totalReceitas = (float) Transaction::query()
                        ->where('user_id', $user->id)
                        ->where('kind', 'income')
                        ->where('status', 'received')
                        ->whereBetween('data_pagamento', [$start->toDateTimeString(), $end->toDateTimeString()])
                        ->sum('amount');

                    $balanco = $totalReceitas - $totalDespesas;

                    $categoria = Transaction::query()
                        ->where('user_id', $user->id)
                        ->where('kind', 'expense')
                        ->where('status', 'paid')
                        ->whereBetween('data_pagamento', [$start->toDateTimeString(), $end->toDateTimeString()])
                        ->select('category_id', DB::raw('SUM(amount) as total'))
                        ->groupBy('category_id')
                        ->orderByDesc('total')
                        ->first();

                    $nomeCategoria = 'Nenhuma';
                    if ($categoria && $categoria->category_id) {
                        $nomeCategoria = Category::query()->where('id', $categoria->category_id)->value('name') ?? 'Nenhuma';
                    }

                    $mensagem = "Você gastou R$ " . number_format($totalDespesas, 2, ',', '.')
                        . " e recebeu R$ " . number_format($totalReceitas, 2, ',', '.')
                        . ". Balanço: R$ " . number_format($balanco, 2, ',', '.')
                        . ". Categoria mais gasta: {$nomeCategoria}";

                    KitamoNotification::create([
                        'id' => (string) Str::uuid(),
                        'user_id' => $user->id,
                        'tipo' => 'resumo_semanal',
                        'prioridade' => 'media',
                        'titulo' => 'Resumo da semana passada',
                        'mensagem' => $mensagem,
                        'lida' => false,
                        'expirada' => false,
                        'data_expiracao' => now()->addWeek(),
                        'acao_primaria_tipo' => 'ver_analise',
                        'acao_primaria_url' => 'kitamo://analytics',
                        'metadata' => [
                            'total_despesas' => $totalDespesas,
                            'total_receitas' => $totalReceitas,
                            'balanco' => $balanco,
                            'categoria_mais_gasta' => $nomeCategoria,
                        ],
                    ]);
                }
            });
    }
}
