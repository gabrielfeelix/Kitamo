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
            'investment_id' => ['nullable', 'integer', 'exists:investments,id'],
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
            'investment_id' => $data['investment_id'] ?? null,
            'tags' => [],
        ]);

        return response()->json([
            'goal' => app(KitamoBootstrap::class)->goal($goal->load(['deposits', 'investment'])),
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
            'investment_id' => ['nullable', 'integer', 'exists:investments,id'],
        ]);

        $goal->update([
            'title' => $data['title'],
            'target_amount' => $data['target_amount'],
            'due_date' => $data['due_date'] ?? null,
            'icon' => $data['icon'] ?? $goal->icon,
            'term' => $data['term'] ?? $goal->term,
            // array_key_exists e não ?? : enviar null aqui é como se desfaz o
            // vínculo com o investimento.
            'investment_id' => array_key_exists('investment_id', $data) ? $data['investment_id'] : $goal->investment_id,
        ]);

        return response()->json([
            'goal' => app(KitamoBootstrap::class)->goal($goal->load(['deposits', 'investment'])),
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
