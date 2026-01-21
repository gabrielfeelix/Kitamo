<script setup lang="ts">
import { computed } from 'vue';

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
            <div class="text-sm font-semibold tracking-wide text-slate-900">{{ monthLabel }}</div>
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
</template>
