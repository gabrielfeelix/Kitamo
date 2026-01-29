<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Plan;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Inertia\Inertia;
use Inertia\Response;

class PlanController extends Controller
{
    public function index(): Response
    {
        $plans = Plan::query()
            ->orderByDesc('is_active')
            ->orderByDesc('is_popular')
            ->orderBy('sort_order')
            ->orderBy('price_cents')
            ->get()
            ->map(fn (Plan $p) => [
                'id' => (int) $p->id,
                'name' => (string) $p->name,
                'slug' => (string) $p->slug,
                'description' => $p->description,
                'price_cents' => (int) $p->price_cents,
                'currency' => (string) ($p->currency ?? 'BRL'),
                'interval' => (string) ($p->interval ?? 'monthly'),
                'accounts_limit' => $p->accounts_limit === null ? null : (int) $p->accounts_limit,
                'cards_limit' => $p->cards_limit === null ? null : (int) $p->cards_limit,
                'projection_days' => (int) ($p->projection_days ?? 30),
                'backup_enabled' => (bool) $p->backup_enabled,
                'recurring_enabled' => (bool) $p->recurring_enabled,
                'priority_support' => (bool) $p->priority_support,
                'trial_days' => (int) ($p->trial_days ?? 0),
                'requires_card' => (bool) $p->requires_card,
                'is_popular' => (bool) $p->is_popular,
                'is_active' => (bool) $p->is_active,
            ]);

        return Inertia::render('Admin/Plans', [
            'plans' => $plans,
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $data = $this->validatePlan($request);

        $slug = Str::slug((string) $data['name']);
        if (! $slug) {
            $slug = 'plan-'.Str::lower(Str::random(6));
        }

        $plan = Plan::create([
            ...$data,
            'slug' => $slug,
        ]);

        if ($plan->is_popular) {
            Plan::query()->where('id', '!=', $plan->id)->update(['is_popular' => false]);
        }

        return back()->with('success', 'Plano criado.');
    }

    public function update(Request $request, Plan $plan): RedirectResponse
    {
        $data = $this->validatePlan($request, $plan->id);

        $plan->fill($data);
        $plan->save();

        if ($plan->is_popular) {
            Plan::query()->where('id', '!=', $plan->id)->update(['is_popular' => false]);
        }

        return back()->with('success', 'Plano atualizado.');
    }

    public function destroy(Plan $plan): RedirectResponse
    {
        $plan->delete();
        return back()->with('success', 'Plano excluído.');
    }

    private function validatePlan(Request $request, ?int $ignoreId = null): array
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:80'],
            'description' => ['nullable', 'string', 'max:200'],
            'price_cents' => ['required', 'integer', 'min:0', 'max:100000000'],
            'currency' => ['nullable', 'string', 'size:3'],
            'interval' => ['required', 'in:monthly,annual,lifetime'],

            'accounts_limit' => ['nullable', 'integer', 'min:1', 'max:1000'],
            'cards_limit' => ['nullable', 'integer', 'min:1', 'max:1000'],
            'projection_days' => ['required', 'integer', 'min:0', 'max:3650'],

            'backup_enabled' => ['boolean'],
            'recurring_enabled' => ['boolean'],
            'priority_support' => ['boolean'],

            'trial_days' => ['required', 'integer', 'min:0', 'max:365'],
            'requires_card' => ['boolean'],

            'is_popular' => ['boolean'],
            'is_active' => ['boolean'],
            'sort_order' => ['required', 'integer', 'min:0', 'max:1000'],
        ]);

        $data['currency'] = $data['currency'] ?? 'BRL';

        $data['accounts_limit'] = array_key_exists('accounts_limit', $data) && $data['accounts_limit'] ? (int) $data['accounts_limit'] : null;
        $data['cards_limit'] = array_key_exists('cards_limit', $data) && $data['cards_limit'] ? (int) $data['cards_limit'] : null;

        return $data;
    }
}

