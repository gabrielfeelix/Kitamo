import type { ImportPreviewRow } from './types';

export type OfxParseResult = {
    institution: string | null;
    account_id: string | null;
    rows: ImportPreviewRow[];
};

function pickTag(block: string, tag: string): string | null {
    const re = new RegExp(`<${tag}>([^<\\r\\n]+)`, 'i');
    const m = block.match(re);
    const captured = m?.[1];
    return captured ? captured.trim() : null;
}

function parseOfxDate(raw: string): string {
    const yyyy = raw.slice(0, 4);
    const mm = raw.slice(4, 6);
    const dd = raw.slice(6, 8);
    return `${yyyy}-${mm}-${dd}`;
}

export function parseOfx(text: string): OfxParseResult {
    const institution = pickTag(text, 'ORG');
    const account_id = pickTag(text, 'ACCTID');

    const rows: ImportPreviewRow[] = [];
    const stmtMatches = text.match(/<STMTTRN>[\s\S]*?<\/STMTTRN>/gi) ?? [];

    for (const block of stmtMatches) {
        const rawDate = pickTag(block, 'DTPOSTED') ?? '';
        const rawAmount = pickTag(block, 'TRNAMT') ?? '0';
        const memo = pickTag(block, 'MEMO') ?? pickTag(block, 'NAME') ?? '';

        const amount = parseFloat(rawAmount);
        if (!Number.isFinite(amount) || rawDate.length < 8) continue;

        rows.push({
            transaction_date: parseOfxDate(rawDate),
            description: memo.replace(/\s+/g, ' ').trim() || 'Lançamento',
            amount: Math.abs(amount),
            kind: amount >= 0 ? 'income' : 'expense',
            suggested_category_id: null,
        });
    }

    return { institution, account_id, rows };
}
