<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class InvestmentPrice extends Model
{
    use HasFactory;

    protected $fillable = [
        'ticker',
        'source',
        'price',
        'quoted_on',
    ];

    protected function casts(): array
    {
        return [
            'price' => 'decimal:8',
            'quoted_on' => 'date',
        ];
    }
}
