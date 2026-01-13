const csrfToken = () => {
    const token = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
    return token ?? '';
};

export const requestJson = async <T>(url: string, options: RequestInit = {}): Promise<T> => {
    const res = await fetch(url, {
        headers: {
            'Content-Type': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-TOKEN': csrfToken(),
            ...(options.headers ?? {}),
        },
        credentials: 'same-origin',
        ...options,
    });

    if (!res.ok) {
        const errorText = await res.text();
        throw new Error(errorText || `Request failed: ${res.status}`);
    }

    return (await res.json()) as T;
};
