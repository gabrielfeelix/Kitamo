<script setup lang="ts">
import { computed, ref } from 'vue';
import { Link, usePage } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import TransactionModal, { type TransactionModalPayload } from '@/Components/TransactionModal.vue';
import DesktopTransactionModal from '@/Components/DesktopTransactionModal.vue';
import DesktopTransactionDrawer from '@/Components/DesktopTransactionDrawer.vue';
import MobileToast from '@/Components/MobileToast.vue';
import { useMediaQuery } from '@/composables/useMediaQuery';
import { deleteEntry, getEntries, getGoals, upsertEntry, type Entry } from '@/stores/localStore';

const page = usePage();
const userName = computed(() => page.props.auth?.user?.name ?? 'Gabriel');

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

const saldoAtual = ref(1450);
const receitas = ref(2500);
const despesas = ref(1350);


const cashflowSeries = [
    { label: 'Ago', height: 70, amount: 1200, tone: 'bg-[#A7F3D0]', highlight: false },
    { label: 'Set', height: 110, amount: 1850, tone: 'bg-[#A7F3D0]', highlight: false },
    { label: 'Out', height: 90, amount: 1500, tone: 'bg-[#A7F3D0]', highlight: false },
    { label: 'Nov', height: 140, amount: 2300, tone: 'bg-[#34D399]', highlight: false },
    { label: 'Dez', height: 160, amount: 2600, tone: 'bg-[#14B8A6]', highlight: false },
    { label: 'Jan', height: 120, amount: 2100, tone: 'bg-[#10B981]', highlight: true },
];

type UpcomingBill = {
    id: string;
    month: string;
    day: string;
    title: string;
    subtitle: string;
    amountLabel: string;
    paid: boolean;
};

const upcomingBills = ref<UpcomingBill[]>([
    { id: '1', month: 'jan', day: '15', title: 'Conta de luz', subtitle: 'Copel', amountLabel: 'R$ 180', paid: false },
    { id: '2', month: 'jan', day: '18', title: 'Internet', subtitle: 'Vivo Fibra', amountLabel: 'R$ 120', paid: false },
]);

const toastOpen = ref(false);
const toastMessage = ref('');
const showToast = (message: string) => {
    toastMessage.value = message;
    toastOpen.value = true;
};

const desktopEntries = ref<Entry[]>(getEntries());
const refreshDesktopEntries = () => {
    desktopEntries.value = getEntries();
};
const desktopGoals = ref(getGoals());

const desktopDrawerOpen = ref(false);
const desktopSelectedEntry = ref<Entry | null>(null);

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

const parseInstallmentCount = (installment?: string) => {
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
    desktopSelectedEntry.value = entry;
    desktopDrawerOpen.value = true;
};

const handleDetailEdit = () => {
    if (!desktopSelectedEntry.value) return;
    desktopDrawerOpen.value = false;
    openEntryEdit(desktopSelectedEntry.value);
};

const handleDetailDelete = () => {
    if (!desktopSelectedEntry.value) return;
    deleteEntry(desktopSelectedEntry.value.id);
    refreshDesktopEntries();
    desktopDrawerOpen.value = false;
    showToast('Lançamento excluído');
};

const handleDetailMarkPaid = () => {
    if (!desktopSelectedEntry.value) return;
    if (desktopSelectedEntry.value.kind !== 'expense') return;
    const nextStatus: Entry['status'] = desktopSelectedEntry.value.status === 'paid' ? 'pending' : 'paid';
    const updated = { ...desktopSelectedEntry.value, status: nextStatus };
    upsertEntry(updated);
    refreshDesktopEntries();
    desktopSelectedEntry.value = updated;
    showToast(nextStatus === 'paid' ? 'Conta marcada como paga' : 'Conta marcada como pendente');
};

const formatDateLabels = (date: Date) => {
    const dayLabel = String(date.getDate()).padStart(2, '0');
    const month = date
        .toLocaleString('pt-BR', { month: 'short' })
        .replace('.', '')
        .toUpperCase()
        .slice(0, 3);
    return { dayLabel, dateLabel: `DIA ${dayLabel} ${month}` };
};

const onTransactionSave = (payload: TransactionModalPayload) => {
    if (payload.kind === 'transfer') {
        showToast('Transferência realizada');
        return;
    }

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

    const entry: Entry = {
        id: `ent-${Date.now()}`,
        dateLabel,
        dayLabel,
        title: payload.description || (payload.kind === 'income' ? 'Receita' : 'Despesa'),
        subtitle: installment ?? '',
        amount: payload.amount,
        kind: payload.kind,
        status: payload.kind === 'income' ? 'received' : payload.isPaid ? 'paid' : 'pending',
        installment,
        icon,
        categoryLabel: payload.category,
        categoryKey,
        accountLabel: payload.account,
        tags: [],
    };
    upsertEntry(entry);
    refreshDesktopEntries();

    if (payload.kind === 'income') {
        receitas.value += payload.amount;
        saldoAtual.value += payload.amount;
    } else {
        despesas.value += payload.amount;
        saldoAtual.value -= payload.amount;
    }
    showToast('Movimentação salva');
};

const toggleBillPaid = (id: string) => {
    const bill = upcomingBills.value.find((b) => b.id === id);
    if (!bill) return;
    bill.paid = !bill.paid;
    if (bill.paid) showToast('Conta marcada como paga');
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

            <div class="flex h-11 w-11 items-center justify-center rounded-full bg-slate-200 text-sm font-semibold text-slate-700">
                {{ initials }}
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
            <button
                type="button"
                class="rounded-2xl bg-white px-3 py-4 text-center shadow-sm ring-1 ring-slate-200/60"
                @click="openTransaction('income')"
            >
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
            </button>

            <button
                type="button"
                class="rounded-2xl bg-white px-3 py-4 text-center shadow-sm ring-1 ring-slate-200/60"
                @click="openTransaction('expense')"
            >
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
            </button>

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

        <section class="mt-5 rounded-3xl bg-amber-50 px-4 py-4 shadow-sm ring-1 ring-amber-200/60">
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
                        Atenção: <span class="font-semibold text-red-500">Faltam R$ 200</span> para cobrir 4 contas até dia 25.
                    </div>
                    <Link :href="route('accounts.index')" class="mt-2 inline-flex items-center gap-1 text-sm font-semibold text-amber-700">
                        Ver contas pendentes
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

            <div class="mt-4 overflow-hidden rounded-2xl bg-white">
                <svg class="h-40 w-full" viewBox="0 0 320 160" fill="none">
                    <path d="M20 96C64 92 100 84 132 72C164 60 188 56 212 72C236 88 264 108 300 96" stroke="#14B8A6" stroke-width="4" stroke-linecap="round" />
                    <path d="M16 100H304" stroke="#EF4444" stroke-width="2" stroke-dasharray="6 6" />
                    <circle cx="192" cy="70" r="5" fill="#EF4444" />
                    <text x="176" y="88" font-size="10" fill="#EF4444" font-weight="600">dia 23</text>
                    <text x="18" y="146" font-size="10" fill="#94A3B8">15</text>
                    <text x="86" y="146" font-size="10" fill="#94A3B8">20</text>
                    <text x="154" y="146" font-size="10" fill="#EF4444" font-weight="700">23</text>
                    <text x="222" y="146" font-size="10" fill="#94A3B8">28</text>
                    <text x="288" y="146" font-size="10" fill="#94A3B8">31</text>
                </svg>
                <div class="px-1 pb-1 text-center text-xs font-semibold text-slate-400">O saldo cruza o zero (negativo) no dia 23.</div>
            </div>
        </section>

        <section class="mt-6">
            <div class="flex items-center justify-between">
                <div class="text-lg font-semibold text-slate-900">Próximas contas</div>
                <Link :href="route('accounts.index')" class="text-sm font-semibold text-emerald-600">Ver todas</Link>
            </div>

            <div class="mt-4 space-y-3">
                <div
                    v-for="bill in upcomingBills"
                    :key="bill.id"
                    class="flex items-center gap-4 rounded-3xl bg-white px-4 py-4 shadow-sm ring-1 ring-slate-200/60"
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
                            @click="toggleBillPaid(bill.id)"
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
        <MobileToast :show="toastOpen" :message="toastMessage" @dismiss="toastOpen = false" />
    </MobileShell>

    <div v-else-if="false">
        <div class="grid gap-6 xl:grid-cols-[1.6fr_0.9fr]">
            <div class="space-y-6">
                <div class="rounded-[28px] bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900 p-6 text-white shadow-[0_30px_60px_-40px_rgba(15,23,42,0.8)]">
                    <div class="flex flex-wrap items-center justify-between gap-4">
                        <div class="flex items-center gap-3 text-sm font-semibold text-slate-200">
                            <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-white/10">
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <rect x="3" y="4" width="18" height="14" rx="3" />
                                    <path d="M3 10h18" />
                                </svg>
                            </span>
                            SALDO TOTAL
                        </div>
                        <div class="flex items-center gap-3">
                            <div class="rounded-2xl bg-emerald-500/15 px-4 py-2 text-sm text-emerald-300">
                                <div class="text-xs">Receitas</div>
                                <div class="text-base font-semibold">+5.240</div>
                            </div>
                            <div class="rounded-2xl bg-red-500/15 px-4 py-2 text-sm text-red-300">
                                <div class="text-xs">Gastos</div>
                                <div class="text-base font-semibold">-1.420</div>
                            </div>
                        </div>
                    </div>
                    <div class="mt-6 text-4xl font-semibold tracking-tight">R$ 15.345,67</div>
                    <p class="mt-2 text-sm text-slate-300">Atualizado em tempo real</p>
                </div>

                <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
                    <div class="rounded-2xl border border-slate-100 bg-white p-4 text-center shadow-sm">
                        <div class="mx-auto flex h-11 w-11 items-center justify-center rounded-2xl bg-slate-100 text-slate-600">
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <circle cx="12" cy="12" r="7" />
                                <circle cx="12" cy="12" r="3" />
                            </svg>
                        </div>
                        <div class="mt-3 text-sm font-semibold text-slate-700">Metas</div>
                    </div>
                    <div class="rounded-2xl border border-slate-100 bg-white p-4 text-center shadow-sm">
                        <div class="mx-auto flex h-11 w-11 items-center justify-center rounded-2xl bg-slate-100 text-slate-600">
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M12 6v6l4 2" />
                                <circle cx="12" cy="12" r="9" />
                            </svg>
                        </div>
                        <div class="mt-3 text-sm font-semibold text-slate-700">Orçamentos</div>
                    </div>
                    <div class="rounded-2xl border border-slate-100 bg-white p-4 text-center shadow-sm">
                        <div class="mx-auto flex h-11 w-11 items-center justify-center rounded-2xl bg-slate-100 text-slate-600">
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="4" y="5" width="16" height="16" rx="3" />
                                <path d="M8 3v4" />
                                <path d="M16 3v4" />
                            </svg>
                        </div>
                        <div class="mt-3 text-sm font-semibold text-slate-700">Fixos</div>
                    </div>
                    <div class="rounded-2xl border border-slate-100 bg-white p-4 text-center shadow-sm">
                        <div class="mx-auto flex h-11 w-11 items-center justify-center rounded-2xl bg-slate-100 text-slate-600">
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M7 3h8l4 4v14H7z" />
                                <path d="M15 3v4h4" />
                            </svg>
                        </div>
                        <div class="mt-3 text-sm font-semibold text-slate-700">Relatórios</div>
                    </div>
                </div>

                <div class="rounded-[28px] border border-white/70 bg-white p-6 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)]">
                    <div class="flex items-center justify-between">
                        <h2 class="text-lg font-semibold text-slate-900">Últimas atividades</h2>
                        <button class="text-sm font-semibold text-blue-600" type="button">Ver histórico completo</button>
                    </div>
                    <div class="mt-6 space-y-5">
                        <div class="flex items-center justify-between border-b border-slate-100 pb-4">
                            <div class="flex items-center gap-4">
                                <span class="flex h-12 w-12 items-center justify-center rounded-2xl bg-red-50 text-red-500">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <rect x="5" y="4" width="14" height="16" rx="4" />
                                        <path d="M8 8h8" />
                                    </svg>
                                </span>
                                <div>
                                    <div class="text-sm font-semibold text-slate-900">Starbucks</div>
                                    <div class="text-xs text-slate-500">Alimentação • Hoje</div>
                                </div>
                            </div>
                            <div class="text-sm font-semibold text-slate-900">-25.00</div>
                        </div>
                        <div class="flex items-center justify-between border-b border-slate-100 pb-4">
                            <div class="flex items-center gap-4">
                                <span class="flex h-12 w-12 items-center justify-center rounded-2xl bg-emerald-50 text-emerald-500">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M12 3v18" />
                                        <path d="M7 7h5a3 3 0 1 1 0 6H7" />
                                    </svg>
                                </span>
                                <div>
                                    <div class="text-sm font-semibold text-slate-900">Salário</div>
                                    <div class="text-xs text-slate-500">Receita • Ontem</div>
                                </div>
                            </div>
                            <div class="text-sm font-semibold text-emerald-600">+5000.00</div>
                        </div>
                        <div class="flex items-center justify-between border-b border-slate-100 pb-4">
                            <div class="flex items-center gap-4">
                                <span class="flex h-12 w-12 items-center justify-center rounded-2xl bg-red-50 text-red-500">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <rect x="5" y="4" width="14" height="16" rx="4" />
                                        <path d="M8 8h8" />
                                    </svg>
                                </span>
                                <div>
                                    <div class="text-sm font-semibold text-slate-900">Uber</div>
                                    <div class="text-xs text-slate-500">Transporte • Ontem</div>
                                </div>
                            </div>
                            <div class="text-sm font-semibold text-slate-900">-23.00</div>
                        </div>
                        <div class="flex items-center justify-between border-b border-slate-100 pb-4">
                            <div class="flex items-center gap-4">
                                <span class="flex h-12 w-12 items-center justify-center rounded-2xl bg-slate-100 text-slate-400">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <rect x="5" y="4" width="14" height="16" rx="4" />
                                        <path d="M8 8h8" />
                                    </svg>
                                </span>
                                <div>
                                    <div class="flex items-center gap-2 text-sm font-semibold text-slate-400">
                                        Spotify
                                        <span class="rounded-full bg-slate-100 px-2 py-1 text-[10px] font-semibold text-slate-400">PENDENTE</span>
                                    </div>
                                    <div class="text-xs text-slate-400">Assinatura • 04/01</div>
                                </div>
                            </div>
                            <div class="text-sm font-semibold text-slate-400">-21.90</div>
                        </div>
                        <div class="flex items-center justify-between">
                            <div class="flex items-center gap-4">
                                <span class="flex h-12 w-12 items-center justify-center rounded-2xl bg-red-50 text-red-500">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <rect x="5" y="4" width="14" height="16" rx="4" />
                                        <path d="M8 8h8" />
                                    </svg>
                                </span>
                                <div>
                                    <div class="text-sm font-semibold text-slate-900">Amazon AWS</div>
                                    <div class="text-xs text-slate-500">Serviços • 03/01</div>
                                </div>
                            </div>
                            <div class="text-sm font-semibold text-slate-900">-150.00</div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="space-y-6">
                <div class="rounded-[28px] border border-white/70 bg-white p-6 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)]">
                    <div class="flex items-center justify-between">
                        <h3 class="text-lg font-semibold text-slate-900">Minhas Contas</h3>
                        <button class="rounded-2xl p-2 text-slate-400 hover:bg-slate-100" type="button" aria-label="Adicionar conta">
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M12 5v14" />
                                <path d="M5 12h14" />
                            </svg>
                        </button>
                    </div>
                    <div class="mt-5 space-y-4">
                        <div class="flex items-center justify-between rounded-2xl border border-slate-100 px-4 py-3">
                            <div class="flex items-center gap-3">
                                <span class="flex h-11 w-11 items-center justify-center rounded-2xl bg-slate-100 text-slate-600">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M12 2l7 7-7 7-7-7 7-7Z" />
                                    </svg>
                                </span>
                                <div>
                                    <div class="text-sm font-semibold text-slate-900">Nubank C/C</div>
                                    <div class="text-xs text-slate-500">Saldo atual</div>
                                </div>
                            </div>
                            <div class="text-sm font-semibold text-slate-900">R$ 2345.67</div>
                        </div>
                        <div class="flex items-center justify-between rounded-2xl border border-slate-100 px-4 py-3">
                            <div class="flex items-center gap-3">
                                <span class="flex h-11 w-11 items-center justify-center rounded-2xl bg-emerald-50 text-emerald-500">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M12 3v18" />
                                        <path d="M8 7h8a3 3 0 1 1 0 6H8" />
                                    </svg>
                                </span>
                                <div>
                                    <div class="text-sm font-semibold text-slate-900">Dinheiro</div>
                                    <div class="text-xs text-slate-500">Saldo atual</div>
                                </div>
                            </div>
                            <div class="text-sm font-semibold text-slate-900">R$ 500.00</div>
                        </div>
                        <div class="flex items-center justify-between rounded-2xl border border-slate-100 px-4 py-3">
                            <div class="flex items-center gap-3">
                                <span class="flex h-11 w-11 items-center justify-center rounded-2xl bg-slate-900 text-white">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <rect x="3" y="5" width="18" height="14" rx="3" />
                                        <path d="M3 10h18" />
                                    </svg>
                                </span>
                                <div>
                                    <div class="text-sm font-semibold text-slate-900">Nubank Cartão</div>
                                    <div class="text-xs text-slate-500">Fatura aberta</div>
                                </div>
                            </div>
                            <div class="text-sm font-semibold text-slate-900">R$ 1450.00</div>
                        </div>
                    </div>
                    <button class="mt-4 w-full rounded-2xl border border-dashed border-slate-200 py-3 text-sm font-semibold text-slate-500" type="button">
                        Ver todas as contas
                    </button>
                </div>

                <div class="rounded-[28px] border border-white/70 bg-white p-6 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)]">
                    <div class="text-sm font-semibold text-slate-400">Balanço</div>
                    <div class="mt-4 h-2 w-full rounded-full bg-slate-100">
                        <div class="h-2 w-3/4 rounded-full bg-slate-400"></div>
                    </div>
                    <p class="mt-3 text-xs text-slate-400">Você economizou 15% mais que no mês passado.</p>
                </div>
            </div>
        </div>
    </div>

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

                    <div class="rounded-2xl bg-white p-7 shadow-sm ring-1 ring-slate-200/60">
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
                    </div>

                    <div class="rounded-2xl bg-white p-7 shadow-sm ring-1 ring-slate-200/60">
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
                    </div>
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

                    <div class="mt-8 flex items-end justify-between gap-4">
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
                </div>

                <div class="rounded-2xl bg-white p-7 shadow-sm ring-1 ring-slate-200/60">
                    <div class="flex items-center justify-between">
                        <div class="text-base font-semibold text-slate-900">Transações Recentes</div>
                        <Link :href="route('accounts.index')" class="text-sm font-semibold text-[#14B8A6]">Ver todas</Link>
                    </div>

                    <div class="mt-6 overflow-hidden rounded-2xl border border-slate-100">
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
                <div class="rounded-2xl border border-amber-100 bg-amber-50 px-7 py-6">
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
                        <div class="text-sm font-semibold text-slate-900">Metas Principais</div>
                        <Link :href="route('goals.index')" class="text-slate-300 hover:text-slate-400" aria-label="Ver metas">
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M9 18l6-6-6-6" />
                            </svg>
                        </Link>
                    </div>

                    <div class="mt-6 space-y-5">
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
