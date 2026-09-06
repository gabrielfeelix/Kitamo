<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Goal extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'investment_id',
        'title',
        'target_amount',
        'current_amount',
        'due_date',
        'status',
        'color',
        'icon',
        'term',
        'tags',
    ];

    protected function casts(): array
    {
        return [
            'target_amount' => 'decimal:2',
            'current_amount' => 'decimal:2',
            'due_date' => 'date',
            'tags' => 'array',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function deposits(): HasMany
    {
        return $this->hasMany(GoalDeposit::class);
    }

    /**
     * Investimento que lastreia a meta. Quando presente, o progresso segue o
     * valor da posição — sobe e desce com o mercado, não só com depósitos.
     */
    public function investment(): BelongsTo
    {
        return $this->belongsTo(Investment::class);
    }
}
