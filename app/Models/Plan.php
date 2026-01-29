<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Plan extends Model
{
    protected $fillable = [
        'name',
        'slug',
        'description',
        'price_cents',
        'currency',
        'interval',
        'accounts_limit',
        'cards_limit',
        'projection_days',
        'backup_enabled',
        'recurring_enabled',
        'priority_support',
        'trial_days',
        'requires_card',
        'is_popular',
        'is_active',
        'sort_order',
    ];

    protected $casts = [
        'backup_enabled' => 'boolean',
        'recurring_enabled' => 'boolean',
        'priority_support' => 'boolean',
        'requires_card' => 'boolean',
        'is_popular' => 'boolean',
        'is_active' => 'boolean',
    ];
}

