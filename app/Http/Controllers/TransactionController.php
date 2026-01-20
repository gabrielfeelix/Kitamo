<?php

namespace App\Http\Controllers;

use App\Models\Account;
use App\Models\Category;
use App\Models\ParcelamentoGrupo;
use App\Models\RecorrenciaGrupo;
use App\Models\Transaction;
use App\Services\Recorrencias\RecorrenciaScheduler;
use App\Support\KitamoBootstrap;
use Carbon\CarbonImmutable;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Storage;

class TransactionController extends Controller
{
    public function store(Request $request, RecorrenciaScheduler $scheduler): JsonResponse
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
            'isRecorrente' => ['nullable', 'boolean'],
            'periodicidade' => ['nullable', 'in:mensal,quinzenal,a_cada_x_dias'],
            'intervalo_dias' => ['nullable', 'integer', 'min:1', 'max:366'],
            'data_fim' => ['nullable', 'date'],
            'tags' => ['nullable', 'array'],
            'tags.*' => ['string', 'max:50'],
            'receipt' => ['nullable', 'file', 'max:10240', 'mimes:pdf,jpg,jpeg,png,webp,heic,heif'],
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

        $isRecorrente = (bool) ($data['isRecorrente'] ?? false);
        if ($isRecorrente && empty($data['periodicidade'])) {
            return response()->json([
                'message' => 'periodicidade é obrigatória para recorrência.',
            ], 422);
        }

        if (!empty($data['data_fim']) && CarbonImmutable::parse($data['data_fim'])->lessThan(CarbonImmutable::today())) {
            return response()->json([
                'message' => 'data_fim deve ser hoje ou no futuro.',
            ], 422);
        }

        $status = $data['kind'] === 'income'
            ? 'received'
            : (!empty($data['isPaid']) ? 'paid' : 'pending');

        $installmentLabel = null;
        $installmentIndex = null;
        $installmentTotal = null;
        $parcelamentoGrupoId = null;
        $parcelaAtual = null;
        $parcelaTotal = null;
        $isParcelado = !empty($data['isInstallment']) && !empty($data['installmentCount']) && (int) $data['installmentCount'] > 1;

        if (!empty($data['isInstallment']) && !empty($data['installmentCount']) && $data['installmentCount'] > 1) {
            $installmentIndex = 1;
            $installmentTotal = (int) $data['installmentCount'];
            $installmentLabel = "Parcela {$installmentIndex}/{$installmentTotal}";
            $parcelaAtual = 1;
            $parcelaTotal = $installmentTotal;
        }

        $recorrenciaGrupoId = null;
        if ($isRecorrente) {
            $recorrenciaGrupoId = (string) Str::uuid();

            RecorrenciaGrupo::create([
                'id' => $recorrenciaGrupoId,
                'user_id' => $user->id,
                'account_id' => $account->id,
                'category_id' => $category->id,
                'kind' => $data['kind'],
                'amount' => $data['amount'],
                'descricao' => $data['description'],
                'periodicidade' => $data['periodicidade'],
                'intervalo_dias' => $data['periodicidade'] === 'a_cada_x_dias' ? ($data['intervalo_dias'] ?? null) : null,
                'data_inicio' => $date,
                'data_fim' => $data['data_fim'] ?? null,
                'is_active' => true,
                'tags' => $data['tags'] ?? [],
            ]);
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
            'is_recurring' => $isRecorrente,
            'is_parcelado' => $isParcelado,
            'parcela_atual' => $parcelaAtual,
            'parcela_total' => $parcelaTotal,
            'recurrence_interval' => $isRecorrente ? $data['periodicidade'] : null,
            'recurrence_end_at' => $isRecorrente ? ($data['data_fim'] ?? null) : null,
            'recorrencia_grupo_id' => $recorrenciaGrupoId,
            'parcelamento_grupo_id' => null,
            'data_pagamento' => in_array($status, ['paid', 'received'], true) ? now() : null,
            'tags' => $data['tags'] ?? [],
        ]);

        if ($request->hasFile('receipt')) {
            $stored = $this->storeReceipt($user->id, $request->file('receipt'));
            $transaction->update($stored);
        }

        $this->applyBalanceAdjustment($account, $transaction, 1);

        if ($isRecorrente && $recorrenciaGrupoId) {
            $this->gerarRecorrenciasFuturas($recorrenciaGrupoId, $scheduler, 12);
        }

        if ($isParcelado && $transaction->kind === 'expense') {
            $parcelamentoGrupoId = (string) Str::uuid();
            $firstInstallmentDate = $this->calcularDataPrimeiraParcela($account, CarbonImmutable::parse($date));

            ParcelamentoGrupo::create([
                'id' => $parcelamentoGrupoId,
                'user_id' => $user->id,
                'account_id' => $account->id,
                'category_id' => $category->id,
                'descricao' => $data['description'],
                'valor_total' => $data['amount'],
                'quantidade_parcelas' => (int) $data['installmentCount'],
                'data_primeira_parcela' => $firstInstallmentDate->toDateString(),
                'tags' => $data['tags'] ?? [],
            ]);

            $this->gerarParcelas($transaction, $parcelamentoGrupoId, $firstInstallmentDate, (int) $data['installmentCount']);
            $transaction = Transaction::query()->findOrFail($transaction->id);
        }

        return response()->json([
            'entry' => app(KitamoBootstrap::class)->entry($transaction->load(['category', 'account'])),
        ]);
    }

    public function update(Request $request, Transaction $transaction, RecorrenciaScheduler $scheduler): JsonResponse
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
            'editar_escopo' => ['nullable', 'in:este,proximos,todos'],
            'periodicidade' => ['nullable', 'in:mensal,quinzenal,a_cada_x_dias'],
            'intervalo_dias' => ['nullable', 'integer', 'min:1', 'max:366'],
            'data_fim' => ['nullable', 'date'],
            'tags' => ['nullable', 'array'],
            'tags.*' => ['string', 'max:50'],
            'receipt' => ['nullable', 'file', 'max:10240', 'mimes:pdf,jpg,jpeg,png,webp,heic,heif'],
            'remove_receipt' => ['nullable', 'boolean'],
        ]);

        $editarEscopo = $data['editar_escopo'] ?? null;
        $isRecorrenteEdit = !empty($transaction->recorrencia_grupo_id) && $editarEscopo !== null;
        $isParcelamentoEdit = !empty($transaction->parcelamento_grupo_id) && $editarEscopo !== null;
        if ($isRecorrenteEdit && $editarEscopo === 'este') {
            $transaction->recorrencia_grupo_id = null;
            $transaction->is_recurring = false;
            $transaction->recurrence_interval = null;
            $transaction->recurrence_end_at = null;
            $transaction->save();
        }
        if ($isParcelamentoEdit && $editarEscopo === 'este') {
            $transaction->parcelamento_grupo_id = null;
            $transaction->is_parcelado = false;
            $transaction->parcela_atual = null;
            $transaction->parcela_total = null;
            $transaction->installment_label = null;
            $transaction->installment_index = null;
            $transaction->installment_total = null;
            $transaction->save();
        }

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
        $isParcelado = !empty($data['isInstallment']) && !empty($data['installmentCount']) && (int) $data['installmentCount'] > 1;
        $parcelaAtual = $transaction->parcela_atual;
        $parcelaTotal = $transaction->parcela_total;

        if (!empty($data['isInstallment']) && !empty($data['installmentCount']) && $data['installmentCount'] > 1) {
            $installmentIndex = 1;
            $installmentTotal = (int) $data['installmentCount'];
            $installmentLabel = "Parcela {$installmentIndex}/{$installmentTotal}";
        }

        $payload = [
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
            'is_parcelado' => $isParcelado,
            'parcela_atual' => $parcelaAtual,
            'parcela_total' => $parcelaTotal,
            'data_pagamento' => in_array($status, ['paid', 'received'], true) ? ($transaction->data_pagamento ?? now()) : null,
            'tags' => $data['tags'] ?? [],
        ];

        if ($request->boolean('remove_receipt')) {
            $this->deleteReceiptIfAny($transaction);
            $payload['receipt_path'] = null;
            $payload['receipt_original_name'] = null;
            $payload['receipt_mime'] = null;
            $payload['receipt_size'] = null;
        }

        if ($isRecorrenteEdit && in_array($editarEscopo, ['proximos', 'todos'], true)) {
            $grupoId = $transaction->recorrencia_grupo_id;
            $query = Transaction::query()->where('recorrencia_grupo_id', $grupoId);
            if ($editarEscopo === 'proximos') {
                $query->whereDate('transaction_date', '>=', $transaction->transaction_date);
            }

            $query->update($payload);

            $grupoUpdate = [
                'account_id' => $account->id,
                'category_id' => $category->id,
                'kind' => $data['kind'],
                'amount' => $data['amount'],
                'descricao' => $data['description'],
            ];

            if (!empty($data['periodicidade'])) {
                $grupoUpdate['periodicidade'] = $data['periodicidade'];
                $grupoUpdate['intervalo_dias'] = $data['periodicidade'] === 'a_cada_x_dias' ? ($data['intervalo_dias'] ?? null) : null;
            }

            if (array_key_exists('data_fim', $data)) {
                $grupoUpdate['data_fim'] = $data['data_fim'] ?? null;
            }

            $grupoUpdate['tags'] = $data['tags'] ?? [];

            RecorrenciaGrupo::where('id', $grupoId)->where('user_id', $user->id)->update($grupoUpdate);
            $this->gerarRecorrenciasFuturas($grupoId, $scheduler, 12);

            $transaction = Transaction::query()->findOrFail($transaction->id);
        } elseif ($isParcelamentoEdit && in_array($editarEscopo, ['proximos', 'todos'], true)) {
            $grupoId = $transaction->parcelamento_grupo_id;
            $query = Transaction::query()->where('parcelamento_grupo_id', $grupoId);
            if ($editarEscopo === 'proximos') {
                $query->where('parcela_atual', '>=', (int) ($transaction->parcela_atual ?? 1));
            }
            $query->update($payload);

            ParcelamentoGrupo::where('id', $grupoId)->where('user_id', $user->id)->update([
                'account_id' => $account->id,
                'category_id' => $category->id,
                'descricao' => $data['description'],
                'valor_total' => $data['amount'],
                'tags' => $data['tags'] ?? [],
            ]);

            $transaction = Transaction::query()->findOrFail($transaction->id);
        } else {
            $transaction->update($payload);
        }

        if ($request->hasFile('receipt')) {
            $this->deleteReceiptIfAny($transaction);
            $stored = $this->storeReceipt($user->id, $request->file('receipt'));
            $transaction->update($stored);
        }

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
        $this->deleteReceiptIfAny($transaction);
        $transaction->delete();

        return response()->json(['ok' => true]);
    }

    private function storeReceipt(int $userId, UploadedFile $file): array
    {
        $disk = Storage::disk('public');

        $ext = strtolower($file->getClientOriginalExtension() ?: $file->extension() ?: 'bin');
        $path = $disk->putFileAs("receipts/{$userId}", $file, (string) Str::uuid() . ".{$ext}");

        return [
            'receipt_path' => $path,
            'receipt_original_name' => $file->getClientOriginalName(),
            'receipt_mime' => $file->getClientMimeType(),
            'receipt_size' => $file->getSize(),
        ];
    }

    private function deleteReceiptIfAny(Transaction $transaction): void
    {
        $path = (string) ($transaction->receipt_path ?? '');
        if (!$path) return;
        if (!str_starts_with($path, 'receipts/')) return;

        Storage::disk('public')->delete($path);
    }

    public function togglePago(Request $request, Transaction $transaction): JsonResponse
    {
        $user = $request->user();
        if ($transaction->user_id !== $user->id) {
            abort(404);
        }

        $account = $transaction->account;
        $wasEffective = in_array($transaction->status, ['paid', 'received'], true);

        if ($wasEffective) {
            $this->applyBalanceAdjustment($account, $transaction, -1);
            $transaction->status = 'pending';
            $transaction->data_pagamento = null;
            $transaction->save();
        } else {
            $transaction->status = $transaction->kind === 'income' ? 'received' : 'paid';
            $transaction->data_pagamento = now();
            $transaction->save();
            $this->applyBalanceAdjustment($account, $transaction, 1);
        }

        return response()->json([
            'status' => $transaction->status,
            'data_pagamento' => $transaction->data_pagamento?->toISOString(),
        ]);
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

    private function gerarRecorrenciasFuturas(string $grupoId, RecorrenciaScheduler $scheduler, int $months): void
    {
        $grupo = RecorrenciaGrupo::query()->find($grupoId);
        if (!$grupo) {
            return;
        }

        $today = CarbonImmutable::today();
        $target = $today->addMonthsNoOverflow(max(1, $months));

        $lastDate = Transaction::query()
            ->where('recorrencia_grupo_id', $grupoId)
            ->max('transaction_date');

        $cursor = $lastDate
            ? CarbonImmutable::parse($lastDate)
            : CarbonImmutable::parse($grupo->data_inicio);

        while ($cursor->lessThan($target)) {
            $cursor = $scheduler->nextDate($cursor, $grupo);
            if (!$scheduler->isActiveOn($grupo, $cursor)) {
                break;
            }

            $exists = Transaction::query()
                ->where('recorrencia_grupo_id', $grupoId)
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
                'is_recurring' => true,
                'recurrence_interval' => $grupo->periodicidade,
                'recurrence_end_at' => $grupo->data_fim,
                'recorrencia_grupo_id' => $grupoId,
                'tags' => $grupo->tags ?? [],
            ]);
        }
    }

    private function calcularDataPrimeiraParcela(Account $account, CarbonImmutable $purchaseDate): CarbonImmutable
    {
        if ($account->type !== 'credit_card') {
            return $purchaseDate;
        }

        $closingDay = (int) ($account->closing_day ?? 0);
        $dueDay = (int) ($account->due_day ?? 0);

        if ($closingDay <= 0 || $dueDay <= 0) {
            return $purchaseDate->addMonthNoOverflow();
        }

        $sameCycle = $purchaseDate->day <= $closingDay;
        $cycleMonth = $sameCycle ? $purchaseDate : $purchaseDate->addMonthNoOverflow();

        $targetDay = min($dueDay, $cycleMonth->daysInMonth);

        return $cycleMonth->setDay($targetDay);
    }

    private function gerarParcelas(Transaction $first, string $grupoId, CarbonImmutable $dataPrimeiraParcela, int $quantidade): void
    {
        $total = round((float) $first->amount, 2);
        $valorParcela = round($total / $quantidade, 2);
        $sobra = round($total - ($valorParcela * $quantidade), 2);

        for ($i = 1; $i <= $quantidade; $i++) {
            $valor = $valorParcela;
            if ($i === 1) {
                $valor = round($valor + $sobra, 2);
            }

            $dataParcela = $dataPrimeiraParcela->addMonthsNoOverflow($i - 1);

            $payload = [
                'user_id' => $first->user_id,
                'account_id' => $first->account_id,
                'category_id' => $first->category_id,
                'kind' => $first->kind,
                'status' => $first->status,
                'amount' => $valor,
                'description' => "{$first->description} ({$i}/{$quantidade})",
                'transaction_date' => $dataParcela->toDateString(),
                'priority' => (bool) $first->priority,
                'installment_label' => "Parcela {$i}/{$quantidade}",
                'installment_index' => $i,
                'installment_total' => $quantidade,
                'is_recurring' => (bool) $first->is_recurring,
                'is_parcelado' => true,
                'parcela_atual' => $i,
                'parcela_total' => $quantidade,
                'parcelamento_grupo_id' => $grupoId,
                'recorrencia_grupo_id' => $first->recorrencia_grupo_id,
                'recurrence_interval' => $first->recurrence_interval,
                'recurrence_end_at' => $first->recurrence_end_at,
                'tags' => $first->tags ?? [],
            ];

            if ($i === 1) {
                $first->update($payload);
                continue;
            }

            Transaction::create($payload);
        }
    }
}
