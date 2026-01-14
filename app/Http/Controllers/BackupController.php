<?php

namespace App\Http\Controllers;

use App\Models\Backup;
use App\Services\BackupService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class BackupController extends Controller
{
    public function create(Request $request, BackupService $backupService): JsonResponse
    {
        $user = $request->user();
        $backup = $backupService->criarBackup($user->id);

        return response()->json([
            'message' => 'Backup criado com sucesso',
            'backup' => $backup,
        ]);
    }

    public function download(Request $request, string $filename)
    {
        $user = $request->user();
        $safe = basename($filename);
        $path = "backups/{$user->id}/{$safe}";

        if (!Storage::exists($path)) {
            return response()->json(['error' => 'Backup não encontrado'], 404);
        }

        return Storage::download($path, $safe);
    }

    public function list(Request $request): JsonResponse
    {
        $user = $request->user();

        $backups = Backup::query()
            ->where('user_id', $user->id)
            ->orderByDesc('created_at')
            ->get(['id', 'filename', 'size_bytes', 'created_at']);

        return response()->json($backups);
    }

    public function restore(Request $request, BackupService $backupService): JsonResponse
    {
        $user = $request->user();

        $data = $request->validate([
            'filename' => ['required', 'string', 'max:255'],
        ]);

        $safe = basename($data['filename']);
        $path = "backups/{$user->id}/{$safe}";

        if (!Storage::exists($path)) {
            return response()->json(['error' => 'Backup não encontrado'], 404);
        }

        $backupService->restaurarBackup($user->id, $path);

        return response()->json(['message' => 'Backup restaurado com sucesso']);
    }

    public function status(Request $request): JsonResponse
    {
        $user = $request->user();

        return response()->json([
            'ultimo_backup' => $user->last_backup_at?->toISOString(),
            'sincronizado' => $user->last_backup_at !== null,
        ]);
    }
}

