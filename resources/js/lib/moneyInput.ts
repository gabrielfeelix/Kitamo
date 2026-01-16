export const numberToMoneyInput = (value: number) => {
    const normalized = Number.isFinite(value) ? value : 0;
    const fixed = normalized.toFixed(2).replace('.', ',');
    const [wholeRaw, centsRaw] = fixed.split(',');
    const whole = (wholeRaw ?? '0').replace(/\B(?=(\d{3})+(?!\d))/g, '.');
    const cents = (centsRaw ?? '00').padEnd(2, '0').slice(0, 2);
    return `${whole},${cents}`;
};

export const moneyInputToNumber = (value: string) => {
    const clean = String(value ?? '')
        .trim()
        .replace(/\s+/g, '')
        .replace(/\.(?=\d{3}(\D|$))/g, ''); // remove separador de milhar

    if (!clean) return 0;

    const normalized = clean.includes(',') ? clean.replace(',', '.') : clean;
    const parsed = Number(normalized);
    return Number.isFinite(parsed) ? parsed : 0;
};

export const formatMoneyInput = (raw: string) => {
    const value = String(raw ?? '').trim();
    if (!value) return '';

    const only = value.replace(/[^\d,.\-]/g, '');
    const negative = only.startsWith('-');
    const unsigned = negative ? only.slice(1) : only;

    const hasComma = unsigned.includes(',');
    const hasDot = unsigned.includes('.');

    let wholePart = '';
    let centsPart = '';

    if (hasComma) {
        const [whole, cents = ''] = unsigned.split(',');
        wholePart = (whole ?? '').replace(/[^\d]/g, '');
        centsPart = cents.replace(/[^\d]/g, '').slice(0, 2);
    } else if (hasDot) {
        const lastDot = unsigned.lastIndexOf('.');
        const whole = unsigned.slice(0, lastDot);
        const cents = unsigned.slice(lastDot + 1);
        wholePart = whole.replace(/[^\d]/g, '');
        centsPart = cents.replace(/[^\d]/g, '').slice(0, 2);
    } else {
        wholePart = unsigned.replace(/[^\d]/g, '');
        centsPart = '';
    }

    const wholeNumber = (wholePart || '0').replace(/^0+(?=\d)/, '');
    const wholeWithThousands = wholeNumber.replace(/\B(?=(\d{3})+(?!\d))/g, '.');
    const cents = (centsPart || '00').padEnd(2, '0').slice(0, 2);

    return `${negative ? '-' : ''}${wholeWithThousands},${cents}`;
};

