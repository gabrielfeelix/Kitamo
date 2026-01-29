<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class UserApiController extends Controller
{
    public function profile(Request $request): JsonResponse
    {
        $user = $request->user();

        return response()->json([
            'id' => (string) $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'theme' => $user->theme ?? 'light',
            'created_at' => $user->created_at?->toISOString(),
        ]);
    }

    public function markOnboardingDone(Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user->onboarding_completed_at) {
            $user->onboarding_completed_at = Carbon::now();
            $user->save();
        }

        return response()->json([
            'ok' => true,
            'onboarding_completed_at' => $user->onboarding_completed_at?->toISOString(),
        ]);
    }

    public function updateTheme(Request $request): JsonResponse
    {
        $data = $request->validate([
            'theme' => ['required', 'in:light,dark'],
        ]);

        $user = $request->user();
        $user->theme = $data['theme'];
        $user->save();

        return response()->json([
            'message' => 'Tema atualizado',
            'theme' => $user->theme,
        ]);
    }
}
