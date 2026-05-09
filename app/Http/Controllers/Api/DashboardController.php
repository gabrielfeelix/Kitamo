<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Account;
use App\Models\Category;
use App\Models\Transaction;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function summary(Request $request): JsonResponse
    {
        $user = $request->user();
        $today = Carbon::today();
        $monthStart = $today->copy()->startOfMonth()->format('Y-m-d');
        $monthEnd = $today->copy()->endOfMonth()->format('Y-m-d');

        $totalBalance = (float) Account::query()
            ->where('user_id', $user->id)
            ->where(function ($q) {
                $q->where('is_archived', false)->orWhereNull('is_archived');
            })
            ->where('incluir_soma', true)
            ->where('type', '!=', 'credit_card')
            ->sum('current_balance');

        $monthly = Transaction::query()
            ->where('user_id', $user->id)
            ->whereBetween('transaction_date', [$monthStart, $monthEnd])
            ->selectRaw('kind, SUM(amount) as total')
            ->groupBy('kind')
            ->pluck('total', 'kind');

        $monthlyIncome = (float) ($monthly['income'] ?? 0);
        $monthlyExpenses = (float) ($monthly['expense'] ?? 0);

        $byCategoryRaw = Transaction::query()
            ->where('user_id', $user->id)
            ->where('kind', 'expense')
            ->whereBetween('transaction_date', [$monthStart, $monthEnd])
            ->selectRaw('category_id, SUM(amount) as total')
            ->groupBy('category_id')
            ->orderByDesc('total')
            ->limit(8)
            ->get();

        $categoryIds = $byCategoryRaw->pluck('category_id')->filter()->all();
        $categories = Category::whereIn('id', $categoryIds)->get()->keyBy('id');

        $byCategory = $byCategoryRaw->map(function ($row) use ($categories, $monthlyExpenses) {
            $cat = $row->category_id ? $categories->get($row->category_id) : null;
            $total = (float) $row->total;
            return [
                'category_id' => $row->category_id,
                'category_name' => $cat?->name ?? 'Sem categoria',
                'category_icon' => $cat?->icon,
                'category_color' => $cat?->color,
                'total' => $total,
                'percentage' => $monthlyExpenses > 0 ? round(($total / $monthlyExpenses) * 100, 1) : 0,
            ];
        });

        $topRecent = Transaction::query()
            ->where('user_id', $user->id)
            ->orderByDesc('transaction_date')
            ->orderByDesc('id')
            ->limit(8)
            ->get()
            ->map(fn (Transaction $t) => [
                'id' => $t->id,
                'account_id' => $t->account_id,
                'category_id' => $t->category_id,
                'kind' => $t->kind,
                'status' => $t->status,
                'amount' => (float) $t->amount,
                'description' => $t->description,
                'notes' => $t->notes,
                'transaction_date' => $t->transaction_date instanceof Carbon
                    ? $t->transaction_date->format('Y-m-d')
                    : $t->transaction_date,
                'priority' => (bool) $t->priority,
                'is_recurring' => (bool) $t->is_recurring,
                'is_parcelado' => (bool) $t->is_parcelado,
                'parcela_atual' => $t->parcela_atual,
                'parcela_total' => $t->parcela_total,
            ]);

        return response()->json([
            'total_balance' => $totalBalance,
            'monthly_income' => $monthlyIncome,
            'monthly_expenses' => $monthlyExpenses,
            'monthly_balance' => $monthlyIncome - $monthlyExpenses,
            'spending_by_category' => $byCategory,
            'top_recent' => $topRecent,
        ]);
    }
}
