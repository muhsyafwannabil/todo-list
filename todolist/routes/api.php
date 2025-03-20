<?php

use App\Http\Controllers\Api\Auth\AuthController;
use App\Http\Controllers\Api\Services\CategoryControlleer;
use App\Http\Controllers\Api\Services\LableControlleer;
use App\Http\Controllers\Api\Services\TodoControlleer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;

Route::prefix('auth')->group(function () {
    //Route login
    Route::post('/login', [AuthController::class, 'login'])->name('auth.login');

    //Route register
    Route::post('/register', [AuthController::class, 'register'])->name('auth.login');

    //Route logout

});

//Route Services
Route::prefix('services')->group(function () {
    //CategoryRoute
    Route::apiResource('category', CategoryControlleer::class);
    //labelRoute
    Route::apiResource('label', LableControlleer::class);
    //Todos Route
    Route::apiResource('todos', TodoControlleer::class);
});


Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');
