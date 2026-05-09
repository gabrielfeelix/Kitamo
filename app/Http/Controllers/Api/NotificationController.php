<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\KitamoNotification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $notifications = KitamoNotification::query()
            ->where('user_id', $request->user()->id)
            ->where('expirada', false)
            ->orderByDesc('created_at')
            ->limit(60)
            ->get()
            ->map(fn (KitamoNotification $n) => $this->shape($n));

        return response()->json(['notifications' => $notifications]);
    }

    public function unreadCount(Request $request): JsonResponse
    {
        $count = KitamoNotification::query()
            ->where('user_id', $request->user()->id)
            ->where('lida', false)
            ->where('expirada', false)
            ->count();

        return response()->json(['count' => $count]);
    }

    public function markRead(Request $request, string $id): JsonResponse
    {
        $notification = KitamoNotification::query()
            ->where('user_id', $request->user()->id)
            ->where('id', $id)
            ->firstOrFail();

        $notification->lida = true;
        $notification->data_leitura = now();
        $notification->save();

        return response()->json(['ok' => true]);
    }

    public function markAllRead(Request $request): JsonResponse
    {
        KitamoNotification::query()
            ->where('user_id', $request->user()->id)
            ->where('lida', false)
            ->update(['lida' => true, 'data_leitura' => now()]);

        return response()->json(['ok' => true]);
    }

    private function shape(KitamoNotification $n): array
    {
        return [
            'id' => $n->id,
            'titulo' => $n->titulo,
            'mensagem' => $n->mensagem,
            'tipo' => $n->tipo,
            'prioridade' => $n->prioridade,
            'lida' => (bool) $n->lida,
            'created_at' => optional($n->created_at)->toIso8601String(),
            'acao_primaria_tipo' => $n->acao_primaria_tipo,
            'acao_primaria_url' => $n->acao_primaria_url,
        ];
    }
}
