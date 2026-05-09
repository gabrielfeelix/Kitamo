<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Plan;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PlanController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $plans = Plan::query()
            ->where('is_active', true)
            ->orderBy('sort_order')
            ->orderBy('price_cents')
            ->get()
            ->map(fn (Plan $p) => [
                'id' => $p->id,
                'name' => $p->name,
                'slug' => $p->slug,
                'description' => $p->description,
                'price_cents' => (int) $p->price_cents,
                'currency' => $p->currency,
                'interval' => $p->interval,
                'is_popular' => (bool) $p->is_popular,
                'trial_days' => (int) $p->trial_days,
            ]);

        return response()->json([
            'plans' => $plans,
            'current' => $request->user()?->plan_slug ?? 'free',
        ]);
    }
}
