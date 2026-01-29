<script setup lang="ts">
import { computed, ref, watch } from 'vue';

interface Props {
    modelValue: string;
    months: Array<{ key: string; label: string; date: Date }>;
}

const props = defineProps<Props>();
const emit = defineEmits<{
    (e: 'update:modelValue', value: string): void;
}>();

const selected = computed({
    get: () => props.modelValue,
    set: (val: string) => emit('update:modelValue', val),
});

const selectedMonth = computed(() => props.months.find((m) => m.key === selected.value));

const currentIndex = computed(() => props.months.findIndex((m) => m.key === selected.value));

const pickerOpen = ref(false);
const pickerYear = ref<number>(new Date().getFullYear());

const previousMonth = () => {
    if (currentIndex.value > 0) {
        selected.value = props.months[currentIndex.value - 1].key;
    }
};

const nextMonth = () => {
    if (currentIndex.value < props.months.length - 1) {
        selected.value = props.months[currentIndex.value + 1].key;
    }
};

const canGoPrevious = computed(() => currentIndex.value > 0);

const canGoNext = computed(() => currentIndex.value < props.months.length - 1);

const monthLabel = computed(() => {
    if (!selectedMonth.value) return '';
    const month = new Intl.DateTimeFormat('pt-BR', { month: 'long' }).format(selectedMonth.value.date);
    const year = selectedMonth.value.date.getFullYear();
    return `${month.charAt(0).toUpperCase() + month.slice(1)} ${year}`;
});

const years = computed(() => {
    const ys = Array.from(new Set(props.months.map((m) => m.date.getFullYear()))).sort((a, b) => a - b);
    return ys;
});

const monthsByYear = computed(() => {
    const map = new Map<number, Map<number, { key: string; date: Date }>>();
    for (const m of props.months) {
        const y = m.date.getFullYear();
        const idx = m.date.getMonth();
        if (!map.has(y)) map.set(y, new Map());
        map.get(y)!.set(idx, { key: m.key, date: m.date });
    }
    return map;
});

const monthShort = (monthIndex: number) => {
    const date = new Date(2026, monthIndex, 1);
    const short = new Intl.DateTimeFormat('pt-BR', { month: 'short' }).format(date);
    return short.replace('.', '').toUpperCase();
};

const canGoPrevYear = computed(() => years.value.length > 0 && pickerYear.value > years.value[0]);
const canGoNextYear = computed(() => years.value.length > 0 && pickerYear.value < years.value[years.value.length - 1]);

const openPicker = () => {
    const y = selectedMonth.value?.date.getFullYear() ?? new Date().getFullYear();
    pickerYear.value = y;
    pickerOpen.value = true;
};

const closePicker = () => {
    pickerOpen.value = false;
};

const selectMonthIndex = (monthIndex: number) => {
    const key = monthsByYear.value.get(pickerYear.value)?.get(monthIndex)?.key ?? null;
    if (!key) return;
    selected.value = key;
    pickerOpen.value = false;
};

const selectCurrentMonth = () => {
    const now = new Date();
    const key = monthsByYear.value.get(now.getFullYear())?.get(now.getMonth())?.key ?? null;
    if (!key) return;
    selected.value = key;
    pickerOpen.value = false;
};

watch(
    () => props.modelValue,
    () => {
        if (!pickerOpen.value) return;
        pickerYear.value = selectedMonth.value?.date.getFullYear() ?? pickerYear.value;
    },
);
</script>

<template>
    <div class="flex items-center justify-between rounded-2xl bg-white px-4 py-3 shadow-sm ring-1 ring-slate-200/60">
        <button
            type="button"
            class="flex h-10 w-10 items-center justify-center rounded-xl text-slate-500 hover:bg-slate-50 disabled:opacity-50 disabled:cursor-not-allowed"
            :disabled="!canGoPrevious"
            aria-label="Mês anterior"
            @click="previousMonth"
        >
            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M15 18l-6-6 6-6" />
            </svg>
        </button>

        <div class="flex-1 text-center">
            <button
                type="button"
                class="inline-flex items-center justify-center gap-2 rounded-full px-4 py-1.5 text-sm font-semibold tracking-wide text-slate-900 hover:bg-slate-50"
                aria-label="Escolher mês"
                @click="openPicker"
            >
                <span>{{ monthLabel }}</span>
                <svg class="h-4 w-4 text-slate-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                    <path d="M6 9l6 6 6-6" />
                </svg>
            </button>
        </div>

        <button
            type="button"
            class="flex h-10 w-10 items-center justify-center rounded-xl text-slate-500 hover:bg-slate-50 disabled:opacity-50 disabled:cursor-not-allowed"
            :disabled="!canGoNext"
            aria-label="Próximo mês"
            @click="nextMonth"
        >
            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M9 18l6-6-6-6" />
            </svg>
        </button>
    </div>

    <div v-if="pickerOpen" class="fixed inset-0 z-[90]">
        <button class="absolute inset-0 bg-black/40 backdrop-blur-sm" type="button" aria-label="Fechar" @click="closePicker"></button>

        <div class="absolute left-1/2 top-28 w-[min(360px,calc(100vw-2.5rem))] -translate-x-1/2 overflow-hidden rounded-3xl bg-white shadow-[0_20px_60px_-20px_rgba(0,0,0,0.4)] ring-1 ring-slate-200/60">
            <div class="flex items-center justify-between bg-[#6D28D9] px-5 py-4 text-white">
                <button
                    type="button"
                    class="flex h-9 w-9 items-center justify-center rounded-2xl bg-white/10 disabled:opacity-50"
                    :disabled="!canGoPrevYear"
                    aria-label="Ano anterior"
                    @click="pickerYear = pickerYear - 1"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M15 18l-6-6 6-6" />
                    </svg>
                </button>

                <div class="text-lg font-bold tracking-wide">{{ pickerYear }}</div>

                <button
                    type="button"
                    class="flex h-9 w-9 items-center justify-center rounded-2xl bg-white/10 disabled:opacity-50"
                    :disabled="!canGoNextYear"
                    aria-label="Próximo ano"
                    @click="pickerYear = pickerYear + 1"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M9 18l6-6-6-6" />
                    </svg>
                </button>
            </div>

            <div class="grid grid-cols-4 gap-y-6 px-6 py-6">
                <button
                    v-for="idx in 12"
                    :key="idx"
                    type="button"
                    class="text-center text-xs font-bold tracking-wide"
                    :class="{
                        'text-[#6D28D9]': monthsByYear.get(pickerYear)?.get(idx - 1)?.key === selected,
                        'text-slate-900 hover:text-[#6D28D9]': monthsByYear.get(pickerYear)?.has(idx - 1),
                        'text-slate-300 cursor-not-allowed': !monthsByYear.get(pickerYear)?.has(idx - 1),
                    }"
                    :disabled="!monthsByYear.get(pickerYear)?.has(idx - 1)"
                    @click="selectMonthIndex(idx - 1)"
                >
                    {{ monthShort(idx - 1) }}
                </button>
            </div>

            <div class="flex items-center justify-between px-6 pb-5">
                <button type="button" class="text-sm font-semibold text-[#6D28D9]" @click="closePicker">Cancelar</button>
                <button type="button" class="text-sm font-semibold text-[#6D28D9]" @click="selectCurrentMonth">Mês atual</button>
            </div>
        </div>
    </div>
</template>
