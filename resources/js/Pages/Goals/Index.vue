<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, Link, router, usePage } from '@inertiajs/vue3';
import { requestFormData, requestJson } from '@/lib/kitamoApi';
import { buildTransactionFormData, buildTransactionRequest, executeTransfer, hasTransactionReceipt } from '@/lib/transactions';
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
    isMobile.value ? { showNav: true } : { title: 'Metas', showSearch: false, showNewAction: false },
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

const faltam = (goal: Goal) => Math.max(0, goal.target - goal.current);

const concluida = (goal: Goal) => goal.target > 0 && goal.current >= goal.target;

/**
 * Meta sem valor-alvo definido. Acontece com meta criada pela metade, e sem
 * tratamento o card dizia "R$ 150 de R$ 0 · Faltam R$ 0" a 0% — três
 * informações que se contradizem.
 */
const semAlvo = (goal: Goal) => !goal.target || goal.target <= 0;

/**
 * Ritmo médio de depósito nos últimos 90 dias, projetado sobre o que falta.
 * É a pergunta que a pessoa realmente faz olhando uma meta — "quando chego?" —
 * e a resposta já estava nos depósitos, só não era mostrada.
 *
 * Só estima com 2+ depósitos: com um só não há intervalo para medir ritmo.
 */
const previsao = (goal: Goal): string | null => {
    if (concluida(goal)) return null;

    const deposits = (goal.deposits ?? []).filter((d) => d.amount > 0).slice().sort((a, b) => a.createdAt - b.createdAt);
    if (deposits.length < 2) return null;

    const primeiro = deposits[0]!.createdAt;
    const ultimo = deposits[deposits.length - 1]!.createdAt;
    const meses = Math.max(1, (ultimo - primeiro) / (1000 * 60 * 60 * 24 * 30));

    const totalDepositado = deposits.reduce((acc, d) => acc + d.amount, 0);
    const porMes = totalDepositado / meses;
    if (porMes <= 0) return null;

    const mesesRestantes = Math.ceil(faltam(goal) / porMes);
    if (!Number.isFinite(mesesRestantes) || mesesRestantes <= 0) return null;
    if (mesesRestantes > 120) return 'nesse ritmo, ainda longe';

    return mesesRestantes === 1 ? 'cerca de 1 mês nesse ritmo' : `cerca de ${mesesRestantes} meses nesse ritmo`;
};

/** Circunferência do anel de progresso (r=26). */
const RING = 2 * Math.PI * 26;
const ringOffset = (goal: Goal) => RING - (pct(goal) / 100) * RING;

const metasConcluidas = computed(() => goals.value.filter((g) => concluida(g)).length);

const totalSaved = computed(() => goals.value.reduce((acc, g) => acc + g.current, 0));
const totalTarget = computed(() => goals.value.reduce((acc, g) => acc + g.target, 0));
const totalPct = computed(() => {
    if (totalTarget.value === 0) return 0;
    return Math.min(100, Math.round((totalSaved.value / totalTarget.value) * 100));
});

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
        try {
            await executeTransfer(payload);
            showToast('Transferência realizada');
            router.reload({ only: ['bootstrap'] });
        } catch {
            showToast('Não foi possível realizar a transferência');
        }
        return;
    }

    await (hasTransactionReceipt(payload) ? requestFormData : requestJson)(route('transactions.store'), {
        method: 'POST',
        body: hasTransactionReceipt(payload) ? buildTransactionFormData(payload) : JSON.stringify(buildTransactionRequest(payload)),
    });
    transactionOpen.value = false;
    showToast('Movimentação salva');
    router.reload({ only: ['bootstrap'] });
};
</script>

<template>
    <Head title="Metas" />

    <component :is="Shell" v-bind="shellProps" @add="openNewTransaction">
        <header v-if="isMobile" class="flex items-center justify-between pt-2">
            <div class="text-2xl font-semibold tracking-tight text-slate-900">Metas</div>
        </header>

        <div :class="[isMobile ? 'contents' : 'mt-8 grid grid-cols-1 lg:grid-cols-12 gap-8 items-start']">
            
            <!-- Left Column -->
            <div :class="[isMobile ? 'contents' : 'lg:col-span-8']">

        <div v-if="goals.length === 0" class="mt-6 rounded-3xl border border-dashed border-slate-300 bg-white px-6 py-12 text-center shadow-sm">
            <h2 class="text-lg font-semibold text-slate-900">Nenhuma meta ainda</h2>
            <p class="mx-auto mt-2 max-w-sm text-sm text-slate-500">
                Uma viagem, uma reserva de emergência, a entrada de um carro. Defina o valor e acompanhe o quanto falta.
            </p>
            <Link
                :href="route('goals.create')"
                class="mt-6 inline-flex items-center gap-2 rounded-2xl bg-slate-900 px-5 py-3 text-sm font-semibold text-white transition-colors hover:bg-slate-800"
            >
                Criar primeira meta
            </Link>
        </div>

        <div v-else :class="[isMobile ? 'mt-6 space-y-4 pb-4' : 'mt-8 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-2 gap-6 pb-8']">
            <Link
                v-for="goal in goals"
                :key="goal.id"
                :href="route('goals.show', { goalId: goal.id })"
                class="group block rounded-[2rem] bg-white p-6 shadow-sm ring-1 ring-slate-200/60 transition-all hover:shadow-lg hover:ring-slate-300/80"
            >
                <!-- `block` é essencial: <Link> vira <a>, que é inline por
                     padrão — sem isso o flex interno colapsava no mobile e o
                     conteúdo se sobrepunha. A bolha decorativa saiu junto:
                     transbordava por cima dos números em telas estreitas. -->
                <div class="flex h-full flex-col justify-between gap-5">
                    <div class="flex items-start gap-4">
                        <!-- O anel carrega o progresso e o ícone ao mesmo tempo:
                             o percentual deixa de ser legenda perdida no rodapé. -->
                        <span class="relative flex h-16 w-16 shrink-0 items-center justify-center">
                            <svg class="absolute inset-0 h-16 w-16 -rotate-90" viewBox="0 0 60 60">
                                <circle cx="30" cy="30" r="26" fill="none" stroke="currentColor" stroke-width="5" class="text-slate-100" />
                                <circle
                                    cx="30"
                                    cy="30"
                                    r="26"
                                    fill="none"
                                    stroke="currentColor"
                                    stroke-width="5"
                                    stroke-linecap="round"
                                    :stroke-dasharray="RING"
                                    :stroke-dashoffset="ringOffset(goal)"
                                    class="transition-[stroke-dashoffset] duration-1000 ease-out"
                                    :class="concluida(goal) ? 'text-emerald-500' : goal.status === 'late' ? 'text-orange-500' : 'text-emerald-500'"
                                />
                            </svg>
                            <span
                                class="relative text-sm font-bold tabular-nums"
                                :class="goal.status === 'late' && !concluida(goal) ? 'text-orange-600' : 'text-slate-900'"
                            >
                                <span v-if="semAlvo(goal)" class="text-slate-300">—</span>
                                <template v-else>{{ pct(goal) }}<span class="text-[10px]">%</span></template>
                            </span>
                        </span>

                        <div class="min-w-0 flex-1">
                            <div class="flex items-start justify-between gap-2">
                                <h3 class="line-clamp-1 text-lg font-bold text-slate-900 transition-colors group-hover:text-emerald-700">
                                    {{ goal.title }}
                                </h3>
                                <span
                                    v-if="concluida(goal)"
                                    class="shrink-0 rounded-full bg-emerald-500 px-2.5 py-1 text-[10px] font-bold text-white"
                                >
                                    Conquistada
                                </span>
                                <span
                                    v-else-if="semAlvo(goal)"
                                    class="shrink-0 rounded-full bg-slate-100 px-2.5 py-1 text-[10px] font-bold text-slate-500"
                                >
                                    Sem alvo
                                </span>
                                <span
                                    v-else
                                    class="shrink-0 rounded-full px-2.5 py-1 text-[10px] font-bold"
                                    :class="statusFor(goal.status).cls"
                                >
                                    {{ statusFor(goal.status).label }}
                                </span>
                            </div>

                            <p class="mt-1 text-xs font-medium text-slate-400">Prazo: {{ goal.due }}</p>
                        </div>
                    </div>

                    <div>
                        <!-- Guardado é o herói; a meta vira referência ao lado. -->
                        <div class="flex flex-wrap items-baseline gap-x-2 gap-y-1">
                            <span class="text-3xl font-bold tracking-tight tabular-nums text-slate-900">
                                {{ formatMoney(goal.current) }}
                            </span>
                            <span v-if="!semAlvo(goal)" class="text-sm font-medium text-slate-400">
                                de {{ formatMoney(goal.target) }}
                            </span>
                            <span v-else class="text-sm font-medium text-slate-400">guardado</span>
                        </div>

                        <p v-if="semAlvo(goal)" class="mt-2 text-sm text-slate-500">
                            Defina um valor-alvo para acompanhar o progresso.
                        </p>
                        <p v-else-if="concluida(goal)" class="mt-2 text-sm font-semibold text-emerald-600">
                            Meta atingida — você chegou lá.
                        </p>
                        <p v-else class="mt-2 text-sm text-slate-500">
                            Faltam <span class="font-semibold text-slate-700">{{ formatMoney(faltam(goal)) }}</span>
                            <template v-if="previsao(goal)"> · {{ previsao(goal) }}</template>
                        </p>
                    </div>
                </div>
            </Link>
        </div>
            </div>

            <!-- Right Column (Desktop Only) -->
            <div v-if="!isMobile" class="lg:col-span-4 lg:sticky lg:top-24 space-y-6">
                <!-- Resumo Geral -->
                <div class="rounded-3xl bg-white p-6 shadow-sm ring-1 ring-slate-200/60">
                    <div class="flex items-center gap-3 mb-6">
                        <div class="flex h-10 w-10 items-center justify-center rounded-2xl bg-emerald-50 text-emerald-600">
                             <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <circle cx="12" cy="12" r="10" />
                                <path d="M12 6v6l4 2" />
                            </svg>
                        </div>
                        <div>
                             <h3 class="text-base font-bold text-slate-900">Resumo Geral</h3>
                             <p class="text-xs font-medium text-slate-500">{{ goals.length }} metas ativas</p>
                        </div>
                    </div>

                    <div class="space-y-4">
                        <div>
                            <div class="flex justify-between items-end mb-1">
                                <span class="text-xs font-bold uppercase tracking-wide text-slate-400">Total Guardado</span>
                                <span class="text-lg font-bold text-emerald-600">{{ formatMoney(totalSaved) }}</span>
                            </div>
                            <div class="h-2 w-full rounded-full bg-slate-100 overflow-hidden">
                                <div class="h-full rounded-full bg-emerald-500 transition-all duration-1000" :style="{ width: `${totalPct}%` }"></div>
                            </div>
                            <div class="text-right mt-1 text-[10px] font-bold text-slate-400">{{ totalPct }}% da meta global</div>
                        </div>

                         <div class="pt-4 border-t border-slate-100 flex justify-between items-center">
                            <span class="text-xs font-semibold text-slate-600">Faltam para atingir tudo</span>
                            <span class="text-sm font-bold text-slate-900">{{ formatMoney(totalTarget - totalSaved) }}</span>
                        </div>
                    </div>

                    <Link :href="route('goals.create')" class="mt-6 flex w-full items-center justify-center gap-2 rounded-2xl bg-slate-900 py-3 text-sm font-bold text-white hover:bg-slate-800 transition-colors">
                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M12 5v14" />
                            <path d="M5 12h14" />
                        </svg>
                        Criar nova meta
                    </Link>
                </div>

                <!-- Metas conquistadas: só aparece quando há o que celebrar.
                     Um card fixo com texto genérico não diz nada sobre você. -->
                <div v-if="metasConcluidas > 0" class="rounded-3xl border border-emerald-100 bg-emerald-50 p-6">
                    <div class="text-3xl font-bold tabular-nums text-emerald-700">{{ metasConcluidas }}</div>
                    <p class="mt-1 text-sm font-medium text-emerald-800">
                        {{ metasConcluidas === 1 ? 'meta conquistada' : 'metas conquistadas' }}
                    </p>
                </div>
            </div>

        </div>

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
