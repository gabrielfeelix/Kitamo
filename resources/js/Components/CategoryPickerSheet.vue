<script setup lang="ts">
import PickerSheet from '@/Components/PickerSheet.vue';

export type CategoryOption = {
    key: string;
    label: string;
    icon: 'food' | 'home' | 'car' | 'other';
    tone: 'amber' | 'blue' | 'slate' | 'purple' | 'red' | 'green';
};

const props = defineProps<{
    open: boolean;
    options: CategoryOption[];
}>();

const emit = defineEmits<{
    (e: 'close'): void;
    (e: 'select', key: string): void;
}>();

const toneClass = (tone: CategoryOption['tone']) => {
    if (tone === 'amber') return 'bg-amber-100 text-amber-600';
    if (tone === 'blue') return 'bg-blue-100 text-blue-600';
    if (tone === 'purple') return 'bg-purple-100 text-purple-600';
    if (tone === 'red') return 'bg-red-100 text-red-600';
    if (tone === 'green') return 'bg-emerald-100 text-emerald-600';
    return 'bg-slate-200 text-slate-600';
};
</script>

<template>
    <PickerSheet :open="open" title="Selecione a Categoria" @close="emit('close')">
        <div class="grid grid-cols-3 gap-4 pb-2">
            <button
                v-for="opt in options"
                :key="opt.key"
                type="button"
                class="flex flex-col items-center gap-2 rounded-2xl px-2 py-2"
                @click="emit('select', opt.key)"
            >
                <span class="flex h-14 w-14 items-center justify-center rounded-full" :class="toneClass(opt.tone)">
                    <svg v-if="opt.icon === 'food'" class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M4 3v7" />
                        <path d="M8 3v7" />
                        <path d="M6 3v7" />
                        <path d="M14 3v7c0 2 1 3 3 3v8" />
                        <path d="M20 3v7" />
                    </svg>
                    <svg v-else-if="opt.icon === 'home'" class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M3 10.5L12 3l9 7.5" />
                        <path d="M5 10v10h14V10" />
                    </svg>
                    <svg v-else-if="opt.icon === 'car'" class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M5 16l1-5 1-3h10l1 3 1 5" />
                        <path d="M7 16h10" />
                        <circle cx="8" cy="17" r="1.5" />
                        <circle cx="16" cy="17" r="1.5" />
                    </svg>
                    <svg v-else class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <rect x="3" y="3" width="18" height="18" rx="4" />
                        <path d="M8 12h8" />
                    </svg>
                </span>
                <span class="text-xs font-semibold text-slate-700">{{ opt.label }}</span>
            </button>
        </div>
    </PickerSheet>
</template>

