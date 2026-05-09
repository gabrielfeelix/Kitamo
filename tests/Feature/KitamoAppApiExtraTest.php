<?php

namespace Tests\Feature;

use App\Models\Account;
use App\Models\Category;
use App\Models\Goal;
use App\Models\KitamoNotification;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Tests\TestCase;

class KitamoAppApiExtraTest extends TestCase
{
    use RefreshDatabase;

    private function authedUser(): array
    {
        $user = User::factory()->create([
            'email' => 'extra@example.com',
            'password' => Hash::make('senha123'),
            'auth_provider' => 'email',
        ]);
        $token = $user->createToken('test')->plainTextToken;
        return [$user, $token];
    }

    public function test_onboarding_marks_user_as_completed_with_entry_mode(): void
    {
        [$user, $token] = $this->authedUser();
        $this->assertNull($user->onboarding_completed_at);

        $this->withToken($token)
            ->postJson('/api/v1/auth/onboarding', ['entry_mode' => 'manual'])
            ->assertOk()
            ->assertJsonPath('user.email', 'extra@example.com');

        $this->assertNotNull($user->fresh()->onboarding_completed_at);
        $this->assertSame('manual', $user->fresh()->entry_mode);
    }

    public function test_transfer_moves_money_between_accounts_and_creates_two_transactions(): void
    {
        [$user, $token] = $this->authedUser();

        $from = Account::create([
            'user_id' => $user->id, 'name' => 'A', 'type' => 'checking',
            'initial_balance' => 1000, 'current_balance' => 1000, 'incluir_soma' => true, 'is_primary' => true,
        ]);
        $to = Account::create([
            'user_id' => $user->id, 'name' => 'B', 'type' => 'savings',
            'initial_balance' => 0, 'current_balance' => 0, 'incluir_soma' => true,
        ]);

        $this->withToken($token)
            ->postJson('/api/v1/transfers', [
                'from_account_id' => $from->id,
                'to_account_id' => $to->id,
                'amount' => 200,
                'transaction_date' => '2026-05-09',
            ])
            ->assertCreated()
            ->assertJson(['ok' => true]);

        $this->assertEquals(800.0, (float) $from->fresh()->current_balance);
        $this->assertEquals(200.0, (float) $to->fresh()->current_balance);
        $this->assertDatabaseCount('transactions', 2);
    }

    public function test_goal_create_and_deposit_updates_progress(): void
    {
        [$user, $token] = $this->authedUser();

        $goalId = $this->withToken($token)
            ->postJson('/api/v1/goals', [
                'title' => 'Viagem',
                'target_amount' => 1000,
            ])
            ->assertCreated()
            ->json('goal.id');

        $this->withToken($token)
            ->postJson("/api/v1/goals/{$goalId}/deposits", ['amount' => 250])
            ->assertCreated();

        $goal = Goal::find($goalId);
        $this->assertEquals(250.0, (float) $goal->current_amount);
    }

    public function test_categories_crud_and_budget_limit(): void
    {
        [$user, $token] = $this->authedUser();

        $catId = $this->withToken($token)
            ->postJson('/api/v1/categories', [
                'name' => 'iFood',
                'type' => 'expense',
                'color' => '#F59E0B',
                'icon' => 'food',
                'budget_limit' => 250,
            ])
            ->assertCreated()
            ->json('category.id');

        $this->withToken($token)
            ->putJson("/api/v1/categories/{$catId}", ['budget_limit' => 300])
            ->assertOk()
            ->assertJsonPath('category.budget_limit', 300);

        $this->withToken($token)
            ->deleteJson("/api/v1/categories/{$catId}")
            ->assertOk();

        $this->assertDatabaseMissing('categories', ['id' => $catId]);
    }

    public function test_notifications_list_and_mark_read(): void
    {
        [$user, $token] = $this->authedUser();

        $n = KitamoNotification::create([
            'id' => (string) Str::uuid(),
            'user_id' => $user->id,
            'tipo' => 'aviso',
            'prioridade' => 'media',
            'titulo' => 'Conta de luz',
            'mensagem' => 'Vence amanhã',
            'lida' => false,
        ]);

        $this->withToken($token)
            ->getJson('/api/v1/notifications')
            ->assertOk()
            ->assertJsonCount(1, 'notifications');

        $this->withToken($token)
            ->getJson('/api/v1/notifications/unread-count')
            ->assertOk()
            ->assertJson(['count' => 1]);

        $this->withToken($token)
            ->patchJson("/api/v1/notifications/{$n->id}/read")
            ->assertOk();

        $this->assertTrue((bool) $n->fresh()->lida);
    }

    public function test_password_change_validates_current_and_updates(): void
    {
        [$user, $token] = $this->authedUser();

        $this->withToken($token)
            ->putJson('/api/v1/auth/password', [
                'current_password' => 'wrong',
                'new_password' => 'nova-senha',
                'new_password_confirmation' => 'nova-senha',
            ])
            ->assertUnprocessable();

        $this->withToken($token)
            ->putJson('/api/v1/auth/password', [
                'current_password' => 'senha123',
                'new_password' => 'nova-senha',
                'new_password_confirmation' => 'nova-senha',
            ])
            ->assertOk();

        $this->assertTrue(Hash::check('nova-senha', $user->fresh()->password));
    }
}
