<script setup lang="ts">
import { computed } from 'vue';
import { Link, usePage } from '@inertiajs/vue3';

const props = withDefaults(
    defineProps<{
        showNav?: boolean;
    }>(),
    {
        showNav: true,
    },
);

const page = usePage();

const navItems = computed(() => [
    {
        label: 'Visão',
        href: route('dashboard'),
        active: route().current('dashboard'),
        icon: 'home' as const,
    },
    {
        label: 'Lançamentos',
        href: route('accounts.index'),
        active: route().current('accounts.*'),
        icon: 'cards' as const,
    },
    {
        label: 'Metas',
        href: route('goals.index'),
        active: route().current('goals.*'),
        icon: 'target' as const,
    },
    {
        label: 'Análise',
        href: route('analysis'),
        active: route().current('analysis'),
        icon: 'pie' as const,
    },
    {
        label: 'Config',
        href: route('settings'),
        active: route().current('settings'),
        icon: 'gear' as const,
    },
]);

const bgClass = computed(() =>
    page.component === 'Dashboard'
        ? 'bg-gradient-to-b from-white via-slate-50 to-slate-100'
        : 'bg-slate-50',
);

const mainPaddingClass = computed(() =>
    props.showNav ? 'pb-[calc(5.5rem+env(safe-area-inset-bottom))]' : 'pb-[env(safe-area-inset-bottom)]',
);
</script>

<template>
    <div class="min-h-screen" :class="bgClass">
        <main class="mx-auto w-full max-w-md px-5 pt-[calc(1rem+env(safe-area-inset-top))]" :class="mainPaddingClass">
            <slot />
        </main>

        <div v-if="showNav" class="fixed inset-x-0 bottom-0 z-40 border-t border-slate-200/70 bg-white">
            <nav class="mx-auto flex w-full max-w-md items-center justify-between px-6 pb-[env(safe-area-inset-bottom)] pt-2" aria-label="Navegação principal">
                <Link
                    v-for="item in navItems"
                    :key="item.label"
                    :href="item.href"
                    class="flex flex-1 flex-col items-center justify-center gap-1 py-2 transition"
                    :class="item.active ? 'text-emerald-600' : 'text-slate-400'"
                    :aria-label="item.label"
                >
                    <span
                        class="flex items-center justify-center"
                        :class="item.icon === 'target' ? 'h-11 w-11 rounded-full bg-white shadow-sm' : 'h-11 w-11'"
                    >
                        <svg
                            v-if="item.icon === 'home'"
                            class="h-7 w-7"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="2"
                        >
                            <path d="M3 10.5L12 3l9 7.5" />
                            <path d="M5 10v10h14V10" />
                        </svg>
                        <svg
                            v-else-if="item.icon === 'cards'"
                            class="h-7 w-7"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="2"
                        >
                            <rect x="3" y="5" width="18" height="14" rx="3" />
                            <path d="M3 10h18" />
                        </svg>
                        <svg
                            v-else-if="item.icon === 'pie'"
                            class="h-7 w-7"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="2"
                        >
                            <path d="M12 3v9h9" />
                            <path d="M21 12a9 9 0 1 1-9-9" />
                        </svg>
                        <svg
                            v-else-if="item.icon === 'target'"
                            class="h-7 w-7"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="2"
                        >
                            <circle cx="12" cy="12" r="8" />
                            <circle cx="12" cy="12" r="4" />
                            <path d="M12 2v3" />
                            <path d="M22 12h-3" />
                            <path d="M12 22v-3" />
                            <path d="M2 12h3" />
                        </svg>
                        <svg
                            v-else
                            class="h-7 w-7"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="2"
                        >
                            <path
                                d="M19.4 15a1 1 0 0 1 .2 1.1l-1 1.8a1 1 0 0 1-1 .5l-1.7-.2a6 6 0 0 1-2 1.2l-.5 1.6a1 1 0 0 1-1 .7h-2a1 1 0 0 1-1-.7l-.5-1.6a6 6 0 0 1-2-1.2l-1.7.2a1 1 0 0 1-1-.5l-1-1.8a1 1 0 0 1 .2-1.1l1.3-1.2a6 6 0 0 1 0-2.4L3.3 10a1 1 0 0 1-.2-1.1l1-1.8a1 1 0 0 1 1-.5l1.7.2a6 6 0 0 1 2-1.2l.5-1.6a1 1 0 0 1 1-.7h2a1 1 0 0 1 1 .7l.5 1.6a6 6 0 0 1 2 1.2l1.7-.2a1 1 0 0 1 1 .5l1 1.8a1 1 0 0 1-.2 1.1l-1.3 1.2a6 6 0 0 1 0 2.4Z"
                            />
                            <path d="M12 15.5a3.5 3.5 0 1 0-3.5-3.5" />
                        </svg>
                    </span>
                    <span class="text-[10px] font-semibold leading-none">{{ item.label }}</span>
                </Link>
            </nav>
        </div>

        <slot name="fab" />
    </div>
</template>
