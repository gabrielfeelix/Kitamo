<?php

namespace App\Http\Controllers;

use App\Models\PerfilFinanceiro;
use App\Services\DiarioService;
use App\Services\HorizonteService;
use Illuminate\Http\Request;
use Inertia\Inertia;

/**
 * A tela inicial do "Quitar" — spec §3.1 e §3.2.
 *
 * Quem ainda não respondeu o onboarding vai para ele: sem perfil não há
 * número, e a tela sem número não diz nada.
 */
class InicioController extends Controller
{
    public function __invoke(Request $request, DiarioService $diario, HorizonteService $horizonte)
    {
        $user = $request->user();

        $temPerfil = PerfilFinanceiro::query()->where('user_id', $user->id)->exists();

        if (! $temPerfil) {
            return redirect()->route('onboarding');
        }

        return Inertia::render('Inicio', [
            'diario' => $diario->calcular($user->id),
            'mes' => $horizonte->mes($user->id),
        ]);
    }
}
