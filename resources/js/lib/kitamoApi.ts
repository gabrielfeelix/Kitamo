const csrfToken = () => {
    const token = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
    return token ?? '';
};

/**
 * Fetch a fresh CSRF token from the server
 */
const refreshCsrfToken = async (): Promise<string> => {
    const response = await fetch('/sanctum/csrf-cookie', {
        credentials: 'same-origin',
    });

    if (!response.ok) {
        throw new Error('Failed to refresh CSRF token');
    }

    // The new token will be in the meta tag after the request
    return csrfToken();
};

export const requestJson = async <T>(url: string, options: RequestInit = {}): Promise<T> => {
    const makeRequest = async (token: string) => {
        return fetch(url, {
            headers: {
                'Content-Type': 'application/json',
                'X-Requested-With': 'XMLHttpRequest',
                'X-CSRF-TOKEN': token,
                ...(options.headers ?? {}),
            },
            credentials: 'same-origin',
            ...options,
        });
    };

    let res = await makeRequest(csrfToken());

    // If we get a 419 (CSRF token mismatch), try to refresh the token and retry once
    if (res.status === 419) {
        try {
            const newToken = await refreshCsrfToken();
            res = await makeRequest(newToken);
        } catch (error) {
            // If token refresh fails, reload the page to get a fresh session
            window.location.reload();
            throw new Error('Session expired. Reloading page...');
        }
    }

    if (!res.ok) {
        const errorText = await res.text();
        throw new Error(errorText || `Request failed: ${res.status}`);
    }

    return (await res.json()) as T;
};

export const requestFormData = async <T>(url: string, options: RequestInit = {}): Promise<T> => {
    const makeRequest = async (token: string) => {
        const headers = new Headers(options.headers ?? {});
        headers.set('X-Requested-With', 'XMLHttpRequest');
        headers.set('X-CSRF-TOKEN', token);

        return fetch(url, {
            credentials: 'same-origin',
            ...options,
            headers,
        });
    };

    let res = await makeRequest(csrfToken());

    if (res.status === 419) {
        try {
            const newToken = await refreshCsrfToken();
            res = await makeRequest(newToken);
        } catch {
            window.location.reload();
            throw new Error('Session expired. Reloading page...');
        }
    }

    if (!res.ok) {
        const errorText = await res.text();
        throw new Error(errorText || `Request failed: ${res.status}`);
    }

    return (await res.json()) as T;
};
