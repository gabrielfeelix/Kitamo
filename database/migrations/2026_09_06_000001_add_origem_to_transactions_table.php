<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Registra a procedência de cada lançamento.
     *
     * Sem isso a reimportação depende de heurística (data + valor + descrição),
     * que colapsa duplicatas legítimas — dois cafés de R$ 12 no mesmo dia — e
     * duplica tudo quando o banco muda o texto da descrição.
     *
     * `origem_id` guarda o identificador do lado de fora: FITID no OFX,
     * transaction id no Pluggy. É o que torna a reimportação idempotente.
     */
    public function up(): void
    {
        Schema::table('transactions', function (Blueprint $table) {
            $table->string('origem', 20)->default('manual')->after('account_id');
            $table->string('origem_id')->nullable()->after('origem');

            // Nullable em origem_id não participa do unique no MySQL, então
            // lançamentos manuais (origem_id = null) nunca colidem entre si.
            $table->unique(
                ['user_id', 'account_id', 'origem', 'origem_id'],
                'transactions_origem_unique'
            );
        });
    }

    public function down(): void
    {
        Schema::table('transactions', function (Blueprint $table) {
            $table->dropUnique('transactions_origem_unique');
            $table->dropColumn(['origem', 'origem_id']);
        });
    }
};
