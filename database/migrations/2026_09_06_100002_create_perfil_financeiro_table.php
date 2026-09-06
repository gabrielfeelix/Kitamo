<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Respostas do onboarding (spec §3.3). Uma linha por usuário.
     * origem diz se os números vieram do chute ("feeling") ou de um
     * extrato importado ("ofx").
     */
    public function up(): void
    {
        Schema::create('perfil_financeiro', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->cascadeOnDelete();

            $table->decimal('renda_mensal', 12, 2)->nullable();
            $table->unsignedTinyInteger('dia_renda')->nullable();
            $table->decimal('gasto_diario_estimado', 12, 2)->nullable();
            $table->decimal('contas_fixas_estimadas', 12, 2)->nullable();
            $table->string('origem')->default('feeling');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('perfil_financeiro');
    }
};
