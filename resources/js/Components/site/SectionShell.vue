<script setup lang="ts">
defineProps<{
    kicker?: string;
    title: string;
    description?: string;
    compact?: boolean;
}>();
</script>

<template>
    <div :class="compact ? 'mb-8' : 'mb-10 md:mb-12'">
        <p v-if="kicker" class="text-[11px] font-bold uppercase tracking-[0.2em] text-slate-500">
            {{ kicker }}
        </p>
        <h2 class="mt-3 text-4xl leading-[1.03] tracking-[-0.03em] text-slate-950 md:text-5xl">
            {{ title }}
        </h2>
        <p v-if="description" class="mt-4 max-w-2xl text-base leading-relaxed text-slate-600 md:text-lg">
            {{ description }}
        </p>
    </div>
</template>
