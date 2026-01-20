<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, Link, usePage } from '@inertiajs/vue3';
import TransactionModal from '@/Components/TransactionModal.vue';

const props = defineProps<{
    title: string;
    subtitle?: string;
}>();

const page = usePage();
const userName = computed(() => page.props.auth?.user?.name ?? 'Gabriel');
const isAdmin = computed(() => Boolean(page.props.auth?.user?.is_admin));

const initials = computed(() => {
    const parts = String(userName.value).trim().split(/\s+/).filter(Boolean);
    const first = parts[0]?.[0] ?? 'G';
    const last = parts.length > 1 ? parts[parts.length - 1]?.[0] : 'F';
    return `${first}${last}`.toUpperCase();
});

const isNotificationsOpen = ref(false);
const isTransactionOpen = ref(false);
const transactionKind = ref<'expense' | 'income'>('expense');
const closeNotifications = () => {
    isNotificationsOpen.value = false;
};
const openNotifications = () => {
    isNotificationsOpen.value = true;
};
const openTransaction = (kind: 'expense' | 'income') => {
    transactionKind.value = kind;
    isTransactionOpen.value = true;
};
const closeTransaction = () => {
    isTransactionOpen.value = false;
};

const goBack = () => {
    if (typeof window === 'undefined') return;
    if (window.history.length > 1) window.history.back();
    else window.location.href = route('dashboard');
};

	const navItems = computed(() => [
	    {
	        label: 'Início',
	        href: route('dashboard'),
	        active: route().current('dashboard'),
	        icon: 'home' as const,
	    },
	    {
	        label: 'Relatórios',
	        href: route('analysis'),
	        active: route().current('analysis*'),
	        icon: 'chart' as const,
	    },
	    {
	        label: 'Transações',
	        href: route('accounts.index'),
	        active: route().current('accounts.*'),
	        icon: 'card' as const,
	    },
	    {
	        label: 'Metas',
	        href: route('goals.index'),
	        active: route().current('goals.*'),
	        icon: 'target' as const,
	    },
	]);
</script>

<template>
    <Head :title="props.title" />

    <div class="min-h-screen bg-gradient-to-br from-slate-50 via-[#F6F8FC] to-[#EEF2F8]">
        <div class="mx-auto max-w-[1400px] px-4 py-6 lg:px-8">
            <div class="grid gap-6 lg:grid-cols-[260px_1fr]">
                <aside
                    class="flex h-full flex-col justify-between rounded-[28px] border border-white/70 bg-white/80 p-6 shadow-[0_24px_60px_-40px_rgba(15,23,42,0.5)] backdrop-blur"
                >
                    <div class="space-y-10">
                        <div class="flex items-center gap-3">
                            <div
                                class="flex h-12 w-12 items-center justify-center rounded-2xl bg-gradient-to-br from-blue-600 to-blue-400 text-white shadow-lg shadow-blue-500/30"
                            >
                                <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <rect x="3" y="3" width="7" height="7" rx="2" />
                                    <rect x="14" y="3" width="7" height="7" rx="2" />
                                    <rect x="14" y="14" width="7" height="7" rx="2" />
                                    <rect x="3" y="14" width="7" height="7" rx="2" />
                                </svg>
                            </div>
                            <div class="text-xl font-semibold tracking-tight text-slate-900">KITAMO.</div>
                        </div>

                        <nav class="space-y-2 text-sm">
                            <Link
                                v-for="item in navItems"
                                :key="item.label"
                                :href="item.href"
                                class="flex items-center gap-3 rounded-2xl px-4 py-3 transition"
                                :class="
                                    item.active
                                        ? 'bg-blue-50 font-semibold text-blue-600 shadow-sm'
                                        : 'text-slate-600 hover:bg-slate-100'
                                "
                            >
                                <span
                                    class="flex h-9 w-9 items-center justify-center rounded-xl"
                                    :class="item.active ? 'bg-white text-blue-600' : 'bg-slate-100 text-slate-500'"
                                >
                                    <svg
                                        v-if="item.icon === 'home'"
                                        class="h-5 w-5"
                                        viewBox="0 0 24 24"
                                        fill="none"
                                        stroke="currentColor"
                                        stroke-width="2"
                                    >
                                        <path d="M3 10.5L12 3l9 7.5" />
                                        <path d="M5 10v10h14V10" />
                                    </svg>
                                    <svg
                                        v-else-if="item.icon === 'chart'"
                                        class="h-5 w-5"
                                        viewBox="0 0 24 24"
                                        fill="none"
                                        stroke="currentColor"
                                        stroke-width="2"
                                    >
                                        <path d="M4 19V5" />
                                        <path d="M10 19V9" />
                                        <path d="M16 19V3" />
                                        <path d="M22 19V12" />
                                    </svg>
                                    <svg
                                        v-else-if="item.icon === 'card'"
                                        class="h-5 w-5"
                                        viewBox="0 0 24 24"
                                        fill="none"
                                        stroke="currentColor"
                                        stroke-width="2"
                                    >
                                        <rect x="3" y="5" width="18" height="14" rx="3" />
                                        <path d="M3 10h18" />
                                    </svg>
                                    <svg
                                        v-else
                                        class="h-5 w-5"
                                        viewBox="0 0 24 24"
                                        fill="none"
                                        stroke="currentColor"
                                        stroke-width="2"
                                    >
                                        <circle cx="12" cy="12" r="8" />
                                        <circle cx="12" cy="12" r="3" />
                                    </svg>
                                </span>
                                {{ item.label }}
                            </Link>
                        </nav>
                    </div>

                    <div class="space-y-2 text-sm">
                        <Link class="flex items-center gap-3 rounded-2xl px-4 py-3 text-slate-600 hover:bg-slate-100" :href="route('profile.edit')">
                            <span class="flex h-9 w-9 items-center justify-center rounded-xl bg-slate-100 text-slate-500">
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <circle cx="12" cy="8" r="4" />
                                    <path d="M4 20c2.5-4 13.5-4 16 0" />
                                </svg>
                            </span>
                            Perfil
                        </Link>
                        <Link class="flex items-center gap-3 rounded-2xl px-4 py-3 text-slate-600 hover:bg-slate-100" :href="route('settings')">
                            <span class="flex h-9 w-9 items-center justify-center rounded-xl bg-slate-100 text-slate-500">
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path
                                        d="M19.4 15a1 1 0 0 1 .2 1.1l-1 1.8a1 1 0 0 1-1 .5l-1.7-.2a6 6 0 0 1-2 1.2l-.5 1.6a1 1 0 0 1-1 .7h-2a1 1 0 0 1-1-.7l-.5-1.6a6 6 0 0 1-2-1.2l-1.7.2a1 1 0 0 1-1-.5l-1-1.8a1 1 0 0 1 .2-1.1l1.3-1.2a6 6 0 0 1 0-2.4L3.3 10a1 1 0 0 1-.2-1.1l1-1.8a1 1 0 0 1 1-.5l1.7.2a6 6 0 0 1 2-1.2l.5-1.6a1 1 0 0 1 1-.7h2a1 1 0 0 1 1 .7l.5 1.6a6 6 0 0 1 2 1.2l1.7-.2a1 1 0 0 1 1 .5l1 1.8a1 1 0 0 1-.2 1.1l-1.3 1.2a6 6 0 0 1 0 2.4Z"
                                    />
                                    <path d="M12 15.5a3.5 3.5 0 1 0-3.5-3.5" />
                                </svg>
                            </span>
                            Configurações
                        </Link>
                        <button
                            class="mt-8 flex w-full items-center justify-center rounded-2xl border border-slate-200 py-3 text-slate-400"
                            type="button"
                            @click="goBack"
                            aria-label="Voltar"
                        >
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M15 18l-6-6 6-6" />
                            </svg>
                        </button>
                    </div>
                </aside>

                <section class="space-y-6">
                    <div class="rounded-[28px] border border-white/70 bg-white/80 p-6 shadow-[0_24px_60px_-40px_rgba(15,23,42,0.5)] backdrop-blur">
                        <div class="flex flex-wrap items-center justify-between gap-4">
                            <div>
                                <h1 class="text-2xl font-semibold text-slate-900">{{ props.title }}</h1>
                                <p v-if="props.subtitle" class="text-sm text-slate-500">{{ props.subtitle }}</p>
                                <p v-else class="text-sm text-slate-500">Bem-vindo de volta, {{ userName }}.</p>
                            </div>
                            <div class="flex flex-wrap items-center gap-3">
                                <button
                                    class="inline-flex items-center gap-2 rounded-2xl bg-red-50 px-4 py-2 text-sm font-semibold text-red-500 shadow-sm"
                                    type="button"
                                    @click="openTransaction('expense')"
                                >
                                    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M12 3v14" />
                                        <path d="M7 12l5 5 5-5" />
                                    </svg>
                                    Nova Saída
                                </button>
                                <button
                                    class="inline-flex items-center gap-2 rounded-2xl bg-emerald-50 px-4 py-2 text-sm font-semibold text-emerald-600 shadow-sm"
                                    type="button"
                                    @click="openTransaction('income')"
                                >
                                    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M12 21V7" />
                                        <path d="M7 12l5-5 5 5" />
                                    </svg>
                                    Nova Entrada
                                </button>
                                <div class="mx-2 hidden h-10 w-px bg-slate-200 sm:block"></div>
                                <Link
                                    v-if="isAdmin"
                                    :href="route('admin.users.index')"
                                    class="inline-flex items-center gap-2 rounded-2xl border border-emerald-100 bg-emerald-50 px-4 py-2 text-sm font-semibold text-emerald-700"
                                >
                                    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10Z" />
                                        <path d="M9 12l2 2 4-4" />
                                    </svg>
                                    Admin
                                </Link>
                                <div class="flex items-center gap-2">
                                    <button
                                        class="relative flex h-11 w-11 items-center justify-center rounded-2xl border border-slate-200 bg-white text-slate-500 transition hover:bg-slate-50"
                                        type="button"
                                        @click="openNotifications"
                                        aria-label="Abrir notificações"
                                    >
                                        <span class="absolute right-3 top-3 h-2 w-2 rounded-full bg-red-500"></span>
                                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M15 17h5l-1.4-1.4A2 2 0 0 1 18 14V11a6 6 0 1 0-12 0v3a2 2 0 0 1-.6 1.6L4 17h5" />
                                            <path d="M9 17a3 3 0 0 0 6 0" />
                                        </svg>
                                    </button>
                                    <div class="flex h-11 w-11 items-center justify-center rounded-2xl border-2 border-blue-500 bg-slate-50 text-sm font-semibold text-slate-700">
                                        {{ initials }}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <slot />
                </section>
            </div>
        </div>
    </div>

    <div v-if="isNotificationsOpen" class="fixed inset-0 z-50">
        <button
            class="absolute inset-0 bg-slate-900/20 backdrop-blur-sm"
            type="button"
            @click="closeNotifications"
            aria-label="Fechar notificações"
        ></button>
        <aside class="absolute right-0 top-0 h-full w-full max-w-[420px] bg-white shadow-2xl">
            <div class="flex items-center justify-between border-b border-slate-100 px-6 py-5">
                <div class="text-lg font-semibold text-slate-900">Notificações</div>
                <button class="rounded-xl p-2 text-slate-400 hover:bg-slate-100" type="button" @click="closeNotifications" aria-label="Fechar">
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M18 6L6 18" />
                        <path d="M6 6l12 12" />
                    </svg>
                </button>
            </div>

            <div class="p-6">
                <div class="rounded-[24px] border border-slate-100 bg-white p-5 shadow-[0_18px_40px_-30px_rgba(15,23,42,0.5)]">
                    <div class="flex gap-4">
                        <div class="flex h-12 w-12 items-center justify-center rounded-2xl bg-red-50 text-red-500">
                            <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M12 9v4" />
                                <path d="M12 17h.01" />
                                <path d="M10.3 4.2l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.7-2.8l-8-14a2 2 0 0 0-3.4 0Z" />
                            </svg>
                        </div>
                        <div class="flex-1">
                            <div class="text-sm font-semibold text-slate-900">Fatura Nubank Vence Hoje</div>
                            <div class="mt-1 text-sm text-slate-500">Evite juros pagando R$ 1.450,00 até as 23:59.</div>
                        </div>
                    </div>
                    <button class="mt-5 w-full rounded-2xl bg-red-600 py-3 text-sm font-semibold text-white shadow-sm hover:bg-red-700" type="button">
                        Pagar Agora
                    </button>
                </div>
            </div>
        </aside>
    </div>

    <TransactionModal :open="isTransactionOpen" :kind="transactionKind" @close="closeTransaction" />
</template>
