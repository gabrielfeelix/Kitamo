export const preventNonDigitKeydown = (event: KeyboardEvent) => {
    if (event.ctrlKey || event.metaKey || event.altKey) return;

    const allowed = [
        'Backspace',
        'Delete',
        'Tab',
        'Escape',
        'Enter',
        'ArrowLeft',
        'ArrowRight',
        'ArrowUp',
        'ArrowDown',
        'Home',
        'End',
    ];
    if (allowed.includes(event.key)) return;

    if (/^\d$/.test(event.key)) return;

    event.preventDefault();
};

export const preventNonMoneyKeydownAllowNegative = (event: KeyboardEvent) => {
    if (event.ctrlKey || event.metaKey || event.altKey) return;

    const allowed = [
        'Backspace',
        'Delete',
        'Tab',
        'Escape',
        'Enter',
        'ArrowLeft',
        'ArrowRight',
        'ArrowUp',
        'ArrowDown',
        'Home',
        'End',
    ];
    if (allowed.includes(event.key)) return;

    if (/^\d$/.test(event.key)) return;
    if (event.key === '-' || event.key === ',' || event.key === '.') return;

    event.preventDefault();
};
