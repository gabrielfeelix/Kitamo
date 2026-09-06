<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Divida>
 */
class DividaFactory extends Factory
{
    public function definition(): array
    {
        $total = fake()->numberBetween(2, 24);

        return [
            'user_id' => User::factory(),
            'account_id' => null,
            'nome' => fake()->randomElement(['Nubank', 'Mercado Pago', 'Itaú', 'Crediário']),
            'saldo_atual' => fake()->randomFloat(2, 100, 20000),
            'valor_parcela' => fake()->randomFloat(2, 50, 2000),
            'dia_vencimento' => fake()->numberBetween(1, 28),
            'parcelas_total' => $total,
            'parcelas_restantes' => fake()->numberBetween(1, $total),
            'taxa_juros' => null,
            'quitada_em' => null,
        ];
    }

    public function quitada(): static
    {
        return $this->state(fn () => [
            'parcelas_restantes' => 0,
            'saldo_atual' => 0,
            'quitada_em' => now(),
        ]);
    }
}
