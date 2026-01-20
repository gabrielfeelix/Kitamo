<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Transaction extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'account_id',
        'category_id',
        'kind',
        'status',
        'amount',
        'moeda',
        'description',
        'notes',
        'transaction_date',
        'priority',
        'installment_label',
        'installment_index',
        'installment_total',
        'is_recurring',
        'is_parcelado',
        'parcela_atual',
        'parcela_total',
        'recurrence_interval',
        'next_run_at',
        'recurrence_end_at',
        'recorrencia_grupo_id',
        'parcelamento_grupo_id',
        'data_pagamento',
        'tags',
        'receipt_path',
        'receipt_original_name',
        'receipt_mime',
        'receipt_size',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'transaction_date' => 'date',
            'priority' => 'boolean',
            'is_recurring' => 'boolean',
            'is_parcelado' => 'boolean',
            'parcela_atual' => 'integer',
            'parcela_total' => 'integer',
            'next_run_at' => 'date',
            'recurrence_end_at' => 'date',
            'data_pagamento' => 'datetime',
            'tags' => 'array',
        ];
    }

    public function recorrenciaGrupo(): BelongsTo
    {
        return $this->belongsTo(RecorrenciaGrupo::class, 'recorrencia_grupo_id');
    }

    public function parcelamentoGrupo(): BelongsTo
    {
        return $this->belongsTo(ParcelamentoGrupo::class, 'parcelamento_grupo_id');
    }

    public function tagsRelation(): BelongsToMany
    {
        return $this->belongsToMany(Tag::class, 'transaction_tags', 'transaction_id', 'tag_id');
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function account(): BelongsTo
    {
        return $this->belongsTo(Account::class);
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }
}
