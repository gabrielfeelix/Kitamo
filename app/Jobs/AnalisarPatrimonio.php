<?php

namespace App\Jobs;

use App\Models\Investment;
use App\Models\KitamoNotification;
use App\Models\User;
use App\Support\KitamoBootstrap;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Carbon;
use Illuminate\Support\Str;

/**
 * Análise mensal do patrimônio.
 *
 * A ideia vem do modelo de agentes com cadência da Pierre: em vez de esperar
 * o usuário abrir um dashboard e interpretar números, o app procura o que
 * mudou e avisa. Só notifica quando há algo acionável — alerta que aparece
 * todo mês sem motivo vira ruído e o usuário desliga.
 */
class AnalisarPatrimonio implements ShouldQueue
{
    use Dispatchable;
    use InteractsWithQueue;
    use Queueable;
    use SerializesModels;

    public function handle(): void
    {
        User::query()->chunkById(100, function ($users) {
            foreach ($users as $user) {
                $this->analisar($user);
            }
        });
    }

    private function analisar(User $user): void
    {
        $investimentos = Investment::query()
            ->where('user_id', $user->id)
            ->ativos()
            ->with('movimentos')
            ->get();

        if ($investimentos->isEmpty()) {
            return;
        }

        $this->alertarExposicaoFgc($user, $investimentos);
        $this->alertarAbaixoDoCdi($user, $investimentos);
        $this->alertarPrecoParado($user, $investimentos);
    }

    /**
     * Saldo garantido acima do teto do FGC numa mesma instituição: o excedente
     * simplesmente não está coberto, e quase ninguém percebe sozinho.
     */
    private function alertarExposicaoFgc(User $user, $investimentos): void
    {
        $porInstituicao = [];

        foreach ($investimentos as $i) {
            if (!in_array($i->asset_class, ['caixinha', 'cdb'], true)) {
                continue;
            }
            $nome = trim((string) $i->institution) ?: 'uma instituição';
            $porInstituicao[$nome] = ($porInstituicao[$nome] ?? 0) + (float) $i->current_value;
        }

        foreach ($porInstituicao as $instituicao => $total) {
            if ($total <= KitamoBootstrap::TETO_FGC) {
                continue;
            }

            $excedente = $total - KitamoBootstrap::TETO_FGC;

            $this->notificar(
                $user,
                'patrimonio_fgc',
                'media',
                'Parte do seu dinheiro está fora da garantia do FGC',
                sprintf(
                    'Você tem %s em %s. O FGC garante até %s por instituição, então %s está sem cobertura.',
                    $this->brl($total),
                    $instituicao,
                    $this->brl(KitamoBootstrap::TETO_FGC),
                    $this->brl($excedente),
                ),
            );
        }
    }

    /**
     * Rendimento abaixo do CDI. Só avisa com pelo menos 90 dias aplicados:
     * antes disso a variação é ruído, não tendência.
     */
    private function alertarAbaixoDoCdi(User $user, $investimentos): void
    {
        $bootstrap = app(KitamoBootstrap::class);

        foreach ($investimentos as $i) {
            $dados = $bootstrap->investment($i);
            $percentual = $dados['percentualDoCdi'] ?? null;

            if ($percentual === null || $percentual >= 90) {
                continue;
            }

            $primeiroAporte = $i->movimentos->where('kind', 'aporte')->min('occurred_on');
            if (!$primeiroAporte || Carbon::parse($primeiroAporte)->diffInDays(now()) < 90) {
                continue;
            }

            $this->notificar(
                $user,
                'patrimonio_rendimento',
                'baixa',
                sprintf('%s está rendendo abaixo do CDI', $i->name),
                sprintf(
                    'No período aplicado, %s rendeu %s%% do CDI. Vale comparar com outras opções.',
                    $i->name,
                    number_format($percentual, 0, ',', '.'),
                ),
            );
        }
    }

    /**
     * Posição manual sem atualização há mais de 60 dias: o número na tela
     * provavelmente já não é verdade.
     */
    private function alertarPrecoParado(User $user, $investimentos): void
    {
        foreach ($investimentos as $i) {
            if ($i->price_source !== 'manual' || !$i->price_updated_at) {
                continue;
            }

            if ($i->price_updated_at->diffInDays(now()) < 60) {
                continue;
            }

            $this->notificar(
                $user,
                'patrimonio_desatualizado',
                'baixa',
                sprintf('Quanto tem hoje em %s?', $i->name),
                sprintf(
                    'O valor de %s não é atualizado há %d dias. Conferir mantém seu patrimônio confiável.',
                    $i->name,
                    (int) $i->price_updated_at->diffInDays(now()),
                ),
            );
        }
    }

    /**
     * Não repete a mesma notificação enquanto a anterior ainda está válida —
     * é o que separa um agente útil de spam mensal.
     */
    private function notificar(User $user, string $tipo, string $prioridade, string $titulo, string $mensagem): void
    {
        $jaExiste = KitamoNotification::query()
            ->where('user_id', $user->id)
            ->where('tipo', $tipo)
            ->where('titulo', $titulo)
            ->where('expirada', false)
            ->exists();

        if ($jaExiste) {
            return;
        }

        KitamoNotification::create([
            'id' => (string) Str::uuid(),
            'user_id' => $user->id,
            'tipo' => $tipo,
            'prioridade' => $prioridade,
            'titulo' => $titulo,
            'mensagem' => $mensagem,
            'lida' => false,
            'expirada' => false,
            'data_expiracao' => now()->addDays(30),
            'acao_primaria_tipo' => 'ver_patrimonio',
            'acao_primaria_url' => 'kitamo://patrimonio',
            'metadata' => ['origem' => 'analise_patrimonio'],
        ]);
    }

    private function brl(float $valor): string
    {
        return 'R$ ' . number_format($valor, 2, ',', '.');
    }
}
