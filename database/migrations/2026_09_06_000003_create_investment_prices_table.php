<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('investment_prices', function (Blueprint $table) {
            $table->id();
            $table->string('ticker');
            $table->string('source');
            $table->decimal('price', 18, 8);
            $table->date('quoted_on');
            $table->timestamps();

            // Uma cotação por ticker/fonte/dia: é isto que evita repetir a
            // requisição a cada carregamento de página e preserva o último
            // preço conhecido quando a API falha.
            $table->unique(['ticker', 'source', 'quoted_on']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('investment_prices');
    }
};
