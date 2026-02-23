<script setup lang="ts">
import SiteFooter from '@/Components/site/SiteFooter.vue';
import SiteHeader from '@/Components/site/SiteHeader.vue';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();
</script>

<template>
    <div class="min-h-screen text-slate-950 bg-slate-950">
        <SiteHeader :can-login="canLogin" :can-register="canRegister" />

        <main class="relative z-10">
            <slot />
        </main>

        <SiteFooter :can-login="canLogin" :can-register="canRegister" />
    </div>
</template>

<style scoped>
</style>
