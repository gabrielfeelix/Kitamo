/**
 * Converte uma data ISO "YYYY-MM-DD" para Date no fuso LOCAL.
 *
 * `new Date('2026-09-01')` interpreta a string como UTC meia-noite, então em
 * qualquer fuso negativo (Brasil incluso) a data volta um dia: transações do
 * dia 1º apareciam no mês anterior. Construir com os componentes separados
 * evita isso.
 */
export const parseISODate = (iso: string | null | undefined): Date | null => {
    const parts = String(iso ?? '')
        .trim()
        .split('-')
        .map((v) => Number(v));

    if (parts.length !== 3) return null;

    const [yyyy, mm, dd] = parts;
    if (!Number.isFinite(yyyy) || !Number.isFinite(mm) || !Number.isFinite(dd)) return null;

    const date = new Date(yyyy, mm - 1, dd);
    return Number.isFinite(date.getTime()) ? date : null;
};

/** Mesma conversão, mas no fim do dia — útil para comparações de intervalo. */
export const parseISODateEndOfDay = (iso: string | null | undefined): Date | null => {
    const date = parseISODate(iso);
    if (!date) return null;
    date.setHours(23, 59, 59, 999);
    return date;
};

/** Chave "YYYY-MM" a partir de um Date local. */
export const monthKeyOf = (date: Date): string =>
    `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
