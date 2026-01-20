<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('transactions', function (Blueprint $table) {
            $table->string('receipt_path')->nullable()->after('tags');
            $table->string('receipt_original_name')->nullable()->after('receipt_path');
            $table->string('receipt_mime')->nullable()->after('receipt_original_name');
            $table->unsignedBigInteger('receipt_size')->nullable()->after('receipt_mime');
        });
    }

    public function down(): void
    {
        Schema::table('transactions', function (Blueprint $table) {
            $table->dropColumn(['receipt_path', 'receipt_original_name', 'receipt_mime', 'receipt_size']);
        });
    }
};

