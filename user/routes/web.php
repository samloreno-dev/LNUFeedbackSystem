<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

// Flutter web SPA (static) fallback
Route::get('/{any}', [App\Http\Controllers\FrontendController::class, 'spa'])
    ->where('any', '.*');


