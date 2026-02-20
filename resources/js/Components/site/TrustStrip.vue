<script setup lang="ts">
defineProps<{
    items: string[];
}>();
</script>

<template>
    <div class="rounded-2xl border border-slate-200/90 bg-white/70 p-3">
        <div class="flex flex-wrap gap-2">
            <span
                v-for="item in items"
                :key="item"
                class="inline-flex h-9 items-center justify-center rounded-full border border-slate-200 bg-white px-4 text-[11px] font-bold uppercase tracking-[0.1em] text-slate-600"
            >
                {{ item }}
            </span>
        </div>
    </div>
</template>
