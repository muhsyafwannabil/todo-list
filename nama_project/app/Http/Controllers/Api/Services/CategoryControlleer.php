<?php

namespace App\Http\Controllers\Api\Services;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Http\Resources\CategoryResources;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class CategoryControlleer extends Controller
{
    public function index()
    {
        return response()->json(Category::all());
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'title' => 'required',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $categories = Category::create([
            'title' => $request->title,
        ]);

        return new CategoryResources(true, 'Data Berhasil Ditambahkan', $categories);
    }

    public function show($id)
    {
        $categories = Category::find($id);

        return new CategoryResources(true, 'Detail Data Post', $categories);
    }

    public function update(Request $request, $id)
    {
        //define validation rules
        $validator = Validator::make($request->all(), [
            'title'     => 'required',
        ]);

        //check if validation fails
        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        //find post by ID
        $categories = Category::find($id);

        //update post without image
        $categories->update([
            'title'     => $request->title,
            'content'   => $request->content,
        ]);


        //return response
        return new CategoryResources(true, 'Data Post Berhasil Diubah!', $categories);
    }

    public function destroy($id)
    {

        //find post by ID
        $categories = Category::find($id);

        //delete post
        $categories->delete();

        //return response
        return new CategoryResources(true, 'Data Post Berhasil Dihapus!', null);
    }
}
