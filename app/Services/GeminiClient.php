<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use RuntimeException;

class GeminiClient
{
    public function __construct(
        private readonly string $apiKey,
        private readonly string $model,
        private readonly string $baseUrl = 'https://generativelanguage.googleapis.com/v1beta',
    ) {}

    public static function fromConfig(): self
    {
        $key = (string) config('services.gemini.api_key', env('GEMINI_API_KEY', ''));
        $model = (string) config('services.gemini.model', env('GEMINI_MODEL', 'gemini-3-flash-preview'));

        if ($key === '') {
            throw new RuntimeException('GEMINI_API_KEY não configurada.');
        }

        return new self($key, $model);
    }

    public function generateJson(string $systemPrompt, string $userPrompt): array
    {
        $url = "{$this->baseUrl}/models/{$this->model}:generateContent?key={$this->apiKey}";

        $response = Http::timeout(45)->post($url, [
            'systemInstruction' => [
                'parts' => [['text' => $systemPrompt]],
            ],
            'contents' => [
                ['role' => 'user', 'parts' => [['text' => $userPrompt]]],
            ],
            'generationConfig' => [
                'responseMimeType' => 'application/json',
                'temperature' => 0.4,
            ],
        ]);

        if (! $response->successful()) {
            throw new RuntimeException("Gemini retornou {$response->status()}: " . $response->body());
        }

        $body = $response->json();
        $text = $body['candidates'][0]['content']['parts'][0]['text'] ?? null;

        if (! is_string($text)) {
            throw new RuntimeException('Resposta Gemini sem texto.');
        }

        $decoded = json_decode($text, true);
        if (! is_array($decoded)) {
            throw new RuntimeException('Resposta Gemini não é JSON válido: ' . substr($text, 0, 200));
        }

        return $decoded;
    }

    public function generateText(string $systemPrompt, string $userPrompt): string
    {
        $url = "{$this->baseUrl}/models/{$this->model}:generateContent?key={$this->apiKey}";

        $response = Http::timeout(45)->post($url, [
            'systemInstruction' => [
                'parts' => [['text' => $systemPrompt]],
            ],
            'contents' => [
                ['role' => 'user', 'parts' => [['text' => $userPrompt]]],
            ],
            'generationConfig' => [
                'temperature' => 0.6,
            ],
        ]);

        if (! $response->successful()) {
            throw new RuntimeException("Gemini retornou {$response->status()}: " . $response->body());
        }

        $body = $response->json();
        return (string) ($body['candidates'][0]['content']['parts'][0]['text'] ?? '');
    }
}
