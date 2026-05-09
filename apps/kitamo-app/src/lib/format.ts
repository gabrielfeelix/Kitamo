export function formatBRL(value: number, withSign = false): string {
    const sign = value < 0 ? '-' : withSign && value > 0 ? '+' : '';
    const abs = Math.abs(value);
    const formatted = abs.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    return `${sign}R$ ${formatted}`;
}

export function formatBRLNumber(value: number): { whole: string; cents: string } {
    const abs = Math.abs(value);
    const formatted = abs.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    const [whole, cents = '00'] = formatted.split(',');
    return { whole, cents };
}

export function parseBRLInput(text: string): number {
    const onlyDigits = text.replace(/[^0-9]/g, '');
    if (!onlyDigits) return 0;
    return parseInt(onlyDigits, 10) / 100;
}

export function formatBRLInput(value: number): string {
    return value.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

export function todayISO(): string {
    return new Date().toISOString().slice(0, 10);
}

export function monthRange(reference: Date = new Date()): { from: string; to: string; label: string } {
    const y = reference.getFullYear();
    const m = reference.getMonth();
    const from = new Date(y, m, 1).toISOString().slice(0, 10);
    const to = new Date(y, m + 1, 0).toISOString().slice(0, 10);
    const monthName = reference.toLocaleDateString('pt-BR', { month: 'long', year: 'numeric' });
    return { from, to, label: monthName.charAt(0).toUpperCase() + monthName.slice(1) };
}

export function greetingByHour(hour: number = new Date().getHours()): string {
    if (hour < 6) return 'Boa madrugada';
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
}
