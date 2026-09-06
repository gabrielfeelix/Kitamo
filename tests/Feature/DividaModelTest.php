<?php

namespace Tests\Feature;

use App\Models\Account;
use App\Models\Divida;
use App\Models\PerfilFinanceiro;
use App\Models\User;
use Carbon\CarbonImmutable;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * Item 0 do handoff: a base de dados do pivô "Quitar".
 *
 * O risco que estes testes guardam é a data de quitação. Ela é o número que
 * o app promete no onboarding ("pra quitar até janeiro") e sai de aritmética
 * de calendário — onde dia 31 em fevereiro é a armadilha clássica.
 */
class DividaModelTest extends TestCase
{
    use RefreshDatabase;

    private function usuario(): User
    {
        return User::factory()->create();
    }

    public function test_divida_nasce_em_aberto_e_separa_quitadas(): void
    {
        $user = $this->usuario();

        $aberta = Divida::factory()->for($user)->create();
        $quitada = Divida::factory()->for($user)->quitada()->create();

        $this->assertFalse($aberta->estaQuitada());
        $this->assertTrue($quitada->estaQuitada());

        $this->assertEqualsCanonicalizing(
            [$aberta->id],
            Divida::emAberto()->pluck('id')->all()
        );
        $this->assertEqualsCanonicalizing(
            [$quitada->id],
            Divida::quitadas()->pluck('id')->all()
        );
    }

    public function test_fatura_de_cartao_e_uma_divida_ligada_a_conta(): void
    {
        $user = $this->usuario();

        $cartao = Account::create([
            'user_id' => $user->id,
            'name' => 'Nubank',
            'type' => 'credit_card',
            'initial_balance' => 0,
            'current_balance' => 0,
            'credit_limit' => 5000,
            'closing_day' => 28,
            'due_day' => 4,
        ]);

        $fatura = Divida::factory()->for($user)->create([
            'nome' => 'Fatura Nubank',
            'account_id' => $cartao->id,
        ]);

        $this->assertTrue($fatura->ehFaturaDeCartao());
        $this->assertSame($cartao->id, $fatura->account->id);

        $emprestimo = Divida::factory()->for($user)->create(['account_id' => null]);
        $this->assertFalse($emprestimo->ehFaturaDeCartao());
    }

    public function test_conta_parcelas_pagas_para_o_7_de_10(): void
    {
        $divida = Divida::factory()->for($this->usuario())->create([
            'parcelas_total' => 10,
            'parcelas_restantes' => 3,
        ]);

        $this->assertSame(7, $divida->parcelasPagas());
    }

    public function test_parcelas_pagas_nunca_e_negativo(): void
    {
        // Dado inconsistente (restantes > total) não pode virar "-2 pagas"
        // na tela do usuário.
        $divida = Divida::factory()->for($this->usuario())->create([
            'parcelas_total' => 3,
            'parcelas_restantes' => 5,
        ]);

        $this->assertSame(0, $divida->parcelasPagas());
    }

    public function test_previsao_de_quitacao_conta_a_partir_do_proximo_vencimento(): void
    {
        $divida = Divida::factory()->for($this->usuario())->create([
            'dia_vencimento' => 10,
            'parcelas_restantes' => 4,
        ]);

        // Hoje é dia 5: o vencimento do dia 10 ainda não passou, então a
        // 1ª das 4 restantes é este mês e a última cai 3 meses depois.
        $previsao = $divida->previsaoQuitacao(CarbonImmutable::create(2026, 9, 5));

        $this->assertSame('2026-12-10', $previsao->toDateString());
    }

    public function test_previsao_pula_o_mes_quando_o_vencimento_ja_passou(): void
    {
        $divida = Divida::factory()->for($this->usuario())->create([
            'dia_vencimento' => 4,
            'parcelas_restantes' => 4,
        ]);

        // Hoje é dia 6, o vencimento do dia 4 já passou: a 1ª restante é
        // outubro, a última é janeiro. É exatamente o caso do Gabriel.
        $previsao = $divida->previsaoQuitacao(CarbonImmutable::create(2026, 9, 6));

        $this->assertSame('2027-01-04', $previsao->toDateString());
    }

    public function test_vencimento_dia_31_encolhe_em_mes_curto(): void
    {
        $divida = Divida::factory()->for($this->usuario())->create([
            'dia_vencimento' => 31,
            'parcelas_restantes' => 1,
        ]);

        $this->assertSame('2026-02-28', $divida->vencimentoNoMes(2026, 2)->toDateString());
        $this->assertSame('2028-02-29', $divida->vencimentoNoMes(2028, 2)->toDateString());
        $this->assertSame('2026-04-30', $divida->vencimentoNoMes(2026, 4)->toDateString());
        $this->assertSame('2026-01-31', $divida->vencimentoNoMes(2026, 1)->toDateString());
    }

    public function test_previsao_atravessa_fevereiro_sem_estourar_a_data(): void
    {
        $divida = Divida::factory()->for($this->usuario())->create([
            'dia_vencimento' => 31,
            'parcelas_restantes' => 3,
        ]);

        // Dez/jan/fev: a última parcela é em fevereiro e precisa virar 28,
        // não 2 de março.
        $previsao = $divida->previsaoQuitacao(CarbonImmutable::create(2026, 12, 1));

        $this->assertSame('2027-02-28', $previsao->toDateString());
    }

    public function test_previsao_de_uma_unica_parcela_restante_e_o_proximo_vencimento(): void
    {
        $divida = Divida::factory()->for($this->usuario())->create([
            'dia_vencimento' => 20,
            'parcelas_restantes' => 1,
        ]);

        $previsao = $divida->previsaoQuitacao(CarbonImmutable::create(2026, 9, 1));

        $this->assertSame('2026-09-20', $previsao->toDateString());
    }

    public function test_divida_sem_parcelas_restantes_nao_tem_previsao(): void
    {
        $divida = Divida::factory()->for($this->usuario())->quitada()->create();

        $this->assertNull($divida->previsaoQuitacao(CarbonImmutable::create(2026, 9, 6)));
    }

    public function test_perfil_financeiro_e_um_por_usuario_e_marca_a_origem(): void
    {
        $user = $this->usuario();

        $perfil = PerfilFinanceiro::factory()->for($user)->create();

        $this->assertSame($perfil->id, $user->fresh()->perfilFinanceiro->id);
        $this->assertFalse($perfil->veioDeExtrato());

        $doExtrato = PerfilFinanceiro::factory()->doExtrato()->create();
        $this->assertTrue($doExtrato->veioDeExtrato());
    }

    public function test_apagar_usuario_leva_dividas_e_perfil_junto(): void
    {
        $user = $this->usuario();
        Divida::factory()->for($user)->create();
        PerfilFinanceiro::factory()->for($user)->create();

        $user->delete();

        $this->assertSame(0, Divida::count());
        $this->assertSame(0, PerfilFinanceiro::count());
    }
}
