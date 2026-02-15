<?php

namespace App\Http\Controllers;

use App\Models\NewsItem;
use App\Models\NewsReaction;
use App\Models\NewsFeedback;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class NewsApiController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $isAdmin = $user && mb_strtolower((string) $user->email) === 'contato@kitamo.com.br';

        $query = NewsItem::query()
            ->where('status', 'published')
            ->whereNotNull('published_at')
            ->orderByDesc('published_at');

        if (! $isAdmin) {
            $query->where('visibility', 'public');
        }

        $news = $query
            ->limit(100)
            ->get();

        $ids = $news->pluck('id')->filter()->values();

        $counts = [];
        $mine = [];
        if ($ids->isNotEmpty()) {
            $rawCounts = NewsReaction::query()
                ->select('news_item_id', 'reaction', DB::raw('count(*) as total'))
                ->whereIn('news_item_id', $ids)
                ->groupBy('news_item_id', 'reaction')
                ->get();

            foreach ($rawCounts as $row) {
                $nid = (int) $row->news_item_id;
                $reaction = (string) $row->reaction;
                $counts[$nid] ??= ['fire' => 0, 'happy' => 0, 'sad' => 0];
                if (array_key_exists($reaction, $counts[$nid])) {
                    $counts[$nid][$reaction] = (int) $row->total;
                }
            }

            if ($user) {
                $mine = NewsReaction::query()
                    ->where('user_id', $user->id)
                    ->whereIn('news_item_id', $ids)
                    ->pluck('reaction', 'news_item_id')
                    ->mapWithKeys(fn ($reaction, $newsItemId) => [(int) $newsItemId => (string) $reaction])
                    ->all();
            }
        }

        $items = $news->map(fn (NewsItem $n) => [
                'id' => (int) $n->id,
                'title' => (string) $n->title,
                'category' => $n->category,
                'type' => (string) $n->type,
                'published_at' => $n->published_at?->toISOString(),
                'content' => $n->content,
                'image_url' => $n->image_url,
                'cta_text' => $n->cta_text,
                'cta_url' => $n->cta_url,
                'reactions' => $counts[(int) $n->id] ?? ['fire' => 0, 'happy' => 0, 'sad' => 0],
                'my_reaction' => $mine[(int) $n->id] ?? null,
            ]);

        return response()->json([
            'items' => $items,
        ]);
    }

    public function react(Request $request, NewsItem $newsItem): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            abort(401);
        }

        $data = $request->validate([
            'reaction' => ['nullable', 'in:fire,happy,sad'],
        ]);

        $reaction = $data['reaction'] ?? null;

        if ($reaction === null) {
            NewsReaction::query()
                ->where('news_item_id', $newsItem->id)
                ->where('user_id', $user->id)
                ->delete();
        } else {
            NewsReaction::query()->updateOrCreate(
                [
                    'news_item_id' => $newsItem->id,
                    'user_id' => $user->id,
                ],
                [
                    'reaction' => $reaction,
                ],
            );
        }

        $rawCounts = NewsReaction::query()
            ->select('reaction', DB::raw('count(*) as total'))
            ->where('news_item_id', $newsItem->id)
            ->groupBy('reaction')
            ->get();

        $counts = ['fire' => 0, 'happy' => 0, 'sad' => 0];
        foreach ($rawCounts as $row) {
            $key = (string) $row->reaction;
            if (array_key_exists($key, $counts)) {
                $counts[$key] = (int) $row->total;
            }
        }

        $mine = NewsReaction::query()
            ->where('news_item_id', $newsItem->id)
            ->where('user_id', $user->id)
            ->value('reaction');

        return response()->json([
            'reactions' => $counts,
            'my_reaction' => $mine ? (string) $mine : null,
        ]);
    }

    public function sendFeedback(Request $request, NewsItem $newsItem): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            abort(401);
        }

        $data = $request->validate([
            'feedback' => ['required', 'string', 'max:1000'],
        ]);

        NewsFeedback::create([
            'news_item_id' => $newsItem->id,
            'user_id' => $user->id,
            'feedback_text' => $data['feedback'],
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Feedback enviado com sucesso!',
        ]);
    }
}

