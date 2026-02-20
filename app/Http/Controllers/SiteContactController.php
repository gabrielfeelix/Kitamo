<?php

namespace App\Http\Controllers;

use App\Models\WebsiteInquiry;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SiteContactController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'email' => ['required', 'email', 'max:190'],
            'objective' => ['required', 'string', 'max:120'],
            'message' => ['required', 'string', 'max:2000'],
            'source' => ['nullable', 'string', 'max:64'],
            'company' => ['nullable', 'string', 'max:120'],
        ]);

        if (! empty($data['company'])) {
            return response()->json([
                'ok' => true,
            ], 202);
        }

        $inquiry = WebsiteInquiry::query()->create([
            'name' => $data['name'],
            'email' => $data['email'],
            'objective' => $data['objective'],
            'message' => $data['message'],
            'source' => $data['source'] ?? 'website-contact',
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
        ]);

        return response()->json([
            'ok' => true,
            'id' => (int) $inquiry->id,
        ]);
    }
}
