<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Office;

class OfficeController extends Controller
{
    public function index(): JsonResponse
    {
        $offices = Office::orderBy('name')->get();

        return response()->json([
            'success' => true,
            'data' => $offices,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'name' => 'required|string|max:255|unique:offices,name',
        ]);

        $office = Office::create([
            'name' => $request->input('name'),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Office created successfully',
            'data' => $office,
        ], 201);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $office = Office::findOrFail($id);

        $request->validate([
            'name' => 'required|string|max:255|unique:offices,name,' . $office->id,
        ]);

        $office->update([
            'name' => $request->input('name'),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Office updated successfully',
            'data' => $office,
        ]);
    }

    public function destroy(int $id): JsonResponse
    {
        $office = Office::findOrFail($id);
        $office->delete();

        return response()->json([
            'success' => true,
            'message' => 'Office deleted successfully',
        ]);
    }
}

