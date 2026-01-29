<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\KitamoNotification;
use App\Models\SystemNotificationRule;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Inertia\Inertia;
use Inertia\Response;

class NotificationRuleController extends Controller
{
    public function index(): Response
    {
        $rules = SystemNotificationRule::query()
            ->orderBy('scope')
            ->orderByDesc('enabled')
            ->orderBy('title')
            ->get()
            ->map(fn (SystemNotificationRule $r) => [
                'id' => (int) $r->id,
                'scope' => (string) $r->scope,
                'title' => (string) $r->title,
                'description' => $r->description,
                'icon' => $r->icon,
                'enabled' => (bool) $r->enabled,
                'trigger_key' => (string) $r->trigger_key,
                'trigger_config' => $r->trigger_config ?? [],
                'channels' => $r->channels ?? [],
                'message_title' => (string) ($r->message_title ?? ''),
                'message_body' => (string) ($r->message_body ?? ''),
            ]);

        return Inertia::render('Admin/Notifications', [
            'rules' => $rules,
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $data = $this->validateRule($request);
        SystemNotificationRule::create($data);
        return back()->with('success', 'Notificação criada.');
    }

    public function update(Request $request, SystemNotificationRule $rule): RedirectResponse
    {
        $data = $this->validateRule($request);
        $rule->fill($data)->save();
        return back()->with('success', 'Notificação atualizada.');
    }

    public function destroy(SystemNotificationRule $rule): RedirectResponse
    {
        $rule->delete();
        return back()->with('success', 'Notificação excluída.');
    }

    public function test(Request $request, SystemNotificationRule $rule): RedirectResponse
    {
        $user = $request->user();

        $id = (string) Str::uuid();
        KitamoNotification::create([
            'id' => $id,
            'user_id' => $user->id,
            'tipo' => 'admin_test',
            'prioridade' => 'media',
            'titulo' => $rule->message_title ?: $rule->title,
            'mensagem' => $rule->message_body ?: ($rule->description ?? ''),
            'lida' => false,
            'data_leitura' => null,
            'expirada' => false,
            'data_expiracao' => null,
            'acao_primaria_tipo' => null,
            'acao_primaria_url' => null,
            'metadata' => [
                'rule_id' => (int) $rule->id,
                'scope' => (string) $rule->scope,
            ],
        ]);

        return back()->with('success', 'Notificação de teste enviada (in-app).');
    }

    private function validateRule(Request $request): array
    {
        $data = $request->validate([
            'scope' => ['required', 'in:user,admin'],
            'title' => ['required', 'string', 'max:120'],
            'description' => ['nullable', 'string', 'max:255'],
            'icon' => ['nullable', 'string', 'max:16'],
            'enabled' => ['boolean'],
            'trigger_key' => ['required', 'string', 'max:64'],
            'trigger_config' => ['nullable', 'array'],
            'channels' => ['nullable', 'array'],
            'message_title' => ['required', 'string', 'max:140'],
            'message_body' => ['nullable', 'string', 'max:5000'],
        ]);

        return [
            ...$data,
            'trigger_config' => $data['trigger_config'] ?? [],
            'channels' => $data['channels'] ?? [],
        ];
    }
}

