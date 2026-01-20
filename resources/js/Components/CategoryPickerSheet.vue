<script setup lang="ts">
import PickerSheet from '@/Components/PickerSheet.vue';
import CategoryIcon from '@/Components/CategoryIcon.vue';

export type CategoryOption = {
    key: string;
    label: string;
    icon: string | 'food' | 'home' | 'car' | 'other';
    tone?: 'amber' | 'blue' | 'slate' | 'purple' | 'red' | 'green';
    customColor?: string;
};

const props = defineProps<{
    open: boolean;
    options: CategoryOption[];
}>();

const emit = defineEmits<{
    (e: 'close'): void;
    (e: 'select', key: string): void;
}>();

const toneClass = (tone?: CategoryOption['tone']) => {
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
                <span
                    class="flex h-14 w-14 items-center justify-center rounded-full text-lg font-semibold"
                    :class="opt.customColor ? '' : toneClass(opt.tone)"
                    :style="opt.customColor ? { backgroundColor: opt.customColor, color: 'white' } : {}"
                >
                    <CategoryIcon :icon="opt.icon" class="h-7 w-7" />
                </span>
                <span class="text-xs font-semibold text-slate-700">{{ opt.label }}</span>
            </button>
        </div>
    </PickerSheet>
</template>

