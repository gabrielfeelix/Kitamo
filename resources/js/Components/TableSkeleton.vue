<script setup lang="ts">
const props = withDefaults(
    defineProps<{
        rows?: number;
        cols?: number;
    }>(),
    {
        rows: 6,
        cols: 6,
    },
);
</script>

<template>
    <div class="animate-pulse overflow-hidden rounded-2xl bg-white ring-1 ring-slate-200/60">
        <div v-for="r in rows" :key="r" class="grid gap-3 border-b border-slate-100 px-4 py-4" :style="{ gridTemplateColumns: `repeat(${cols}, minmax(0, 1fr))` }">
            <div v-for="c in cols" :key="`${r}-${c}`" class="h-4 rounded bg-slate-200"></div>
        </div>
    </div>
</template>

