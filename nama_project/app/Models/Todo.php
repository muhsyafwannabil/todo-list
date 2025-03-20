<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Todo extends Model
{

    protected $fillable = ['title', 'description', 'category_id', 'label_id', 'status', 'deadline'];

    public function category()
    {
        return $this->belongsTo(Category::class);
    }
    public function label()
    {
        return $this->belongsTo(Label::class);
    }
}
