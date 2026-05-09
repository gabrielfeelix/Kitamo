import type { ImportPreviewRow, TransactionKind } from './types';

export type CsvParseResult = {
    rows: ImportPreviewRow[];
    skipped: number;
};

function splitCsvLine(line: string, sep: string): string[] {
    const out: string[] = [];
    let cur = '';
    let inQuotes = false;
    for (let i = 0; i < line.length; i++) {
        const ch = line[i];
        if (ch === '"') {
            if (inQuotes && line[i + 1] === '"') {
                cur += '"';
                i++;
            } else {
                inQuotes = !inQuotes;
            }
        } else if (ch === sep && !inQuotes) {
            out.push(cur);
            cur = '';
        } else {
            cur += ch;
        }
    }
    out.push(cur);
    return out.map((s) => s.trim().replace(/^"|"$/g, ''));
}

function detectSeparator(headerLine: string): string {
    const candidates = [',', ';', '\t', '|'];
    let best = ',';
    let bestCount = 0;
    for (const c of candidates) {
        const count = (headerLine.match(new RegExp(`\\${c}`, 'g')) ?? []).length;
        if (count > bestCount) {
            best = c;
            bestCount = count;
        }
    }
    return best;
}

function normalizeHeader(h: string): string {
    return h
        .toLowerCase()
        .normalize('NFD')
        .replace(/[̀-ͯ]/g, '')
        .replace(/[^a-z0-9]/g, '');
}

function parseCsvDate(raw: string): string | null {
    const trimmed = raw.trim();
    let m = trimmed.match(/^(\d{2})\/(\d{2})\/(\d{4})$/);
    if (m) return `${m[3]}-${m[2]}-${m[1]}`;
    m = trimmed.match(/^(\d{4})-(\d{2})-(\d{2})$/);
    if (m) return trimmed;
    m = trimmed.match(/^(\d{2})-(\d{2})-(\d{4})$/);
    if (m) return `${m[3]}-${m[2]}-${m[1]}`;
    return null;
}

function parseCsvAmount(raw: string): number {
    const cleaned = raw
        .replace(/[^\d,.\-]/g, '')
        .replace(/\.(?=\d{3}(\D|$))/g, '')
        .replace(',', '.');
    const value = parseFloat(cleaned);
    return Number.isFinite(value) ? value : NaN;
}

const DATE_HEADERS = ['data', 'date', 'datapagamento', 'datatransacao', 'datalancamento'];
const DESC_HEADERS = ['descricao', 'description', 'historico', 'descrição', 'lancamento', 'memo', 'titulo'];
const AMOUNT_HEADERS = ['valor', 'amount', 'montante', 'preco'];
const KIND_HEADERS = ['tipo', 'type', 'natureza'];

export function parseCsv(text: string): CsvParseResult {
    const normalized = text.replace(/^﻿/, '');
    const lines = normalized.split(/\r?\n/).filter((l) => l.trim().length > 0);
    if (lines.length < 2) return { rows: [], skipped: 0 };

    const headerLine = lines[0] ?? '';
    const sep = detectSeparator(headerLine);
    const headers = splitCsvLine(headerLine, sep).map(normalizeHeader);

    const dateIdx = headers.findIndex((h) => DATE_HEADERS.includes(h));
    const descIdx = headers.findIndex((h) => DESC_HEADERS.includes(h));
    const amountIdx = headers.findIndex((h) => AMOUNT_HEADERS.includes(h));
    const kindIdx = headers.findIndex((h) => KIND_HEADERS.includes(h));

    if (dateIdx === -1 || amountIdx === -1) {
        return { rows: [], skipped: lines.length - 1 };
    }

    const rows: ImportPreviewRow[] = [];
    let skipped = 0;

    for (let i = 1; i < lines.length; i++) {
        const line = lines[i];
        if (line === undefined) continue;
        const cols = splitCsvLine(line, sep);
        const dateRaw = cols[dateIdx] ?? '';
        const amountRaw = cols[amountIdx] ?? '';
        const descRaw = descIdx !== -1 ? (cols[descIdx] ?? '') : '';
        const kindRaw = kindIdx !== -1 ? (cols[kindIdx]?.toLowerCase() ?? '') : '';

        const date = parseCsvDate(dateRaw);
        const amount = parseCsvAmount(amountRaw);

        if (!date || !Number.isFinite(amount)) {
            skipped++;
            continue;
        }

        let kind: TransactionKind;
        if (kindRaw.includes('cred') || kindRaw.includes('rec') || kindRaw.includes('income')) {
            kind = 'income';
        } else if (kindRaw.includes('deb') || kindRaw.includes('exp') || kindRaw.includes('saida')) {
            kind = 'expense';
        } else {
            kind = amount >= 0 ? 'income' : 'expense';
        }

        rows.push({
            transaction_date: date,
            description: descRaw.trim() || 'Lançamento',
            amount: Math.abs(amount),
            kind,
            suggested_category_id: null,
        });
    }

    return { rows, skipped };
}
