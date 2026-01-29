<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $categories = [
            ['name' => 'Alimentação', 'type' => 'expense', 'color' => '#27AE60', 'icon' => 'cart'],
            ['name' => 'Transporte', 'type' => 'expense', 'color' => '#3498DB', 'icon' => 'car'],
            ['name' => 'Moradia', 'type' => 'expense', 'color' => '#9B59B6', 'icon' => 'home'],
            ['name' => 'Lazer', 'type' => 'expense', 'color' => '#E67E22', 'icon' => 'sparkles'],
            ['name' => 'Saúde', 'type' => 'expense', 'color' => '#E74C3C', 'icon' => 'heart'],
            ['name' => 'Salário', 'type' => 'income', 'color' => '#2ECC71', 'icon' => 'money'],
            ['name' => 'Outros', 'type' => 'income', 'color' => '#95A5A6', 'icon' => 'briefcase'],
        ];

        foreach ($categories as $category) {
            Category::firstOrCreate(
                [
                    'name' => $category['name'],
                    'type' => $category['type'],
                    'user_id' => null,
                ],
                [
                    'color' => $category['color'],
                    'icon' => $category['icon'],
                    'is_default' => true,
                ]
            );
        }
    }
}
