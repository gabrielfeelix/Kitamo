<script setup lang="ts">
import { computed } from 'vue';
import type { Goal } from '@/types/kitamo';

const props = defineProps<{
    open: boolean;
    goal: Goal | null;
}>();

const emit = defineEmits<{
    (event: 'close'): void;
    (event: 'add-money'): void;
    (event: 'edit'): void;
    (event: 'delete'): void;
}>();

const pct = computed(() => {
    const g = props.goal;
    if (!g?.target) return 0;
    return Math.min(100, Math.round((g.current / g.target) * 100));
});

const formatMoney0 = (value: number) =>
    new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL', maximumFractionDigits: 0 }).format(value);
</script>

<template>
    <div v-if="open" class="fixed inset-0 z-[95]">
        <button class="absolute inset-0 bg-black/35 backdrop-blur-sm" type="button" @click="emit('close')" aria-label="Fechar"></button>

        <aside class="absolute right-0 top-0 flex h-screen w-[440px] flex-col bg-white shadow-[-18px_0_60px_-40px_rgba(15,23,42,0.6)]">
            <header class="flex items-center justify-between border-b border-slate-100 px-8 py-6">
                <div class="text-base font-semibold text-slate-900">Detalhes da Meta</div>
                <button
                    type="button"
                    class="flex h-10 w-10 items-center justify-center rounded-xl bg-slate-50 text-slate-400 hover:bg-slate-100"
                    aria-label="Fechar"
                    @click="emit('close')"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M18 6L6 18" />
                        <path d="M6 6l12 12" />
                    </svg>
                </button>
            </header>

            <div class="min-h-0 flex-1 overflow-y-auto px-8 py-8">
                <div class="flex flex-col items-center">
                    <div class="flex h-20 w-20 items-center justify-center rounded-3xl bg-emerald-50 text-[#14B8A6] ring-1 ring-emerald-100">
                        <svg v-if="goal?.icon === 'home'" class="h-10 w-10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M3 10.5L12 3l9 7.5" />
                            <path d="M5 10v10h14V10" />
                        </svg>
                        <svg v-else-if="goal?.icon === 'plane'" class="h-10 w-10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M2 16l20-8-20-8 6 8-6 8Z" />
                            <path d="M6 16v6l4-4" />
                        </svg>
                        <svg v-else class="h-10 w-10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M5 16l1-5 1-3h10l1 3 1 5" />
                            <path d="M7 16h10" />
                            <circle cx="8" cy="17" r="1.5" />
                            <circle cx="16" cy="17" r="1.5" />
                        </svg>
                    </div>

                    <div class="mt-6 text-2xl font-semibold text-slate-900">{{ goal?.title }}</div>
                    <div class="mt-2 text-sm font-semibold text-slate-400"><span class="text-[#14B8A6]">{{ pct }}%</span> concluído</div>

                    <div class="mt-6 h-2 w-full rounded-full bg-slate-100">
                        <div class="h-2 rounded-full bg-[#14B8A6]" :style="{ width: `${pct}%` }"></div>
                    </div>
                </div>

                <div class="mt-7 grid grid-cols-2 gap-4">
                    <div class="rounded-2xl bg-slate-50 px-5 py-4">
                        <div class="text-[11px] font-bold uppercase tracking-wide text-slate-400">Poupado</div>
                        <div class="mt-2 text-sm font-semibold text-slate-700">{{ formatMoney0(goal?.current ?? 0).replace('R$', 'R$') }}</div>
                    </div>
                    <div class="rounded-2xl bg-slate-50 px-5 py-4">
                        <div class="text-[11px] font-bold uppercase tracking-wide text-slate-400">Objetivo</div>
                        <div class="mt-2 text-sm font-semibold text-slate-700">{{ formatMoney0(goal?.target ?? 0).replace('R$', 'R$') }}</div>
                    </div>
                </div>

                <div class="mt-5 flex flex-wrap gap-2">
                    <span
                        v-for="t in goal?.tags ?? []"
                        :key="t"
                        class="inline-flex items-center rounded-full border border-slate-200 bg-slate-50 px-3 py-1 text-xs font-semibold text-slate-600"
                    >
                        {{ t }}
                    </span>
                </div>

                <div class="mt-8">
                    <div class="flex items-center gap-2 text-sm font-semibold text-slate-700">
                        <svg class="h-5 w-5 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M6 6v12" />
                            <path d="M18 6v12" />
                            <path d="M8 8h8" />
                            <path d="M8 12h8" />
                        </svg>
                        Histórico de Depósitos
                    </div>

                    <div class="mt-4 space-y-3">
                        <div
                            v-for="d in (goal?.deposits ?? []).slice(0, 5)"
                            :key="d.id"
                            class="flex items-center justify-between rounded-2xl border border-slate-100 bg-white px-4 py-4"
                        >
                            <div class="flex items-center gap-3">
                                <span class="flex h-10 w-10 items-center justify-center rounded-full bg-emerald-50 text-emerald-600">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M12 3v14" />
                                        <path d="M7 12l5 5 5-5" />
                                    </svg>
                                </span>
                                <div>
                                    <div class="text-sm font-semibold text-slate-900">{{ d.title }}</div>
                                    <div class="mt-0.5 text-xs font-semibold text-slate-400">{{ d.subtitle }}</div>
                                </div>
                            </div>
                            <div class="text-sm font-bold text-emerald-600">+ {{ formatMoney0(d.amount).replace('R$', 'R$') }}</div>
                        </div>
                    </div>
                </div>
            </div>

            <footer class="border-t border-slate-100 px-8 py-6">
                <button
                    type="button"
                    class="flex h-12 w-full items-center justify-center gap-2 rounded-xl bg-[#14B8A6] text-sm font-semibold text-white shadow-lg shadow-emerald-500/20"
                    @click="emit('add-money')"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M12 5v14" />
                        <path d="M5 12h14" />
                    </svg>
                    Adicionar Dinheiro
                </button>

                <div class="mt-4 grid grid-cols-2 gap-4">
                    <button type="button" class="h-11 rounded-xl bg-slate-100 text-sm font-semibold text-slate-600" @click="emit('edit')">Editar Meta</button>
                    <button type="button" class="h-11 rounded-xl border border-red-200 bg-white text-sm font-semibold text-red-500" @click="emit('delete')">Excluir</button>
                </div>
            </footer>
        </aside>
    </div>
</template>

