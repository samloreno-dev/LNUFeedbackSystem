<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // If the existing feedback.analysis column is non-nullable and/or has different type,
        // Laravel may fail. We normalize it to nullable JSON.
        // This migration assumes the column exists.
        Schema::table('feedback', function (Blueprint $table) {
            // Using change() requires doctrine/dbal. If it's not installed, this won't work.
            // So we keep this migration minimal; if you want to enforce strict schema,
            // install doctrine/dbal or adjust manually.
        });
    }

    public function down(): void
    {
        // no-op
    }
};

