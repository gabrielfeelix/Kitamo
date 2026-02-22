<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

/*
|--------------------------------------------------------------------------
| Polyfill: mb_split (mbstring regex)
|--------------------------------------------------------------------------
|
| Hostinger's CloudLinux/LiteSpeed server does not load mbstring.so
| despite it appearing enabled in hPanel. The symfony/polyfill-mbstring
| package covers most mb_* functions but NOT mb_split (regex-based).
| Laravel's Illuminate\Support\Str uses mb_split() in studly(), title(),
| etc. This polyfill uses preg_split with the /u flag as a fallback.
|
| TODO: Remove this polyfill once Hostinger fixes the extension loading
|       (tracked: mbstring.ini missing from /opt/alt/php83/link/conf/).
|
*/
if (!function_exists('mb_split')) {
    function mb_split(string $pattern, string $string, int $limit = -1): array|false
    {
        $result = preg_split('/' . $pattern . '/u', $string, $limit);
        return $result === false ? false : $result;
    }
}

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->alias([
            'admin' => \App\Http\Middleware\EnsureAdmin::class,
        ]);

        $middleware->web(prepend: [
            \App\Http\Middleware\DevBypassDatabaseAuth::class,
        ]);

        $middleware->web(append: [
            \App\Http\Middleware\EnsureUserNotDisabled::class,
            \App\Http\Middleware\LogUserAction::class,
            \App\Http\Middleware\HandleInertiaRequests::class,
            \Illuminate\Http\Middleware\AddLinkHeadersForPreloadedAssets::class,
        ]);

        //
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        //
    })->create();
