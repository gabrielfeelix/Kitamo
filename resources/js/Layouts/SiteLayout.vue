<script setup lang="ts">
import SiteFooter from '@/Components/site/SiteFooter.vue';
import SiteHeader from '@/Components/site/SiteHeader.vue';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();
</script>

<template>
    <div class="site-shell min-h-screen text-slate-950">
        <div class="site-ambient"></div>
        <SiteHeader :can-login="canLogin" :can-register="canRegister" />

        <main class="relative z-10 pt-24">
            <slot />
        </main>

        <SiteFooter :can-login="canLogin" :can-register="canRegister" />
    </div>
</template>

<style scoped>
.site-shell {
    background: linear-gradient(180deg, #f7f8f4 0%, #eff2ea 55%, #ebeee6 100%);
}

.site-ambient {
    position: fixed;
    inset: 0;
    pointer-events: none;
    z-index: 0;
    background:
        radial-gradient(46rem 46rem at 8% 12%, rgba(16, 185, 129, 0.15), transparent 62%),
        radial-gradient(38rem 38rem at 92% 15%, rgba(15, 23, 42, 0.1), transparent 64%),
        radial-gradient(36rem 36rem at 45% 88%, rgba(56, 189, 248, 0.08), transparent 70%);
}
</style>
