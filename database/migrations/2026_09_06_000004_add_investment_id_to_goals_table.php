<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('goals', function (Blueprint $table) {
            // Meta ligada a um investimento: o progresso passa a acompanhar o
            // valor da posição, em vez de depender só de depósitos manuais.
            $table->foreignId('investment_id')->nullable()->after('user_id')->constrained()->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('goals', function (Blueprint $table) {
            $table->dropForeign(['investment_id']);
            $table->dropColumn('investment_id');
        });
    }
};
