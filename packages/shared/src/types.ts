export type TransactionKind = 'expense' | 'income';
export type TransactionStatus = 'paid' | 'pending' | 'received';
export type AccountType = 'checking' | 'savings' | 'wallet' | 'credit_card' | 'investment';

export type Account = {
    id: number;
    name: string;
    type: string;
    institution: string | null;
    bank_account_type: 'corrente' | 'poupanca' | 'salario' | null;
    initial_balance: number;
    current_balance: number;
    credit_limit: number | null;
    closing_day: number | null;
    due_day: number | null;
    incluir_soma: boolean;
    is_primary: boolean;
    color: string | null;
    icon: string | null;
};

export type Category = {
    id: number;
    name: string;
    type: TransactionKind;
    color: string | null;
    icon: string | null;
    is_default: boolean;
    budget_limit?: number | null;
    spent_this_month?: number;
};

export type Transaction = {
    id: number;
    account_id: number;
    category_id: number | null;
    kind: TransactionKind;
    status: TransactionStatus;
    amount: number;
    description: string;
    notes: string | null;
    transaction_date: string;
    priority: boolean;
    is_recurring: boolean;
    is_parcelado: boolean;
    parcela_atual: number | null;
    parcela_total: number | null;
};

export type DashboardSummary = {
    total_balance: number;
    monthly_income: number;
    monthly_expenses: number;
    monthly_balance: number;
    spending_by_category: Array<{
        category_id: number | null;
        category_name: string;
        category_icon: string | null;
        category_color: string | null;
        total: number;
        percentage: number;
    }>;
    top_recent: Transaction[];
    upcoming_bills?: UpcomingBill[];
};

export type UpcomingBill = {
    id: string;
    description: string;
    amount: number;
    due_date: string;
    status: 'late' | 'soon' | 'ok';
    icon: string | null;
    color: string | null;
};

export type AuthUser = {
    id: number;
    name: string;
    email: string;
    avatar_path?: string | null;
    plan?: 'free' | 'plus';
    onboarding_completed_at?: string | null;
    has_2fa?: boolean;
    auth_provider?: 'email' | 'google';
};

export type LoginResponse = {
    token: string;
    user: AuthUser;
};

export type ImportPreviewRow = {
    transaction_date: string;
    description: string;
    amount: number;
    kind: TransactionKind;
    suggested_category_id: number | null;
};

export type AiTip = {
    title: string;
    body: string;
    severity: 'info' | 'warn' | 'good';
    action?: string;
};

export type Goal = {
    id: number;
    title: string;
    target_amount: number;
    current_amount: number;
    due_date: string | null;
    status: string;
    color: string | null;
    icon: string | null;
    deposits_count?: number;
};

export type GoalDeposit = {
    id: number;
    goal_id: number;
    amount: number;
    deposit_date: string;
    notes: string | null;
};

export type AppNotification = {
    id: string;
    titulo: string;
    mensagem: string;
    tipo: string;
    prioridade: string;
    lida: boolean;
    created_at: string;
    acao_primaria_tipo?: string | null;
    acao_primaria_url?: string | null;
};

export type ActiveSession = {
    id: number;
    name: string;
    last_used_at: string | null;
    is_current: boolean;
};
