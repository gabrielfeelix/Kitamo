<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import { Link, useForm, usePage } from '@inertiajs/vue3';
import { requestJson } from '@/lib/kitamoApi';
import type { Account, BootstrapData, Category } from '@/types/kitamo';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopSettingsShell from '@/Layouts/DesktopSettingsShell.vue';
import TransactionModal, { type TransactionModalPayload } from '@/Components/TransactionModal.vue';
import NewAccountModal from '@/Components/NewAccountModal.vue';
import NewCategoryModal from '@/Components/NewCategoryModal.vue';
import MobileToast from '@/Components/MobileToast.vue';
import { useIsMobile } from '@/composables/useIsMobile';

const isMobile = useIsMobile();
const page = usePage();
const bootstrap = computed(
    () => (page.props.bootstrap ?? { entries: [], goals: [], accounts: [], categories: [] }) as BootstrapData,
);
const userName = computed(() => page.props.auth?.user?.name ?? 'Gabriel Felix');
const userEmail = computed(() => page.props.auth?.user?.email ?? 'gab.feelix@gmail.com');
const userPhone = computed(() => page.props.auth?.user?.phone ?? '');

const form = useForm({
    name: userName.value,
    email: userEmail.value,
    phone: userPhone.value,
});

watch(
    () => [userName.value, userEmail.value, userPhone.value],
    () => {
        form.name = userName.value;
        form.email = userEmail.value;
        form.phone = userPhone.value;
    },
);

const resetForm = () => {
    form.name = userName.value;
    form.email = userEmail.value;
    form.phone = userPhone.value;
    form.clearErrors();
};

const submitProfile = () => {
    form.patch(route('profile.update'), {
        preserveScroll: true,
    });
};

const initials = computed(() => {
    const parts = String(userName.value).trim().split(/\s+/).filter(Boolean);
    const first = parts[0]?.[0] ?? 'G';
    const last = parts.length > 1 ? parts[parts.length - 1]?.[0] : 'F';
    return `${first}${last}`.toUpperCase();
});

type AccountIcon = 'wallet' | 'bank' | 'card' | 'phone';
type AccountItem = { key: string; label: string; amount: number; icon: AccountIcon };

type CategoryIcon = 'food' | 'home' | 'car' | 'game' | 'briefcase' | 'heart' | 'shirt' | 'bolt' | 'pill';
type CategoryItem = { key: string; label: string; icon: CategoryIcon; bg: string; fg: string };

const accountIcons = new Set<AccountIcon>(['wallet', 'bank', 'card', 'phone']);
const resolveAccountIcon = (account: Account): AccountIcon => {
    const icon = (account.icon ?? '').toString() as AccountIcon;
    if (accountIcons.has(icon)) return icon;
    if (account.type === 'credit_card') return 'card';
    if (account.type === 'bank') return 'bank';
    return 'wallet';
};

const mapAccount = (account: Account): AccountItem => ({
    key: account.id,
    label: account.name,
    amount: account.current_balance ?? 0,
    icon: resolveAccountIcon(account),
});

const categoryIcons = new Set<CategoryIcon>(['food', 'home', 'car', 'game', 'briefcase', 'heart', 'shirt', 'bolt', 'pill']);
const categoryStyles: Record<CategoryIcon, { bg: string; fg: string }> = {
    food: { bg: 'bg-amber-50', fg: 'text-amber-600' },
    home: { bg: 'bg-blue-50', fg: 'text-blue-600' },
    car: { bg: 'bg-slate-100', fg: 'text-slate-700' },
    game: { bg: 'bg-emerald-50', fg: 'text-emerald-600' },
    briefcase: { bg: 'bg-slate-100', fg: 'text-slate-700' },
    heart: { bg: 'bg-red-50', fg: 'text-red-500' },
    shirt: { bg: 'bg-pink-50', fg: 'text-pink-500' },
    bolt: { bg: 'bg-yellow-50', fg: 'text-yellow-600' },
    pill: { bg: 'bg-purple-50', fg: 'text-purple-600' },
};

const resolveCategoryIcon = (category: Category): CategoryIcon => {
    const icon = (category.icon ?? '').toString() as CategoryIcon;
    if (categoryIcons.has(icon)) return icon;
    if (category.name.toLowerCase().includes('mora')) return 'home';
    if (category.name.toLowerCase().includes('trans')) return 'car';
    if (category.name.toLowerCase().includes('saú') || category.name.toLowerCase().includes('saude')) return 'heart';
    if (category.name.toLowerCase().includes('lazer')) return 'game';
    if (category.name.toLowerCase().includes('roup')) return 'shirt';
    return 'food';
};

const mapCategory = (category: Category): CategoryItem => {
    const icon = resolveCategoryIcon(category);
    const styles = categoryStyles[icon] ?? categoryStyles.food;
    return {
        key: category.id,
        label: category.name,
        icon,
        bg: styles.bg,
        fg: styles.fg,
    };
};

const accounts = ref<AccountItem[]>([]);
const categories = ref<CategoryItem[]>([]);

watch(
    () => bootstrap.value.accounts,
    (value) => {
        accounts.value = (value ?? []).map(mapAccount);
    },
    { immediate: true },
);

watch(
    () => bootstrap.value.categories,
    (value) => {
        categories.value = (value ?? []).map(mapCategory);
    },
    { immediate: true },
);

const formatMoney = (value: number) =>
    new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL',
    }).format(value);

const transactionOpen = ref(false);
const transactionKind = ref<'expense' | 'income'>('expense');

const openQuickTransaction = () => {
    transactionKind.value = 'expense';
    transactionOpen.value = true;
};

const newAccountOpen = ref(false);
const newCategoryOpen = ref(false);

const toastOpen = ref(false);
const toastMessage = ref('');
const showToast = (message: string) => {
    toastMessage.value = message;
    toastOpen.value = true;
};

const onTransactionSave = async (payload: TransactionModalPayload) => {
    if (payload.kind === 'transfer') {
        showToast('Transferência realizada');
        return;
    }

    await requestJson(route('transactions.store'), {
        method: 'POST',
        body: JSON.stringify({
            kind: payload.kind,
            amount: payload.amount,
            description: payload.description,
            category: payload.category,
            account: payload.account,
            dateKind: payload.dateKind,
            dateOther: payload.dateOther,
            isPaid: payload.isPaid,
            isInstallment: payload.isInstallment,
            installmentCount: payload.installmentCount,
        }),
    });

    showToast('Movimentação salva');
};

const parseBalance = (value: string) => Number(value.replace(/\./g, '').replace(',', '.')) || 0;

const onSaveAccount = async (payload: { name: string; type: 'wallet' | 'bank' | 'card'; initialBalance: string; icon: string }) => {
    const response = await requestJson<{ account: Account }>(route('accounts.store'), {
        method: 'POST',
        body: JSON.stringify({
            name: payload.name || 'Nova conta',
            type: payload.type,
            initial_balance: parseBalance(payload.initialBalance),
            icon: payload.icon || null,
        }),
    });

    if (response?.account) {
        accounts.value = [...accounts.value, mapAccount(response.account)];
    }

    newAccountOpen.value = false;
    showToast('Conta criada');
};

const onSaveCategory = async (payload: { name: string; type: 'expense' | 'income'; icon: CategoryIcon }) => {
    const response = await requestJson<{ category: Category }>(route('categories.store'), {
        method: 'POST',
        body: JSON.stringify({
            name: payload.name || 'Nova categoria',
            type: payload.type,
            icon: payload.icon,
        }),
    });

    if (response?.category) {
        categories.value = [...categories.value, mapCategory(response.category)];
    }

    newCategoryOpen.value = false;
    showToast('Categoria criada');
};
</script>


<template>
    <MobileShell v-if="isMobile" @add="openQuickTransaction">
        <header class="pt-2">
            <div class="text-2xl font-semibold tracking-tight text-slate-900">Configurações</div>
        </header>

        <div class="mt-5 rounded-3xl bg-white p-5 text-center shadow-sm ring-1 ring-slate-200/60">
            <div class="mx-auto flex h-20 w-20 items-center justify-center rounded-full bg-slate-100 text-lg font-semibold text-slate-700 shadow-sm ring-4 ring-white">
                {{ initials }}
            </div>
            <div class="mt-4 text-lg font-semibold text-slate-900">{{ userName }}</div>
            <div class="text-sm text-slate-400">{{ userEmail }}</div>
            <Link
                :href="route('profile.edit')"
                class="mt-4 inline-flex items-center justify-center rounded-full border border-teal-500 px-5 py-2 text-sm font-semibold text-teal-600"
            >
                Editar perfil
            </Link>
        </div>

        <div class="mt-6 overflow-hidden rounded-3xl bg-white shadow-sm ring-1 ring-slate-200/60">
            <Link :href="route('settings.home-widgets')" class="flex items-center justify-between gap-4 px-5 py-5">
                <div class="flex items-center gap-4">
                    <span class="flex h-12 w-12 items-center justify-center rounded-2xl bg-emerald-50 text-emerald-600">
                        <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <rect x="3" y="3" width="8" height="8" rx="2" />
                            <rect x="13" y="3" width="8" height="5" rx="2" />
                            <rect x="13" y="10" width="8" height="11" rx="2" />
                            <rect x="3" y="13" width="8" height="8" rx="2" />
                        </svg>
                    </span>
                    <div>
                        <div class="text-sm font-semibold text-slate-900">Gerenciar tela inicial</div>
                        <div class="mt-1 text-xs font-semibold text-slate-400">Escolha o que aparece na Home</div>
                    </div>
                </div>
                <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M9 18l6-6-6-6" />
                </svg>
            </Link>
        </div>

        <div class="mt-8">
            <div class="text-lg font-semibold text-slate-900">Minhas Contas</div>

            <div class="mt-4 overflow-hidden rounded-3xl bg-white shadow-sm ring-1 ring-slate-200/60">
                <Link
                    v-for="acc in accounts"
                    :key="acc.key"
                    :href="route('accounts.show', { accountKey: acc.key })"
                    class="flex items-center justify-between gap-4 px-5 py-4"
                    :class="acc.key !== accounts[0]?.key ? 'border-t border-slate-100' : ''"
                >
                    <div class="flex items-center gap-4">
                        <span
                            class="flex h-12 w-12 items-center justify-center rounded-2xl"
                            :class="acc.icon === 'bank' ? 'bg-blue-50 text-blue-600' : 'bg-slate-100 text-slate-600'"
                        >
                            <svg v-if="acc.icon === 'wallet'" class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M4 7h16v12H4z" />
                                <path d="M4 7V5h12v2" />
                                <path d="M16 12h4" />
                            </svg>
                            <svg v-else-if="acc.icon === 'card'" class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="5" width="18" height="14" rx="3" />
                                <path d="M3 10h18" />
                            </svg>
                            <svg v-else-if="acc.icon === 'phone'" class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="7" y="2" width="10" height="20" rx="2" />
                                <path d="M11 19h2" />
                            </svg>
                            <svg v-else class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M3 10h18" />
                                <path d="M5 10V8l7-5 7 5v2" />
                                <path d="M6 10v9" />
                                <path d="M18 10v9" />
                                <path d="M9 19v-6h6v6" />
                            </svg>
                        </span>
                        <div class="text-sm font-semibold text-slate-900">{{ acc.label }}</div>
                    </div>
                    <div class="flex items-center gap-2">
                        <div class="text-sm font-semibold text-slate-700">{{ formatMoney(acc.amount) }}</div>
                        <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 18l6-6-6-6" />
                        </svg>
                    </div>
                </Link>

                <button type="button" class="flex w-full items-center gap-4 border-t border-slate-100 px-5 py-4 text-left" @click="newAccountOpen = true">
                    <span class="flex h-12 w-12 items-center justify-center rounded-2xl border-2 border-dashed border-teal-300 text-teal-500">
                        <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M12 5v14" />
                            <path d="M5 12h14" />
                        </svg>
                    </span>
                    <div class="text-sm font-semibold text-teal-600">Adicionar conta</div>
                </button>
            </div>
        </div>

        <div class="mt-8">
            <div class="text-lg font-semibold text-slate-900">Categorias</div>

            <div class="mt-4 grid grid-cols-2 gap-3">
                <button
                    v-for="cat in categories"
                    :key="cat.key"
                    type="button"
                    class="flex items-center gap-3 rounded-2xl bg-white px-4 py-4 text-left shadow-sm ring-1 ring-slate-200/60"
                >
                    <span class="flex h-11 w-11 items-center justify-center rounded-2xl" :class="[cat.bg, cat.fg]">
                        <svg v-if="cat.icon === 'food'" class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M4 3v7" />
                            <path d="M8 3v7" />
                            <path d="M6 3v7" />
                            <path d="M14 3v7c0 2 1 3 3 3v8" />
                            <path d="M20 3v7" />
                        </svg>
                        <svg v-else-if="cat.icon === 'home'" class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M3 10.5L12 3l9 7.5" />
                            <path d="M5 10v10h14V10" />
                        </svg>
                        <svg v-else-if="cat.icon === 'car'" class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M5 16l1-5 1-3h10l1 3 1 5" />
                            <path d="M7 16h10" />
                            <circle cx="8" cy="17" r="1.5" />
                            <circle cx="16" cy="17" r="1.5" />
                        </svg>
                        <svg v-else-if="cat.icon === 'game'" class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M7 12h4" />
                            <path d="M9 10v4" />
                            <path d="M17 11h.01" />
                            <path d="M19 13h.01" />
                            <path d="M6 18l-2-3 2-7h12l2 7-2 3H6Z" />
                        </svg>
                        <svg v-else-if="cat.icon === 'briefcase'" class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <rect x="3" y="7" width="18" height="13" rx="3" />
                            <path d="M9 7V5a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2v2" />
                            <path d="M3 12h18" />
                        </svg>
                        <svg v-else-if="cat.icon === 'heart'" class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M20 8c0 5-8 10-8 10S4 13 4 8a4 4 0 0 1 8 0 4 4 0 0 1 8 0Z" />
                        </svg>
                        <svg v-else-if="cat.icon === 'pill'" class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M10 14 8 16a4 4 0 0 1-6-6l2-2a4 4 0 0 1 6 6Z" />
                            <path d="M14 10l2-2a4 4 0 0 1 6 6l-2 2a4 4 0 0 1-6-6Z" />
                            <path d="M8 16l8-8" />
                        </svg>
                        <svg v-else-if="cat.icon === 'bolt'" class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M13 2 3 14h8l-1 8 10-12h-8l1-8Z" />
                        </svg>
                        <svg v-else class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M15 3H9l-2 4h10l-2-4Z" />
                            <path d="M7 7v14" />
                            <path d="M17 7v14" />
                        </svg>
                    </span>
                    <div class="text-sm font-semibold text-slate-900">{{ cat.label }}</div>
                </button>

                <button type="button" class="flex items-center gap-3 rounded-2xl border-2 border-dashed border-teal-300 bg-white px-4 py-4 text-left text-teal-600" @click="newCategoryOpen = true">
                    <span class="flex h-11 w-11 items-center justify-center rounded-2xl border border-teal-300">
                        <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M12 5v14" />
                            <path d="M5 12h14" />
                        </svg>
                    </span>
                    <div class="text-sm font-semibold">Adicionar</div>
                </button>
            </div>
        </div>

        <div class="mt-8 pb-4">
            <div class="text-lg font-semibold text-slate-900">Geral</div>

            <div class="mt-4 overflow-hidden rounded-3xl bg-white shadow-sm ring-1 ring-slate-200/60">
                <Link :href="route('settings.notifications')" class="flex w-full items-center justify-between px-5 py-4 text-left">
                    <div class="flex items-center gap-4">
                        <span class="flex h-11 w-11 items-center justify-center rounded-2xl bg-slate-100 text-slate-500">
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M15 17h5l-1.4-1.4a2 2 0 0 1-.6-1.4V11a6 6 0 1 0-12 0v3.2c0 .5-.2 1-.6 1.4L4 17h5" />
                                <path d="M9 17a3 3 0 0 0 6 0" />
                            </svg>
                        </span>
                        <div class="text-sm font-semibold text-slate-900">Notificações</div>
                    </div>
                    <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M9 18l6-6-6-6" />
                    </svg>
                </Link>

                <div class="border-t border-slate-100">
                    <Link :href="route('settings.security')" class="flex w-full items-center justify-between px-5 py-4 text-left">
                        <div class="flex items-center gap-4">
                            <span class="flex h-11 w-11 items-center justify-center rounded-2xl bg-slate-100 text-slate-500">
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M12 22s8-4 8-10V6l-8-4-8 4v6c0 6 8 10 8 10Z" />
                                </svg>
                            </span>
                            <div class="text-sm font-semibold text-slate-900">Segurança e Privacidade</div>
                        </div>
                        <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 18l6-6-6-6" />
                        </svg>
                    </Link>
                </div>

                <div class="border-t border-slate-100">
                    <Link :href="route('settings.support')" class="flex w-full items-center justify-between px-5 py-4 text-left">
                        <div class="flex items-center gap-4">
                            <span class="flex h-11 w-11 items-center justify-center rounded-2xl bg-slate-100 text-slate-500">
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <circle cx="12" cy="12" r="9" />
                                    <path d="M12 16v-1" />
                                    <path d="M12 11a2 2 0 1 0-2-2" />
                                </svg>
                            </span>
                            <div class="text-sm font-semibold text-slate-900">Ajuda e Suporte</div>
                        </div>
                        <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 18l6-6-6-6" />
                        </svg>
                    </Link>
                </div>

                <div class="border-t border-slate-100">
                    <Link :href="route('settings.about')" class="flex w-full items-center justify-between px-5 py-4 text-left">
                        <div class="flex items-center gap-4">
                            <span class="flex h-11 w-11 items-center justify-center rounded-2xl bg-slate-100 text-slate-500">
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <circle cx="12" cy="12" r="9" />
                                    <path d="M12 10v6" />
                                    <path d="M12 8h.01" />
                                </svg>
                            </span>
                            <div>
                                <div class="text-sm font-semibold text-slate-900">Sobre o App</div>
                                <div class="text-xs font-semibold text-slate-400">Versão 1.0.0</div>
                            </div>
                        </div>
                        <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 18l6-6-6-6" />
                        </svg>
                    </Link>
                </div>
            </div>

            <div class="mt-6 flex justify-center">
                <Link
                    :href="route('logout')"
                    method="post"
                    as="button"
                    class="text-sm font-semibold text-red-500"
                >
                    Sair da conta
                </Link>
            </div>
        </div>

        <TransactionModal :open="transactionOpen" :kind="transactionKind" @close="transactionOpen = false" @save="onTransactionSave" />
        <NewAccountModal :open="newAccountOpen" @close="newAccountOpen = false" @save="onSaveAccount" />
        <NewCategoryModal :open="newCategoryOpen" @close="newCategoryOpen = false" @save="onSaveCategory" />
        <MobileToast :show="toastOpen" :message="toastMessage" @dismiss="toastOpen = false" />
    </MobileShell>

    <div v-else-if="false">
        <div class="rounded-[28px] border border-white/70 bg-white p-8 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)]">
            <div class="text-sm font-semibold text-slate-900">Configurações (desktop/tablet)</div>
            <div class="mt-2 text-sm text-slate-500">Vamos adaptar essa tela depois da versão mobile.</div>
        </div>
    </div>

    <DesktopSettingsShell v-else>
        <div class="overflow-hidden rounded-3xl bg-white shadow-sm ring-1 ring-slate-200/60">
            <div class="px-10 py-9">
                <div class="flex items-center gap-6">
                    <div class="h-20 w-20 overflow-hidden rounded-2xl bg-slate-200 ring-4 ring-white shadow-sm">
                        <div class="flex h-full w-full items-center justify-center bg-slate-300 text-xl font-bold text-slate-700">
                            {{ initials }}
                        </div>
                    </div>
                    <div class="min-w-0">
                        <div class="truncate text-2xl font-semibold tracking-tight text-slate-900">{{ userName }}</div>
                        <div class="mt-1 text-sm font-semibold text-slate-400">Informações básicas de acesso à conta.</div>
                    </div>
                </div>

                <form class="mt-10 space-y-8" @submit.prevent="submitProfile">
                    <div class="grid grid-cols-2 gap-8">
                        <div>
                            <div class="text-[11px] font-bold uppercase tracking-wide text-slate-300">Nome completo</div>
                            <input
                                v-model="form.name"
                                type="text"
                                class="mt-3 h-12 w-full rounded-2xl bg-slate-50 px-4 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60 focus:outline-none focus:ring-2 focus:ring-emerald-200"
                            />
                            <div v-if="form.errors.name" class="mt-2 text-xs font-semibold text-red-500">{{ form.errors.name }}</div>
                        </div>

                        <div>
                            <div class="text-[11px] font-bold uppercase tracking-wide text-slate-300">Telefone</div>
                            <input
                                v-model="form.phone"
                                type="tel"
                                class="mt-3 h-12 w-full rounded-2xl bg-slate-50 px-4 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60 focus:outline-none focus:ring-2 focus:ring-emerald-200"
                            />
                        </div>
                    </div>

                    <div>
                        <div class="text-[11px] font-bold uppercase tracking-wide text-slate-300">E-mail de acesso</div>
                        <div class="mt-3 flex items-center gap-3 rounded-2xl bg-slate-50 px-4 ring-1 ring-slate-200/60">
                            <input
                                v-model="form.email"
                                type="email"
                                disabled
                                class="h-12 w-full cursor-not-allowed bg-transparent text-sm font-semibold text-slate-400 focus:outline-none"
                            />
                            <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="6" y="11" width="12" height="10" rx="2" />
                                <path d="M8 11V8a4 4 0 1 1 8 0v3" />
                            </svg>
                        </div>
                        <div class="mt-2 text-xs font-semibold text-slate-300">O e-mail não pode ser alterado para garantir a segurança da conta.</div>
                    </div>

                    <div class="pt-2">
                        <Link :href="route('password.request')" class="inline-flex items-center gap-2 text-sm font-semibold text-[#14B8A6]">
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M10 14 8 16a4 4 0 0 1-6-6l2-2a4 4 0 0 1 6 6Z" />
                                <path d="M14 10l2-2a4 4 0 0 1 6 6l-2 2a4 4 0 0 1-6-6Z" />
                                <path d="M8 16l8-8" />
                            </svg>
                            Esqueceu sua senha?
                        </Link>
                    </div>
                </form>
            </div>

            <div class="flex items-center justify-between border-t border-slate-100 px-10 py-7">
                <button type="button" class="text-sm font-semibold text-slate-400 hover:text-slate-500" @click="resetForm">Cancelar</button>
                <button
                    type="button"
                    class="inline-flex h-12 items-center justify-center rounded-2xl bg-[#14B8A6] px-8 text-sm font-semibold text-white shadow-lg shadow-emerald-500/20 disabled:opacity-60"
                    :disabled="form.processing"
                    @click="submitProfile"
                >
                    Guardar Alterações
                </button>
            </div>
        </div>

        <MobileToast :show="toastOpen" :message="toastMessage" @dismiss="toastOpen = false" />
    </DesktopSettingsShell>
</template>
