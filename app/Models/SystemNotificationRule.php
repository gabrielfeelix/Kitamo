<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SystemNotificationRule extends Model
{
    protected $fillable = [
        'scope',
        'title',
        'description',
        'icon',
        'enabled',
        'trigger_key',
        'trigger_config',
        'channels',
        'message_title',
        'message_body',
    ];

    protected $casts = [
        'enabled' => 'boolean',
        'trigger_config' => 'array',
        'channels' => 'array',
    ];
}

