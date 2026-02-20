<script setup lang="ts">
import { Link } from '@inertiajs/vue3';
import type { SitePricingPlan } from '@/types/site';

defineProps<{
    plans: SitePricingPlan[];
    canRegister?: boolean;
}>();
</script>

<template>
    <div class="grid gap-4 md:grid-cols-3">
        <article
            v-for="plan in plans"
            :key="plan.name"
            class="rounded-3xl border p-6"
            :class="
                plan.highlighted
                    ? 'border-emerald-300 bg-emerald-50/70 shadow-[0_24px_40px_-34px_rgba(16,185,129,0.75)]'
                    : 'border-slate-200 bg-white/80'
            "
        >
            <p class="text-xs font-bold uppercase tracking-[0.18em] text-slate-500">{{ plan.name }}</p>
            <h3 class="mt-3 text-4xl tracking-[-0.03em] text-slate-950">{{ plan.monthly }}</h3>
            <p class="mt-2 text-sm leading-relaxed text-slate-600">{{ plan.subtitle }}</p>

            <ul class="mt-6 space-y-2">
                <li v-for="feature in plan.features" :key="feature" class="flex items-center gap-2 text-sm font-semibold text-slate-700">
                    <span class="h-2 w-2 rounded-full bg-emerald-500"></span>
                    {{ feature }}
                </li>
            </ul>

            <Link
                :href="canRegister ? '/register' : '/login'"
                class="mt-7 inline-flex h-11 w-full items-center justify-center rounded-full text-[11px] font-bold uppercase tracking-[0.14em] transition"
                :class="plan.highlighted ? 'bg-slate-900 text-white hover:bg-emerald-500 hover:text-slate-950' : 'border border-slate-300 bg-white text-slate-800 hover:bg-slate-900 hover:text-white'"
            >
                {{ plan.ctaLabel }}
            </Link>
        </article>
    </div>
</template>
