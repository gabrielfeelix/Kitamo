<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, Link, router, usePage } from '@inertiajs/vue3';
import { requestJson } from '@/lib/kitamoApi';
import { buildTransactionRequest } from '@/lib/transactions';
import type { BootstrapData, Goal, Entry } from '@/types/kitamo';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import DesktopTransactionModal from '@/Components/DesktopTransactionModal.vue';
import MobileToast from '@/Components/MobileToast.vue';
import { useMediaQuery } from '@/composables/useMediaQuery';
import type { TransactionModalPayload } from '@/Components/TransactionModal.vue';
import DesktopGoalDrawer from '@/Components/DesktopGoalDrawer.vue';
import DesktopGoalAddMoneyModal from '@/Components/DesktopGoalAddMoneyModal.vue';
import DesktopGoalCreateModal from '@/Components/DesktopGoalCreateModal.vue';

const isMobile = useMediaQuery('(max-width: 767px)');

const page = usePage();
const bootstrap = computed(
    () => (page.props.bootstrap ?? { entries: [], goals: [], accounts: [], categories: [] }) as BootstrapData,
);

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

const statusPill = computed(() => ({
    on_track: { label: 'No ritmo', cls: 'bg-emerald-50 text-emerald-600', dot: 'bg-emerald-500' },
    ahead: { label: 'Adiantado', cls: 'bg-blue-50 text-blue-600', dot: 'bg-blue-500' },
    late: { label: 'Atrasado', cls: 'bg-red-50 text-red-500', dot: 'bg-red-500' },
}));

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

const desktopTransactionOpen = ref(false);
const desktopTransactionKind = ref<'expense' | 'income' | 'transfer'>('expense');

const toastOpen = ref(false);
const toastMessage = ref('');
const showToast = (message: string) => {
    toastMessage.value = message;
    toastOpen.value = true;
};

};

const onDesktopTransactionSave = async (payload: TransactionModalPayload) => {
    if (payload.kind === 'transfer') {
        showToast('Transferência realizada');
        return;
    }

    await requestJson(route('transactions.store'), {
        method: 'POST',
        body: JSON.stringify(buildTransactionRequest(payload)),
    });
    showToast('Movimentação salva');
};
</script>

<template>
    <Head title="Metas" />

    <MobileShell v-if="isMobile">
        <header class="flex items-center justify-between pt-2">
            <div class="text-2xl font-semibold tracking-tight text-slate-900">Metas</div>
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

                            <span class="inline-flex items-center gap-2 rounded-full px-3 py-1 text-xs font-semibold" :class="statusPill[goal.status].cls">
                                <span class="h-2 w-2 rounded-full" :class="statusPill[goal.status].dot"></span>
                                {{ statusPill[goal.status].label }}
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

        <template #fab>
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
    </MobileShell>

    <DesktopShell
        v-else
        title="Minhas Metas"
        subtitle="Domingo, 11 Jan 2026"
        search-placeholder="Buscar (ex: Supermercado)..."
        @new-transaction="desktopTransactionOpen = true"
    >
        <div class="space-y-8">
            <div class="flex items-center justify-between gap-6">
                <div class="flex items-center gap-3">
                    <button
                        type="button"
                        class="h-10 rounded-full px-5 text-sm font-semibold"
                        :class="goalFilter === 'all' ? 'bg-[#14B8A6] text-white' : 'bg-white text-slate-500 ring-1 ring-slate-200'"
                        @click="goalFilter = 'all'"
                    >
                        Todas
                    </button>
                    <button
                        type="button"
                        class="h-10 rounded-full px-5 text-sm font-semibold"
                        :class="goalFilter === 'short' ? 'bg-[#14B8A6] text-white' : 'bg-white text-slate-500 ring-1 ring-slate-200'"
                        @click="goalFilter = 'short'"
                    >
                        Curto Prazo
                    </button>
                    <button
                        type="button"
                        class="h-10 rounded-full px-5 text-sm font-semibold"
                        :class="goalFilter === 'long' ? 'bg-[#14B8A6] text-white' : 'bg-white text-slate-500 ring-1 ring-slate-200'"
                        @click="goalFilter = 'long'"
                    >
                        Longo Prazo
                    </button>
                </div>
                <button
                    type="button"
                    class="inline-flex h-11 items-center gap-2 rounded-xl bg-[#14B8A6] px-5 text-sm font-semibold text-white shadow-lg shadow-emerald-500/20"
                    @click="openCreateGoal"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M12 5v14" />
                        <path d="M5 12h14" />
                    </svg>
                    Nova Meta Financeira
                </button>
            </div>

            <div class="grid grid-cols-3 gap-6">
                <button
                    v-for="goal in filteredGoals.slice(0, 2)"
                    :key="goal.id"
                    type="button"
                    class="rounded-2xl bg-white p-6 text-left shadow-sm ring-1 ring-slate-200/60 hover:shadow-md"
                    @click="openGoalDrawer(goal)"
                >
                    <div class="flex items-start justify-between gap-4">
                        <div class="flex h-12 w-12 items-center justify-center rounded-2xl bg-emerald-50 text-[#14B8A6] ring-1 ring-emerald-100">
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
                        </div>

                        <div class="text-right">
                            <span class="inline-flex rounded-full px-3 py-1 text-[10px] font-bold uppercase tracking-wide" :class="statusPill[goal.status].cls">
                                {{ statusPill[goal.status].label }}
                            </span>
                            <div class="mt-2 text-[10px] font-bold uppercase tracking-wide text-slate-300">Prazo: {{ goal.due }}</div>
                        </div>
                    </div>

                    <div class="mt-6 text-lg font-semibold text-slate-900">{{ goal.title }}</div>
                    <div class="mt-2 flex items-end gap-2">
                        <div class="text-2xl font-bold tracking-tight text-slate-900">R$ {{ goal.current.toLocaleString('pt-BR', { maximumFractionDigits: 0 }) }}</div>
                        <div class="pb-1 text-xs font-semibold text-slate-400">/ {{ formatMoney(goal.target).replace('R$', 'R$') }}</div>
                        <div class="ml-auto pb-1 text-sm font-bold text-[#14B8A6]">{{ pct(goal) }}%</div>
                    </div>

                    <div class="mt-4 h-2 w-full rounded-full bg-slate-100">
                        <div class="h-2 rounded-full" :class="goal.icon === 'plane' ? 'bg-blue-500' : 'bg-[#14B8A6]'" :style="{ width: `${pct(goal)}%` }"></div>
                    </div>

                    <div class="mt-5 flex flex-wrap gap-2">
                        <span v-for="t in goal.tags ?? []" :key="t" class="inline-flex rounded-lg bg-slate-100 px-3 py-1 text-xs font-semibold text-slate-500">
                            {{ t }}
                        </span>
                    </div>

                    <button type="button" class="mt-6 flex h-11 w-full items-center justify-center gap-2 rounded-xl bg-slate-50 text-sm font-semibold text-slate-600" @click.stop="openAddMoney(goal)">
                        <svg class="h-5 w-5 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M12 5v14" />
                            <path d="M5 12h14" />
                        </svg>
                        Adicionar Valor
                    </button>
                </button>

                <button
                    type="button"
                    class="flex flex-col items-center justify-center rounded-2xl border border-dashed border-slate-200 bg-white p-6 text-center text-slate-400 hover:bg-slate-50"
                    @click="openCreateGoal"
                >
                    <div class="flex h-20 w-20 items-center justify-center rounded-full bg-slate-50">
                        <svg class="h-10 w-10 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M12 5v14" />
                            <path d="M5 12h14" />
                        </svg>
                    </div>
                    <div class="mt-6 text-base font-semibold text-slate-600">Nova Meta</div>
                    <div class="mt-2 text-sm font-semibold text-slate-400">Crie um objetivo financeiro e acompanhe o progresso.</div>
                </button>
            </div>
        </div>

        <DesktopGoalDrawer
            :open="goalDrawerOpen"
            :goal="selectedGoal"
            @close="goalDrawerOpen = false"
            @add-money="addMoneyOpen = true"
            @edit="editSelectedGoal"
            @delete="deleteSelectedGoal"
        />
        <DesktopGoalAddMoneyModal :open="addMoneyOpen" @close="addMoneyOpen = false" @confirm="onAddMoneyConfirm" />
        <DesktopGoalCreateModal :open="createGoalOpen" @close="createGoalOpen = false" @created="onGoalCreated" />
        <DesktopTransactionModal :open="desktopTransactionOpen" :kind="desktopTransactionKind" @close="desktopTransactionOpen = false" @save="onDesktopTransactionSave" />
        <MobileToast :show="toastOpen" :message="toastMessage" @dismiss="toastOpen = false" />
    </DesktopShell>
</template>
