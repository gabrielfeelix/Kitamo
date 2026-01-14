<?php

namespace App\Services;

use App\Models\Account;
use App\Models\Backup;
use App\Models\Category;
use App\Models\Goal;
use App\Models\GoalDeposit;
use App\Models\ParcelamentoGrupo;
use App\Models\RecorrenciaGrupo;
use App\Models\Tag;
use App\Models\Transaction;
use App\Models\Transferencia;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class BackupService
{
    public function criarBackup(int $userId): array
    {
        $user = User::query()->findOrFail($userId);

        $accounts = Account::where('user_id', $userId)->get();
        $categories = Category::where('user_id', $userId)->get();
        $tags = Tag::where('user_id', $userId)->get();
        $goals = Goal::where('user_id', $userId)->get();
        $goalDeposits = GoalDeposit::whereIn('goal_id', $goals->pluck('id'))->get();
        $transactions = Transaction::with('tagsRelation')
            ->where('user_id', $userId)
            ->orderBy('transaction_date')
            ->orderBy('id')
            ->get();
        $recorrenciaGrupos = RecorrenciaGrupo::where('user_id', $userId)->get();
        $parcelamentoGrupos = ParcelamentoGrupo::where('user_id', $userId)->get();
        $transferencias = Transferencia::where('user_id', $userId)->orderBy('transferido_em')->get();

        $backup = [
            'versao' => '1.0',
            'criado_em' => now()->toIso8601String(),
            'usuario' => [
                'id' => (string) $user->id,
                'nome' => $user->name,
                'email' => $user->email,
                'theme' => $user->theme ?? 'light',
            ],
            'contas' => $accounts->map(fn (Account $a) => [
                'id' => (int) $a->id,
                'name' => $a->name,
                'type' => $a->type,
                'icon' => $a->icon,
                'initial_balance' => (float) $a->initial_balance,
                'current_balance' => (float) $a->current_balance,
                'credit_limit' => $a->credit_limit !== null ? (float) $a->credit_limit : null,
                'closing_day' => $a->closing_day,
                'due_day' => $a->due_day,
                'is_archived' => (bool) $a->is_archived,
            ])->all(),
            'categorias' => $categories->map(fn (Category $c) => [
                'id' => (int) $c->id,
                'name' => $c->name,
                'type' => $c->type,
                'color' => $c->color,
                'icon' => $c->icon,
                'is_default' => (bool) $c->is_default,
            ])->all(),
            'tags' => $tags->map(fn (Tag $t) => [
                'id' => (string) $t->id,
                'nome' => $t->nome,
                'cor' => $t->cor,
            ])->all(),
            'metas' => $goals->map(fn (Goal $g) => [
                'id' => (int) $g->id,
                'title' => $g->title,
                'target_amount' => (float) $g->target_amount,
                'current_amount' => (float) $g->current_amount,
                'due_date' => $g->due_date?->toDateString(),
                'status' => $g->status,
                'color' => $g->color,
                'icon' => $g->icon,
                'term' => $g->term,
                'tags' => $g->tags ?? [],
            ])->all(),
            'meta_depositos' => $goalDeposits->map(fn (GoalDeposit $d) => [
                'id' => (int) $d->id,
                'goal_id' => (int) $d->goal_id,
                'title' => $d->title,
                'subtitle' => $d->subtitle,
                'amount' => (float) $d->amount,
                'deposited_at' => $d->deposited_at?->toISOString(),
            ])->all(),
            'transacoes' => $transactions->map(fn (Transaction $t) => [
                'id' => (int) $t->id,
                'user_id' => (int) $t->user_id,
                'account_id' => (int) $t->account_id,
                'category_id' => $t->category_id ? (int) $t->category_id : null,
                'kind' => $t->kind,
                'status' => $t->status,
                'amount' => (float) $t->amount,
                'description' => $t->description,
                'notes' => $t->notes,
                'transaction_date' => $t->transaction_date?->toDateString(),
                'priority' => (bool) $t->priority,
                'installment_label' => $t->installment_label,
                'installment_index' => $t->installment_index,
                'installment_total' => $t->installment_total,
                'is_recurring' => (bool) $t->is_recurring,
                'recurrence_interval' => $t->recurrence_interval,
                'next_run_at' => $t->next_run_at?->toDateString(),
                'recurrence_end_at' => $t->recurrence_end_at?->toDateString(),
                'recorrencia_grupo_id' => $t->recorrencia_grupo_id,
                'data_pagamento' => $t->data_pagamento?->toISOString(),
                'is_parcelado' => (bool) $t->is_parcelado,
                'parcela_atual' => $t->parcela_atual,
                'parcela_total' => $t->parcela_total,
                'parcelamento_grupo_id' => $t->parcelamento_grupo_id,
                'tags' => $t->tags ?? [],
                'tag_ids' => $t->tagsRelation->pluck('id')->all(),
            ])->all(),
            'recorrencia_grupos' => $recorrenciaGrupos->map(fn (RecorrenciaGrupo $g) => [
                'id' => (string) $g->id,
                'account_id' => (int) $g->account_id,
                'category_id' => $g->category_id ? (int) $g->category_id : null,
                'kind' => $g->kind,
                'amount' => (float) $g->amount,
                'descricao' => $g->descricao,
                'periodicidade' => $g->periodicidade,
                'intervalo_dias' => $g->intervalo_dias,
                'data_inicio' => $g->data_inicio?->toDateString(),
                'data_fim' => $g->data_fim?->toDateString(),
                'is_active' => (bool) $g->is_active,
                'tags' => $g->tags ?? [],
            ])->all(),
            'parcelamento_grupos' => $parcelamentoGrupos->map(fn (ParcelamentoGrupo $g) => [
                'id' => (string) $g->id,
                'account_id' => (int) $g->account_id,
                'category_id' => $g->category_id ? (int) $g->category_id : null,
                'descricao' => $g->descricao,
                'valor_total' => (float) $g->valor_total,
                'quantidade_parcelas' => $g->quantidade_parcelas,
                'data_primeira_parcela' => $g->data_primeira_parcela?->toDateString(),
                'tags' => $g->tags ?? [],
            ])->all(),
            'transferencias' => $transferencias->map(fn (Transferencia $t) => [
                'id' => (int) $t->id,
                'conta_origem_id' => (int) $t->conta_origem_id,
                'conta_destino_id' => (int) $t->conta_destino_id,
                'valor' => (float) $t->valor,
                'descricao' => $t->descricao,
                'transferido_em' => $t->transferido_em?->toISOString(),
            ])->all(),
        ];

        $timestamp = now()->format('Y-m-d_His');
        $filename = "kitamo_backup_{$userId}_{$timestamp}.json";
        $path = "backups/{$userId}/{$filename}";

        Storage::put($path, json_encode($backup, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
        $size = Storage::size($path);

        $user->last_backup_at = now();
        $user->save();

        Backup::create([
            'id' => (string) Str::uuid(),
            'user_id' => $userId,
            'filename' => $filename,
            'size_bytes' => $size,
        ]);

        return [
            'filename' => $filename,
            'path' => $path,
            'size_bytes' => $size,
            'url' => Storage::url($path),
        ];
    }

    public function restaurarBackup(int $userId, string $path): void
    {
        $payload = json_decode(Storage::get($path), true);
        if (!is_array($payload)) {
            throw new \RuntimeException('Backup inválido.');
        }

        DB::transaction(function () use ($userId, $payload) {
            DB::table('transaction_tags')
                ->whereIn('transaction_id', Transaction::where('user_id', $userId)->pluck('id'))
                ->delete();

            Transaction::where('user_id', $userId)->delete();
            Transferencia::where('user_id', $userId)->delete();
            ParcelamentoGrupo::where('user_id', $userId)->delete();
            RecorrenciaGrupo::where('user_id', $userId)->delete();

            $goalIds = Goal::where('user_id', $userId)->pluck('id');
            GoalDeposit::whereIn('goal_id', $goalIds)->delete();
            Goal::where('user_id', $userId)->delete();

            Category::where('user_id', $userId)->delete();
            Tag::where('user_id', $userId)->delete();
            Account::where('user_id', $userId)->delete();

            foreach (($payload['contas'] ?? []) as $row) {
                DB::table('accounts')->insert([
                    'id' => $row['id'],
                    'user_id' => $userId,
                    'name' => $row['name'],
                    'type' => $row['type'],
                    'icon' => $row['icon'] ?? null,
                    'initial_balance' => $row['initial_balance'] ?? 0,
                    'current_balance' => $row['current_balance'] ?? 0,
                    'credit_limit' => $row['credit_limit'] ?? null,
                    'closing_day' => $row['closing_day'] ?? null,
                    'due_day' => $row['due_day'] ?? null,
                    'is_archived' => (int) ($row['is_archived'] ?? 0),
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }

            foreach (($payload['categorias'] ?? []) as $row) {
                DB::table('categories')->insert([
                    'id' => $row['id'],
                    'user_id' => $userId,
                    'name' => $row['name'],
                    'type' => $row['type'],
                    'color' => $row['color'] ?? null,
                    'icon' => $row['icon'] ?? null,
                    'is_default' => (int) ($row['is_default'] ?? 0),
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }

            foreach (($payload['tags'] ?? []) as $row) {
                DB::table('tags')->insert([
                    'id' => $row['id'],
                    'user_id' => $userId,
                    'nome' => $row['nome'],
                    'cor' => $row['cor'],
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }

            foreach (($payload['metas'] ?? []) as $row) {
                DB::table('goals')->insert([
                    'id' => $row['id'],
                    'user_id' => $userId,
                    'title' => $row['title'],
                    'target_amount' => $row['target_amount'],
                    'current_amount' => $row['current_amount'],
                    'due_date' => $row['due_date'],
                    'status' => $row['status'],
                    'color' => $row['color'] ?? null,
                    'icon' => $row['icon'],
                    'term' => $row['term'],
                    'tags' => json_encode($row['tags'] ?? []),
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }

            foreach (($payload['meta_depositos'] ?? []) as $row) {
                DB::table('goal_deposits')->insert([
                    'id' => $row['id'],
                    'goal_id' => $row['goal_id'],
                    'title' => $row['title'],
                    'subtitle' => $row['subtitle'],
                    'amount' => $row['amount'],
                    'deposited_at' => $row['deposited_at'],
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }

            foreach (($payload['recorrencia_grupos'] ?? []) as $row) {
                DB::table('recorrencia_grupos')->insert([
                    'id' => $row['id'],
                    'user_id' => $userId,
                    'account_id' => $row['account_id'],
                    'category_id' => $row['category_id'],
                    'kind' => $row['kind'],
                    'amount' => $row['amount'],
                    'descricao' => $row['descricao'],
                    'periodicidade' => $row['periodicidade'],
                    'intervalo_dias' => $row['intervalo_dias'],
                    'data_inicio' => $row['data_inicio'],
                    'data_fim' => $row['data_fim'],
                    'is_active' => (int) ($row['is_active'] ?? 1),
                    'tags' => json_encode($row['tags'] ?? []),
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }

            foreach (($payload['parcelamento_grupos'] ?? []) as $row) {
                DB::table('parcelamento_grupos')->insert([
                    'id' => $row['id'],
                    'user_id' => $userId,
                    'account_id' => $row['account_id'],
                    'category_id' => $row['category_id'],
                    'descricao' => $row['descricao'],
                    'valor_total' => $row['valor_total'],
                    'quantidade_parcelas' => $row['quantidade_parcelas'],
                    'data_primeira_parcela' => $row['data_primeira_parcela'],
                    'tags' => json_encode($row['tags'] ?? []),
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }

            foreach (($payload['transferencias'] ?? []) as $row) {
                DB::table('transferencias')->insert([
                    'id' => $row['id'],
                    'user_id' => $userId,
                    'conta_origem_id' => $row['conta_origem_id'],
                    'conta_destino_id' => $row['conta_destino_id'],
                    'valor' => $row['valor'],
                    'descricao' => $row['descricao'],
                    'transferido_em' => $row['transferido_em'],
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }

            foreach (($payload['transacoes'] ?? []) as $row) {
                DB::table('transactions')->insert([
                    'id' => $row['id'],
                    'user_id' => $userId,
                    'account_id' => $row['account_id'],
                    'category_id' => $row['category_id'],
                    'kind' => $row['kind'],
                    'status' => $row['status'],
                    'amount' => $row['amount'],
                    'description' => $row['description'],
                    'notes' => $row['notes'],
                    'transaction_date' => $row['transaction_date'],
                    'priority' => (int) ($row['priority'] ?? 0),
                    'installment_label' => $row['installment_label'],
                    'installment_index' => $row['installment_index'],
                    'installment_total' => $row['installment_total'],
                    'is_recurring' => (int) ($row['is_recurring'] ?? 0),
                    'is_parcelado' => (int) ($row['is_parcelado'] ?? 0),
                    'parcela_atual' => $row['parcela_atual'],
                    'parcela_total' => $row['parcela_total'],
                    'recurrence_interval' => $row['recurrence_interval'],
                    'next_run_at' => $row['next_run_at'],
                    'recurrence_end_at' => $row['recurrence_end_at'],
                    'recorrencia_grupo_id' => $row['recorrencia_grupo_id'],
                    'parcelamento_grupo_id' => $row['parcelamento_grupo_id'],
                    'data_pagamento' => $row['data_pagamento'],
                    'tags' => json_encode($row['tags'] ?? []),
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);

                foreach (($row['tag_ids'] ?? []) as $tagId) {
                    DB::table('transaction_tags')->insert([
                        'transaction_id' => $row['id'],
                        'tag_id' => $tagId,
                    ]);
                }
            }
        });
    }
}
