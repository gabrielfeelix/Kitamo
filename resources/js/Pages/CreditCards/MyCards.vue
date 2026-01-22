<script setup lang="ts">
import { computed, ref, watch, onMounted } from 'vue';
import { Head, Link } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import { useIsMobile } from '@/composables/useIsMobile';
import CreateCreditCardFlowModal from '@/Components/CreateCreditCardFlowModal.vue';
import MonthNavigator from '@/Components/MonthNavigator.vue';
import { requestJson } from '@/lib/kitamoApi';
import { getBankSvgPath } from '@/lib/bankLogos';

const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() =>
    isMobile.value ? { showNav: false } : { title: 'Meus Cartões', subtitle: 'Cartões de crédito', showSearch: false, showNewAction: false },
);

const formatBRL = (value: number) =>
    new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL', minimumFractionDigits: 2 }).format(value);

const formatPercentage = (value: number) => {
    return value.toLocaleString('pt-BR', { minimumFractionDigits: 1, maximumFractionDigits: 1 }) + '%';
};

// Month selection logic
const monthItems = computed(() => {
    const base = new Date();
    const items: Array<{ key: string; label: string; date: Date }> = [];
    for (let i = -2; i <= 2; i += 1) {
        const d = new Date(base.getFullYear(), base.getMonth() + i, 1);
        const label = new Intl.DateTimeFormat('pt-BR', { month: 'short' }).format(d).replace('.', '').toUpperCase();
        items.push({ key: `${d.getFullYear()}-${d.getMonth()}`, label, date: d });
    }
    return items;
});

const selectedMonthKey = ref('');
const cardsDataByMonth = ref<Map<string, any[]>>(new Map());
const loadingMonthKeys = ref<Set<string>>(new Set());

onMounted(() => {
    selectedMonthKey.value = monthItems.value[2]?.key ?? monthItems.value[0]?.key ?? '';
});

// Watch for month changes and load data
watch(
    selectedMonthKey,
    (key) => {
        if (key) {
            void loadCardsForMonth(key);
        }
    },
    { immediate: true },
);

const loadCardsForMonth = async (monthKey: string) => {
    const cacheKey = `cards-${monthKey}`;

    // Clear previous data for this month to avoid showing stale data
    cardsDataByMonth.value.delete(cacheKey);

    if (loadingMonthKeys.value.has(cacheKey)) {
        return;
    }
    loadingMonthKeys.value.add(cacheKey);

    try {
        const [year, month] = monthKey.split('-').map(Number);
        const response = await requestJson<{ cartoes: any[] }>(`/api/cartoes-by-month?year=${year}&month=${month}`, {
            method: 'GET',
        });
        cardsDataByMonth.value.set(cacheKey, Array.isArray((response as any)?.cartoes) ? (response as any).cartoes : []);
    } catch (error) {
        console.error('Failed to load credit cards for month', error);
        cardsDataByMonth.value.set(cacheKey, []);
    } finally {
        loadingMonthKeys.value.delete(cacheKey);
    }
};

const isLoading = computed(() => {
    const monthKey = selectedMonthKey.value;
    if (!monthKey) return false;
    const cacheKey = `cards-${monthKey}`;
    return loadingMonthKeys.value.has(cacheKey);
});

const creditCards = computed(() => {
    const monthKey = selectedMonthKey.value;
    if (!monthKey) return [];
    const cacheKey = `cards-${monthKey}`;

    // If loading, return empty array to show loading state
    if (loadingMonthKeys.value.has(cacheKey)) {
        return [];
    }

    const monthData = cardsDataByMonth.value.get(cacheKey) ?? [];
    if (!cardsDataByMonth.value.has(cacheKey)) return [];

    return monthData.map((a) => {
        const limite = Number(a.credit_limit ?? a.limite ?? 0);
        const usado = Math.max(0, Number(a.current_balance ?? a.limite_usado ?? 0));
        const percentualUsado = limite > 0 ? (usado / limite) * 100 : 0;
        const disponivel = limite - usado;

        let status = 'PAGA';
        if (usado >= limite) status = 'ATRASADA';
        else if (usado > 0) status = 'ABERTA';

        const banco = a.institution ?? null;
        return {
            id: a.id,
            nome: a.name || a.nome,
            bandeira: a.bandeira ?? a.card_brand ?? null,
            fechamentoDia: Number(a.dia_fechamento ?? a.closing_day ?? 0) || null,
            vencimentoDia: Number(a.dia_vencimento ?? a.due_day ?? 0) || null,
            cor: ((a as any).color || a.cor) ?? '#8B5CF6',
            banco,
            svgPath: banco ? getBankSvgPath(banco) : null,
            limite,
            usado,
            disponivel: Math.max(0, disponivel),
            percentualUsado,
            status,
        };
    });
});

const creditCardsDisplay = computed(() => {
    const normalize = (value: string) => String(value ?? '').trim().toLowerCase();
    const grouped = new Map<string, Array<(typeof creditCards.value)[number]>>();

    for (const card of creditCards.value) {
        const key = normalize(card.nome);
        const items = grouped.get(key) ?? [];
        items.push(card);
        grouped.set(key, items);
    }

    const result: Array<(typeof creditCards.value)[number] & { displayName: string }> = [];
    for (const group of grouped.values()) {
        if (group.length === 1) {
            result.push({ ...group[0]!, displayName: group[0]!.nome });
            continue;
        }

        const sorted = [...group].sort((a, b) => String(a.id).localeCompare(String(b.id)));
        const hasBrandDiff = new Set(sorted.map((c) => String(c.bandeira ?? '').toLowerCase())).size > 1;
        const hasDueDiff = new Set(sorted.map((c) => c.vencimentoDia ?? null)).size > 1;
        const hasClosingDiff = new Set(sorted.map((c) => c.fechamentoDia ?? null)).size > 1;

        sorted.forEach((card, index) => {
            const canDisambiguate = hasBrandDiff || hasDueDiff || hasClosingDiff;
            const displayName = canDisambiguate ? card.nome : `${card.nome} (${index + 1})`;
            result.push({ ...card, displayName });
        });
    }

    const indexById = new Map(creditCards.value.map((c, idx) => [String(c.id), idx]));
    return result.sort((a, b) => (indexById.get(String(a.id)) ?? 0) - (indexById.get(String(b.id)) ?? 0));
});

watch(
    () => selectedMonthKey.value,
    (newMonthKey) => {
        if (newMonthKey) {
            loadCardsForMonth(newMonthKey);
        }
    }
);

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

const createCreditCardFlowOpen = ref(false);

const handleCreateCreditCardFlowSave = () => {
    createCreditCardFlowOpen.value = false;
    window.location.reload();
};
</script>

<template>
    <Head title="Meus Cartões" />

    <component :is="Shell" v-bind="shellProps">
        <template v-if="!isMobile" #headerActions>
            <button
                type="button"
                class="flex h-11 w-11 items-center justify-center rounded-2xl bg-white text-slate-600 ring-1 ring-slate-200/60"
                aria-label="Adicionar cartão"
                @click="createCreditCardFlowOpen = true"
            >
                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <line x1="12" y1="5" x2="12" y2="19" />
                    <line x1="5" y1="12" x2="19" y2="12" />
                </svg>
            </button>
        </template>

        <!-- Header -->
        <header v-if="isMobile" class="flex items-center justify-between px-6 pt-4 pb-8">
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

        <!-- Month Selector -->
        <div :class="isMobile ? 'px-6 pb-6' : 'pb-6'">
            <MonthNavigator v-model="selectedMonthKey" :months="monthItems" />
        </div>

        <!-- Dívida Consolidada Card -->
        <div :class="isMobile ? 'px-6' : ''">
            <div class="rounded-3xl bg-[#1E293B] p-6 shadow-xl">
                <!-- Header -->
                <div class="flex items-start justify-between">
                    <div class="text-[10px] font-semibold uppercase tracking-wider text-[#64748B]">
                        Dívida Consolidada
                    </div>
                    <div class="flex h-6 w-6 items-center justify-center">
                        <svg class="h-4 w-4 text-white/30" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <line x1="3" y1="6" x2="21" y2="6" />
                            <line x1="3" y1="12" x2="21" y2="12" />
                            <line x1="3" y1="18" x2="21" y2="18" />
                        </svg>
                    </div>
                </div>

                <!-- Valor principal -->
                <div v-if="isLoading" class="mt-3 h-10 w-48 animate-pulse rounded-lg bg-white/10"></div>
                <div v-else class="mt-3 text-[32px] font-bold leading-none text-white">
                    {{ formatBRL(devedaConsolidada) }}
                </div>

                <!-- Grid de 2 colunas -->
                <div v-if="isLoading" class="mt-6 grid grid-cols-2 gap-6">
                    <!-- Coluna esquerda: Uso de crédito -->
                    <div>
                        <div class="text-[10px] font-semibold uppercase tracking-wide text-[#64748B]">
                            Uso de Crédito
                        </div>
                        <div class="mt-1 flex items-center gap-2">
                            <div class="h-7 w-16 animate-pulse rounded bg-white/10"></div>
                            <div class="h-1.5 flex-1 animate-pulse rounded-full bg-[#334155]"></div>
                        </div>
                    </div>

                    <!-- Coluna direita: Disponível consolidado -->
                    <div>
                        <div class="text-[10px] font-semibold uppercase tracking-wide text-[#64748B]">
                            Disp. Consolidado
                        </div>
                        <div class="mt-1 h-7 w-32 animate-pulse rounded bg-white/10"></div>
                    </div>
                </div>

                <div v-else class="mt-6 grid grid-cols-2 gap-6">
                    <!-- Coluna esquerda: Uso de crédito -->
                    <div>
                        <div class="text-[10px] font-semibold uppercase tracking-wide text-[#64748B]">
                            Uso de Crédito
                        </div>
                        <!-- Percentual e barra na mesma linha -->
                        <div class="mt-1 flex items-center gap-2">
                            <div class="text-xl font-bold text-[#14B8A6] whitespace-nowrap">
                                {{ formatPercentage(percentualUsoConsolidado) }}
                            </div>
                            <!-- Barra horizontal (pequena, ao lado) -->
                            <div class="h-1.5 flex-1 overflow-hidden rounded-full bg-[#334155]">
                                <div
                                    class="h-full bg-[#14B8A6] transition-all"
                                    :style="{ width: `${Math.min(100, percentualUsoConsolidado)}%` }"
                                ></div>
                            </div>
                        </div>
                    </div>

                    <!-- Coluna direita: Disponível consolidado -->
                    <div>
                        <div class="text-[10px] font-semibold uppercase tracking-wide text-[#64748B]">
                            Disp. Consolidado
                        </div>
                        <div class="mt-1 text-xl font-bold text-white">
                            {{ formatBRL(disponivelConsolidado) }}
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Cartões List -->
        <div :class="isMobile ? 'mt-8 px-6' : 'mt-10'">
            <div class="flex items-center justify-between">
                <div class="text-xs font-bold uppercase tracking-wide text-slate-900">
                    Cartões
                </div>
                <div class="text-xs font-semibold uppercase tracking-wide text-slate-400">
                    {{ creditCards.length }} UNIDADES
                </div>
            </div>

            <!-- Loading Skeletons -->
            <div
                v-if="isLoading"
                :class="isMobile ? 'mt-4 space-y-3 pb-8' : 'mt-5 grid grid-cols-2 gap-4 pb-10 xl:grid-cols-3'"
            >
                <div v-for="i in 3" :key="i" class="overflow-hidden rounded-2xl bg-white shadow-sm ring-1 ring-slate-200/60">
                    <div class="p-4">
                        <div class="flex items-start gap-3">
                            <div class="h-12 w-12 shrink-0 animate-pulse rounded-2xl bg-slate-200"></div>
                            <div class="flex-1 min-w-0">
                                <div class="h-5 w-32 animate-pulse rounded bg-slate-200"></div>
                                <div class="mt-2 flex gap-1">
                                    <div class="h-5 w-12 animate-pulse rounded-md bg-slate-100"></div>
                                    <div class="h-5 w-8 animate-pulse rounded-md bg-slate-100"></div>
                                    <div class="h-5 w-8 animate-pulse rounded-md bg-slate-100"></div>
                                </div>
                            </div>
                            <div class="text-right">
                                <div class="h-5 w-20 animate-pulse rounded bg-slate-200"></div>
                                <div class="mt-1 h-5 w-16 animate-pulse rounded-md bg-slate-100"></div>
                            </div>
                        </div>
                        <div class="mt-3 flex items-center justify-between">
                            <div class="h-4 w-32 animate-pulse rounded bg-slate-100"></div>
                            <div class="h-4 w-24 animate-pulse rounded bg-slate-100"></div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Cards -->
            <div
                v-else-if="creditCards.length"
                :class="isMobile ? 'mt-4 space-y-3 pb-8' : 'mt-5 grid grid-cols-2 gap-4 pb-10 xl:grid-cols-3'"
            >
                <Link
                    v-for="card in creditCardsDisplay"
                    :key="card.id"
                    :href="route('credit-cards.show', { account: card.id })"
                    class="block overflow-hidden rounded-2xl bg-white shadow-sm ring-1 ring-slate-200/60"
                >
                    <!-- Card Content -->
                    <div class="p-4">
                        <div class="flex items-start gap-3">
                            <!-- Icon -->
                            <div
                                v-if="card.svgPath"
                                class="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-white"
                            >
                                <img
                                    :src="`/Bancos-em-SVG-main/${card.svgPath}`"
                                    :alt="card.banco ?? ''"
                                    class="h-10 w-10 object-contain"
                                    @error="($event.target as HTMLImageElement).style.display = 'none'"
                                />
                            </div>
                            <div
                                v-else
                                class="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl"
                                :style="{ backgroundColor: card.cor }"
                            >
                                <svg class="h-6 w-6 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <rect x="2" y="5" width="20" height="14" rx="2" />
                                    <line x1="2" y1="10" x2="22" y2="10" />
                                </svg>
                            </div>

                            <!-- Card Info -->
                            <div class="flex-1 min-w-0">
                                <div class="text-base font-bold text-slate-900">{{ card.displayName }}</div>
                                <div class="mt-1 flex flex-wrap items-center gap-1 text-[11px] font-semibold text-slate-500">
                                    <span
                                        v-if="card.bandeira"
                                        class="inline-flex items-center rounded-md bg-slate-100 px-2 py-0.5 uppercase tracking-wide text-slate-500"
                                    >
                                        {{ String(card.bandeira) }}
                                    </span>
                                </div>
                            </div>

                            <!-- Amount and Status -->
                            <div class="text-right">
                                <div class="text-base font-bold text-slate-900">{{ formatBRL(card.usado) }}</div>
                                <div
                                    class="mt-1 inline-block rounded-md px-2 py-0.5 text-[10px] font-bold uppercase tracking-wide"
                                    :class="getStatusBadgeClasses(card.status)"
                                >
                                    {{ card.status }}
                                </div>
                            </div>
                        </div>

                        <!-- Stats and Progress Bar -->
                        <div class="mt-3 space-y-2">
                            <!-- Stats -->
                            <div class="flex items-center justify-between text-[11px] font-medium text-slate-500">
                                <span>LIMITE USADO: {{ Math.round(card.percentualUsado) }}%</span>
                                <span>DISP: {{ formatBRL(card.disponivel) }}</span>
                            </div>

                            <!-- Progress Bar -->
                            <div class="h-1.5 w-full overflow-hidden rounded-full bg-slate-100">
                                <div
                                    class="h-full rounded-full transition-all duration-300"
                                    :style="{
                                        width: `${Math.min(card.percentualUsado, 100)}%`,
                                        backgroundColor: card.cor
                                    }"
                                ></div>
                            </div>

                            <div class="mt-3 flex items-center justify-between text-[11px] font-semibold text-slate-500">
                                <div class="flex flex-wrap items-center gap-4">
                                    <span v-if="card.fechamentoDia" class="inline-flex items-center gap-1" :title="`Fechamento dia ${card.fechamentoDia}`">
                                        <svg class="h-4 w-4 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M8 2v4" />
                                            <path d="M16 2v4" />
                                            <path d="M3 10h18" />
                                            <path d="M5 6h14a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2Z" />
                                        </svg>
                                        FECHA DIA {{ String(card.fechamentoDia).padStart(2, '0') }}
                                    </span>
                                    <span v-if="card.vencimentoDia" class="inline-flex items-center gap-1" :title="`Vencimento dia ${card.vencimentoDia}`">
                                        <svg class="h-4 w-4 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M8 2v4" />
                                            <path d="M16 2v4" />
                                            <path d="M3 10h18" />
                                            <path d="M5 6h14a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2Z" />
                                            <path d="M12 14v4" />
                                            <path d="M12 12h.01" />
                                        </svg>
                                        VENCE DIA {{ String(card.vencimentoDia).padStart(2, '0') }}
                                    </span>
                                </div>
                            </div>
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
    </component>
</template>
