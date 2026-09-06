<?php

namespace App\Http\Controllers;

use App\Models\Account;
use App\Models\Category;
use App\Models\Transaction;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CreditCardController extends Controller
{
    private function getBankLogoPath(?string $institution): ?string
    {
        if (!$institution) {
            return null;
        }

        $logoMap = [
            'Nubank' => 'nubank-logo-svg.png',
            'Nu Pagamentos S.A' => 'nubank-logo-svg.png',
            'Banco Inter S.A' => 'Banco Inter S.A/inter.svg',
            'Banco Inter' => 'Banco Inter S.A/inter.svg',
            'Inter' => 'Banco Inter S.A/inter.svg',
            'Itaú' => 'Itaú/itau-oficial.png',
            'Itau' => 'Itaú/itau-oficial.png',
            'Banco Itaú' => 'Itaú/itau-oficial.png',
            'Itaú Unibanco' => 'Itaú/itau-oficial.png',
            'Bradesco' => 'Bradesco S.A/bradesco com nome.svg',
            'Bradesco S.A' => 'Bradesco S.A/bradesco com nome.svg',
            'Banco do Brasil' => 'Banco do Brasil S.A/banco-do-brasil-com-fundo.svg',
            'Banco do Brasil S.A' => 'Banco do Brasil S.A/banco-do-brasil-com-fundo.svg',
            'Caixa' => 'Caixa Econômica Federal/caixa-economica-federal-1.svg',
            'Caixa Econômica Federal' => 'Caixa Econômica Federal/caixa-economica-federal-1.svg',
            'Santander' => 'Banco Santander Brasil S.A/banco-santander-logo.svg',
            'Banco Santander Brasil S.A' => 'Banco Santander Brasil S.A/banco-santander-logo.svg',
            'Banco Santander' => 'Banco Santander Brasil S.A/banco-santander-logo.svg',
            'C6 Bank' => 'C6 Bank/c6-bank-logo-oficial-vector.png',
            'Banco C6 S.A' => 'C6 Bank/c6-bank-logo-oficial-vector.png',
            'PicPay' => 'PicPay/Logo-PicPay -nome .svg',
            'Neon' => 'Neon/header-logo-neon.svg',
            'Banco Safra S.A' => 'Banco Safra S.A/logo-safra-nome.svg',
            'Banco Votorantim' => 'Banco Votorantim/banco-bv-logo.svg',
            'Banco BTG Pacutal' => 'Banco BTG Pacutal/btg-pactual-nome .svg',
            'Banco Original S.A' => 'Banco Original S.A/banco-original-logo-branco-nome.svg',
            'Banco Sofisa' => 'Banco Sofisa/logo-banco-sofisa-verde.svg',
            'Banco Mercantil do Brasil S.A' => 'Banco Mercantil do Brasil S.A/banco-mercantil-novo-azul.svg',
        ];

        return $logoMap[$institution] ?? null;
    }

    private function invoicePeriod(Account $cartao, int $year, int $monthIndex): array
    {
        $closingDayRaw = (int) ($cartao->closing_day ?? 0);
        $dueDayRaw = (int) ($cartao->due_day ?? 0);

        $monthStart = Carbon::create($year, $monthIndex + 1, 1)->startOfDay();

        if ($closingDayRaw <= 0) {
            return [
                'start' => $monthStart->copy(),
                'end' => $monthStart->copy()->endOfMonth()->endOfDay(),
            ];
        }

        // A fatura mostrada no mês é a que VENCE nesse mês.
        // O fechamento é a data de fechamento mais recente ANTES do vencimento.
        $dueDays = (int) $monthStart->daysInMonth;
        $dueDay = $dueDayRaw > 0 ? min($dueDayRaw, $dueDays) : $dueDays;
        $due = Carbon::create($year, $monthIndex + 1, $dueDay)->endOfDay();

        $closingThisMonth = Carbon::create($year, $monthIndex + 1, min($closingDayRaw, $dueDays))->endOfDay();

        if ($closingThisMonth->lessThan($due)) {
            $end = $closingThisMonth;
        } else {
            $prev = $monthStart->copy()->subMonthNoOverflow();
            $end = Carbon::create($prev->year, $prev->month, min($closingDayRaw, (int) $prev->daysInMonth))->endOfDay();
        }

        $cycleStartMonth = $end->copy()->subMonthNoOverflow();
        $startDay = $closingDayRaw + 1;
        $cycleDays = (int) $cycleStartMonth->daysInMonth;

        if ($startDay > $cycleDays) {
            $start = $end->copy()->startOfMonth()->startOfDay();
        } else {
            $start = Carbon::create($cycleStartMonth->year, $cycleStartMonth->month, $startDay)->startOfDay();
        }

        return [
            'start' => $start,
            'end' => $end,
        ];
    }

    public function index(Request $request)
    {
        $user = $request->user();

        $cartoes = Account::query()
            ->where('user_id', $user->id)
            ->where('type', 'credit_card')
            ->orderBy('id', 'desc')
            ->get()
            ->map(function (Account $account) {
                $svgPath = $this->getBankLogoPath($account->institution);

                return [
                    'id' => (string) $account->id,
                    'nome' => $account->name,
                    'bandeira' => ($account->card_brand ?: 'visa'),
                    'limite' => (float) ($account->credit_limit ?? 0),
                    'limite_usado' => (float) ($account->current_balance ?? 0),
                    'dia_fechamento' => (int) ($account->closing_day ?? 10),
                    'dia_vencimento' => (int) ($account->due_day ?? 17),
                    'cor' => ($account->color ?: '#8B5CF6'),
                    'banco' => $account->institution,
                    'svgPath' => $svgPath,
                ];
            });

        return response()->json([
            'cartoes' => $cartoes,
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'nome' => ['required', 'string', 'max:50'],
            'bandeira' => ['nullable', 'string', 'max:30'],
            'limite' => ['required', 'numeric', 'min:0'],
            'dia_fechamento' => ['required', 'integer', 'min:1', 'max:31'],
            'dia_vencimento' => ['required', 'integer', 'min:1', 'max:31'],
            'cor' => ['nullable', 'string', 'max:20'],
            'icone' => ['nullable', 'string', 'max:50'],
            'institution' => ['nullable', 'string', 'max:255'],
            'is_primary' => ['nullable', 'boolean'],
        ]);

        $account = Account::create([
            'user_id' => $request->user()->id,
            'name' => $data['nome'],
            'type' => 'credit_card',
            'icon' => $data['icone'] ?? 'credit-card',
            'color' => $data['cor'] ?? '#8B5CF6',
            'card_brand' => $data['bandeira'] ?? 'visa',
            'initial_balance' => 0,
            'current_balance' => 0,
            'credit_limit' => $data['limite'],
            'closing_day' => $data['dia_fechamento'],
            'due_day' => $data['dia_vencimento'],
            'institution' => $data['institution'] ?? null,
            'is_primary' => $data['is_primary'] ?? false,
        ]);

        return response()->json([
            'id' => (string) $account->id,
        ], 201);
    }

    public function update(Request $request, Account $cartao)
    {
        abort_unless($request->user()->id === $cartao->user_id, 403);
        abort_unless($cartao->type === 'credit_card', 404);

        $data = $request->validate([
            'nome' => ['sometimes', 'required', 'string', 'max:50'],
            'bandeira' => ['nullable', 'string', 'max:30'],
            'limite' => ['sometimes', 'required', 'numeric', 'min:0'],
            'dia_fechamento' => ['sometimes', 'required', 'integer', 'min:1', 'max:31'],
            'dia_vencimento' => ['sometimes', 'required', 'integer', 'min:1', 'max:31'],
            'cor' => ['nullable', 'string', 'max:20'],
            'icone' => ['nullable', 'string', 'max:50'],
            'institution' => ['nullable', 'string', 'max:255'],
            'is_primary' => ['nullable', 'boolean'],
        ]);

        $cartao->fill([
            'name' => $data['nome'] ?? $cartao->name,
            'credit_limit' => array_key_exists('limite', $data) ? $data['limite'] : $cartao->credit_limit,
            'closing_day' => array_key_exists('dia_fechamento', $data) ? $data['dia_fechamento'] : $cartao->closing_day,
            'due_day' => array_key_exists('dia_vencimento', $data) ? $data['dia_vencimento'] : $cartao->due_day,
            'icon' => $data['icone'] ?? $cartao->icon,
            'color' => $data['cor'] ?? $cartao->color,
            'card_brand' => $data['bandeira'] ?? $cartao->card_brand,
            'institution' => array_key_exists('institution', $data) ? ($data['institution'] ?: null) : $cartao->institution,
            'is_primary' => array_key_exists('is_primary', $data) ? $data['is_primary'] : $cartao->is_primary,
        ]);
        $cartao->save();

        return response()->json(['ok' => true]);
    }

    public function destroy(Request $request, Account $cartao)
    {
        abort_unless($request->user()->id === $cartao->user_id, 403);
        abort_unless($cartao->type === 'credit_card', 404);

        $userId = $request->user()->id;
        $today = Carbon::today()->toDateString();

        $totalTransactions = (int) Transaction::query()
            ->where('user_id', $userId)
            ->where('account_id', $cartao->id)
            ->count();

        $parcelasPendentes = (int) Transaction::query()
            ->where('user_id', $userId)
            ->where('account_id', $cartao->id)
            ->whereNotNull('parcelamento_grupo_id')
            ->where('status', 'pending')
            ->where('transaction_date', '>', $today)
            ->count();

        $comprasPendentes = (int) Transaction::query()
            ->where('user_id', $userId)
            ->where('account_id', $cartao->id)
            ->where('kind', 'expense')
            ->where('status', 'pending')
            ->count();

        $cartao->delete();

        return response()->json([
            'ok' => true,
            'deleted' => [
                'transactions' => $totalTransactions,
                'compras_pendentes' => $comprasPendentes,
                'parcelas_pendentes_futuras' => $parcelasPendentes,
            ],
        ]);
    }

    public function getByMonth(Request $request)
    {
        $user = $request->user();

        $data = $request->validate([
            'year' => ['required', 'integer', 'min:2020', 'max:2099'],
            'month' => ['required', 'integer', 'min:0', 'max:11'],
        ]);

        $year = (int) $data['year'];
        $month = (int) $data['month'];

        $creditCards = Account::where('user_id', $user->id)
            ->where('type', 'credit_card')
            ->get();

        $result = $creditCards->map(function (Account $account) use ($year, $month, $user) {
            $period = $this->invoicePeriod($account, $year, $month);
            $start = $period['start'];
            $end = $period['end'];

            $accountCreatedAt = $account->created_at ? Carbon::parse($account->created_at) : null;
            if ($accountCreatedAt && $accountCreatedAt->greaterThan($end)) {
                $balanceUsed = 0.0;
            } else {
                $expenseSum = (float) Transaction::query()
                    ->where('user_id', $user->id)
                    ->where('account_id', $account->id)
                    ->where('kind', 'expense')
                    ->whereBetween('transaction_date', [$start, $end])
                    ->where('status', 'pending')
                    ->sum('amount');

                $incomeSum = (float) Transaction::query()
                    ->where('user_id', $user->id)
                    ->where('account_id', $account->id)
                    ->where('kind', 'income')
                    ->whereBetween('transaction_date', [$start, $end])
                    ->whereIn('status', ['received'])
                    ->sum('amount');

                $balanceUsed = max(0.0, $expenseSum - $incomeSum);
            }

            $svgPath = $this->getBankLogoPath($account->institution);

            return [
                'id' => (string) $account->id,
                'nome' => $account->name,
                'bandeira' => $account->card_brand ?: 'visa',
                'limite' => (float) ($account->credit_limit ?? 0),
                'limite_usado' => $balanceUsed,
                'dia_fechamento' => (int) ($account->closing_day ?? 10),
                'dia_vencimento' => (int) ($account->due_day ?? 17),
                'cor' => $account->color ?: '#8B5CF6',
                'is_primary' => (bool) $account->is_primary,
                'banco' => $account->institution,
                'svgPath' => $svgPath,
            ];
        });

        return response()->json([
            'cartoes' => $result->values(),
        ]);
    }

    public function payInvoice(Request $request, Account $cartao): JsonResponse
    {
        $user = $request->user();
        abort_unless((int) $cartao->user_id === (int) $user->id, 404);
        abort_unless($cartao->type === 'credit_card', 404);

        $data = $request->validate([
            'year' => ['required', 'integer', 'min:2020', 'max:2099'],
            'month' => ['required', 'integer', 'min:0', 'max:11'],
            'pay_account' => ['required', 'string', 'max:255'],
        ]);

        $year = (int) $data['year'];
        $month = (int) $data['month'];
        $payAccountName = trim((string) $data['pay_account']);

        $payAccount = Account::query()
            ->where('user_id', $user->id)
            ->where('type', '!=', 'credit_card')
            ->where('name', $payAccountName)
            ->first();

        if (!$payAccount) {
            return response()->json(['message' => 'Conta para pagamento inválida.'], 422);
        }

        $period = $this->invoicePeriod($cartao, $year, $month);
        $start = $period['start'];
        $end = $period['end'];

        $invoiceQuery = Transaction::query()
            ->where('user_id', $user->id)
            ->where('account_id', $cartao->id)
            ->where('kind', 'expense')
            ->whereBetween('transaction_date', [$start, $end])
            ->where('status', 'pending');

        $invoiceTotal = (float) $invoiceQuery->sum('amount');

        if ($invoiceTotal <= 0) {
            return response()->json([
                'paid' => true,
                'amount' => 0,
            ]);
        }

        if ((float) ($payAccount->current_balance ?? 0) < $invoiceTotal) {
            return response()->json(['message' => 'Saldo insuficiente.'], 422);
        }

        $category = Category::query()->firstOrCreate(
            [
                'user_id' => $user->id,
                'name' => 'Fatura do cartão',
                'type' => 'expense',
            ],
            [
                'is_default' => false,
                'color' => '#EF4444',
                'icon' => 'card',
            ],
        );

        Transaction::create([
            'user_id' => $user->id,
            'account_id' => $payAccount->id,
            'category_id' => $category->id,
            'kind' => 'expense',
            'status' => 'paid',
            'amount' => $invoiceTotal,
            'moeda' => $payAccount->moeda ?? 'BRL',
            'description' => sprintf('Pagamento de fatura - %s', $cartao->name),
            'transaction_date' => now()->toDateString(),
            'priority' => false,
            'is_recurring' => false,
            'is_parcelado' => false,
            'data_pagamento' => now(),
            'tags' => [],
        ]);

        $payAccount->current_balance = (float) ($payAccount->current_balance ?? 0) - $invoiceTotal;
        $payAccount->save();

        $invoiceQuery->update([
            'status' => 'paid',
            'data_pagamento' => now(),
        ]);

        return response()->json([
            'paid' => true,
            'amount' => $invoiceTotal,
        ]);
    }
}
