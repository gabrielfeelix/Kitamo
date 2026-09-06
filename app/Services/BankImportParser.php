<?php

namespace App\Services;

use Illuminate\Support\Str;

class BankImportParser
{
    public function parseOfx(string $text): array
    {
        $institution = $this->pickTag($text, 'ORG');
        $accountId = $this->pickTag($text, 'ACCTID');

        $rows = [];
        if (preg_match_all('/<STMTTRN>(.*?)<\/STMTTRN>/is', $text, $blocks)) {
            foreach ($blocks[1] as $block) {
                $rawDate = $this->pickTag($block, 'DTPOSTED');
                $rawAmount = $this->pickTag($block, 'TRNAMT');
                $memo = $this->pickTag($block, 'MEMO') ?? $this->pickTag($block, 'NAME');

                if ($rawDate === null || $rawAmount === null || strlen($rawDate) < 8) {
                    continue;
                }

                $amount = (float) $rawAmount;
                if (! is_finite($amount)) {
                    continue;
                }

                $rows[] = [
                    'transaction_date' => substr($rawDate, 0, 4) . '-' . substr($rawDate, 4, 2) . '-' . substr($rawDate, 6, 2),
                    'description' => trim(preg_replace('/\s+/', ' ', $memo ?? 'Lançamento')),
                    'amount' => abs($amount),
                    'kind' => $amount >= 0 ? 'income' : 'expense',
                    'suggested_category_id' => null,
                    // Identificador único do lançamento no padrão OFX. É o que
                    // permite reimportar o mesmo extrato sem duplicar nem
                    // colapsar duas compras legitimamente iguais no mesmo dia.
                    'origem_id' => $this->pickTag($block, 'FITID'),
                ];
            }
        }

        return [
            'institution' => $institution,
            'account_id' => $accountId,
            'rows' => $rows,
        ];
    }

    public function parseCsv(string $text): array
    {
        $text = preg_replace('/^\xEF\xBB\xBF/', '', $text);
        $lines = preg_split('/\r?\n/', $text);
        $lines = array_values(array_filter($lines, fn ($l) => trim($l) !== ''));

        if (count($lines) < 2) {
            return ['institution' => null, 'account_id' => null, 'rows' => []];
        }

        $sep = $this->detectSeparator($lines[0]);
        $headers = array_map([$this, 'normalizeHeader'], $this->splitCsv($lines[0], $sep));

        $dateIdx = $this->findHeader($headers, ['data', 'date', 'datapagamento', 'datatransacao', 'datalancamento']);
        $descIdx = $this->findHeader($headers, ['descricao', 'description', 'historico', 'lancamento', 'memo', 'titulo']);
        $amountIdx = $this->findHeader($headers, ['valor', 'amount', 'montante', 'preco']);
        $kindIdx = $this->findHeader($headers, ['tipo', 'type', 'natureza']);

        if ($dateIdx === -1 || $amountIdx === -1) {
            return ['institution' => null, 'account_id' => null, 'rows' => []];
        }

        $rows = [];
        for ($i = 1; $i < count($lines); $i++) {
            $cols = $this->splitCsv($lines[$i], $sep);
            $dateRaw = $cols[$dateIdx] ?? '';
            $amountRaw = $cols[$amountIdx] ?? '';
            $descRaw = $descIdx !== -1 ? ($cols[$descIdx] ?? '') : '';
            $kindRaw = $kindIdx !== -1 ? Str::lower($cols[$kindIdx] ?? '') : '';

            $date = $this->parseCsvDate($dateRaw);
            $amount = $this->parseCsvAmount($amountRaw);

            if ($date === null || ! is_finite($amount)) {
                continue;
            }

            if (Str::contains($kindRaw, ['cred', 'rec', 'income'])) {
                $kind = 'income';
            } elseif (Str::contains($kindRaw, ['deb', 'exp', 'saida'])) {
                $kind = 'expense';
            } else {
                $kind = $amount >= 0 ? 'income' : 'expense';
            }

            $rows[] = [
                'transaction_date' => $date,
                'description' => trim($descRaw) !== '' ? trim($descRaw) : 'Lançamento',
                'amount' => abs($amount),
                'kind' => $kind,
                'suggested_category_id' => null,
                // CSV não tem identificador padronizado. O commit cai no
                // fallback por conteúdo, que considera a ordem de ocorrência
                // para não colapsar duplicatas legítimas.
                'origem_id' => null,
            ];
        }

        return ['institution' => null, 'account_id' => null, 'rows' => $rows];
    }

    private function pickTag(string $block, string $tag): ?string
    {
        if (preg_match('/<' . $tag . '>([^<\r\n]+)/i', $block, $m)) {
            return trim($m[1]);
        }
        return null;
    }

    private function splitCsv(string $line, string $sep): array
    {
        $out = [];
        $cur = '';
        $inQuotes = false;
        for ($i = 0; $i < strlen($line); $i++) {
            $ch = $line[$i];
            if ($ch === '"') {
                if ($inQuotes && ($line[$i + 1] ?? '') === '"') {
                    $cur .= '"';
                    $i++;
                } else {
                    $inQuotes = ! $inQuotes;
                }
            } elseif ($ch === $sep && ! $inQuotes) {
                $out[] = $cur;
                $cur = '';
            } else {
                $cur .= $ch;
            }
        }
        $out[] = $cur;
        return array_map(fn ($s) => trim($s, " \"\r\n"), $out);
    }

    private function detectSeparator(string $header): string
    {
        $best = ',';
        $bestCount = 0;
        foreach ([',', ';', "\t", '|'] as $sep) {
            $count = substr_count($header, $sep);
            if ($count > $bestCount) {
                $best = $sep;
                $bestCount = $count;
            }
        }
        return $best;
    }

    private function normalizeHeader(string $h): string
    {
        $h = Str::lower($h);
        $h = Str::ascii($h);
        return preg_replace('/[^a-z0-9]/', '', $h);
    }

    private function findHeader(array $headers, array $candidates): int
    {
        foreach ($headers as $i => $h) {
            if (in_array($h, $candidates, true)) {
                return $i;
            }
        }
        return -1;
    }

    private function parseCsvDate(string $raw): ?string
    {
        $trimmed = trim($raw);
        if (preg_match('/^(\d{2})\/(\d{2})\/(\d{4})$/', $trimmed, $m)) {
            return "{$m[3]}-{$m[2]}-{$m[1]}";
        }
        if (preg_match('/^(\d{4})-(\d{2})-(\d{2})$/', $trimmed)) {
            return $trimmed;
        }
        if (preg_match('/^(\d{2})-(\d{2})-(\d{4})$/', $trimmed, $m)) {
            return "{$m[3]}-{$m[2]}-{$m[1]}";
        }
        return null;
    }

    private function parseCsvAmount(string $raw): float
    {
        $cleaned = preg_replace('/[^\d,.\-]/', '', $raw);
        $cleaned = preg_replace('/\.(?=\d{3}(\D|$))/', '', $cleaned);
        $cleaned = str_replace(',', '.', $cleaned);
        return is_numeric($cleaned) ? (float) $cleaned : NAN;
    }
}
