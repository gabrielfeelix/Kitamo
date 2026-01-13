<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import { Link, router, usePage } from '@inertiajs/vue3';
import { getEntries, setEntries } from '@/stores/localStore';
import DesktopTransactionDrawer from '@/Components/DesktopTransactionDrawer.vue';

const props = withDefaults(
    defineProps<{
    title: string;
    subtitle?: string;
    searchPlaceholder?: string;
    newActionLabel?: string;
    showSearch?: boolean;
    showNewAction?: boolean;
}>(),
    {
        showSearch: true,
        showNewAction: true,
    },
);

const emit = defineEmits<{
    (event: 'new-transaction'): void;
    (event: 'search', value: string): void;
}>();

const page = usePage();
const userName = computed(() => page.props.auth?.user?.name ?? 'Gabriel Design');
const isAdmin = computed(() => Boolean(page.props.auth?.user?.is_admin));
const initials = computed(() => {
    const parts = String(userName.value).trim().split(/\s+/).filter(Boolean);
    const first = parts[0]?.[0] ?? 'G';
    const last = parts.length > 1 ? parts[parts.length - 1]?.[0] : 'D';
    return `${first}${last}`.toUpperCase();
});

const search = ref('');
const onSearchInput = (event: Event) => {
    const target = event.target as HTMLInputElement;
    search.value = target.value;
    notificationsOpen.value = false;
    emit('search', search.value);
};

const notificationsOpen = ref(false);
const profileOpen = ref(false);
const toggleNotifications = () => {
    notificationsOpen.value = !notificationsOpen.value;
    suggestionsOpen.value = false;
};

const toggleProfile = () => {
    profileOpen.value = !profileOpen.value;
    notificationsOpen.value = false;
    suggestionsOpen.value = false;
};

const closePopovers = () => {
    notificationsOpen.value = false;
    suggestionsOpen.value = false;
    profileOpen.value = false;
};

const drawerOpen = ref(false);
const drawerEntryId = ref<string | null>(null);
const entriesVersion = ref(0);
const drawerEntry = computed(() => {
    entriesVersion.value;
    if (!drawerEntryId.value) return null;
    return getEntries().find((e) => e.id === drawerEntryId.value) ?? null;
});

const openDrawerForEntry = (id: string) => {
    drawerEntryId.value = id;
    drawerOpen.value = true;
    closePopovers();
};

const editDrawerEntry = () => {
    const entry = drawerEntry.value;
    if (!entry) return;
    drawerOpen.value = false;
    router.get(route('accounts.index'), { edit: entry.id }, { preserveScroll: true });
};

const markDrawerAsPaid = () => {
    const entry = drawerEntry.value;
    if (!entry) return;
    const all = getEntries();
    const idx = all.findIndex((e) => e.id === entry.id);
    if (idx < 0) return;
    if (all[idx].kind !== 'expense') return;
    all[idx] = { ...all[idx], status: all[idx].status === 'paid' ? 'pending' : 'paid' };
    setEntries(all);
    entriesVersion.value += 1;
};

const deleteDrawerEntry = () => {
    const entry = drawerEntry.value;
    if (!entry) return;
    const all = getEntries().filter((e) => e.id !== entry.id);
    setEntries(all);
    entriesVersion.value += 1;
    drawerOpen.value = false;
    drawerEntryId.value = null;
};

const suggestionsOpen = ref(false);
type Suggestion = { id: string; title: string; dateLabel: string; amount: number; kind: 'expense' | 'income' };
const suggestions = ref<Suggestion[]>([]);

const formatMoney = (value: number) =>
    new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value);

const formatSuggestionAmount = (value: number) => {
    const isInteger = Number.isInteger(value);
    return new Intl.NumberFormat('pt-BR', {
        minimumFractionDigits: isInteger ? 0 : 2,
        maximumFractionDigits: isInteger ? 0 : 2,
    }).format(value);
};

watch(
    () => search.value,
    (value) => {
        const q = value.trim().toLowerCase();
        if (!q) {
            suggestions.value = [];
            suggestionsOpen.value = false;
            return;
        }
        const hits = getEntries()
            .filter((e) => e.title.toLowerCase().includes(q))
            .slice(0, 5)
            .map((e) => ({ id: e.id, title: e.title, dateLabel: '11 Jan 2026', amount: e.amount, kind: e.kind }));
        suggestions.value = hits;
        suggestionsOpen.value = hits.length > 0;
    },
);

const onSearchFocus = () => {
    suggestionsOpen.value = suggestions.value.length > 0;
};

type NavItem = { label: string; href: string; active: boolean; icon: 'dashboard' | 'transactions' | 'goals' | 'reports' };
const navItems = computed<NavItem[]>(() => [
    { label: 'Dashboard', href: route('dashboard'), active: route().current('dashboard'), icon: 'dashboard' },
    { label: 'Lançamentos', href: route('accounts.index'), active: route().current('accounts.*'), icon: 'transactions' },
    { label: 'Metas', href: route('goals.index'), active: route().current('goals.*'), icon: 'goals' },
    { label: 'Relatórios', href: route('analysis'), active: route().current('analysis*'), icon: 'reports' },
]);

const showSearch = computed(() => props.showSearch ?? true);
const newActionLabel = computed(() => props.newActionLabel ?? 'Nova Transação');
const showNewAction = computed(() => props.showNewAction ?? true);
</script>

<template>
    <div class="min-h-screen bg-[#F6F8FB]">
        <button
            v-if="notificationsOpen || suggestionsOpen || profileOpen"
            type="button"
            class="fixed inset-0 z-[80] cursor-default bg-transparent"
            @click="closePopovers"
            aria-label="Fechar"
        ></button>
        <div class="flex min-h-screen">
            <aside class="flex w-[260px] flex-col border-r border-slate-100 bg-white">
                <Link :href="route('dashboard')" class="flex items-center gap-3 px-6 py-6" aria-label="Ir para início">
                    <div class="flex h-11 w-11 items-center justify-center rounded-2xl bg-[#14B8A6] text-lg font-bold text-white">
                        K
                    </div>
                    <div class="text-lg font-semibold tracking-tight text-slate-900">
                        KITAMO
                    </div>
                </Link>

                <nav class="mt-2 space-y-1 px-4">
                    <Link
                        v-for="item in navItems"
                        :key="item.label"
                        :href="item.href"
                        class="group flex items-center gap-3 rounded-xl px-4 py-3 text-sm font-semibold transition"
                        :class="
                            item.active
                                ? 'border border-emerald-200 bg-emerald-50 text-slate-900 ring-0'
                                : 'border border-transparent text-slate-500 hover:bg-slate-50'
                        "
                    >
                        <span
                            class="flex h-9 w-9 items-center justify-center rounded-xl"
                            :class="item.active ? 'bg-white text-[#14B8A6] ring-1 ring-emerald-100' : 'bg-slate-100 text-slate-400 group-hover:bg-white'"
                        >
                            <svg v-if="item.icon === 'dashboard'" class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="3" width="7" height="7" rx="2" />
                                <rect x="14" y="3" width="7" height="7" rx="2" />
                                <rect x="14" y="14" width="7" height="7" rx="2" />
                                <rect x="3" y="14" width="7" height="7" rx="2" />
                            </svg>
                            <svg v-else-if="item.icon === 'transactions'" class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M7 7h14" />
                                <path d="M7 17h14" />
                                <path d="M3 7l3 3-3 3" />
                                <path d="M3 17l3-3-3-3" />
                            </svg>
                            <svg v-else-if="item.icon === 'goals'" class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <circle cx="12" cy="12" r="9" />
                                <circle cx="12" cy="12" r="5" />
                                <path d="M12 12l4-2" />
                            </svg>
                            <svg v-else class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M4 19V5" />
                                <path d="M4 19h16" />
                                <path d="M7 15v-4" />
                                <path d="M12 15V8" />
                                <path d="M17 15v-7" />
                            </svg>
                        </span>
                        <span class="flex-1">{{ item.label }}</span>
                        <span v-if="item.active" class="h-6 w-1.5 rounded-full bg-[#14B8A6]"></span>
                    </Link>
                </nav>

                <div class="mt-auto border-t border-slate-100 px-6 py-5">
                    <div class="relative">
                        <button
                            type="button"
                            class="flex w-full items-center gap-3 text-left"
                            @click="toggleProfile"
                            aria-label="Abrir menu do perfil"
                        >
                            <div class="flex h-10 w-10 items-center justify-center rounded-full bg-slate-200 text-sm font-bold text-slate-700">
                                {{ initials }}
                            </div>
                            <div class="min-w-0 flex-1">
                                <div class="truncate text-sm font-semibold text-slate-900">{{ userName }}</div>
                                <div class="text-xs text-slate-400">Pleno UI/UX</div>
                            </div>
                            <div class="flex h-9 w-9 items-center justify-center rounded-xl bg-slate-100 text-slate-400">
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path
                                        d="M19.4 15a1 1 0 0 1 .2 1.1l-1 1.8a1 1 0 0 1-1 .5l-1.7-.2a6 6 0 0 1-2 1.2l-.5 1.6a1 1 0 0 1-1 .7h-2a1 1 0 0 1-1-.7l-.5-1.6a6 6 0 0 1-2-1.2l-1.7.2a1 1 0 0 1-1-.5l-1-1.8a1 1 0 0 1 .2-1.1l1.3-1.2a6 6 0 0 1 0-2.4L3.3 10a1 1 0 0 1-.2-1.1l1-1.8a1 1 0 0 1 1-.5l1.7.2a6 6 0 0 1 2-1.2l.5-1.6a1 1 0 0 1 1-.7h2a1 1 0 0 1 1 .7l.5 1.6a6 6 0 0 1 2 1.2l1.7-.2a1 1 0 0 1 1 .5l1 1.8a1 1 0 0 1-.2 1.1l-1.3 1.2a6 6 0 0 1 0 2.4Z"
                                    />
                                    <path d="M12 15.5a3.5 3.5 0 1 0-3.5-3.5" />
                                </svg>
                            </div>
                        </button>

                        <div
                            v-if="profileOpen"
                            class="absolute bottom-14 left-0 z-40 w-full overflow-hidden rounded-2xl border border-slate-200/70 bg-white shadow-[0_20px_40px_-30px_rgba(15,23,42,0.5)]"
                        >
                            <Link
                                :href="route('settings')"
                                class="flex items-center gap-3 px-4 py-3 text-sm font-semibold text-slate-700 hover:bg-slate-50"
                            >
                                <svg class="h-4 w-4 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path
                                        d="M19.4 15a1 1 0 0 1 .2 1.1l-1 1.8a1 1 0 0 1-1 .5l-1.7-.2a6 6 0 0 1-2 1.2l-.5 1.6a1 1 0 0 1-1 .7h-2a1 1 0 0 1-1-.7l-.5-1.6a6 6 0 0 1-2-1.2l-1.7.2a1 1 0 0 1-1-.5l-1-1.8a1 1 0 0 1 .2-1.1l1.3-1.2a6 6 0 0 1 0-2.4L3.3 10a1 1 0 0 1-.2-1.1l1-1.8a1 1 0 0 1 1-.5l1.7.2a6 6 0 0 1 2-1.2l.5-1.6a1 1 0 0 1 1-.7h2a1 1 0 0 1 1 .7l.5 1.6a6 6 0 0 1 2 1.2l1.7-.2a1 1 0 0 1 1 .5l1 1.8a1 1 0 0 1-.2 1.1l-1.3 1.2a6 6 0 0 1 0 2.4Z"
                                    />
                                    <path d="M12 15.5a3.5 3.5 0 1 0-3.5-3.5" />
                                </svg>
                                Configuracoes
                            </Link>
                            <Link
                                :href="route('logout')"
                                method="post"
                                as="button"
                                class="flex w-full items-center gap-3 px-4 py-3 text-sm font-semibold text-rose-600 hover:bg-rose-50"
                            >
                                <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M9 6h-4v12h4" />
                                    <path d="M16 6l4 6-4 6" />
                                    <path d="M20 12H9" />
                                </svg>
                                Sair
                            </Link>
                        </div>
                    </div>
                </div>
            </aside>

            <div class="flex min-w-0 flex-1 flex-col">
                <header class="relative flex items-center justify-between gap-6 border-b border-slate-100 bg-white px-10 py-6">
                    <div class="min-w-0">
                        <div class="text-2xl font-semibold tracking-tight text-slate-900">{{ title }}</div>
                        <div class="text-sm text-slate-400">{{ subtitle }}</div>
                    </div>

                    <div class="flex items-center gap-3">
                        <div v-if="showSearch" class="relative w-[260px]">
                            <span class="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-slate-400">
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <circle cx="11" cy="11" r="7" />
                                    <path d="M20 20l-3.5-3.5" />
                                </svg>
                            </span>
                            <input
                                :value="search"
                                :placeholder="searchPlaceholder ?? 'Buscar transação...'"
                                class="h-11 w-full rounded-xl bg-slate-50 pl-10 pr-4 text-sm font-semibold text-slate-600 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-emerald-200"
                                type="text"
                                @input="onSearchInput"
                                @focus="onSearchFocus"
                            />

                            <div
                                v-if="suggestionsOpen"
                                class="absolute left-0 top-[calc(100%+10px)] z-[90] w-[320px] overflow-hidden rounded-2xl bg-white shadow-[0_24px_60px_-40px_rgba(15,23,42,0.45)] ring-1 ring-slate-200/60"
                            >
                                <div class="px-5 py-3 text-[10px] font-bold uppercase tracking-wide text-slate-400">Resultados sugeridos</div>
                                <div class="divide-y divide-slate-100">
                                    <button
                                        v-for="s in suggestions"
                                        :key="s.id"
                                        type="button"
                                        class="flex w-full items-center justify-between gap-4 px-5 py-4 text-left hover:bg-slate-50"
                                        @click="openDrawerForEntry(s.id)"
                                    >
                                        <div class="flex min-w-0 items-center gap-3">
                                            <span class="flex h-9 w-9 items-center justify-center rounded-full bg-amber-50 text-amber-600 ring-1 ring-slate-100">
                                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                    <path d="M6 6h15l-2 7H7L6 6Z" />
                                                    <path d="M6 6l-2-2H2" />
                                                    <circle cx="9" cy="18" r="1.5" />
                                                    <circle cx="17" cy="18" r="1.5" />
                                                </svg>
                                            </span>
                                            <div class="min-w-0">
                                                <div class="truncate text-sm font-semibold text-slate-900">{{ s.title }}</div>
                                                <div class="mt-0.5 text-xs font-semibold text-slate-400">{{ s.dateLabel }}</div>
                                            </div>
                                        </div>
                                        <div class="text-sm font-bold" :class="s.kind === 'income' ? 'text-emerald-600' : 'text-red-500'">
                                            {{ s.kind === 'income' ? '+' : '-' }}{{ formatSuggestionAmount(s.amount) }}
                                        </div>
                                    </button>
                                </div>
                            </div>
                        </div>

                        <slot name="actions" />

                        <Link
                            v-if="isAdmin"
                            :href="route('admin.users.index')"
                            class="inline-flex h-11 items-center gap-2 rounded-xl border border-emerald-100 bg-emerald-50 px-4 text-sm font-semibold text-emerald-700"
                            aria-label="Administração"
                        >
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10Z" />
                                <path d="M9 12l2 2 4-4" />
                            </svg>
                            Admin
                        </Link>

                        <div class="relative">
                            <button
                                type="button"
                                class="relative flex h-11 w-11 items-center justify-center rounded-xl bg-white text-slate-500 shadow-sm ring-1 ring-slate-200"
                                aria-label="Notificações"
                                @click="toggleNotifications"
                            >
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M15 17h5l-1.4-1.4a2 2 0 0 1-.6-1.4V11a6 6 0 1 0-12 0v3.2c0 .5-.2 1-.6 1.4L4 17h5" />
                                    <path d="M9 17a3 3 0 0 0 6 0" />
                                </svg>
                                <span class="absolute right-2 top-2 h-2 w-2 rounded-full bg-red-500"></span>
                            </button>

                            <div
                                v-if="notificationsOpen"
                                class="absolute right-0 top-[calc(100%+12px)] z-[90] w-[320px] overflow-hidden rounded-2xl bg-white shadow-[0_24px_60px_-40px_rgba(15,23,42,0.45)] ring-1 ring-slate-200/60"
                            >
                                <div class="px-5 py-4 text-sm font-semibold text-slate-900">Notificações</div>
                                <div class="border-t border-slate-100 px-5 py-4">
                                    <div class="flex items-start gap-3">
                                        <span class="mt-1 h-2 w-2 rounded-full bg-red-500"></span>
                                        <div class="min-w-0">
                                            <div class="text-sm font-semibold text-slate-900">Saldo Baixo</div>
                                            <div class="mt-1 text-xs font-semibold text-slate-400">Sua conta Inter está abaixo do R$ 100.</div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <button
                            v-if="showNewAction && newActionLabel"
                            type="button"
                            class="inline-flex h-11 items-center gap-2 rounded-xl bg-[#14B8A6] px-4 text-sm font-semibold text-white shadow-lg shadow-emerald-500/20"
                            @click="emit('new-transaction')"
                        >
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M12 5v14" />
                                <path d="M5 12h14" />
                            </svg>
                            {{ newActionLabel }}
                        </button>
                    </div>
                </header>

                <main class="min-w-0 flex-1 px-10 py-8">
                    <slot />
                </main>
            </div>
        </div>

        <DesktopTransactionDrawer
            :open="drawerOpen"
            :entry="drawerEntry"
            @close="drawerOpen = false"
            @delete="deleteDrawerEntry"
            @edit="editDrawerEntry"
            @mark-paid="markDrawerAsPaid"
        />
    </div>
</template>
