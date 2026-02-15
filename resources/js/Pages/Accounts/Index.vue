<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue';
import { Link, router, usePage } from '@inertiajs/vue3';
import { requestFormData, requestJson } from '@/lib/kitamoApi';
import { buildTransactionFormData, buildTransactionRequest, executeTransfer, hasTransactionReceipt } from '@/lib/transactions';
import type { BootstrapData, Entry } from '@/types/kitamo';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import TransactionModal, { type TransactionModalPayload } from '@/Components/TransactionModal.vue';
import MobileToast from '@/Components/MobileToast.vue';
import TransactionDetailModal, { type TransactionDetail } from '@/Components/TransactionDetailModal.vue';
import TransactionFilterModal, { type TransactionFilterState } from '@/Components/TransactionFilterModal.vue';
import ImportInvoiceModal from '@/Components/ImportInvoiceModal.vue';
import ExportReportModal from '@/Components/ExportReportModal.vue';
import MonthNavigator from '@/Components/MonthNavigator.vue';
import CategoryIcon from '@/Components/CategoryIcon.vue';
import { useIsMobile } from '@/composables/useIsMobile';

import type { AccountOption } from '@/Components/AccountPickerSheet.vue';
import type { CategoryOption } from '@/Components/CategoryPickerSheet.vue';

const page = usePage();
const userName = computed(() => page.props.auth?.user?.name ?? 'Gabriel');
const bootstrap = computed(
    () => (page.props.bootstrap ?? { entries: [], goals: [], accounts: [], categories: [], tags: [] }) as BootstrapData,
);
const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() =>
    isMobile.value
        ? { showNav: true }
        : {
              title: 'Transações',
              subtitle: monthLabel.value,
              searchPlaceholder: 'Buscar transação…',
              newActionLabel: 'Nova Transação',
          },
);

type FilterKind = 'all' | 'paid' | 'to_pay';

type MonthMode = 'current' | 'past' | 'future';

const activeMonth = ref(new Date());
const months = computed(() => {
    const now = new Date();
    const items: Array<{ key: string; label: string; date: Date }> = [];
    for (let i = -120; i <= 120; i += 1) {
        const d = new Date(now.getFullYear(), now.getMonth() + i, 1);
        const label = new Intl.DateTimeFormat('pt-BR', { month: 'short' }).format(d).replace('.', '').toUpperCase();
        items.push({ key: `${d.getFullYear()}-${d.getMonth()}`, label, date: d });
    }
    return items;
});
const currentMonthKey = `${new Date().getFullYear()}-${new Date().getMonth()}`;
const selectedMonthKey = ref(months.value.find((m) => m.key === currentMonthKey)?.key ?? months.value[0]?.key ?? '');
const selectedMonth = computed(() => months.value.find((m) => m.key === selectedMonthKey.value) ?? months.value[0]);
const monthLabel = computed(() => {
    if (!selectedMonth.value) return '';
    const month = new Intl.DateTimeFormat('pt-BR', { month: 'long' }).format(selectedMonth.value.date);
    const year = selectedMonth.value.date.getFullYear();
    return `${month.charAt(0).toUpperCase() + month.slice(1)} ${year}`;
});

const filter = ref<FilterKind>('all');
const entryKindFilter = ref<'all' | 'income' | 'expense'>('all');
const accountFilter = ref<'all' | string>('all');

const entries = ref<Entry[]>(bootstrap.value.entries ?? []);
const normalizeCategoryName = (value: string) =>
    String(value ?? '')
        .trim()
        .toLowerCase()
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '');

const categoriesByKey = computed(
    () =>
        new Map(
            (bootstrap.value.categories ?? []).map((c) => [`${c.type}|${normalizeCategoryName(c.name)}`, c] as const),
        ),
);

const categoryForEntry = (entry: Entry) => {
    const type = entry.kind === 'income' ? 'income' : 'expense';
    const normalized = normalizeCategoryName(entry.categoryLabel ?? '');
    return categoriesByKey.value.get(`${type}|${normalized}`) ?? categoriesByKey.value.get(`expense|${normalized}`) ?? null;
};
const pickerCategories = computed<CategoryOption[]>(() => {
    const unique = new Map<string, CategoryOption>();
    for (const c of bootstrap.value.categories ?? []) {
        const kind = c.type === 'income' ? 'income' : c.type === 'expense' ? 'expense' : undefined;
        const current = unique.get(c.name);
        const mergedKind = current?.kind && kind && current.kind !== kind ? undefined : (current?.kind ?? kind);
        unique.set(c.name, {
            key: c.name,
            label: c.name,
            icon: (c.icon ?? 'other') as any,
            tone: 'slate',
            customColor: c.color ?? undefined,
            kind: mergedKind,
        });
    }
    return Array.from(unique.values());
});

const pickerAccounts = computed<AccountOption[]>(() => {
    const tone = (name: string): AccountOption['tone'] => {
        const n = name.toLowerCase();
        if (n.includes('nubank')) return 'purple';
        if (n.includes('inter')) return 'amber';
        if (n.includes('carteira') || n.includes('dinheiro')) return 'emerald';
        return 'slate';
    };
    const accounts: AccountOption[] = [];

    for (const a of bootstrap.value.accounts ?? []) {
        if (a.type === 'credit_card') continue;
        accounts.push({
            key: a.name,
            label: a.name,
            subtitle: a.type === 'wallet' ? 'Carteira' : 'Conta',
            tone: tone(a.name),
            type: a.type as 'bank' | 'wallet',
            balance: Number(a.current_balance ?? 0),
            customColor: (a as any).color ?? undefined,
            icon: a.icon ?? undefined,
        });
    }

    for (const a of bootstrap.value.accounts ?? []) {
        if (a.type !== 'credit_card') continue;
        const limit = Number(a.credit_limit ?? 0);
        const used = Math.max(0, Number(a.current_balance ?? 0));
        accounts.push({
            key: a.name,
            label: a.name,
            subtitle: 'Cartão de Crédito',
            tone: tone(a.name),
            type: 'credit_card',
            limit,
            used,
            available: limit - used,
            customColor: (a as any).color ?? undefined,
            icon: a.icon ?? undefined,
        });
    }

    return accounts;
});

const accountOptions = computed(() => {
    const options = new Set<string>();
    for (const entry of entries.value) {
        if (entry.accountLabel) options.add(entry.accountLabel);
    }
    return Array.from(options).sort((a, b) => a.localeCompare(b));
});

const toastOpen = ref(false);
const toastMessage = ref('');
const showToast = (message: string) => {
    toastMessage.value = message;
    toastOpen.value = true;
};

const isRecurringEntry = (entry: Entry) => Boolean(entry.isRecurring) && !Boolean(entry.installment);

const replaceEntry = (entry: Entry) => {
    const idx = entries.value.findIndex((item) => item.id === entry.id);
    if (idx >= 0) entries.value[idx] = entry;
    else entries.value.unshift(entry);
};

const entryToRequest = (entry: Entry) => ({
    kind: entry.kind,
    amount: entry.amount,
    description: entry.title,
    category: entry.categoryLabel,
    account: entry.accountLabel,
    dateKind: entry.transactionDate ? 'other' : 'today',
    dateOther: entry.transactionDate ?? '',
    isPaid: entry.status === 'paid' || entry.status === 'received',
    isInstallment: Boolean(entry.installment),
    installmentCount: entry.installment ? parseInstallmentCount(entry.installment) : undefined,
    tags: entry.tags ?? [],
});

const toggleEntryPaid = async (id: string) => {
    const entry = entries.value.find((e) => e.id === id);
    if (!entry) return;
    if (entry.kind !== 'expense') return;
    const nextStatus: Entry['status'] = entry.status === 'paid' ? 'pending' : 'paid';
    const payload = { ...entryToRequest({ ...entry, status: nextStatus }), isPaid: nextStatus === 'paid' };
    const response = await requestJson<{ entry: Entry }>(route('transactions.update', entry.id), {
        method: 'PATCH',
        body: JSON.stringify(payload),
    });
    replaceEntry(response.entry);
    if (response.entry.status === 'paid') showToast('Conta marcada como paga');
    router.reload({ only: ['bootstrap'] });
    void loadMonthCashBalance(selectedMonthKey.value);
};

const filteredEntries = computed(() => {
    let raw = entries.value;
    if (filter.value === 'paid') raw = raw.filter((e) => e.status === 'paid' || e.status === 'received');
    if (filter.value === 'to_pay') raw = raw.filter((e) => e.status === 'pending');
    if (entryKindFilter.value !== 'all') raw = raw.filter((e) => e.kind === entryKindFilter.value);

    if (accountFilter.value !== 'all') raw = raw.filter((e) => e.accountLabel === accountFilter.value);

    if (filterState.value.recurrence === 'recurring') {
        raw = raw.filter((e) => Boolean(e.isRecurring));
    } else if (filterState.value.recurrence === 'non_recurring') {
        raw = raw.filter((e) => !Boolean(e.isRecurring));
    }

    if (filterState.value.period === 'today') {
        const now = new Date();
        raw = raw.filter((e) => {
            if (!e.transactionDate) return false;
            const date = parseISODate(e.transactionDate);
            if (!date) return false;
            return date.getFullYear() === now.getFullYear() && date.getMonth() === now.getMonth() && date.getDate() === now.getDate();
        });
    } else if (filterState.value.period === 'month') {
        const month = activeMonth.value.getMonth();
        const year = activeMonth.value.getFullYear();
        raw = raw.filter((e) => {
            if (!e.transactionDate) return false;
            const date = parseISODate(e.transactionDate);
            if (!date) return false;
            return date.getFullYear() === year && date.getMonth() === month;
        });
    } else if (filterState.value.period === 'range') {
        const start = parseBRDate(filterState.value.rangeStart);
        const end = parseBRDate(filterState.value.rangeEnd);
        if (start && end) {
            const startTime = new Date(start.getFullYear(), start.getMonth(), start.getDate()).getTime();
            const endTime = new Date(end.getFullYear(), end.getMonth(), end.getDate()).getTime();
            const minTime = Math.min(startTime, endTime);
            const maxTime = Math.max(startTime, endTime);
            raw = raw.filter((e) => {
                if (!e.transactionDate) return false;
                const date = parseISODate(e.transactionDate);
                if (!date) return false;
                const t = new Date(date.getFullYear(), date.getMonth(), date.getDate()).getTime();
                return t >= minTime && t <= maxTime;
            });
        }
    }

    const selectedCategories = filterState.value.categories;
    if (selectedCategories.length > 0) {
        raw = raw.filter((e) => selectedCategories.includes(e.categoryKey));
    }
    const selectedTags = filterState.value.tags;
    if (selectedTags.length > 0) {
        raw = raw.filter((e) => e.tags.some((t) => selectedTags.includes(t)));
    }
    return raw;
});

const grouped = computed(() => {
    const groups = new Map<string, Entry[]>();
    for (const entry of filteredEntries.value) {
        const groupKey = `${entry.dateLabel}|${entry.dayLabel}`;
        const list = groups.get(groupKey) ?? [];
        list.push(entry);
        groups.set(groupKey, list);
    }
    return Array.from(groups.entries()).map(([key, list]) => {
        const [dateLabel, dayLabel] = key.split('|');
        const total = list.reduce((acc, entry) => acc + (entry.kind === 'income' ? entry.amount : -entry.amount), 0);
        return { dateLabel, dayLabel, total, list };
    });
});

const formatMoney = (value: number) =>
    new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL',
    }).format(value);

const monthSummaryLoading = ref(false);
const monthMode = ref<MonthMode>('current');
const monthCashBalance = ref<number | null>(null);
const monthBalanceNet = ref<number | null>(null);

const fallbackCashBalance = () =>
    (bootstrap.value.accounts ?? [])
        .filter((a) => a.type !== 'credit_card' && a.incluir_soma !== false)
        .reduce((acc, a) => acc + Number(a.current_balance ?? 0), 0);

const loadMonthCashBalance = async (key: string) => {
    if (!key) return;
    const [year, month] = key.split('-').map(Number);
    if (!Number.isFinite(year) || !Number.isFinite(month)) return;

    monthSummaryLoading.value = true;
    try {
        const response = await requestJson<{ mode?: MonthMode; balanco?: number; accounts?: Array<{ current_balance?: number | string }> }>(
            `/api/contas-by-month?year=${year}&month=${month}`,
            { method: 'GET' },
        );
        const mode = (response as any)?.mode as MonthMode | undefined;
        if (mode) monthMode.value = mode;

        const accounts = ((response as any)?.accounts ?? []) as Array<{ current_balance?: number | string }>;
        monthCashBalance.value = accounts.reduce((acc, a) => acc + Number(a.current_balance ?? 0), 0);
        const balanco = Number((response as any)?.balanco ?? NaN);
        monthBalanceNet.value = Number.isFinite(balanco) ? balanco : null;
    } catch (error) {
        console.error('Failed to load month cash balance', error);
        monthMode.value = 'current';
        monthCashBalance.value = null;
        monthBalanceNet.value = null;
    } finally {
        monthSummaryLoading.value = false;
    }
};

watch(
    selectedMonthKey,
    (key) => {
        const m = months.value.find((month) => month.key === key);
        if (m) activeMonth.value = m.date;
        void loadMonthCashBalance(key);
    },
    { immediate: true },
);

const saldoTitle = computed(() => (monthMode.value === 'past' ? 'Final do mês' : monthMode.value === 'future' ? 'Saldo previsto' : 'Saldo atual'));
const saldoValue = computed(() => monthCashBalance.value ?? fallbackCashBalance());

const balancoMensal = computed(() => monthBalanceNet.value ?? 0);

const transactionOpen = ref(false);
const transactionKind = ref<'expense' | 'income'>('expense');
const transactionInitial = ref<TransactionModalPayload | null>(null);

const detailOpen = ref(false);
const detailTransaction = ref<TransactionDetail | null>(null);

const formatDateLabels = (date: Date) => {
    const dayLabel = String(date.getDate()).padStart(2, '0');
    const month = date
        .toLocaleString('pt-BR', { month: 'short' })
        .replace('.', '')
        .toUpperCase()
        .slice(0, 3);
    return { dayLabel, dateLabel: `DIA ${dayLabel} ${month}` };
};

const parseInstallmentCount = (installment?: string | null) => {
    if (!installment) return 3;
    const match = installment.match(/\/\s*(\d+)/);
    if (!match) return 3;
    const count = Number(match[1]);
    return Number.isFinite(count) && count > 0 ? count : 3;
};

const formatLongDate = (iso?: string) => {
    if (!iso) return '';
    const date = parseISODate(iso);
    if (!date) return iso;
    return new Intl.DateTimeFormat('pt-BR', { day: '2-digit', month: 'long', year: 'numeric' }).format(date);
};

const toAccountIcon = (label: string): TransactionDetail['accountIcon'] => {
    const normalized = label.toLowerCase();
    if (normalized.includes('carteira') || normalized.includes('wallet')) return 'wallet';
    if (normalized.includes('card') || normalized.includes('crédito') || normalized.includes('credito')) return 'card';
    return 'bank';
};

const toCategoryIcon = (entry: Entry): TransactionDetail['categoryIcon'] => {
    const icon = (entry.icon ?? '').toLowerCase();
    if (['food', 'home', 'car', 'game', 'heart', 'briefcase', 'pill', 'money', 'trend', 'bolt', 'cart', 'shirt', 'gym', 'sparkles'].includes(icon)) {
        return icon as TransactionDetail['categoryIcon'];
    }
    const label = (entry.categoryLabel ?? '').toLowerCase();
    if (label.includes('alimentação') || label.includes('comida')) return 'cart';
    if (label.includes('moradia') || label.includes('home')) return 'home';
    if (label.includes('transporte') || label.includes('carro')) return 'car';
    if (label.includes('lazer') || label.includes('game')) return 'sparkles';
    if (label.includes('saúde') || label.includes('health')) return 'heart';
    if (label.includes('salário') || label.includes('renda')) return 'money';
    if (label.includes('trabalho') || label.includes('freelance')) return 'briefcase';
    return 'bolt';
};

const listCategoryIcon = (entry: Entry) => {
    const fromCategory = categoryForEntry(entry)?.icon ?? null;
    return (fromCategory || toCategoryIcon(entry)) as string;
};

const listCategoryStyle = (entry: Entry) => {
    const color = categoryForEntry(entry)?.color ?? null;
    return color ? { color } : undefined;
};

const openDetail = (entry: Entry) => {
    const category = categoryForEntry(entry);
    const account = (bootstrap.value.accounts ?? []).find((a) => a.name === entry.accountLabel) ?? null;
    detailTransaction.value = {
        id: entry.id,
        title: entry.title,
        amount: entry.amount,
        kind: entry.kind,
        status: entry.status,
        categoryLabel: entry.categoryLabel,
        categoryIcon: (category?.icon ?? null) || toCategoryIcon(entry),
        categoryColor: category?.color ?? null,
        accountLabel: entry.accountLabel,
        accountIcon: toAccountIcon(entry.accountLabel),
        accountType: (account?.type ?? null) as any,
        accountInstitution: (account as any)?.institution ?? null,
        accountSvgPath: (account as any)?.svgPath ?? null,
        accountColor: (account as any)?.color ?? null,
        accountSystemIcon: (account as any)?.icon ?? null,
        dateLabel: formatLongDate(entry.transactionDate),
        installmentLabel: entry.installment ? entry.installment.replace('Parcela ', '') : undefined,
        receiptUrl: entry.receiptUrl ?? null,
        receiptName: entry.receiptName ?? null,
    };
    detailOpen.value = true;
};

const openCreate = () => {
    transactionKind.value = 'expense';
    transactionInitial.value = null;
    transactionOpen.value = true;
};

const openEdit = (id: string, options?: { mode?: 'edit' | 'duplicate' }) => {
    const entry = entries.value.find((e) => String(e.id) === String(id));
    if (!entry) return;

    const transferChoices = (() => {
        const keys = pickerAccounts.value.filter((a) => a.type !== 'credit_card').map((a) => a.key);
        const from = keys[0] ?? entry.accountLabel ?? '';
        const to = keys.find((k) => k !== from) ?? from;
        return { from, to };
    })();

    transactionKind.value = entry.kind;
    transactionInitial.value = {
        id: options?.mode === 'duplicate' ? undefined : entry.id,
        kind: entry.kind,
        amount: entry.amount,
        description: entry.title,
        category: entry.categoryLabel,
        account: entry.accountLabel,
        dateKind: entry.transactionDate ? 'other' : 'today',
        dateOther: entry.transactionDate ?? '',
        transactionDate: entry.transactionDate ?? '',
        isInstallment: Boolean(entry.installment),
        installmentCount: parseInstallmentCount(entry.installment),
        isPaid: entry.status === 'paid' || entry.status === 'received',
        tags: entry.tags ?? [],
        receiptFile: null,
        receiptUrl: entry.receiptUrl ?? null,
        receiptName: entry.receiptName ?? null,
        removeReceipt: false,
        transferFrom: transferChoices.from,
        transferTo: transferChoices.to,
        transferDescription: '',
        despesaFixa: Boolean(entry.isFixed),
        repetir: Boolean(entry.isRecurring) && !Boolean(entry.isFixed),
        recurrenceGroupId: entry.recurrenceGroupId ?? null,
        isFixed: Boolean(entry.isFixed),
        recurrenceEveryMonths: entry.recurrenceEveryMonths ?? null,
        recurrenceEndsAt: entry.recurrenceEndsAt ?? null,
    };
    transactionOpen.value = true;
};

const toEntryModel = (payload: TransactionModalPayload): Entry | null => {
    if (payload.kind === 'transfer') return null;
    const id = payload.id ?? `ent-${Date.now()}`;
    const existing = entries.value.find((e) => e.id === id) ?? null;
    const now = new Date();
    const { dateLabel, dayLabel } = formatDateLabels(now);

    const categoryKey =
        payload.category === 'Alimentação'
            ? 'food'
            : payload.category === 'Moradia'
              ? 'home'
              : payload.category === 'Transporte'
                ? 'car'
                : 'other';
    const icon = categoryKey === 'food' ? 'cart' : categoryKey === 'home' ? 'home' : categoryKey === 'car' ? 'car' : payload.kind === 'income' ? 'money' : 'cart';

    const isExpense = payload.kind === 'expense';
    const installment = isExpense && payload.isInstallment && payload.installmentCount > 1 ? `Parcela 1/${payload.installmentCount}` : undefined;

    return {
        id,
        dateLabel: existing?.dateLabel ?? dateLabel,
        dayLabel: existing?.dayLabel ?? dayLabel,
        title: payload.description || (payload.kind === 'income' ? 'Receita' : 'Despesa'),
        subtitle: installment ?? existing?.subtitle ?? '',
        amount: payload.amount,
        kind: payload.kind,
        status: payload.kind === 'income' ? (payload.isPaid ? 'received' : 'pending') : payload.isPaid ? 'paid' : 'pending',
        priority: existing?.priority ?? false,
        installment,
        icon: existing?.icon ?? icon,
        categoryLabel: payload.category,
        categoryKey,
        accountLabel: payload.account,
        tags: existing?.tags ?? [],
    };
};

const onTransactionSave = async (payload: TransactionModalPayload) => {
    if (payload.kind === 'transfer') {
        try {
            await executeTransfer(payload);
            showToast('Transferência realizada');
            router.reload({ only: ['bootstrap'] });
            void loadMonthCashBalance(selectedMonthKey.value);
        } catch {
            showToast('Não foi possível realizar a transferência');
        }
        return;
    }

    const url = payload.id ? route('transactions.update', payload.id) : route('transactions.store');
    const method = payload.id ? 'PATCH' : 'POST';
    const response = await (hasTransactionReceipt(payload) ? requestFormData : requestJson)<{ entry: Entry }>(url, {
        method,
        body: hasTransactionReceipt(payload) ? buildTransactionFormData(payload) : JSON.stringify(buildTransactionRequest(payload)),
    });
    replaceEntry(response.entry);
    showToast(payload.id ? 'Lançamento atualizado' : 'Lançamento criado');
    void loadMonthCashBalance(selectedMonthKey.value);
};

const onDetailDelete = async () => {
    const id = detailTransaction.value?.id;
    if (!id) return;
    await requestJson(route('transactions.destroy', id), { method: 'DELETE' });
    entries.value = entries.value.filter((entry) => entry.id !== id);
    detailOpen.value = false;
    showToast('Lançamento excluído');
    void loadMonthCashBalance(selectedMonthKey.value);
};

const onDetailEdit = () => {
    const id = detailTransaction.value?.id;
    if (!id) return;
    detailOpen.value = false;
    openEdit(id, { mode: 'edit' });
};

const onDetailDuplicate = () => {
    const id = detailTransaction.value?.id;
    if (!id) return;
    detailOpen.value = false;
    openEdit(id, { mode: 'duplicate' });
};

const filterOpen = ref(false);
const filterState = ref<TransactionFilterState>({
    categories: [],
    tags: [],
    period: 'month',
    rangeStart: '',
    rangeEnd: '',
    status: 'all',
    recurrence: 'all',
    min: '0,00',
    max: '10.000,00',
});

const filterCategories = [
    { key: 'food', label: 'Alimentação', icon: 'food' as const },
    { key: 'home', label: 'Moradia', icon: 'home' as const },
    { key: 'car', label: 'Transporte', icon: 'car' as const },
];

const desktopTypeOpen = ref(false);
const desktopCategoryOpen = ref(false);
const desktopAccountOpen = ref(false);
const closeDesktopMenus = () => {
    desktopTypeOpen.value = false;
    desktopCategoryOpen.value = false;
    desktopAccountOpen.value = false;
};
const toggleDesktopTypeMenu = () => {
    desktopTypeOpen.value = !desktopTypeOpen.value;
    desktopCategoryOpen.value = false;
    desktopAccountOpen.value = false;
};
const toggleDesktopCategoryMenu = () => {
    desktopCategoryOpen.value = !desktopCategoryOpen.value;
    desktopTypeOpen.value = false;
    desktopAccountOpen.value = false;
};
const toggleDesktopAccountMenu = () => {
    desktopAccountOpen.value = !desktopAccountOpen.value;
    desktopTypeOpen.value = false;
    desktopCategoryOpen.value = false;
};

const desktopTypeLabel = computed(() => {
    if (entryKindFilter.value === 'income') return 'Receitas';
    if (entryKindFilter.value === 'expense') return 'Despesas';
    return 'Todos os tipos';
});
const desktopCategoryLabel = computed(() => (filterState.value.categories.length ? `Categorias (${filterState.value.categories.length})` : 'Categorias'));

const desktopAccountLabel = computed(() => (accountFilter.value === 'all' ? 'Contas' : accountFilter.value));

const setEntryKindFilter = (value: 'all' | 'income' | 'expense') => {
    entryKindFilter.value = value;
    closeDesktopMenus();
};
const setAccountFilter = (value: 'all' | string) => {
    accountFilter.value = value;
    closeDesktopMenus();
};
const toggleCategory = (key: TransactionFilterState['categories'][number]) => {
    const next = new Set(filterState.value.categories);
    if (next.has(key)) next.delete(key);
    else next.add(key);
    filterState.value = { ...filterState.value, categories: Array.from(next) };
};

const clearFilters = () => {
    filter.value = 'all';
    filterState.value = {
        categories: [],
        tags: [],
        period: 'month',
        rangeStart: '',
        rangeEnd: '',
        status: 'all',
        recurrence: 'all',
        min: '0,00',
        max: '10.000,00',
    };
    filterOpen.value = false;
};

const applyFilters = (payload: TransactionFilterState) => {
    filter.value = payload.status;
    filterState.value = payload;
    filterOpen.value = false;
};

const importOpen = ref(false);
const exportOpen = ref(false);
const moreMenuOpen = ref(false);
const onInvoiceImported = async (payload: { importedCount: number; items: Array<{ title: string; amount: number }> }) => {
    const now = new Date();
    const { dateLabel, dayLabel } = formatDateLabels(now);
    for (const item of payload.items) {
        const requestPayload = {
            kind: 'expense',
            amount: item.amount,
            description: item.title,
            category: item.title.toLowerCase().includes('uber') ? 'Transporte' : 'Outros',
            account: 'Carteira',
            dateKind: 'today',
            isPaid: false,
            isInstallment: false,
        };
        const response = await requestJson<{ entry: Entry }>(route('transactions.store'), {
            method: 'POST',
            body: JSON.stringify(requestPayload),
        });
        replaceEntry(response.entry);
    }
    showToast('Fatura importada com sucesso!');
};

const parseISODate = (iso: string) => {
    const parts = String(iso ?? '').split('-').map((v) => Number(v));
    if (parts.length !== 3) return null;
    const [yyyy, mm, dd] = parts;
    if (!Number.isFinite(yyyy) || !Number.isFinite(mm) || !Number.isFinite(dd)) return null;
    const date = new Date(yyyy, mm - 1, dd);
    return Number.isFinite(date.getTime()) ? date : null;
};

const parseBRDate = (brDate: string) => {
    const match = String(brDate ?? '')
        .trim()
        .match(/^(\d{2})\/(\d{2})\/(\d{4})$/);
    if (!match) return null;
    const [, dd, mm, yyyy] = match;
    const date = new Date(Number(yyyy), Number(mm) - 1, Number(dd));
    return Number.isFinite(date.getTime()) ? date : null;
};

const toISODate = (date: Date) => {
    const yyyy = String(date.getFullYear());
    const mm = String(date.getMonth() + 1).padStart(2, '0');
    const dd = String(date.getDate()).padStart(2, '0');
    return `${yyyy}-${mm}-${dd}`;
};

const desktopImportChooserOpen = ref(false);
const desktopDrawerOpen = ref(false);
const desktopSelectedEntry = ref<Entry | null>(null);

const desktopTransactionOpen = ref(false);
const desktopTransactionKind = ref<'expense' | 'income' | 'transfer'>('expense');
const desktopTransactionInitial = ref<TransactionModalPayload | null>(null);

const openDesktopCreate = () => {
    desktopTransactionKind.value = 'expense';
    desktopTransactionInitial.value = null;
    desktopTransactionOpen.value = true;
};

const openDesktopDetail = (entry: Entry) => {
    desktopSelectedEntry.value = entry;
    desktopDrawerOpen.value = true;
};

const openDesktopEdit = (entry: Entry) => {
    const transferChoices = (() => {
        const keys = pickerAccounts.value.filter((a) => a.type !== 'credit_card').map((a) => a.key);
        const from = keys[0] ?? entry.accountLabel ?? '';
        const to = keys.find((k) => k !== from) ?? from;
        return { from, to };
    })();

    desktopTransactionKind.value = entry.kind;
    desktopTransactionInitial.value = {
        id: entry.id,
        kind: entry.kind,
        amount: entry.amount,
        description: entry.title,
        category: entry.categoryLabel,
        account: entry.accountLabel,
        dateKind: entry.transactionDate ? 'other' : 'today',
        dateOther: entry.transactionDate ?? '',
        transactionDate: entry.transactionDate ?? '',
        isInstallment: Boolean(entry.installment),
        installmentCount: parseInstallmentCount(entry.installment),
        isPaid: entry.status === 'paid' || entry.status === 'received',
        tags: entry.tags ?? [],
        receiptFile: null,
        receiptUrl: entry.receiptUrl ?? null,
        receiptName: entry.receiptName ?? null,
        removeReceipt: false,
        transferFrom: transferChoices.from,
        transferTo: transferChoices.to,
        transferDescription: '',
        despesaFixa: Boolean(entry.isFixed),
        repetir: Boolean(entry.isRecurring) && !Boolean(entry.isFixed),
        recurrenceGroupId: entry.recurrenceGroupId ?? null,
        isFixed: Boolean(entry.isFixed),
        recurrenceEveryMonths: entry.recurrenceEveryMonths ?? null,
        recurrenceEndsAt: entry.recurrenceEndsAt ?? null,
    };
    desktopTransactionOpen.value = true;
};

const deleteDesktopSelected = async () => {
    if (!desktopSelectedEntry.value) return;
    const id = desktopSelectedEntry.value.id;
    await requestJson(route('transactions.destroy', id), { method: 'DELETE' });
    entries.value = entries.value.filter((entry) => entry.id !== id);
    desktopDrawerOpen.value = false;
    showToast('Lançamento excluído');
};

const handleDesktopEdit = () => {
    if (!desktopSelectedEntry.value) return;
    desktopDrawerOpen.value = false;
    openDesktopEdit(desktopSelectedEntry.value);
};

const handleDesktopSave = async (payload: TransactionModalPayload) => {
    await onTransactionSave(payload);
    desktopTransactionOpen.value = false;
};

const onDesktopImportChoose = (mode: 'csv' | 'invoice' | 'open_finance') => {
    desktopImportChooserOpen.value = false;
    if (mode === 'invoice') {
        importOpen.value = true;
        return;
    }
    showToast('Em breve');
};

onMounted(() => {
    const url = new URL(window.location.href);
    const open = url.searchParams.get('open');
    const edit = url.searchParams.get('edit');
    const create = url.searchParams.get('create');

    const kind = url.searchParams.get('kind');
    const account = url.searchParams.get('account');

    if (kind === 'income' || kind === 'expense' || kind === 'all') {
        entryKindFilter.value = kind;
    }
    if (account) {
        accountFilter.value = decodeURIComponent(account);
    }

    if (open) {
        const found = entries.value.find((e) => String(e.id) === String(open));
        if (found) openDetail(found);
        url.searchParams.delete('open');
        window.history.replaceState({}, '', url.toString());
    }

    if (edit) {
        const found = entries.value.find((e) => String(e.id) === String(edit));
        if (found) openEdit(String(found.id), { mode: 'edit' });
        url.searchParams.delete('edit');
        window.history.replaceState({}, '', url.toString());
    }

    if (create) {
        openCreate();
        url.searchParams.delete('create');
        window.history.replaceState({}, '', url.toString());
    }
});
</script>

<template>
    <component :is="Shell" v-bind="shellProps" @add="openCreate">
        <!-- Header -->
        <header class="flex items-center justify-between pt-2">
            <div v-if="isMobile">
                <div class="text-2xl font-semibold tracking-tight text-slate-900">Transações</div>
            </div>
            <div class="flex items-center gap-2 ml-auto">
                <button
                    type="button"
                    class="flex h-11 w-11 items-center justify-center rounded-2xl bg-white text-slate-500 shadow-sm ring-1 ring-slate-200/60 transition hover:bg-slate-50"
                    aria-label="Filtrar"
                    @click="filterOpen = true"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M4 5h16l-6 7v6l-4 2v-8L4 5Z" />
                    </svg>
                </button>

                <Link
                    :href="route('accounts.search')"
                    class="flex h-11 w-11 items-center justify-center rounded-2xl bg-white text-slate-500 shadow-sm ring-1 ring-slate-200/60 transition hover:bg-slate-50"
                    aria-label="Buscar"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="11" cy="11" r="7" />
                        <path d="M20 20l-3.5-3.5" />
                    </svg>
                </Link>

                <div class="relative">
                    <button
                        type="button"
                        class="flex h-11 w-11 items-center justify-center rounded-2xl bg-white text-slate-500 shadow-sm ring-1 ring-slate-200/60 transition hover:bg-slate-50"
                        aria-label="Mais opções"
                        @click="moreMenuOpen = !moreMenuOpen"
                    >
                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="currentColor">
                            <circle cx="12" cy="5" r="2" />
                            <circle cx="12" cy="12" r="2" />
                            <circle cx="12" cy="19" r="2" />
                        </svg>
                    </button>

                    <div v-if="moreMenuOpen" class="fixed inset-0 z-[65]" @click="moreMenuOpen = false">
                        <div
                            class="absolute right-5 top-16 w-56 overflow-hidden rounded-2xl bg-white shadow-2xl ring-1 ring-slate-200/70"
                            @click.stop
                        >
                            <button
                                type="button"
                                class="w-full border-b border-slate-100 px-4 py-3 text-left text-sm font-semibold text-slate-900 hover:bg-slate-50"
                                @click="() => { moreMenuOpen = false; importOpen = true; }"
                            >
                                Importar fatura
                            </button>
                            <button
                                type="button"
                                class="w-full px-4 py-3 text-left text-sm font-semibold text-slate-900 hover:bg-slate-50"
                                @click="() => { moreMenuOpen = false; exportOpen = true; }"
                            >
                                Exportar relatório
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </header>

        <!-- Main Layout -->
         <div :class="[isMobile ? 'contents' : 'mt-8 grid grid-cols-1 lg:grid-cols-12 gap-8 items-start']">
            
            <!-- Left Column: Transactions -->
            <div :class="[isMobile ? 'contents' : 'lg:col-span-8']">
                 
                 <!-- Navigation & Quick Filters Desktop -->
                 <div class="mt-5 flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
                    <MonthNavigator v-model="selectedMonthKey" :months="months" class="flex-1" />
                    
                    <div class="flex items-center gap-2 overflow-x-auto pb-2 md:pb-0">
                         <button
                            type="button"
                            class="whitespace-nowrap rounded-full px-4 py-2 text-sm font-semibold transition"
                            :class="entryKindFilter === 'all' ? 'bg-[#14B8A6] text-white shadow-md shadow-emerald-500/20' : 'bg-white text-slate-500 ring-1 ring-slate-200/60 hover:bg-slate-50'"
                            @click="setEntryKindFilter('all')"
                        >
                            Todos
                        </button>
                        <button
                            type="button"
                            class="whitespace-nowrap rounded-full px-4 py-2 text-sm font-semibold transition"
                            :class="entryKindFilter === 'income' ? 'bg-[#14B8A6] text-white shadow-md shadow-emerald-500/20' : 'bg-white text-slate-500 ring-1 ring-slate-200/60 hover:bg-slate-50'"
                            @click="setEntryKindFilter('income')"
                        >
                            Receitas
                        </button>
                        <button
                            type="button"
                            class="whitespace-nowrap rounded-full px-4 py-2 text-sm font-semibold transition"
                            :class="entryKindFilter === 'expense' ? 'bg-[#14B8A6] text-white shadow-md shadow-emerald-500/20' : 'bg-white text-slate-500 ring-1 ring-slate-200/60 hover:bg-slate-50'"
                            @click="setEntryKindFilter('expense')"
                        >
                            Despesas
                        </button>
                    </div>
                </div>

                <!-- Lista -->
                <div class="mt-6 space-y-6">
                    <div v-for="group in grouped" :key="group.dateLabel + group.dayLabel">
                        <div class="flex items-center justify-between px-1 py-2">
                            <div class="text-xs font-bold uppercase tracking-wide text-slate-400">{{ group.dateLabel }}</div>
                            <div class="text-xs font-bold" :class="group.total >= 0 ? 'text-emerald-600' : 'text-red-500'">
                                {{ group.total >= 0 ? '+' : '' }}{{ formatMoney(group.total) }}
                            </div>
                        </div>

                        <div class="space-y-3">
                            <div
                                v-for="entry in group.list"
                                :key="entry.id"
                                class="group relative overflow-hidden rounded-3xl bg-white px-4 py-4 shadow-sm ring-1 ring-slate-200/60 transition-all hover:shadow-md hover:ring-slate-300/80 cursor-pointer"
                                role="button"
                                tabindex="0"
                                @click="openDetail(entry)"
                            >
                                <div
                                    class="absolute left-0 top-0 h-full w-1.5"
                                    :class="entry.kind === 'income' ? 'bg-emerald-500' : entry.priority ? 'bg-red-500' : 'bg-transparent'"
                                ></div>

                                <div class="flex items-center gap-4">
                                     <div class="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-slate-50 text-slate-500 ring-1 ring-slate-200/60 transition group-hover:scale-110 group-hover:bg-white group-hover:shadow-sm">
                                        <CategoryIcon :icon="listCategoryIcon(entry)" class="h-6 w-6" :style="listCategoryStyle(entry)" />
                                    </div>

                                    <div class="min-w-0 flex-1">
                                        <div class="flex flex-wrap items-center gap-2">
                                            <div class="truncate text-sm font-bold text-slate-900 group-hover:text-emerald-700 transition-colors">{{ entry.title }}</div>
                                            <span
                                                v-if="entry.priority"
                                                class="rounded-md bg-red-50 px-1.5 py-0.5 text-[10px] font-bold text-red-600 ring-1 ring-red-100"
                                            >
                                                Prioridade
                                            </span>
                                        </div>
                                        <div class="truncate text-xs font-medium text-slate-400">{{ entry.installment ?? entry.subtitle }}</div>
                                        <div v-if="entry.tags.length || isRecurringEntry(entry)" class="mt-2 flex flex-wrap gap-2">
                                            <span
                                                v-if="isRecurringEntry(entry)"
                                                class="inline-flex items-center rounded-full bg-emerald-50 px-2 py-0.5 text-[10px] font-bold text-emerald-600 ring-1 ring-emerald-100"
                                            >
                                                {{ entry.isFixed ? 'Fixa' : 'Repetir' }}
                                            </span>
                                            <span
                                                v-for="tag in entry.tags"
                                                :key="tag"
                                                class="inline-flex items-center rounded-full px-2 py-0.5 text-[10px] font-bold ring-1 ring-inset"
                                                :class="
                                                    tag === 'Essencial'
                                                        ? 'bg-emerald-50 text-emerald-600 ring-emerald-100'
                                                    : tag === 'Urgente'
                                                          ? 'bg-red-50 text-red-500 ring-red-100'
                                                          : 'bg-slate-50 text-slate-500 ring-slate-200'
                                                "
                                            >
                                                {{ tag }}
                                            </span>
                                        </div>
                                    </div>

                                    <div class="text-right">
                                        <div
                                            class="text-sm font-bold"
                                            :class="
                                                entry.kind === 'income'
                                                    ? 'text-emerald-600'
                                                    : entry.status === 'paid'
                                                      ? 'text-emerald-600/60 line-through decoration-2'
                                                      : 'text-red-500'
                                            "
                                        >
                                            {{ entry.kind === 'income' ? '+' : '-' }} {{ formatMoney(entry.amount) }}
                                        </div>

                                        <div class="mt-2 flex items-center justify-end gap-2">
                                            <button
                                                v-if="entry.kind === 'expense'"
                                                type="button"
                                                class="group/check flex h-7 w-7 items-center justify-center rounded-full border-2 transition-all active:scale-95"
                                                :class="entry.status === 'paid' ? 'border-emerald-500 bg-emerald-500' : 'border-slate-200 bg-white hover:border-emerald-300'"
                                                :title="entry.status === 'paid' ? 'Marcar como não paga' : 'Marcar como paga'"
                                                @click.stop="toggleEntryPaid(entry.id)"
                                            >
                                                <svg v-if="entry.status === 'paid'" class="h-4 w-4 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">
                                                    <path d="M20 6 9 17l-5-5" />
                                                </svg>
                                                 <svg v-else class="h-4 w-4 text-emerald-300 opacity-0 transition group-hover/check:opacity-100" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">
                                                    <path d="M20 6 9 17l-5-5" />
                                                </svg>
                                            </button>
                                            <span
                                                v-else
                                                class="inline-flex items-center gap-1 rounded-full bg-emerald-50 px-2 py-0.5 text-[10px] font-bold text-emerald-600 ring-1 ring-emerald-100"
                                            >
                                                <svg class="h-3 w-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                                                    <path d="M20 6 9 17l-5-5" />
                                                </svg>
                                                Recebido
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Right Column: Summary -->
            <div :class="[isMobile ? 'order-first' : 'lg:col-span-4 lg:sticky lg:top-24']">
                 <div class="overflow-hidden rounded-3xl bg-white shadow-sm ring-1 ring-slate-200/60 transition hover:ring-slate-300/70" :class="monthSummaryLoading ? 'opacity-70 grayscale' : ''">
                    <div :class="[isMobile ? 'grid grid-cols-2 divide-x divide-slate-100' : 'flex flex-col divide-y divide-slate-100']">
                        <div class="px-6 py-6 text-center lg:py-8">
                            <div class="text-xs font-bold uppercase tracking-wider text-slate-400 mb-2">{{ saldoTitle }}</div>
                            <div class="text-2xl font-bold tracking-tight" :class="saldoValue >= 0 ? 'text-emerald-600' : 'text-red-500'">
                                {{ formatMoney(saldoValue) }}
                            </div>
                        </div>
                        <div class="px-6 py-6 text-center lg:py-8">
                            <div class="text-xs font-bold uppercase tracking-wider text-slate-400 mb-2">Balanço do mês</div>
                            <div class="text-2xl font-bold tracking-tight" :class="balancoMensal >= 0 ? 'text-emerald-600' : 'text-red-500'">
                                {{ balancoMensal >= 0 ? '+' : '' }}{{ formatMoney(Math.abs(balancoMensal)) }}
                            </div>
                        </div>
                    </div>
                    <div v-if="!isMobile" class="bg-slate-50 px-6 py-4 text-center text-xs font-medium text-slate-500">
                        Os valores são atualizados automaticamente com base nos filtros e transações.
                    </div>
                </div>

                 <div v-if="!isMobile" class="mt-6 rounded-3xl bg-[#F0FDF4] p-6 ring-1 ring-emerald-100">
                     <div class="flex items-start gap-4">
                         <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-emerald-100 text-emerald-600">
                             <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M12 2v20" />
                                <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6" />
                             </svg>
                         </div>
                         <div>
                             <h4 class="text-sm font-bold text-emerald-900">Dica Financeira</h4>
                             <p class="mt-1 text-xs leading-relaxed text-emerald-700">Mantenha suas despesas categorizadas para entender melhor seus hábitos de consumo no relatório de análise.</p>
                         </div>
                     </div>
                 </div>
            </div>
        </div>

        <TransactionModal
            :open="transactionOpen"
            :kind="transactionKind"
            :initial="transactionInitial"
            :categories="pickerCategories"
            :accounts="pickerAccounts"
            :tags="bootstrap.tags"
            @close="transactionOpen = false"
            @save="onTransactionSave"
        />
        <TransactionDetailModal
            :open="detailOpen"
            :transaction="detailTransaction"
            @close="detailOpen = false"
            @edit="onDetailEdit"
            @duplicate="onDetailDuplicate"
            @delete="onDetailDelete"
        />
        <TransactionFilterModal
            :open="filterOpen"
            :categories="filterCategories"
            :tags="bootstrap.tags"
            :initial="filterState"
            :results-count="filteredEntries.length"
            @close="filterOpen = false"
            @clear="clearFilters"
            @apply="applyFilters"
        />
        <ImportInvoiceModal :open="importOpen" @close="importOpen = false" @imported="onInvoiceImported" />
        <ExportReportModal
            :open="exportOpen"
            :default-month-key="selectedMonthKey"
            @close="exportOpen = false"
            @exported="() => { showToast('Relatório baixado'); }"
        />
        <MobileToast :show="toastOpen" :message="toastMessage" @dismiss="toastOpen = false" />
    </component>
</template>
