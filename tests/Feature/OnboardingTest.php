<?php

namespace Tests\Feature;

use App\Models\Divida;
use App\Models\PerfilFinanceiro;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * Item 3: onboarding. Spec §3.3.
 *
 * A regra que estes testes guardam: pular não pode travar nem inventar. O
 * spec exige default explícito para cada resposta pulada — quem pula tudo
 * chega ao fim com um número incompleto, não com erro.
 */
class OnboardingTest extends TestCase
{
    use RefreshDatabase;

    public function test_exige_login(): void
    {
        $this->get('/onboarding')->assertRedirect('/login');
        $this->post('/onboarding', [])->assertRedirect('/login');
    }

    public function test_abre_a_tela(): void
    {
        $this->actingAs(User::factory()->create())
            ->get('/onboarding')
            ->assertOk();
    }

    public function test_salva_as_respostas_e_a_divida(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)->post('/onboarding', [
            'renda_mensal' => 3650,
            'dia_renda' => 5,
            'gasto_diario_estimado' => 40,
            'contas_fixas_estimadas' => 914,
            'dividas' => [[
                'nome' => 'Nubank',
                'valor_parcela' => 1534.06,
                'dia_vencimento' => 4,
                'parcelas_restantes' => 4,
            ]],
        ])->assertRedirect(route('inicio'));

        $perfil = PerfilFinanceiro::where('user_id', $user->id)->firstOrFail();
        $this->assertSame('3650.00', $perfil->renda_mensal);
        $this->assertSame(5, $perfil->dia_renda);
        $this->assertSame(PerfilFinanceiro::ORIGEM_FEELING, $perfil->origem);

        $divida = Divida::where('user_id', $user->id)->firstOrFail();
        $this->assertSame('Nubank', $divida->nome);
        $this->assertSame(4, $divida->parcelas_restantes);
        // parcelas_total espelha o restante: no onboarding a pessoa informa
        // o que falta, não o histórico.
        $this->assertSame(4, $divida->parcelas_total);
    }

    public function test_pular_tudo_cria_perfil_vazio_sem_quebrar(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)->post('/onboarding', [])
            ->assertRedirect(route('inicio'));

        $perfil = PerfilFinanceiro::where('user_id', $user->id)->firstOrFail();
        $this->assertNull($perfil->renda_mensal);
        $this->assertNull($perfil->dia_renda);
        $this->assertSame(0, Divida::where('user_id', $user->id)->count());
    }

    public function test_divida_sem_dia_de_vencimento_usa_o_dia_1(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)->post('/onboarding', [
            'dividas' => [['nome' => 'Crediário']],
        ])->assertRedirect();

        $divida = Divida::where('user_id', $user->id)->firstOrFail();
        $this->assertSame(1, $divida->dia_vencimento);
        $this->assertSame('0.00', $divida->valor_parcela);
        $this->assertSame(0, $divida->parcelas_restantes);
    }

    public function test_responder_de_novo_atualiza_em_vez_de_duplicar(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)->post('/onboarding', ['renda_mensal' => 3000]);
        $this->actingAs($user)->post('/onboarding', ['renda_mensal' => 4000]);

        $this->assertSame(1, PerfilFinanceiro::where('user_id', $user->id)->count());
        $this->assertSame(
            '4000.00',
            PerfilFinanceiro::where('user_id', $user->id)->first()->renda_mensal
        );
    }

    public function test_recusa_dado_invalido(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->post('/onboarding', ['dia_renda' => 45])
            ->assertSessionHasErrors('dia_renda');

        $this->actingAs($user)
            ->post('/onboarding', ['renda_mensal' => -100])
            ->assertSessionHasErrors('renda_mensal');

        $this->actingAs($user)
            ->post('/onboarding', ['dividas' => [['saldo_atual' => 10]]])
            ->assertSessionHasErrors('dividas.0.nome');
    }

    public function test_inicio_manda_para_o_onboarding_quem_nao_respondeu(): void
    {
        $this->actingAs(User::factory()->create())
            ->get('/inicio')
            ->assertRedirect(route('onboarding'));
    }

    public function test_inicio_abre_depois_do_onboarding(): void
    {
        $user = User::factory()->create();
        PerfilFinanceiro::factory()->for($user)->create();

        $this->actingAs($user)->get('/inicio')->assertOk();
    }

    public function test_nao_mexe_no_perfil_de_outro_usuario(): void
    {
        $outro = User::factory()->create();
        PerfilFinanceiro::factory()->for($outro)->create(['renda_mensal' => 9999]);

        $user = User::factory()->create();
        $this->actingAs($user)->post('/onboarding', ['renda_mensal' => 1000]);

        $this->assertSame(
            '9999.00',
            PerfilFinanceiro::where('user_id', $outro->id)->first()->renda_mensal
        );
    }
}
