<?php

namespace App\Http\Controllers;

use App\Models\Goal;
use App\Models\GoalDeposit;
use App\Support\KitamoBootstrap;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GoalDepositController extends Controller
{
    public function store(Request $request, Goal $goal): JsonResponse
    {
        $user = $request->user();
        if ($goal->user_id !== $user->id) {
            abort(404);
        }

        $data = $request->validate([
            'amount' => ['required', 'numeric', 'min:0.01'],
            'title' => ['nullable', 'string', 'max:255'],
            'subtitle' => ['nullable', 'string', 'max:255'],
            'deposited_at' => ['nullable', 'date'],
        ]);

        $deposit = GoalDeposit::create([
            'goal_id' => $goal->id,
            'title' => $data['title'] ?? 'Depósito',
            'subtitle' => $data['subtitle'] ?? null,
            'amount' => $data['amount'],
            'deposited_at' => $data['deposited_at'] ?? now(),
        ]);

        $goal->current_amount = ($goal->current_amount ?? 0) + $deposit->amount;
        $goal->save();

        return response()->json([
            'goal' => app(KitamoBootstrap::class)->goal($goal->load('deposits')),
        ]);
    }
}
