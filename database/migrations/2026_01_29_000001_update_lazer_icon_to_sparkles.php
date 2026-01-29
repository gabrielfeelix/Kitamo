<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Padroniza o ícone de "Lazer" para um ícone mais apropriado.
        // Ajusta apenas casos comuns (nulo/placeholder/ícones antigos).
        DB::table('categories')
            ->where('name', 'Lazer')
            ->where(function ($q) {
                $q->whereNull('icon')
                    ->orWhere('icon', '')
                    ->orWhereIn('icon', ['other', 'game', 'credit-card', 'credit_card', 'card']);
            })
            ->update(['icon' => 'sparkles']);
    }

    public function down(): void
    {
        // No-op: não há forma segura de restaurar o ícone anterior do usuário.
    }
};

