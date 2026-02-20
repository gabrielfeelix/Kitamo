<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class WebsiteInquiry extends Model
{
    protected $fillable = [
        'name',
        'email',
        'objective',
        'message',
        'source',
        'ip_address',
        'user_agent',
        'handled_at',
    ];

    protected $casts = [
        'handled_at' => 'datetime',
    ];
}
