<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Account;
use App\Models\Transaction;
use App\Services\GeminiClient;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use RuntimeException;

class AiController extends Controller
{
    public function tips(Request $request): JsonResponse
    {
        $user = $request->user();
        $context = $this->buildFinancialContext($user->id);

        $systemPrompt = <<<'PROMPT'
Você é um assistente financeiro carinhoso e direto, focado em pessoas de baixa renda no Brasil.
Sua missão: dar 3 a 5 dicas curtas, práticas e empáticas baseadas nos dados financeiros do usuário.
Use linguagem simples, sem jargão. Cada dica tem título curto (até 6 palavras) e corpo de 1-2 frases.
Severity: "good" para elogios/conquistas, "warn" para alertas importantes, "info" para sugestões neutras.
Responda APENAS JSON no formato: {"tips": [{"title": "...", "body": "...", "severity": "info|warn|good"}]}
PROMPT;

        try {
            $gemini = GeminiClient::fromConfig();
            $result = $gemini->generateJson($systemPrompt, $context);
        } catch (RuntimeException $e) {
            return response()->json([
                'tips' => $this->fallbackTips($user->id),
                'fallback' => true,
            ]);
        }

        $tips = $result['tips'] ?? [];
        $tips = array_values(array_filter($tips, fn ($t) => is_array($t) && isset($t['title'], $t['body'])));

        return response()->json(['tips' => $tips]);
    }

    public function chat(Request $request): JsonResponse
    {
        $data = $request->validate([
            'message' => ['required', 'string', 'max:500'],
        ]);

        $context = $this->buildFinancialContext($request->user()->id);

        $systemPrompt = <<<'PROMPT'
Você é um assistente financeiro do Kitamo. Responda de forma curta (até 4 frases),
empática e prática. Linguagem simples, sem jargão. Foque em pessoas de baixa renda.
Use os dados financeiros fornecidos para personalizar a resposta.
PROMPT;

        $userPrompt = "Dados do usuário:\n{$context}\n\nPergunta: {$data['message']}";

        try {
            $gemini = GeminiClient::fromConfig();
            $reply = $gemini->generateText($systemPrompt, $userPrompt);
        } catch (RuntimeException $e) {
            return response()->json([
                'reply' => 'A IA está indisponível agora. Tente novamente em instantes.',
                'fallback' => true,
            ]);
        }

        return response()->json(['reply' => $reply]);
    }

    private function buildFinancialContext(int $userId): string
    {
        $today = Carbon::today();
        $monthStart = $today->copy()->startOfMonth()->format('Y-m-d');
        $monthEnd = $today->copy()->endOfMonth()->format('Y-m-d');

        $totalBalance = (float) Account::query()
            ->where('user_id', $userId)
            ->where(function ($q) {
                $q->where('is_archived', false)->orWhereNull('is_archived');
            })
            ->where('incluir_soma', true)
            ->where('type', '!=', 'credit_card')
            ->sum('current_balance');

        $monthly = Transaction::query()
            ->where('user_id', $userId)
            ->whereBetween('transaction_date', [$monthStart, $monthEnd])
            ->selectRaw('kind, SUM(amount) as total')
            ->groupBy('kind')
            ->pluck('total', 'kind');

        $income = (float) ($monthly['income'] ?? 0);
        $expenses = (float) ($monthly['expense'] ?? 0);

        $byCategory = Transaction::query()
            ->where('transactions.user_id', $userId)
            ->where('kind', 'expense')
            ->whereBetween('transaction_date', [$monthStart, $monthEnd])
            ->leftJoin('categories', 'categories.id', '=', 'transactions.category_id')
            ->selectRaw('COALESCE(categories.name, "Sem categoria") as cat, SUM(amount) as total')
            ->groupBy('cat')
            ->orderByDesc('total')
            ->limit(5)
            ->get();

        $catLines = $byCategory
            ->map(fn ($r) => "- {$r->cat}: R$ " . number_format((float) $r->total, 2, ',', '.'))
            ->implode("\n");

        $balanceFmt = number_format($totalBalance, 2, ',', '.');
        $incomeFmt = number_format($income, 2, ',', '.');
        $expensesFmt = number_format($expenses, 2, ',', '.');
        $month = $today->translatedFormat('F/Y');

        return <<<TXT
Mês: {$month}
Saldo geral atual: R$ {$balanceFmt}
Receita do mês: R$ {$incomeFmt}
Gastos do mês: R$ {$expensesFmt}

Top categorias de gasto:
{$catLines}
TXT;
    }

    private function fallbackTips(int $userId): array
    {
        $tips = [];
        $today = Carbon::today();
        $monthStart = $today->copy()->startOfMonth()->format('Y-m-d');
        $monthEnd = $today->copy()->endOfMonth()->format('Y-m-d');

        $monthly = Transaction::query()
            ->where('user_id', $userId)
            ->whereBetween('transaction_date', [$monthStart, $monthEnd])
            ->selectRaw('kind, SUM(amount) as total')
            ->groupBy('kind')
            ->pluck('total', 'kind');

        $income = (float) ($monthly['income'] ?? 0);
        $expenses = (float) ($monthly['expense'] ?? 0);

        if ($income > 0 && $expenses > 0) {
            $ratio = $expenses / $income;
            if ($ratio > 0.9) {
                $tips[] = [
                    'title' => 'Gasto perto da renda',
                    'body' => 'Você está gastando ' . number_format($ratio * 100, 0) . '% do que ganha. Vale dar uma olhada nas categorias maiores.',
                    'severity' => 'warn',
                ];
            } elseif ($ratio < 0.7) {
                $tips[] = [
                    'title' => 'Sobrando dinheiro',
                    'body' => 'Você gastou ' . number_format($ratio * 100, 0) . '% do que ganhou. Considere guardar uma parte.',
                    'severity' => 'good',
                ];
            }
        }

        if (empty($tips)) {
            $tips[] = [
                'title' => 'Comece registrando',
                'body' => 'Adicione seus gastos e receitas pra eu poder te ajudar com dicas personalizadas.',
                'severity' => 'info',
            ];
        }

        return $tips;
    }
}
