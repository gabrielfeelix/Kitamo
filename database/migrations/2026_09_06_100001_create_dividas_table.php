<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Uma dívida é qualquer coisa que a pessoa precisa quitar: parcelamento,
     * empréstimo, renegociação ou a fatura de cartão em aberto (nesse caso
     * account_id aponta para o cartão). Ver spec §6.
     */
    public function up(): void
    {
        Schema::create('dividas', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('account_id')->nullable()->constrained()->nullOnDelete();

            $table->string('nome');
            $table->decimal('saldo_atual', 12, 2)->default(0);
            $table->decimal('valor_parcela', 12, 2)->default(0);
            $table->unsignedTinyInteger('dia_vencimento')->default(1);
            $table->unsignedSmallInteger('parcelas_restantes')->default(0);
            $table->unsignedSmallInteger('parcelas_total')->default(0);
            $table->decimal('taxa_juros', 8, 4)->nullable();
            $table->timestamp('quitada_em')->nullable();
            $table->timestamps();

            $table->index(['user_id', 'quitada_em']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('dividas');
    }
};
