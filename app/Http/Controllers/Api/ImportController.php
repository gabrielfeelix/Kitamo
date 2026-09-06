<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Account;
use App\Models\Transaction;
use App\Services\BankImportParser;
use App\Support\InvoiceCycle;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ImportController extends Controller
{
    public function preview(Request $request, BankImportParser $parser): JsonResponse
    {
        $request->validate([
            'file' => ['required', 'file', 'max:10240'],
        ]);

        $file = $request->file('file');
        $extension = strtolower($file->getClientOriginalExtension());
        $contents = file_get_contents($file->getRealPath());

        if ($contents === false) {
            return response()->json(['message' => 'Não foi possível ler o arquivo.'], 422);
        }

        $origem = match ($extension) {
            'ofx', 'qfx' => 'ofx',
            'csv', 'txt' => 'csv',
            default => null,
        };

        if ($origem === null) {
            return response()->json([
                'message' => "Formato '{$extension}' não suportado. Use OFX ou CSV.",
            ], 422);
        }

        $result = $origem === 'ofx'
            ? $parser->parseOfx($contents)
            : $parser->parseCsv($contents);

        return response()->json([
            'institution' => $result['institution'] ?? null,
            'account_id' => $result['account_id'] ?? null,
            // O commit precisa saber a procedência para gravar em `origem` e
            // escolher a estratégia de deduplicação.
            'origem' => $origem,
            'rows' => $result['rows'],
        ]);
    }

    public function commit(Request $request): JsonResponse
    {
        $data = $request->validate([
            'account_id' => ['required', 'integer', 'exists:accounts,id'],
            'rows' => ['required', 'array', 'min:1'],
            'rows.*.transaction_date' => ['required', 'date'],
            'rows.*.description' => ['required', 'string', 'max:255'],
            'rows.*.amount' => ['required', 'numeric', 'min:0'],
            'rows.*.kind' => ['required', 'in:expense,income'],
            'rows.*.category_id' => ['nullable', 'integer', 'exists:categories,id'],
            'rows.*.origem_id' => ['nullable', 'string', 'max:255'],
            'origem' => ['nullable', 'in:ofx,csv'],
        ]);

        $origem = $data['origem'] ?? 'csv';

        $account = Account::where('id', $data['account_id'])
            ->where('user_id', $request->user()->id)
            ->firstOrFail();

        $result = DB::transaction(function () use ($data, $account, $request, $origem) {
            $userId = $request->user()->id;
            $count = 0;
            $skipped = 0;
            $netDelta = 0.0;

            // Quantas vezes cada assinatura de conteúdo já apareceu neste
            // arquivo. Sem isso, duas compras legitimamente iguais no mesmo dia
            // (dois cafés de R$ 12) colapsariam numa só.
            $ocorrencia = [];

            foreach ($data['rows'] as $row) {
                $origemId = $row['origem_id'] ?? null;

                if ($origemId !== null && $origemId !== '') {
                    // Caminho bom: o arquivo trouxe identificador próprio
                    // (FITID no OFX). Reimportar o mesmo extrato é idempotente.
                    $exists = Transaction::query()
                        ->where('user_id', $userId)
                        ->where('account_id', $account->id)
                        ->where('origem', $origem)
                        ->where('origem_id', $origemId)
                        ->exists();
                } else {
                    // Fallback para arquivos sem identificador (CSV). Compara
                    // conteúdo, mas conta ocorrências: a 2ª linha idêntica só
                    // é considerada duplicata se já houver 2 iguais no banco.
                    $assinatura = $row['transaction_date'] . '|' . $row['kind']
                        . '|' . number_format((float) $row['amount'], 2, '.', '')
                        . '|' . $row['description'];
                    $indice = $ocorrencia[$assinatura] = ($ocorrencia[$assinatura] ?? 0) + 1;

                    $jaExistentes = Transaction::query()
                        ->where('user_id', $userId)
                        ->where('account_id', $account->id)
                        ->whereDate('transaction_date', $row['transaction_date'])
                        ->where('kind', $row['kind'])
                        ->whereRaw('ABS(amount - ?) < 0.005', [(float) $row['amount']])
                        ->where('description', $row['description'])
                        ->count();

                    $exists = $jaExistentes >= $indice;
                }

                if ($exists) {
                    $skipped++;
                    continue;
                }

                // Num cartão, a compra importada ainda compõe fatura em aberto:
                // precisa ficar 'pending', que é o status que
                // InvoiceCycle::outstandingDebt soma. Gravar 'paid' zeraria a
                // dívida do cartão. Em conta corrente o lançamento já aconteceu.
                if ($account->type === 'credit_card') {
                    $status = 'pending';
                } else {
                    $status = $row['kind'] === 'income' ? 'received' : 'paid';
                }

                Transaction::create([
                    'user_id' => $userId,
                    'account_id' => $account->id,
                    'category_id' => $row['category_id'] ?? null,
                    'origem' => $origem,
                    'origem_id' => $origemId ?: null,
                    'kind' => $row['kind'],
                    'status' => $status,
                    'amount' => $row['amount'],
                    'description' => $row['description'],
                    'transaction_date' => $row['transaction_date'],
                    'priority' => false,
                    'is_recurring' => false,
                    'is_parcelado' => false,
                ]);
                $netDelta += $row['kind'] === 'income' ? (float) $row['amount'] : -(float) $row['amount'];
                $count++;
            }

            // Em cartão de crédito o saldo é derivado das transações
            // (InvoiceCycle::outstandingDebt), não acumulado por delta —
            // somar aqui contaria a fatura duas vezes.
            if ($account->type === 'credit_card') {
                $account->current_balance = InvoiceCycle::outstandingDebt((int) $account->id);
            } else {
                $account->current_balance = (float) $account->current_balance + $netDelta;
            }
            $account->save();

            return ['created' => $count, 'skipped' => $skipped];
        });

        return response()->json($result);
    }
}
