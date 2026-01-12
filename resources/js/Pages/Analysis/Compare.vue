<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, Link } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import DesktopTransactionModal from '@/Components/DesktopTransactionModal.vue';
import MobileToast from '@/Components/MobileToast.vue';
import { useMediaQuery } from '@/composables/useMediaQuery';
import { upsertEntry, type Entry } from '@/stores/localStore';
import type { TransactionModalPayload } from '@/Components/TransactionModal.vue';

const isMobile = useMediaQuery('(max-width: 767px)');

const label = ref('Jan 2026 vs Dez 2025');

const left = ref({ month: 'JAN 2026', rec: 2500, desp: 1350, total: 1150 });
const right = ref({ month: 'DEZ 2025', rec: 2500, desp: 1280, total: 1220 });

const diffPct = computed(() => {
    if (!right.value.desp) return 0;
    return Math.round(((left.value.desp - right.value.desp) / right.value.desp) * 1000) / 10;
});
const diffAbs = computed(() => left.value.desp - right.value.desp);

const categories = ref([
    { key: 'food', label: 'Alimentação', a: 500, b: 450 },
    { key: 'home', label: 'Moradia', a: 600, b: 600 },
    { key: 'transport', label: 'Transporte', a: 150, b: 130 },
]);

const maxCategory = computed(() => Math.max(...categories.value.flatMap((c) => [c.a, c.b]), 1));

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

const formatDateLabels = (date: Date) => {
    const dayLabel = String(date.getDate()).padStart(2, '0');
    const month = date
        .toLocaleString('pt-BR', { month: 'short' })
        .replace('.', '')
        .toUpperCase()
        .slice(0, 3);
    return { dayLabel, dateLabel: `DIA ${dayLabel} ${month}` };
};

const onDesktopTransactionSave = (payload: TransactionModalPayload) => {
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
    showToast('Movimentação salva');
};
</script>

<template>
    <Head title="Comparativo" />

    <MobileShell v-if="isMobile" :show-nav="false">
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
                <button type="button" class="flex h-10 w-10 items-center justify-center rounded-xl text-slate-500 hover:bg-slate-50" aria-label="Anterior">
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M15 18l-6-6 6-6" />
                    </svg>
                </button>
                <div class="text-sm font-semibold text-slate-900">{{ label }}</div>
                <button type="button" class="flex h-10 w-10 items-center justify-center rounded-xl text-slate-500 hover:bg-slate-50" aria-label="Próximo">
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
                    <div class="text-sm font-semibold text-slate-900">Você gastou {{ diffPct }}% a mais em Janeiro</div>
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
                <div class="flex items-center justify-between rounded-2xl bg-red-50 px-4 py-4 text-sm font-semibold text-red-500 ring-1 ring-red-100">
                    <div class="flex items-center gap-2">
                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M12 19V5" />
                            <path d="M5 12l7-7 7 7" />
                        </svg>
                        Alimentação: +11%
                    </div>
                    <div>R$ 50 a mais</div>
                </div>
                <div class="flex items-center justify-between rounded-2xl bg-red-50 px-4 py-4 text-sm font-semibold text-red-500 ring-1 ring-red-100">
                    <div class="flex items-center gap-2">
                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M12 19V5" />
                            <path d="M5 12l7-7 7 7" />
                        </svg>
                        Transporte: +15%
                    </div>
                    <div>R$ 20 a mais</div>
                </div>
                <div class="flex items-center justify-between rounded-2xl bg-emerald-50 px-4 py-4 text-sm font-semibold text-emerald-600 ring-1 ring-emerald-100">
                    <div class="flex items-center gap-2">
                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M20 6 9 17l-5-5" />
                        </svg>
                        Moradia: Sem variação
                    </div>
                    <div></div>
                </div>
            </div>
        </div>
    </MobileShell>

    <div v-else-if="false"></div>

    <DesktopShell v-else title="Comparativo" subtitle="Domingo, 11 Jan 2026" @new-transaction="desktopTransactionOpen = true">
        <div class="mx-auto max-w-[980px] space-y-6">
            <div class="rounded-2xl bg-white px-6 py-5 shadow-sm ring-1 ring-slate-200/60">
                <div class="flex items-center justify-between">
                    <button type="button" class="flex h-10 w-10 items-center justify-center rounded-xl text-slate-500 hover:bg-slate-50" aria-label="Anterior">
                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M15 18l-6-6 6-6" />
                        </svg>
                    </button>
                    <div class="text-sm font-semibold text-slate-900">{{ label }}</div>
                    <button type="button" class="flex h-10 w-10 items-center justify-center rounded-xl text-slate-500 hover:bg-slate-50" aria-label="Próximo">
                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 18l6-6-6-6" />
                        </svg>
                    </button>
                </div>
            </div>

            <div class="grid grid-cols-2 gap-6">
                <div class="rounded-2xl bg-white p-6 shadow-sm ring-1 ring-slate-200/60">
                    <div class="text-xs font-bold uppercase tracking-wide text-slate-400">{{ left.month }}</div>
                    <div class="mt-4 space-y-3 text-sm font-semibold">
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
                <div class="rounded-2xl bg-white p-6 shadow-sm ring-1 ring-slate-200/60">
                    <div class="text-xs font-bold uppercase tracking-wide text-slate-400">{{ right.month }}</div>
                    <div class="mt-4 space-y-3 text-sm font-semibold">
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

            <div class="rounded-2xl border border-amber-100 bg-amber-50 px-6 py-5">
                <div class="flex items-start gap-3">
                    <span class="mt-0.5 flex h-9 w-9 items-center justify-center rounded-2xl bg-amber-100 text-amber-700">
                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M12 9v4" />
                            <path d="M12 17h.01" />
                            <circle cx="12" cy="12" r="9" />
                        </svg>
                    </span>
                    <div class="flex-1">
                        <div class="text-sm font-semibold text-slate-900">Você gastou {{ diffPct }}% a mais em Janeiro</div>
                        <div class="mt-1 text-sm font-semibold text-amber-700">+{{ formatMoney(diffAbs).replace('R$', 'R$') }} de aumento</div>
                    </div>
                </div>
            </div>

            <div class="rounded-2xl bg-white p-6 shadow-sm ring-1 ring-slate-200/60">
                <div class="text-base font-semibold text-slate-900">Despesas por categoria</div>
                <div class="mt-5 space-y-6">
                    <div v-for="c in categories" :key="c.key">
                        <div class="text-sm font-semibold text-slate-700">{{ c.label }}</div>
                        <div class="mt-3 space-y-2">
                            <div class="flex items-center gap-3">
                                <div class="h-2 flex-1 rounded-full bg-slate-100">
                                    <div class="h-2 rounded-full bg-slate-300" :style="{ width: `${Math.round((c.b / maxCategory) * 100)}%` }"></div>
                                </div>
                                <div class="w-20 text-right text-xs font-semibold text-slate-400">{{ formatMoney(c.b).replace('R$', 'R$') }}</div>
                            </div>
                            <div class="flex items-center gap-3">
                                <div class="h-2 flex-1 rounded-full bg-slate-100">
                                    <div class="h-2 rounded-full bg-[#14B8A6]" :style="{ width: `${Math.round((c.a / maxCategory) * 100)}%` }"></div>
                                </div>
                                <div class="w-20 text-right text-xs font-semibold text-slate-700">{{ formatMoney(c.a).replace('R$', 'R$') }}</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <DesktopTransactionModal :open="desktopTransactionOpen" :kind="desktopTransactionKind" @close="desktopTransactionOpen = false" @save="onDesktopTransactionSave" />
        <MobileToast :show="toastOpen" :message="toastMessage" @dismiss="toastOpen = false" />
    </DesktopShell>
</template>
