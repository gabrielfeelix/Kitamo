<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('news_reactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('news_item_id')->constrained('news_items')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('reaction', 16);
            $table->timestamps();

            $table->unique(['news_item_id', 'user_id']);
            $table->index(['news_item_id', 'reaction']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('news_reactions');
    }
};

