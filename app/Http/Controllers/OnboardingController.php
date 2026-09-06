<?php

namespace App\Http\Controllers;

use App\Models\Divida;
use App\Models\PerfilFinanceiro;
use App\Services\DiarioService;
use Illuminate\Http\Request;
use Inertia\Inertia;

/**
 * Onboarding do "Quitar" — spec §3.3. Cinco perguntas e uma oferta, uma por
 * tela, tudo pulável.
 *
 * Regra do spec: cada resposta pulada tem default explícito. Pular não pode
 * travar o app nem gerar número falso — gera número incompleto, que a
 * própria tela do diário sinaliza.
 */
class OnboardingController extends Controller
{
    public function show(Request $request)
    {
        $user = $request->user();

        return Inertia::render('Onboarding/Index', [
            'perfil' => PerfilFinanceiro::query()
                ->where('user_id', $user->id)
                ->first(),
            'dividas' => Divida::query()
                ->where('user_id', $user->id)
                ->emAberto()
                ->get(['id', 'nome', 'saldo_atual', 'valor_parcela', 'dia_vencimento', 'parcelas_restantes']),
        ]);
    }

    public function store(Request $request, DiarioService $diario)
    {
        $dados = $request->validate([
            'renda_mensal' => ['nullable', 'numeric', 'min:0', 'max:99999999'],
            'dia_renda' => ['nullable', 'integer', 'min:1', 'max:31'],
            'gasto_diario_estimado' => ['nullable', 'numeric', 'min:0', 'max:99999999'],
            'contas_fixas_estimadas' => ['nullable', 'numeric', 'min:0', 'max:99999999'],

            'dividas' => ['nullable', 'array', 'max:20'],
            'dividas.*.nome' => ['required', 'string', 'max:120'],
            'dividas.*.saldo_atual' => ['nullable', 'numeric', 'min:0', 'max:99999999'],
            'dividas.*.valor_parcela' => ['nullable', 'numeric', 'min:0', 'max:99999999'],
            'dividas.*.dia_vencimento' => ['nullable', 'integer', 'min:1', 'max:31'],
            'dividas.*.parcelas_restantes' => ['nullable', 'integer', 'min:0', 'max:600'],
        ]);

        $user = $request->user();

        PerfilFinanceiro::updateOrCreate(
            ['user_id' => $user->id],
            [
                'renda_mensal' => $dados['renda_mensal'] ?? null,
                'dia_renda' => $dados['dia_renda'] ?? null,
                'gasto_diario_estimado' => $dados['gasto_diario_estimado'] ?? null,
                'contas_fixas_estimadas' => $dados['contas_fixas_estimadas'] ?? null,
                'origem' => PerfilFinanceiro::ORIGEM_FEELING,
            ],
        );

        foreach ($dados['dividas'] ?? [] as $d) {
            $parcelas = (int) ($d['parcelas_restantes'] ?? 0);

            Divida::create([
                'user_id' => $user->id,
                'nome' => $d['nome'],
                'saldo_atual' => $d['saldo_atual'] ?? 0,
                'valor_parcela' => $d['valor_parcela'] ?? 0,
                'dia_vencimento' => $d['dia_vencimento'] ?? 1,
                'parcelas_restantes' => $parcelas,
                'parcelas_total' => $parcelas,
            ]);
        }

        return redirect()->route('inicio');
    }
}
