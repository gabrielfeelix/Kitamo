<script setup lang="ts">
import { computed } from 'vue';
import PickerSheet from '@/Components/PickerSheet.vue';
import CategoryIcon from '@/Components/CategoryIcon.vue';

type CategoryKind = 'expense' | 'income';

export type CategoryOption = {
    key: string;
    label: string;
    icon: string | 'food' | 'home' | 'car' | 'other';
    tone?: 'amber' | 'blue' | 'slate' | 'purple' | 'red' | 'green';
    customColor?: string;
    kind?: CategoryKind;
};

const props = defineProps<{
    open: boolean;
    options: CategoryOption[];
    kind?: CategoryKind;
}>();

const emit = defineEmits<{
    (e: 'close'): void;
    (e: 'select', key: string): void;
    (e: 'create'): void;
}>();

const toneClass = (tone?: CategoryOption['tone']) => {
    if (tone === 'amber') return 'bg-amber-100 text-amber-600';
    if (tone === 'blue') return 'bg-blue-100 text-blue-600';
    if (tone === 'purple') return 'bg-purple-100 text-purple-600';
    if (tone === 'red') return 'bg-red-100 text-red-600';
    if (tone === 'green') return 'bg-emerald-100 text-emerald-600';
    return 'bg-slate-200 text-slate-600';
};

const filteredOptions = computed(() => {
    if (!props.kind) return props.options ?? [];
    return (props.options ?? []).filter((opt) => !opt.kind || opt.kind === props.kind);
});
</script>

<template>
    <PickerSheet :open="open" title="Selecione a Categoria" @close="emit('close')">
        <div v-if="filteredOptions.length === 0" class="pb-4 pt-2 text-center">
            <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-slate-100 text-slate-400">
                <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M4 7h16v12H4z" />
                    <path d="M4 7V5h12v2" />
                    <path d="M8 12h8" />
                </svg>
            </div>
            <div class="mt-3 text-sm font-semibold text-slate-900">Nenhuma categoria encontrada</div>
            <div class="mt-1 text-xs font-semibold text-slate-500">Crie uma categoria para continuar.</div>
            <button
                type="button"
                class="mt-4 inline-flex items-center justify-center rounded-2xl bg-teal-500 px-4 py-3 text-sm font-semibold text-white shadow-lg shadow-teal-500/20"
                @click="emit('create')"
            >
                Criar categoria
            </button>
        </div>

        <div v-else class="grid grid-cols-3 gap-4 pb-2">
            <button
                v-for="opt in filteredOptions"
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
