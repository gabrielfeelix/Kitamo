<?php

namespace App\Http\Controllers;

use App\Models\Category;
use App\Support\KitamoBootstrap;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class CategoryController extends Controller
{
    /**
     * System categories that are locked (cannot be edited by users).
     */
    private function isLockedSystemCategoryName(string $name): bool
    {
        $normalized = (string) Str::of($name)->trim()->lower()->ascii()->replaceMatches('/\s+/', ' ');
        return in_array($normalized, ['alimentacao', 'lazer', 'moradia', 'saude', 'transporte'], true);
    }

    public function store(Request $request): JsonResponse
    {
        $user = $request->user();

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'type' => ['required', 'in:income,expense'],
            'color' => ['required', 'string', 'regex:/^#[0-9A-F]{6}$/i'],
            'icon' => ['required', 'string', 'max:64'],
        ]);

        if ($this->isLockedSystemCategoryName($data['name'])) {
            return response()->json(['message' => 'Essa categoria é do sistema e não pode ser criada/alterada.'], 422);
        }

        $category = Category::create([
            'user_id' => $user->id,
            'name' => $data['name'],
            'type' => $data['type'],
            'color' => strtoupper($data['color']),
            'icon' => $data['icon'],
            'is_default' => false,
        ]);

        return response()->json(app(KitamoBootstrap::class)->category($category), 201);
    }

    public function update(Request $request, Category $category): JsonResponse
    {
        $user = $request->user();

        if ($category->user_id !== $user->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        if ($category->is_default || $this->isLockedSystemCategoryName($category->name)) {
            return response()->json(['message' => 'Cannot edit default categories'], 403);
        }

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'color' => ['required', 'string', 'regex:/^#[0-9A-F]{6}$/i'],
            'icon' => ['required', 'string', 'max:64'],
        ]);

        $category->update([
            'name' => $data['name'],
            'color' => strtoupper($data['color']),
            'icon' => $data['icon'],
        ]);

        return response()->json(app(KitamoBootstrap::class)->category($category));
    }

    public function destroy(Category $category): JsonResponse
    {
        $user = request()->user();

        if ($category->user_id !== $user->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        if ($category->is_default || $this->isLockedSystemCategoryName($category->name)) {
            return response()->json(['message' => 'Cannot delete default categories'], 403);
        }

        // A FK é nullOnDelete: apagar uma categoria em uso orfana todas as
        // transações históricas (category_id = NULL) e corrompe relatórios
        // passados de forma irreversível. Exige uma categoria de destino.
        $emUso = \App\Models\Transaction::query()
            ->where('user_id', $user->id)
            ->where('category_id', $category->id)
            ->count();

        if ($emUso > 0) {
            $destinoId = request()->input('reassign_to');

            if (! $destinoId) {
                return response()->json([
                    'message' => "Esta categoria está em uso por {$emUso} transação(ões). "
                        . 'Informe reassign_to com a categoria de destino.',
                    'transactions_count' => $emUso,
                    'requires_reassign' => true,
                ], 409);
            }

            $destino = Category::query()
                ->where('id', $destinoId)
                ->where('user_id', $user->id)
                ->first();

            if (! $destino || (int) $destino->id === (int) $category->id) {
                return response()->json(['message' => 'Categoria de destino inválida.'], 422);
            }

            \DB::transaction(function () use ($category, $destino, $user) {
                \App\Models\Transaction::query()
                    ->where('user_id', $user->id)
                    ->where('category_id', $category->id)
                    ->update(['category_id' => $destino->id]);

                $category->delete();
            });

            return response()->json([
                'message' => 'Category deleted successfully',
                'reassigned' => $emUso,
                'reassigned_to' => $destino->name,
            ]);
        }

        $category->delete();

        return response()->json(['message' => 'Category deleted successfully']);
    }
}
