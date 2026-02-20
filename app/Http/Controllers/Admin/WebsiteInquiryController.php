<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\WebsiteInquiry;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class WebsiteInquiryController extends Controller
{
    public function index(): Response
    {
        $inquiries = WebsiteInquiry::query()
            ->orderByRaw('handled_at is null desc')
            ->orderByDesc('created_at')
            ->get()
            ->map(fn (WebsiteInquiry $inquiry) => [
                'id' => (int) $inquiry->id,
                'name' => $inquiry->name,
                'email' => $inquiry->email,
                'objective' => $inquiry->objective,
                'message' => $inquiry->message,
                'source' => $inquiry->source,
                'handled_at' => $inquiry->handled_at?->toISOString(),
                'created_at' => $inquiry->created_at?->toISOString(),
            ]);

        return Inertia::render('Admin/Inquiries', [
            'inquiries' => $inquiries,
        ]);
    }

    public function update(Request $request, WebsiteInquiry $inquiry): RedirectResponse
    {
        $data = $request->validate([
            'handled' => ['required', 'boolean'],
        ]);

        $inquiry->handled_at = $data['handled'] ? now() : null;
        $inquiry->save();

        return back()->with('success', 'Contato atualizado.');
    }

    public function destroy(WebsiteInquiry $inquiry): RedirectResponse
    {
        $inquiry->delete();

        return back()->with('success', 'Contato removido.');
    }
}
