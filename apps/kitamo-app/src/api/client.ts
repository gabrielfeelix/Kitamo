import { create, isAxiosError, type AxiosInstance } from 'axios';
import Constants from 'expo-constants';
import { Platform } from 'react-native';

import { tokenStorage } from '@/stores/tokenStorage';

function resolveBaseUrl(): string {
    const fromExtra = Constants.expoConfig?.extra?.apiUrl as string | undefined;
    if (fromExtra && fromExtra !== 'http://localhost:8000') {
        return fromExtra;
    }

    if (Platform.OS === 'android') {
        return 'http://10.0.2.2:8000';
    }

    return 'http://localhost:8000';
}

export const apiClient: AxiosInstance = create({
    baseURL: `${resolveBaseUrl()}/api/v1`,
    headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
    },
    timeout: 20000,
});

apiClient.interceptors.request.use(async (config) => {
    const token = await tokenStorage.get();
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
});

let onUnauthorized: (() => void) | null = null;

export function setUnauthorizedHandler(handler: () => void): void {
    onUnauthorized = handler;
}

apiClient.interceptors.response.use(
    (response) => response,
    (error) => {
        const url = error?.config?.url as string | undefined;
        if (error?.response?.status === 401 && onUnauthorized && url !== '/auth/logout') {
            onUnauthorized();
        }
        return Promise.reject(error);
    },
);

export function extractApiError(error: unknown): string {
    if (isAxiosError(error)) {
        const data = error.response?.data as { message?: string; errors?: Record<string, string[]> } | undefined;
        if (data?.errors) {
            const first = Object.values(data.errors)[0];
            if (first && first.length > 0) return first[0];
        }
        if (data?.message) return data.message;
        if (error.code === 'ECONNABORTED') return 'A requisição demorou demais.';
        if (!error.response) return 'Sem conexão com o servidor.';
        return `Erro ${error.response.status}.`;
    }
    if (error instanceof Error) return error.message;
    return 'Erro desconhecido.';
}
