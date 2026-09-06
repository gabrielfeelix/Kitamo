<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Respostas do onboarding (spec §3.3). Uma linha por usuário.
 */
class PerfilFinanceiro extends Model
{
    use HasFactory;

    protected $table = 'perfil_financeiro';

    public const ORIGEM_FEELING = 'feeling';
    public const ORIGEM_OFX = 'ofx';

    protected $fillable = [
        'user_id',
        'renda_mensal',
        'dia_renda',
        'gasto_diario_estimado',
        'contas_fixas_estimadas',
        'origem',
    ];

    protected function casts(): array
    {
        return [
            'renda_mensal' => 'decimal:2',
            'gasto_diario_estimado' => 'decimal:2',
            'contas_fixas_estimadas' => 'decimal:2',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /** true quando os números vieram de extrato, não de chute. */
    public function veioDeExtrato(): bool
    {
        return $this->origem === self::ORIGEM_OFX;
    }
}
