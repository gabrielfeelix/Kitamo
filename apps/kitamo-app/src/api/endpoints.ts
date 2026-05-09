import type {
    Account,
    ActiveSession,
    AiTip,
    AppNotification,
    AuthUser,
    Category,
    DashboardSummary,
    Goal,
    GoalDeposit,
    ImportPreviewRow,
    LoginResponse,
    Transaction,
    TransactionKind,
} from '@kitamo/shared';

import { apiClient } from './client';

export const authApi = {
    async login(email: string, password: string): Promise<LoginResponse> {
        const { data } = await apiClient.post<LoginResponse>('/auth/login', { email, password });
        return data;
    },
    async register(name: string, email: string, password: string): Promise<LoginResponse> {
        const { data } = await apiClient.post<LoginResponse>('/auth/register', { name, email, password });
        return data;
    },
    async google(idToken: string): Promise<LoginResponse> {
        const { data } = await apiClient.post<LoginResponse>('/auth/google', { id_token: idToken });
        return data;
    },
    async me(): Promise<AuthUser> {
        const { data } = await apiClient.get<{ user: AuthUser }>('/auth/me');
        return data.user;
    },
    async completeOnboarding(payload: { entry_mode: 'manual' | 'connect' | 'skip' }): Promise<AuthUser> {
        const { data } = await apiClient.post<{ user: AuthUser }>('/auth/onboarding', payload);
        return data.user;
    },
    async changePassword(payload: { current_password: string; new_password: string }): Promise<void> {
        await apiClient.put('/auth/password', payload);
    },
    async sessions(): Promise<ActiveSession[]> {
        const { data } = await apiClient.get<{ sessions: ActiveSession[] }>('/auth/sessions');
        return data.sessions;
    },
    async revokeAllSessions(): Promise<void> {
        await apiClient.post('/auth/sessions/revoke-all');
    },
};

export const dashboardApi = {
    async summary(): Promise<DashboardSummary> {
        const { data } = await apiClient.get<DashboardSummary>('/dashboard/summary');
        return data;
    },
};

export const accountsApi = {
    async list(): Promise<Account[]> {
        const { data } = await apiClient.get<{ accounts: Account[] }>('/accounts');
        return data.accounts;
    },
    async create(payload: Partial<Account> & { name: string; type: string }): Promise<Account> {
        const { data } = await apiClient.post<{ account: Account }>('/accounts', payload);
        return data.account;
    },
    async update(id: number, payload: Partial<Account>): Promise<Account> {
        const { data } = await apiClient.put<{ account: Account }>(`/accounts/${id}`, payload);
        return data.account;
    },
    async remove(id: number): Promise<void> {
        await apiClient.delete(`/accounts/${id}`);
    },
};

export const categoriesApi = {
    async list(): Promise<Category[]> {
        const { data } = await apiClient.get<{ categories: Category[] }>('/categories');
        return data.categories;
    },
    async create(payload: { name: string; type: TransactionKind; color?: string; icon?: string; budget_limit?: number | null }): Promise<Category> {
        const { data } = await apiClient.post<{ category: Category }>('/categories', payload);
        return data.category;
    },
    async update(id: number, payload: Partial<Pick<Category, 'name' | 'color' | 'icon' | 'budget_limit'>>): Promise<Category> {
        const { data } = await apiClient.put<{ category: Category }>(`/categories/${id}`, payload);
        return data.category;
    },
    async remove(id: number): Promise<void> {
        await apiClient.delete(`/categories/${id}`);
    },
};

export type CreateTransactionPayload = {
    account_id: number;
    category_id: number | null;
    kind: TransactionKind;
    amount: number;
    description: string;
    transaction_date: string;
    notes?: string;
    priority?: boolean;
};

export const transactionsApi = {
    async list(params: { kind?: TransactionKind; from?: string; to?: string; limit?: number } = {}): Promise<Transaction[]> {
        const { data } = await apiClient.get<{ transactions: Transaction[] }>('/transactions', { params });
        return data.transactions;
    },
    async show(id: number): Promise<Transaction> {
        const { data } = await apiClient.get<{ transaction: Transaction }>(`/transactions/${id}`);
        return data.transaction;
    },
    async create(payload: CreateTransactionPayload): Promise<Transaction> {
        const { data } = await apiClient.post<{ transaction: Transaction }>('/transactions', payload);
        return data.transaction;
    },
    async update(id: number, payload: Partial<CreateTransactionPayload>): Promise<Transaction> {
        const { data } = await apiClient.put<{ transaction: Transaction }>(`/transactions/${id}`, payload);
        return data.transaction;
    },
    async remove(id: number): Promise<void> {
        await apiClient.delete(`/transactions/${id}`);
    },
};

export const transfersApi = {
    async create(payload: { from_account_id: number; to_account_id: number; amount: number; transaction_date: string; notes?: string }): Promise<{ ok: true }> {
        const { data } = await apiClient.post<{ ok: true }>('/transfers', payload);
        return data;
    },
};

export const goalsApi = {
    async list(): Promise<Goal[]> {
        const { data } = await apiClient.get<{ goals: Goal[] }>('/goals');
        return data.goals;
    },
    async create(payload: { title: string; target_amount: number; due_date?: string; color?: string; icon?: string }): Promise<Goal> {
        const { data } = await apiClient.post<{ goal: Goal }>('/goals', payload);
        return data.goal;
    },
    async deposit(id: number, payload: { amount: number; notes?: string; deposit_date?: string }): Promise<GoalDeposit> {
        const { data } = await apiClient.post<{ deposit: GoalDeposit }>(`/goals/${id}/deposits`, payload);
        return data.deposit;
    },
    async remove(id: number): Promise<void> {
        await apiClient.delete(`/goals/${id}`);
    },
};

export const notificationsApi = {
    async list(): Promise<AppNotification[]> {
        const { data } = await apiClient.get<{ notifications: AppNotification[] }>('/notifications');
        return data.notifications;
    },
    async markRead(id: string): Promise<void> {
        await apiClient.patch(`/notifications/${id}/read`);
    },
    async markAllRead(): Promise<void> {
        await apiClient.post('/notifications/read-all');
    },
    async unreadCount(): Promise<number> {
        const { data } = await apiClient.get<{ count: number }>('/notifications/unread-count');
        return data.count;
    },
};

export type ImportPreview = {
    institution: string | null;
    account_id: string | null;
    rows: ImportPreviewRow[];
};

export const importApi = {
    async preview(fileUri: string, fileName: string, mimeType: string): Promise<ImportPreview> {
        const form = new FormData();
        form.append('file', {
            uri: fileUri,
            name: fileName,
            type: mimeType,
        } as unknown as Blob);
        const { data } = await apiClient.post<ImportPreview>('/import/preview', form, {
            headers: { 'Content-Type': 'multipart/form-data' },
        });
        return data;
    },
    async commit(accountId: number, rows: ImportPreviewRow[]): Promise<{ created: number; skipped: number }> {
        const { data } = await apiClient.post<{ created: number; skipped: number }>('/import/commit', {
            account_id: accountId,
            rows,
        });
        return data;
    },
};

export const aiApi = {
    async tips(): Promise<{ tips: AiTip[]; fallback?: boolean }> {
        const { data } = await apiClient.post<{ tips: AiTip[]; fallback?: boolean }>('/ai/tips');
        return data;
    },
    async chat(message: string): Promise<{ reply: string; fallback?: boolean }> {
        const { data } = await apiClient.post<{ reply: string; fallback?: boolean }>('/ai/chat', { message });
        return data;
    },
};
