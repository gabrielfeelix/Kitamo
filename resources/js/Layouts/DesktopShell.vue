<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref } from 'vue';
import { Link, usePage } from '@inertiajs/vue3';
import DesktopNotificationsPopover from '@/Components/DesktopNotificationsPopover.vue';
import ConfigModal from '@/Components/ConfigModal.vue';
import { requestJson } from '@/lib/kitamoApi';

const emit = defineEmits<{
    (e: 'add'): void;
}>();

const props = withDefaults(
    defineProps<{
        title?: string;
        subtitle?: string;
        showSearch?: boolean;
        searchPlaceholder?: string;
        showNewAction?: boolean;
        newActionLabel?: string;
    }>(),
    {
        title: '',
        subtitle: '',
        showSearch: true,
        searchPlaceholder: 'Buscar…',
        showNewAction: true,
        newActionLabel: 'Nova Transação',
    },
);

const page = usePage();
const userName = computed(() => String((page.props as any)?.auth?.user?.name ?? ''));
const firstName = computed(() => userName.value.trim().split(/\s+/)[0] ?? userName.value);
const avatarUrl = computed(() => (page.props as any)?.auth?.user?.avatar_url ?? (page.props as any)?.auth?.user?.profile_photo_url ?? null);

const initials = computed(() => {
    const parts = userName.value.trim().split(/\s+/).filter(Boolean);
    const first = parts[0]?.[0] ?? 'K';
    const last = parts.length > 1 ? parts[parts.length - 1]?.[0] : '';
    return `${first}${last}`.toUpperCase();
});

const navItems = computed(() => [
    {
        label: 'Dashboard',
        href: route('dashboard'),
        active: route().current('dashboard'),
        icon: 'dashboard' as const,
    },
    {
        label: 'Minhas Contas',
        href: route('accounts.overview'),
        active: route().current('accounts.overview'),
        icon: 'accounts' as const,
    },
	    {
	        label: 'Transações',
	        href: route('accounts.index'),
	        active: route().current('accounts.*') && !route().current('accounts.overview'),
	        icon: 'cards' as const,
	    },
    {
        label: 'Cartões de crédito',
        href: route('credit-cards.my-cards'),
        active: route().current('credit-cards.*'),
        icon: 'credit' as const,
    },
    {
        label: 'Metas',
        href: route('goals.index'),
        active: route().current('goals.*'),
        icon: 'target' as const,
    },
    {
        label: 'Relatórios',
        href: route('analysis'),
        active: route().current('analysis*'),
        icon: 'chart' as const,
    },
]);

const notificationsOpen = ref(false);
const unreadCount = ref(0);
const setUnreadCount = (count: number) => {
    unreadCount.value = count;
};
const configModalOpen = ref(false);

const loadUnreadCount = async () => {
    try {
        const response = await requestJson<{ count: number }>(route('api.notifications.count-unread'));
        unreadCount.value = Number(response.count ?? 0);
    } catch {
        // ignore
    }
};

let unreadInterval: number | null = null;
onMounted(() => {
    loadUnreadCount();
    unreadInterval = window.setInterval(loadUnreadCount, 60_000);
});
onUnmounted(() => {
    if (unreadInterval) window.clearInterval(unreadInterval);
});
</script>

<template>
    <div class="min-h-screen bg-slate-50">
        <div class="flex min-h-screen">
            <aside class="hidden w-[280px] flex-col border-r border-slate-200/70 bg-white md:flex">
                <div class="px-7 pt-7">
                    <div class="flex items-center gap-3">
                        <div class="flex h-12 w-12 items-center justify-center rounded-2xl bg-[#14B8A6] text-xl font-bold text-white">
                            K
                        </div>
                        <div class="text-xl font-semibold tracking-tight text-slate-900">Kitamo</div>
                    </div>
                </div>

                <nav class="mt-8 flex-1 space-y-2 px-5" aria-label="Menu principal">
                    <Link
                        v-for="item in navItems"
                        :key="item.label"
                        :href="item.href"
                        class="group flex items-center gap-4 rounded-2xl px-4 py-3.5 ring-1 ring-transparent transition"
                        :class="
                            item.active
                                ? 'bg-emerald-50 text-slate-900 ring-emerald-100'
                                : 'text-slate-500 hover:bg-slate-50 hover:text-slate-700'
                        "
                    >
                        <span
                            class="flex h-11 w-11 items-center justify-center rounded-2xl"
                            :class="item.active ? 'bg-white text-emerald-600 ring-1 ring-emerald-100' : 'bg-slate-100 text-slate-400'"
                        >
                            <svg v-if="item.icon === 'dashboard'" class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="3" width="7" height="7" rx="2" />
                                <rect x="14" y="3" width="7" height="7" rx="2" />
                                <rect x="3" y="14" width="7" height="7" rx="2" />
                                <rect x="14" y="14" width="7" height="7" rx="2" />
                            </svg>
                            <svg v-else-if="item.icon === 'cards'" class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="5" width="18" height="14" rx="3" />
                                <path d="M3 10h18" />
                            </svg>
                            <svg v-else-if="item.icon === 'target'" class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <circle cx="12" cy="12" r="8" />
                                <circle cx="12" cy="12" r="3" />
                                <path d="M12 2v3" />
                                <path d="M22 12h-3" />
                                <path d="M12 22v-3" />
                                <path d="M2 12h3" />
                            </svg>
                            <svg v-else-if="item.icon === 'accounts'" class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M21 12V7H5a2 2 0 0 1 0-4h14v4" />
                                <path d="M3 5v14a2 2 0 0 0 2 2h16v-5" />
                                <path d="M18 12a2 2 0 0 0 0 4h4v-4Z" />
                            </svg>
                            <svg v-else-if="item.icon === 'credit'" class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="2" y="5" width="20" height="14" rx="3" />
                                <path d="M2 10h20" />
                            </svg>
                            <svg v-else class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M4 19V5" />
                                <path d="M10 19V9" />
                                <path d="M16 19v-4" />
                                <path d="M22 19V7" />
                            </svg>
                        </span>
                        <span class="text-sm font-semibold">{{ item.label }}</span>

                        <span v-if="item.active" class="ml-auto h-9 w-1.5 rounded-full bg-[#14B8A6]"></span>
                    </Link>

                    <button
                        type="button"
                        class="group flex w-full items-center gap-4 rounded-2xl px-4 py-3.5 text-slate-500 transition hover:bg-slate-50 hover:text-slate-700"
                        aria-label="Menu"
                        @click="configModalOpen = true"
                    >
                        <span class="flex h-11 w-11 items-center justify-center rounded-2xl bg-slate-100 text-slate-400">
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M4 6h16" />
                                <path d="M4 12h16" />
                                <path d="M4 18h16" />
                            </svg>
                        </span>
                        <span class="text-sm font-semibold">Menu</span>
                    </button>
                </nav>

                <div class="px-5 pb-6">
                    <div class="flex items-center justify-between rounded-2xl bg-white px-4 py-4 ring-1 ring-slate-200/60">
                        <div class="flex items-center gap-3">
                            <div class="flex h-11 w-11 items-center justify-center overflow-hidden rounded-full bg-slate-200 text-sm font-bold text-slate-700">
                                <img v-if="avatarUrl" :src="avatarUrl" alt="" class="h-full w-full object-cover" />
                                <span v-else>{{ initials }}</span>
                            </div>
                            <div class="leading-tight">
                                <div class="text-sm font-semibold text-slate-900">{{ firstName || 'Usuário' }}</div>
                                <div class="text-xs font-medium text-slate-400">Plano UI/UX</div>
                            </div>
                        </div>
                        <Link
                            :href="route('settings')"
                            class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-50 text-slate-600 ring-1 ring-slate-200/60"
                            aria-label="Configurações"
                        >
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path
                                    d="M12 15.5A3.5 3.5 0 1 0 12 8.5a3.5 3.5 0 0 0 0 7Z"
                                />
                                <path
                                    d="M19.4 15a7.9 7.9 0 0 0 .1-1 7.9 7.9 0 0 0-.1-1l2-1.6-2-3.4-2.4 1a7.4 7.4 0 0 0-1.7-1l-.4-2.6H9.1L8.7 8a7.4 7.4 0 0 0-1.7 1l-2.4-1-2 3.4 2 1.6a7.9 7.9 0 0 0-.1 1 7.9 7.9 0 0 0 .1 1l-2 1.6 2 3.4 2.4-1a7.4 7.4 0 0 0 1.7 1l.4 2.6h5.8l.4-2.6a7.4 7.4 0 0 0 1.7-1l2.4 1 2-3.4-2-1.6Z"
                                />
                            </svg>
                        </Link>
                    </div>
                </div>
            </aside>

            <div class="flex min-w-0 flex-1 flex-col">
                <header class="sticky top-0 z-30 border-b border-slate-200/70 bg-white/80 backdrop-blur">
                    <div class="flex items-center justify-between gap-4 px-6 py-4 md:px-10">
                        <div>
                            <div v-if="props.title" class="text-lg font-semibold text-slate-900">{{ props.title }}</div>
                            <div v-if="props.subtitle" class="text-sm font-medium text-slate-400">{{ props.subtitle }}</div>
                        </div>

                        <div class="flex items-center gap-3">
                            <div v-if="props.showSearch" class="hidden items-center gap-2 rounded-2xl bg-slate-50 px-4 py-2 ring-1 ring-slate-200/60 md:flex">
                                <svg class="h-5 w-5 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <circle cx="11" cy="11" r="7" />
                                    <path d="M21 21l-4.3-4.3" />
                                </svg>
                                <input
                                    type="text"
                                    :placeholder="props.searchPlaceholder"
                                    class="w-[260px] bg-transparent text-sm font-semibold text-slate-700 placeholder:text-slate-400 focus:outline-none"
                                />
                            </div>

                            <slot name="headerActions" />

                            <button
                                type="button"
                                class="relative flex h-11 w-11 items-center justify-center rounded-2xl bg-white text-slate-600 ring-1 ring-slate-200/60"
                                aria-label="Notificações"
                                :aria-expanded="notificationsOpen ? 'true' : 'false'"
                                @click="notificationsOpen = !notificationsOpen"
                            >
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M6 8a6 6 0 0 1 12 0c0 7 3 7 3 7H3s3 0 3-7" />
                                    <path d="M10 21a2 2 0 0 0 4 0" />
                                </svg>
                                <span v-if="unreadCount > 0" class="absolute right-2.5 top-2.5 h-2 w-2 rounded-full bg-red-500"></span>
                            </button>

                            <Link
                                :href="route('settings')"
                                class="flex h-11 w-11 items-center justify-center overflow-hidden rounded-2xl bg-slate-200 text-sm font-bold text-slate-700 ring-1 ring-slate-200/60"
                                aria-label="Perfil"
                            >
                                <img v-if="avatarUrl" :src="avatarUrl" alt="" class="h-full w-full object-cover" />
                                <span v-else>{{ initials }}</span>
                            </Link>

                            <button
                                v-if="props.showNewAction"
                                type="button"
                                class="h-11 w-11 items-center justify-center rounded-full bg-[#14B8A6] text-white shadow-xl shadow-emerald-500/30 ring-1 ring-emerald-400/20 md:inline-flex"
                                aria-label="Nova transação"
                                @click="emit('add')"
                            >
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M12 5v14" />
                                    <path d="M5 12h14" />
                                </svg>
                            </button>
                        </div>
                    </div>
                </header>

                <main class="flex-1 px-6 py-8 md:px-10">
                    <div class="mx-auto w-full max-w-[1100px]">
                        <slot />
                    </div>
                </main>
            </div>
        </div>
    </div>

    <DesktopNotificationsPopover
        :open="notificationsOpen"
        @close="() => { notificationsOpen = false; loadUnreadCount(); }"
        @unread="setUnreadCount"
    />

    <ConfigModal :open="configModalOpen" @close="configModalOpen = false" />
</template>
