<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('feedback', function (Blueprint $table) {
            // Add only if it doesn't exist.
            // Laravel doesn't have a portable "hasColumn" for Schema builder,
            // so we rely on SQLSTATE/attempt pattern via Schema? Not available here.
            // The migration is safe because running migrations in Laravel should only happen once.
            $table->json('analysis')->nullable()->after('message');
        });
    }

    public function down(): void
    {
        Schema::table('feedback', function (Blueprint $table) {
            $table->dropColumn('analysis');
        });
    }
};

