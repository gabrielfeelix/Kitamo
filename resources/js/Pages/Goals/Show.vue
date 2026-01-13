<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, Link } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import KitamoLayout from '@/Layouts/KitamoLayout.vue';
import AddMoneyModal from '@/Components/AddMoneyModal.vue';
import MobileToast from '@/Components/MobileToast.vue';
import { useMediaQuery } from '@/composables/useMediaQuery';
import { addDepositToGoal, getGoal, type Goal } from '@/stores/localStore';

const isMobile = useMediaQuery('(max-width: 767px)');

const props = defineProps<{
    goalId: string;
}>();

type GoalColor = 'teal' | 'blue' | 'orange';
type GoalIcon = 'home' | 'plane' | 'car';

const goalData = ref<Goal | null>(getGoal(props.goalId));

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

const onDepositConfirm = (payload: { amount: string }) => {
    const value = Number(payload.amount.replace(/\./g, '').replace(',', '.')) || 0;
    addDepositToGoal(goal.value.id, { title: 'Depósito manual', subtitle: 'Hoje', amount: value });
    goalData.value = getGoal(goal.value.id);
    showToast('Valor adicionado');
};
</script>

<template>
    <Head :title="goal.title" />

    <MobileShell v-if="isMobile" :show-nav="false">
        <header class="relative flex items-center justify-center pt-2">
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

        <div class="-mx-5 mt-4 overflow-hidden rounded-b-[36px] px-5 pb-10 pt-8 text-white" :class="headerClass">
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

                <div class="mt-6 w-full">
                    <div class="flex items-center justify-between text-xs font-semibold opacity-90">
                        <div>{{ pct }}%</div>
                        <div>Meta: {{ formatMoney0(goal.target).replace('R$', 'R$') }}</div>
                    </div>
                    <div class="mt-3 h-3 w-full rounded-full bg-black/20">
                        <div class="h-3 rounded-full bg-white" :style="{ width: `${pct}%` }"></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="-mt-7 grid grid-cols-2 gap-3">
            <div class="rounded-3xl bg-white p-4 shadow-sm ring-1 ring-slate-200/60">
                <div class="text-[10px] font-semibold uppercase tracking-wide text-slate-400">FALTAM</div>
                <div class="mt-2 text-lg font-semibold text-slate-900">{{ formatMoney0(remaining).replace('R$', 'R$') }}</div>
            </div>
            <div class="rounded-3xl bg-white p-4 shadow-sm ring-1 ring-slate-200/60">
                <div class="text-[10px] font-semibold uppercase tracking-wide text-slate-400">PRAZO</div>
                <div class="mt-2 text-lg font-semibold text-slate-900">{{ goal.due }}</div>
            </div>
        </div>

        <div class="mt-7 pb-[calc(7rem+env(safe-area-inset-bottom))]">
            <div class="text-base font-semibold text-slate-900">Histórico de depósitos</div>
            <div class="mt-4 space-y-3">
                <div v-for="d in deposits" :key="d.id" class="flex items-center justify-between rounded-3xl bg-white px-4 py-4 shadow-sm ring-1 ring-slate-200/60">
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

        <div class="fixed inset-x-0 bottom-0 bg-white px-5 pb-[calc(1rem+env(safe-area-inset-bottom))] pt-3 shadow-[0_-18px_40px_-32px_rgba(15,23,42,0.45)]">
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
            @close="depositOpen = false"
            @confirm="onDepositConfirm"
        />
        <MobileToast :show="toastOpen" :message="toastMessage" @dismiss="toastOpen = false" />
    </MobileShell>

    <KitamoLayout v-else :title="goal.title" subtitle="Mobile-first por enquanto.">
        <div class="rounded-[28px] border border-white/70 bg-white p-8 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)]">
            <div class="text-sm font-semibold text-slate-900">Detalhe de meta (desktop/tablet)</div>
            <div class="mt-2 text-sm text-slate-500">Vamos adaptar essa tela depois da versão mobile.</div>
        </div>
    </KitamoLayout>
</template>
