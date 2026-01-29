<?php

namespace App\Support;

use App\Models\Account;
use App\Models\Category;
use App\Models\Goal;
use App\Models\GoalDeposit;
use App\Models\Tag;
use App\Models\Transaction;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class KitamoBootstrap
{
    private function normalizeCategoryName(string $name): string
    {
        return (string) Str::of($name)->trim()->lower()->ascii()->replaceMatches('/\s+/', ' ');
    }

    private function normalizeTagName(string $name): string
    {
        $value = (string) Str::of($name)->trim()->replaceMatches('/\s+/', ' ');
        $value = ltrim($value, "# \t\n\r\0\x0B");
        return trim($value);
    }

    private function categoriesForUser(User $user): array
    {
        $categoryModels = Category::query()
            ->whereNull('user_id')
            ->orWhere('user_id', $user->id)
            ->orderBy('is_default', 'desc')
            ->orderBy('name')
            ->get();

        $grouped = $categoryModels->groupBy(
            fn (Category $c) => $this->normalizeCategoryName($c->name) . '|' . $c->type
        );

        return $grouped
            ->map(function ($items) use ($user) {
                /** @var \Illuminate\Support\Collection<int, Category> $items */
                $userCategory = $items->firstWhere('user_id', $user->id);
                $defaultCategory = $items->firstWhere('user_id', null);
                $chosen = $userCategory ?? $defaultCategory ?? $items->first();

                $resolved = $this->category($chosen);
                if (empty($resolved['color']) && !empty($defaultCategory?->color)) {
                    $resolved['color'] = $defaultCategory->color;
                }
                if (empty($resolved['icon']) && !empty($defaultCategory?->icon)) {
                    $resolved['icon'] = $defaultCategory->icon;
                }

                return $resolved;
            })
            ->values()
            ->sortBy('name')
            ->values()
            ->all();
    }

    public function forUser(User $user): array
    {
        $transactions = Transaction::with(['category', 'account', 'recorrenciaGrupo'])
            ->where('user_id', $user->id)
            ->orderByDesc('transaction_date')
            ->orderByDesc('id')
            ->get();

        $goals = Goal::with('deposits')
            ->where('user_id', $user->id)
            ->orderByDesc('created_at')
            ->get();

        $accounts = Account::where('user_id', $user->id)
            ->where('is_archived', false)
            ->orderBy('name')
            ->get();

        $categories = $this->categoriesForUser($user);

        $tagModels = Tag::where('user_id', $user->id)
            ->orderBy('nome')
            ->get();

        $tagMap = [];
        foreach ($tagModels as $tag) {
            $nome = $this->normalizeTagName((string) $tag->nome);
            if ($nome === '' || mb_strtolower($nome) === 'recorrente') {
                continue;
            }
            $key = mb_strtolower($nome);
            $tagMap[$key] = [
                'id' => (string) $tag->id,
                'nome' => $nome,
                'cor' => $tag->cor ?: '#64748B',
            ];
        }

        foreach ($transactions as $transaction) {
            foreach (($transaction->tags ?? []) as $raw) {
                $nome = $this->normalizeTagName((string) $raw);
                if ($nome === '' || mb_strtolower($nome) === 'recorrente') {
                    continue;
                }
                $key = mb_strtolower($nome);
                if (array_key_exists($key, $tagMap)) {
                    continue;
                }
                $tagMap[$key] = [
                    'id' => "derived:{$key}",
                    'nome' => $nome,
                    'cor' => '#64748B',
                ];
            }

            if ($transaction->relationLoaded('recorrenciaGrupo') && $transaction->recorrenciaGrupo) {
                foreach (($transaction->recorrenciaGrupo->tags ?? []) as $raw) {
                    $nome = $this->normalizeTagName((string) $raw);
                    if ($nome === '' || mb_strtolower($nome) === 'recorrente') {
                        continue;
                    }
                    $key = mb_strtolower($nome);
                    if (array_key_exists($key, $tagMap)) {
                        continue;
                    }
                    $tagMap[$key] = [
                        'id' => "derived:{$key}",
                        'nome' => $nome,
                        'cor' => '#64748B',
                    ];
                }
            }
        }

        $tags = collect(array_values($tagMap))
            ->sortBy(fn ($t) => $t['nome'])
            ->values();

        return [
            'entries' => $transactions->map(fn (Transaction $t) => $this->entry($t))->values(),
            'goals' => $goals->map(fn (Goal $g) => $this->goal($g))->values(),
            'accounts' => $accounts->map(fn (Account $a) => $this->account($a))->values(),
            'categories' => $categories,
            'tags' => $tags,
        ];
    }

    public function entry(Transaction $transaction): array
    {
        $date = $transaction->transaction_date ? Carbon::parse($transaction->transaction_date) : Carbon::now();
        $dayLabel = $date->format('d');
        $dateLabel = sprintf('DIA %s %s', $dayLabel, $this->monthShort($date));

        $categoryName = $transaction->category?->name ?? 'Outros';
        $categoryKey = $this->categoryKey($categoryName);
        $categoryIcon = $transaction->category?->icon;

        $tags = array_values(
            array_unique(
                array_values(
                    array_filter(
                        array_map(fn ($t) => $this->normalizeTagName((string) $t), $transaction->tags ?? []),
                        fn ($t) => $t !== '' && mb_strtolower($t) !== 'recorrente'
                    )
                )
            )
        );

        $grupo = $transaction->relationLoaded('recorrenciaGrupo') ? $transaction->recorrenciaGrupo : null;
        $isRecurring = (bool) $transaction->is_recurring;
        $recurrenceInterval = $grupo?->periodicidade ?? $transaction->recurrence_interval;
        $recurrenceEveryMonths = null;
        if ($recurrenceInterval === 'a_cada_x_meses') {
            $recurrenceEveryMonths = (int) ($grupo?->intervalo_meses ?? 1);
        }
        $recurrenceEndsAt = $grupo?->data_fim?->toDateString() ?? ($transaction->recurrence_end_at?->toDateString() ?? null);
        $isFixed = $isRecurring && $recurrenceEndsAt === null;

        return [
            'id' => (string) $transaction->id,
            'dateLabel' => $dateLabel,
            'dayLabel' => $dayLabel,
            'transactionDate' => $date->toDateString(),
            'title' => $transaction->description,
            'subtitle' => $transaction->installment_label ?? $categoryName,
            'amount' => (float) $transaction->amount,
            'kind' => $transaction->kind,
            'status' => $transaction->status,
            'priority' => (bool) $transaction->priority,
            'installment' => $transaction->installment_label,
            'icon' => $categoryIcon ?: $this->entryIcon($transaction->kind, $categoryKey),
            'categoryLabel' => $categoryName,
            'categoryKey' => $categoryKey,
            'accountLabel' => $transaction->account?->name ?? 'Conta',
            'isRecurring' => $isRecurring,
            'isFixed' => $isFixed,
            'recurrenceGroupId' => $transaction->recorrencia_grupo_id ? (string) $transaction->recorrencia_grupo_id : null,
            'recurrenceInterval' => $recurrenceInterval,
            'recurrenceEveryMonths' => $recurrenceEveryMonths,
            'recurrenceEndsAt' => $recurrenceEndsAt,
            'tags' => $tags,
            'receiptUrl' => $transaction->receipt_path ? Storage::disk('public')->url($transaction->receipt_path) : null,
            'receiptName' => $transaction->receipt_original_name,
        ];
    }

    public function goal(Goal $goal): array
    {
        $due = $goal->due_date ? Carbon::parse($goal->due_date) : null;
        $dueLabel = $due ? sprintf('%s %s', $this->monthShort($due), $due->year) : '';

        return [
            'id' => (string) $goal->id,
            'title' => $goal->title,
            'due' => $dueLabel,
            'current' => (float) $goal->current_amount,
            'target' => (float) $goal->target_amount,
            'status' => $goal->status ?? 'on_track',
            'icon' => $goal->icon ?? 'home',
            'term' => $goal->term,
            'tags' => $goal->tags ?? [],
            'deposits' => $goal->deposits->sortByDesc('deposited_at')->values()->map(
                fn (GoalDeposit $deposit) => $this->goalDeposit($deposit)
            )->all(),
        ];
    }

    public function goalDeposit(GoalDeposit $deposit): array
    {
        $date = $deposit->deposited_at ? Carbon::parse($deposit->deposited_at) : Carbon::now();
        $subtitle = $date->isSameDay(Carbon::now())
            ? 'Hoje'
            : sprintf('%s %s', $date->format('d'), $this->monthShort($date));

        return [
            'id' => (string) $deposit->id,
            'title' => $deposit->title,
            'subtitle' => $deposit->subtitle ?: $subtitle,
            'amount' => (float) $deposit->amount,
            'createdAt' => $date->getTimestamp(),
        ];
    }

    public function account(Account $account): array
    {
        $svgPath = null;
        if ($account->institution) {
            // Map institution name to logo file path
            $logoMap = [
                'Nubank' => 'nubank-logo-svg.png',
                'Nu Pagamentos S.A' => 'nubank-logo-svg.png',
                'Banco Inter S.A' => 'Banco Inter S.A/inter.svg',
                'Banco Inter' => 'Banco Inter S.A/inter.svg',
                'Inter' => 'Banco Inter S.A/inter.svg',
                'Itaú' => 'Itaú/itau-oficial.png',
                'Itau' => 'Itaú/itau-oficial.png',
                'Banco Itaú' => 'Itaú/itau-oficial.png',
                'Itaú Unibanco' => 'Itaú/itau-oficial.png',
                'Bradesco' => 'Bradesco S.A/bradesco com nome.svg',
                'Bradesco S.A' => 'Bradesco S.A/bradesco com nome.svg',
                'Banco do Brasil' => 'Banco do Brasil S.A/banco-do-brasil-com-fundo.svg',
                'Banco do Brasil S.A' => 'Banco do Brasil S.A/banco-do-brasil-com-fundo.svg',
                'Caixa' => 'Caixa Econômica Federal/caixa-economica-federal-1.svg',
                'Caixa Econômica Federal' => 'Caixa Econômica Federal/caixa-economica-federal-1.svg',
                'Santander' => 'Banco Santander Brasil S.A/banco-santander-logo.svg',
                'Banco Santander Brasil S.A' => 'Banco Santander Brasil S.A/banco-santander-logo.svg',
                'Banco Santander' => 'Banco Santander Brasil S.A/banco-santander-logo.svg',
                'C6 Bank' => 'C6 Bank/c6-bank-logo-oficial-vector.png',
                'Banco C6 S.A' => 'C6 Bank/c6-bank-logo-oficial-vector.png',
                'PicPay' => 'PicPay/Logo-PicPay -nome .svg',
                'Neon' => 'Neon/header-logo-neon.svg',
                'Banco Safra S.A' => 'Banco Safra S.A/logo-safra-nome.svg',
                'Banco Votorantim' => 'Banco Votorantim/banco-bv-logo.svg',
                'Banco BTG Pacutal' => 'Banco BTG Pacutal/btg-pactual-nome .svg',
                'Banco Original S.A' => 'Banco Original S.A/banco-original-logo-branco-nome.svg',
                'Banco Sofisa' => 'Banco Sofisa/logo-banco-sofisa-verde.svg',
                'Banco Mercantil do Brasil S.A' => 'Banco Mercantil do Brasil S.A/banco-mercantil-novo-azul.svg',
            ];

            $svgPath = $logoMap[$account->institution] ?? null;
        }

        return [
            'id' => (string) $account->id,
            'name' => $account->name,
            'type' => $account->type,
            'icon' => $account->icon,
            'color' => $account->color,
            'card_brand' => $account->card_brand,
            'current_balance' => (float) $account->current_balance,
            'credit_limit' => $account->credit_limit ? (float) $account->credit_limit : null,
            'closing_day' => $account->closing_day,
            'due_day' => $account->due_day,
            'incluir_soma' => (bool) $account->incluir_soma,
            'institution' => $account->institution,
            'bank_account_type' => $account->bank_account_type,
            'svgPath' => $svgPath,
        ];
    }

    public function category(Category $category): array
    {
        return [
            'id' => (string) $category->id,
            'name' => $category->name,
            'type' => $category->type,
            'color' => $category->color,
            'icon' => $category->icon,
            'is_default' => (bool) $category->is_default,
        ];
    }

    public function tag(Tag $tag): array
    {
        return [
            'id' => (string) $tag->id,
            'nome' => $tag->nome,
            'cor' => $tag->cor,
        ];
    }

    private function monthShort(Carbon $date): string
    {
        $map = [
            1 => 'JAN',
            2 => 'FEV',
            3 => 'MAR',
            4 => 'ABR',
            5 => 'MAI',
            6 => 'JUN',
            7 => 'JUL',
            8 => 'AGO',
            9 => 'SET',
            10 => 'OUT',
            11 => 'NOV',
            12 => 'DEZ',
        ];

        return $map[(int) $date->month] ?? strtoupper($date->format('M'));
    }

    private function categoryKey(string $name): string
    {
        $value = mb_strtolower($name);
        if (str_contains($value, 'aliment')) return 'food';
        if (str_contains($value, 'mora') || str_contains($value, 'casa')) return 'home';
        if (str_contains($value, 'transp') || str_contains($value, 'uber') || str_contains($value, 'car')) return 'car';
        return 'other';
    }

    private function entryIcon(string $kind, string $categoryKey): string
    {
        if ($categoryKey === 'home') return 'home';
        if ($categoryKey === 'car') return 'car';
        if ($categoryKey === 'food') return 'cart';
        return $kind === 'income' ? 'money' : 'cart';
    }
}
