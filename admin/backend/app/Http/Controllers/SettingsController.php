<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class SettingsController extends Controller
{
    public function index(): JsonResponse
    {
        $settings = DB::table('settings')
            ->pluck('value', 'key')
            ->toArray();

        return response()->json([
            'success' => true,
            'data' => $settings,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'settings' => 'required|array',
        ]);

        $settings = $request->input('settings');

        foreach ($settings as $key => $value) {
            DB::table('settings')->updateOrInsert(
                ['key' => $key],
                ['value' => $value, 'updated_at' => now()]
            );
        }

        return response()->json([
            'success' => true,
            'message' => 'Settings saved successfully',
        ]);
    }
}

