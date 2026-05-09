<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Account;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Validation\Rules\Password as PasswordRule;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'email' => ['required', 'email', 'unique:users,email'],
            'password' => ['required', 'string', 'min:6'],
        ]);

        $user = User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
            'auth_provider' => 'email',
        ]);

        Account::create($this->defaultAccountPayload($user->id));

        $token = $user->createToken('kitamo-app')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => $this->shapeUser($user),
        ], 201);
    }

    public function google(Request $request): JsonResponse
    {
        $data = $request->validate([
            'id_token' => ['required', 'string'],
        ]);

        $tokenInfo = Http::timeout(15)->get('https://oauth2.googleapis.com/tokeninfo', [
            'id_token' => $data['id_token'],
        ]);

        if (! $tokenInfo->successful()) {
            throw ValidationException::withMessages([
                'google' => ['Não foi possível validar sua conta Google.'],
            ]);
        }

        $payload = $tokenInfo->json();
        $email = $payload['email'] ?? null;
        $audience = $payload['aud'] ?? null;

        if (! is_string($email) || ! filter_var($email, FILTER_VALIDATE_EMAIL)) {
            throw ValidationException::withMessages([
                'google' => ['Conta Google sem email válido.'],
            ]);
        }

        $allowedAudiences = array_filter([
            config('services.google.client_id'),
            config('services.google.web_client_id'),
            config('services.google.ios_client_id'),
            config('services.google.android_client_id'),
        ]);

        if ($allowedAudiences && ! in_array($audience, $allowedAudiences, true)) {
            throw ValidationException::withMessages([
                'google' => ['Login Google não pertence a este aplicativo.'],
            ]);
        }

        $user = User::where('email', $email)->first();
        if (! $user) {
            $user = User::create([
                'name' => $payload['name'] ?? 'Kitamo',
                'email' => $email,
                'email_verified_at' => now(),
                'password' => Hash::make(Str::random(32)),
                'avatar_path' => $payload['picture'] ?? null,
                'auth_provider' => 'google',
            ]);

            Account::create($this->defaultAccountPayload($user->id));
        } else {
            $user->update([
                'avatar_path' => $payload['picture'] ?? $user->avatar_path,
                'auth_provider' => 'google',
            ]);
        }

        $token = $user->createToken('kitamo-app')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => $this->shapeUser($user),
        ]);
    }

    private function defaultAccountPayload(int $userId): array
    {
        return [
            'user_id' => $userId,
            'name' => 'Carteira',
            'type' => 'checking',
            'initial_balance' => 0,
            'current_balance' => 0,
            'incluir_soma' => true,
            'is_primary' => true,
            'icon' => 'wallet',
            'color' => '#33D6C5',
        ];
    }

    public function login(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        $credentials = [
            'email' => $data['email'],
            'password' => $data['password'],
        ];

        if (! Auth::validate($credentials)) {
            $user = User::where('email', $data['email'])->first();

            if ($user?->is_google_auth) {
                throw ValidationException::withMessages([
                    'email' => ['Essa conta foi criada pelo Google. Entre com o botão "Entrar com Google".'],
                ]);
            }

            throw ValidationException::withMessages([
                'email' => [trans('auth.failed')],
            ]);
        }

        $user = User::where('email', $data['email'])->firstOrFail();

        $token = $user->createToken('kitamo-app')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => $this->shapeUser($user),
        ]);
    }

    public function me(Request $request): JsonResponse
    {
        return response()->json([
            'user' => $this->shapeUser($request->user()),
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['ok' => true]);
    }

    public function onboarding(Request $request): JsonResponse
    {
        $data = $request->validate([
            'entry_mode' => ['required', 'in:manual,connect,skip'],
        ]);

        $user = $request->user();
        $user->entry_mode = $data['entry_mode'];
        if ($user->onboarding_completed_at === null) {
            $user->onboarding_completed_at = now();
        }
        $user->save();

        return response()->json(['user' => $this->shapeUser($user->fresh())]);
    }

    public function changePassword(Request $request): JsonResponse
    {
        $data = $request->validate([
            'current_password' => ['required', 'string'],
            'new_password' => ['required', 'confirmed', PasswordRule::min(6)],
        ]);

        $user = $request->user();

        if (! Hash::check($data['current_password'], $user->password)) {
            throw ValidationException::withMessages([
                'current_password' => ['A senha atual está incorreta.'],
            ]);
        }

        $user->password = Hash::make($data['new_password']);
        $user->save();

        return response()->json(['ok' => true]);
    }

    public function sessions(Request $request): JsonResponse
    {
        $currentId = $request->user()->currentAccessToken()->id ?? null;

        $tokens = DB::table('personal_access_tokens')
            ->where('tokenable_type', User::class)
            ->where('tokenable_id', $request->user()->id)
            ->orderByDesc('last_used_at')
            ->get()
            ->map(fn ($t) => [
                'id' => (int) $t->id,
                'name' => $t->name,
                'last_used_at' => $t->last_used_at,
                'is_current' => (int) $t->id === (int) $currentId,
            ]);

        return response()->json(['sessions' => $tokens]);
    }

    public function revokeAllSessions(Request $request): JsonResponse
    {
        $currentId = $request->user()->currentAccessToken()->id ?? null;

        DB::table('personal_access_tokens')
            ->where('tokenable_type', User::class)
            ->where('tokenable_id', $request->user()->id)
            ->when($currentId, fn ($q) => $q->where('id', '!=', $currentId))
            ->delete();

        return response()->json(['ok' => true]);
    }

    private function shapeUser(User $user): array
    {
        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'avatar_path' => $user->avatar_url,
            'plan' => $user->plan_slug ?? 'free',
            'onboarding_completed_at' => optional($user->onboarding_completed_at)->toIso8601String(),
            'has_2fa' => (bool) ($user->twofa_enabled ?? false),
            'auth_provider' => $user->auth_provider,
        ];
    }
}
