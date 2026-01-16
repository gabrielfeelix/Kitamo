<script setup lang="ts">
	import { computed, onMounted, ref } from 'vue';
	import { Link, usePage } from '@inertiajs/vue3';
	import { requestJson } from '@/lib/kitamoApi';
	import { buildTransactionRequest } from '@/lib/transactions';
	import type { BootstrapData, Entry } from '@/types/kitamo';
	import MobileShell from '@/Layouts/MobileShell.vue';
	import DesktopShell from '@/Layouts/DesktopShell.vue';
	import TransactionModal, { type TransactionModalPayload } from '@/Components/TransactionModal.vue';
	import DesktopTransactionModal from '@/Components/DesktopTransactionModal.vue';
	import MobileToast from '@/Components/MobileToast.vue';
	import TransactionDetailModal, { type TransactionDetail } from '@/Components/TransactionDetailModal.vue';
	import TransactionFilterModal, { type TransactionFilterState } from '@/Components/TransactionFilterModal.vue';
	import ImportInvoiceModal from '@/Components/ImportInvoiceModal.vue';
	import DesktopImportChooserModal from '@/Components/DesktopImportChooserModal.vue';
	import DesktopTransactionDrawer from '@/Components/DesktopTransactionDrawer.vue';
	import { useIsMobile } from '@/composables/useIsMobile';
import type { AccountOption } from '@/Components/AccountPickerSheet.vue';
import type { CategoryOption } from '@/Components/CategoryPickerSheet.vue';

const page = usePage();
const userName = computed(() => page.props.auth?.user?.name ?? 'Gabriel');
const bootstrap = computed(
    () => (page.props.bootstrap ?? { entries: [], goals: [], accounts: [], categories: [] }) as BootstrapData,
);
const isMobile = useIsMobile();

type FilterKind = 'all' | 'paid' | 'to_pay';

const activeMonth = ref(new Date(2026, 0, 1));
const monthLabel = computed(() => {
    const month = new Intl.DateTimeFormat('pt-BR', { month: 'long' }).format(activeMonth.value).toUpperCase();
    return `${month} ${activeMonth.value.getFullYear()}`;
});
const shiftMonth = (delta: number) => {
    const d = new Date(activeMonth.value);
    d.setMonth(d.getMonth() + delta);
    activeMonth.value = d;
};

const filter = ref<FilterKind>('all');
const entryKindFilter = ref<'all' | 'income' | 'expense'>('all');
const accountFilter = ref<'all' | string>('all');

const entries = ref<Entry[]>(bootstrap.value.entries ?? []);
const pickerCategories = computed<CategoryOption[]>(() => {
    const unique = new Map<string, CategoryOption>();
    for (const c of bootstrap.value.categories ?? []) {
        unique.set(c.name, { key: c.name, label: c.name, icon: 'other', tone: 'slate' });
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
    return (bootstrap.value.accounts ?? [])
        .filter((a) => a.type !== 'credit_card')
        .map((a) => ({ key: a.name, label: a.name, subtitle: a.type === 'wallet' ? 'Carteira' : 'Conta', tone: tone(a.name) }));
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

const isRecurringEntry = (entry: Entry) => Boolean(entry.tags?.includes('Recorrente')) && !Boolean(entry.installment);

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
};

const filteredEntries = computed(() => {
    let raw = entries.value;
    if (filter.value === 'paid') raw = raw.filter((e) => e.status === 'paid' || e.status === 'received');
    if (filter.value === 'to_pay') raw = raw.filter((e) => e.status === 'pending');
    if (entryKindFilter.value !== 'all') raw = raw.filter((e) => e.kind === entryKindFilter.value);

    if (accountFilter.value !== 'all') raw = raw.filter((e) => e.accountLabel === accountFilter.value);

    const monthAbbrToIndex: Record<string, number> = {
        JAN: 0,
        FEV: 1,
        MAR: 2,
        ABR: 3,
        MAI: 4,
        JUN: 5,
        JUL: 6,
        AGO: 7,
        SET: 8,
        OUT: 9,
        NOV: 10,
        DEZ: 11,
    };
    const parseMonthIndex = (label: string) => {
        const last = label.trim().split(/\s+/).at(-1)?.toUpperCase() ?? '';
        const idx = monthAbbrToIndex[last];
        return Number.isFinite(idx) ? idx : null;
    };
    if (filterState.value.period === 'month') {
        const selectedMonthIdx = activeMonth.value.getMonth();
        raw = raw.filter((e) => {
            const entryMonthIdx = parseMonthIndex(e.dateLabel);
            if (entryMonthIdx === null) return true;
            return entryMonthIdx === selectedMonthIdx;
        });
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

const openDetail = (entry: Entry) => {
    detailTransaction.value = {
        id: entry.id,
        title: entry.title,
        amount: entry.amount,
        kind: entry.kind,
        status: entry.status,
        categoryLabel: entry.categoryLabel,
        categoryIcon:
            entry.categoryKey === 'food'
                ? 'cart'
                : entry.categoryKey === 'home'
                  ? 'home'
                  : entry.categoryKey === 'car'
                    ? 'car'
                    : entry.kind === 'income'
                      ? 'briefcase'
                      : 'heart',
        accountLabel: entry.accountLabel,
        accountIcon: 'wallet',
        dateLabel: `20 de janeiro de 2026`,
        installmentLabel: entry.installment ? entry.installment.replace('Parcela ', '') : undefined,
    };
    detailOpen.value = true;
};

const openCreate = () => {
    transactionKind.value = 'expense';
    transactionInitial.value = null;
    transactionOpen.value = true;
};

const openEdit = (id: string, options?: { mode?: 'edit' | 'duplicate' }) => {
    const entry = entries.value.find((e) => e.id === id);
    if (!entry) return;

    transactionKind.value = entry.kind;
    transactionInitial.value = {
        id: options?.mode === 'duplicate' ? undefined : entry.id,
        kind: entry.kind,
        amount: entry.amount,
        description: entry.title,
        category: entry.categoryLabel,
        account: entry.accountLabel,
        dateKind: 'today',
        isInstallment: Boolean(entry.installment),
        installmentCount: parseInstallmentCount(entry.installment),
        isPaid: entry.status === 'paid',
        transferFrom: 'Banco Inter',
        transferTo: 'Carteira',
        transferDescription: '',
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
        status: payload.kind === 'income' ? 'received' : payload.isPaid ? 'paid' : 'pending',
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
        showToast('Transferência realizada');
        return;
    }

    const url = payload.id ? route('transactions.update', payload.id) : route('transactions.store');
    const method = payload.id ? 'PATCH' : 'POST';
    const response = await requestJson<{ entry: Entry }>(url, {
        method,
        body: JSON.stringify(buildTransactionRequest(payload)),
    });
    replaceEntry(response.entry);
    showToast(payload.id ? 'Lançamento atualizado' : 'Lançamento criado');
};

const onDetailDelete = async () => {
    const id = detailTransaction.value?.id;
    if (!id) return;
    await requestJson(route('transactions.destroy', id), { method: 'DELETE' });
    entries.value = entries.value.filter((entry) => entry.id !== id);
    detailOpen.value = false;
    showToast('Lançamento excluído');
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
    categories: ['food', 'home', 'car'],
    tags: [],
    period: 'month',
    status: 'all',
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
    return 'Todos Tipos';
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
    filterState.value = { categories: [], tags: [], period: 'month', status: 'all', min: '0,00', max: '10.000,00' };
    filterOpen.value = false;
};

const applyFilters = (payload: TransactionFilterState) => {
    filter.value = payload.status;
    filterState.value = payload;
    filterOpen.value = false;
};

const importOpen = ref(false);
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
    desktopTransactionKind.value = entry.kind;
    desktopTransactionInitial.value = {
        id: entry.id,
        kind: entry.kind,
        amount: entry.amount,
        description: entry.title,
        category: entry.categoryLabel,
        account: entry.accountLabel,
        dateKind: 'today',
        isInstallment: Boolean(entry.installment),
        installmentCount: parseInstallmentCount(entry.installment),
        isPaid: entry.status === 'paid',
        transferFrom: 'Banco Inter',
        transferTo: 'Carteira',
        transferDescription: '',
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

    const kind = url.searchParams.get('kind');
    const account = url.searchParams.get('account');

    if (kind === 'income' || kind === 'expense' || kind === 'all') {
        entryKindFilter.value = kind;
    }
    if (account) {
        accountFilter.value = decodeURIComponent(account);
    }

    if (open) {
        const found = entries.value.find((e) => e.id === open);
        if (found) openDesktopDetail(found);
        url.searchParams.delete('open');
        window.history.replaceState({}, '', url.toString());
    }

    if (edit) {
        const found = entries.value.find((e) => e.id === edit);
        if (found) openDesktopEdit(found);
        url.searchParams.delete('edit');
        window.history.replaceState({}, '', url.toString());
    }
});
</script>

<template>
    <MobileShell v-if="isMobile" @add="openCreate">
	        <header class="flex items-center justify-between pt-2">
	            <div>
	                <div class="text-2xl font-semibold tracking-tight text-slate-900">Lançamentos</div>
	            </div>
	            <div class="flex items-center gap-2">
	                <button
	                    type="button"
	                    class="flex h-11 w-11 items-center justify-center rounded-2xl bg-white text-slate-500 shadow-sm ring-1 ring-slate-200/60"
	                    aria-label="Filtrar"
                    @click="filterOpen = true"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M4 5h16l-6 7v6l-4 2v-8L4 5Z" />
                    </svg>
                </button>

                <button
                    type="button"
                    class="flex h-11 w-11 items-center justify-center rounded-2xl bg-white text-slate-500 shadow-sm ring-1 ring-slate-200/60"
                    aria-label="Importar fatura"
                    @click="importOpen = true"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M12 3v12" />
                        <path d="M8 11l4 4 4-4" />
                        <path d="M4 21h16" />
                    </svg>
                </button>

                <Link
                    :href="route('accounts.search')"
                    class="flex h-11 w-11 items-center justify-center rounded-2xl bg-white text-slate-500 shadow-sm ring-1 ring-slate-200/60"
                    aria-label="Buscar"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="11" cy="11" r="7" />
                        <path d="M20 20l-3.5-3.5" />
                    </svg>
                </Link>
            </div>
        </header>

        <div class="mt-5 rounded-2xl bg-white px-3 py-3 shadow-sm ring-1 ring-slate-200/60">
            <div class="flex items-center justify-between">
                <button
                    type="button"
                    class="flex h-10 w-10 items-center justify-center rounded-xl text-slate-500 hover:bg-slate-50"
                    aria-label="Mês anterior"
                    @click="shiftMonth(-1)"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M15 18l-6-6 6-6" />
                    </svg>
                </button>
                <div class="text-sm font-semibold tracking-wide text-slate-900">{{ monthLabel }}</div>
                <button
                    type="button"
                    class="flex h-10 w-10 items-center justify-center rounded-xl text-slate-500 hover:bg-slate-50"
                    aria-label="Próximo mês"
                    @click="shiftMonth(1)"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M9 18l6-6-6-6" />
                    </svg>
                </button>
            </div>
        </div>

	        <div class="mt-3 flex flex-wrap items-center gap-2">
	            <button
	                type="button"
	                class="rounded-full px-4 py-2 text-sm font-semibold transition"
                :class="entryKindFilter === 'all' ? 'bg-emerald-500 text-white' : 'bg-white text-slate-500 ring-1 ring-slate-200/60'"
                @click="setEntryKindFilter('all')"
            >
                Todos tipos
            </button>
            <button
                type="button"
                class="rounded-full px-4 py-2 text-sm font-semibold transition"
                :class="entryKindFilter === 'income' ? 'bg-emerald-500 text-white' : 'bg-white text-slate-500 ring-1 ring-slate-200/60'"
                @click="setEntryKindFilter('income')"
            >
                Receitas
            </button>
            <button
                type="button"
                class="rounded-full px-4 py-2 text-sm font-semibold transition"
                :class="entryKindFilter === 'expense' ? 'bg-emerald-500 text-white' : 'bg-white text-slate-500 ring-1 ring-slate-200/60'"
                @click="setEntryKindFilter('expense')"
            >
                Despesas
            </button>
        </div>

        <div class="mt-4 space-y-4">
            <div v-for="group in grouped" :key="group.dateLabel + group.dayLabel">
                <div class="flex items-center justify-between px-1 py-2">
                    <div class="text-xs font-semibold uppercase tracking-wide text-slate-400">{{ group.dateLabel }}</div>
                    <div class="text-xs font-semibold" :class="group.total >= 0 ? 'text-emerald-600' : 'text-red-500'">
                        {{ group.total >= 0 ? '+' : '-' }} {{ formatMoney(Math.abs(group.total)).replace('R$', 'R$') }}
                    </div>
                </div>

                <div class="space-y-3">
                    <div
                        v-for="entry in group.list"
                        :key="entry.id"
                        class="relative overflow-hidden rounded-3xl bg-white px-4 py-4 shadow-sm ring-1 ring-slate-200/60"
                        role="button"
                        tabindex="0"
                        @click="openDetail(entry)"
                    >
                        <div
                            class="absolute left-0 top-0 h-full w-1.5"
                            :class="entry.kind === 'income' ? 'bg-emerald-500' : entry.priority ? 'bg-red-500' : 'bg-transparent'"
                        ></div>

                        <div class="flex items-center gap-4">
                            <div class="flex h-12 w-12 items-center justify-center rounded-2xl bg-slate-50 text-slate-500 ring-1 ring-slate-200/60">
                                <svg v-if="entry.icon === 'gym'" class="h-6 w-6 text-emerald-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M6 8v8" />
                                    <path d="M18 8v8" />
                                    <path d="M8 10h8" />
                                    <path d="M8 14h8" />
                                    <path d="M4 10v4" />
                                    <path d="M20 10v4" />
                                </svg>
                                <svg v-else-if="entry.icon === 'home'" class="h-6 w-6 text-blue-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M3 10.5L12 3l9 7.5" />
                                    <path d="M5 10v10h14V10" />
                                </svg>
                                <svg v-else-if="entry.icon === 'car'" class="h-6 w-6 text-indigo-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M5 16l1-5 1-3h10l1 3 1 5" />
                                    <path d="M7 16h10" />
                                    <circle cx="8" cy="17" r="1.5" />
                                    <circle cx="16" cy="17" r="1.5" />
                                </svg>
                                <svg v-else-if="entry.icon === 'cart'" class="h-6 w-6 text-amber-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M6 6h15l-2 7H7L6 6Z" />
                                    <path d="M6 6l-2-2H2" />
                                    <circle cx="9" cy="18" r="1.5" />
                                    <circle cx="17" cy="18" r="1.5" />
                                </svg>
                                <svg v-else class="h-6 w-6 text-emerald-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M12 3v18" />
                                    <path d="M7 7h5a3 3 0 1 1 0 6H7" />
                                </svg>
                            </div>

                            <div class="min-w-0 flex-1">
                                <div class="flex flex-wrap items-center gap-2">
                                    <div class="truncate text-sm font-semibold text-slate-900">{{ entry.title }}</div>
                                    <span
                                        v-if="entry.priority"
                                        class="rounded-md bg-red-500 px-2 py-1 text-[10px] font-semibold text-white"
                                    >
                                        Prioridade
                                    </span>
                                </div>
                                <div class="truncate text-xs text-slate-400">{{ entry.installment ?? entry.subtitle }}</div>
                                <div v-if="entry.tags.length || isRecurringEntry(entry)" class="mt-2 flex flex-wrap gap-2">
                                    <span v-if="isRecurringEntry(entry)" class="group relative inline-flex items-center">
                                        <span class="inline-flex items-center gap-1 rounded bg-[#DBEAFE] px-2 py-0.5 text-[12px] font-semibold text-[#3B82F6]">
                                            🔁 Recorrente
                                        </span>
                                        <span
                                            class="absolute bottom-full left-0 mb-2 hidden w-64 rounded-lg bg-slate-800 px-3 py-2 text-xs font-medium text-white shadow-lg group-hover:block"
                                        >
                                            Despesa recorrente - repete todo mês
                                            <span
                                                class="absolute top-full left-4 h-0 w-0 border-l-4 border-r-4 border-t-4 border-transparent border-t-slate-800"
                                            ></span>
                                        </span>
                                    </span>
                                    <span
                                        v-for="tag in entry.tags.filter((t) => t !== 'Recorrente')"
                                        :key="tag"
                                        class="inline-flex items-center rounded-full px-2 py-0.5 text-[10px] font-semibold"
                                        :class="
                                            tag === 'Essencial'
                                                ? 'bg-emerald-50 text-emerald-600'
                                                : tag === 'Urgente'
                                                  ? 'bg-red-50 text-red-500'
                                                  : 'bg-slate-100 text-slate-600'
                                        "
                                    >
                                        {{ tag }}
                                    </span>
                                </div>
                            </div>

                            <div class="text-right">
                                <div
                                    class="text-sm font-semibold"
                                    :class="
                                        entry.kind === 'income'
                                            ? 'text-emerald-600'
                                            : entry.status === 'paid'
                                              ? 'text-emerald-600 line-through'
                                              : 'text-red-500'
                                    "
                                >
                                    {{ entry.kind === 'income' ? '+' : '-' }} {{ formatMoney(entry.amount).replace('R$', 'R$') }}
                                </div>

                                <div class="mt-2 flex items-center justify-end gap-2">
                                    <button
                                        v-if="entry.kind === 'expense'"
                                        type="button"
                                        class="flex h-6 w-6 items-center justify-center rounded-full border-2"
                                        :class="entry.status === 'paid' ? 'border-emerald-500 bg-emerald-500' : 'border-slate-200 bg-white'"
                                        :aria-label="entry.status === 'paid' ? 'Marcar como não paga' : 'Marcar como paga'"
                                        @click.stop="toggleEntryPaid(entry.id)"
                                    >
                                        <svg v-if="entry.status === 'paid'" class="h-4 w-4 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">
                                            <path d="M20 6 9 17l-5-5" />
                                        </svg>
                                    </button>
                                    <span
                                        v-else
                                        class="inline-flex items-center gap-1 rounded-full bg-emerald-50 px-2 py-1 text-[10px] font-semibold text-emerald-600"
                                    >
                                        <svg class="h-3.5 w-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
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

	        <TransactionModal
                :open="transactionOpen"
                :kind="transactionKind"
                :initial="transactionInitial"
                :categories="pickerCategories"
                :accounts="pickerAccounts"
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
            :initial="filterState"
            :results-count="filteredEntries.length"
            @close="filterOpen = false"
            @clear="clearFilters"
            @apply="applyFilters"
        />
        <ImportInvoiceModal :open="importOpen" @close="importOpen = false" @imported="onInvoiceImported" />
        <MobileToast :show="toastOpen" :message="toastMessage" @dismiss="toastOpen = false" />
    </MobileShell>

    <div v-else-if="false">
        <div class="grid gap-6 xl:grid-cols-2">
            <Link
                :href="route('accounts.checking')"
                class="rounded-[28px] border border-white/70 bg-white p-6 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)] transition hover:-translate-y-0.5 hover:shadow-[0_30px_70px_-45px_rgba(15,23,42,0.55)]"
            >
                <div class="flex items-center justify-between">
                    <div class="flex items-center gap-4">
                        <span class="flex h-12 w-12 items-center justify-center rounded-2xl bg-slate-100 text-slate-600">
                            <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M12 2l7 7-7 7-7-7 7-7Z" />
                            </svg>
                        </span>
                        <div>
                            <div class="text-base font-semibold text-slate-900">Nubank C/C</div>
                            <div class="text-sm text-slate-500">Saldo atual</div>
                        </div>
                    </div>
                    <div class="text-base font-semibold text-slate-900">R$ 2345.67</div>
                </div>
            </Link>

            <Link
                :href="route('accounts.card')"
                class="rounded-[28px] border border-white/70 bg-white p-6 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)] transition hover:-translate-y-0.5 hover:shadow-[0_30px_70px_-45px_rgba(15,23,42,0.55)]"
            >
                <div class="flex items-center justify-between">
                    <div class="flex items-center gap-4">
                        <span class="flex h-12 w-12 items-center justify-center rounded-2xl bg-slate-900 text-white">
                            <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="5" width="18" height="14" rx="3" />
                                <path d="M3 10h18" />
                            </svg>
                        </span>
                        <div>
                            <div class="text-base font-semibold text-slate-900">Nubank Cartão</div>
                            <div class="text-sm text-slate-500">Fatura aberta</div>
                        </div>
                    </div>
                    <div class="text-base font-semibold text-slate-900">R$ 1450.00</div>
                </div>
            </Link>
        </div>
    </div>

    <DesktopShell v-else title="Lançamentos" subtitle="Domingo, 11 Jan 2026" search-placeholder="Buscar (ex: Supermercado)..." @new-transaction="openDesktopCreate">
        <button v-if="desktopTypeOpen || desktopCategoryOpen || desktopAccountOpen" type="button" class="fixed inset-0 z-[70]" aria-label="Fechar filtros" @click="closeDesktopMenus"></button>

        <div class="space-y-8">
            <div class="rounded-2xl bg-white px-6 py-5 shadow-sm ring-1 ring-slate-200/60">
	                <div class="flex items-center justify-between gap-6">
	                    <div class="flex items-center gap-4">
                        <div class="flex items-center rounded-2xl border border-slate-200 bg-white px-2 py-1">
                            <button type="button" class="flex h-10 w-10 items-center justify-center rounded-xl text-slate-500 hover:bg-slate-50" aria-label="Mês anterior" @click="shiftMonth(-1)">
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M15 18l-6-6 6-6" />
                                </svg>
                            </button>
                            <div class="px-4 text-sm font-semibold tracking-wide text-slate-900">{{ monthLabel }}</div>
                            <button type="button" class="flex h-10 w-10 items-center justify-center rounded-xl text-slate-500 hover:bg-slate-50" aria-label="Próximo mês" @click="shiftMonth(1)">
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M9 18l6-6-6-6" />
                                </svg>
                            </button>
                        </div>

                        <div class="relative">
                            <button
                                type="button"
                                class="inline-flex h-11 items-center gap-2 rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-600"
                                @click="toggleDesktopTypeMenu"
                            >
                                {{ desktopTypeLabel }}
                                <svg class="h-4 w-4 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M6 9l6 6 6-6" />
                                </svg>
                            </button>
                            <div v-if="desktopTypeOpen" class="absolute left-0 top-full z-[71] mt-2 w-56 overflow-hidden rounded-2xl bg-white shadow-lg ring-1 ring-slate-200/60">
                                <button
                                    type="button"
                                    class="flex w-full items-center justify-between px-5 py-3 text-left text-sm font-semibold"
                                    :class="entryKindFilter === 'all' ? 'bg-slate-50 text-slate-900' : 'text-slate-600 hover:bg-slate-50'"
                                    @click="setEntryKindFilter('all')"
                                >
                                    Todos
                                </button>
                                <button
                                    type="button"
                                    class="flex w-full items-center justify-between px-5 py-3 text-left text-sm font-semibold"
                                    :class="entryKindFilter === 'income' ? 'bg-slate-50 text-slate-900' : 'text-slate-600 hover:bg-slate-50'"
                                    @click="setEntryKindFilter('income')"
                                >
                                    Receitas
                                </button>
                                <button
                                    type="button"
                                    class="flex w-full items-center justify-between px-5 py-3 text-left text-sm font-semibold"
                                    :class="entryKindFilter === 'expense' ? 'bg-slate-50 text-slate-900' : 'text-slate-600 hover:bg-slate-50'"
                                    @click="setEntryKindFilter('expense')"
                                >
                                    Despesas
                                </button>
                            </div>
                        </div>

                        <div class="relative">
                            <button
                                type="button"
                                class="inline-flex h-11 items-center gap-2 rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-600"
                                @click="toggleDesktopCategoryMenu"
                            >
                                {{ desktopCategoryLabel }}
                                <svg class="h-4 w-4 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M6 9l6 6 6-6" />
                                </svg>
                            </button>
                            <div v-if="desktopCategoryOpen" class="absolute left-0 top-full z-[71] mt-2 w-72 overflow-hidden rounded-2xl bg-white shadow-lg ring-1 ring-slate-200/60">
                                <div class="px-5 py-3 text-xs font-bold uppercase tracking-wide text-slate-400">Categorias</div>
                                <button
                                    v-for="c in filterCategories"
                                    :key="c.key"
                                    type="button"
                                    class="flex w-full items-center justify-between px-5 py-3 text-left text-sm font-semibold text-slate-600 hover:bg-slate-50"
                                    @click="toggleCategory(c.key)"
                                >
                                    <span>{{ c.label }}</span>
                                    <span v-if="filterState.categories.includes(c.key)" class="text-[#14B8A6]">
                                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M20 6 9 17l-5-5" />
                                        </svg>
                                    </span>
                                </button>
                            </div>
                        </div>

                        <div class="relative">
                            <button
                                type="button"
                                class="inline-flex h-11 items-center gap-2 rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-600"
                                @click="toggleDesktopAccountMenu"
                            >
                                {{ desktopAccountLabel }}
                                <svg class="h-4 w-4 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M6 9l6 6 6-6" />
                                </svg>
                            </button>
                            <div v-if="desktopAccountOpen" class="absolute left-0 top-full z-[71] mt-2 w-64 overflow-hidden rounded-2xl bg-white shadow-lg ring-1 ring-slate-200/60">
                                <button
                                    type="button"
                                    class="flex w-full items-center justify-between px-5 py-3 text-left text-sm font-semibold"
                                    :class="accountFilter === 'all' ? 'bg-slate-50 text-slate-900' : 'text-slate-600 hover:bg-slate-50'"
                                    @click="setAccountFilter('all')"
                                >
                                    Todas as contas
                                </button>
                                <button
                                    v-for="account in accountOptions"
                                    :key="account"
                                    type="button"
                                    class="flex w-full items-center justify-between px-5 py-3 text-left text-sm font-semibold"
                                    :class="accountFilter === account ? 'bg-slate-50 text-slate-900' : 'text-slate-600 hover:bg-slate-50'"
                                    @click="setAccountFilter(account)"
                                >
                                    {{ account }}
                                </button>
                                <div v-if="!accountOptions.length" class="px-5 py-4 text-sm text-slate-400">Sem contas disponíveis</div>
                            </div>
                        </div>
	                    </div>

	                    <button
	                        type="button"
	                        class="inline-flex h-11 items-center rounded-xl bg-[#14B8A6] px-5 text-sm font-semibold text-white shadow-lg shadow-emerald-500/20"
	                        @click="filterOpen = true"
	                    >
	                        Filtrar
	                    </button>
	                </div>
	            </div>

            <div class="rounded-2xl bg-white shadow-sm ring-1 ring-slate-200/60">
                <div class="flex items-center justify-between px-8 py-6">
                    <div class="text-lg font-semibold text-slate-900">Histórico</div>
                    <div class="flex items-center gap-3">
                        <button
                            type="button"
                            class="inline-flex h-11 items-center gap-2 rounded-xl border border-emerald-200 bg-emerald-50 px-4 text-sm font-semibold text-[#14B8A6]"
                            @click="desktopImportChooserOpen = true"
                        >
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M4 7h6l2 2h8v10H4V7Z" />
                                <path d="M12 12v6" />
                                <path d="M9 15l3 3 3-3" />
                            </svg>
                            Importar Dados
                        </button>

                        <button
                            type="button"
                            class="flex h-11 w-11 items-center justify-center rounded-xl border border-slate-200 bg-white text-slate-500"
                            @click="desktopImportChooserOpen = true"
                            aria-label="Importar"
                        >
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M12 3v12" />
                                <path d="M8 11l4 4 4-4" />
                                <path d="M4 21h16" />
                            </svg>
                        </button>
                    </div>
                </div>

                <div class="px-8 pb-8">
                    <table class="w-full">
                        <thead class="border-b border-slate-100 text-xs font-bold uppercase tracking-wide text-slate-400">
                            <tr class="text-left">
                                <th class="py-4">Descrição</th>
                                <th class="py-4">Categoria</th>
                                <th class="py-4">Conta</th>
                                <th class="py-4">Data</th>
                                <th class="py-4">Status</th>
                                <th class="py-4 text-right">Valor</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr
                                v-for="row in filteredEntries"
                                :key="row.id"
                                class="cursor-pointer border-b border-slate-100 text-sm font-semibold text-slate-700 last:border-b-0 hover:bg-slate-50"
                                @click="openDesktopDetail(row)"
                            >
                                <td class="py-5">
                                    <div class="flex items-center gap-4">
                                        <span class="flex h-11 w-11 items-center justify-center rounded-full bg-slate-50 text-slate-500 ring-1 ring-slate-100">
                                            <svg v-if="row.title.toLowerCase().includes('netflix')" class="h-6 w-6 text-red-500" viewBox="0 0 24 24" fill="currentColor">
                                                <path d="M9 7v10l9-5-9-5Z" />
                                            </svg>
                                            <svg v-else-if="row.categoryKey === 'home'" class="h-6 w-6 text-blue-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <path d="M3 10.5L12 3l9 7.5" />
                                                <path d="M5 10v10h14V10" />
                                            </svg>
                                            <svg v-else class="h-6 w-6 text-amber-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <path d="M6 6h15l-2 7H7L6 6Z" />
                                                <path d="M6 6l-2-2H2" />
                                                <circle cx="9" cy="18" r="1.5" />
                                                <circle cx="17" cy="18" r="1.5" />
                                            </svg>
                                        </span>
                                        <div>{{ row.title }}</div>
                                    </div>
                                </td>
                                <td class="py-5">
                                    <span class="inline-flex rounded-md bg-slate-100 px-3 py-1 text-xs font-semibold text-slate-500">{{ row.categoryLabel }}</span>
                                </td>
                                <td class="py-5 text-slate-500">{{ row.accountLabel }}</td>
                                <td class="py-5 text-slate-500">{{ row.kind === 'income' ? 'Hoje, 10:00' : '10 Jan 2026' }}</td>
                                <td class="py-5">
                                    <span
                                        class="inline-flex rounded-full px-3 py-1 text-[10px] font-bold uppercase tracking-wide"
                                        :class="row.status === 'pending' ? 'bg-amber-50 text-amber-700' : 'bg-emerald-50 text-emerald-700'"
                                    >
                                        {{ row.status === 'pending' ? 'Pendente' : 'Pago' }}
                                    </span>
                                </td>
                                <td class="py-5 text-right">
                                    <div class="flex items-center justify-end gap-3">
                                        <div class="font-bold" :class="row.kind === 'income' ? 'text-emerald-600' : 'text-slate-700'">
                                            {{ row.kind === 'income' ? '+' : '-' }} {{ formatMoney(row.amount).replace('R$', 'R$') }}
                                        </div>
                                        <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M9 18l6-6-6-6" />
                                        </svg>
                                    </div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <DesktopImportChooserModal :open="desktopImportChooserOpen" @close="desktopImportChooserOpen = false" @choose="onDesktopImportChoose" />
        <DesktopTransactionDrawer
            :open="desktopDrawerOpen"
            :entry="desktopSelectedEntry"
            @close="desktopDrawerOpen = false"
            @edit="handleDesktopEdit"
            @delete="deleteDesktopSelected"
        />
	        <DesktopTransactionModal
	            :open="desktopTransactionOpen"
	            :kind="desktopTransactionKind"
	            :initial="desktopTransactionInitial"
	            @close="desktopTransactionOpen = false"
	            @save="handleDesktopSave"
	        />
	        <TransactionFilterModal
	            :open="filterOpen"
	            :categories="filterCategories"
	            :initial="filterState"
            :results-count="filteredEntries.length"
            @close="filterOpen = false"
            @clear="clearFilters"
            @apply="applyFilters"
        />
        <ImportInvoiceModal :open="importOpen" @close="importOpen = false" @imported="onInvoiceImported" />
        <MobileToast :show="toastOpen" :message="toastMessage" @dismiss="toastOpen = false" />
    </DesktopShell>
</template>
