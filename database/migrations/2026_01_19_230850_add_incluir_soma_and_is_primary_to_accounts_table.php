<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('accounts', function (Blueprint $table) {
            // Include in dashboard total/sum (for wallets and bank accounts)
            $table->boolean('incluir_soma')->default(true)->after('is_archived');

            // Mark as primary credit card (e.g., for "PRINCIPAL" badge in card display)
            $table->boolean('is_primary')->default(false)->after('incluir_soma');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('accounts', function (Blueprint $table) {
            $table->dropColumn(['incluir_soma', 'is_primary']);
        });
    }
};
