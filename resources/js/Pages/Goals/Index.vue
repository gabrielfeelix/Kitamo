<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, Link, router, usePage } from '@inertiajs/vue3';
import { requestJson } from '@/lib/kitamoApi';
import { buildTransactionRequest } from '@/lib/transactions';
import type { BootstrapData, Goal, Entry } from '@/types/kitamo';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import MobileToast from '@/Components/MobileToast.vue';
import TransactionModal, { type TransactionModalPayload } from '@/Components/TransactionModal.vue';
import type { CategoryOption } from '@/Components/CategoryPickerSheet.vue';
import type { AccountOption } from '@/Components/AccountPickerSheet.vue';
import { useIsMobile } from '@/composables/useIsMobile';

const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() =>
    isMobile.value ? { showNav: true } : { title: 'Metas', showSearch: false, showNewAction: true },
);

const page = usePage();
const bootstrap = computed(
    () => (page.props.bootstrap ?? { entries: [], goals: [], accounts: [], categories: [], tags: [] }) as BootstrapData,
);

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

const goals = ref<Goal[]>(bootstrap.value.goals ?? []);

const formatMoney = (value: number) =>
    new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL',
        maximumFractionDigits: 0,
    }).format(value);

const pct = (goal: Goal) => {
    if (!goal.target) return 0;
    return Math.min(100, Math.round((goal.current / goal.target) * 100));
};

const statusPill = {
    on_track: { label: 'No ritmo', cls: 'bg-emerald-50 text-emerald-600', dot: 'bg-emerald-500' },
    ahead: { label: 'Adiantado', cls: 'bg-blue-50 text-blue-600', dot: 'bg-blue-500' },
    late: { label: 'Atrasado', cls: 'bg-red-50 text-red-500', dot: 'bg-red-500' },
} as const;

const statusFor = (status: string) => statusPill[status as keyof typeof statusPill] ?? statusPill.on_track;

type GoalFilter = 'all' | 'short' | 'long';
const goalFilter = ref<GoalFilter>('all');
const filteredGoals = computed(() => {
    if (goalFilter.value === 'all') return goals.value;
    return goals.value.filter((g) => (g.term ?? 'long') === goalFilter.value);
});

const goalDrawerOpen = ref(false);
const selectedGoalId = ref<string | null>(null);
const selectedGoal = computed(() => (selectedGoalId.value ? goals.value.find((g) => g.id === selectedGoalId.value) ?? null : null));

const createGoalOpen = ref(false);
const openCreateGoal = () => {
    createGoalOpen.value = true;
};
const onGoalCreated = (payload: { goal: Goal }) => {
    const idx = goals.value.findIndex((g) => g.id === payload.goal.id);
    if (idx >= 0) goals.value[idx] = payload.goal;
    else goals.value.unshift(payload.goal);
    openGoalDrawer(payload.goal);
};

const openGoalDrawer = (goal: Goal) => {
    selectedGoalId.value = goal.id;
    goalDrawerOpen.value = true;
};

const addMoneyOpen = ref(false);
const openAddMoney = (goal: Goal) => {
    selectedGoalId.value = goal.id;
    goalDrawerOpen.value = true;
    addMoneyOpen.value = true;
};

const onAddMoneyConfirm = async (payload: { amount: string }) => {
    if (!selectedGoalId.value) return;
    const value = Number(payload.amount.replace(/\./g, '').replace(',', '.')) || 0;
    const response = await requestJson<{ goal: Goal }>(route('goals.deposits.store', selectedGoalId.value), {
        method: 'POST',
        body: JSON.stringify({ amount: value, title: 'Depósito mensal' }),
    });
    const idx = goals.value.findIndex((g) => g.id === response.goal.id);
    if (idx >= 0) goals.value[idx] = response.goal;
    showToast('Valor adicionado');
};

const deleteSelectedGoal = async () => {
    if (!selectedGoalId.value) return;
    const id = selectedGoalId.value;
    await requestJson(route('goals.destroy', id), { method: 'DELETE' });
    goals.value = goals.value.filter((goal) => goal.id !== id);
    goalDrawerOpen.value = false;
    showToast('Meta excluída');
};

const editSelectedGoal = () => {
    if (!selectedGoalId.value) return;
    router.get(route('goals.edit', { goalId: selectedGoalId.value }));
};

const transactionOpen = ref(false);
const transactionKind = ref<'expense' | 'income' | 'transfer'>('expense');
const transactionInitial = ref<TransactionModalPayload | null>(null);

const openNewTransaction = () => {
    transactionKind.value = 'expense';
    transactionInitial.value = null;
    transactionOpen.value = true;
};

const toastOpen = ref(false);
const toastMessage = ref('');
const showToast = (message: string) => {
    toastMessage.value = message;
    toastOpen.value = true;
};

const onTransactionSave = async (payload: TransactionModalPayload) => {
    if (payload.kind === 'transfer') {
        showToast('Transferência realizada');
        return;
    }

    await requestJson(route('transactions.store'), {
        method: 'POST',
        body: JSON.stringify(buildTransactionRequest(payload)),
    });
    transactionOpen.value = false;
    showToast('Movimentação salva');
};
</script>

<template>
    <Head title="Metas" />

    <component :is="Shell" v-bind="shellProps" @add="openNewTransaction">
        <header class="flex items-center justify-between pt-2">
            <div v-if="isMobile" class="text-2xl font-semibold tracking-tight text-slate-900">Metas</div>
            <Link
                :href="route('goals.create')"
                class="flex h-11 w-11 items-center justify-center rounded-2xl bg-white text-[#14B8A6] shadow-sm ring-1 ring-slate-200/60"
                aria-label="Nova meta"
            >
                <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M12 5v14" />
                    <path d="M5 12h14" />
                </svg>
            </Link>
        </header>

        <div v-if="goals.length === 0" class="mt-6 rounded-3xl border border-dashed border-slate-200 bg-white px-5 py-8 text-center shadow-sm">
            <Link
                :href="route('goals.create')"
                class="mx-auto flex h-16 w-16 items-center justify-center rounded-2xl bg-slate-50 text-slate-400"
                aria-label="Nova meta"
            >
                <svg class="h-8 w-8" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M12 5v14" />
                    <path d="M5 12h14" />
                </svg>
            </Link>
            <div class="mt-4 text-base font-semibold text-slate-900">Nova meta</div>
            <div class="mt-2 text-sm text-slate-500">Crie um objetivo financeiro e acompanhe o progresso.</div>
        </div>

        <div v-else class="mt-6 space-y-4 pb-4">
            <Link
                v-for="goal in goals"
                :key="goal.id"
                :href="route('goals.show', { goalId: goal.id })"
                class="block rounded-3xl bg-white p-5 shadow-sm ring-1 ring-slate-200/60"
            >
                <div class="flex items-start gap-4">
                    <span
                        class="flex h-12 w-12 items-center justify-center rounded-2xl"
                        :class="goal.icon === 'home' ? 'bg-emerald-50 text-emerald-600' : goal.icon === 'plane' ? 'bg-blue-50 text-blue-600' : 'bg-orange-50 text-orange-500'"
                    >
                        <svg v-if="goal.icon === 'home'" class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M3 10.5L12 3l9 7.5" />
                            <path d="M5 10v10h14V10" />
                        </svg>
                        <svg v-else-if="goal.icon === 'plane'" class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M2 16l20-8-20-8 6 8-6 8Z" />
                            <path d="M6 16v6l4-4" />
                        </svg>
                        <svg v-else class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M5 16l1-5 1-3h10l1 3 1 5" />
                            <path d="M7 16h10" />
                            <circle cx="8" cy="17" r="1.5" />
                            <circle cx="16" cy="17" r="1.5" />
                        </svg>
                    </span>

                    <div class="flex-1">
                        <div class="flex items-start justify-between gap-3">
                            <div>
                                <div class="text-base font-semibold text-slate-900">{{ goal.title }}</div>
                                <div class="mt-1 text-xs font-semibold text-slate-400">Prazo: {{ goal.due }}</div>
                            </div>

                            <span class="inline-flex items-center gap-2 rounded-full px-3 py-1 text-xs font-semibold" :class="statusFor(goal.status).cls">
                                <span class="h-2 w-2 rounded-full" :class="statusFor(goal.status).dot"></span>
                                {{ statusFor(goal.status).label }}
                            </span>
                        </div>

                        <div class="mt-4 flex items-center justify-between text-sm font-semibold">
                            <div :class="goal.status === 'late' ? 'text-orange-500' : 'text-[#14B8A6]'">{{ formatMoney(goal.current).replace('R$', 'R$') }}</div>
                            <div class="text-slate-400">de {{ formatMoney(goal.target).replace('R$', 'R$') }}</div>
                        </div>

                        <div class="mt-3 h-2 w-full rounded-full bg-slate-100">
                            <div
                                class="h-2 rounded-full"
                                :class="goal.status === 'late' ? 'bg-orange-500' : 'bg-[#14B8A6]'"
                                :style="{ width: `${pct(goal)}%` }"
                            ></div>
                        </div>

                        <div class="mt-3 text-right text-[10px] font-semibold text-slate-400">{{ pct(goal) }}% concluído</div>
                    </div>
                </div>
            </Link>
        </div>

        <template v-if="isMobile" #fab>
            <Link
                :href="route('goals.create')"
                class="fixed bottom-[calc(5.5rem+env(safe-area-inset-bottom)+1rem)] right-5 z-50 flex h-14 w-14 items-center justify-center rounded-full bg-teal-500 text-white shadow-xl shadow-teal-500/30"
                aria-label="Criar meta"
            >
                <svg class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M12 5v14" />
                    <path d="M5 12h14" />
                </svg>
            </Link>
        </template>

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
    </component>

</template>
