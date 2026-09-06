<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('investment_transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('investment_id')->constrained()->cascadeOnDelete();
            $table->string('kind');
            $table->decimal('amount', 15, 2);
            $table->decimal('quantity', 18, 8)->nullable();
            $table->decimal('unit_price', 18, 8)->nullable();
            $table->date('occurred_on');
            // nullOnDelete: apagar a transação de caixa não pode apagar o
            // histórico do aporte — são fatos independentes.
            $table->foreignId('transaction_id')->nullable()->constrained()->nullOnDelete();
            $table->timestamps();

            $table->index(['investment_id', 'occurred_on']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('investment_transactions');
    }
};
