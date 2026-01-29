<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Considera que todos os usuários existentes já passaram pelo onboarding.
        // Novos usuários continuarão com onboarding_completed_at = null.
        DB::table('users')
            ->whereNull('onboarding_completed_at')
            ->update(['onboarding_completed_at' => DB::raw('created_at')]);
    }

    public function down(): void
    {
        // Não desfaz para evitar reabrir onboarding em massa.
    }
};

