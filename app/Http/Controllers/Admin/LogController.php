<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\ActionLog;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class LogController extends Controller
{
    public function index(Request $request): Response
    {
        $q = trim((string) $request->query('q', ''));

        $query = ActionLog::query()
            ->with(['actor:id,name,email'])
            ->orderByDesc('created_at');

        if ($q !== '') {
            $query->where(function ($sub) use ($q) {
                $sub->where('path', 'like', "%{$q}%")
                    ->orWhere('route_name', 'like', "%{$q}%")
                    ->orWhereHas('actor', fn ($u) => $u->where('email', 'like', "%{$q}%")->orWhere('name', 'like', "%{$q}%"));
            });
        }

        $logs = $query
            ->paginate(50)
            ->withQueryString()
            ->through(fn (ActionLog $log) => [
                'id' => (int) $log->id,
                'created_at' => $log->created_at?->toISOString(),
                'method' => $log->method,
                'route_name' => $log->route_name,
                'path' => $log->path,
                'status_code' => $log->status_code,
                'actor' => $log->actor ? [
                    'id' => (int) $log->actor->id,
                    'name' => (string) $log->actor->name,
                    'email' => (string) $log->actor->email,
                ] : null,
                'payload' => $log->payload,
            ]);

        return Inertia::render('Admin/Logs', [
            'q' => $q,
            'logs' => $logs,
        ]);
    }
}

