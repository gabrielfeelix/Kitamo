<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('system_notification_rules', function (Blueprint $table) {
            $table->id();
            $table->string('scope', 16)->default('user'); // user|admin
            $table->string('title');
            $table->string('description')->nullable();
            $table->string('icon', 16)->nullable();
            $table->boolean('enabled')->default(true);

            $table->string('trigger_key', 64)->default('custom');
            $table->json('trigger_config')->nullable();
            $table->json('channels')->nullable(); // ["in_app","email",...]

            $table->string('message_title')->default('');
            $table->text('message_body')->nullable();

            $table->timestamps();

            $table->index(['scope', 'enabled']);
            $table->index(['trigger_key']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('system_notification_rules');
    }
};

