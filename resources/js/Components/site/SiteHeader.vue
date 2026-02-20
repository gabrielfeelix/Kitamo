<script setup lang="ts">
import { computed, ref } from 'vue';
import { Link } from '@inertiajs/vue3';
import { siteNavigation } from '@/types/site';

const props = defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const mobileOpen = ref(false);

const primaryHref = computed(() => (props.canRegister ? '/register' : '/login'));
const primaryLabel = computed(() => (props.canRegister ? 'Começar grátis' : 'Entrar para testar'));
</script>

<template>
    <header class="fixed inset-x-0 top-0 z-50 border-b border-white/50 bg-[#f7f8f4]/90 backdrop-blur-xl">
        <div class="mx-auto flex h-20 w-full max-w-[1240px] items-center justify-between px-5 md:px-6">
            <Link :href="route('site.home')" class="text-2xl font-bold tracking-[-0.04em] text-slate-950">
                kitamo
            </Link>

            <nav class="hidden items-center gap-5 lg:flex">
                <Link
                    v-for="item in siteNavigation"
                    :key="item.routeName"
                    :href="route(item.routeName)"
                    class="site-nav-link"
                    :class="{ 'is-active': route().current(item.routeName) }"
                >
                    {{ item.label }}
                </Link>
            </nav>

            <div class="hidden items-center gap-3 sm:flex">
                <Link
                    v-if="canLogin"
                    href="/login"
                    class="inline-flex h-10 items-center justify-center rounded-full border border-slate-300 px-4 text-[11px] font-bold uppercase tracking-[0.16em] text-slate-800 transition hover:bg-slate-900 hover:text-white"
                >
                    Entrar
                </Link>
                <Link
                    :href="primaryHref"
                    class="inline-flex h-10 items-center justify-center rounded-full bg-slate-900 px-5 text-[11px] font-bold uppercase tracking-[0.15em] text-white transition hover:bg-emerald-500 hover:text-slate-950"
                >
                    {{ primaryLabel }}
                </Link>
            </div>

            <button
                type="button"
                class="inline-flex h-10 w-10 items-center justify-center rounded-full border border-slate-300 text-slate-700 lg:hidden"
                aria-label="Abrir navegação"
                @click="mobileOpen = !mobileOpen"
            >
                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path v-if="!mobileOpen" d="M3 6h18M3 12h18M3 18h18" />
                    <path v-else d="M6 6l12 12M18 6L6 18" />
                </svg>
            </button>
        </div>

        <div v-if="mobileOpen" class="border-t border-slate-200 bg-[#f7f8f4] px-5 py-4 lg:hidden">
            <div class="grid gap-2">
                <Link
                    v-for="item in siteNavigation"
                    :key="`mobile-${item.routeName}`"
                    :href="route(item.routeName)"
                    class="rounded-xl px-3 py-2 text-sm font-semibold text-slate-700 transition hover:bg-slate-100"
                    :class="{ 'bg-emerald-50 text-emerald-700': route().current(item.routeName) }"
                    @click="mobileOpen = false"
                >
                    {{ item.label }}
                </Link>
            </div>

            <div class="mt-4 grid gap-2">
                <Link
                    v-if="canLogin"
                    href="/login"
                    class="inline-flex h-10 items-center justify-center rounded-full border border-slate-300 text-xs font-bold uppercase tracking-[0.16em] text-slate-700"
                    @click="mobileOpen = false"
                >
                    Entrar
                </Link>
                <Link
                    :href="primaryHref"
                    class="inline-flex h-10 items-center justify-center rounded-full bg-slate-900 text-xs font-bold uppercase tracking-[0.15em] text-white"
                    @click="mobileOpen = false"
                >
                    {{ primaryLabel }}
                </Link>
            </div>
        </div>
    </header>
</template>

<style scoped>
.site-nav-link {
    color: #475569;
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: 0.14em;
    font-weight: 700;
    transition: color 180ms ease;
}

.site-nav-link:hover,
.site-nav-link.is-active {
    color: #0f172a;
}
</style>
