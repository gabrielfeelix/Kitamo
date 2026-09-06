export type EntryTag = 'Essencial' | 'Urgente' | 'Supérfluo' | string;

export type UserTag = {
    id: string;
    nome: string;
    cor: string;
};

export type Entry = {
    id: string;
    dateLabel: string;
    dayLabel: string;
    transactionDate?: string;
    title: string;
    subtitle: string;
    amount: number;
    kind: 'expense' | 'income';
    status: 'paid' | 'pending' | 'received';
    priority?: boolean;
    installment?: string | null;
    icon: 'gym' | 'home' | 'cart' | 'money' | 'car' | string;
    categoryLabel: string;
    categoryKey: 'food' | 'home' | 'car' | 'other' | string;
    accountLabel: string;
    isRecurring?: boolean;
    isFixed?: boolean;
    recurrenceGroupId?: string | null;
    recurrenceInterval?: string | null;
    recurrenceEveryMonths?: number | null;
    recurrenceEndsAt?: string | null;
    tags: EntryTag[];
    receiptUrl?: string | null;
    receiptName?: string | null;
};

export type GoalDeposit = {
    id: string;
    title: string;
    subtitle: string;
    amount: number;
    createdAt: number;
};

export type Goal = {
    id: string;
    title: string;
    due: string;
    current: number;
    target: number;
    status: 'on_track' | 'ahead' | 'late' | string;
    icon: 'home' | 'plane' | 'car' | string;
    tags?: string[];
    term?: 'short' | 'long' | string | null;
    deposits: GoalDeposit[];
};

export type Account = {
    id: string;
    name: string;
    type: string;
    icon?: string | null;
    color?: string | null;
    card_brand?: string | null;
    initial_balance?: number;
    current_balance: number;
    credit_limit?: number | null;
    closing_day?: number | null;
    due_day?: number | null;
    incluir_soma?: boolean;
    is_primary?: boolean;
    institution?: string | null;
    bank_account_type?: 'corrente' | 'poupanca' | 'salario' | string | null;
};

export type CreditCard = {
    id: string;
    nome: string;
    bandeira: 'visa' | 'mastercard' | 'elo' | 'amex';
    limite: number;
    limite_usado: number;
    dia_fechamento: number;
    dia_vencimento: number;
    cor: string;
    is_primary?: boolean;
    created_at?: string;
    updated_at?: string;
};

export type CreditCardStatement = {
    id: string;
    total: number;
    data_fechamento: string;
    data_vencimento: string;
    transacoes: Entry[];
};

export type Category = {
    id: string;
    name: string;
    type: string;
    color?: string | null;
    icon?: string | null;
    is_default?: boolean;
};

export type AssetClass = 'caixinha' | 'cdb' | 'tesouro' | 'acao' | 'fii' | 'cripto' | 'outro';

export type Investment = {
    id: string;
    name: string;
    assetClass: AssetClass;
    institution: string | null;
    ticker: string | null;
    quantity: number | null;
    currentValue: number;
    /** Aportes menos resgates: o que o usuário efetivamente pôs de bolso. */
    totalAportado: number;
    /** Valor atual menos aportado. Pode ser negativo — prejuízo é informação. */
    rendimento: number;
    rentabilidade: number;
    priceSource: 'manual' | 'binance' | 'bcb';
    priceUpdatedAt: string | null;
    color: string | null;
    icon: string | null;
};

export type BootstrapData = {
    entries: Entry[];
    goals: Goal[];
    accounts: Account[];
    investments: Investment[];
    categories: Category[];
    tags: UserTag[];
};
