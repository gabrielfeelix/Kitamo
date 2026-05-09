<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Account;
use App\Models\Transaction;
use App\Services\BankImportParser;
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

        $result = match ($extension) {
            'ofx', 'qfx' => $parser->parseOfx($contents),
            'csv', 'txt' => $parser->parseCsv($contents),
            default => null,
        };

        if ($result === null) {
            return response()->json([
                'message' => "Formato '{$extension}' não suportado. Use OFX ou CSV.",
            ], 422);
        }

        return response()->json([
            'institution' => $result['institution'] ?? null,
            'account_id' => $result['account_id'] ?? null,
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
        ]);

        $account = Account::where('id', $data['account_id'])
            ->where('user_id', $request->user()->id)
            ->firstOrFail();

        $result = DB::transaction(function () use ($data, $account, $request) {
            $count = 0;
            $skipped = 0;
            $netDelta = 0.0;

            foreach ($data['rows'] as $row) {
                $exists = Transaction::query()
                    ->where('user_id', $request->user()->id)
                    ->where('account_id', $account->id)
                    ->whereDate('transaction_date', $row['transaction_date'])
                    ->where('kind', $row['kind'])
                    ->whereRaw('ABS(amount - ?) < 0.005', [(float) $row['amount']])
                    ->where('description', $row['description'])
                    ->exists();

                if ($exists) {
                    $skipped++;
                    continue;
                }

                Transaction::create([
                    'user_id' => $request->user()->id,
                    'account_id' => $account->id,
                    'category_id' => $row['category_id'] ?? null,
                    'kind' => $row['kind'],
                    'status' => $row['kind'] === 'income' ? 'received' : 'paid',
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

            $account->current_balance = (float) $account->current_balance + $netDelta;
            $account->save();

            return ['created' => $count, 'skipped' => $skipped];
        });

        return response()->json($result);
    }
}
