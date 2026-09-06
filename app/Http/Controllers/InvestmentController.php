<?php

namespace App\Http\Controllers;

use App\Models\Investment;
use App\Models\InvestmentTransaction;
use App\Models\Tag;
use App\Models\Transaction;
use App\Support\KitamoBootstrap;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class InvestmentController extends Controller
{
    private const CLASSES = ['caixinha', 'cdb', 'tesouro', 'acao', 'fii', 'cripto', 'outro'];
    private const FONTES = ['manual', 'binance', 'bcb'];

    /**
     * Sem esta tag o aporte apareceria como despesa nos relatórios, inventando
     * um gasto que na verdade é dinheiro que continua sendo do usuário — o
     * mesmo erro que a tag `quitacao-fatura` resolve para faturas.
     */
    public const TAG_APORTE = 'aporte-investimento';

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'asset_class' => ['required', Rule::in(self::CLASSES)],
            'institution' => ['nullable', 'string', 'max:120'],
            'ticker' => ['nullable', 'string', 'max:20'],
            'quantity' => ['nullable', 'numeric', 'min:0'],
            'current_value' => ['required', 'numeric', 'min:0'],
            'price_source' => ['nullable', Rule::in(self::FONTES)],
            'color' => ['nullable', 'string', 'max:20'],
            'icon' => ['nullable', 'string', 'max:40'],
        ]);

        $investment = Investment::create([
            ...$data,
            'user_id' => $request->user()->id,
            'price_source' => $data['price_source'] ?? 'manual',
            'price_updated_at' => now(),
        ]);

        return response()->json([
            'investment' => app(KitamoBootstrap::class)->investment($investment->load('movimentos')),
        ]);
    }

    public function update(Request $request, Investment $investment): JsonResponse
    {
        $this->autorizar($request, $investment);

        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:120'],
            'asset_class' => ['sometimes', Rule::in(self::CLASSES)],
            'institution' => ['nullable', 'string', 'max:120'],
            'ticker' => ['nullable', 'string', 'max:20'],
            'quantity' => ['nullable', 'numeric', 'min:0'],
            'current_value' => ['sometimes', 'numeric', 'min:0'],
            'price_source' => ['sometimes', Rule::in(self::FONTES)],
            'color' => ['nullable', 'string', 'max:20'],
            'icon' => ['nullable', 'string', 'max:40'],
        ]);

        // Edição manual continua disponível mesmo em ativo sincronizado: é o
        // erro que deixa usuários de concorrentes presos a dado errado.
        if (array_key_exists('current_value', $data)) {
            $data['price_updated_at'] = now();
        }

        $investment->update($data);

        return response()->json([
            'investment' => app(KitamoBootstrap::class)->investment($investment->fresh()->load('movimentos')),
        ]);
    }

    public function destroy(Request $request, Investment $investment): JsonResponse
    {
        $this->autorizar($request, $investment);

        // As Transaction de caixa já geradas não são apagadas: são fatos do
        // passado e removê-las reescreveria o extrato do usuário.
        $investment->delete();

        return response()->json(['ok' => true]);
    }

    /**
     * Aporte ou resgate. Quando `afeta_caixa` vem marcado, cria também a
     * Transaction correspondente — as duas escritas numa transação só, porque
     * metade desse fluxo gravado é dinheiro perdido.
     */
    public function aporte(Request $request, Investment $investment): JsonResponse
    {
        $this->autorizar($request, $investment);

        $data = $request->validate([
            'kind' => ['required', Rule::in(['aporte', 'resgate'])],
            'amount' => ['required', 'numeric', 'gt:0'],
            'quantity' => ['nullable', 'numeric', 'min:0'],
            'unit_price' => ['nullable', 'numeric', 'min:0'],
            'occurred_on' => ['required', 'date'],
            'afeta_caixa' => ['nullable', 'boolean'],
            'account_id' => ['nullable', 'integer', 'exists:accounts,id'],
        ]);

        return DB::transaction(function () use ($request, $investment, $data) {
            $transactionId = null;

            if (($data['afeta_caixa'] ?? false) && !empty($data['account_id'])) {
                $ehAporte = $data['kind'] === 'aporte';

                $transaction = Transaction::create([
                    'user_id' => $request->user()->id,
                    'account_id' => $data['account_id'],
                    'description' => ($ehAporte ? 'Aporte em ' : 'Resgate de ') . $investment->name,
                    'amount' => $data['amount'],
                    'kind' => $ehAporte ? 'expense' : 'income',
                    'status' => $ehAporte ? 'paid' : 'received',
                    'transaction_date' => $data['occurred_on'],
                    'data_pagamento' => $data['occurred_on'],
                ]);

                $this->marcarComTagDeAporte($transaction);
                $transactionId = $transaction->id;
            }

            InvestmentTransaction::create([
                'investment_id' => $investment->id,
                'kind' => $data['kind'],
                'amount' => $data['amount'],
                'quantity' => $data['quantity'] ?? null,
                'unit_price' => $data['unit_price'] ?? null,
                'occurred_on' => $data['occurred_on'],
                'transaction_id' => $transactionId,
            ]);

            // O aporte aumenta a posição; o resgate reduz.
            $delta = $data['kind'] === 'aporte' ? $data['amount'] : -$data['amount'];
            $investment->current_value = max(0, (float) $investment->current_value + $delta);
            $investment->price_updated_at = now();
            $investment->save();

            return response()->json([
                'investment' => app(KitamoBootstrap::class)->investment($investment->fresh()->load('movimentos')),
            ]);
        });
    }

    private function marcarComTagDeAporte(Transaction $transaction): void
    {
        // O model Tag usa `nome`/`cor` (português), tem chave UUID não
        // incremental — daí o id explícito — e a relação em Transaction
        // chama-se `tagsRelation()`, não `tags()`.
        $tag = Tag::firstOrCreate(
            ['user_id' => $transaction->user_id, 'nome' => self::TAG_APORTE],
            ['id' => (string) Str::uuid(), 'cor' => '#8B5CF6'],
        );

        $transaction->tagsRelation()->syncWithoutDetaching([$tag->id]);
    }

    private function autorizar(Request $request, Investment $investment): void
    {
        if ($investment->user_id !== $request->user()->id) {
            abort(404);
        }
    }
}
