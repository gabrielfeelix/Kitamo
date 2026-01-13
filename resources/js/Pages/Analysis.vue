<script setup lang="ts">
import { computed, ref } from 'vue';
import { Link, usePage } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import TransactionModal, { type TransactionModalPayload } from '@/Components/TransactionModal.vue';
import DesktopTransactionModal from '@/Components/DesktopTransactionModal.vue';
import ExportReportModal from '@/Components/ExportReportModal.vue';
import DesktopExportReportModal from '@/Components/DesktopExportReportModal.vue';
import MobileToast from '@/Components/MobileToast.vue';
import { useMediaQuery } from '@/composables/useMediaQuery';
import { upsertEntry, type Entry } from '@/stores/localStore';

const page = usePage();
const userName = computed(() => page.props.auth?.user?.name ?? 'Gabriel');
const isMobile = useMediaQuery('(max-width: 767px)');

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

const analysisPeriod = ref<'month' | '3_months' | 'year'>('month');

const formatBRL = (value: number) =>
    new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL',
        maximumFractionDigits: 0,
    }).format(value);

const receitas = ref(2500);
const despesas = ref(1350);
const balanco = computed(() => receitas.value - despesas.value);

type Category = {
    key: string;
    label: string;
    value: number;
    color: string;
};

const categories = computed<Category[]>(() => [
    { key: 'moradia', label: 'Moradia', value: 600, color: '#3B82F6' },
    { key: 'alimentacao', label: 'Alimentação', value: 500, color: '#F59E0B' },
    { key: 'transporte', label: 'Transporte', value: 150, color: '#8B5CF6' },
    { key: 'lazer', label: 'Lazer', value: 100, color: '#10B981' },
]);

const totalExpenses = computed(() => categories.value.reduce((acc, item) => acc + item.value, 0));
const categoriesWithPct = computed(() =>
    categories.value.map((item) => ({
        ...item,
        pct: totalExpenses.value ? Math.round((item.value / totalExpenses.value) * 100) : 0,
    })),
);

const donutSegments = computed(() => {
    const radius = 64;
    const circumference = 2 * Math.PI * radius;
    let offset = 0;

    return categoriesWithPct.value.map((item) => {
        const fraction = totalExpenses.value ? item.value / totalExpenses.value : 0;
        const dash = circumference * fraction;
        const segment = {
            ...item,
            radius,
            circumference,
            dasharray: `${dash} ${circumference - dash}`,
            dashoffset: -offset,
        };
        offset += dash;
        return segment;
    });
});

const lastMonths = ref([
    { key: 'nov', label: 'Nov', value: 1100 },
    { key: 'dez', label: 'Dez', value: 1280 },
    { key: 'jan', label: 'Jan', value: 1350, highlight: true },
]);

const maxMonthValue = computed(() => Math.max(...lastMonths.value.map((m) => m.value), 1));
const increasePct = computed(() => {
    const jan = lastMonths.value.at(-1)?.value ?? 0;
    const dez = lastMonths.value.at(-2)?.value ?? 0;
    if (!dez) return 0;
    return Math.round(((jan - dez) / dez) * 1000) / 10;
});

const topExpenses = ref([
    { key: 'aluguel', label: 'Aluguel', value: 1200, color: '#3B82F6' },
    { key: 'supermercado', label: 'Supermercado', value: 250, color: '#F59E0B' },
    { key: 'luz', label: 'Conta de luz', value: 180, color: '#F59E0B' },
    { key: 'internet', label: 'Internet', value: 120, color: '#8B5CF6' },
    { key: 'academia', label: 'Academia', value: 89, color: '#10B981' },
]);

const maxTopExpense = computed(() => Math.max(...topExpenses.value.map((e) => e.value), 1));

const transactionOpen = ref(false);
const transactionKind = ref<'expense' | 'income'>('expense');
const desktopTransactionOpen = ref(false);

const exportOpen = ref(false);
const desktopExportOpen = ref(false);
const toastOpen = ref(false);
const toastMessage = ref('');
const showToast = (message: string) => {
    toastMessage.value = message;
    toastOpen.value = true;
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

    if (payload.kind === 'income') receitas.value += payload.amount;
    else despesas.value += payload.amount;

    showToast('Movimentação salva');
};
</script>

<template>
    <MobileShell v-if="isMobile">
        <header class="flex items-center justify-between pt-2">
            <div>
                <div class="text-2xl font-semibold tracking-tight text-slate-900">Análise</div>
            </div>
            <button
                type="button"
                class="flex h-11 w-11 items-center justify-center rounded-2xl bg-white text-slate-500 shadow-sm ring-1 ring-slate-200/60"
                aria-label="Exportar relatório"
                @click="exportOpen = true"
            >
                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M12 5v10" />
                    <path d="M8 9l4-4 4 4" />
                    <path d="M4 19h16" />
                </svg>
            </button>
        </header>

        <Link
            :href="route('analysis.compare')"
            class="mt-6 flex items-center justify-between gap-4 rounded-2xl bg-[#E6FFFB] px-4 py-4 shadow-sm ring-1 ring-emerald-100"
        >
            <div class="flex items-center gap-4">
                <span class="flex h-12 w-12 items-center justify-center rounded-2xl bg-[#14B8A6] text-white">
                    <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M7 7h10" />
                        <path d="M7 17h10" />
                        <path d="M10 10l-3-3 3-3" />
                        <path d="M14 14l3 3-3 3" />
                    </svg>
                </span>
                <div>
                    <div class="text-sm font-semibold text-slate-900">Comparar Períodos</div>
                    <div class="mt-1 text-xs font-semibold text-slate-500">Jan 2026 vs Dez 2025</div>
                </div>
            </div>
            <svg class="h-5 w-5 text-emerald-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M9 18l6-6-6-6" />
            </svg>
        </Link>

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

        <div class="mt-4 overflow-hidden rounded-3xl bg-white shadow-sm ring-1 ring-slate-200/60">
            <div class="grid grid-cols-3 divide-x divide-slate-100">
                <div class="px-4 py-4 text-center">
                    <div class="text-[10px] font-semibold uppercase tracking-wide text-slate-400">Receitas</div>
                    <div class="mt-2 text-sm font-semibold text-emerald-600">{{ formatBRL(receitas) }}</div>
                </div>
                <div class="px-4 py-4 text-center">
                    <div class="text-[10px] font-semibold uppercase tracking-wide text-slate-400">Despesas</div>
                    <div class="mt-2 text-sm font-semibold text-red-500">{{ formatBRL(despesas) }}</div>
                </div>
                <div class="px-4 py-4 text-center">
                    <div class="text-[10px] font-semibold uppercase tracking-wide text-slate-400">Balanço</div>
                    <div class="mt-2 text-sm font-semibold text-emerald-600">+{{ formatBRL(balanco) }}</div>
                </div>
            </div>
        </div>

        <div class="mt-4 rounded-3xl bg-white p-5 shadow-sm ring-1 ring-slate-200/60">
            <div class="text-base font-semibold text-slate-900">Despesas por categoria</div>

            <div class="mt-6 flex items-center justify-center">
                <div class="relative h-52 w-52">
                    <svg class="h-full w-full -rotate-90" viewBox="0 0 160 160">
                        <circle cx="80" cy="80" r="64" stroke="#E2E8F0" stroke-width="18" fill="none" />
                        <circle
                            v-for="segment in donutSegments"
                            :key="segment.key"
                            cx="80"
                            cy="80"
                            :r="segment.radius"
                            :stroke="segment.color"
                            stroke-width="18"
                            fill="none"
                            stroke-linecap="butt"
                            :stroke-dasharray="segment.dasharray"
                            :stroke-dashoffset="segment.dashoffset"
                        />
                    </svg>
                    <div class="absolute inset-0 flex flex-col items-center justify-center text-center">
                        <div class="text-3xl font-semibold text-slate-900">{{ despesas }}</div>
                        <div class="mt-1 text-[10px] font-semibold uppercase tracking-wide text-slate-400">Total de despesas</div>
                    </div>
                </div>
            </div>

            <div class="mt-5 space-y-3">
                <div v-for="item in categoriesWithPct" :key="item.key" class="flex items-center gap-3">
                    <span class="h-3 w-3 rounded-full" :style="{ backgroundColor: item.color }"></span>
                    <div class="flex-1 text-sm font-semibold text-slate-600">{{ item.label }}</div>
                    <div class="text-sm font-semibold text-slate-900">{{ formatBRL(item.value) }}</div>
                    <div class="w-12 text-right text-xs font-semibold text-slate-400">({{ item.pct }}%)</div>
                </div>
            </div>
        </div>

        <div class="mt-4 rounded-3xl bg-white p-5 shadow-sm ring-1 ring-slate-200/60">
            <div class="text-base font-semibold text-slate-900">Últimos 3 meses</div>

            <div class="mt-5 grid grid-cols-3 items-end gap-4">
                <div v-for="m in lastMonths" :key="m.key" class="text-center">
                    <div class="text-xs font-semibold text-slate-400">{{ formatBRL(m.value) }}</div>
                    <div
                        class="mx-auto mt-3 w-20 rounded-2xl"
                        :class="m.highlight ? 'bg-teal-500' : 'bg-slate-200'"
                        :style="{ height: `${Math.max(28, Math.round((m.value / maxMonthValue) * 96))}px` }"
                    ></div>
                    <div class="mt-2 text-xs font-semibold" :class="m.highlight ? 'text-teal-600' : 'text-slate-400'">{{ m.label }}</div>
                </div>
            </div>

            <div class="mt-4 text-sm font-semibold text-slate-400">
                Aumento de <span class="text-red-500">{{ increasePct }}%</span> em relação ao mês anterior
            </div>
        </div>

        <div class="mt-5 pb-4">
            <div class="text-lg font-semibold text-slate-900">Top 5 gastos</div>

            <div class="mt-4 space-y-4">
                <div v-for="item in topExpenses" :key="item.key">
                    <div class="flex items-center justify-between text-sm font-semibold">
                        <div class="text-slate-900">{{ item.label }}</div>
                        <div class="text-slate-900">{{ formatBRL(item.value) }}</div>
                    </div>
                    <div class="mt-2 h-2 w-full rounded-full bg-slate-100">
                        <div
                            class="h-2 rounded-full"
                            :style="{ width: `${Math.round((item.value / maxTopExpense) * 100)}%`, backgroundColor: item.color }"
                        ></div>
                    </div>
                </div>
            </div>
        </div>

        <template #fab>
            <button
                type="button"
                class="fixed bottom-[calc(5.5rem+env(safe-area-inset-bottom)+1rem)] right-5 z-50 flex h-14 w-14 items-center justify-center rounded-full bg-teal-500 text-white shadow-xl shadow-teal-500/30"
                aria-label="Adicionar"
                @click="
                    transactionKind = 'expense';
                    transactionOpen = true;
                "
            >
                <svg class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M12 5v14" />
                    <path d="M5 12h14" />
                </svg>
            </button>
        </template>

        <TransactionModal :open="transactionOpen" :kind="transactionKind" @close="transactionOpen = false" @save="onTransactionSave" />
        <ExportReportModal
            :open="exportOpen"
            @close="exportOpen = false"
            @exported="({ channel }) => showToast(channel === 'download' ? 'Relatório baixado' : 'Relatório enviado por email')"
        />
        <MobileToast :show="toastOpen" :message="toastMessage" @dismiss="toastOpen = false" />
    </MobileShell>

    <div v-else-if="false">
        <div class="space-y-6">
            <div class="flex flex-wrap items-center justify-between gap-4">
                <div class="flex flex-wrap items-center gap-3">
                    <button class="inline-flex items-center gap-2 rounded-2xl border border-slate-100 bg-white px-5 py-3 text-sm font-semibold text-slate-700 shadow-sm" type="button">
                        Este mês
                        <svg class="h-4 w-4 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M6 9l6 6 6-6" />
                        </svg>
                    </button>
                    <button class="inline-flex items-center gap-2 rounded-2xl border border-slate-100 bg-white px-5 py-3 text-sm font-semibold text-slate-700 shadow-sm" type="button">
                        Todas as contas
                        <svg class="h-4 w-4 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M6 9l6 6 6-6" />
                        </svg>
                    </button>
                </div>
                <button class="flex h-11 w-11 items-center justify-center rounded-2xl border border-slate-100 bg-white text-slate-600 shadow-sm" type="button" aria-label="Filtros">
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M4 5h16l-6 7v6l-4 2v-8L4 5Z" />
                    </svg>
                </button>
            </div>

            <div class="grid gap-6 xl:grid-cols-[1.6fr_0.9fr]">
                <div class="space-y-6">
                    <div class="grid gap-6 md:grid-cols-2">
                        <div class="rounded-[28px] border border-white/70 bg-white p-6 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)]">
                            <div class="flex items-start justify-between">
                                <div class="text-xs font-semibold uppercase tracking-wide text-slate-400">Total Entradas</div>
                                <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-emerald-50 text-emerald-600">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M12 21V7" />
                                        <path d="M7 12l5-5 5 5" />
                                    </svg>
                                </span>
                            </div>
                            <div class="mt-5 text-2xl font-semibold text-slate-900">+ R$ 5.250,00</div>
                            <div class="mt-3 inline-flex rounded-xl bg-emerald-50 px-3 py-2 text-xs font-semibold text-emerald-600">+12% vs mês anterior</div>
                        </div>
                        <div class="rounded-[28px] border border-white/70 bg-white p-6 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)]">
                            <div class="flex items-start justify-between">
                                <div class="text-xs font-semibold uppercase tracking-wide text-slate-400">Total Saídas</div>
                                <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-red-50 text-red-500">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M12 3v14" />
                                        <path d="M7 12l5 5 5-5" />
                                    </svg>
                                </span>
                            </div>
                            <div class="mt-5 text-2xl font-semibold text-slate-900">- R$ 1.408,00</div>
                            <div class="mt-2 text-xs font-medium text-slate-400">Dentro do orçamento</div>
                        </div>
                    </div>

                    <div class="rounded-[28px] border border-white/70 bg-white p-6 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)]">
                        <div class="flex h-[320px] items-center justify-center">
                            <div class="text-center">
                                <div class="mx-auto flex h-16 w-16 items-center justify-center rounded-3xl bg-slate-50 text-slate-300">
                                    <svg class="h-10 w-10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M4 19V5" />
                                        <path d="M10 19V9" />
                                        <path d="M16 19V3" />
                                        <path d="M22 19V12" />
                                    </svg>
                                </div>
                                <div class="mt-4 text-sm font-semibold text-slate-400">Gráfico de evolução mensal</div>
                            </div>
                        </div>
                    </div>

                    <div>
                        <div class="px-2 text-xs font-semibold uppercase tracking-wide text-slate-400">Histórico Detalhado</div>
                        <div class="mt-4 rounded-[28px] border border-white/70 bg-white p-4 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)]">
                            <div class="divide-y divide-slate-100">
                                <div class="flex items-center justify-between px-4 py-5">
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
                                <div class="flex items-center justify-between px-4 py-5">
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
                                <div class="flex items-center justify-between px-4 py-5">
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
                                <div class="flex items-center justify-between px-4 py-5">
                                    <div class="flex items-center gap-4">
                                        <span class="flex h-12 w-12 items-center justify-center rounded-2xl bg-slate-50 text-slate-400">
                                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <rect x="5" y="4" width="14" height="16" rx="4" />
                                                <path d="M8 8h8" />
                                            </svg>
                                        </span>
                                        <div>
                                            <div class="flex items-center gap-2 text-sm font-semibold text-slate-500">
                                                Spotify
                                                <span class="rounded-full bg-slate-100 px-2 py-1 text-[10px] font-semibold text-slate-400">PENDENTE</span>
                                            </div>
                                            <div class="text-xs text-slate-400">Assinatura • 04/01</div>
                                        </div>
                                    </div>
                                    <div class="text-sm font-semibold text-slate-500">-21.90</div>
                                </div>
                                <div class="flex items-center justify-between px-4 py-5">
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
                                <div class="flex items-center justify-between px-4 py-5">
                                    <div class="flex items-center gap-4">
                                        <span class="flex h-12 w-12 items-center justify-center rounded-2xl bg-emerald-50 text-emerald-500">
                                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <path d="M12 3v18" />
                                                <path d="M7 7h5a3 3 0 1 1 0 6H7" />
                                            </svg>
                                        </span>
                                        <div>
                                            <div class="text-sm font-semibold text-slate-900">Freela Design</div>
                                            <div class="text-xs text-slate-500">Receita • 02/01</div>
                                        </div>
                                    </div>
                                    <div class="text-sm font-semibold text-emerald-600">+1200.00</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="space-y-6">
                    <div class="rounded-[28px] border border-white/70 bg-white p-6 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)]">
                        <div class="flex items-center gap-2 text-lg font-semibold text-slate-900">
                            <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-50 text-slate-400">
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M12 6v6l4 2" />
                                    <circle cx="12" cy="12" r="9" />
                                </svg>
                            </span>
                            Top Categorias
                        </div>

                        <div class="mt-6 space-y-6">
                            <div class="space-y-2">
                                <div class="flex items-center justify-between text-sm font-semibold text-slate-700">
                                    <span>Alimentação</span>
                                    <span class="text-slate-600">R$ 800</span>
                                </div>
                                <div class="h-3 rounded-full bg-slate-100">
                                    <div class="h-3 w-2/5 rounded-full bg-red-500"></div>
                                </div>
                            </div>

                            <div class="space-y-2">
                                <div class="flex items-center justify-between text-sm font-semibold text-slate-700">
                                    <span>Moradia</span>
                                    <span class="text-slate-600">R$ 600</span>
                                </div>
                                <div class="h-3 rounded-full bg-slate-100">
                                    <div class="h-3 w-[30%] rounded-full bg-blue-600"></div>
                                </div>
                            </div>

                            <div class="space-y-2">
                                <div class="flex items-center justify-between text-sm font-semibold text-slate-700">
                                    <span>Transporte</span>
                                    <span class="text-slate-600">R$ 400</span>
                                </div>
                                <div class="h-3 rounded-full bg-slate-100">
                                    <div class="h-3 w-1/5 rounded-full bg-amber-500"></div>
                                </div>
                            </div>

                            <div class="space-y-2">
                                <div class="flex items-center justify-between text-sm font-semibold text-slate-700">
                                    <span>Lazer</span>
                                    <span class="text-slate-600">R$ 250</span>
                                </div>
                                <div class="h-3 rounded-full bg-slate-100">
                                    <div class="h-3 w-[14%] rounded-full bg-violet-500"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <DesktopShell
        v-else
        title="Relatórios e Análise"
        subtitle="Domingo, 11 Jan 2026"
        :show-search="false"
        new-action-label="Novo Lançamento"
        @new-transaction="desktopTransactionOpen = true"
    >
        <div class="space-y-6">
            <div class="rounded-2xl bg-white px-6 py-5 shadow-sm ring-1 ring-slate-200/60">
                <div class="flex items-center justify-between gap-6">
                    <div class="flex items-center gap-4">
                        <div class="flex items-center gap-2 rounded-2xl bg-slate-50 px-4 py-3 ring-1 ring-slate-200/60">
                            <button
                                type="button"
                                class="flex h-9 w-9 items-center justify-center rounded-xl text-slate-500 hover:bg-white"
                                aria-label="Mês anterior"
                                @click="shiftMonth(-1)"
                            >
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M15 18l-6-6 6-6" />
                                </svg>
                            </button>
                            <div class="min-w-[170px] text-center text-sm font-semibold text-slate-900">{{ monthLabel }}</div>
                            <button
                                type="button"
                                class="flex h-9 w-9 items-center justify-center rounded-xl text-slate-500 hover:bg-white"
                                aria-label="Próximo mês"
                                @click="shiftMonth(1)"
                            >
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M9 18l6-6-6-6" />
                                </svg>
                            </button>
                        </div>

                        <div class="h-10 w-px bg-slate-100"></div>

                        <div class="flex items-center gap-2 rounded-2xl bg-slate-50 p-1 ring-1 ring-slate-200/60">
                            <button
                                type="button"
                                class="h-9 rounded-xl px-4 text-sm font-semibold"
                                :class="analysisPeriod === 'month' ? 'bg-[#14B8A6] text-white' : 'text-slate-500 hover:bg-white'"
                                @click="analysisPeriod = 'month'"
                            >
                                Mês
                            </button>
                            <button
                                type="button"
                                class="h-9 rounded-xl px-4 text-sm font-semibold"
                                :class="analysisPeriod === '3_months' ? 'bg-[#14B8A6] text-white' : 'text-slate-500 hover:bg-white'"
                                @click="analysisPeriod = '3_months'"
                            >
                                3 Meses
                            </button>
                            <button
                                type="button"
                                class="h-9 rounded-xl px-4 text-sm font-semibold"
                                :class="analysisPeriod === 'year' ? 'bg-[#14B8A6] text-white' : 'text-slate-500 hover:bg-white'"
                                @click="analysisPeriod = 'year'"
                            >
                                Ano
                            </button>
                        </div>
                    </div>

                    <div class="flex items-center gap-3">
                        <button
                            type="button"
                            class="inline-flex h-10 items-center gap-2 rounded-xl bg-slate-900 px-4 text-sm font-semibold text-white shadow-sm"
                            @click="desktopExportOpen = true"
                        >
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M12 3v12" />
                                <path d="M8 11l4 4 4-4" />
                                <path d="M4 21h16" />
                            </svg>
                            Exportar Dados
                        </button>
                        <button
                            type="button"
                            class="flex h-10 w-10 items-center justify-center rounded-xl bg-white text-slate-500 shadow-sm ring-1 ring-slate-200/60"
                            aria-label="Ajustes"
                            @click="showToast('Em breve')"
                        >
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M12 3v2" />
                                <path d="M12 19v2" />
                                <path d="M4 7h16" />
                                <path d="M6 7v10" />
                                <path d="M18 7v10" />
                                <path d="M4 17h16" />
                                <path d="M8 17v-2" />
                                <path d="M16 17v-2" />
                            </svg>
                        </button>
                    </div>
                </div>
            </div>

            <div class="grid grid-cols-12 gap-6">
                <div class="col-span-3 rounded-2xl bg-white px-6 py-5 shadow-sm ring-1 ring-slate-200/60">
                    <div class="text-[11px] font-bold uppercase tracking-wide text-slate-400">Receitas</div>
                    <div class="mt-2 text-2xl font-bold tracking-tight text-emerald-600">R$ 4.500,00</div>
                    <div class="mt-2 text-xs font-semibold text-slate-400">Previsão: <span class="text-slate-600">R$ 5.200</span></div>
                </div>
                <div class="col-span-3 rounded-2xl bg-white px-6 py-5 shadow-sm ring-1 ring-slate-200/60">
                    <div class="text-[11px] font-bold uppercase tracking-wide text-slate-400">Despesas</div>
                    <div class="mt-2 text-2xl font-bold tracking-tight text-red-500">R$ 2.340,00</div>
                    <div class="mt-2 text-xs font-semibold text-slate-400">Economia: <span class="text-emerald-600">R$ 450</span></div>
                </div>
                <div class="col-span-3 rounded-2xl bg-white px-6 py-5 shadow-sm ring-1 ring-slate-200/60">
                    <div class="text-[11px] font-bold uppercase tracking-wide text-slate-400">Transferências</div>
                    <div class="mt-2 text-2xl font-bold tracking-tight text-blue-600">R$ 1.200,00</div>
                    <div class="mt-2 text-xs font-semibold text-slate-400">Investido: <span class="text-blue-600">R$ 800</span></div>
                </div>
                <div class="col-span-3 rounded-2xl bg-[#14B8A6] px-6 py-5 text-white shadow-sm">
                    <div class="text-[11px] font-bold uppercase tracking-wide text-white/80">Disponível</div>
                    <div class="mt-2 text-2xl font-bold tracking-tight">R$ 2.160,00</div>
                    <div class="mt-2 text-xs font-semibold text-white/80">Meta do mês: <span class="text-white">75%</span></div>
                </div>
            </div>

            <div class="grid grid-cols-12 gap-6">
                <div class="col-span-8 overflow-hidden rounded-2xl bg-white shadow-sm ring-1 ring-slate-200/60">
                    <div class="flex items-start justify-between px-7 py-6">
                        <div>
                            <div class="text-lg font-semibold text-slate-900">Fluxo de Caixa Mensal</div>
                            <div class="mt-1 text-xs font-semibold text-slate-400">Dados consolidados de Junho 2026</div>
                        </div>
                        <div class="flex items-center gap-5 text-xs font-semibold text-slate-400">
                            <div class="flex items-center gap-2">
                                <span class="h-2.5 w-2.5 rounded-full bg-[#14B8A6]"></span>
                                ENTRADAS
                            </div>
                            <div class="flex items-center gap-2">
                                <span class="h-2.5 w-2.5 rounded-full bg-red-400"></span>
                                SAÍDAS
                            </div>
                        </div>
                    </div>
                    <div class="h-[320px] bg-white">
                        <div class="h-full w-full">
                            <div class="h-full w-full border-t border-slate-50"></div>
                        </div>
                        <div class="flex h-full items-end justify-between px-8 pb-8 text-[11px] font-bold uppercase tracking-wide text-slate-300">
                            <div>SEM1</div>
                            <div>SEM2</div>
                            <div>SEM3</div>
                            <div class="text-[#14B8A6]">SEM4</div>
                        </div>
                    </div>
                </div>

                <div class="col-span-4 overflow-hidden rounded-2xl bg-white shadow-sm ring-1 ring-slate-200/60">
                    <div class="px-7 py-6">
                        <div class="text-lg font-semibold text-slate-900">Onde você gastou</div>
                    </div>
                    <div class="px-7 pb-7">
                        <div class="flex items-center justify-center">
                            <div class="relative h-44 w-44">
                                <svg class="h-full w-full -rotate-90" viewBox="0 0 160 160">
                                    <circle cx="80" cy="80" r="58" stroke="#E2E8F0" stroke-width="18" fill="none" />
                                    <circle cx="80" cy="80" r="58" stroke="#14B8A6" stroke-width="18" fill="none" stroke-dasharray="182 999" />
                                    <circle cx="80" cy="80" r="58" stroke="#3B82F6" stroke-width="18" fill="none" stroke-dasharray="140 999" stroke-dashoffset="-182" />
                                    <circle cx="80" cy="80" r="58" stroke="#F59E0B" stroke-width="18" fill="none" stroke-dasharray="86 999" stroke-dashoffset="-322" />
                                    <circle cx="80" cy="80" r="58" stroke="#EF4444" stroke-width="18" fill="none" stroke-dasharray="65 999" stroke-dashoffset="-408" />
                                </svg>
                                <div class="absolute inset-0 flex flex-col items-center justify-center text-center">
                                    <div class="text-[10px] font-bold uppercase tracking-wide text-slate-300">Total mês</div>
                                    <div class="mt-2 text-xl font-bold text-slate-900">R$ 2.340</div>
                                </div>
                            </div>
                        </div>

                        <div class="mt-6 space-y-4 text-sm font-semibold">
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-3 text-slate-600"><span class="h-2.5 w-2.5 rounded-full bg-[#14B8A6]"></span>Alimentação</div>
                                <div class="text-slate-900">R$ 936</div>
                            </div>
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-3 text-slate-600"><span class="h-2.5 w-2.5 rounded-full bg-[#3B82F6]"></span>Assinaturas</div>
                                <div class="text-slate-900">R$ 585</div>
                            </div>
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-3 text-slate-600"><span class="h-2.5 w-2.5 rounded-full bg-[#F59E0B]"></span>Transporte</div>
                                <div class="text-slate-900">R$ 468</div>
                            </div>
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-3 text-slate-600"><span class="h-2.5 w-2.5 rounded-full bg-[#EF4444]"></span>Outros</div>
                                <div class="text-slate-900">R$ 351</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="grid grid-cols-12 gap-6">
                <div class="col-span-7 rounded-2xl bg-white px-7 py-6 shadow-sm ring-1 ring-slate-200/60">
                    <div class="text-lg font-semibold text-slate-900">Maiores Lançamentos</div>
                    <div class="mt-6 space-y-6">
                        <div class="flex items-center gap-4">
                            <span class="flex h-12 w-12 items-center justify-center rounded-2xl bg-blue-50 text-blue-600">
                                <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M3 10.5L12 3l9 7.5" />
                                    <path d="M5 10v10h14V10" />
                                </svg>
                            </span>
                            <div class="flex-1">
                                <div class="flex items-center justify-between text-sm font-semibold text-slate-900">
                                    <span>Aluguel Apto</span>
                                    <span>R$ 1.200</span>
                                </div>
                                <div class="mt-3 h-2 w-full rounded-full bg-slate-100">
                                    <div class="h-2 w-[55%] rounded-full bg-blue-500"></div>
                                </div>
                            </div>
                        </div>
                        <div class="flex items-center gap-4">
                            <span class="flex h-12 w-12 items-center justify-center rounded-2xl bg-amber-50 text-amber-600">
                                <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M6 6h15l-2 7H7L6 6Z" />
                                    <path d="M6 6l-2-2H2" />
                                    <circle cx="9" cy="18" r="1.5" />
                                    <circle cx="17" cy="18" r="1.5" />
                                </svg>
                            </span>
                            <div class="flex-1">
                                <div class="flex items-center justify-between text-sm font-semibold text-slate-900">
                                    <span>Supermercado Mês</span>
                                    <span>R$ 850</span>
                                </div>
                                <div class="mt-3 h-2 w-full rounded-full bg-slate-100">
                                    <div class="h-2 w-[42%] rounded-full bg-orange-500"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-span-5 overflow-hidden rounded-2xl bg-slate-900 px-7 py-6 text-white shadow-sm">
                    <div class="flex items-start gap-4">
                        <span class="flex h-12 w-12 items-center justify-center rounded-2xl bg-[#14B8A6] text-white">
                            <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M12 20h9" />
                                <path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L8 18l-4 1 1-4 11.5-11.5Z" />
                            </svg>
                        </span>
                        <div class="flex-1">
                            <div class="text-lg font-semibold">Análise do Assistente</div>
                            <div class="mt-4 text-sm font-semibold leading-relaxed text-white/80">
                                "Gabriel, notei que o seu gasto com <span class="text-white">Alimentação</span> está 12% acima da média dos últimos 3 meses. No entanto, o seu saldo disponível é
                                saudável para o dia 11. Se mantiver as despesas fixas sob controle, você poderá investir <span class="text-white">R$ 500</span> extras este mês."
                            </div>
                            <div class="mt-6 flex items-center gap-3">
                                <button type="button" class="h-10 rounded-xl bg-[#14B8A6] px-5 text-sm font-semibold text-white">Ver Plano de Ação</button>
                                <button type="button" class="h-10 rounded-xl bg-white/10 px-5 text-sm font-semibold text-white/80 hover:bg-white/15">Descartar</button>
                            </div>
                        </div>
                        <div class="ml-auto flex h-16 w-16 items-end justify-end">
                            <div class="h-14 w-14 rounded-[20px] bg-white/10"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <DesktopTransactionModal :open="desktopTransactionOpen" :kind="transactionKind" @close="desktopTransactionOpen = false" @save="onTransactionSave" />
        <DesktopExportReportModal
            :open="desktopExportOpen"
            @close="desktopExportOpen = false"
            @exported="({ channel }) => { desktopExportOpen = false; showToast(channel === 'download' ? 'Relatório baixado' : 'Relatório enviado por email'); }"
        />
        <MobileToast :show="toastOpen" :message="toastMessage" @dismiss="toastOpen = false" />
    </DesktopShell>
</template>
