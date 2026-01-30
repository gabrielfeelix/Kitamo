<script setup lang="ts">
import { computed } from 'vue';

type Variant = 'active' | 'inactive' | 'pending' | 'error';

const props = withDefaults(
    defineProps<{
        variant: Variant;
        label?: string;
    }>(),
    {
        label: undefined,
    },
);

const resolved = computed(() => {
    if (props.variant === 'active') {
        return { label: props.label ?? 'Ativo', dot: 'bg-emerald-500', cls: 'bg-emerald-100 text-emerald-700' };
    }
    if (props.variant === 'pending') {
        return { label: props.label ?? 'Pendente', dot: 'bg-amber-500', cls: 'bg-amber-100 text-amber-700' };
    }
    if (props.variant === 'error') {
        return { label: props.label ?? 'Erro', dot: 'bg-red-500', cls: 'bg-red-100 text-red-700' };
    }
    return { label: props.label ?? 'Inativo', dot: 'bg-slate-400', cls: 'bg-slate-100 text-slate-700' };
});
</script>

<template>
    <span class="inline-flex items-center gap-2 rounded-full px-3 py-1 text-xs font-medium" :class="resolved.cls">
        <span class="h-2 w-2 rounded-full" :class="resolved.dot" aria-hidden="true"></span>
        <span>{{ resolved.label }}</span>
    </span>
</template>

