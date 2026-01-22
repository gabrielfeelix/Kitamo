<?php

namespace App\Http\Controllers;

use App\Http\Requests\ProfileUpdateRequest;
use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Redirect;
use Inertia\Inertia;
use Inertia\Response;

class ProfileController extends Controller
{
    private function isLocalWithoutDatabaseDriver(): bool
    {
        return app()->environment('local') && ! extension_loaded('pdo_mysql') && ! extension_loaded('pdo_sqlite');
    }

    /**
     * Display the user's profile form.
     */
    public function edit(Request $request): Response
    {
        return Inertia::render('Profile/Edit', [
            'mustVerifyEmail' => $request->user() instanceof MustVerifyEmail,
            'status' => session('status'),
        ]);
    }

    /**
     * Update the user's profile information.
     */
    public function update(ProfileUpdateRequest $request): RedirectResponse
    {
        if ($this->isLocalWithoutDatabaseDriver()) {
            return Redirect::back()->with('status', 'profile-updated');
        }

        $user = $request->user();

        // Se autenticado via Google, não permitir alterar nome ou avatar
        if ($user->auth_provider === 'google') {
            // Apenas permite atualizar telefone
            $validated = $request->validated();
            $user->phone = $validated['phone'] ?? $user->phone;
            $user->save();

            return Redirect::back()->with('status', 'profile-updated');
        }

        $user->fill($request->validated());

        if ($request->hasFile('avatar')) {
            $old = $user->avatar_path;

            $path = $request->file('avatar')->storePublicly('avatars', 'public');
            $user->avatar_path = $path;

            if ($old && !str_starts_with($old, 'http')) {
                Storage::disk('public')->delete($old);
            }
        }

        if ($request->user()->isDirty('email')) {
            $request->user()->email_verified_at = null;
        }

        $request->user()->save();

        return Redirect::back()->with('status', 'profile-updated');
    }

    /**
     * Delete the user's account.
     */
    public function destroy(Request $request): RedirectResponse
    {
        $request->validate([
            'password' => ['required', 'current_password'],
        ]);

        $user = $request->user();

        Auth::logout();

        $user->delete();

        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return Redirect::to('/');
    }
}
