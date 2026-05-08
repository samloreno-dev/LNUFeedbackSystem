<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Office;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            AdminUserSeeder::class,
        ]);

        // NOTE: Do not seed default offices from the admin dashboard.
        // Offices should come from the database (created/managed via /offices endpoints).
        // Keeping database seeding limited to initial admin user setup.

    }
}

