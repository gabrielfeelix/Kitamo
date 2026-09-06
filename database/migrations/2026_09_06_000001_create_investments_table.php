<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('investments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->string('asset_class');
            $table->string('institution')->nullable();
            $table->string('ticker')->nullable();
            $table->decimal('quantity', 18, 8)->nullable();
            $table->decimal('current_value', 15, 2)->default(0);
            $table->string('price_source')->default('manual');
            $table->timestamp('price_updated_at')->nullable();
            $table->boolean('is_archived')->default(false);
            $table->string('color')->nullable();
            $table->string('icon')->nullable();
            $table->timestamps();

            $table->index(['user_id', 'is_archived']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('investments');
    }
};
