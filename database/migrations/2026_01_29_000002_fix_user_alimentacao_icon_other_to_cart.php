<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Alguns usuários acabam com categorias duplicadas (user_id != null) sem ícone ou com "other".
        // Para evitar inconsistência na listagem/detalhes, padroniza Alimentação.
        DB::table('categories')
            ->whereNotNull('user_id')
            ->where('name', 'Alimentação')
            ->where(function ($q) {
                $q->whereNull('icon')
                    ->orWhere('icon', '')
                    ->orWhereIn('icon', ['other', 'food', 'heart']);
            })
            ->update(['icon' => 'cart']);
    }

    public function down(): void
    {
        // No-op
    }
};

