<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('plans', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('slug')->unique();
            $table->string('description', 200)->nullable();

            $table->unsignedInteger('price_cents')->default(0);
            $table->string('currency', 3)->default('BRL');
            $table->string('interval', 16)->default('monthly'); // monthly|annual|lifetime

            $table->unsignedInteger('accounts_limit')->nullable(); // null = ilimitado
            $table->unsignedInteger('cards_limit')->nullable(); // null = ilimitado
            $table->unsignedInteger('projection_days')->default(30);

            $table->boolean('backup_enabled')->default(false);
            $table->boolean('recurring_enabled')->default(false);
            $table->boolean('priority_support')->default(false);

            $table->unsignedInteger('trial_days')->default(0);
            $table->boolean('requires_card')->default(false);

            $table->boolean('is_popular')->default(false);
            $table->boolean('is_active')->default(true);
            $table->unsignedInteger('sort_order')->default(0);

            $table->timestamps();

            $table->index(['is_active', 'sort_order']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('plans');
    }
};

