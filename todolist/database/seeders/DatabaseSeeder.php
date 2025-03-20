<?php

namespace Database\Seeders;
use App\Models\Category;
use App\Models\Label;
use App\Models\Todo;
use App\Models\User;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // User::factory(10)->create();

        User::factory()->create([
            'name' => 'Test User',
            'email' => 'test@example.com',
        ]);

        Category::create ([
            'title' => 'Category 1',
        ]);

        Label::create([
            'title' => 'Label 1',
        ]);

        Todo::create([
            'status' => 'sedang',
            'title' => 'Todo 1',
            'description' => 'Description 1',
            'deadline' => now(),
            'category_id' => 1,
            'label_id' => 1,
        ]);

    }
}
