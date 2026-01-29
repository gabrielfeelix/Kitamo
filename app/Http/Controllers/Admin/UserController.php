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
    public function index(): Response
    {
        $users = User::query()
            ->select('id', 'name', 'email', 'phone', 'avatar_path', 'is_admin', 'disabled_at', 'created_at')
            ->orderByDesc('created_at')
            ->get()
            ->map(fn (User $user) => [
                'id' => (int) $user->id,
                'name' => (string) $user->name,
                'email' => (string) $user->email,
                'phone' => $user->phone,
                'avatar_url' => $user->avatar_url,
                'created_at' => $user->created_at?->toISOString(),
                'role' => $user->is_admin ? 'admin' : 'user',
                'status' => $user->disabled_at ? 'disabled' : 'active',
                'plan' => 'Free',
            ]);

        return Inertia::render('Admin/Users', [
            'users' => $users,
        ]);
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
