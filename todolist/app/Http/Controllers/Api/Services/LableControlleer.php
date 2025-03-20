<?php

namespace App\Http\Controllers\Api\Services;

use App\Http\Controllers\Controller;
use App\Http\Resources\lableResources;
use App\Models\Label;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class LableControlleer extends Controller
{
    public function index()
    {
        try {
            $labels = Label::all(); // Pastikan tabel "labels" ada di database
            return response()->json($labels, 200);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Server Error: ' . $e->getMessage()], 500);
        }
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'title' => 'required',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $Lable = Label::create([
            'title' => $request->title,
        ]);

        return new lableResources(true, 'Data Berhasil Ditambahkan', $Lable);
    }

    public function show($id)
    {
        $Lable = Label::find($id);

        return new lableResources(true, 'Detail Data Post', $Lable);
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
        $Lable = Label::find($id);

        //update post without image
        $Lable->update([
            'title'     => $request->title,
            'content'   => $request->content,
        ]);


        //return response
        return new lableResources(true, 'Data Post Berhasil Diubah!', $Lable);
    }

    public function destroy($id)
    {

        //find post by ID
        $Lable = Label::find($id);

        //delete post
        $Lable->delete();

        //return response
        return new lableResources(true, 'Data Post Berhasil Dihapus!', null);
    }
}
