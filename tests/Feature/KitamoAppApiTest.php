<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class KitamoAppApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_app_registration_creates_default_wallet_account(): void
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Teste App',
            'email' => 'app@example.com',
            'password' => 'senha123',
        ]);

        $response->assertCreated()
            ->assertJsonStructure(['token', 'user' => ['id', 'name', 'email']]);

        $this->assertDatabaseHas('accounts', [
            'name' => 'Carteira',
            'type' => 'checking',
            'initial_balance' => 0,
            'current_balance' => 0,
            'incluir_soma' => true,
            'is_primary' => true,
        ]);
    }

    public function test_import_commit_skips_duplicate_rows(): void
    {
        $register = $this->postJson('/api/v1/auth/register', [
            'name' => 'Teste Import',
            'email' => 'import@example.com',
            'password' => 'senha123',
        ])->assertCreated();

        $token = $register->json('token');
        $accountId = $this->withToken($token)
            ->getJson('/api/v1/accounts')
            ->assertOk()
            ->json('accounts.0.id');

        $payload = [
            'account_id' => $accountId,
            'rows' => [[
                'transaction_date' => '2026-05-02',
                'description' => 'Mercado',
                'amount' => 25.50,
                'kind' => 'expense',
                'suggested_category_id' => null,
            ]],
        ];

        $this->withToken($token)
            ->postJson('/api/v1/import/commit', $payload)
            ->assertOk()
            ->assertJson(['created' => 1, 'skipped' => 0]);

        $this->withToken($token)
            ->postJson('/api/v1/import/commit', $payload)
            ->assertOk()
            ->assertJson(['created' => 0, 'skipped' => 1]);

        $this->assertDatabaseCount('transactions', 1);
    }

    public function test_app_login_accepts_same_password_as_web_login(): void
    {
        User::factory()->create([
            'email' => 'web-user@example.com',
            'password' => Hash::make('senha123'),
            'auth_provider' => 'password',
        ]);

        $this->postJson('/api/v1/auth/login', [
            'email' => 'web-user@example.com',
            'password' => 'senha123',
        ])
            ->assertOk()
            ->assertJsonStructure(['token', 'user' => ['id', 'name', 'email']]);
    }

    public function test_app_login_tells_google_users_to_use_google_button(): void
    {
        User::factory()->create([
            'email' => 'google-user@example.com',
            'password' => Hash::make('random-password-not-known-by-user'),
            'auth_provider' => 'google',
        ]);

        $this->postJson('/api/v1/auth/login', [
            'email' => 'google-user@example.com',
            'password' => 'senha123',
        ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['email'])
            ->assertJsonPath('errors.email.0', 'Essa conta foi criada pelo Google. Entre com o botão "Entrar com Google".');
    }

    public function test_google_login_creates_user_default_wallet_and_token(): void
    {
        config()->set('services.google.web_client_id', 'google-web-client-id');

        Http::fake([
            'https://oauth2.googleapis.com/tokeninfo*' => Http::response([
                'aud' => 'google-web-client-id',
                'email' => 'google@example.com',
                'name' => 'Google User',
                'picture' => 'https://example.com/avatar.png',
            ]),
        ]);

        $response = $this->postJson('/api/v1/auth/google', [
            'id_token' => 'fake-google-id-token',
        ]);

        $response->assertOk()
            ->assertJsonStructure(['token', 'user' => ['id', 'name', 'email']]);

        $this->assertDatabaseHas('users', [
            'email' => 'google@example.com',
            'auth_provider' => 'google',
        ]);

        $this->assertDatabaseHas('accounts', [
            'name' => 'Carteira',
            'type' => 'checking',
            'current_balance' => 0,
        ]);
    }
}
