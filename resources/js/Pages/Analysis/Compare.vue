<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, Link, router, usePage } from '@inertiajs/vue3';
import { requestJson } from '@/lib/kitamoApi';
import { executeTransfer } from '@/lib/transactions';
import type { BootstrapData, Entry } from '@/types/kitamo';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import MobileToast from '@/Components/MobileToast.vue';
import type { TransactionModalPayload } from '@/Components/TransactionModal.vue';
import { useIsMobile } from '@/composables/useIsMobile';

const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() =>
    isMobile.value
        ? { showNav: false }
        : { title: 'Relatórios', subtitle: 'Comparar períodos', showSearch: false, showNewAction: false },
);
const page = usePage();
const bootstrap = computed(
    () => (page.props.bootstrap ?? { entries: [], goals: [], accounts: [], categories: [], tags: [] }) as BootstrapData,
);
const entries = computed<Entry[]>(() => bootstrap.value.entries ?? []);

const anchorMonth = ref(new Date());
const shiftMonth = (delta: number) => {
    const next = new Date(anchorMonth.value);
    next.setMonth(next.getMonth() + delta);
    anchorMonth.value = next;
};

const monthKey = (date: Date) => `${date.getFullYear()}-${date.getMonth()}`;
const formatMonthLabel = (date: Date) =>
    new Intl.DateTimeFormat('pt-BR', { month: 'short', year: 'numeric' })
        .format(date)
        .replace('.', '')
        .toUpperCase();

const leftMonth = computed(() => new Date(anchorMonth.value.getFullYear(), anchorMonth.value.getMonth(), 1));
const rightMonth = computed(() => new Date(anchorMonth.value.getFullYear(), anchorMonth.value.getMonth() - 1, 1));
const label = computed(() => `${formatMonthLabel(leftMonth.value)} vs ${formatMonthLabel(rightMonth.value)}`);

const summarizeMonth = (date: Date) => {
    const key = monthKey(date);
    let rec = 0;
    let desp = 0;
    for (const entry of entries.value) {
        if (!entry.transactionDate) continue;
        const entryDate = new Date(entry.transactionDate);
        if (monthKey(entryDate) != key) continue;
        if (entry.kind === 'income') rec += entry.amount;
        if (entry.kind === 'expense') desp += entry.amount;
    }
    return { month: formatMonthLabel(date), rec, desp, total: rec - desp };
};

const left = computed(() => summarizeMonth(leftMonth.value));
const right = computed(() => summarizeMonth(rightMonth.value));

const diffPct = computed(() => {
    if (!right.value.desp) return 0;
    return Math.round(((left.value.desp - right.value.desp) / right.value.desp) * 1000) / 10;
});
const diffAbs = computed(() => left.value.desp - right.value.desp);

const categories = computed(() => {
    const leftMap = new Map();
    const rightMap = new Map();
    const leftKey = monthKey(leftMonth.value);
    const rightKey = monthKey(rightMonth.value);

    for (const entry of entries.value) {
        if (entry.kind !== 'expense' || !entry.transactionDate) continue;
        const entryDate = new Date(entry.transactionDate);
        const key = monthKey(entryDate);
        const label = entry.categoryLabel || 'Outros';
        if (key == leftKey) leftMap.set(label, (leftMap.get(label) ?? 0) + entry.amount);
        if (key == rightKey) rightMap.set(label, (rightMap.get(label) ?? 0) + entry.amount);
    }

    const keys = new Set(leftMap.keys());
    for (const key of rightMap.keys()) {
        keys.add(key);
    }

    return Array.from(keys)
        .map((key) => ({
            key: key.toLowerCase().replace(/\s+/g, '-'),
            label: key,
            a: leftMap.get(key) ?? 0,
            b: rightMap.get(key) ?? 0,
        }))
        .sort((a, b) => (b.a + b.b) - (a.a + a.b));
});

const maxCategory = computed(() => Math.max(...categories.value.flatMap((c) => [c.a, c.b]), 1));

type Insight = {
    key: string;
    label: string;
    kind: 'up' | 'down' | 'flat';
    pct: number;
    abs: number;
};

const insights = computed<Insight[]>(() => {
    const items = categories.value
        .map((c) => {
            const abs = c.a - c.b;
            const pct = c.b > 0 ? Math.round((abs / c.b) * 1000) / 10 : c.a > 0 ? 100 : 0;
            const kind: Insight['kind'] = abs > 0 ? 'up' : abs < 0 ? 'down' : 'flat';
            return { key: c.key, label: c.label, kind, pct, abs };
        })
        .filter((i) => Math.abs(i.abs) > 0.01 || i.pct !== 0);

    return items.sort((a, b) => Math.abs(b.abs) - Math.abs(a.abs)).slice(0, 3);
});

const formatMoney = (value: number) =>
    new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL',
        maximumFractionDigits: 0,
    }).format(value);

const desktopTransactionOpen = ref(false);
const desktopTransactionKind = ref<'expense' | 'income' | 'transfer'>('expense');
const toastOpen = ref(false);
const toastMessage = ref('');
const showToast = (message: string) => {
    toastMessage.value = message;
    toastOpen.value = true;
};

const onDesktopTransactionSave = async (payload: TransactionModalPayload) => {
    if (payload.kind === 'transfer') {
        try {
            await executeTransfer(payload);
            showToast('Transferência realizada');
            router.reload({ only: ['bootstrap'] });
        } catch {
            showToast('Não foi possível realizar a transferência');
        }
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
    <Head title="Comparativo" />

    <component :is="Shell" v-bind="shellProps">
        <header class="flex items-center gap-3 pt-2">
            <Link
                :href="route('analysis')"
                class="flex h-10 w-10 items-center justify-center rounded-2xl bg-white text-slate-600 shadow-sm ring-1 ring-slate-200/60"
                aria-label="Voltar"
            >
                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M15 18l-6-6 6-6" />
                </svg>
            </Link>
            <div class="text-xl font-semibold tracking-tight text-slate-900">Comparativo</div>
        </header>

        <div class="mt-6 rounded-2xl bg-white px-3 py-3 shadow-sm ring-1 ring-slate-200/60">
            <div class="flex items-center justify-between">
                <button type="button" class="flex h-10 w-10 items-center justify-center rounded-xl text-slate-500 hover:bg-slate-50" aria-label="Anterior" @click="shiftMonth(-1)">
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M15 18l-6-6 6-6" />
                    </svg>
                </button>
                <div class="text-sm font-semibold text-slate-900">{{ label }}</div>
                <button type="button" class="flex h-10 w-10 items-center justify-center rounded-xl text-slate-500 hover:bg-slate-50" aria-label="Próximo" @click="shiftMonth(1)">
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M9 18l6-6-6-6" />
                    </svg>
                </button>
            </div>
        </div>

        <div class="mt-6 grid grid-cols-2 gap-3">
            <div class="rounded-2xl bg-white p-4 shadow-sm ring-1 ring-slate-200/60">
                <div class="text-[10px] font-semibold uppercase tracking-wide text-slate-400">{{ left.month }}</div>
                <div class="mt-3 space-y-2 text-xs font-semibold">
                    <div class="flex items-center justify-between">
                        <div class="text-slate-400">Rec.</div>
                        <div class="text-emerald-600">{{ formatMoney(left.rec).replace('R$', 'R$') }}</div>
                    </div>
                    <div class="flex items-center justify-between">
                        <div class="text-slate-400">Desp.</div>
                        <div class="text-red-500">{{ formatMoney(left.desp).replace('R$', 'R$') }}</div>
                    </div>
                    <div class="flex items-center justify-between">
                        <div class="text-slate-400">Total</div>
                        <div class="text-emerald-600">+{{ formatMoney(left.total).replace('R$', 'R$') }}</div>
                    </div>
                </div>
            </div>
            <div class="rounded-2xl bg-white p-4 shadow-sm ring-1 ring-slate-200/60">
                <div class="text-[10px] font-semibold uppercase tracking-wide text-slate-400">{{ right.month }}</div>
                <div class="mt-3 space-y-2 text-xs font-semibold">
                    <div class="flex items-center justify-between">
                        <div class="text-slate-400">Rec.</div>
                        <div class="text-emerald-600">{{ formatMoney(right.rec).replace('R$', 'R$') }}</div>
                    </div>
                    <div class="flex items-center justify-between">
                        <div class="text-slate-400">Desp.</div>
                        <div class="text-red-500">{{ formatMoney(right.desp).replace('R$', 'R$') }}</div>
                    </div>
                    <div class="flex items-center justify-between">
                        <div class="text-slate-400">Total</div>
                        <div class="text-emerald-600">+{{ formatMoney(right.total).replace('R$', 'R$') }}</div>
                    </div>
                </div>
            </div>
        </div>

        <div class="mt-5 rounded-3xl bg-amber-50 p-5 shadow-sm ring-1 ring-amber-100">
            <div class="flex gap-4">
                <div class="flex h-10 w-10 items-center justify-center rounded-2xl bg-amber-100 text-amber-600">
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M12 9v4" />
                        <path d="M12 17h.01" />
                        <path d="M10.3 4.2l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.7-2.8l-8-14a2 2 0 0 0-3.4 0Z" />
                    </svg>
                </div>
                <div class="flex-1">
                    <div class="text-sm font-semibold text-slate-900">Você gastou {{ diffPct }}% a mais em {{ left.month }}</div>
                    <div class="mt-1 text-sm font-semibold text-amber-700">
                        {{ diffAbs >= 0 ? '+' : '-' }}{{ formatMoney(Math.abs(diffAbs)).replace('R$', 'R$') }} de aumento
                    </div>
                </div>
            </div>
        </div>

        <div class="mt-7">
            <div class="text-base font-semibold text-slate-900">Despesas por categoria</div>
            <div class="mt-3 flex items-center justify-end gap-4 text-xs font-semibold">
                <span class="inline-flex items-center gap-2 text-slate-400"><span class="h-2 w-2 rounded-full bg-slate-300"></span> Dez</span>
                <span class="inline-flex items-center gap-2 text-slate-600"><span class="h-2 w-2 rounded-full bg-[#14B8A6]"></span> Jan</span>
            </div>

            <div class="mt-3 rounded-3xl bg-white p-5 shadow-sm ring-1 ring-slate-200/60">
                <div v-for="c in categories" :key="c.key" class="py-4 first:pt-0 last:pb-0">
                    <div class="text-sm font-semibold text-slate-900">{{ c.label }}</div>
                    <div class="mt-3 space-y-3">
                        <div class="flex items-center gap-3">
                            <div class="h-2 flex-1 rounded-full bg-slate-100">
                                <div class="h-2 rounded-full bg-slate-300" :style="{ width: `${Math.round((c.b / maxCategory) * 100)}%` }"></div>
                            </div>
                            <div class="w-16 text-right text-xs font-semibold text-slate-400">{{ formatMoney(c.b).replace('R$', 'R$') }}</div>
                        </div>
                        <div class="flex items-center gap-3">
                            <div class="h-2 flex-1 rounded-full bg-slate-100">
                                <div class="h-2 rounded-full bg-[#14B8A6]" :style="{ width: `${Math.round((c.a / maxCategory) * 100)}%` }"></div>
                            </div>
                            <div class="w-16 text-right text-xs font-semibold text-slate-700">{{ formatMoney(c.a).replace('R$', 'R$') }}</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="mt-7 pb-6">
            <div class="text-base font-semibold text-slate-900">Insights</div>
            <div class="mt-3 space-y-3">
                <div
                    v-for="insight in insights"
                    :key="insight.key"
                    class="flex items-center justify-between rounded-2xl px-4 py-4 text-sm font-semibold ring-1"
                    :class="
                        insight.kind === 'up'
                            ? 'bg-red-50 text-red-500 ring-red-100'
                            : insight.kind === 'down'
                              ? 'bg-emerald-50 text-emerald-600 ring-emerald-100'
                              : 'bg-slate-50 text-slate-600 ring-slate-100'
                    "
                >
                    <div class="flex items-center gap-2">
                        <svg
                            v-if="insight.kind === 'up'"
                            class="h-5 w-5"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="2"
                        >
                            <path d="M12 19V5" />
                            <path d="M5 12l7-7 7 7" />
                        </svg>
                        <svg
                            v-else-if="insight.kind === 'down'"
                            class="h-5 w-5"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="2"
                        >
                            <path d="M12 5v14" />
                            <path d="M19 12l-7 7-7-7" />
                        </svg>
                        <svg
                            v-else
                            class="h-5 w-5"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="2"
                        >
                            <path d="M5 12h14" />
                        </svg>
                        <span>
                            {{ insight.label }}:
                            {{
                                insight.kind === 'flat'
                                    ? 'Sem variação'
                                    : `${insight.abs > 0 ? '+' : '-'}${Math.abs(insight.pct)}%`
                            }}
                        </span>
                    </div>
                    <div v-if="insight.kind !== 'flat'">
                        {{ insight.abs > 0 ? '+' : '-' }}{{ formatMoney(Math.abs(insight.abs)).replace('R$', 'R$') }}
                    </div>
                </div>

                <div v-if="insights.length === 0" class="rounded-2xl bg-slate-50 px-4 py-4 text-sm font-semibold text-slate-500 ring-1 ring-slate-100">
                    Sem insights suficientes para este período.
                </div>
            </div>
        </div>
    </component>

</template>
