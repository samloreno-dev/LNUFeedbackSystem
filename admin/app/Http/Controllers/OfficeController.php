<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Office;

class OfficeController extends Controller
{
    public function index(): JsonResponse
    {
        $offices = Office::withCount('feedback')
            ->orderBy('name')
            ->get();

        return response()->json($offices); // ✅ FIX: remove wrapper
    }

    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'name' => 'required|string|max:255|unique:offices,name',
        ]);

        $office = Office::create([
            'name' => $request->input('name'),
        ]);

        return response()->json($office, 201); // ✅ FIX
    }

    public function update(Request $request, Office $office): JsonResponse
    {
        $request->validate([
            'name' => 'required|string|max:255|unique:offices,name,' . $office->id,
        ]);

        $office->update([
            'name' => $request->input('name'),
        ]);

        return response()->json($office); // ✅ FIX
    }

    public function destroy(Office $office): JsonResponse
    {
        $office->delete();

        return response()->json([
            'message' => 'Office deleted successfully',
        ]);
    }
}