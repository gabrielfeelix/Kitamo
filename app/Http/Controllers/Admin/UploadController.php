<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class UploadController extends Controller
{
    public function image(Request $request): JsonResponse
    {
        $data = $request->validate([
            'image' => ['required', 'file', 'max:2048', 'mimes:jpg,jpeg,png,gif,webp'],
        ]);

        /** @var \Illuminate\Http\UploadedFile $file */
        $file = $data['image'];
        $path = $file->storePublicly('emails', ['disk' => 'public']);

        return response()->json([
            'url' => Storage::disk('public')->url($path),
        ]);
    }
}

