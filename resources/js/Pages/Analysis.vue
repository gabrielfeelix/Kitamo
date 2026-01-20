<script setup lang="ts">
import { computed, ref } from 'vue';
import { Link, usePage } from '@inertiajs/vue3';
import { requestJson } from '@/lib/kitamoApi';
import type { BootstrapData } from '@/types/kitamo';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import TransactionModal, { type TransactionModalPayload } from '@/Components/TransactionModal.vue';
import ExportReportModal from '@/Components/ExportReportModal.vue';
import MobileToast from '@/Components/MobileToast.vue';
import CategoryIcon from '@/Components/CategoryIcon.vue';
import type { AccountOption } from '@/Components/AccountPickerSheet.vue';
import type { CategoryOption } from '@/Components/CategoryPickerSheet.vue';
import { useIsMobile } from '@/composables/useIsMobile';

const page = usePage();
const bootstrap = computed(
    () => (page.props.bootstrap ?? { entries: [], goals: [], accounts: [], categories: [], tags: [] }) as BootstrapData,
);
const entries = computed(() => bootstrap.value.entries ?? []);
const pickerCategories = computed<CategoryOption[]>(() => {
    const unique = new Map<string, CategoryOption>();
    for (const c of bootstrap.value.categories ?? []) {
        const kind = c.type === 'income' ? 'income' : c.type === 'expense' ? 'expense' : undefined;
        const current = unique.get(c.name);
        const mergedKind = current?.kind && kind && current.kind !== kind ? undefined : (current?.kind ?? kind);
        unique.set(c.name, { key: c.name, label: c.name, icon: 'other', tone: 'slate', kind: mergedKind });
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

const monthKey = (date: Date) => `${date.getFullYear()}-${date.getMonth()}`;
const yearKey = (date: Date) => `${date.getFullYear()}`;

const activeMonth = ref(new Date());
const analysisPeriod = ref<'month' | '3_months' | 'year'>('month');
const monthLabel = computed(() => {
    const month = new Intl.DateTimeFormat('pt-BR', { month: 'long' }).format(activeMonth.value).toUpperCase();
    return `${month} ${activeMonth.value.getFullYear()}`;
});
const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() =>
    isMobile.value
        ? { showNav: true }
        : {
              title: 'Relatórios',
              subtitle: monthLabel.value,
              searchPlaceholder: 'Buscar transação…',
              newActionLabel: 'Nova Transação',
              showSearch: false,
          },
);
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

const normalizeKey = (value: string) => String(value ?? '').trim().toLowerCase();
const categoryIconByName = computed(() => {
    const map = new Map<string, string>();
    for (const c of bootstrap.value.categories ?? []) {
        map.set(`${normalizeKey(c.name)}|${c.type}`, c.icon ?? 'other');
    }
    return map;
});

const fallbackCategoryIcon = (entry: (typeof entries.value)[number]) => {
    const key = String(entry.categoryKey ?? '').toLowerCase();
    if (key === 'food') return 'food';
    if (key === 'home') return 'home';
    if (key === 'car') return 'car';
    return 'other';
};

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
            categoryIcon: categoryIconByName.value.get(`${normalizeKey(entry.categoryLabel)}|expense`) ?? fallbackCategoryIcon(entry),
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
    <component :is="Shell" v-bind="shellProps" @add="openQuickTransaction">
	        <header class="flex items-center justify-between pt-2">
	            <div v-if="isMobile">
	                <div class="text-2xl font-semibold tracking-tight text-slate-900">Relatórios</div>
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
                            <div class="text-3xl font-semibold text-slate-900">{{ formatBRL(despesas) }}</div>
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
                        <div class="flex min-w-0 items-center gap-2 text-slate-900">
                            <span class="flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-slate-100 text-slate-600">
                                <CategoryIcon :icon="item.categoryIcon" class="h-4 w-4" />
                            </span>
                            <span class="truncate">{{ item.label }}</span>
                        </div>
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

        <TransactionModal
            :open="transactionOpen"
            :kind="transactionKind"
            :categories="pickerCategories"
            :accounts="pickerAccounts"
            :tags="bootstrap.tags"
            @close="transactionOpen = false"
            @save="onTransactionSave"
        />
        <ExportReportModal
            :open="exportOpen"
            @close="exportOpen = false"
            @exported="({ channel, format }) => { if (channel === 'download') exportTransactions(format); showToast(channel === 'download' ? 'Relatório baixado' : 'Relatório enviado por email'); }"
        />
        <MobileToast :show="toastOpen" :message="toastMessage" @dismiss="toastOpen = false" />
    </component>

</template>
