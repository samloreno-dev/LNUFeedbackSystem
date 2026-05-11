<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\OfficeController;
use App\Http\Controllers\FeedbackController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\AdminAuthController;
use App\Http\Controllers\SettingsController;

Route::post('/feedback', [FeedbackController::class, 'store']);

Route::post('/admin/login', [AdminAuthController::class, 'login']);

Route::get('/dashboard-summary', [DashboardController::class, 'summary']);

Route::get('/offices', [OfficeController::class, 'index']);

Route::get('/feedback', [FeedbackController::class, 'index']);

Route::middleware('auth:sanctum')->group(function () {

    Route::post('/admin/logout', [AdminAuthController::class, 'logout']);
    Route::get('/admin/me', [AdminAuthController::class, 'me']);

    // Offices CRUD
    Route::post('/offices', [OfficeController::class, 'store']);

    // ⚠️ FIX: use {office} instead of {id} (cleaner for Laravel model binding)
    Route::put('/offices/{office}', [OfficeController::class, 'update']);
    Route::delete('/offices/{office}', [OfficeController::class, 'destroy']);

    // Settings
    Route::get('/settings', [SettingsController::class, 'index']);
    Route::post('/settings', [SettingsController::class, 'store']);
});