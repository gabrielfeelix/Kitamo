<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, Link, usePage } from '@inertiajs/vue3';
import type { BootstrapData } from '@/types/kitamo';
import MobileShell from '@/Layouts/MobileShell.vue';
import KitamoLayout from '@/Layouts/KitamoLayout.vue';
import { useIsMobile } from '@/composables/useIsMobile';

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
        const label = new Intl.DateTimeFormat('pt-BR', { month: 'long', year: 'numeric' })
            .format(d)
            .toUpperCase();
        items.push({ key: `${d.getFullYear()}-${d.getMonth()}`, label, date: d });
    }
    return items;
});
const selectedMonthKey = ref(monthItems.value[2]?.key ?? monthItems.value[0]?.key ?? '');

const formatBRL = (value: number) =>
    new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value);

const creditCards = computed(() =>
    (bootstrap.value.accounts ?? [])
        .filter((a) => a.type === 'credit_card')
        .map((a) => {
            const limite = Number(a.credit_limit ?? 0);
            const usado = Math.max(0, Number(a.current_balance ?? 0));
            const percentualUsado = limite > 0 ? Math.min(100, (usado / limite) * 100) : 0;
            const disponivel = limite - usado;

            return {
                id: a.id,
                nome: a.name,
                cor: (a as any).color ?? '#8B5CF6',
                limite,
                usado,
                disponivel: Math.max(0, disponivel),
                percentualUsado: Math.round(percentualUsado),
                status: usado >= limite ? 'ATRASADA' : usado > 0 ? 'ABERTA' : 'PAGA',
                diaFechamento: a.closing_day ?? '-',
                diaVencimento: a.due_day ?? '-',
            };
        }),
);

const devedaConsolidada = computed(() => {
    return creditCards.value.reduce((sum, card) => sum + card.usado, 0);
});

const limiteConsolidado = computed(() => {
    return creditCards.value.reduce((sum, card) => sum + card.limite, 0);
});

const percentualUsoConsolidado = computed(() => {
    if (limiteConsolidado.value === 0) return 0;
    return Math.round((devedaConsolidada.value / limiteConsolidado.value) * 100);
});

const disponivelConsolidado = computed(() => {
    return limiteConsolidado.value - devedaConsolidada.value;
});

const getStatusColor = (status: string) => {
    if (status === 'PAGA') return 'text-emerald-600';
    if (status === 'ATRASADA') return 'text-red-500';
    return 'text-amber-500';
};

const getStatusBg = (status: string) => {
    if (status === 'PAGA') return 'bg-emerald-50';
    if (status === 'ATRASADA') return 'bg-red-50';
    return 'bg-amber-50';
};

const getProgressColor = (percentual: number) => {
    if (percentual < 50) return 'bg-emerald-500';
    if (percentual < 80) return 'bg-amber-500';
    return 'bg-red-500';
};
</script>

<template>
    <Head title="Meus Cartões" />

    <MobileShell v-if="isMobile">
        <header class="flex items-center justify-between pt-2">
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

            <Link
                :href="route('accounts.card')"
                class="flex h-10 w-10 items-center justify-center rounded-2xl bg-[#14B8A6] text-white shadow-sm"
                aria-label="Adicionar cartão"
            >
                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <line x1="12" y1="5" x2="12" y2="19" />
                    <line x1="5" y1="12" x2="19" y2="12" />
                </svg>
            </Link>
        </header>

        <!-- Month Navigation -->
        <div class="mt-6">
            <div class="flex items-center justify-between gap-2">
                <button type="button" class="text-slate-400 hover:text-slate-600">
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M15 19l-7-7 7-7" />
                    </svg>
                </button>
                <div class="flex-1 text-center">
                    <div class="text-xs font-semibold uppercase tracking-wide text-slate-400">
                        {{ monthItems.find((m) => m.key === selectedMonthKey)?.label }}
                    </div>
                </div>
                <button type="button" class="text-slate-400 hover:text-slate-600">
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M9 5l7 7-7 7" />
                    </svg>
                </button>
            </div>
        </div>

        <!-- Dívida Consolidada -->
        <section class="mt-6 rounded-3xl bg-slate-900 p-5 text-white shadow-lg">
            <div class="flex items-start justify-between">
                <div>
                    <div class="text-xs font-semibold uppercase tracking-wide text-slate-400">Dívida Consolidada</div>
                    <div class="mt-2 text-3xl font-bold">{{ formatBRL(devedaConsolidada) }}</div>
                </div>
                <button
                    type="button"
                    class="flex h-10 w-10 items-center justify-center rounded-full bg-white/10 text-white ring-1 ring-white/10"
                    aria-label="Mais opções"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="currentColor">
                        <circle cx="12" cy="5" r="2" />
                        <circle cx="12" cy="12" r="2" />
                        <circle cx="12" cy="19" r="2" />
                    </svg>
                </button>
            </div>

            <div class="mt-4 grid grid-cols-2 gap-3">
                <div class="rounded-xl bg-white/10 px-3 py-2 ring-1 ring-white/10">
                    <div class="text-xs font-semibold uppercase text-slate-300">Uso de Crédito</div>
                    <div class="mt-1 text-lg font-bold text-white">{{ percentualUsoConsolidado }}%</div>
                </div>
                <div class="rounded-xl bg-white/10 px-3 py-2 ring-1 ring-white/10">
                    <div class="text-xs font-semibold uppercase text-slate-300">Disp Consolidado</div>
                    <div class="mt-1 text-lg font-bold text-white">{{ formatBRL(disponivelConsolidado) }}</div>
                </div>
            </div>
        </section>

        <!-- Cards List -->
        <section class="mt-8">
            <div class="flex items-center justify-between">
                <div class="text-xs font-bold uppercase tracking-wide text-slate-400">
                    Cartões
                    <span class="ml-1 text-slate-600">{{ creditCards.length }} UNIDADES</span>
                </div>
            </div>

            <div v-if="creditCards.length" class="mt-4 space-y-4">
                <Link
                    v-for="card in creditCards"
                    :key="card.id"
                    :href="route('credit-cards.show', { account: card.id })"
                    class="block"
                >
                    <div class="overflow-hidden rounded-2xl bg-white shadow-sm ring-1 ring-slate-200/60">
                        <!-- Card Header -->
                        <div
                            class="flex items-start justify-between p-4 text-white"
                            :style="{ backgroundColor: card.cor }"
                        >
                            <div>
                                <div class="text-sm font-semibold opacity-80">{{ card.nome }}</div>
                                <div class="mt-1 text-lg font-bold">{{ formatBRL(card.usado) }}</div>
                            </div>
                            <div
                                class="rounded-full px-3 py-1 text-xs font-bold uppercase"
                                :class="getStatusBg(card.status)"
                            >
                                <span :class="getStatusColor(card.status)">{{ card.status }}</span>
                            </div>
                        </div>

                        <!-- Card Stats -->
                        <div class="bg-slate-50 px-4 py-3">
                            <div class="text-xs font-semibold uppercase tracking-wide text-slate-500">
                                Limite Usado {{ card.percentualUsado }}%
                            </div>
                            <div class="mt-2 h-2 overflow-hidden rounded-full bg-slate-200">
                                <div
                                    class="h-full transition-all"
                                    :class="getProgressColor(card.percentualUsado)"
                                    :style="{ width: `${Math.min(100, card.percentualUsado)}%` }"
                                ></div>
                            </div>
                            <div class="mt-2 flex items-center justify-between text-xs text-slate-500">
                                <span>{{ formatBRL(card.usado) }}</span>
                                <span>{{ formatBRL(card.disponivel) }}</span>
                            </div>
                            <div class="mt-2 text-xs font-semibold text-slate-600">
                                DISP {{ formatBRL(card.disponivel) }}
                            </div>
                        </div>
                    </div>
                </Link>
            </div>

            <div
                v-else
                class="mt-4 rounded-2xl border border-dashed border-slate-200 bg-slate-50 px-4 py-6 text-center"
            >
                <div class="text-sm font-semibold text-slate-900">Nenhum cartão cadastrado</div>
            </div>
        </section>
    </MobileShell>

    <KitamoLayout v-else title="Meus Cartões" subtitle="Gerencie seus cartões de crédito">
        <div class="rounded-2xl bg-white p-6 shadow-sm ring-1 ring-slate-200/60">
            <div class="text-sm font-semibold text-slate-900">Abra no mobile para ver o layout completo.</div>
        </div>
    </KitamoLayout>
</template>
