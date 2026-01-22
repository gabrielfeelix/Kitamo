<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;
use Laravel\Socialite\Facades\Socialite;

class GoogleController extends Controller
{
    public function redirect(): RedirectResponse
    {
        return Socialite::driver('google')->redirect();
    }

    public function callback(): RedirectResponse
    {
        $googleUser = Socialite::driver('google')->stateless()->user();
        $email = $googleUser->getEmail();

        $user = User::where('email', $email)->first();
        if (!$user) {
            $user = User::create([
                'name' => $googleUser->getName() ?: ($googleUser->getNickname() ?: 'Kitamo'),
                'email' => $email,
                'email_verified_at' => now(),
                'password' => bcrypt(Str::random(32)),
                'avatar_path' => $googleUser->getAvatar(),
                'auth_provider' => 'google',
            ]);
        } else {
            // Atualizar foto e provider se for login via Google
            $user->update([
                'avatar_path' => $googleUser->getAvatar(),
                'auth_provider' => 'google',
            ]);
        }

        Auth::login($user, true);

        return redirect()->intended(route('dashboard'));
    }
}
