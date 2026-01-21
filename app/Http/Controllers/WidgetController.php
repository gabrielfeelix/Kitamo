<?php

namespace App\Http\Controllers;

use App\Models\Account;
use App\Models\Transaction;
use Carbon\CarbonImmutable;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WidgetController extends Controller
{
    public function data(Request $request): JsonResponse
    {
        $user = $request->user();
        $today = CarbonImmutable::today();
        $startMonth = $today->startOfMonth();

        $saldoAtual = (float) Account::query()
            ->where('user_id', $user->id)
            ->includedInNetWorth()
            ->sum('current_balance');

        $proximasContas = Transaction::query()
            ->with('category')
            ->where('user_id', $user->id)
            ->where('kind', 'expense')
            ->where('status', 'pending')
            ->whereDate('transaction_date', '>=', $today->toDateString())
            ->orderBy('transaction_date', 'asc')
            ->limit(3)
            ->get()
            ->map(function (Transaction $t) {
                $date = CarbonImmutable::parse($t->transaction_date);

                return [
                    'id' => (string) $t->id,
                    'descricao' => $t->description,
                    'valor' => (float) $t->amount,
                    'data' => $date->format('d/m'),
                    'categoria' => $t->category?->name ?? 'Sem categoria',
                    'icone' => $t->category?->icon ?? 'shopping-cart',
                ];
            })
            ->values();

        $receitas = (float) Transaction::query()
            ->where('user_id', $user->id)
            ->where('kind', 'income')
            ->where('status', 'received')
            ->where('data_pagamento', '>=', $startMonth->toDateTimeString())
            ->sum('amount');

        $despesas = (float) Transaction::query()
            ->where('user_id', $user->id)
            ->where('kind', 'expense')
            ->where('status', 'paid')
            ->where('data_pagamento', '>=', $startMonth->toDateTimeString())
            ->sum('amount');

        $balancoMes = $receitas - $despesas;

        return response()->json([
            'saldo_atual' => round($saldoAtual, 2),
            'saldo_formatado' => 'R$ ' . number_format($saldoAtual, 2, ',', '.'),
            'proximas_contas' => $proximasContas,
            'balanco_mes' => round($balancoMes, 2),
            'balanco_mes_formatado' => 'R$ ' . number_format($balancoMes, 2, ',', '.'),
            'deep_link_adicionar' => 'kitamo://transaction/create',
        ]);
    }
}
