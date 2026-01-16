<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import { computed, onMounted, ref } from 'vue';
import MobileShell from '@/Layouts/MobileShell.vue';
import KitamoLayout from '@/Layouts/KitamoLayout.vue';
import { useIsMobile } from '@/composables/useIsMobile';

type HomeWidgetsState = {
    accounts: boolean;
    creditCards: boolean;
    projection: boolean;
    upcomingBills: boolean;
};

const STORAGE_KEY = 'kitamo:home_widgets';

const isMobile = useIsMobile();

const state = ref<HomeWidgetsState>({
    accounts: true,
    creditCards: true,
    projection: true,
    upcomingBills: true,
});

onMounted(() => {
    try {
        const raw = localStorage.getItem(STORAGE_KEY);
        if (!raw) return;
        const parsed = JSON.parse(raw) as Partial<HomeWidgetsState>;
        state.value = { ...state.value, ...parsed };
    } catch {
        // ignore
    }
});

const save = () => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(state.value));
};

const toggle = (key: keyof HomeWidgetsState) => {
    state.value[key] = !state.value[key];
    save();
};

const items = computed(() => [
    {
        key: 'accounts' as const,
        title: 'Contas bancárias',
        description: 'Mostra suas contas e saldo atual',
        icon: 'bank' as const,
    },
    {
        key: 'creditCards' as const,
        title: 'Cartões de crédito',
        description: 'Mostra cartões e faturas',
        icon: 'card' as const,
    },
    {
        key: 'projection' as const,
        title: 'Projeção 30 dias',
        description: 'Gráfico e alertas de projeção',
        icon: 'chart' as const,
    },
    {
        key: 'upcomingBills' as const,
        title: 'Próximas contas',
        description: 'Lista de gastos a pagar',
        icon: 'calendar' as const,
    },
]);
</script>

<template>
    <Head title="Tela inicial" />

    <MobileShell v-if="isMobile" :show-nav="false">
        <header class="relative flex items-center justify-center pt-2">
            <Link
                :href="route('settings')"
                class="absolute left-0 flex h-10 w-10 items-center justify-center rounded-2xl bg-white text-slate-600 shadow-sm ring-1 ring-slate-200/60"
                aria-label="Voltar"
            >
                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M15 18l-6-6 6-6" />
                </svg>
            </Link>
            <div class="text-xl font-semibold tracking-tight text-slate-900">Tela inicial</div>
        </header>

        <div class="mt-6 rounded-3xl bg-white p-5 shadow-sm ring-1 ring-slate-200/60">
            <div class="text-sm font-semibold text-slate-900">Gerenciar tela inicial</div>
            <div class="mt-1 text-xs font-semibold text-slate-400">Ative ou oculte seções na Home.</div>

            <div class="mt-5 space-y-3">
                <button
                    v-for="item in items"
                    :key="item.key"
                    type="button"
                    class="flex w-full items-center justify-between rounded-2xl bg-slate-50 px-4 py-4 text-left ring-1 ring-slate-200/60"
                    @click="toggle(item.key)"
                >
                    <div class="flex items-center gap-4">
                        <span class="flex h-11 w-11 items-center justify-center rounded-2xl bg-white text-slate-500 ring-1 ring-slate-200/60">
                            <svg v-if="item.icon === 'bank'" class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M3 10h18" />
                                <path d="M5 10V8l7-5 7 5v2" />
                                <path d="M6 10v9" />
                                <path d="M18 10v9" />
                            </svg>
                            <svg v-else-if="item.icon === 'card'" class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="5" width="18" height="14" rx="3" />
                                <path d="M3 10h18" />
                            </svg>
                            <svg v-else-if="item.icon === 'calendar'" class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="4" width="18" height="18" rx="3" />
                                <path d="M8 2v4" />
                                <path d="M16 2v4" />
                                <path d="M3 10h18" />
                            </svg>
                            <svg v-else class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M4 19V5" />
                                <path d="M10 19V9" />
                                <path d="M16 19v-4" />
                                <path d="M22 19V7" />
                            </svg>
                        </span>
                        <div>
                            <div class="text-sm font-semibold text-slate-900">{{ item.title }}</div>
                            <div class="mt-1 text-xs font-semibold text-slate-400">{{ item.description }}</div>
                        </div>
                    </div>

                    <span
                        class="relative inline-flex h-7 w-12 items-center rounded-full transition"
                        :class="state[item.key] ? 'bg-[#14B8A6]' : 'bg-slate-300'"
                        aria-label="Ativar/ocultar"
                    >
                        <span
                            class="inline-block h-6 w-6 transform rounded-full bg-white transition"
                            :class="state[item.key] ? 'translate-x-5' : 'translate-x-1'"
                        ></span>
                    </span>
                </button>
            </div>
        </div>
    </MobileShell>

    <KitamoLayout v-else title="Tela inicial" subtitle="Gerenciar seções">
        <div class="rounded-2xl bg-white p-6 shadow-sm ring-1 ring-slate-200/60">
            <div class="text-sm font-semibold text-slate-900">Abra no mobile para configurar.</div>
        </div>
    </KitamoLayout>
</template>

