<?php

namespace Tests\Feature;

use App\Models\Account;
use App\Models\Divida;
use App\Models\PerfilFinanceiro;
use App\Models\User;
use App\Services\HorizonteService;
use Carbon\CarbonImmutable;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * Item 2: o horizonte que fala.
 *
 * O risco que estes testes guardam é uma parcela sumir da projeção. Um
 * vencimento dia 31 não existe em fevereiro; se o cálculo exigir dia
 * exato, a parcela desaparece justo no mês mais curto — e o app mostra
 * um mês folgado que não existe.
 */
class HorizonteServiceTest extends TestCase
{
    use RefreshDatabase;

    private function service(): HorizonteService
    {
        return app(HorizonteService::class);
    }

    private function usuario(float $saldo = 0, array $perfil = [], array $dividas = []): User
    {
        $user = User::factory()->create();

        Account::create([
            'user_id' => $user->id,
            'name' => 'Conta',
            'type' => 'bank',
            'initial_balance' => $saldo,
            'current_balance' => $saldo,
        ]);

        if ($perfil !== []) {
            PerfilFinanceiro::factory()->for($user)->create($perfil);
        }

        foreach ($dividas as $d) {
            Divida::factory()->for($user)->create($d);
        }

        return $user;
    }

    public function test_cada_linha_tem_nome_e_valor(): void
    {
        $user = $this->usuario(5000,
            ['renda_mensal' => 3000, 'dia_renda' => 5, 'gasto_diario_estimado' => 0,
             'contas_fixas_estimadas' => 0],
            [['nome' => 'Nubank', 'valor_parcela' => 1534.06,
              'dia_vencimento' => 4, 'parcelas_restantes' => 4]],
        );

        $h = $this->service()->mes($user->id, CarbonImmutable::create(2026, 9, 1));

        $dia4 = collect($h['dias'])->firstWhere('dia', 4);
        $this->assertSame('parcela do Nubank', $dia4['lancamentos'][0]['nome']);
        $this->assertSame(1534.06, $dia4['lancamentos'][0]['valor']);
        $this->assertSame('saida', $dia4['lancamentos'][0]['tipo']);

        $dia5 = collect($h['dias'])->firstWhere('dia', 5);
        $this->assertSame('salário', $dia5['lancamentos'][0]['nome']);
        $this->assertSame('entrada', $dia5['lancamentos'][0]['tipo']);
    }

    public function test_explica_quando_a_parcela_cai_antes_do_salario(): void
    {
        // O caso que custou R$ 1.674 ao Gabriel em 12 meses.
        $user = $this->usuario(100,
            ['renda_mensal' => 3000, 'dia_renda' => 6, 'gasto_diario_estimado' => 0,
             'contas_fixas_estimadas' => 0],
            [['nome' => 'Nubank', 'valor_parcela' => 1534.06,
              'dia_vencimento' => 4, 'parcelas_restantes' => 4]],
        );

        $h = $this->service()->mes($user->id, CarbonImmutable::create(2026, 9, 1));
        $dia4 = collect($h['dias'])->firstWhere('dia', 4);

        $this->assertSame('aperto', $dia4['estado']);
        $this->assertSame(
            'a parcela do Nubank cai antes do salário do dia 6',
            $dia4['motivo']
        );
    }

    public function test_dia_tranquilo_nao_tem_motivo(): void
    {
        $user = $this->usuario(10000,
            ['renda_mensal' => 3000, 'dia_renda' => 5, 'gasto_diario_estimado' => 0,
             'contas_fixas_estimadas' => 0],
        );

        $h = $this->service()->mes($user->id, CarbonImmutable::create(2026, 9, 1));

        $this->assertSame('tranquilo', $h['dias'][0]['estado']);
        $this->assertNull($h['dias'][0]['motivo']);
    }

    public function test_saldo_baixo_vira_atencao_antes_de_estourar(): void
    {
        $user = $this->usuario(50, ['renda_mensal' => 0, 'dia_renda' => null,
            'gasto_diario_estimado' => 0, 'contas_fixas_estimadas' => 0]);

        $h = $this->service()->mes($user->id, CarbonImmutable::create(2026, 9, 1));

        $this->assertSame('atencao', $h['dias'][0]['estado']);
        $this->assertSame('o saldo fica baixo neste dia', $h['dias'][0]['motivo']);
    }

    public function test_parcela_dia_31_nao_some_em_fevereiro(): void
    {
        $user = $this->usuario(10000,
            ['renda_mensal' => 0, 'dia_renda' => null, 'gasto_diario_estimado' => 0,
             'contas_fixas_estimadas' => 0],
            [['nome' => 'Crediário', 'valor_parcela' => 200,
              'dia_vencimento' => 31, 'parcelas_restantes' => 12]],
        );

        $fev = $this->service()->mes($user->id, CarbonImmutable::create(2026, 2, 1));

        $ultimo = collect($fev['dias'])->last();
        $this->assertSame(28, $ultimo['dia']);
        $this->assertSame('parcela do Crediário', $ultimo['lancamentos'][0]['nome']);

        // E aparece uma única vez no mês.
        $comLancamento = collect($fev['dias'])->filter(fn ($d) => $d['lancamentos'] !== []);
        $this->assertCount(1, $comLancamento);
    }

    public function test_toda_combinacao_de_vencimento_e_renda_aparece_uma_vez_por_mes(): void
    {
        // 24 meses × vencimento 1–31 × renda 1–31, como pede o handoff.
        // A garantia: cada lançamento aparece exatamente uma vez no mês,
        // nunca zero (some) nem duas (duplica).
        $s = $this->service();

        foreach ([1, 4, 15, 28, 29, 30, 31] as $venc) {
            foreach ([1, 5, 28, 31] as $diaRenda) {
                $user = $this->usuario(50000,
                    ['renda_mensal' => 3000, 'dia_renda' => $diaRenda,
                     'gasto_diario_estimado' => 0, 'contas_fixas_estimadas' => 0],
                    [['nome' => 'X', 'valor_parcela' => 100,
                      'dia_vencimento' => $venc, 'parcelas_restantes' => 36]],
                );

                for ($i = 0; $i < 24; $i++) {
                    $mes = CarbonImmutable::create(2026, 1, 1)->addMonthsNoOverflow($i);
                    $h = $s->mes($user->id, $mes);

                    $parcelas = collect($h['dias'])->flatMap(fn ($d) => $d['lancamentos'])
                        ->where('nome', 'parcela do X');
                    $salarios = collect($h['dias'])->flatMap(fn ($d) => $d['lancamentos'])
                        ->where('nome', 'salário');

                    $this->assertCount(1, $parcelas,
                        "vencimento {$venc} em {$mes->format('Y-m')}");
                    $this->assertCount(1, $salarios,
                        "renda dia {$diaRenda} em {$mes->format('Y-m')}");
                }
            }
        }
    }

    public function test_horizonte_de_12_meses_mostra_a_divida_acabando(): void
    {
        $user = $this->usuario(0,
            ['renda_mensal' => 3000, 'dia_renda' => 5, 'gasto_diario_estimado' => 0,
             'contas_fixas_estimadas' => 1000],
            [['nome' => 'Nubank', 'valor_parcela' => 1500,
              'dia_vencimento' => 4, 'parcelas_restantes' => 4]],
        );

        $doze = $this->service()->doze($user->id, CarbonImmutable::create(2026, 9, 1));

        $this->assertCount(12, $doze);
        $this->assertSame('set/26', $doze[0]['label']);

        // Enquanto há parcela, o mês pesa 1500 a mais.
        $this->assertTrue($doze[0]['tem_divida']);
        $this->assertSame(1500.0, $doze[0]['parcelas']);
        $this->assertSame(500.0, $doze[0]['saldo_final']);

        // A 4ª parcela é a última: de dezembro em diante não pesa mais.
        $this->assertTrue($doze[3]['tem_divida']);
        $this->assertFalse($doze[4]['tem_divida']);
        $this->assertSame(0.0, $doze[4]['parcelas']);

        // E o saldo volta a subir 2000 por mês.
        $this->assertSame($doze[4]['saldo_final'] + 2000.0, $doze[5]['saldo_final']);
    }

    public function test_mes_negativo_no_horizonte_fica_em_aperto(): void
    {
        $user = $this->usuario(0,
            ['renda_mensal' => 2000, 'dia_renda' => 5, 'gasto_diario_estimado' => 0,
             'contas_fixas_estimadas' => 900],
            [['nome' => 'Nubank', 'valor_parcela' => 1534,
              'dia_vencimento' => 4, 'parcelas_restantes' => 6]],
        );

        $doze = $this->service()->doze($user->id, CarbonImmutable::create(2026, 9, 1));

        $this->assertSame('aperto', $doze[0]['estado']);
        $this->assertSame(-434.0, $doze[0]['saldo_final']);
    }

    public function test_marca_o_primeiro_dia_apertado_do_mes(): void
    {
        $user = $this->usuario(100,
            ['renda_mensal' => 3000, 'dia_renda' => 20, 'gasto_diario_estimado' => 0,
             'contas_fixas_estimadas' => 0],
            [['nome' => 'Nubank', 'valor_parcela' => 500,
              'dia_vencimento' => 10, 'parcelas_restantes' => 4]],
        );

        $h = $this->service()->mes($user->id, CarbonImmutable::create(2026, 9, 1));

        $this->assertSame('2026-09-10', $h['primeiro_dia_apertado']);
    }

    public function test_gasto_diario_consome_o_saldo(): void
    {
        $user = $this->usuario(1000,
            ['renda_mensal' => 0, 'dia_renda' => null, 'gasto_diario_estimado' => 10,
             'contas_fixas_estimadas' => 0],
        );

        $h = $this->service()->mes($user->id, CarbonImmutable::create(2026, 9, 1));

        $this->assertSame(990.0, $h['dias'][0]['saldo']);
        $this->assertSame(980.0, $h['dias'][1]['saldo']);
        // 30 dias × 10 = 300
        $this->assertSame(700.0, $h['saldo_final']);
    }

    public function test_divida_quitada_nao_entra_no_horizonte(): void
    {
        $user = $this->usuario(1000, ['renda_mensal' => 0, 'dia_renda' => null,
            'gasto_diario_estimado' => 0, 'contas_fixas_estimadas' => 0]);
        Divida::factory()->for($user)->quitada()->create([
            'nome' => 'Paga', 'valor_parcela' => 900, 'dia_vencimento' => 10,
        ]);

        $h = $this->service()->mes($user->id, CarbonImmutable::create(2026, 9, 1));

        $this->assertSame(1000.0, $h['saldo_final']);
        $comLancamento = collect($h['dias'])->filter(fn ($d) => $d['lancamentos'] !== []);
        $this->assertCount(0, $comLancamento);
    }

    public function test_usuario_sem_perfil_nao_quebra(): void
    {
        $user = $this->usuario(0);

        $h = $this->service()->mes($user->id, CarbonImmutable::create(2026, 9, 1));
        $doze = $this->service()->doze($user->id, CarbonImmutable::create(2026, 9, 1));

        $this->assertCount(30, $h['dias']);
        $this->assertCount(12, $doze);
    }
}
