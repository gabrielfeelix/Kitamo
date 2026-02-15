<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class NewsFeedback extends Model
{
    protected $fillable = [
        'news_item_id',
        'user_id',
        'feedback_text',
    ];

    protected $casts = [
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    public function newsItem(): BelongsTo
    {
        return $this->belongsTo(NewsItem::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
