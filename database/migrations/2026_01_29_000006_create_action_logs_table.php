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
            // Keep it compatible with shared-host MySQL setups (avoid FK constraints that can fail)
            $table->unsignedBigInteger('actor_user_id');
            $table->string('method', 10);
            $table->string('route_name', 120)->nullable();
            $table->text('path');
            $table->unsignedSmallInteger('status_code')->nullable();
            $table->string('ip', 45)->nullable();
            $table->text('user_agent')->nullable();
            // Use longText instead of JSON for maximum compatibility (Laravel will still cast it to array)
            $table->longText('payload')->nullable();
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
