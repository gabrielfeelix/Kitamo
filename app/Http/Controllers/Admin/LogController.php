<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\ActionLog;
use App\Models\User;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Inertia\Inertia;
use Inertia\Response;
use Symfony\Component\HttpFoundation\StreamedResponse;

class LogController extends Controller
{
    public function index(Request $request): Response
    {
        $q = trim((string) $request->query('q', ''));
        $actorId = $request->query('actor_id');
        $method = strtoupper(trim((string) $request->query('method', '')));
        $datePreset = trim((string) $request->query('date', 'today'));
        $start = trim((string) $request->query('start', ''));
        $end = trim((string) $request->query('end', ''));

        $query = $this->baseFilteredQuery(
            q: $q,
            actorId: $actorId,
            method: $method,
            datePreset: $datePreset,
            start: $start,
            end: $end,
        );

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
            'filters' => [
                'q' => $q,
                'actor_id' => $actorId ? (int) $actorId : null,
                'method' => $method ?: null,
                'date' => $datePreset ?: 'today',
                'start' => $start ?: null,
                'end' => $end ?: null,
            ],
            'actors' => User::query()
                ->select('id', 'name', 'email')
                ->orderBy('name')
                ->get()
                ->map(fn (User $u) => ['id' => (int) $u->id, 'name' => (string) $u->name, 'email' => (string) $u->email]),
            'logs' => $logs,
        ]);
    }

    public function export(Request $request): StreamedResponse
    {
        $q = trim((string) $request->query('q', ''));
        $actorId = $request->query('actor_id');
        $method = strtoupper(trim((string) $request->query('method', '')));
        $datePreset = trim((string) $request->query('date', 'today'));
        $start = trim((string) $request->query('start', ''));
        $end = trim((string) $request->query('end', ''));

        $query = $this->baseFilteredQuery(
            q: $q,
            actorId: $actorId,
            method: $method,
            datePreset: $datePreset,
            start: $start,
            end: $end,
        );

        $today = Carbon::now()->format('Y-m-d');
        $filename = "logs_kitamo_{$today}.csv";

        return response()->streamDownload(function () use ($query) {
            $out = fopen('php://output', 'w');
            if (! $out) return;

            fputcsv($out, ['Data/Hora', 'Método', 'Endpoint', 'Usuário', 'Status', 'Payload']);

            $query
                ->reorder()
                ->orderBy('id')
                ->chunkById(500, function ($rows) use ($out) {
                    foreach ($rows as $log) {
                        $userLabel = $log->actor ? ($log->actor->name.' <'.$log->actor->email.'>') : '';
                        $payload = $log->payload ? json_encode($log->payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES) : '';
                        fputcsv($out, [
                            optional($log->created_at)->toDateTimeString(),
                            (string) $log->method,
                            (string) $log->path,
                            (string) $userLabel,
                            $log->status_code,
                            $payload,
                        ]);
                    }
                });

            fclose($out);
        }, $filename, [
            'Content-Type' => 'text/csv; charset=UTF-8',
        ]);
    }

    private function baseFilteredQuery(
        string $q,
        mixed $actorId,
        string $method,
        string $datePreset,
        string $start,
        string $end,
    ): Builder {
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

        if ($actorId !== null && $actorId !== '' && is_numeric($actorId)) {
            $query->where('actor_user_id', (int) $actorId);
        }

        if ($method !== '' && in_array($method, ['GET', 'POST', 'DELETE', 'PATCH', 'PUT', 'PATCH_PUT'], true)) {
            if ($method === 'PATCH_PUT') {
                $query->whereIn('method', ['PATCH', 'PUT']);
            } else {
                $query->where('method', $method);
            }
        }

        $applyRange = function (?Carbon $from, ?Carbon $to) use ($query) {
            if ($from) $query->where('created_at', '>=', $from);
            if ($to) $query->where('created_at', '<=', $to);
        };

        $preset = $datePreset ?: 'today';
        if ($preset === 'yesterday') {
            $from = Carbon::yesterday()->startOfDay();
            $to = Carbon::yesterday()->endOfDay();
            $applyRange($from, $to);
        } elseif ($preset === '7d') {
            $applyRange(Carbon::now()->subDays(7)->startOfDay(), Carbon::now()->endOfDay());
        } elseif ($preset === '30d') {
            $applyRange(Carbon::now()->subDays(30)->startOfDay(), Carbon::now()->endOfDay());
        } elseif ($preset === 'custom') {
            $from = $start ? Carbon::parse($start)->startOfDay() : null;
            $to = $end ? Carbon::parse($end)->endOfDay() : null;
            $applyRange($from, $to);
        } else {
            $from = Carbon::today()->startOfDay();
            $to = Carbon::today()->endOfDay();
            $applyRange($from, $to);
        }

        return $query;
    }
}
