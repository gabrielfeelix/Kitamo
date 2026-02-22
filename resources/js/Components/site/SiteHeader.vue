<script setup lang="ts">
import { computed, ref } from 'vue';
import { Link } from '@inertiajs/vue3';
import { headerNavigation } from '@/types/site';

const props = defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const mobileOpen = ref(false);

const primaryHref = computed(() => (props.canRegister ? '/register' : '/login'));
const primaryLabel = computed(() => (props.canRegister ? 'Criar Conta' : 'Acessar APP'));
</script>

<template>
    <header class="fixed inset-x-0 top-0 z-50 py-4 px-4 pointer-events-none transition-all duration-300">
        <div class="mx-auto flex h-16 w-full max-w-[1200px] items-center justify-between px-6 bg-slate-900/40 backdrop-blur-md border border-white/10 rounded-2xl shadow-lg pointer-events-auto transition-all duration-300 hover:bg-slate-900/60">
            <Link :href="route('site.home')" class="text-2xl font-extrabold tracking-[-0.04em] text-white flex items-center gap-1 group">
                kitamo<span class="text-teal-400 group-hover:animate-pulse">.</span>
            </Link>

            <nav class="hidden items-center gap-2 lg:flex p-1 bg-white/5 rounded-full border border-white/5">
                <Link
                    v-for="item in headerNavigation"
                    :key="item.routeName"
                    :href="route(item.routeName)"
                    class="site-nav-link"
                    :class="{ 'is-active bg-white/10 text-white': route().current(item.routeName), 'text-slate-300': !route().current(item.routeName) }"
                >
                    {{ item.label }}
                </Link>
            </nav>

            <div class="hidden items-center gap-3 sm:flex">
                <Link
                    v-if="canLogin"
                    href="/login"
                    class="inline-flex h-10 items-center justify-center rounded-xl px-4 text-[12px] font-bold uppercase tracking-[0.12em] text-slate-300 transition hover:text-white hover:bg-white/10"
                >
                    Entrar
                </Link>
                <Link
                    :href="primaryHref"
                    class="inline-flex h-10 items-center justify-center rounded-xl bg-teal-500 px-6 text-[12px] font-extrabold uppercase tracking-[0.15em] text-slate-950 transition-all hover:bg-teal-400 hover:scale-105 shadow-[0_0_20px_-5px_theme(colors.teal.500)]"
                >
                    {{ primaryLabel }}
                </Link>
            </div>

            <button
                type="button"
                class="inline-flex h-10 w-10 items-center justify-center rounded-xl border border-white/20 bg-white/5 text-white lg:hidden transition-all hover:bg-white/10"
                aria-label="Abrir navegação"
                @click="mobileOpen = !mobileOpen"
            >
                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path v-if="!mobileOpen" d="M4 6h16M4 12h16M4 18h16" />
                    <path v-else d="M6 6l12 12M18 6L6 18" />
                </svg>
            </button>
        </div>

        <!-- Mobile Menu Overlay -->
        <Teleport to="body">
            <transition name="fade">
                <div v-if="mobileOpen" class="fixed inset-0 z-[60] bg-slate-950/95 backdrop-blur-xl p-6 flex flex-col pt-24">
                    <button class="absolute top-6 right-6 w-12 h-12 flex items-center justify-center rounded-xl bg-white/10 text-white border border-white/10" @click="mobileOpen = false">
                        <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M6 6l12 12M18 6L6 18" />
                        </svg>
                    </button>
                    <div class="grid gap-4 flex-grow">
                        <Link
                            v-for="item in headerNavigation"
                            :key="`mobile-${item.routeName}`"
                            :href="route(item.routeName)"
                            class="text-4xl font-extrabold tracking-tighter text-slate-300 p-2 transition-colors hover:text-white"
                            :class="{ 'text-teal-400': route().current(item.routeName) }"
                            @click="mobileOpen = false"
                        >
                            {{ item.label }}
                        </Link>
                    </div>

                    <div class="mt-8 grid gap-4 pb-8 border-t border-white/10 pt-8">
                        <Link
                            v-if="canLogin"
                            href="/login"
                            class="inline-flex h-16 items-center justify-center rounded-xl border border-white/20 bg-white/5 text-[14px] font-bold uppercase tracking-[0.16em] text-white w-full transition-all active:scale-95"
                            @click="mobileOpen = false"
                        >
                            Entrar na minha conta
                        </Link>
                        <Link
                            :href="primaryHref"
                            class="inline-flex h-16 items-center justify-center rounded-xl bg-teal-500 text-[14px] font-extrabold uppercase tracking-[0.15em] text-slate-950 w-full transition-all active:scale-95 shadow-[0_0_30px_-5px_theme(colors.teal.500)]"
                            @click="mobileOpen = false"
                        >
                            {{ primaryLabel }}
                        </Link>
                    </div>
                </div>
            </transition>
        </Teleport>
    </header>
</template>

<style scoped>
.site-nav-link {
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: 0.1em;
    font-weight: 700;
    transition: all 200ms ease;
    padding: 8px 16px;
    border-radius: 99px;
}

.site-nav-link:hover {
    background: rgba(255, 255, 255, 0.1);
    color: white;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
