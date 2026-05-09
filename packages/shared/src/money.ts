export function formatBRL(value: number): string {
    return new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL',
    }).format(value);
}

export function formatShortDate(date: string): string {
    const [year, month, day] = date.split('-').map(Number);
    if (!year || !month || !day) return date;

    return new Intl.DateTimeFormat('pt-BR', {
        day: '2-digit',
        month: '2-digit',
    }).format(new Date(year, month - 1, day));
}

export function formatFullDate(date: string): string {
    const [year, month, day] = date.split('-').map(Number);
    if (!year || !month || !day) return date;

    return new Intl.DateTimeFormat('pt-BR', {
        day: '2-digit',
        month: 'long',
        year: 'numeric',
    }).format(new Date(year, month - 1, day));
}

export function todayLocalDate(): string {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');

    return `${year}-${month}-${day}`;
}

export function formatBRLCompact(value: number): string {
    const abs = Math.abs(value);
    if (abs >= 1_000_000) return `R$ ${(value / 1_000_000).toFixed(1)}M`;
    if (abs >= 1_000) return `R$ ${(value / 1_000).toFixed(1)}K`;
    return formatBRL(value);
}

export function parseBRLInput(raw: string): number {
    const onlyNumber = raw.replace(/[^\d,.-]/g, '');
    const hasComma = onlyNumber.includes(',');
    const hasDot = onlyNumber.includes('.');
    const cleaned = hasComma
        ? onlyNumber.replace(/\./g, '').replace(',', '.')
        : hasDot
            ? onlyNumber
            : onlyNumber;
    const value = parseFloat(cleaned);
    return Number.isFinite(value) ? value : 0;
}

export function centsToReais(cents: number): number {
    return cents / 100;
}

export function reaisToCents(reais: number): number {
    return Math.round(reais * 100);
}
