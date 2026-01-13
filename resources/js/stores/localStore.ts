export type GoalStatus = 'on_track' | 'ahead' | 'late';
export type GoalIcon = 'home' | 'plane' | 'car';

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
    status: GoalStatus;
    icon: GoalIcon;
    deposits: GoalDeposit[];
    tags?: string[];
    term?: 'short' | 'long';
};

export type EntryStatus = 'paid' | 'pending' | 'received';
export type EntryKind = 'expense' | 'income';
export type EntryTag = 'Essencial' | 'Recorrente' | 'Urgente' | 'Supérfluo';
export type Entry = {
    id: string;
    dateLabel: string;
    dayLabel: string;
    title: string;
    subtitle: string;
    amount: number;
    kind: EntryKind;
    status: EntryStatus;
    priority?: boolean;
    installment?: string;
    icon: 'gym' | 'home' | 'cart' | 'money' | 'car';
    categoryLabel: string;
    categoryKey: 'food' | 'home' | 'car' | 'other';
    accountLabel: string;
    tags: EntryTag[];
};

type KitamoUser = { id?: number | string; email?: string } | null;

const getUserContext = (): KitamoUser => {
    if (typeof window === 'undefined') return null;
    return (window as any).__kitamoUser ?? null;
};

const getUserKey = (): string => {
    const user = getUserContext();
    if (user?.email) return String(user.email).toLowerCase();
    if (user?.id) return `id:${user.id}`;
    return 'anon';
};

const shouldSeedDemo = (): boolean => {
    const email = getUserContext()?.email?.toLowerCase() ?? '';
    return email.startsWith('gab.feelix');
};

const storageKey = (name: string) => `kitamo:${getUserKey()}:${name}`;

const readJson = <T>(name: string, fallback: T): T => {
    try {
        const raw = window.localStorage.getItem(storageKey(name));
        if (!raw) {
            const legacyKey = `kitamo:${name}`;
            const legacyRaw = window.localStorage.getItem(legacyKey);
            if (!legacyRaw) return fallback;
            window.localStorage.setItem(storageKey(name), legacyRaw);
            window.localStorage.removeItem(legacyKey);
            return JSON.parse(legacyRaw) as T;
        }
        return JSON.parse(raw) as T;
    } catch {
        return fallback;
    }
};

const writeJson = <T>(name: string, value: T) => {
    window.localStorage.setItem(storageKey(name), JSON.stringify(value));
};

const seedGoals = (): Goal[] => [
    {
        id: 'house',
        title: 'Casa própria',
        due: 'Dez 2026',
        current: 7000,
        target: 20000,
        status: 'on_track',
        icon: 'home',
        tags: ['Essencial', 'Longo Prazo'],
        term: 'long',
        deposits: [
            { id: 'd1', title: 'Depósito mensal', subtitle: 'Hoje', amount: 500, createdAt: Date.now() - 3600_000 },
            { id: 'd2', title: 'Economia extra', subtitle: '15 Jan', amount: 200, createdAt: Date.now() - 86400_000 * 3 },
        ],
    },
    {
        id: 'trip',
        title: 'Viagem Europa',
        due: 'Jun 2026',
        current: 3000,
        target: 5000,
        status: 'ahead',
        icon: 'plane',
        tags: ['Férias'],
        term: 'short',
        deposits: [
            { id: 'd3', title: 'Depósito mensal', subtitle: 'Hoje', amount: 500, createdAt: Date.now() - 3600_000 },
            { id: 'd4', title: 'Economia extra', subtitle: '15 Jan', amount: 200, createdAt: Date.now() - 86400_000 * 3 },
        ],
    },
    {
        id: 'car',
        title: 'Carro novo',
        due: 'Dez 2027',
        current: 4500,
        target: 30000,
        status: 'late',
        icon: 'car',
        tags: ['Urgente', 'Longo Prazo'],
        term: 'long',
        deposits: [
            { id: 'd5', title: 'Depósito mensal', subtitle: 'Hoje', amount: 500, createdAt: Date.now() - 3600_000 },
            { id: 'd6', title: 'Economia extra', subtitle: '15 Jan', amount: 200, createdAt: Date.now() - 86400_000 * 3 },
        ],
    },
];

export const getGoals = (): Goal[] => {
    const existing = readJson<Goal[]>('goals', []);
    if (existing.length) return existing;
    if (!shouldSeedDemo()) return [];
    const seeded = seedGoals();
    writeJson('goals', seeded);
    return seeded;
};

export const getGoal = (goalId: string): Goal | null => {
    const all = getGoals();
    return all.find((g) => g.id === goalId) ?? null;
};

export const upsertGoal = (goal: Goal) => {
    const all = getGoals();
    const idx = all.findIndex((g) => g.id === goal.id);
    if (idx >= 0) all[idx] = goal;
    else all.unshift(goal);
    writeJson('goals', all);
};

export const createGoal = (data: Omit<Goal, 'deposits'>) => {
    const goal: Goal = { ...data, deposits: [] };
    upsertGoal(goal);
    return goal;
};

export const addDepositToGoal = (goalId: string, deposit: Omit<GoalDeposit, 'id' | 'createdAt'>) => {
    const goal = getGoal(goalId);
    if (!goal) return;
    const newDeposit: GoalDeposit = {
        id: `dep-${Date.now()}`,
        createdAt: Date.now(),
        ...deposit,
    };
    const updated: Goal = {
        ...goal,
        current: goal.current + deposit.amount,
        deposits: [newDeposit, ...goal.deposits],
    };
    upsertGoal(updated);
};

const seedEntries = (): Entry[] => [
    {
        id: 'netflix',
        dateLabel: 'DIA 28 JAN',
        dayLabel: '28',
        title: 'Netflix',
        subtitle: 'Assinaturas',
        amount: 55.9,
        kind: 'expense',
        status: 'paid',
        icon: 'cart',
        categoryLabel: 'Assinaturas',
        categoryKey: 'other',
        accountLabel: 'Nubank',
        tags: ['Supérfluo', 'Recorrente'],
    },
    {
        id: 'rent',
        dateLabel: 'DIA 25 JAN',
        dayLabel: '25',
        title: 'Aluguel Apto',
        subtitle: 'Imobiliária',
        amount: 1200,
        kind: 'expense',
        status: 'pending',
        priority: true,
        icon: 'home',
        categoryLabel: 'Moradia',
        categoryKey: 'home',
        accountLabel: 'Banco Inter',
        tags: ['Essencial', 'Recorrente'],
    },
    {
        id: 'groceries',
        dateLabel: 'DIA 20 JAN',
        dayLabel: '20',
        title: 'Supermercado',
        subtitle: 'Parcela 1/3',
        amount: 250,
        kind: 'expense',
        status: 'pending',
        installment: 'Parcela 1/3',
        icon: 'cart',
        categoryLabel: 'Alimentação',
        categoryKey: 'food',
        accountLabel: 'Carteira',
        tags: ['Essencial'],
    },
    {
        id: 'salary',
        dateLabel: 'DIA 10 JAN',
        dayLabel: '10',
        title: 'Salário',
        subtitle: 'Empresa XYZ',
        amount: 3500,
        kind: 'income',
        status: 'received',
        icon: 'money',
        categoryLabel: 'Trabalho',
        categoryKey: 'other',
        accountLabel: 'Banco Inter',
        tags: [],
    },
];

export const getEntries = (): Entry[] => {
    const existing = readJson<Entry[]>('entries', []);
    if (existing.length) {
        let changed = false;
        const migrated = existing.map((entry) => {
            if (entry.id === 'netflix' && !entry.tags.includes('Supérfluo')) {
                changed = true;
                return { ...entry, tags: ['Supérfluo', ...entry.tags] as EntryTag[] };
            }
            return entry;
        });
        if (changed) writeJson('entries', migrated);
        return migrated;
    }
    if (!shouldSeedDemo()) return [];
    const seeded = seedEntries();
    writeJson('entries', seeded);
    return seeded;
};

export const setEntries = (entries: Entry[]) => writeJson('entries', entries);

export const upsertEntry = (entry: Entry) => {
    const all = getEntries();
    const idx = all.findIndex((e) => e.id === entry.id);
    if (idx >= 0) all[idx] = entry;
    else all.unshift(entry);
    setEntries(all);
};

export const deleteEntry = (id: string) => {
    const all = getEntries().filter((e) => e.id !== id);
    setEntries(all);
};
