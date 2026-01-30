<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Hash;
use Inertia\Inertia;
use Inertia\Response;

class UserController extends Controller
{
    public function index(Request $request): Response
    {
        $q = trim((string) $request->query('q', ''));
        $role = trim((string) $request->query('role', ''));
        $status = trim((string) $request->query('status', ''));
        $plan = trim((string) $request->query('plan', ''));

        $query = User::query()
            ->select('id', 'name', 'email', 'phone', 'avatar_path', 'is_admin', 'disabled_at', 'email_verified_at', 'created_at')
            ->orderByDesc('created_at');

        if ($q !== '') {
            $query->where(function ($sub) use ($q) {
                $sub->where('name', 'like', "%{$q}%")
                    ->orWhere('email', 'like', "%{$q}%");
            });
        }

        if (in_array($role, ['admin', 'user'], true)) {
            $query->where('is_admin', $role === 'admin');
        }

        if (in_array($status, ['active', 'inactive', 'pending'], true)) {
            if ($status === 'inactive') {
                $query->whereNotNull('disabled_at');
            } elseif ($status === 'pending') {
                $query->whereNull('disabled_at')->whereNull('email_verified_at');
            } else {
                $query->whereNull('disabled_at')->whereNotNull('email_verified_at');
            }
        }

        if ($plan !== '' && in_array($plan, ['Free', 'Pro', 'Premium', 'Família'], true) && $plan !== 'Free') {
            // Ainda não existe vínculo de plano no usuário. Enquanto isso, apenas "Free" tem usuários.
            $query->whereRaw('0 = 1');
        }

        $users = $query
            ->paginate(50)
            ->withQueryString()
            ->through(fn (User $user) => [
                'id' => (int) $user->id,
                'name' => (string) $user->name,
                'email' => (string) $user->email,
                'phone' => $user->phone,
                'avatar_url' => $user->avatar_url,
                'created_at' => $user->created_at?->toISOString(),
                'role' => $user->is_admin ? 'admin' : 'user',
                'is_disabled' => (bool) $user->disabled_at,
                'email_verified_at' => $user->email_verified_at?->toISOString(),
                'plan' => 'Free',
            ]);

        return Inertia::render('Admin/Users', [
            'q' => $q,
            'filters' => [
                'q' => $q,
                'plan' => $plan ?: null,
                'status' => $status ?: null,
                'role' => $role ?: null,
            ],
            'users' => $users,
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8'],
            'phone' => ['nullable', 'string', 'max:30'],
            'role' => ['nullable', 'in:admin,user'],
            'status' => ['nullable', 'in:active,disabled'],
        ]);

        $user = new User();
        $user->name = $data['name'];
        $user->email = $data['email'];
        $user->phone = $data['phone'] ?? null;
        $user->password = $data['password'];
        $user->is_admin = ($data['role'] ?? 'user') === 'admin';
        $user->disabled_at = ($data['status'] ?? 'active') === 'disabled' ? Carbon::now() : null;
        $user->save();

        return back()->with('success', 'Usuário criado.');
    }

    public function update(Request $request, User $user): RedirectResponse
    {
        $data = $request->validate([
            'name' => ['sometimes', 'required', 'string', 'max:255'],
            'phone' => ['nullable', 'string', 'max:30'],
            'role' => ['sometimes', 'required', 'in:admin,user'],
            'status' => ['sometimes', 'required', 'in:active,disabled'],
        ]);

        if (mb_strtolower((string) $user->email) === 'contato@kitamo.com.br' && array_key_exists('status', $data) && $data['status'] === 'disabled') {
            return back()->withErrors(['default' => 'Não é possível desativar o usuário administrador principal.']);
        }

        if (array_key_exists('name', $data)) {
            $user->name = $data['name'];
        }
        if (array_key_exists('phone', $data)) {
            $user->phone = $data['phone'] ?: null;
        }
        if (array_key_exists('role', $data)) {
            $user->is_admin = $data['role'] === 'admin';
        }
        if (array_key_exists('status', $data)) {
            $user->disabled_at = $data['status'] === 'disabled' ? Carbon::now() : null;
        }

        $user->save();

        return back()->with('success', 'Usuário atualizado.');
    }

    public function destroy(User $user): RedirectResponse
    {
        if (mb_strtolower((string) $user->email) === 'contato@kitamo.com.br') {
            return back()->withErrors(['default' => 'Não é possível excluir o usuário administrador principal.']);
        }
        $user->delete();
        return back()->with('success', 'Usuário excluído.');
    }

    public function updatePassword(Request $request, User $user): RedirectResponse
    {
        $data = $request->validate([
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);

        $user->forceFill([
            'password' => Hash::make($data['password']),
        ])->save();

        return back()->with('success', 'Senha atualizada.');
    }
}
