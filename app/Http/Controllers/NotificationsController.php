<?php

namespace App\Http\Controllers;

use App\Models\KitamoNotification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationsController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $data = $request->validate([
            'lida' => ['nullable'],
            'limit' => ['nullable', 'integer', 'min:1', 'max:100'],
        ]);

        $query = KitamoNotification::query()
            ->where('user_id', $user->id)
            ->where('expirada', false);

        if ($request->has('lida')) {
            $query->where('lida', $request->boolean('lida'));
        }

        $query->orderByRaw("
            CASE prioridade
                WHEN 'urgente' THEN 1
                WHEN 'alta' THEN 2
                WHEN 'media' THEN 3
                WHEN 'baixa' THEN 4
                ELSE 5
            END
        ");
        $query->orderBy('created_at', 'desc');
        $query->orderBy('lida', 'asc');

        $limit = (int) ($data['limit'] ?? 20);

        $items = $query->limit($limit)->get()->map(function (KitamoNotification $notification) {
            return [
                'id' => (string) $notification->id,
                'title' => $notification->titulo,
                'body' => $notification->mensagem,
                'type' => $notification->tipo,
                'priority' => $notification->prioridade,
                'read_at' => $notification->data_leitura?->toISOString(),
                'created_at' => $notification->created_at?->toISOString(),
                'action' => [
                    'type' => $notification->acao_primaria_tipo,
                    'url' => $notification->acao_primaria_url,
                ],
                'metadata' => $notification->metadata,
            ];
        });

        return response()->json([
            'notifications' => $items->values(),
        ]);
    }

    public function marcarLida(Request $request, KitamoNotification $notification): JsonResponse
    {
        $user = $request->user();
        if ($notification->user_id !== $user->id) {
            return response()->json(['error' => 'Não autorizado'], 403);
        }

        $notification->lida = true;
        $notification->data_leitura = now();
        $notification->save();

        return response()->json(['message' => 'Notificação marcada como lida']);
    }

    public function marcarTodasLidas(Request $request): JsonResponse
    {
        $user = $request->user();

        KitamoNotification::query()
            ->where('user_id', $user->id)
            ->where('lida', false)
            ->update([
                'lida' => true,
                'data_leitura' => now(),
            ]);

        return response()->json(['message' => 'Todas notificações marcadas como lidas']);
    }

    public function destroy(Request $request, KitamoNotification $notification): JsonResponse
    {
        $user = $request->user();
        if ($notification->user_id !== $user->id) {
            return response()->json(['error' => 'Não autorizado'], 403);
        }

        $notification->delete();

        return response()->json(['ok' => true]);
    }

    public function limparLidas(Request $request): JsonResponse
    {
        $user = $request->user();
        $count = KitamoNotification::query()
            ->where('user_id', $user->id)
            ->where('lida', true)
            ->delete();

        return response()->json(['deleted' => $count]);
    }

    public function countUnread(Request $request): JsonResponse
    {
        $user = $request->user();

        $base = KitamoNotification::query()
            ->where('user_id', $user->id)
            ->where('expirada', false)
            ->where('lida', false);

        $count = (clone $base)->count();

        $urgentes = (clone $base)->where('prioridade', 'urgente')->count();
        $altas = (clone $base)->where('prioridade', 'alta')->count();
        $medias = (clone $base)->where('prioridade', 'media')->count();
        $baixas = (clone $base)->where('prioridade', 'baixa')->count();

        return response()->json([
            'count' => $count,
            'urgentes' => $urgentes,
            'altas' => $altas,
            'medias' => $medias,
            'baixas' => $baixas,
        ]);
    }
}
