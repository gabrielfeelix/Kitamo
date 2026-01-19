<?php

namespace App\Http\Controllers;

use App\Models\Account;
use Illuminate\Http\Request;

class CreditCardController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();

        $cartoes = Account::query()
            ->where('user_id', $user->id)
            ->where('type', 'credit_card')
            ->orderBy('id', 'desc')
            ->get()
            ->map(fn (Account $account) => [
                'id' => (string) $account->id,
                'nome' => $account->name,
                'bandeira' => ($account->card_brand ?: 'visa'),
                'limite' => (float) ($account->credit_limit ?? 0),
                'limite_usado' => (float) ($account->current_balance ?? 0),
                'dia_fechamento' => (int) ($account->closing_day ?? 10),
                'dia_vencimento' => (int) ($account->due_day ?? 17),
                'cor' => ($account->color ?: '#8B5CF6'),
            ]);

        return response()->json([
            'cartoes' => $cartoes,
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'nome' => ['required', 'string', 'max:50'],
            'bandeira' => ['nullable', 'string', 'max:30'],
            'limite' => ['required', 'numeric', 'min:0'],
            'dia_fechamento' => ['required', 'integer', 'min:1', 'max:31'],
            'dia_vencimento' => ['required', 'integer', 'min:1', 'max:31'],
            'cor' => ['nullable', 'string', 'max:20'],
            'icone' => ['nullable', 'string', 'max:50'],
            'is_primary' => ['nullable', 'boolean'],
        ]);

        $account = Account::create([
            'user_id' => $request->user()->id,
            'name' => $data['nome'],
            'type' => 'credit_card',
            'icon' => $data['icone'] ?? 'credit-card',
            'color' => $data['cor'] ?? '#8B5CF6',
            'card_brand' => $data['bandeira'] ?? 'visa',
            'initial_balance' => 0,
            'current_balance' => 0,
            'credit_limit' => $data['limite'],
            'closing_day' => $data['dia_fechamento'],
            'due_day' => $data['dia_vencimento'],
            'is_primary' => $data['is_primary'] ?? false,
        ]);

        return response()->json([
            'id' => (string) $account->id,
        ], 201);
    }

    public function update(Request $request, Account $cartao)
    {
        abort_unless($request->user()->id === $cartao->user_id, 403);
        abort_unless($cartao->type === 'credit_card', 404);

        $data = $request->validate([
            'nome' => ['sometimes', 'required', 'string', 'max:50'],
            'bandeira' => ['nullable', 'string', 'max:30'],
            'limite' => ['sometimes', 'required', 'numeric', 'min:0'],
            'dia_fechamento' => ['sometimes', 'required', 'integer', 'min:1', 'max:31'],
            'dia_vencimento' => ['sometimes', 'required', 'integer', 'min:1', 'max:31'],
            'cor' => ['nullable', 'string', 'max:20'],
            'icone' => ['nullable', 'string', 'max:50'],
            'is_primary' => ['nullable', 'boolean'],
        ]);

        $cartao->fill([
            'name' => $data['nome'] ?? $cartao->name,
            'credit_limit' => array_key_exists('limite', $data) ? $data['limite'] : $cartao->credit_limit,
            'closing_day' => array_key_exists('dia_fechamento', $data) ? $data['dia_fechamento'] : $cartao->closing_day,
            'due_day' => array_key_exists('dia_vencimento', $data) ? $data['dia_vencimento'] : $cartao->due_day,
            'icon' => $data['icone'] ?? $cartao->icon,
            'color' => $data['cor'] ?? $cartao->color,
            'card_brand' => $data['bandeira'] ?? $cartao->card_brand,
            'is_primary' => array_key_exists('is_primary', $data) ? $data['is_primary'] : $cartao->is_primary,
        ]);
        $cartao->save();

        return response()->json(['ok' => true]);
    }

    public function destroy(Request $request, Account $cartao)
    {
        abort_unless($request->user()->id === $cartao->user_id, 403);
        abort_unless($cartao->type === 'credit_card', 404);

        $cartao->delete();

        return response()->json(['ok' => true]);
    }
}
