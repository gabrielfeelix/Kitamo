<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Investment extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'name',
        'asset_class',
        'institution',
        'ticker',
        'quantity',
        'current_value',
        'price_source',
        'price_updated_at',
        'is_archived',
        'color',
        'icon',
    ];

    protected function casts(): array
    {
        return [
            'quantity' => 'decimal:8',
            'current_value' => 'decimal:2',
            'price_updated_at' => 'datetime',
            'is_archived' => 'boolean',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function movimentos(): HasMany
    {
        return $this->hasMany(InvestmentTransaction::class);
    }

    public function scopeAtivos(Builder $query): Builder
    {
        return $query->where('is_archived', false);
    }
}
