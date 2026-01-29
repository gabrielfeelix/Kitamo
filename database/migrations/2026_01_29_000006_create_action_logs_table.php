<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('action_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('actor_user_id')->constrained('users')->cascadeOnDelete();
            $table->string('method', 10);
            $table->string('route_name', 120)->nullable();
            $table->text('path');
            $table->unsignedSmallInteger('status_code')->nullable();
            $table->string('ip', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->json('payload')->nullable();
            $table->timestamps();

            $table->index(['actor_user_id', 'created_at']);
            $table->index(['route_name', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('action_logs');
    }
};

