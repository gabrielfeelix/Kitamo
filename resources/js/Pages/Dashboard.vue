<script setup lang="ts">
import { computed, ref } from 'vue';
import { Link, usePage } from '@inertiajs/vue3';
import { requestJson } from '@/lib/kitamoApi';
import { buildTransactionRequest } from '@/lib/transactions';
import type { BootstrapData, Entry, Goal } from '@/types/kitamo';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import TransactionModal, { type TransactionModalPayload } from '@/Components/TransactionModal.vue';
import DesktopTransactionModal from '@/Components/DesktopTransactionModal.vue';
import DesktopTransactionDrawer from '@/Components/DesktopTransactionDrawer.vue';
import TransactionDetailModal, { type TransactionDetail } from '@/Components/TransactionDetailModal.vue';
import MobileToast from '@/Components/MobileToast.vue';
import { useMediaQuery } from '@/composables/useMediaQuery';

const page = usePage();
const userName = computed(() => page.props.auth?.user?.name ?? 'Gabriel');
const bootstrap = computed(
    () => (page.props.bootstrap ?? { entries: [], goals: [], accounts: [], categories: [] }) as BootstrapData,
);

const isMobile = useMediaQuery('(max-width: 767px)');

const initials = computed(() => {
    const parts = String(userName.value).trim().split(/\s+/).filter(Boolean);
    const first = parts[0]?.[0] ?? 'G';
    const last = parts.length > 1 ? parts[parts.length - 1]?.[0] : 'F';
    return `${first}${last}`.toUpperCase();
});

const todayLabel = computed(() =>
    new Intl.DateTimeFormat('pt-BR', {
        day: 'numeric',
        month: 'long',
        year: 'numeric',
    }).format(new Date()),
);

const formatBRL = (value: number) =>
    new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL',
    }).format(value);

const desktopEntries = ref<Entry[]>(bootstrap.value.entries ?? []);
const desktopGoals = ref<Goal[]>(bootstrap.value.goals ?? []);

const computeTotals = (items: Entry[]) => {
    let income = 0;
    let expense = 0;
    for (const entry of items) {
        if (entry.kind === 'income') income += entry.amount;
        else expense += entry.amount;
    }
    return { income, expense, balance: income - expense };
};

const saldoAtual = ref(0);
const receitas = ref(0);
const despesas = ref(0);

const syncTotals = () => {
    const totals = computeTotals(desktopEntries.value);
    saldoAtual.value = totals.balance;
    receitas.value = totals.income;
    despesas.value = totals.expense;
};

syncTotals();

const cashflowSeries = computed(() => {
    const entries = desktopEntries.value;
    if (!entries.length) return [];

    const monthLabels = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    const now = new Date();
    const months = Array.from({ length: 6 }, (_, idx) => {
        const date = new Date(now.getFullYear(), now.getMonth() - (5 - idx), 1);
        return {
            key: `${date.getFullYear()}-${date.getMonth() + 1}`,
            label: monthLabels[date.getMonth()],
            total: 0,
            highlight: idx === 5,
        };
    });

    for (const entry of entries) {
        if (!entry.transactionDate) continue;
        const date = new Date(entry.transactionDate);
        const key = `${date.getFullYear()}-${date.getMonth() + 1}`;
        const target = months.find((m) => m.key === key);
        if (!target) continue;
        target.total += entry.kind === 'income' ? entry.amount : -entry.amount;
    }

    const maxValue = Math.max(...months.map((m) => Math.abs(m.total)), 1);

    return months.map((month) => {
        const ratio = Math.abs(month.total) / maxValue;
        const height = Math.round(70 + ratio * 90);
        const tone = ratio > 0.66 ? 'bg-[#14B8A6]' : ratio > 0.33 ? 'bg-[#34D399]' : 'bg-[#A7F3D0]';
        return {
            label: month.label,
            height,
            amount: Math.abs(month.total),
            tone,
            highlight: month.highlight,
        };
    });
});

type UpcomingBill = {
    id: string;
    month: string;
    day: string;
    title: string;
    subtitle: string;
    amountLabel: string;
    paid: boolean;
};

const buildUpcomingBills = (entries: Entry[]): UpcomingBill[] => {
    const formatter = new Intl.DateTimeFormat('pt-BR', { month: 'short' });

    return entries
        .filter((entry) => entry.kind === 'expense')
        .filter((entry) => Boolean(entry.transactionDate))
        .map((entry) => {
            const date = entry.transactionDate ? new Date(entry.transactionDate) : new Date();
            const month = formatter.format(date).replace('.', '').toLowerCase();
            const day = String(date.getDate()).padStart(2, '0');
            return {
                id: entry.id,
                month,
                day,
                title: entry.title,
                subtitle: entry.categoryLabel,
                amountLabel: formatBRL(entry.amount),
                paid: entry.status === 'paid',
            };
        })
        .sort((a, b) => (a.day > b.day ? 1 : -1))
        .slice(0, 3);
};

const upcomingBills = computed(() => buildUpcomingBills(desktopEntries.value));

const recentEntries = computed(() => {
    return desktopEntries.value
        .filter((entry) => Boolean(entry.transactionDate))
        .sort((a, b) => {
            const dateA = new Date(a.transactionDate!);
            const dateB = new Date(b.transactionDate!);
            return dateB.getTime() - dateA.getTime();
        })
        .slice(0, 5);
});

const formatEntryDate = (date?: string) => {
    if (!date) return '';
    const entryDate = new Date(date);
    const today = new Date();
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);

    if (entryDate.toDateString() === today.toDateString()) return 'Hoje';
    if (entryDate.toDateString() === yesterday.toDateString()) return 'Ontem';

    return new Intl.DateTimeFormat('pt-BR', { day: '2-digit', month: '2-digit' }).format(entryDate);
};

const creditCards = computed(() =>
    (bootstrap.value.accounts ?? [])
        .filter((account) => account.type === 'credit_card')
        .map((account) => ({
            id: account.id,
            label: account.name,
            subtitle: 'Fatura aberta',
            amount: account.current_balance,
        })),
);

const mobileAccounts = computed(() =>
    (bootstrap.value.accounts ?? []).slice(0, 3).map((account) => ({
        id: account.id,
        name: account.name,
        subtitle: account.type === 'credit_card' ? 'Fatura aberta' : 'Saldo atual',
        amount: account.current_balance ?? 0,
        type: account.type,
    })),
);

const needsAttention = computed(() => saldoAtual.value < 0);

const hasEntries = computed(() => desktopEntries.value.length > 0);
const hasGoals = computed(() => desktopGoals.value.length > 0);
const hasCashflow = computed(() => cashflowSeries.value.length > 0);
const hasUpcomingBills = computed(() => upcomingBills.value.length > 0);

const toastOpen = ref(false);
const toastMessage = ref('');
const showToast = (message: string) => {
    toastMessage.value = message;
    toastOpen.value = true;
};

const replaceEntry = (entry: Entry) => {
    const idx = desktopEntries.value.findIndex((item) => item.id === entry.id);
    if (idx >= 0) desktopEntries.value[idx] = entry;
    else desktopEntries.value.unshift(entry);
    syncTotals();
};

const removeEntry = (id: string) => {
    desktopEntries.value = desktopEntries.value.filter((entry) => entry.id !== id);
    syncTotals();
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

const desktopDrawerOpen = ref(false);
const desktopSelectedEntry = ref<Entry | null>(null);

const mobileDetailOpen = ref(false);
const mobileSelectedEntry = ref<Entry | null>(null);

const formatDetailDate = (date?: string) => {
    if (!date) return '';
    return new Intl.DateTimeFormat('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric' }).format(new Date(date));
};

const toAccountIcon = (label: string): TransactionDetail['accountIcon'] => {
    const normalized = label.toLowerCase();
    if (normalized.includes('carteira') || normalized.includes('wallet')) return 'wallet';
    if (normalized.includes('card') || normalized.includes('crédito') || normalized.includes('credito')) return 'card';
    return 'bank';
};

const toCategoryIcon = (entry: Entry): TransactionDetail['categoryIcon'] => {
    const key = (entry.categoryKey ?? '').toLowerCase();
    if (key === 'food') return 'food';
    if (key === 'home') return 'home';
    if (key === 'car') return 'car';

    const icon = (entry.icon ?? '').toLowerCase();
    if (icon.includes('home')) return 'home';
    if (icon.includes('car')) return 'car';
    if (icon.includes('cart')) return 'cart';
    return 'bolt';
};

const mobileTransactionDetail = computed<TransactionDetail | null>(() => {
    const entry = mobileSelectedEntry.value;
    if (!entry) return null;
    return {
        id: entry.id,
        title: entry.title,
        amount: entry.amount,
        kind: entry.kind,
        status: entry.status,
        categoryLabel: entry.categoryLabel,
        categoryIcon: toCategoryIcon(entry),
        accountLabel: entry.accountLabel,
        accountIcon: toAccountIcon(entry.accountLabel),
        dateLabel: formatDetailDate(entry.transactionDate) || entry.dateLabel,
        installmentLabel: entry.installment ?? undefined,
    };
});

const transactionOpen = ref(false);
const transactionKind = ref<'expense' | 'income' | 'transfer'>('expense');
const transactionInitial = ref<TransactionModalPayload | null>(null);
const openTransaction = (kind: 'expense' | 'income' | 'transfer') => {
    transactionKind.value = kind;
    transactionInitial.value = null;
    desktopTransactionInitial.value = null;
    if (isMobile.value) transactionOpen.value = true;
    else desktopTransactionOpen.value = true;
};

const desktopTransactionOpen = ref(false);
const desktopTransactionInitial = ref<TransactionModalPayload | null>(null);
const openDesktopTransaction = () => {
    openTransaction('expense');
};

const parseInstallmentCount = (installment?: string | null) => {
    if (!installment) return 3;
    const match = installment.match(/\/\s*(\d+)/);
    if (!match) return 3;
    const count = Number(match[1]);
    return Number.isFinite(count) && count > 0 ? count : 3;
};

const openEntryEdit = (entry: Entry) => {
    transactionKind.value = entry.kind;
    const initial: TransactionModalPayload = {
        id: entry.id,
        kind: entry.kind,
        amount: entry.amount,
        description: entry.title,
        category: entry.categoryLabel,
        account: entry.accountLabel,
        dateKind: 'today',
        dateOther: '',
        isInstallment: Boolean(entry.installment),
        installmentCount: parseInstallmentCount(entry.installment),
        isPaid: entry.status === 'paid',
        transferFrom: 'Banco Inter',
        transferTo: 'Carteira',
        transferDescription: '',
    };

    if (isMobile.value) {
        transactionInitial.value = initial;
        transactionOpen.value = true;
        return;
    }

    desktopTransactionInitial.value = initial;
    desktopTransactionOpen.value = true;
};

const openEntryDetail = (entry: Entry) => {
    if (isMobile.value) {
        mobileSelectedEntry.value = entry;
        mobileDetailOpen.value = true;
        return;
    }

    desktopSelectedEntry.value = entry;
    desktopDrawerOpen.value = true;
};

const handleDetailEdit = () => {
    const entry = isMobile.value ? mobileSelectedEntry.value : desktopSelectedEntry.value;
    if (!entry) return;
    desktopDrawerOpen.value = false;
    mobileDetailOpen.value = false;
    openEntryEdit(entry);
};

const handleDetailDelete = async () => {
    const target = isMobile.value ? mobileSelectedEntry.value : desktopSelectedEntry.value;
    if (!target) return;
    await requestJson(route('transactions.destroy', target.id), { method: 'DELETE' });
    removeEntry(target.id);
    desktopDrawerOpen.value = false;
    mobileDetailOpen.value = false;
    showToast('Lançamento excluído');
};

const handleDetailMarkPaid = async () => {
    if (!desktopSelectedEntry.value) return;
    if (desktopSelectedEntry.value.kind !== 'expense') return;
    const nextStatus: Entry['status'] = desktopSelectedEntry.value.status === 'paid' ? 'pending' : 'paid';
    const payload = { ...entryToRequest({ ...desktopSelectedEntry.value, status: nextStatus }), isPaid: nextStatus === 'paid' };
    const response = await requestJson<{ entry: Entry }>(route('transactions.update', desktopSelectedEntry.value.id), {
        method: 'PATCH',
        body: JSON.stringify(payload),
    });
    replaceEntry(response.entry);
    desktopSelectedEntry.value = response.entry;
    showToast(nextStatus === 'paid' ? 'Conta marcada como paga' : 'Conta marcada como pendente');
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

const toggleBillPaid = async (id: string) => {
    const entry = desktopEntries.value.find((item) => item.id === id);
    if (!entry || entry.kind !== 'expense') return;
    const nextStatus: Entry['status'] = entry.status === 'paid' ? 'pending' : 'paid';
    const payload = { ...entryToRequest({ ...entry, status: nextStatus }), isPaid: nextStatus === 'paid' };

    const response = await requestJson<{ entry: Entry }>(route('transactions.update', entry.id), {
        method: 'PATCH',
        body: JSON.stringify(payload),
    });

    replaceEntry(response.entry);
    if (nextStatus === 'paid') showToast('Conta marcada como paga');
};

const openBillDetails = (id: string) => {
    const entry = desktopEntries.value.find((item) => item.id === id);
    if (!entry) return;

    openEntryDetail(entry);
};
</script>

<template>
    <MobileShell v-if="isMobile">
        <header class="flex items-start justify-between pt-2">
            <div>
                <div class="text-2xl font-semibold tracking-tight text-slate-900">Visão</div>
                <div class="text-sm text-slate-500">
                    {{ todayLabel }}
                </div>
            </div>

            <div class="flex items-center gap-2">
                <Link
                    :href="route('settings.notifications')"
                    class="flex h-11 w-11 items-center justify-center rounded-full border border-slate-200 bg-white text-slate-600 shadow-sm hover:bg-slate-50"
                    aria-label="Notificações"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M6 8a6 6 0 0 1 12 0c0 7 3 7 3 7H3s3 0 3-7" />
                        <path d="M10 21a2 2 0 0 0 4 0" />
                    </svg>
                </Link>

                <Link
                    :href="route('settings')"
                    class="flex h-11 w-11 items-center justify-center rounded-full bg-slate-200 text-sm font-semibold text-slate-700"
                    aria-label="Abrir configurações"
                >
                    {{ initials }}
                </Link>
            </div>
        </header>

        <section class="mt-7 text-center">
            <div class="text-xs font-semibold uppercase tracking-wide text-slate-400">Saldo Atual</div>
            <div class="mt-3 text-5xl font-semibold tracking-tight text-teal-500">
                {{ formatBRL(saldoAtual) }}
            </div>
            <div class="mt-2 flex items-center justify-center gap-2 text-xs font-semibold text-slate-400">
                <span class="h-2 w-2 rounded-full bg-emerald-500"></span>
                Atualizado agora
            </div>
        </section>

        <section class="mt-6 grid grid-cols-3 gap-3">
            <Link
                :href="route('accounts.index', { kind: 'income' })"
                class="relative rounded-2xl bg-white px-3 py-4 text-center shadow-sm ring-1 ring-slate-200/60 transition hover:-translate-y-0.5"
            >
                <span class="absolute right-3 top-3 text-emerald-500">
                    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M9 18l6-6-6-6" />
                    </svg>
                </span>
                <div class="mx-auto flex h-10 w-10 items-center justify-center rounded-2xl bg-emerald-50 text-emerald-600">
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M12 21V7" />
                        <path d="M7 12l5-5 5 5" />
                    </svg>
                </div>
                <div class="mt-2 text-[10px] font-semibold uppercase tracking-wide text-slate-400">Receitas</div>
                <div class="mt-1 text-sm font-semibold text-slate-700">
                    {{ formatBRL(receitas).replace('R$', '').trim() }}
                </div>
            </Link>

            <Link
                :href="route('accounts.index', { kind: 'expense' })"
                class="relative rounded-2xl bg-white px-3 py-4 text-center shadow-sm ring-1 ring-slate-200/60 transition hover:-translate-y-0.5"
            >
                <span class="absolute right-3 top-3 text-red-500">
                    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M9 18l6-6-6-6" />
                    </svg>
                </span>
                <div class="mx-auto flex h-10 w-10 items-center justify-center rounded-2xl bg-red-50 text-red-500">
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M12 3v14" />
                        <path d="M7 12l5 5 5-5" />
                    </svg>
                </div>
                <div class="mt-2 text-[10px] font-semibold uppercase tracking-wide text-slate-400">Despesas</div>
                <div class="mt-1 text-sm font-semibold text-slate-700">
                    {{ formatBRL(despesas).replace('R$', '').trim() }}
                </div>
            </Link>

            <button
                type="button"
                class="rounded-2xl bg-white px-3 py-4 text-center shadow-sm ring-1 ring-slate-200/60"
            >
                <div class="mx-auto flex h-10 w-10 items-center justify-center rounded-2xl bg-teal-50 text-teal-600">
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M12 3v18" />
                        <path d="M7 7h5a3 3 0 1 1 0 6H7" />
                    </svg>
                </div>
                <div class="mt-2 text-[10px] font-semibold uppercase tracking-wide text-slate-400">Balanço</div>
                <div class="mt-1 text-sm font-semibold text-emerald-600">+{{ formatBRL(receitas - despesas).replace('R$', '').trim() }}</div>
            </button>
        </section>

        <section v-if="needsAttention" class="mt-5 rounded-3xl bg-amber-50 px-4 py-4 shadow-sm ring-1 ring-amber-200/60">
            <div class="flex gap-4">
                <div class="flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl bg-amber-100 text-amber-600">
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M12 9v4" />
                        <path d="M12 17h.01" />
                        <path d="M10 3h4l8 18H2L10 3Z" />
                    </svg>
                </div>
                <div class="flex-1">
                    <div class="text-sm font-semibold text-slate-900">
                        Atenção: <span class="font-semibold text-red-500">Saldo negativo de {{ formatBRL(Math.abs(saldoAtual)) }}</span> no momento.
                    </div>
                    <Link :href="route('accounts.index')" class="mt-2 inline-flex items-center gap-1 text-sm font-semibold text-amber-700">
Ver lançamentos
                        <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 18l6-6-6-6" />
                        </svg>
                    </Link>
                </div>
            </div>
        </section>

        <section class="mt-5 rounded-3xl bg-white p-4 shadow-sm ring-1 ring-slate-200/60">
            <div class="flex items-center justify-between">
                <div class="flex items-center gap-3">
                    <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-emerald-50 text-emerald-600">
                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M4 19V5" />
                            <path d="M10 19V9" />
                            <path d="M16 19v-4" />
                            <path d="M22 19V7" />
                        </svg>
                    </span>
                    <div class="text-base font-semibold text-slate-900">Projeção 30 dias</div>
                </div>
                <div class="rounded-full bg-red-50 px-3 py-1 text-xs font-semibold text-red-500">31/jan: -R$ 250</div>
            </div>

            <div v-if="hasCashflow" class="mt-4">
                <div class="grid grid-cols-6 items-end gap-3">
                    <div v-for="bar in cashflowSeries" :key="bar.label" class="text-center">
                        <div class="text-[10px] font-semibold text-slate-400">{{ formatBRL(bar.amount).replace('R$', '').trim() }}</div>
                        <div class="mx-auto mt-2 w-8 rounded-2xl" :class="bar.tone" :style="{ height: `${bar.height}px` }"></div>
                        <div class="mt-2 text-[10px] font-semibold" :class="bar.highlight ? 'text-emerald-600' : 'text-slate-400'">{{ bar.label }}</div>
                    </div>
                </div>
            </div>
            <div v-else class="mt-4 rounded-2xl border border-dashed border-slate-200 bg-slate-50 px-4 py-6 text-center">
                <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-white text-slate-400">
                    <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M4 19V5" />
                        <path d="M10 19V9" />
                        <path d="M16 19v-4" />
                        <path d="M22 19V7" />
                    </svg>
                </div>
                <div class="mt-3 text-sm font-semibold text-slate-900">Sem projeções ainda</div>
                <div class="mt-1 text-xs text-slate-500">Adicione seus primeiros lançamentos para ver o fluxo.</div>
            </div>
        </section>

        <section class="mt-6 rounded-3xl bg-white p-4 shadow-sm ring-1 ring-slate-200/60">
            <div class="flex items-center justify-between">
                <div class="text-lg font-semibold text-slate-900">Cartões de crédito</div>
                <button class="rounded-2xl p-2 text-slate-400 hover:bg-slate-100" type="button" aria-label="Adicionar cartão">
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M12 5v14" />
                        <path d="M5 12h14" />
                    </svg>
                </button>
            </div>

            <div v-if="creditCards.length === 0" class="mt-4 rounded-2xl border border-slate-200 bg-slate-50 px-4 py-6 text-center">
                <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-white text-slate-400">
                    <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <rect x="3" y="5" width="18" height="14" rx="3" />
                        <path d="M3 10h18" />
                    </svg>
                </div>
                <div class="mt-3 text-sm font-semibold text-slate-900">Você ainda não possui cartões cadastrados.</div>
                <div class="mt-1 text-xs text-slate-500">Melhore seu controle financeiro agora!</div>
                <button type="button" class="mt-4 rounded-full bg-emerald-500 px-4 py-2 text-xs font-semibold text-white">Adicionar cartões</button>
            </div>

            <div v-else class="mt-4 space-y-3">
                <Link
                    v-for="card in creditCards"
                    :key="card.id"
                    :href="route('accounts.index', { account: card.label })"
                    class="flex items-center justify-between rounded-2xl border border-slate-100 bg-white px-4 py-4 shadow-sm ring-1 ring-slate-200/60"
                >
                    <div class="flex items-center gap-3">
                        <span class="flex h-11 w-11 items-center justify-center rounded-2xl bg-slate-900 text-white">
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="5" width="18" height="14" rx="3" />
                                <path d="M3 10h18" />
                            </svg>
                        </span>
                        <div>
                            <div class="text-sm font-semibold text-slate-900">{{ card.label }}</div>
                            <div class="text-xs text-slate-500">{{ card.subtitle }}</div>
                        </div>
                    </div>
                    <div class="text-sm font-semibold text-slate-900">R$ {{ card.amount.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) }}</div>
                </Link>
            </div>
        </section>

        <section class="mt-6">
            <div class="flex items-center justify-between">
                <div class="text-lg font-semibold text-slate-900">Próximas contas</div>
                <Link :href="route('accounts.index')" class="text-sm font-semibold text-emerald-600">Ver todas</Link>
            </div>

            <div v-if="hasUpcomingBills" class="mt-4 space-y-3">
                <div
                    v-for="bill in upcomingBills"
                    :key="bill.id"
                    class="flex items-center gap-4 rounded-3xl bg-white px-4 py-4 shadow-sm ring-1 ring-slate-200/60 cursor-pointer hover:bg-slate-50 active:bg-slate-100 transition-colors"
                    @click="openBillDetails(bill.id)"
                >
                    <div class="flex h-14 w-14 flex-col items-center justify-center rounded-2xl bg-slate-50 text-slate-600 ring-1 ring-slate-200/70">
                        <div class="text-[10px] font-semibold uppercase text-slate-400">{{ bill.month }}</div>
                        <div class="text-base font-semibold">{{ bill.day }}</div>
                    </div>
                    <div class="min-w-0 flex-1">
                        <div class="truncate text-sm font-semibold text-slate-900">{{ bill.title }}</div>
                        <div class="truncate text-xs text-slate-400">{{ bill.subtitle }}</div>
                    </div>
                    <div class="flex flex-col items-end gap-2 text-right">
                        <div
                            class="text-sm font-semibold"
                            :class="bill.paid ? 'text-emerald-600 line-through' : 'text-red-500'"
                        >
                            - {{ bill.amountLabel }}
                        </div>
                        <button
                            type="button"
                            class="flex h-6 w-6 items-center justify-center rounded-full border-2"
                            :class="bill.paid ? 'border-emerald-500 bg-emerald-500' : 'border-slate-200 bg-white'"
                            :aria-label="bill.paid ? 'Marcar como não paga' : 'Marcar como paga'"
                            @click.stop="toggleBillPaid(bill.id)"
                        >
                            <svg v-if="bill.paid" class="h-4 w-4 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">
                                <path d="M20 6 9 17l-5-5" />
                            </svg>
                        </button>
                    </div>
                </div>
            </div>
        </section>

        <template #fab>
            <button
                type="button"
                class="fixed bottom-[calc(5.5rem+env(safe-area-inset-bottom)+1rem)] right-5 z-50 flex h-14 w-14 items-center justify-center rounded-full bg-teal-500 text-white shadow-xl shadow-teal-500/30"
                aria-label="Adicionar"
                @click="openTransaction('expense')"
            >
                <svg class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M12 5v14" />
                    <path d="M5 12h14" />
                </svg>
            </button>
        </template>

        <TransactionModal :open="transactionOpen" :kind="transactionKind" :initial="transactionInitial" @close="transactionOpen = false" @save="onTransactionSave" />
        <TransactionDetailModal
            :open="mobileDetailOpen"
            :transaction="mobileTransactionDetail"
            @close="mobileDetailOpen = false"
            @edit="handleDetailEdit"
            @delete="handleDetailDelete"
            @duplicate="handleDetailEdit"
        />
        <MobileToast :show="toastOpen" :message="toastMessage" @dismiss="toastOpen = false" />
    </MobileShell>

    <DesktopShell v-else title="Visão Geral" subtitle="Domingo, 11 Jan 2026" @new-transaction="openDesktopTransaction">
        <div class="grid grid-cols-[1fr_360px] gap-8">
            <div class="space-y-8">
                <div class="grid grid-cols-3 gap-6">
                    <div class="relative overflow-hidden rounded-2xl bg-gradient-to-br from-[#14B8A6] to-[#10B981] p-7 text-white shadow-lg shadow-emerald-500/20">
                        <div class="absolute -right-10 -top-10 h-32 w-32 rounded-full bg-white/15"></div>
                        <div class="absolute -right-2 top-12 h-10 w-20 rounded-2xl bg-white/10"></div>

                        <div class="text-sm font-semibold opacity-95">Saldo Total</div>
                        <div class="mt-2 text-4xl font-bold tracking-tight">
                            R$ {{ saldoAtual.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) }}
                        </div>
                        <div class="mt-5 inline-flex items-center gap-2 rounded-full bg-white/20 px-4 py-2 text-xs font-semibold">
                            <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M12 21V7" />
                                <path d="M7 12l5-5 5 5" />
                            </svg>
                            +12% esse mês
                        </div>
                    </div>

                    <Link
                        :href="route('accounts.index', { kind: 'income' })"
                        class="group relative rounded-2xl bg-white p-7 shadow-sm ring-1 ring-slate-200/60 transition hover:-translate-y-0.5"
                    >
                        <span class="absolute right-5 top-5 text-emerald-500 opacity-70 transition group-hover:opacity-100">
                            <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M9 18l6-6-6-6" />
                            </svg>
                        </span>
                        <div class="flex items-start justify-between">
                            <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-emerald-50 text-emerald-600">
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M12 21V7" />
                                    <path d="M7 12l5-5 5 5" />
                                </svg>
                            </span>
                            <span class="rounded-full bg-emerald-50 px-3 py-1 text-xs font-semibold text-emerald-600">+2.5%</span>
                        </div>
                        <div class="mt-4 text-sm font-semibold text-slate-400">Receitas</div>
                        <div class="mt-1 text-2xl font-bold text-slate-900">
                            R$ {{ receitas.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) }}
                        </div>
                    </Link>

                    <Link
                        :href="route('accounts.index', { kind: 'expense' })"
                        class="group relative rounded-2xl bg-white p-7 shadow-sm ring-1 ring-slate-200/60 transition hover:-translate-y-0.5"
                    >
                        <span class="absolute right-5 top-5 text-red-500 opacity-70 transition group-hover:opacity-100">
                            <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M9 18l6-6-6-6" />
                            </svg>
                        </span>
                        <div class="flex items-start justify-between">
                            <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-red-50 text-red-500">
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M12 3v14" />
                                    <path d="M7 12l5 5 5-5" />
                                </svg>
                            </span>
                            <span class="rounded-full bg-slate-100 px-3 py-1 text-xs font-semibold text-slate-500">Estável</span>
                        </div>
                        <div class="mt-4 text-sm font-semibold text-slate-400">Despesas</div>
                        <div class="mt-1 text-2xl font-bold text-slate-900">
                            R$ {{ despesas.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) }}
                        </div>
                    </Link>
                </div>

                <div class="rounded-2xl bg-white p-7 shadow-sm ring-1 ring-slate-200/60">
                    <div class="flex items-center justify-between">
                        <div class="text-base font-semibold text-slate-900">Fluxo de Caixa</div>
                        <Link :href="route('analysis')" class="inline-flex items-center gap-2 rounded-xl bg-slate-50 px-4 py-2 text-sm font-semibold text-slate-500">
                            Últimos 6 meses
                            <svg class="h-4 w-4 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M6 9l6 6 6-6" />
                            </svg>
                        </Link>
                    </div>

                    <div v-if="hasCashflow" class="mt-8 flex items-end justify-between gap-4">
                        <div v-for="item in cashflowSeries" :key="item.label" class="group flex-1">
                            <div class="relative mx-auto w-full">
                                <div class="pointer-events-none absolute -top-8 left-1/2 -translate-x-1/2 rounded-full bg-slate-900 px-3 py-1 text-[11px] font-semibold text-white opacity-0 transition group-hover:opacity-100">
                                    {{ formatBRL(item.amount) }}
                                </div>
                                <div class="mx-auto w-full rounded-t-2xl" :class="item.tone" :style="{ height: `${item.height}px` }"></div>
                            </div>
                            <div class="mt-3 text-center text-xs font-semibold" :class="item.highlight ? 'text-[#14B8A6]' : 'text-slate-400'">{{ item.label }}</div>
                        </div>
                    </div>
                    <div v-else class="mt-8 rounded-2xl border border-dashed border-slate-200 bg-slate-50 px-6 py-10 text-center">
                        <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-white text-slate-400">
                            <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M4 19V5" />
                                <path d="M10 19V9" />
                                <path d="M16 19v-4" />
                                <path d="M22 19V7" />
                            </svg>
                        </div>
                        <div class="mt-3 text-sm font-semibold text-slate-900">Sem fluxo registrado</div>
                        <div class="mt-1 text-xs text-slate-500">Adicione lançamentos para preencher o gráfico.</div>
                    </div>
                </div>

                <div class="rounded-2xl bg-white p-7 shadow-sm ring-1 ring-slate-200/60">
                    <div class="flex items-center justify-between">
                        <div class="text-base font-semibold text-slate-900">Transações Recentes</div>
                        <Link :href="route('accounts.index')" class="text-sm font-semibold text-[#14B8A6]">Ver todas</Link>
                    </div>

                    <div v-if="hasEntries" class="mt-6 overflow-hidden rounded-2xl border border-slate-100">
                        <div class="grid grid-cols-[2fr_1fr_1fr_1fr] gap-4 bg-slate-50 px-6 py-3 text-xs font-bold uppercase tracking-wide text-slate-400">
                            <div>Transação</div>
                            <div>Categoria</div>
                            <div>Data</div>
                            <div class="text-right">Valor</div>
                        </div>

                        <div
                            v-for="row in desktopEntries.slice(0, 2)"
                            :key="row.id"
                            class="grid cursor-pointer grid-cols-[2fr_1fr_1fr_1fr] gap-4 border-t border-slate-100 px-6 py-5 text-sm font-semibold text-slate-700 hover:bg-slate-50"
                            role="button"
                            tabindex="0"
                            @click="openEntryDetail(row)"
                            @keydown.enter="openEntryDetail(row)"
                        >
                            <div class="flex items-center gap-4">
                                <span
                                    class="flex h-10 w-10 items-center justify-center rounded-2xl ring-1 ring-slate-100"
                                    :class="row.kind === 'income' ? 'bg-emerald-50 text-emerald-600' : 'bg-amber-50 text-amber-600'"
                                >
                                    <svg v-if="row.kind === 'income'" class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M12 21V7" />
                                        <path d="M7 12l5-5 5 5" />
                                    </svg>
                                    <svg v-else class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M6 6h15l-2 7H7L6 6Z" />
                                        <path d="M6 6l-2-2H2" />
                                        <circle cx="9" cy="18" r="1.5" />
                                        <circle cx="17" cy="18" r="1.5" />
                                    </svg>
                                </span>
                                <div class="truncate">{{ row.title }}</div>
                            </div>
                            <div>
                                <span class="inline-flex rounded-md bg-slate-100 px-3 py-1 text-xs font-semibold text-slate-500">{{ row.categoryLabel }}</span>
                            </div>
                            <div class="text-slate-500">20 Jan 2026</div>
                            <div class="text-right" :class="row.kind === 'income' ? 'text-emerald-600' : 'text-red-500'">
                                {{ row.kind === 'income' ? '+' : '-' }} {{ formatBRL(row.amount).replace('R$', 'R$') }}
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="space-y-8">
                <div v-if="hasEntries" class="rounded-2xl border border-amber-100 bg-amber-50 px-7 py-6">
                    <div class="flex items-start gap-3">
                        <span class="mt-0.5 flex h-8 w-8 items-center justify-center rounded-full bg-amber-100 text-amber-700">
                            <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M12 9v4" />
                                <path d="M12 17h.01" />
                                <circle cx="12" cy="12" r="9" />
                            </svg>
                        </span>
                        <div class="flex-1">
                            <div class="text-sm font-bold text-amber-700">Atenção Necessária</div>
                            <div class="mt-2 text-sm font-semibold text-amber-700/80">
                                Faltam <span class="text-red-500">R$ 200</span> para cobrir as contas previstas para os próximos 5 dias.
                            </div>
                            <Link :href="route('accounts.index')" class="mt-4 inline-flex h-9 items-center rounded-lg border border-amber-200 bg-white px-4 text-sm font-semibold text-amber-700">
                                Resolver
                            </Link>
                        </div>
                    </div>
                </div>

                <div class="rounded-2xl bg-white p-7 shadow-sm ring-1 ring-slate-200/60">
                    <div class="text-sm font-semibold text-slate-900">Transferência Rápida</div>
                    <div class="mt-5 flex items-center gap-4">
                        <button type="button" class="flex h-12 w-12 items-center justify-center rounded-full border border-dashed border-slate-200 text-slate-400" @click="openTransaction('transfer')">
                            <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M12 5v14" />
                                <path d="M5 12h14" />
                            </svg>
                        </button>
                        <div class="flex items-center gap-4">
                            <div class="flex h-12 w-12 items-center justify-center rounded-full bg-slate-200 text-xs font-bold text-slate-600">M</div>
                            <div class="flex h-12 w-12 items-center justify-center rounded-full bg-slate-200 text-xs font-bold text-slate-600">A</div>
                        </div>
                    </div>

                    <div class="mt-6 flex items-center gap-3 rounded-xl bg-slate-50 px-4 py-3 ring-1 ring-slate-200/60">
                        <div class="text-sm font-semibold text-slate-400">R$ 0,00</div>
                        <button type="button" class="ml-auto inline-flex h-9 items-center justify-center rounded-lg bg-[#14B8A6] px-4 text-sm font-semibold text-white" @click="openTransaction('transfer')">
                            Enviar
                        </button>
                    </div>
                </div>

                <div class="rounded-2xl bg-white p-7 shadow-sm ring-1 ring-slate-200/60">
                    <div class="flex items-center justify-between">
                        <div class="text-sm font-semibold text-slate-900">Cartões de crédito</div>
                        <button type="button" class="text-slate-300 hover:text-slate-400" aria-label="Adicionar cartão">
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M12 5v14" />
                                <path d="M5 12h14" />
                            </svg>
                        </button>
                    </div>

                    <div v-if="creditCards.length === 0" class="mt-5 rounded-2xl border border-slate-200 bg-slate-50 px-5 py-6 text-center">
                        <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-white text-slate-400">
                            <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="5" width="18" height="14" rx="3" />
                                <path d="M3 10h18" />
                            </svg>
                        </div>
                        <div class="mt-3 text-sm font-semibold text-slate-900">Você ainda não possui cartões cadastrados.</div>
                        <div class="mt-1 text-xs text-slate-500">Melhore seu controle financeiro agora!</div>
                        <button type="button" class="mt-4 rounded-full bg-emerald-500 px-4 py-2 text-xs font-semibold text-white">Adicionar cartões</button>
                    </div>

                    <div v-else class="mt-5 space-y-3">
                        <Link
                            v-for="card in creditCards"
                            :key="card.id"
                            :href="route('accounts.index', { account: card.label })"
                            class="flex items-center justify-between rounded-2xl border border-slate-100 bg-white px-4 py-4"
                        >
                            <div class="flex items-center gap-3">
                                <span class="flex h-11 w-11 items-center justify-center rounded-2xl bg-slate-900 text-white">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <rect x="3" y="5" width="18" height="14" rx="3" />
                                        <path d="M3 10h18" />
                                    </svg>
                                </span>
                                <div>
                                    <div class="text-sm font-semibold text-slate-900">{{ card.label }}</div>
                                    <div class="text-xs text-slate-500">{{ card.subtitle }}</div>
                                </div>
                            </div>
                            <div class="text-sm font-semibold text-slate-900">R$ {{ card.amount.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) }}</div>
                        </Link>
                    </div>
                </div>

                <div class="rounded-2xl bg-white p-7 shadow-sm ring-1 ring-slate-200/60">
                    <div class="flex items-center justify-between">
                        <div class="text-sm font-semibold text-slate-900">Metas Principais</div>
                        <Link :href="route('goals.index')" class="text-slate-300 hover:text-slate-400" aria-label="Ver metas">
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M9 18l6-6-6-6" />
                            </svg>
                        </Link>
                    </div>

                    <div v-if="hasGoals" class="mt-6 space-y-5">
                        <Link v-for="g in desktopGoals.slice(0, 2)" :key="g.id" :href="route('goals.show', { goalId: g.id })" class="block">
                            <div class="flex items-center justify-between text-sm font-semibold text-slate-700 hover:text-slate-900">
                                <div>{{ g.title }}</div>
                                <div class="text-slate-400">{{ Math.min(100, Math.round((g.current / g.target) * 100)) }}%</div>
                            </div>
                            <div class="mt-3 h-2 w-full rounded-full bg-slate-100">
                                <div
                                    class="h-2 rounded-full"
                                    :class="g.icon === 'plane' ? 'bg-blue-500' : 'bg-[#14B8A6]'"
                                    :style="{ width: `${Math.min(100, Math.round((g.current / g.target) * 100))}%` }"
                                ></div>
                            </div>
                        </Link>
                    </div>
                </div>
            </div>
        </div>

        <DesktopTransactionModal :open="desktopTransactionOpen" :kind="transactionKind" :initial="desktopTransactionInitial" @close="desktopTransactionOpen = false" @save="onTransactionSave" />

        <DesktopTransactionDrawer
            :open="desktopDrawerOpen"
            :entry="desktopSelectedEntry"
            @close="desktopDrawerOpen = false"
            @edit="handleDetailEdit"
            @delete="handleDetailDelete"
            @mark-paid="handleDetailMarkPaid"
        />
        <MobileToast :show="toastOpen" :message="toastMessage" @dismiss="toastOpen = false" />
    </DesktopShell>
</template>
