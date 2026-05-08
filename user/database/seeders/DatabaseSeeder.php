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

        // Seed default offices
        $defaultOffices = ['Library', 'Dormitory', 'Registrar'];
        foreach ($defaultOffices as $officeName) {
            Office::firstOrCreate(['name' => $officeName]);
        }
    }
}

