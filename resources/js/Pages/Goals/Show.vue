<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, Link, usePage } from '@inertiajs/vue3';
import { requestJson } from '@/lib/kitamoApi';
import type { BootstrapData, Goal } from '@/types/kitamo';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import AddMoneyModal from '@/Components/AddMoneyModal.vue';
import MobileToast from '@/Components/MobileToast.vue';
import { useIsMobile } from '@/composables/useIsMobile';
import type { AccountOption } from '@/Components/AccountPickerSheet.vue';

const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() =>
    isMobile.value ? { showNav: false } : { title: 'Metas', subtitle: 'Detalhes', showSearch: false, showNewAction: false },
);

const page = usePage();
const bootstrap = computed(
    () => (page.props.bootstrap ?? { entries: [], goals: [], accounts: [], categories: [], tags: [] }) as BootstrapData,
);

const props = defineProps<{
    goalId: string;
}>();

type GoalColor = 'teal' | 'blue' | 'orange';
type GoalIcon = 'home' | 'plane' | 'car';

const goalData = ref<Goal | null>(bootstrap.value.goals.find((g) => g.id === props.goalId) ?? null);

const goal = computed(() => {
    const g = goalData.value;
    if (!g) return { id: props.goalId, title: 'Meta', color: 'teal' as GoalColor, icon: 'home' as GoalIcon, target: 0, current: 0, due: '' };
    const color: GoalColor = g.icon === 'plane' ? 'blue' : g.icon === 'car' ? 'orange' : 'teal';
    const icon: GoalIcon = g.icon === 'plane' ? 'plane' : g.icon === 'car' ? 'car' : 'home';
    return { id: g.id, title: g.title, color, icon, target: g.target, current: g.current, due: g.due };
});

const pct = computed(() => Math.min(100, Math.round((goal.value.current / goal.value.target) * 100)));
const remaining = computed(() => Math.max(0, goal.value.target - goal.value.current));

const formatMoney0 = (value: number) =>
    new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL', maximumFractionDigits: 0 }).format(value);

const headerClass = computed(() => {
    if (goal.value.color === 'blue') return 'bg-[#2563EB]';
    if (goal.value.color === 'orange') return 'bg-[#F97316]';
    return 'bg-[#0D9488]';
});

const depositOpen = ref(false);
const toastOpen = ref(false);
const toastMessage = ref('');
const showToast = (message: string) => {
    toastMessage.value = message;
    toastOpen.value = true;
};

const deposits = computed(() => goalData.value?.deposits ?? []);

const onDepositConfirm = async (payload: { amount: string }) => {
    const value = Number(payload.amount.replace(/\./g, '').replace(',', '.')) || 0;
    const response = await requestJson<{ goal: Goal }>(route('goals.deposits.store', goal.value.id), {
        method: 'POST',
        body: JSON.stringify({ amount: value, title: 'Depósito manual' }),
    });
    goalData.value = response.goal;
    showToast('Valor adicionado');
};

const pickerAccounts = computed<AccountOption[]>(() => {
    const options: AccountOption[] = [];
    for (const a of bootstrap.value.accounts ?? []) {
        if (a.type === 'credit_card') continue;
        options.push({
            key: a.name,
            label: a.name,
            subtitle: a.type === 'wallet' ? 'Carteira' : 'Conta',
            type: a.type as any,
            balance: Number(a.current_balance ?? 0),
            customColor: (a as any).color ?? undefined,
            icon: a.icon ?? undefined,
        });
    }
    return options;
});

const onDepositConfirmWithFrom = async (payload: { amount: string; from: string; repeat: boolean }) => {
    await onDepositConfirm({ amount: payload.amount });

    const value = Number(payload.amount.replace(/\./g, '').replace(',', '.')) || 0;
    if (!payload.from || !value) return;

    try {
        const txPayload = {
            kind: 'expense',
            amount: value,
            description: `Depósito meta: ${goal.value.title}`,
            category: 'Metas',
            account: payload.from,
            dateKind: 'today',
            dateOther: '',
            isPaid: true,
            isInstallment: false,
            installmentCount: 1,
            tags: [],
        };

        await requestJson(route('transactions.store'), {
            method: 'POST',
            body: JSON.stringify(txPayload),
        });
    } catch {
        // ignore transaction creation failures, goal deposit already done
    }
};
</script>

<template>
    <Head :title="goal.title" />

    <component :is="Shell" v-bind="shellProps">
        <header v-if="isMobile" class="relative flex items-center justify-center pt-2">
            <Link
                :href="route('goals.index')"
                class="absolute left-0 flex h-10 w-10 items-center justify-center rounded-2xl bg-white text-slate-600 shadow-sm ring-1 ring-slate-200/60"
                aria-label="Voltar"
            >
                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M15 18l-6-6 6-6" />
                </svg>
            </Link>
            <div class="text-base font-semibold text-slate-900">{{ goal.title }}</div>
            <Link
                :href="route('goals.edit', { goalId: goal.id })"
                class="absolute right-0 flex h-10 w-10 items-center justify-center rounded-full bg-white text-slate-600 shadow-sm ring-1 ring-slate-200/60"
                aria-label="Editar"
            >
                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M12 20h9" />
                    <path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L8 18l-4 1 1-4 11.5-11.5Z" />
                </svg>
            </Link>
        </header>

        <div class="mt-4" :class="[isMobile ? 'flex flex-col' : 'grid grid-cols-1 lg:grid-cols-12 gap-8 items-start']">
            <!-- Left Column: Main Info -->
            <div class="w-full" :class="[isMobile ? '' : 'lg:col-span-8']">
                <div class="-mx-5 overflow-hidden rounded-b-[36px] px-5 pb-10 pt-8 text-white md:mx-0 md:rounded-3xl md:px-8 md:pb-12 md:pt-10 transition-colors" :class="headerClass">
                    <div class="flex flex-col items-center">
                        <div class="flex h-20 w-20 items-center justify-center rounded-full bg-white/20 ring-1 ring-white/30">
                            <svg v-if="goal.icon === 'home'" class="h-9 w-9" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M3 10.5L12 3l9 7.5" />
                                <path d="M5 10v10h14V10" />
                            </svg>
                            <svg v-else-if="goal.icon === 'plane'" class="h-9 w-9" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M2 16l20-8-20-8 6 8-6 8Z" />
                                <path d="M6 16v6l4-4" />
                            </svg>
                            <svg v-else class="h-9 w-9" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M5 16l1-5 1-3h10l1 3 1 5" />
                                <path d="M7 16h10" />
                                <circle cx="8" cy="17" r="1.5" />
                                <circle cx="16" cy="17" r="1.5" />
                            </svg>
                        </div>

                        <div class="mt-6 text-sm font-semibold opacity-90">Total economizado</div>
                        <div class="mt-2 text-4xl font-bold tracking-tight">
                            <span class="mr-2 align-middle text-2xl font-semibold opacity-90">R$</span>
                            <span class="align-middle">{{ formatMoney0(goal.current).replace('R$', '').trim() }}</span>
                        </div>

                        <div class="mt-6 w-full max-w-lg">
                            <div class="flex items-center justify-between text-xs font-semibold opacity-90">
                                <div>{{ pct }}%</div>
                                <div>Meta: {{ formatMoney0(goal.target).replace('R$', 'R$') }}</div>
                            </div>
                            <div class="mt-3 h-3 w-full rounded-full bg-black/20">
                                <div class="h-3 rounded-full bg-white transition-all duration-1000" :style="{ width: `${pct}%` }"></div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="-mt-7 grid grid-cols-2 gap-3 md:mt-6">
                    <div class="rounded-3xl bg-white p-4 shadow-sm ring-1 ring-slate-200/60">
                        <div class="text-[10px] font-semibold uppercase tracking-wide text-slate-400">FALTAM</div>
                        <div class="mt-2 text-lg font-semibold text-slate-900">{{ formatMoney0(remaining).replace('R$', 'R$') }}</div>
                    </div>
                    <div class="rounded-3xl bg-white p-4 shadow-sm ring-1 ring-slate-200/60">
                        <div class="text-[10px] font-semibold uppercase tracking-wide text-slate-400">PRAZO</div>
                        <div class="mt-2 text-lg font-semibold text-slate-900">{{ goal.due }}</div>
                    </div>
                </div>
            </div>

            <!-- Right Column: History -->
            <div class="w-full" :class="[isMobile ? 'mt-7' : 'lg:col-span-4 lg:sticky lg:top-24']">
                
                <div v-if="!isMobile" class="mb-6 rounded-3xl bg-white p-6 shadow-sm ring-1 ring-slate-200/60">
                     <h3 class="text-lg font-bold text-slate-900 mb-4">Ações</h3>
                     <button
                        type="button"
                        class="flex h-12 w-full items-center justify-center gap-2 rounded-2xl bg-[#14B8A6] text-base font-bold text-white shadow-[0_2px_8px_rgba(20,184,166,0.25)] hover:bg-[#0D9488] transition-colors"
                        @click="depositOpen = true"
                    >
                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M12 5v14" />
                            <path d="M5 12h14" />
                        </svg>
                        Adicionar valor
                    </button>
                    <div class="mt-3 flex gap-3">
                         <Link :href="route('goals.edit', { goalId: goal.id })" class="flex-1 flex items-center justify-center gap-2 rounded-xl bg-slate-50 py-3 text-sm font-semibold text-slate-600 hover:bg-slate-100">
                             Editar
                         </Link>
                         <!-- Opção de deletar poderia estar aqui -->
                    </div>
                </div>

                <div class="text-base font-semibold text-slate-900 mb-4 px-1">Histórico de depósitos</div>
                
                <div v-if="deposits.length === 0" class="rounded-3xl border border-dashed border-slate-200 bg-slate-50 p-6 text-center">
                    <p class="text-sm text-slate-500">Nenhum depósito feito ainda.</p>
                </div>

                <div v-else class="space-y-3 pb-[calc(7rem+env(safe-area-inset-bottom))] lg:pb-0">
                    <div v-for="d in deposits" :key="d.id" class="flex items-center justify-between rounded-3xl bg-white px-4 py-4 shadow-sm ring-1 ring-slate-200/60 transition hover:bg-slate-50">
                        <div class="flex items-center gap-3">
                            <span class="flex h-11 w-11 items-center justify-center rounded-2xl bg-emerald-50 text-emerald-600">
                                <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M12 3v14" />
                                    <path d="M7 12l5 5 5-5" />
                                </svg>
                            </span>
                            <div>
                                <div class="text-sm font-semibold text-slate-900">{{ d.title }}</div>
                                <div class="mt-1 text-xs font-semibold text-slate-400">{{ d.subtitle }}</div>
                            </div>
                        </div>
                        <div class="text-sm font-semibold text-emerald-600">+ {{ formatMoney0(d.amount).replace('R$', 'R$') }}</div>
                    </div>
                </div>
            </div>
        </div>

        <div class="fixed inset-x-0 bottom-0 bg-white px-5 pb-[calc(1rem+env(safe-area-inset-bottom))] pt-3 shadow-[0_-18px_40px_-32px_rgba(15,23,42,0.45)] md:static md:bg-transparent md:px-0 md:pb-0 md:pt-6 md:shadow-none">
            <div class="mx-auto w-full max-w-md">
                <button
                    type="button"
                    class="flex h-[52px] w-full items-center justify-center gap-2 rounded-2xl bg-[#14B8A6] text-base font-bold text-white shadow-[0_2px_8px_rgba(20,184,166,0.25)]"
                    @click="depositOpen = true"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M12 5v14" />
                        <path d="M5 12h14" />
                    </svg>
                    Adicionar valor
                </button>
            </div>
        </div>

        <AddMoneyModal
            :open="depositOpen"
            :accent="goal.color === 'blue' ? 'blue' : 'teal'"
            :accounts="pickerAccounts"
            @close="depositOpen = false"
            @confirm="onDepositConfirmWithFrom"
        />
        <MobileToast :show="toastOpen" :message="toastMessage" @dismiss="toastOpen = false" />
    </component>
</template>
