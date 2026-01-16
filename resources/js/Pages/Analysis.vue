<script setup lang="ts">
import { computed, ref } from 'vue';
import { Link, usePage } from '@inertiajs/vue3';
import { requestJson } from '@/lib/kitamoApi';
import type { BootstrapData } from '@/types/kitamo';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import TransactionModal, { type TransactionModalPayload } from '@/Components/TransactionModal.vue';
import DesktopTransactionModal from '@/Components/DesktopTransactionModal.vue';
import ExportReportModal from '@/Components/ExportReportModal.vue';
import DesktopExportReportModal from '@/Components/DesktopExportReportModal.vue';
import MobileToast from '@/Components/MobileToast.vue';
import { useMediaQuery } from '@/composables/useMediaQuery';

const page = usePage();
const bootstrap = computed(
    () => (page.props.bootstrap ?? { entries: [], goals: [], accounts: [], categories: [] }) as BootstrapData,
);
const entries = computed(() => bootstrap.value.entries ?? []);

const monthKey = (date: Date) => `${date.getFullYear()}-${date.getMonth()}`;
const yearKey = (date: Date) => `${date.getFullYear()}`;

const activeMonth = ref(new Date());
const analysisPeriod = ref<'month' | '3_months' | 'year'>('month');
const monthLabel = computed(() => {
    const month = new Intl.DateTimeFormat('pt-BR', { month: 'long' }).format(activeMonth.value).toUpperCase();
    return `${month} ${activeMonth.value.getFullYear()}`;
});
const isMobile = useMediaQuery('(max-width: 767px)');
const shiftMonth = (delta: number) => {
    const d = new Date(activeMonth.value);
    d.setMonth(d.getMonth() + delta);
    activeMonth.value = d;
};

const scopedEntries = computed(() => {
    if (!entries.value.length) return [];
    if (analysisPeriod.value === 'month') {
        const key = monthKey(activeMonth.value);
        return entries.value.filter((entry) => {
            if (!entry.transactionDate) return false;
            const date = new Date(entry.transactionDate);
            return monthKey(date) === key;
        });
    }
    if (analysisPeriod.value === 'year') {
        const key = yearKey(activeMonth.value);
        return entries.value.filter((entry) => {
            if (!entry.transactionDate) return false;
            const date = new Date(entry.transactionDate);
            return yearKey(date) === key;
        });
    }
    // 3 months
    return entries.value.filter((entry) => {
        if (!entry.transactionDate) return false;
        const date = new Date(entry.transactionDate);
        const diff = (activeMonth.value.getFullYear() - date.getFullYear()) * 12 + (activeMonth.value.getMonth() - date.getMonth());
        return diff >= 0 && diff < 3;
    });
});
const formatBRL = (value: number) =>
    new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL',
        maximumFractionDigits: 0,
    }).format(value);

const receitas = computed(() => scopedEntries.value.filter((e) => e.kind === 'income').reduce((acc, e) => acc + e.amount, 0));
const despesas = computed(() => scopedEntries.value.filter((e) => e.kind === 'expense').reduce((acc, e) => acc + e.amount, 0));
const balanco = computed(() => receitas.value - despesas.value);

type Category = {
    key: string;
    label: string;
    value: number;
    color: string;
};

const categories = computed<Category[]>(() => {
    const palette = ['#14B8A6', '#3B82F6', '#F59E0B', '#10B981', '#EF4444', '#8B5CF6'];
    const totals = new Map<string, number>();
    for (const entry of scopedEntries.value) {
        if (entry.kind !== 'expense') continue;
        const key = entry.categoryLabel || 'Outros';
        totals.set(key, (totals.get(key) ?? 0) + entry.amount);
    }
    return Array.from(totals.entries()).map(([label, value], idx) => ({
        key: label.toLowerCase().replace(/\s+/g, '-'),
        label,
        value,
        color: palette[idx % palette.length],
    }));
});

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

const lastMonths = computed(() => {
    const now = new Date(activeMonth.value);
    const labels = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    const months = Array.from({ length: 3 }, (_, idx) => {
        const date = new Date(now.getFullYear(), now.getMonth() - (2 - idx), 1);
        const key = `${date.getFullYear()}-${date.getMonth() + 1}`;
        return { key, label: labels[date.getMonth()], value: 0, highlight: idx === 2 };
    });

    for (const entry of scopedEntries.value) {
        if (!entry.transactionDate) continue;
        const date = new Date(entry.transactionDate);
        const key = `${date.getFullYear()}-${date.getMonth() + 1}`;
        const target = months.find((m) => m.key === key);
        if (!target) continue;
        target.value += entry.kind === 'expense' ? entry.amount : 0;
    }

    return months;
});

const maxMonthValue = computed(() => Math.max(...lastMonths.value.map((m) => m.value), 1));
const increasePct = computed(() => {
    const jan = lastMonths.value.at(-1)?.value ?? 0;
    const dez = lastMonths.value.at(-2)?.value ?? 0;
    if (!dez) return 0;
    return Math.round(((jan - dez) / dez) * 1000) / 10;
});

const topExpenses = computed(() => {
    const palette = ['#3B82F6', '#F59E0B', '#EF4444', '#8B5CF6', '#10B981'];
    return scopedEntries.value
        .filter((entry) => entry.kind === 'expense')
        .sort((a, b) => b.amount - a.amount)
        .slice(0, 5)
        .map((entry, idx) => ({
            key: entry.id,
            label: entry.title,
            value: entry.amount,
            color: palette[idx % palette.length],
        }));
});

const maxTopExpense = computed(() => Math.max(...topExpenses.value.map((e) => e.value), 1));
const hasCategoryData = computed(() => categories.value.length > 0 && totalExpenses.value > 0);
const hasTrendData = computed(() => lastMonths.value.length > 0);
const hasTopExpenses = computed(() => topExpenses.value.length > 0);

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

const exportTransactions = (format: 'pdf' | 'excel' | 'csv') => {
    const targetFormat = format === 'excel' ? 'excel' : 'csv';
    const url = route('exports.transactions', { format: targetFormat });
    window.location.href = url;
};

const openQuickTransaction = () => {
    transactionKind.value = 'expense';
    transactionOpen.value = true;
};

const onTransactionSave = async (payload: TransactionModalPayload) => {
    if (payload.kind === 'transfer') {
        showToast('Transferência realizada');
        return;
    }

    await requestJson(route('transactions.store'), {
        method: 'POST',
        body: JSON.stringify({
            kind: payload.kind,
            amount: payload.amount,
            description: payload.description,
            category: payload.category,
            account: payload.account,
            dateKind: payload.dateKind,
            dateOther: payload.dateOther,
            isPaid: payload.isPaid,
            isInstallment: payload.isInstallment,
            installmentCount: payload.installmentCount,
        }),
    });

    showToast('Movimentação salva');
};
</script>

<template>
    <MobileShell v-if="isMobile" @add="openQuickTransaction">
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

            <div v-if="hasCategoryData">
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
            <div v-else class="mt-6 rounded-2xl border border-dashed border-slate-200 bg-slate-50 px-4 py-6 text-center">
                <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-white text-slate-400">
                    <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M12 8v8" />
                        <path d="M8 12h8" />
                        <circle cx="12" cy="12" r="9" />
                    </svg>
                </div>
                <div class="mt-3 text-sm font-semibold text-slate-900">Você ainda não possui despesas este mês.</div>
                <div class="mt-1 text-xs text-slate-500">Adicione seus gastos para ver o gráfico.</div>
            </div>
        </div>

        <div class="mt-4 rounded-3xl bg-white p-5 shadow-sm ring-1 ring-slate-200/60">
            <div class="text-base font-semibold text-slate-900">Últimos 3 meses</div>

            <div v-if="hasTrendData">
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
            <div v-else class="mt-5 rounded-2xl border border-dashed border-slate-200 bg-slate-50 px-4 py-6 text-center">
                <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-white text-slate-400">
                    <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M4 19V5" />
                        <path d="M10 19V9" />
                        <path d="M16 19v-4" />
                        <path d="M22 19V7" />
                    </svg>
                </div>
                <div class="mt-3 text-sm font-semibold text-slate-900">Sem histórico ainda</div>
                <div class="mt-1 text-xs text-slate-500">Seu gráfico aparece quando houver lançamentos.</div>
            </div>
        </div>

        <div class="mt-5 pb-4">
            <div class="text-lg font-semibold text-slate-900">Top 5 gastos</div>

            <div v-if="hasTopExpenses" class="mt-4 space-y-4">
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
            <div v-else class="mt-4 rounded-2xl border border-dashed border-slate-200 bg-slate-50 px-4 py-6 text-center">
                <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-white text-slate-400">
                    <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <rect x="3" y="5" width="18" height="14" rx="3" />
                        <path d="M3 10h18" />
                    </svg>
                </div>
                <div class="mt-3 text-sm font-semibold text-slate-900">Sem gastos registrados</div>
                <div class="mt-1 text-xs text-slate-500">Adicione lançamentos para preencher este ranking.</div>
            </div>
        </div>

        <TransactionModal :open="transactionOpen" :kind="transactionKind" @close="transactionOpen = false" @save="onTransactionSave" />
        <ExportReportModal
            :open="exportOpen"
            @close="exportOpen = false"
            @exported="({ channel, format }) => { if (channel === 'download') exportTransactions(format); showToast(channel === 'download' ? 'Relatório baixado' : 'Relatório enviado por email'); }"
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
                        <div class="mt-2 text-2xl font-bold tracking-tight text-emerald-600">{{ formatBRL(receitas) }}</div>
                        <div class="mt-2 text-xs font-semibold text-slate-400">Previsão: <span class="text-slate-600">{{ formatBRL(0) }}</span></div>
                    </div>
                    <div class="col-span-3 rounded-2xl bg-white px-6 py-5 shadow-sm ring-1 ring-slate-200/60">
                        <div class="text-[11px] font-bold uppercase tracking-wide text-slate-400">Despesas</div>
                        <div class="mt-2 text-2xl font-bold tracking-tight text-red-500">{{ formatBRL(despesas) }}</div>
                        <div class="mt-2 text-xs font-semibold text-slate-400">Economia: <span class="text-slate-600">{{ formatBRL(0) }}</span></div>
                    </div>
                    <div class="col-span-3 rounded-2xl bg-white px-6 py-5 shadow-sm ring-1 ring-slate-200/60">
                        <div class="text-[11px] font-bold uppercase tracking-wide text-slate-400">Transferências</div>
                        <div class="mt-2 text-2xl font-bold tracking-tight text-blue-600">{{ formatBRL(0) }}</div>
                        <div class="mt-2 text-xs font-semibold text-slate-400">Investido: <span class="text-slate-600">{{ formatBRL(0) }}</span></div>
                    </div>
                    <div class="col-span-3 rounded-2xl bg-[#14B8A6] px-6 py-5 text-white shadow-sm">
                        <div class="text-[11px] font-bold uppercase tracking-wide text-white/80">Disponível</div>
                        <div class="mt-2 text-2xl font-bold tracking-tight">{{ formatBRL(balanco) }}</div>
                        <div class="mt-2 text-xs font-semibold text-white/80">Meta do mês: <span class="text-white">0%</span></div>
                    </div>
                </div>

                <div class="grid grid-cols-12 gap-6">
                    <div class="col-span-8 rounded-2xl bg-white px-7 py-8 shadow-sm ring-1 ring-slate-200/60">
                        <div class="text-lg font-semibold text-slate-900">Fluxo de Caixa Mensal</div>
                        <div class="mt-5 rounded-2xl border border-dashed border-slate-200 bg-slate-50 px-6 py-10 text-center">
                            <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-white text-slate-400">
                                <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M4 19V5" />
                                    <path d="M10 19V9" />
                                    <path d="M16 19v-4" />
                                    <path d="M22 19V7" />
                                </svg>
                            </div>
                            <div class="mt-3 text-sm font-semibold text-slate-900">Sem dados ainda</div>
                            <div class="mt-1 text-xs text-slate-500">Os gráficos aparecem quando houver lançamentos.</div>
                        </div>
                    </div>
                    <div class="col-span-4 rounded-2xl bg-white px-7 py-8 shadow-sm ring-1 ring-slate-200/60">
                        <div class="text-lg font-semibold text-slate-900">Onde você gastou</div>
                        <div class="mt-5 rounded-2xl border border-dashed border-slate-200 bg-slate-50 px-6 py-10 text-center">
                            <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-white text-slate-400">
                                <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <circle cx="12" cy="12" r="9" />
                                    <path d="M12 8v8" />
                                    <path d="M8 12h8" />
                                </svg>
                            </div>
                            <div class="mt-3 text-sm font-semibold text-slate-900">Sem categorias</div>
                            <div class="mt-1 text-xs text-slate-500">Adicione despesas para ver a divisão.</div>
                        </div>
                    </div>
                </div>

                <div class="grid grid-cols-12 gap-6">
                    <div class="col-span-7 rounded-2xl bg-white px-7 py-8 shadow-sm ring-1 ring-slate-200/60">
                        <div class="text-lg font-semibold text-slate-900">Resumo do período</div>
                        <div class="mt-5 rounded-2xl border border-dashed border-slate-200 bg-slate-50 px-6 py-10 text-center">
                            <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-white text-slate-400">
                                <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <rect x="3" y="4" width="18" height="16" rx="3" />
                                    <path d="M7 8h10" />
                                    <path d="M7 12h7" />
                                </svg>
                            </div>
                            <div class="mt-3 text-sm font-semibold text-slate-900">Sem histórico</div>
                            <div class="mt-1 text-xs text-slate-500">Os detalhes aparecem após os primeiros lançamentos.</div>
                        </div>
                    </div>
                    <div class="col-span-5 rounded-2xl bg-white px-7 py-8 shadow-sm ring-1 ring-slate-200/60">
                        <div class="text-lg font-semibold text-slate-900">Top gastos</div>
                        <div class="mt-5 rounded-2xl border border-dashed border-slate-200 bg-slate-50 px-6 py-10 text-center">
                            <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-white text-slate-400">
                                <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M4 19V5" />
                                    <path d="M10 19V9" />
                                    <path d="M16 19v-4" />
                                    <path d="M22 19V7" />
                                </svg>
                            </div>
                            <div class="mt-3 text-sm font-semibold text-slate-900">Sem ranking</div>
                            <div class="mt-1 text-xs text-slate-500">Registre despesas para ver os maiores gastos.</div>
                        </div>
                    </div>
                </div>
        </div>

        <DesktopTransactionModal :open="desktopTransactionOpen" :kind="transactionKind" @close="desktopTransactionOpen = false" @save="onTransactionSave" />
        <DesktopExportReportModal
            :open="desktopExportOpen"
            @close="desktopExportOpen = false"
            @exported="({ channel, format }) => { desktopExportOpen = false; if (channel === 'download') exportTransactions(format); showToast(channel === 'download' ? 'Relatório baixado' : 'Relatório enviado por email'); }"
        />
        <MobileToast :show="toastOpen" :message="toastMessage" @dismiss="toastOpen = false" />
    </DesktopShell>
</template>
