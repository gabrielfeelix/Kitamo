<script setup lang="ts">
import type { SiteFaqItem } from '@/types/site';

defineProps<{
    items: SiteFaqItem[];
}>();
</script>

<template>
    <div class="space-y-3">
        <details
            v-for="item in items"
            :key="item.question"
            class="rounded-2xl border border-slate-200 bg-white/80 p-4"
        >
            <summary class="cursor-pointer list-none text-base font-semibold text-slate-900">
                {{ item.question }}
            </summary>
            <p class="mt-3 text-sm leading-relaxed text-slate-600">
                {{ item.answer }}
            </p>
        </details>
    </div>
</template>
