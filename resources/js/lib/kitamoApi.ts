const csrfToken = () => {
    const token = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
    return token ?? '';
};

const getCookie = (name: string) => {
    const value = `; ${document.cookie}`;
    const parts = value.split(`; ${name}=`);
    if (parts.length < 2) return '';
    return parts.pop()!.split(';').shift() ?? '';
};

const xsrfToken = () => {
    const raw = getCookie('XSRF-TOKEN');
    if (!raw) return '';
    try {
        return decodeURIComponent(raw);
    } catch {
        return raw;
    }
};

/**
 * Fetch a fresh CSRF token from the server
 */
const refreshCsrfToken = async (): Promise<{ csrf: string; xsrf: string }> => {
    let response = await fetch('/sanctum/csrf-cookie', { credentials: 'include' });
    if (!response.ok) {
        response = await fetch('/csrf-cookie', { credentials: 'include' });
    }
    if (!response.ok) throw new Error('Failed to refresh CSRF token');

    // /sanctum/csrf-cookie refreshes the XSRF-TOKEN cookie; meta token may stay the same.
    return { csrf: csrfToken(), xsrf: xsrfToken() };
};

export const requestJson = async <T>(url: string, options: RequestInit = {}): Promise<T> => {
    const makeRequest = async (token: { csrf: string; xsrf: string }) => {
        const requestedMethod = String(options.method ?? 'GET').toUpperCase();
        const shouldOverrideMethod = ['PATCH', 'PUT', 'DELETE'].includes(requestedMethod);
        // Important (Laravel): X-CSRF-TOKEN expects the raw session token, while X-XSRF-TOKEN
        // expects the (possibly encrypted) XSRF-TOKEN cookie value.
        const shouldSendCsrfHeader = !token.xsrf;

        const headers = {
            'Content-Type': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
            ...(shouldSendCsrfHeader ? { 'X-CSRF-TOKEN': token.csrf } : {}),
            ...(token.xsrf ? { 'X-XSRF-TOKEN': token.xsrf } : {}),
            ...(shouldOverrideMethod ? { 'X-HTTP-Method-Override': requestedMethod } : {}),
            ...(options.headers ?? {}),
        };

        return fetch(url, {
            credentials: 'include',
            ...options,
            method: shouldOverrideMethod ? 'POST' : (options.method ?? 'GET'),
            headers,
        });
    };

    const requestedMethod = String(options.method ?? 'GET').toUpperCase();
    const unsafeMethod = requestedMethod !== 'GET' && requestedMethod !== 'HEAD';
    let token = { csrf: csrfToken(), xsrf: xsrfToken() };
    if (unsafeMethod && !token.xsrf) {
        try {
            token = await refreshCsrfToken();
        } catch {
            // fallback: tenta com o meta-token mesmo
        }
    }

    let res = await makeRequest(token);

    // If we get a 419 (CSRF token mismatch), try to refresh the token and retry once
    if (res.status === 419) {
        try {
            const refreshed = await refreshCsrfToken();
            res = await makeRequest(refreshed);
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
    const makeRequest = async (token: { csrf: string; xsrf: string }) => {
        const requestedMethod = String(options.method ?? 'GET').toUpperCase();
        const shouldOverrideMethod = ['PATCH', 'PUT', 'DELETE'].includes(requestedMethod);
        const shouldSendCsrfHeader = !token.xsrf;

        const headers = new Headers(options.headers ?? {});
        headers.set('X-Requested-With', 'XMLHttpRequest');
        if (shouldSendCsrfHeader && token.csrf) {
            headers.set('X-CSRF-TOKEN', token.csrf);
        }
        if (token.xsrf) {
            headers.set('X-XSRF-TOKEN', token.xsrf);
        }
        if (shouldOverrideMethod) {
            headers.set('X-HTTP-Method-Override', requestedMethod);
        }

        let body = options.body;
        if (shouldOverrideMethod && body instanceof FormData) {
            const cloned = new FormData();
            for (const [key, value] of body.entries()) {
                cloned.append(key, value);
            }
            cloned.set('_method', requestedMethod);
            body = cloned;
        }

        return fetch(url, {
            credentials: 'include',
            ...options,
            method: shouldOverrideMethod ? 'POST' : (options.method ?? 'GET'),
            body,
            headers,
        });
    };

    const requestedMethod = String(options.method ?? 'GET').toUpperCase();
    const unsafeMethod = requestedMethod !== 'GET' && requestedMethod !== 'HEAD';
    let token = { csrf: csrfToken(), xsrf: xsrfToken() };
    if (unsafeMethod && !token.xsrf) {
        try {
            token = await refreshCsrfToken();
        } catch {
            // fallback
        }
    }

    let res = await makeRequest(token);

    if (res.status === 419) {
        try {
            const refreshed = await refreshCsrfToken();
            res = await makeRequest(refreshed);
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
