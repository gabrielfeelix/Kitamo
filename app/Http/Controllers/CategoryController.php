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
            'color' => ['nullable', 'string', 'max:32'],
            'icon' => ['nullable', 'string', 'max:64'],
        ]);

        $category = Category::create([
            'user_id' => $user->id,
            'name' => $data['name'],
            'type' => $data['type'],
            'color' => $data['color'] ?? null,
            'icon' => $data['icon'] ?? null,
            'is_default' => false,
        ]);

        return response()->json([
            'category' => app(KitamoBootstrap::class)->category($category),
        ]);
    }
}
