<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Category extends Model
{
    protected $fillable = ['title', 'todo_id'];
    public function todos()
    {
        return $this->hasMany(Todo::class);
    }
}
