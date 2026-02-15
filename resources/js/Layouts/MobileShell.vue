<script setup lang="ts">
import { computed, getCurrentInstance, onMounted, onUnmounted, ref } from 'vue';
import { Link, router, usePage } from '@inertiajs/vue3';
import ConfigModal from '@/Components/ConfigModal.vue';
import WhatsNewModal from '@/Components/WhatsNewModal.vue';
import ToastStack from '@/Components/ToastStack.vue';
import BackToTopButton from '@/Components/BackToTopButton.vue';

const emit = defineEmits<{
    (e: 'add'): void;
    (e: 'config'): void;
}>();

const configModalOpen = ref(false);
const newsOpen = ref(false);

const props = withDefaults(
    defineProps<{
        showNav?: boolean;
    }>(),
    {
        showNav: true,
    },
);

const page = usePage();

const navVisible = ref(true);
let lastScrollY = 0;
let ticking = false;

const updateNavVisibility = () => {
    const current = window.scrollY || 0;
    const delta = current - lastScrollY;
    lastScrollY = current;

    if (current <= 0) {
        navVisible.value = true;
        return;
    }

    // evita flicker com pequenos deltas
    if (Math.abs(delta) < 8) return;

    if (delta > 0) navVisible.value = false; // scroll para baixo
    else navVisible.value = true; // scroll para cima
};

const onScroll = () => {
    if (ticking) return;
    ticking = true;
    requestAnimationFrame(() => {
        updateNavVisibility();
        ticking = false;
    });
};

onMounted(() => {
    lastScrollY = window.scrollY || 0;
    window.addEventListener('scroll', onScroll, { passive: true });
});

onUnmounted(() => {
    window.removeEventListener('scroll', onScroll);
});

const navItems = computed(() => [
    {
        label: 'Início',
        href: route('dashboard'),
        active: route().current('dashboard'),
        icon: 'home' as const,
    },
    {
        label: 'Transações',
        href: route('accounts.index'),
        active: route().current('accounts.*') && !route().current('accounts.overview'),
        icon: 'cards' as const,
    },
    {
        label: 'Relatórios',
        href: route('analysis'),
        active: route().current('analysis*'),
        icon: 'pie' as const,
    },
    {
        label: 'Config',
        href: route('settings'),
        active: route().current('settings*') || route().current('profile.*'),
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

const hasParentAddListener = () => {
    const vnodeProps = (getCurrentInstance()?.vnode.props ?? {}) as Record<string, unknown>;
    return Boolean((vnodeProps as any).onAdd || (vnodeProps as any).onAddOnce);
};

const handleAddClick = () => {
    if (hasParentAddListener()) {
        emit('add');
        return;
    }
    router.visit(`${route('accounts.index')}?create=1`);
};
</script>

<template>
    <div class="min-h-screen" :class="bgClass">
        <main
            class="mx-auto w-full max-w-md px-5 pt-[calc(1rem+env(safe-area-inset-top))] md:max-w-2xl md:px-8"
            :class="mainPaddingClass"
        >
            <slot />
        </main>

        <div
            v-if="showNav"
            class="fixed inset-x-0 bottom-0 z-40 border-t border-slate-200/70 bg-white transition-transform duration-200"
            :class="navVisible ? 'translate-y-0' : 'translate-y-[110%]'"
        >
            <nav
                class="mx-auto flex w-full max-w-md items-center justify-between px-6 pb-[env(safe-area-inset-bottom)] pt-2 md:max-w-2xl md:px-10"
                aria-label="Navegação principal"
            >
                <Link
                    :href="navItems[0].href"
                    class="flex flex-1 flex-col items-center justify-center gap-1 py-2 transition"
                    :class="navItems[0].active ? 'text-emerald-600' : 'text-slate-400'"
                    :aria-label="navItems[0].label"
                >
                    <span class="flex h-11 w-11 items-center justify-center">
                        <svg class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M3 10.5L12 3l9 7.5" />
                            <path d="M5 10v10h14V10" />
                        </svg>
                    </span>
                    <span class="text-[10px] font-semibold leading-none">{{ navItems[0].label }}</span>
                </Link>

                <Link
                    :href="navItems[1].href"
                    class="flex flex-1 flex-col items-center justify-center gap-1 py-2 transition"
                    :class="navItems[1].active ? 'text-emerald-600' : 'text-slate-400'"
                    :aria-label="navItems[1].label"
                >
                    <span class="flex h-11 w-11 items-center justify-center">
                        <svg class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <rect x="3" y="5" width="18" height="14" rx="3" />
                            <path d="M3 10h18" />
                        </svg>
                    </span>
                    <span class="text-[10px] font-semibold leading-none">{{ navItems[1].label }}</span>
                </Link>

                <button
                    type="button"
                    class="mx-2 -mt-7 flex h-14 w-14 items-center justify-center rounded-full bg-emerald-500 text-white shadow-xl shadow-emerald-500/30 ring-8 ring-white"
                    aria-label="Nova movimentação"
                    @click="handleAddClick"
                >
                    <svg class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M12 5v14" />
                        <path d="M5 12h14" />
                    </svg>
                </button>

                <Link
                    :href="navItems[2].href"
                    class="flex flex-1 flex-col items-center justify-center gap-1 py-2 transition"
                    :class="navItems[2].active ? 'text-emerald-600' : 'text-slate-400'"
                    :aria-label="navItems[2].label"
                >
                    <span class="flex h-11 w-11 items-center justify-center">
                        <svg class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M12 3v9h9" />
                            <path d="M21 12a9 9 0 1 1-9-9" />
                        </svg>
                    </span>
                    <span class="text-[10px] font-semibold leading-none">{{ navItems[2].label }}</span>
                </Link>

                <button
                    type="button"
                    class="flex flex-1 flex-col items-center justify-center gap-1 py-2 transition text-slate-400"
                    aria-label="Gerenciamento"
                    @click="configModalOpen = true"
                >
                    <span class="flex h-11 w-11 items-center justify-center">
                        <svg class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M4 6h16" />
                            <path d="M4 12h16" />
                            <path d="M4 18h16" />
                        </svg>
                    </span>
                    <span class="text-[10px] font-semibold leading-none">Mais</span>
                </button>
            </nav>
        </div>

        <slot name="fab" />

        <ConfigModal
            :open="configModalOpen"
            @close="configModalOpen = false"
            @news="() => { configModalOpen = false; newsOpen = true; }"
        />
        <WhatsNewModal :open="newsOpen" @close="newsOpen = false" />

        <ToastStack />
        <BackToTopButton />
    </div>
</template>
