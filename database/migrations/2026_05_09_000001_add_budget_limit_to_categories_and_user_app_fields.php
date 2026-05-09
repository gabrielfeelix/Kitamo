<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('categories', function (Blueprint $table) {
            if (! Schema::hasColumn('categories', 'budget_limit')) {
                $table->decimal('budget_limit', 12, 2)->nullable()->after('icon');
            }
        });

        Schema::table('users', function (Blueprint $table) {
            if (! Schema::hasColumn('users', 'entry_mode')) {
                $table->string('entry_mode', 20)->nullable()->after('onboarding_completed_at');
            }
            if (! Schema::hasColumn('users', 'plan_slug')) {
                $table->string('plan_slug', 40)->default('free')->after('entry_mode');
            }
            if (! Schema::hasColumn('users', 'twofa_enabled')) {
                $table->boolean('twofa_enabled')->default(false)->after('plan_slug');
            }
        });
    }

    public function down(): void
    {
        Schema::table('categories', function (Blueprint $table) {
            if (Schema::hasColumn('categories', 'budget_limit')) {
                $table->dropColumn('budget_limit');
            }
        });
        Schema::table('users', function (Blueprint $table) {
            foreach (['entry_mode', 'plan_slug', 'twofa_enabled'] as $col) {
                if (Schema::hasColumn('users', $col)) {
                    $table->dropColumn($col);
                }
            }
        });
    }
};
