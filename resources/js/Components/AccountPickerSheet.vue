<script setup lang="ts">
import PickerSheet from '@/Components/PickerSheet.vue';

export type AccountOption = {
    key: string;
    label: string;
    subtitle?: string;
    tone: 'purple' | 'amber' | 'emerald' | 'slate';
};

const props = defineProps<{
    open: boolean;
    options: AccountOption[];
}>();

const emit = defineEmits<{
    (e: 'close'): void;
    (e: 'select', key: string): void;
}>();

const toneClass = (tone: AccountOption['tone']) => {
    if (tone === 'purple') return 'bg-purple-100 text-purple-600';
    if (tone === 'amber') return 'bg-amber-100 text-amber-600';
    if (tone === 'emerald') return 'bg-emerald-100 text-emerald-600';
    return 'bg-slate-200 text-slate-600';
};
</script>

<template>
    <PickerSheet :open="open" title="Qual conta usar?" @close="emit('close')">
        <div class="space-y-3 pb-2">
            <button
                v-for="opt in options"
                :key="opt.key"
                type="button"
                class="flex w-full items-center gap-4 rounded-2xl bg-slate-50 px-4 py-4 text-left ring-1 ring-slate-200/70"
                @click="emit('select', opt.key)"
            >
                <span class="flex h-12 w-12 items-center justify-center rounded-full" :class="toneClass(opt.tone)">
                    <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M3 10h18" />
                        <path d="M5 10V8l7-5 7 5v2" />
                        <path d="M6 10v9" />
                        <path d="M18 10v9" />
                    </svg>
                </span>
                <div class="min-w-0 flex-1">
                    <div class="truncate text-base font-semibold text-slate-900">{{ opt.label }}</div>
                    <div v-if="opt.subtitle" class="mt-0.5 truncate text-xs font-semibold text-slate-400">{{ opt.subtitle }}</div>
                </div>
                <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                    <path d="M9 5l7 7-7 7" />
                </svg>
            </button>
        </div>
    </PickerSheet>
</template>

