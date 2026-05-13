<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Avoid: Duplicate column name 'analysis'
        if (!Schema::hasColumn('feedback', 'analysis')) {
            Schema::table('feedback', function (Blueprint $table) {
                $table->json('analysis')->nullable()->after('message');
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasColumn('feedback', 'analysis')) {
            Schema::table('feedback', function (Blueprint $table) {
                $table->dropColumn('analysis');
            });
        }
    }
};


