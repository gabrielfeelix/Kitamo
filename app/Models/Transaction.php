<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

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
        'description',
        'notes',
        'transaction_date',
        'priority',
        'installment_label',
        'installment_index',
        'installment_total',
        'is_recurring',
        'recurrence_interval',
        'next_run_at',
        'recurrence_end_at',
        'tags',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'transaction_date' => 'date',
            'priority' => 'boolean',
            'is_recurring' => 'boolean',
            'next_run_at' => 'date',
            'recurrence_end_at' => 'date',
            'tags' => 'array',
        ];
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
