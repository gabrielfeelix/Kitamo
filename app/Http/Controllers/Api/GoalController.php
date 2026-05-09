<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Goal;
use App\Models\GoalDeposit;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GoalController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $goals = Goal::query()
            ->where('user_id', $request->user()->id)
            ->withCount('deposits')
            ->orderBy('status')
            ->orderBy('id')
            ->get()
            ->map(fn (Goal $g) => $this->shape($g));

        return response()->json(['goals' => $goals]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'title' => ['required', 'string', 'max:120'],
            'target_amount' => ['required', 'numeric', 'min:0.01'],
            'due_date' => ['nullable', 'date'],
            'color' => ['nullable', 'string', 'max:20'],
            'icon' => ['nullable', 'string', 'max:60'],
        ]);

        $goal = Goal::create([
            ...$data,
            'user_id' => $request->user()->id,
            'current_amount' => 0,
            'status' => 'active',
        ]);

        return response()->json(['goal' => $this->shape($goal)], 201);
    }

    public function destroy(Request $request, Goal $goal): JsonResponse
    {
        $this->authorize_goal($request, $goal);
        $goal->delete();
        return response()->json(['ok' => true]);
    }

    public function deposit(Request $request, Goal $goal): JsonResponse
    {
        $this->authorize_goal($request, $goal);

        $data = $request->validate([
            'amount' => ['required', 'numeric', 'min:0.01'],
            'notes' => ['nullable', 'string', 'max:255'],
            'deposit_date' => ['nullable', 'date'],
            'title' => ['nullable', 'string', 'max:120'],
        ]);

        $deposit = GoalDeposit::create([
            'goal_id' => $goal->id,
            'title' => $data['title'] ?? 'Depósito',
            'subtitle' => $data['notes'] ?? null,
            'amount' => $data['amount'],
            'deposited_at' => $data['deposit_date'] ?? now(),
        ]);

        $goal->current_amount = (float) $goal->current_amount + (float) $data['amount'];
        if ($goal->current_amount >= (float) $goal->target_amount) {
            $goal->status = 'completed';
        }
        $goal->save();

        return response()->json([
            'deposit' => [
                'id' => $deposit->id,
                'goal_id' => $deposit->goal_id,
                'amount' => (float) $deposit->amount,
                'deposit_date' => optional($deposit->deposited_at)->format('Y-m-d'),
                'notes' => $deposit->subtitle,
            ],
        ], 201);
    }

    private function authorize_goal(Request $request, Goal $goal): void
    {
        abort_if($goal->user_id !== $request->user()->id, 404);
    }

    private function shape(Goal $g): array
    {
        return [
            'id' => $g->id,
            'title' => $g->title,
            'target_amount' => (float) $g->target_amount,
            'current_amount' => (float) $g->current_amount,
            'due_date' => $g->due_date?->format('Y-m-d'),
            'status' => $g->status,
            'color' => $g->color,
            'icon' => $g->icon,
            'deposits_count' => $g->deposits_count ?? 0,
        ];
    }
}
