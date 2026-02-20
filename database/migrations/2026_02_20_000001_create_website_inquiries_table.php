<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('website_inquiries', function (Blueprint $table) {
            $table->id();
            $table->string('name', 120);
            $table->string('email', 190);
            $table->string('objective', 120);
            $table->text('message');
            $table->string('source', 64)->nullable();
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->timestamp('handled_at')->nullable();
            $table->timestamps();

            $table->index('email');
            $table->index('created_at');
            $table->index('handled_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('website_inquiries');
    }
};
