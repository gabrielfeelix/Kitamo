<script setup lang="ts">
import { computed, ref, watch, onMounted } from 'vue';
import { Head, Link, usePage } from '@inertiajs/vue3';
import type { BootstrapData } from '@/types/kitamo';
import MobileShell from '@/Layouts/MobileShell.vue';
import KitamoLayout from '@/Layouts/KitamoLayout.vue';
import { useIsMobile } from '@/composables/useIsMobile';
import { requestJson } from '@/lib/kitamoApi';
import CreateCreditCardFlowModal from '@/Components/CreateCreditCardFlowModal.vue';

const isMobile = useIsMobile();
const page = usePage();

const bootstrap = computed(
    () => (page.props.bootstrap ?? { entries: [], goals: [], accounts: [], categories: [] }) as BootstrapData,
);

const activeMonth = ref(new Date());
const monthItems = computed(() => {
    const base = new Date(activeMonth.value.getFullYear(), activeMonth.value.getMonth(), 1);
    const items: Array<{ key: string; label: string; date: Date }> = [];
    for (let i = -2; i <= 2; i += 1) {
        const d = new Date(base.getFullYear(), base.getMonth() + i, 1);
        const label = new Intl.DateTimeFormat('pt-BR', { month: 'short' }).format(d).replace('.', '').toUpperCase();
        items.push({ key: `${d.getFullYear()}-${d.getMonth()}`, label, date: d });
    }
    return items;
});
const selectedMonthKey = ref(monthItems.value[2]?.key ?? monthItems.value[0]?.key ?? '');
const cardsDataByMonth = ref<Map<string, any[]>>(new Map());

const loadCardsForMonth = async (monthKey: string) => {
    if (cardsDataByMonth.value.has(monthKey)) {
        return;
    }

    try {
        const [year, month] = monthKey.split('-').map(Number);
        const response = await requestJson<{ cartoes: any[] }>(`/api/cartoes-by-month?year=${year}&month=${month}`, {
            method: 'GET',
        });
        cardsDataByMonth.value.set(monthKey, response.cartoes);
    } catch (error) {
        console.error('Failed to load cards for month', error);
    }
};

const selectMonth = (monthKey: string) => {
    selectedMonthKey.value = monthKey;
    const item = monthItems.value.find(m => m.key === monthKey);
    if (item) {
        activeMonth.value = item.date;
    }
};

const formatBRL = (value: number) =>
    new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL', minimumFractionDigits: 2 }).format(value);

const formatPercentage = (value: number) => {
    return value.toLocaleString('pt-BR', { minimumFractionDigits: 1, maximumFractionDigits: 1 }) + '%';
};

const creditCards = computed(() => {
    const monthKey = selectedMonthKey.value;
    const monthData = cardsDataByMonth.value.get(monthKey);

    if (monthData) {
        return monthData.map((card: any) => {
            const limite = Number(card.limite ?? 0);
            const usado = Math.max(0, Number(card.limite_usado ?? 0));
            const percentualUsado = limite > 0 ? (usado / limite) * 100 : 0;
            const disponivel = limite - usado;

            let status = 'PAGA';
            if (usado >= limite) status = 'ATRASADA';
            else if (usado > 0) status = 'ABERTA';

            return {
                id: card.id,
                nome: card.nome,
                cor: card.cor ?? '#8B5CF6',
                limite,
                usado,
                disponivel: Math.max(0, disponivel),
                percentualUsado,
                status,
            };
        });
    }

    return (bootstrap.value.accounts ?? [])
        .filter((a) => a.type === 'credit_card')
        .map((a) => {
            const limite = Number(a.credit_limit ?? 0);
            const usado = Math.max(0, Number(a.current_balance ?? 0));
            const percentualUsado = limite > 0 ? (usado / limite) * 100 : 0;
            const disponivel = limite - usado;

            let status = 'PAGA';
            if (usado >= limite) status = 'ATRASADA';
            else if (usado > 0) status = 'ABERTA';

            return {
                id: a.id,
                nome: a.name,
                cor: (a as any).color ?? '#8B5CF6',
                limite,
                usado,
                disponivel: Math.max(0, disponivel),
                percentualUsado,
                status,
            };
        });
});

const devedaConsolidada = computed(() => {
    return creditCards.value.reduce((sum, card) => sum + card.usado, 0);
});

const limiteConsolidado = computed(() => {
    return creditCards.value.reduce((sum, card) => sum + card.limite, 0);
});

const percentualUsoConsolidado = computed(() => {
    if (limiteConsolidado.value === 0) return 0;
    return (devedaConsolidada.value / limiteConsolidado.value) * 100;
});

const disponivelConsolidado = computed(() => {
    return Math.max(0, limiteConsolidado.value - devedaConsolidada.value);
});

const getStatusBadgeClasses = (status: string) => {
    if (status === 'PAGA') return 'bg-emerald-50 text-emerald-600';
    if (status === 'ATRASADA') return 'bg-red-50 text-red-500';
    return 'bg-amber-50 text-amber-600';
};

// Watch for month changes and load data
watch(
    () => selectedMonthKey.value,
    (newMonthKey) => {
        loadCardsForMonth(newMonthKey);
    }
);

// Load initial month data
onMounted(() => {
    loadCardsForMonth(selectedMonthKey.value);
});

const createCreditCardFlowOpen = ref(false);

const handleCreateCreditCardFlowSave = () => {
    createCreditCardFlowOpen.value = false;
    window.location.reload();
};
</script>

<template>
    <Head title="Meus Cartões" />

    <MobileShell v-if="isMobile" :show-nav="false">
        <!-- Header -->
        <header class="flex items-center justify-between px-6 pt-4 pb-6">
            <Link
                :href="route('dashboard')"
                class="flex h-10 w-10 items-center justify-center rounded-2xl bg-white text-slate-600 shadow-sm ring-1 ring-slate-200/60"
                aria-label="Voltar"
            >
                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M15 18l-6-6 6-6" />
                </svg>
            </Link>

            <div class="text-center">
                <div class="text-lg font-semibold text-slate-900">Meus Cartões</div>
            </div>

            <button
                type="button"
                class="flex h-10 w-10 items-center justify-center rounded-2xl bg-white text-slate-600 shadow-sm ring-1 ring-slate-200/60"
                aria-label="Adicionar cartão"
                @click="createCreditCardFlowOpen = true"
            >
                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <line x1="12" y1="5" x2="12" y2="19" />
                    <line x1="5" y1="12" x2="19" y2="12" />
                </svg>
            </button>
        </header>

        <!-- Month Navigation -->
        <div class="px-6 pb-6">
            <div class="flex gap-4 overflow-x-auto pb-2 text-xs font-bold text-slate-300">
                <button
                    v-for="m in monthItems"
                    :key="m.key"
                    type="button"
                    class="relative shrink-0 px-2 py-1"
                    :class="m.key === selectedMonthKey ? 'text-[#14B8A6]' : ''"
                    @click="selectMonth(m.key)"
                >
                    {{ m.label }}
                    <span v-if="m.key === selectedMonthKey" class="absolute inset-x-0 -bottom-1 mx-auto h-1 w-4 rounded-full bg-[#14B8A6]"></span>
                </button>
            </div>
        </div>

        <!-- Dívida Consolidada Card -->
        <div class="px-6">
            <div class="rounded-3xl bg-[#1E293B] p-6 shadow-xl">
                <div class="flex items-start justify-between">
                    <div class="text-[10px] font-semibold uppercase tracking-wider text-[#64748B]">
                        Dívida Consolidada
                    </div>
                    <div class="flex h-8 w-8 items-center justify-center">
                        <svg class="h-4 w-4 text-white/40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <line x1="3" y1="6" x2="21" y2="6" />
                            <line x1="3" y1="12" x2="21" y2="12" />
                            <line x1="3" y1="18" x2="21" y2="18" />
                        </svg>
                    </div>
                </div>

                <div class="mt-3 text-[32px] font-bold leading-none text-white">
                    {{ formatBRL(devedaConsolidada) }}
                </div>

                <div class="mt-5 grid grid-cols-2 gap-4">
                    <!-- Uso de Crédito -->
                    <div>
                        <div class="text-[10px] font-semibold uppercase tracking-wide text-[#64748B]">
                            Uso de Crédito
                        </div>
                        <div class="mt-1 text-2xl font-bold text-[#14B8A6]">
                            {{ formatPercentage(percentualUsoConsolidado) }}
                        </div>
                    </div>

                    <!-- Progress bar vertical -->
                    <div class="flex items-end justify-end">
                        <div class="h-16 w-2 overflow-hidden rounded-full bg-[#334155]">
                            <div
                                class="w-full bg-[#14B8A6] transition-all"
                                :style="{ height: `${Math.min(100, percentualUsoConsolidado)}%` }"
                            ></div>
                        </div>
                    </div>
                </div>

                <div class="mt-4">
                    <div class="text-[10px] font-semibold uppercase tracking-wide text-[#64748B]">
                        Disp. Consolidado
                    </div>
                    <div class="mt-1 text-xl font-bold text-white">
                        {{ formatBRL(disponivelConsolidado) }}
                    </div>
                </div>
            </div>
        </div>

        <!-- Cartões List -->
        <div class="mt-8 px-6">
            <div class="flex items-center justify-between">
                <div class="text-xs font-bold uppercase tracking-wide text-slate-900">
                    Cartões
                </div>
                <div class="text-xs font-semibold uppercase tracking-wide text-slate-400">
                    {{ creditCards.length }} UNIDADES
                </div>
            </div>

            <!-- Cards -->
            <div v-if="creditCards.length" class="mt-5 space-y-4 pb-8">
                <Link
                    v-for="card in creditCards"
                    :key="card.id"
                    :href="route('credit-cards.show', { account: card.id })"
                    class="block overflow-hidden rounded-3xl bg-white shadow-sm ring-1 ring-slate-200"
                >
                    <!-- Card Header with Icon -->
                    <div class="flex items-start gap-4 p-5">
                        <div
                            class="flex h-14 w-14 shrink-0 items-center justify-center rounded-2xl"
                            :style="{ backgroundColor: card.cor }"
                        >
                            <svg class="h-7 w-7 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="2" y="5" width="20" height="14" rx="2" />
                                <line x1="2" y1="10" x2="22" y2="10" />
                            </svg>
                        </div>

                        <div class="flex-1">
                            <div class="text-base font-bold text-slate-900">{{ card.nome }}</div>
                            <div class="mt-1 text-xs font-semibold uppercase tracking-wide text-slate-400">
                                {{ card.nome.toUpperCase() }}
                            </div>
                        </div>

                        <div class="text-right">
                            <div class="text-base font-bold text-slate-900">{{ formatBRL(card.usado) }}</div>
                            <div
                                class="mt-1.5 inline-block rounded-full px-2.5 py-0.5 text-[10px] font-bold uppercase tracking-wide"
                                :class="getStatusBadgeClasses(card.status)"
                            >
                                {{ card.status }}
                            </div>
                        </div>
                    </div>

                    <!-- Card Stats -->
                    <div class="bg-slate-50 px-5 pb-5 pt-3">
                        <div class="flex items-center justify-between text-[10px] font-semibold uppercase tracking-wide text-slate-500">
                            <span>Limite Usado: {{ Math.round(card.percentualUsado) }}%</span>
                            <span>Disp: {{ formatBRL(card.disponivel) }}</span>
                        </div>

                        <!-- Progress Bar -->
                        <div class="mt-2 h-1.5 overflow-hidden rounded-full bg-slate-200">
                            <div
                                class="h-full"
                                :style="{ width: `${Math.min(100, card.percentualUsado)}%`, backgroundColor: card.cor }"
                            ></div>
                        </div>
                    </div>
                </Link>
            </div>

            <div
                v-else
                class="mt-4 rounded-2xl border border-dashed border-slate-200 bg-slate-50 px-4 py-8 text-center"
            >
                <div class="text-sm font-semibold text-slate-900">Nenhum cartão cadastrado</div>
                <div class="mt-1 text-xs text-slate-500">Adicione um cartão para começar</div>
            </div>
        </div>

        <CreateCreditCardFlowModal :open="createCreditCardFlowOpen" @close="createCreditCardFlowOpen = false" @save="handleCreateCreditCardFlowSave" />
    </MobileShell>

    <KitamoLayout v-else title="Meus Cartões" subtitle="Gerencie seus cartões de crédito">
        <div class="rounded-2xl bg-white p-6 shadow-sm ring-1 ring-slate-200/60">
            <div class="text-sm font-semibold text-slate-900">Abra no mobile para ver o layout completo.</div>
        </div>
    </KitamoLayout>
</template>
