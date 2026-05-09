import type { AuthUser } from '@kitamo/shared';
import { create } from 'zustand';

import { apiClient } from '@/api/client';
import { tokenStorage } from '@/stores/tokenStorage';

type AuthState = {
    user: AuthUser | null;
    token: string | null;
    bootstrapped: boolean;
    setSession: (token: string, user: AuthUser) => Promise<void>;
    bootstrap: () => Promise<void>;
    logout: () => Promise<void>;
};

export const useAuth = create<AuthState>((set) => ({
    user: null,
    token: null,
    bootstrapped: false,

    async setSession(token, user) {
        await tokenStorage.set(token);
        set({ token, user, bootstrapped: true });
    },

    async bootstrap() {
        const token = await tokenStorage.get();
        if (!token) {
            set({ bootstrapped: true, token: null, user: null });
            return;
        }
        try {
            const { data } = await apiClient.get<{ user: AuthUser }>('/auth/me');
            set({ token, user: data.user, bootstrapped: true });
        } catch {
            await tokenStorage.clear();
            set({ token: null, user: null, bootstrapped: true });
        }
    },

    async logout() {
        try {
            await apiClient.post('/auth/logout');
        } catch {
            // ignore network failures on logout
        }
        await tokenStorage.clear();
        set({ token: null, user: null });
    },
}));
