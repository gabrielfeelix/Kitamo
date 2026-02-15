<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\NewsItem;
use App\Models\NewsFeedback;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;
use Inertia\Response;

class NewsItemsController extends Controller
{
    public function index(): Response
    {
        $items = NewsItem::query()
            ->orderByDesc('created_at')
            ->limit(300)
            ->get()
            ->map(fn (NewsItem $n) => [
                'id' => (int) $n->id,
                'title' => (string) $n->title,
                'category' => $n->category,
                'type' => (string) $n->type,
                'visibility' => (string) $n->visibility,
                'status' => (string) $n->status,
                'scheduled_at' => $n->scheduled_at?->toISOString(),
                'published_at' => $n->published_at?->toISOString(),
                'content' => $n->content,
                'image_url' => $n->image_url,
                'cta_text' => $n->cta_text,
                'cta_url' => $n->cta_url,
                'created_at' => $n->created_at?->toISOString(),
            ]);

        // Buscar feedbacks com informações do usuário e da novidade
        $feedbacks = NewsFeedback::query()
            ->join('users', 'news_feedbacks.user_id', '=', 'users.id')
            ->join('news_items', 'news_feedbacks.news_item_id', '=', 'news_items.id')
            ->select(
                'news_feedbacks.id',
                'news_feedbacks.news_item_id',
                'news_items.title as news_title',
                'users.name as user_name',
                'users.email as user_email',
                'news_feedbacks.feedback_text',
                'news_feedbacks.created_at'
            )
            ->orderByDesc('news_feedbacks.created_at')
            ->limit(100)
            ->get()
            ->map(fn ($f) => [
                'id' => (int) $f->id,
                'news_item_id' => (int) $f->news_item_id,
                'news_title' => (string) $f->news_title,
                'user_name' => (string) $f->user_name,
                'user_email' => (string) $f->user_email,
                'feedback_text' => (string) $f->feedback_text,
                'created_at' => Carbon::parse($f->created_at)->toISOString(),
            ]);

        return Inertia::render('Admin/News', [
            'items' => $items,
            'feedbacks' => $feedbacks,
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'title' => ['required', 'string', 'max:160'],
            'category' => ['nullable', 'string', 'max:80'],
            'type' => ['nullable', 'in:new,improvement,fix,announcement'],
            'visibility' => ['nullable', 'in:public,admin'],
            'status' => ['nullable', 'in:draft,scheduled,published'],
            'scheduled_at' => ['nullable', 'date'],
            'content' => ['nullable', 'string'],
            'image_url' => ['nullable', 'string', 'max:500'],
            'cta_text' => ['nullable', 'string', 'max:80'],
            'cta_url' => ['nullable', 'string', 'max:500'],
        ]);

        $item = new NewsItem();
        $item->created_by_user_id = $request->user()?->id;
        $item->title = $data['title'];
        $item->category = $data['category'] ?? null;
        $item->type = $data['type'] ?? 'new';
        $item->visibility = $data['visibility'] ?? 'public';
        $item->status = $data['status'] ?? 'draft';
        $item->scheduled_at = isset($data['scheduled_at']) ? Carbon::parse($data['scheduled_at']) : null;
        $item->content = $data['content'] ?? null;
        $item->image_url = $data['image_url'] ?? null;
        $item->cta_text = $data['cta_text'] ?? null;
        $item->cta_url = $data['cta_url'] ?? null;
        if ($item->status === 'published') {
            $item->published_at = now();
        }
        $item->save();

        return back()->with('success', 'Novidade criada.');
    }

    public function update(Request $request, NewsItem $newsItem): RedirectResponse
    {
        $data = $request->validate([
            'title' => ['sometimes', 'required', 'string', 'max:160'],
            'category' => ['nullable', 'string', 'max:80'],
            'type' => ['nullable', 'in:new,improvement,fix,announcement'],
            'visibility' => ['nullable', 'in:public,admin'],
            'status' => ['nullable', 'in:draft,scheduled,published'],
            'scheduled_at' => ['nullable', 'date'],
            'content' => ['nullable', 'string'],
            'image_url' => ['nullable', 'string', 'max:500'],
            'cta_text' => ['nullable', 'string', 'max:80'],
            'cta_url' => ['nullable', 'string', 'max:500'],
        ]);

        if (array_key_exists('title', $data)) $newsItem->title = $data['title'];
        $newsItem->category = $data['category'] ?? null;
        if (($data['type'] ?? null) !== null) $newsItem->type = $data['type'];
        if (($data['visibility'] ?? null) !== null) $newsItem->visibility = $data['visibility'];
        if (($data['status'] ?? null) !== null) {
            $newsItem->status = $data['status'];
            if ($newsItem->status === 'published' && ! $newsItem->published_at) {
                $newsItem->published_at = now();
            }
        }
        $newsItem->scheduled_at = isset($data['scheduled_at']) && $data['scheduled_at']
            ? Carbon::parse($data['scheduled_at'])
            : null;
        $newsItem->content = $data['content'] ?? null;
        $newsItem->image_url = $data['image_url'] ?? null;
        $newsItem->cta_text = $data['cta_text'] ?? null;
        $newsItem->cta_url = $data['cta_url'] ?? null;
        $newsItem->save();

        return back()->with('success', 'Novidade atualizada.');
    }

    public function destroy(NewsItem $newsItem): RedirectResponse
    {
        $newsItem->delete();
        return back()->with('success', 'Novidade excluída.');
    }
}

