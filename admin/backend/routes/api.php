<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

Route::middleware('api')->group(function () {
    Route::post('/feedback', [App\Http\Controllers\FeedbackController::class, 'store']);

    // Admin Auth
    Route::post('/admin/login', [App\Http\Controllers\AdminAuthController::class, 'login']);

    // Protected Admin Routes
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/admin/logout', [App\Http\Controllers\AdminAuthController::class, 'logout']);
        Route::get('/admin/me', [App\Http\Controllers\AdminAuthController::class, 'me']);

        // Feedback
        Route::get('/feedback', [App\Http\Controllers\FeedbackController::class, 'index']);

        // Offices
        Route::get('/offices', [App\Http\Controllers\OfficeController::class, 'index']);
        Route::post('/offices', [App\Http\Controllers\OfficeController::class, 'store']);
        Route::put('/offices/{id}', [App\Http\Controllers\OfficeController::class, 'update']);
        Route::delete('/offices/{id}', [App\Http\Controllers\OfficeController::class, 'destroy']);

        // Settings
        Route::get('/settings', [App\Http\Controllers\SettingsController::class, 'index']);
        Route::post('/settings', [App\Http\Controllers\SettingsController::class, 'store']);
    });
});

