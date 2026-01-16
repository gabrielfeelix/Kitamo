<script setup lang="ts">
import { computed, ref, watch } from 'vue';

export type TransactionFilterState = {
    categories: string[];
    tags: string[];
    period: 'month' | '3m' | '6m';
    status: 'all' | 'paid' | 'to_pay';
    min: string;
    max: string;
};

const props = defineProps<{
    open: boolean;
    categories: { key: string; label: string; icon: 'food' | 'home' | 'car' }[];
    initial: TransactionFilterState;
    resultsCount: number;
}>();

const emit = defineEmits<{
    (event: 'close'): void;
    (event: 'apply', payload: TransactionFilterState): void;
    (event: 'clear'): void;
}>();

const close = () => emit('close');

const local = ref<TransactionFilterState>({
    categories: [],
    tags: [],
    period: 'month',
    status: 'all',
    min: '0,00',
    max: '10.000,00',
});

watch(
    () => props.open,
    (isOpen) => {
        if (!isOpen) return;
        local.value = { ...props.initial, categories: [...props.initial.categories], tags: [...props.initial.tags] };
    },
);

const toggleCategory = (key: string) => {
    const list = new Set(local.value.categories);
    if (list.has(key)) list.delete(key);
    else list.add(key);
    local.value.categories = Array.from(list);
};

const toggleTag = (tag: string) => {
    const list = new Set(local.value.tags);
    if (list.has(tag)) list.delete(tag);
    else list.add(tag);
    local.value.tags = Array.from(list);
};

const normalizeMoneyInput = (raw: string) => {
    const digits = raw.replace(/[^\d]/g, '');
    const padded = digits.padStart(3, '0');
    const cents = padded.slice(-2);
    const whole = padded.slice(0, -2).replace(/^0+/, '') || '0';
    return `${whole},${cents}`;
};

const onMinInput = (event: Event) => {
    const target = event.target as HTMLInputElement;
    local.value.min = normalizeMoneyInput(target.value);
};

const onMaxInput = (event: Event) => {
    const target = event.target as HTMLInputElement;
    local.value.max = normalizeMoneyInput(target.value);
};

const centsFromMoneyInput = (value: string) => {
    const digits = value.replace(/[^\d]/g, '');
    const padded = digits.padStart(3, '0');
    const cents = Number(padded);
    return Number.isFinite(cents) ? cents : 0;
};

const moneyInputFromCents = (cents: number) => {
    const safe = Math.max(0, Math.floor(cents));
    const padded = String(safe).padStart(3, '0');
    const centsPart = padded.slice(-2);
    const whole = padded.slice(0, -2).replace(/^0+/, '') || '0';
    const wholeWithThousands = whole.replace(/\B(?=(\d{3})+(?!\d))/g, '.');
    return `${wholeWithThousands},${centsPart}`;
};

const RANGE_MAX_CENTS = 1_000_000; // R$ 10.000,00
const rangeMinCents = computed(() => Math.min(RANGE_MAX_CENTS, centsFromMoneyInput(local.value.min)));
const rangeMaxCents = computed(() => Math.min(RANGE_MAX_CENTS, centsFromMoneyInput(local.value.max)));
const rangeMinPct = computed(() => (RANGE_MAX_CENTS ? (rangeMinCents.value / RANGE_MAX_CENTS) * 100 : 0));
const rangeMaxPct = computed(() => (RANGE_MAX_CENTS ? (rangeMaxCents.value / RANGE_MAX_CENTS) * 100 : 0));

watch(
    () => local.value.min,
    () => {
        const minCents = rangeMinCents.value;
        const maxCents = rangeMaxCents.value;
        if (minCents > maxCents) {
            local.value.max = moneyInputFromCents(minCents);
        }
    },
);

watch(
    () => local.value.max,
    () => {
        const minCents = rangeMinCents.value;
        const maxCents = rangeMaxCents.value;
        if (maxCents < minCents) {
            local.value.min = moneyInputFromCents(maxCents);
        }
    },
);

const onRangeMinInput = (event: Event) => {
    const value = Number((event.target as HTMLInputElement).value);
    const next = Math.max(0, Math.min(value, rangeMaxCents.value));
    local.value.min = moneyInputFromCents(next);
};

const onRangeMaxInput = (event: Event) => {
    const value = Number((event.target as HTMLInputElement).value);
    const next = Math.min(RANGE_MAX_CENTS, Math.max(value, rangeMinCents.value));
    local.value.max = moneyInputFromCents(next);
};

const periodButtonClass = (value: TransactionFilterState['period']) =>
    local.value.period === value ? 'border-[#14B8A6] text-[#14B8A6] bg-[#E6FFFB]' : 'border-slate-200 text-slate-600 bg-white';

const statusButtonClass = (value: TransactionFilterState['status']) =>
    local.value.status === value ? 'border-[#14B8A6] text-[#14B8A6] bg-[#E6FFFB]' : 'border-slate-200 text-slate-600 bg-white';

const canApply = computed(() => true);
</script>

<template>
    <div v-if="open" class="fixed inset-0 z-[75]">
        <button class="absolute inset-0 bg-black/50 backdrop-blur-sm" type="button" @click="close" aria-label="Fechar"></button>

        <div class="absolute inset-x-0 bottom-0 h-[650px] max-h-[calc(100vh-150px)] w-full overflow-hidden rounded-t-[24px] bg-white shadow-[0_-4px_20px_rgba(0,0,0,0.25)]">
            <div class="flex h-full flex-col">
                <header class="relative flex h-14 items-center justify-between px-4">
                    <button class="h-10 w-10 rounded-full bg-slate-100 text-slate-500" type="button" @click="close" aria-label="Fechar">
                        <svg class="mx-auto h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M18 6L6 18" />
                            <path d="M6 6l12 12" />
                        </svg>
                    </button>

                    <div class="pointer-events-none absolute inset-0 flex items-center justify-center">
                        <div class="text-[16px] font-bold text-[#1F2937]">Filtrar transações</div>
                    </div>

                    <button type="button" class="text-sm font-semibold text-[#14B8A6]" @click="emit('clear')">Limpar</button>
                </header>

                <div class="flex-1 overflow-y-auto px-6 pb-6 pt-2">
                    <div class="text-sm font-bold text-slate-900">Categorias</div>
                    <div class="mt-3 grid grid-cols-2 gap-3">
                        <button
                            v-for="cat in categories"
                            :key="cat.key"
                            type="button"
                            class="flex items-center gap-3 rounded-xl bg-white px-3 py-3 text-left"
                            @click="toggleCategory(cat.key)"
                        >
                            <span
                                class="flex h-6 w-6 items-center justify-center rounded-md border"
                                :class="local.categories.includes(cat.key) ? 'border-[#14B8A6] bg-[#14B8A6]' : 'border-slate-200 bg-white'"
                            >
                                <svg v-if="local.categories.includes(cat.key)" class="h-4 w-4 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">
                                    <path d="M20 6 9 17l-5-5" />
                                </svg>
                            </span>
                            <span class="flex items-center gap-2 text-sm font-semibold text-slate-600">
                                <svg v-if="cat.icon === 'food'" class="h-5 w-5 text-amber-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M4 3v7" />
                                    <path d="M8 3v7" />
                                    <path d="M6 3v7" />
                                    <path d="M14 3v7c0 2 1 3 3 3v8" />
                                    <path d="M20 3v7" />
                                </svg>
                                <svg v-else-if="cat.icon === 'home'" class="h-5 w-5 text-blue-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M3 10.5L12 3l9 7.5" />
                                    <path d="M5 10v10h14V10" />
                                </svg>
                                <svg v-else class="h-5 w-5 text-slate-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M5 16l1-5 1-3h10l1 3 1 5" />
                                    <path d="M7 16h10" />
                                    <circle cx="8" cy="17" r="1.5" />
                                    <circle cx="16" cy="17" r="1.5" />
                                </svg>
                                {{ cat.label }}
                            </span>
                        </button>
                    </div>

                    <div class="mt-6 text-sm font-bold text-slate-900">Tags</div>
                    <div class="mt-3 flex flex-wrap gap-3">
                        <button
                            type="button"
                            class="rounded-full border px-4 py-2 text-sm font-semibold"
                            :class="local.tags.includes('Essencial') ? 'border-[#14B8A6] bg-[#E6FFFB] text-[#14B8A6]' : 'border-slate-200 bg-white text-slate-600'"
                            @click="toggleTag('Essencial')"
                        >
                            Essencial
                        </button>
                        <button
                            type="button"
                            class="rounded-full border px-4 py-2 text-sm font-semibold"
                            :class="local.tags.includes('Recorrente') ? 'border-[#14B8A6] bg-[#E6FFFB] text-[#14B8A6]' : 'border-slate-200 bg-white text-slate-600'"
                            @click="toggleTag('Recorrente')"
                        >
                            Recorrente
                        </button>
                        <button
                            type="button"
                            class="rounded-full border px-4 py-2 text-sm font-semibold"
                            :class="local.tags.includes('Urgente') ? 'border-[#14B8A6] bg-[#E6FFFB] text-[#14B8A6]' : 'border-slate-200 bg-white text-slate-600'"
                            @click="toggleTag('Urgente')"
                        >
                            Urgente
                        </button>
                    </div>

                    <div class="mt-6 text-sm font-bold text-slate-900">Status</div>
                    <div class="mt-3 flex flex-wrap gap-3">
                        <button type="button" class="rounded-full border px-4 py-2 text-sm font-semibold" :class="statusButtonClass('all')" @click="local.status = 'all'">
                            Todas
                        </button>
                        <button type="button" class="rounded-full border px-4 py-2 text-sm font-semibold" :class="statusButtonClass('paid')" @click="local.status = 'paid'">
                            Pagas
                        </button>
                        <button type="button" class="rounded-full border px-4 py-2 text-sm font-semibold" :class="statusButtonClass('to_pay')" @click="local.status = 'to_pay'">
                            A pagar
                        </button>
                    </div>

                    <div class="mt-6 text-sm font-bold text-slate-900">Período</div>
                    <div class="mt-3 flex flex-wrap gap-3">
                        <button type="button" class="rounded-full border px-4 py-2 text-sm font-semibold" :class="periodButtonClass('month')" @click="local.period = 'month'">
                            Este mês
                        </button>
                        <button type="button" class="rounded-full border px-4 py-2 text-sm font-semibold" :class="periodButtonClass('3m')" @click="local.period = '3m'">
                            Últimos 3 meses
                        </button>
                        <button type="button" class="rounded-full border px-4 py-2 text-sm font-semibold" :class="periodButtonClass('6m')" @click="local.period = '6m'">
                            Últimos 6 meses
                        </button>
                    </div>

                    <div class="mt-6 text-sm font-bold text-slate-900">Valor</div>
                    <div class="mt-3 grid grid-cols-2 gap-5">
                        <div>
                            <div class="text-xs font-bold text-slate-400">MÍNIMO</div>
                            <div class="mt-2 border-b border-slate-200 pb-2">
                                <div class="flex items-center gap-2 text-xs font-semibold text-slate-900">
                                    <span class="text-slate-500">R$</span>
                                    <input
                                        class="w-full bg-transparent text-xs font-semibold text-slate-900 focus:outline-none"
                                        :value="local.min"
                                        inputmode="numeric"
                                        @input="onMinInput"
                                        aria-label="Valor mínimo"
                                    />
                                </div>
                            </div>
                        </div>
                        <div>
                            <div class="text-xs font-bold text-slate-400">MÁXIMO</div>
                            <div class="mt-2 border-b border-slate-200 pb-2">
                                <div class="flex items-center gap-2 text-xs font-semibold text-slate-900">
                                    <span class="text-slate-500">R$</span>
                                    <input
                                        class="w-full bg-transparent text-xs font-semibold text-slate-900 focus:outline-none"
                                        :value="local.max"
                                        inputmode="numeric"
                                        @input="onMaxInput"
                                        aria-label="Valor máximo"
                                    />
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="mt-4">
                        <div class="relative h-2 rounded-full bg-slate-200">
                            <div
                                class="absolute h-2 rounded-full bg-[#14B8A6]"
                                :style="{ left: `${rangeMinPct}%`, width: `${Math.max(0, rangeMaxPct - rangeMinPct)}%` }"
                            ></div>
                        </div>
                        <div class="relative mt-2 h-6">
                            <input
                                type="range"
                                min="0"
                                :max="RANGE_MAX_CENTS"
                                step="100"
                                :value="rangeMinCents"
                                class="absolute inset-0 h-6 w-full bg-transparent opacity-0"
                                @input="onRangeMinInput"
                                aria-label="Controle mínimo"
                            />
                            <input
                                type="range"
                                min="0"
                                :max="RANGE_MAX_CENTS"
                                step="100"
                                :value="rangeMaxCents"
                                class="absolute inset-0 h-6 w-full bg-transparent opacity-0"
                                @input="onRangeMaxInput"
                                aria-label="Controle máximo"
                            />
                            <div
                                class="pointer-events-none absolute top-1/2 h-4 w-4 -translate-y-1/2 rounded-full border border-slate-200 bg-white shadow"
                                :style="{ left: `calc(${rangeMinPct}% - 8px)` }"
                            ></div>
                            <div
                                class="pointer-events-none absolute top-1/2 h-4 w-4 -translate-y-1/2 rounded-full border border-slate-200 bg-white shadow"
                                :style="{ left: `calc(${rangeMaxPct}% - 8px)` }"
                            ></div>
                        </div>
                        <div class="mt-1 flex items-center justify-between text-[10px] font-semibold text-slate-400">
                            <span>R$ 0</span>
                            <span>R$ 10.000</span>
                        </div>
                    </div>
                </div>

                <footer class="px-6 pb-[calc(18px+env(safe-area-inset-bottom))] pt-3">
                    <button
                        type="button"
                        class="h-[52px] w-full rounded-xl bg-[#14B8A6] text-base font-bold text-white shadow-[0_2px_8px_rgba(20,184,166,0.25)] disabled:opacity-60"
                        :disabled="!canApply"
                        @click="emit('apply', local)"
                    >
                        Aplicar filtros
                    </button>
                    <div class="mt-3 text-center text-xs font-semibold text-slate-400">{{ resultsCount }} transações encontradas</div>
                </footer>
            </div>
        </div>
    </div>
</template>
