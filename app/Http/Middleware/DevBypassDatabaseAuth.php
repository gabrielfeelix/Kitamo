<?php

namespace App\Http\Middleware;

use App\Models\User;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class DevBypassDatabaseAuth
{
    public function handle(Request $request, Closure $next)
    {
        if (! app()->environment('local')) {
            return $next($request);
        }

        if (extension_loaded('pdo_mysql') || extension_loaded('pdo_sqlite')) {
            return $next($request);
        }

        if (! Auth::check()) {
            $user = new User();
            $user->forceFill([
                'name' => 'Gabriel',
                'email' => 'dev@example.com',
            ]);
            $user->setAttribute('id', 1);
            $user->setAttribute('email_verified_at', now());

            Auth::setUser($user);
        }

        return $next($request);
    }
}

