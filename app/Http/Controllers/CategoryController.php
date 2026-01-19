<?php

namespace App\Http\Controllers;

use App\Models\Category;
use App\Support\KitamoBootstrap;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        $user = $request->user();

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'type' => ['required', 'in:income,expense'],
            'color' => ['required', 'string', 'regex:/^#[0-9A-F]{6}$/i'],
            'icon' => ['required', 'string', 'max:64'],
        ]);

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

        if ($category->is_default) {
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

        if ($category->is_default) {
            return response()->json(['message' => 'Cannot delete default categories'], 403);
        }

        $category->delete();

        return response()->json(['message' => 'Category deleted successfully']);
    }
}
