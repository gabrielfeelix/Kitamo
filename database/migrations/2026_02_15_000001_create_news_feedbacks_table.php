<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('news_feedbacks', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('news_item_id');
            $table->unsignedBigInteger('user_id');
            $table->text('feedback_text');
            $table->timestamps();

            $table->index('news_item_id');
            $table->index('user_id');
            $table->index('created_at');
        });

        // Adicionar índice único para reações (cada usuário só pode ter uma reação por novidade)
        if (Schema::hasTable('news_reactions')) {
            Schema::table('news_reactions', function (Blueprint $table) {
                // Remove duplicatas primeiro se existirem
                DB::statement('
                    DELETE FROM news_reactions 
                    WHERE id NOT IN (
                        SELECT MIN(id) 
                        FROM news_reactions 
                        GROUP BY news_item_id, user_id
                    )
                ');
                
                // Adiciona índice único
                $table->unique(['news_item_id', 'user_id'], 'unique_user_news_reaction');
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('news_feedbacks');
        
        if (Schema::hasTable('news_reactions')) {
            Schema::table('news_reactions', function (Blueprint $table) {
                $table->dropUnique('unique_user_news_reaction');
            });
        }
    }
};
