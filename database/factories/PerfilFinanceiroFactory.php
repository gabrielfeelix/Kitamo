<?php

namespace Database\Factories;

use App\Models\PerfilFinanceiro;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\PerfilFinanceiro>
 */
class PerfilFinanceiroFactory extends Factory
{
    protected $model = PerfilFinanceiro::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'renda_mensal' => 3650,
            'dia_renda' => 5,
            'gasto_diario_estimado' => 40,
            'contas_fixas_estimadas' => 900,
            'origem' => PerfilFinanceiro::ORIGEM_FEELING,
        ];
    }

    public function doExtrato(): static
    {
        return $this->state(fn () => ['origem' => PerfilFinanceiro::ORIGEM_OFX]);
    }
}
