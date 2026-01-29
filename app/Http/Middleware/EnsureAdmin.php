<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureAdmin
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        // Painel admin: acesso exclusivo para este e-mail.
        if (! $user || mb_strtolower((string) $user->email) !== 'contato@kitamo.com.br') {
            abort(403);
        }

        return $next($request);
    }
}
