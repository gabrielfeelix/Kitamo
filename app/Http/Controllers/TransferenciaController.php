<?php

namespace App\Http\Controllers;

use App\Models\Account;
use App\Models\Transferencia;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class TransferenciaController extends Controller
{
    private function resolveAccountForUser(Request $request, array $data, string $keyPrefix): Account
    {
        $user = $request->user();

        $idKey = "{$keyPrefix}_id";
        $nameKey = $keyPrefix;

        if (!empty($data[$idKey])) {
            return Account::where('user_id', $user->id)->findOrFail((int) $data[$idKey]);
        }

        $name = trim((string) ($data[$nameKey] ?? ''));
        if ($name === '') {
            throw ValidationException::withMessages([
                $nameKey => ['Conta inválida.'],
            ]);
        }

        return Account::where('user_id', $user->id)->where('name', $name)->firstOrFail();
    }

    public function preview(Request $request): JsonResponse
    {
        $user = $request->user();

        $data = $request->validate([
            'conta_origem_id' => ['nullable', 'integer', 'required_without:conta_origem'],
            'conta_origem' => ['nullable', 'string', 'max:255', 'required_without:conta_origem_id'],
            'conta_destino_id' => ['nullable', 'integer', 'required_without:conta_destino'],
            'conta_destino' => ['nullable', 'string', 'max:255', 'required_without:conta_destino_id'],
            'valor' => ['required', 'numeric', 'min:0.01'],
        ]);

        $contaOrigem = $this->resolveAccountForUser($request, $data, 'conta_origem');
        $contaDestino = $this->resolveAccountForUser($request, $data, 'conta_destino');

        if ((int) $contaOrigem->id === (int) $contaDestino->id) {
            return response()->json(['message' => 'Conta de origem e destino devem ser diferentes.'], 422);
        }

        if ($contaOrigem->type === 'credit_card' || $contaDestino->type === 'credit_card') {
            return response()->json(['message' => 'Não é possível transferir para/entre cartões de crédito.'], 422);
        }

        $valor = (float) $data['valor'];

        $saldoOrigemAtual = (float) $contaOrigem->current_balance;
        $saldoDestinoAtual = (float) $contaDestino->current_balance;

        $saldoOrigemProjetado = $saldoOrigemAtual - $valor;
        $saldoDestinoProjetado = $saldoDestinoAtual + $valor;

        return response()->json([
            'conta_origem' => [
                'id' => (string) $contaOrigem->id,
                'nome' => $contaOrigem->name,
                'saldo_atual' => round($saldoOrigemAtual, 2),
                'saldo_projetado' => round($saldoOrigemProjetado, 2),
                'ficara_negativo' => $saldoOrigemProjetado < 0,
            ],
            'conta_destino' => [
                'id' => (string) $contaDestino->id,
                'nome' => $contaDestino->name,
                'saldo_atual' => round($saldoDestinoAtual, 2),
                'saldo_projetado' => round($saldoDestinoProjetado, 2),
            ],
        ]);
    }

    public function executar(Request $request): JsonResponse
    {
        $user = $request->user();

        $data = $request->validate([
            'conta_origem_id' => ['nullable', 'integer', 'required_without:conta_origem'],
            'conta_origem' => ['nullable', 'string', 'max:255', 'required_without:conta_origem_id'],
            'conta_destino_id' => ['nullable', 'integer', 'required_without:conta_destino'],
            'conta_destino' => ['nullable', 'string', 'max:255', 'required_without:conta_destino_id'],
            'valor' => ['required', 'numeric', 'min:0.01'],
            'descricao' => ['nullable', 'string', 'max:255'],
        ]);

        $valor = (float) $data['valor'];

        $origemResolved = $this->resolveAccountForUser($request, $data, 'conta_origem');
        $destinoResolved = $this->resolveAccountForUser($request, $data, 'conta_destino');

        if ((int) $origemResolved->id === (int) $destinoResolved->id) {
            return response()->json(['message' => 'Conta de origem e destino devem ser diferentes.'], 422);
        }

        if ($origemResolved->type === 'credit_card' || $destinoResolved->type === 'credit_card') {
            return response()->json(['message' => 'Não é possível transferir para/entre cartões de crédito.'], 422);
        }

        $transferencia = DB::transaction(function () use ($user, $data, $valor, $origemResolved, $destinoResolved) {
            $contaOrigem = Account::where('user_id', $user->id)->lockForUpdate()->findOrFail($origemResolved->id);
            $contaDestino = Account::where('user_id', $user->id)->lockForUpdate()->findOrFail($destinoResolved->id);

            if ((int) $contaOrigem->id === (int) $contaDestino->id) {
                throw ValidationException::withMessages([
                    'conta_destino' => ['Conta de origem e destino devem ser diferentes.'],
                ]);
            }

            if ($contaOrigem->type === 'credit_card' || $contaDestino->type === 'credit_card') {
                throw ValidationException::withMessages([
                    'conta_destino' => ['Não é possível transferir para/entre cartões de crédito.'],
                ]);
            }

            $contaOrigem->current_balance = (float) $contaOrigem->current_balance - $valor;
            $contaOrigem->save();

            $contaDestino->current_balance = (float) $contaDestino->current_balance + $valor;
            $contaDestino->save();

            return Transferencia::create([
                'user_id' => $user->id,
                'conta_origem_id' => $contaOrigem->id,
                'conta_destino_id' => $contaDestino->id,
                'valor' => $valor,
                'descricao' => $data['descricao'] ?? 'Transferência',
                'transferido_em' => now(),
            ]);
        });

        return response()->json([
            'ok' => true,
            'transferencia_id' => (string) $transferencia->id,
        ]);
    }
}
