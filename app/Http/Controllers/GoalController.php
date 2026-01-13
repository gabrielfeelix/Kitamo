<?php

namespace App\Http\Controllers;

use App\Models\Goal;
use App\Support\KitamoBootstrap;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GoalController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        $user = $request->user();

        $data = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'target_amount' => ['required', 'numeric', 'min:0'],
            'due_date' => ['nullable', 'date'],
            'icon' => ['nullable', 'string', 'max:64'],
            'term' => ['nullable', 'string', 'max:16'],
        ]);

        $goal = Goal::create([
            'user_id' => $user->id,
            'title' => $data['title'],
            'target_amount' => $data['target_amount'],
            'current_amount' => 0,
            'due_date' => $data['due_date'] ?? null,
            'status' => 'on_track',
            'icon' => $data['icon'] ?? 'home',
            'term' => $data['term'] ?? null,
            'tags' => [],
        ]);

        return response()->json([
            'goal' => app(KitamoBootstrap::class)->goal($goal->load('deposits')),
        ]);
    }

    public function update(Request $request, Goal $goal): JsonResponse
    {
        $user = $request->user();
        if ($goal->user_id !== $user->id) {
            abort(404);
        }

        $data = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'target_amount' => ['required', 'numeric', 'min:0'],
            'due_date' => ['nullable', 'date'],
            'icon' => ['nullable', 'string', 'max:64'],
            'term' => ['nullable', 'string', 'max:16'],
        ]);

        $goal->update([
            'title' => $data['title'],
            'target_amount' => $data['target_amount'],
            'due_date' => $data['due_date'] ?? null,
            'icon' => $data['icon'] ?? $goal->icon,
            'term' => $data['term'] ?? $goal->term,
        ]);

        return response()->json([
            'goal' => app(KitamoBootstrap::class)->goal($goal->load('deposits')),
        ]);
    }

    public function destroy(Request $request, Goal $goal): JsonResponse
    {
        $user = $request->user();
        if ($goal->user_id !== $user->id) {
            abort(404);
        }

        $goal->delete();

        return response()->json(['ok' => true]);
    }
}
