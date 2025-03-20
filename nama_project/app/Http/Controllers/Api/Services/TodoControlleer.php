<?php

namespace App\Http\Controllers\Api\Services;

use App\Http\Controllers\Controller;
use App\Http\Resources\TodoResource;
use App\Models\Todo;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class TodoControlleer extends Controller
{
    public function index()
    {
        $todos = Todo::with(['category', 'label'])
            ->orderByRaw("
                CASE
                    WHEN status = 'tinggi' THEN 1
                    WHEN status = 'sedang' THEN 2
                    WHEN status = 'rendah' THEN 3
                END
            ")->get();

        return response()->json($todos);
    }

    public function store(Request $request)
    {
        $request->validate([
            'title' => 'required',
            'category_id' => 'required|exists:categories,id',
            'label_id' => 'required|exists:labels,id',
            'status' => 'required|in:rendah,sedang,tinggi',
            'deadline' => 'required',
        ]);

        $todo = Todo::create($request->all());
        $todo->load('category', 'label');
        return response()->json($todo, 201);
    }


    public function show($id)
    {
        $Todo = Todo::find($id);

        return new TodoResource(true, 'Detail Data Post', $Todo);
    }

    public function update(Request $request, Todo $todo)
    {
        $todo->update($request->only(['title', 'description', 'category_id', 'label_id', 'status', 'deadline']));
        $todo->load('category', 'label');
        return response()->json([
            'message' => 'Todo berhasil diperbarui',
            'data' => $todo
        ], 200);
    }
    public function destroy($id)
    {

        //find post by ID
        $Todo = Todo::find($id);

        //delete post
        $Todo->delete();

        //return response
        return new TodoResource(true, 'Data Post Berhasil Dihapus!', null);
    }
}
