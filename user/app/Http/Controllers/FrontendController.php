<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\File;

class FrontendController extends Controller
{
    /**
     * Serve Flutter web (built index.html) from the public directory.
     *
     * This supports direct route access like /feedback or /thankyou.
     */
    public function spa(Request $request)
    {
        $indexPath = public_path('flutter/index.html');

        if (!File::exists($indexPath)) {
            // Fallback to existing root welcome.
            return response()->view('welcome');
        }

        return response()->file($indexPath);
    }
}

