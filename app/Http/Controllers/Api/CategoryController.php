<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Transaction;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $userId = $request->user()->id;

        $categories = Category::query()
            ->where(function ($q) use ($userId) {
                $q->whereNull('user_id')->orWhere('user_id', $userId);
            })
            ->orderBy('name')
            ->get();

        $monthStart = Carbon::today()->startOfMonth()->format('Y-m-d');
        $monthEnd = Carbon::today()->endOfMonth()->format('Y-m-d');

        $spentByCat = Transaction::query()
            ->where('user_id', $userId)
            ->where('kind', 'expense')
            ->whereBetween('transaction_date', [$monthStart, $monthEnd])
            ->selectRaw('category_id, SUM(amount) as total')
            ->groupBy('category_id')
            ->pluck('total', 'category_id');

        $shaped = $categories->map(fn (Category $c) => [
            'id' => $c->id,
            'name' => $c->name,
            'type' => $c->type,
            'color' => $c->color,
            'icon' => $c->icon,
            'is_default' => (bool) $c->is_default,
            'budget_limit' => $c->budget_limit !== null ? (float) $c->budget_limit : null,
            'spent_this_month' => (float) ($spentByCat[$c->id] ?? 0),
        ]);

        return response()->json(['categories' => $shaped]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:80'],
            'type' => ['required', 'in:expense,income'],
            'color' => ['nullable', 'string', 'max:20'],
            'icon' => ['nullable', 'string', 'max:60'],
            'budget_limit' => ['nullable', 'numeric', 'min:0'],
        ]);

        $category = Category::create([
            ...$data,
            'user_id' => $request->user()->id,
            'is_default' => false,
        ]);

        return response()->json(['category' => $this->shape($category, 0)], 201);
    }

    public function update(Request $request, Category $category): JsonResponse
    {
        $this->authorizeCategory($request, $category);

        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:80'],
            'color' => ['nullable', 'string', 'max:20'],
            'icon' => ['nullable', 'string', 'max:60'],
            'budget_limit' => ['nullable', 'numeric', 'min:0'],
        ]);

        $category->update($data);

        return response()->json(['category' => $this->shape($category->fresh(), null)]);
    }

    public function destroy(Request $request, Category $category): JsonResponse
    {
        $this->authorizeCategory($request, $category);

        if ($category->is_default || $category->user_id === null) {
            abort(422, 'Categorias padrão não podem ser apagadas.');
        }

        $category->delete();

        return response()->json(['ok' => true]);
    }

    private function authorizeCategory(Request $request, Category $category): void
    {
        if ($category->user_id !== null && $category->user_id !== $request->user()->id) {
            abort(404);
        }
    }

    private function shape(Category $c, ?float $spent): array
    {
        return [
            'id' => $c->id,
            'name' => $c->name,
            'type' => $c->type,
            'color' => $c->color,
            'icon' => $c->icon,
            'is_default' => (bool) $c->is_default,
            'budget_limit' => $c->budget_limit !== null ? (float) $c->budget_limit : null,
            'spent_this_month' => (float) ($spent ?? 0),
        ];
    }
}
