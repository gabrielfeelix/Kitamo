<?php

namespace App\Http\Middleware;

use App\Models\ActionLog;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class LogUserAction
{
    private function shouldLog(Request $request): bool
    {
        if (! $request->user()) return false;

        $method = strtoupper($request->getMethod());
        if (! in_array($method, ['POST', 'PUT', 'PATCH', 'DELETE'], true)) return false;

        $path = '/'.ltrim($request->path(), '/');
        if ($path === '/sanctum/csrf-cookie' || $path === '/csrf-cookie') return false;
        if ($path === '/login' || $path === '/logout') return false;

        return true;
    }

    private function scrubPayload(array $payload): array
    {
        $redactKeys = [
            'password',
            'password_confirmation',
            'current_password',
            'token',
            '_token',
            'csrf',
        ];

        $scrub = function ($value) use (&$scrub) {
            if (is_array($value)) {
                $out = [];
                foreach ($value as $k => $v) $out[$k] = $scrub($v);
                return $out;
            }
            if (is_string($value) && strlen($value) > 500) {
                return mb_substr($value, 0, 500).'…';
            }
            return $value;
        };

        $out = [];
        foreach ($payload as $key => $value) {
            $lower = mb_strtolower((string) $key);
            $isSensitive = false;
            foreach ($redactKeys as $needle) {
                if (str_contains($lower, $needle)) {
                    $isSensitive = true;
                    break;
                }
            }

            $out[$key] = $isSensitive ? '[REDACTED]' : $scrub($value);
        }

        return $out;
    }

    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);

        try {
            if ($this->shouldLog($request)) {
                ActionLog::create([
                    'actor_user_id' => $request->user()->id,
                    'method' => strtoupper($request->getMethod()),
                    'route_name' => $request->route()?->getName(),
                    'path' => '/'.ltrim($request->path(), '/'),
                    'status_code' => method_exists($response, 'getStatusCode') ? $response->getStatusCode() : null,
                    'ip' => $request->ip(),
                    'user_agent' => $request->userAgent(),
                    'payload' => $this->scrubPayload($request->except(['_method'])),
                ]);
            }
        } catch (\Throwable) {
            // never break requests due to logging
        }

        return $response;
    }
}

