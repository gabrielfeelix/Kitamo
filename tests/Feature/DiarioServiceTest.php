<?php

namespace Tests\Feature;

use App\Models\Divida;
use App\Models\PerfilFinanceiro;
use App\Models\User;
use App\Services\DiarioService;
use Carbon\CarbonImmutable;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * Item 1: o número que a tela inicial promete.
 *
 * O risco que estes testes guardam: um diário errado para mais faz a pessoa
 * gastar dinheiro que ela não tem, e é justamente quem está endividado que
 * paga caro por isso. Por isso o caso da sobra negativa tem teste próprio —
 * ele não pode virar "R$ 0" nem sumir.
 */
class DiarioServiceTest extends TestCase
{
    use RefreshDatabase;

    private function service(): DiarioService
    {
        return app(DiarioService::class);
    }

    private function usuarioCom(array $perfil = [], array $dividas = []): User
    {
        $user = User::factory()->create();

        PerfilFinanceiro::factory()->for($user)->create($perfil);

        foreach ($dividas as $d) {
            Divida::factory()->for($user)->create($d);
        }

        return $user;
    }

    public function test_diario_e_a_sobra_dividida_pelos_dias_do_mes(): void
    {
        // 3000 − 900 fixas − 1500 de parcela = 600 de sobra em setembro (30)
        $user = $this->usuarioCom(
            ['renda_mensal' => 3000, 'contas_fixas_estimadas' => 900],
            [['valor_parcela' => 1500, 'parcelas_restantes' => 4, 'dia_vencimento' => 4]],
        );

        $r = $this->service()->calcular($user->id, CarbonImmutable::create(2026, 9, 6));

        $this->assertSame(600.0, $r['sobra_mensal']);
        $this->assertSame(30, $r['dias_no_mes']);
        $this->assertSame(20.0, $r['diario']);
        $this->assertTrue($r['fecha']);
        $this->assertSame(0.0, $r['falta_por_mes']);
    }

    public function test_mesma_sobra_muda_o_diario_conforme_o_mes(): void
    {
        $perfil = ['renda_mensal' => 2000, 'contas_fixas_estimadas' => 1070];
        $dividas = [['valor_parcela' => 0, 'parcelas_restantes' => 0]];

        $user = $this->usuarioCom($perfil, $dividas);
        $s = $this->service();

        // Sobra de 930 em fev (28), abr (30) e jan (31)
        $fev = $s->calcular($user->id, CarbonImmutable::create(2026, 2, 10));
        $abr = $s->calcular($user->id, CarbonImmutable::create(2026, 4, 10));
        $jan = $s->calcular($user->id, CarbonImmutable::create(2026, 1, 10));

        $this->assertSame(28, $fev['dias_no_mes']);
        $this->assertSame(33.21, $fev['diario']);

        $this->assertSame(30, $abr['dias_no_mes']);
        $this->assertSame(31.0, $abr['diario']);

        $this->assertSame(31, $jan['dias_no_mes']);
        $this->assertSame(30.0, $jan['diario']);
    }

    public function test_fevereiro_bissexto_tem_29_dias(): void
    {
        $user = $this->usuarioCom(
            ['renda_mensal' => 1000, 'contas_fixas_estimadas' => 710],
            [['valor_parcela' => 0, 'parcelas_restantes' => 0]],
        );

        $r = $this->service()->calcular($user->id, CarbonImmutable::create(2028, 2, 10));

        $this->assertSame(29, $r['dias_no_mes']);
        $this->assertSame(10.0, $r['diario']);
    }

    public function test_sobra_negativa_nao_vira_diario_zero_disfarcado(): void
    {
        // 2000 − 900 − 1534 = −434. O app precisa dizer quanto falta.
        $user = $this->usuarioCom(
            ['renda_mensal' => 2000, 'contas_fixas_estimadas' => 900],
            [['valor_parcela' => 1534, 'parcelas_restantes' => 4]],
        );

        $r = $this->service()->calcular($user->id, CarbonImmutable::create(2026, 9, 6));

        $this->assertFalse($r['fecha']);
        $this->assertSame(-434.0, $r['sobra_mensal']);
        $this->assertSame(434.0, $r['falta_por_mes']);
        $this->assertSame(0.0, $r['diario']);
    }

    public function test_sobra_exatamente_zero_nao_fecha(): void
    {
        // Zero é o limite: não sobra nada para o dia a dia, então a conta
        // não fecha. Tratar como "fecha" daria um diário de R$ 0,00.
        $user = $this->usuarioCom(
            ['renda_mensal' => 2434, 'contas_fixas_estimadas' => 900],
            [['valor_parcela' => 1534, 'parcelas_restantes' => 4]],
        );

        $r = $this->service()->calcular($user->id, CarbonImmutable::create(2026, 9, 6));

        $this->assertSame(0.0, $r['sobra_mensal']);
        $this->assertFalse($r['fecha']);
        $this->assertSame(0.0, $r['diario']);
    }

    public function test_soma_as_parcelas_de_varias_dividas(): void
    {
        $user = $this->usuarioCom(
            ['renda_mensal' => 5000, 'contas_fixas_estimadas' => 1000],
            [
                ['valor_parcela' => 1534.06, 'parcelas_restantes' => 4],
                ['valor_parcela' => 133.28, 'parcelas_restantes' => 1],
                ['valor_parcela' => 200, 'parcelas_restantes' => 12],
            ],
        );

        $r = $this->service()->calcular($user->id, CarbonImmutable::create(2026, 9, 6));

        $this->assertSame(1867.34, $r['parcelas_do_mes']);
        $this->assertSame(2132.66, $r['sobra_mensal']);
    }

    public function test_divida_quitada_nao_pesa_no_diario(): void
    {
        $user = User::factory()->create();
        PerfilFinanceiro::factory()->for($user)->create([
            'renda_mensal' => 3000,
            'contas_fixas_estimadas' => 1000,
        ]);
        Divida::factory()->for($user)->create(['valor_parcela' => 500, 'parcelas_restantes' => 3]);
        Divida::factory()->for($user)->quitada()->create(['valor_parcela' => 900]);

        $r = $this->service()->calcular($user->id, CarbonImmutable::create(2026, 9, 6));

        $this->assertSame(500.0, $r['parcelas_do_mes']);
        $this->assertSame(1500.0, $r['sobra_mensal']);
    }

    public function test_data_de_quitacao_e_a_divida_mais_longa(): void
    {
        $user = $this->usuarioCom(
            ['renda_mensal' => 5000, 'contas_fixas_estimadas' => 500],
            [
                ['valor_parcela' => 100, 'parcelas_restantes' => 2, 'dia_vencimento' => 10],
                ['valor_parcela' => 100, 'parcelas_restantes' => 5, 'dia_vencimento' => 10],
                ['valor_parcela' => 100, 'parcelas_restantes' => 3, 'dia_vencimento' => 10],
            ],
        );

        // A mais longa: 5 parcelas a partir de setembro → janeiro de 2027.
        $r = $this->service()->calcular($user->id, CarbonImmutable::create(2026, 9, 6));

        $this->assertSame('2027-01-10', $r['quitacao_em']);
        $this->assertSame('janeiro', $r['quitacao_label']);
    }

    public function test_sem_dividas_nao_ha_data_de_quitacao(): void
    {
        $user = User::factory()->create();
        PerfilFinanceiro::factory()->for($user)->create([
            'renda_mensal' => 3000,
            'contas_fixas_estimadas' => 900,
        ]);

        $r = $this->service()->calcular($user->id, CarbonImmutable::create(2026, 9, 6));

        $this->assertFalse($r['tem_dividas']);
        $this->assertNull($r['quitacao_em']);
        $this->assertNull($r['quitacao_label']);
        $this->assertSame(2100.0, $r['sobra_mensal']);
    }

    public function test_usuario_sem_perfil_nao_quebra(): void
    {
        // Antes do onboarding não existe perfil. A tela precisa carregar.
        $user = User::factory()->create();

        $r = $this->service()->calcular($user->id, CarbonImmutable::create(2026, 9, 6));

        $this->assertSame(0.0, $r['renda_mensal']);
        $this->assertSame(0.0, $r['sobra_mensal']);
        $this->assertFalse($r['fecha']);
        $this->assertFalse($r['tem_dividas']);
    }

    public function test_quitacao_distante_ganha_o_ano_no_rotulo(): void
    {
        $user = $this->usuarioCom(
            ['renda_mensal' => 5000, 'contas_fixas_estimadas' => 500],
            [['valor_parcela' => 100, 'parcelas_restantes' => 30, 'dia_vencimento' => 10]],
        );

        $r = $this->service()->calcular($user->id, CarbonImmutable::create(2026, 9, 6));

        $this->assertSame('2029-02-10', $r['quitacao_em']);
        $this->assertSame('fevereiro de 2029', $r['quitacao_label']);
    }

    public function test_nao_mistura_dados_de_outro_usuario(): void
    {
        $outro = $this->usuarioCom(
            ['renda_mensal' => 9000, 'contas_fixas_estimadas' => 0],
            [['valor_parcela' => 5000, 'parcelas_restantes' => 10]],
        );

        $user = $this->usuarioCom(
            ['renda_mensal' => 3000, 'contas_fixas_estimadas' => 900],
            [['valor_parcela' => 600, 'parcelas_restantes' => 2]],
        );

        $r = $this->service()->calcular($user->id, CarbonImmutable::create(2026, 9, 6));

        $this->assertSame(600.0, $r['parcelas_do_mes']);
        $this->assertSame(1500.0, $r['sobra_mensal']);
        $this->assertNotNull($outro->id);
    }
}
