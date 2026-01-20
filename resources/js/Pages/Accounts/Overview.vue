<script setup lang="ts">
import { computed, ref, watch, onMounted } from 'vue';
import { Head, Link, usePage } from '@inertiajs/vue3';
import type { BootstrapData } from '@/types/kitamo';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import { useIsMobile } from '@/composables/useIsMobile';
import CreateAccountFlowModal from '@/Components/CreateAccountFlowModal.vue';
import CreateCreditCardFlowModal from '@/Components/CreateCreditCardFlowModal.vue';
import CreditCardModal, { type CreditCardModalPayload } from '@/Components/CreditCardModal.vue';
import MobileToast from '@/Components/MobileToast.vue';
import { requestJson } from '@/lib/kitamoApi';

const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() =>
    isMobile.value ? { showNav: false } : { title: 'Minhas Contas', subtitle: 'Resumo', showSearch: false, showNewAction: false },
);
const page = usePage();
const bootstrap = computed(
    () => (page.props.bootstrap ?? { entries: [], goals: [], accounts: [], categories: [], tags: [] }) as BootstrapData,
);

const activeMonth = ref(new Date());
const monthItems = computed(() => {
    const base = new Date(activeMonth.value.getFullYear(), activeMonth.value.getMonth(), 1);
    const items: Array<{ key: string; label: string; date: Date }> = [];
    for (let i = -2; i <= 2; i += 1) {
        const d = new Date(base.getFullYear(), base.getMonth() + i, 1);
        const label = new Intl.DateTimeFormat('pt-BR', { month: 'short' }).format(d).replace('.', '').toUpperCase();
        items.push({ key: `${d.getFullYear()}-${d.getMonth()}`, label, date: d });
    }
    return items;
});
const selectedMonthKey = ref('');
const accountsDataByMonth = ref<Map<string, any[]>>(new Map());
const accountsModeByMonth = ref<Map<string, string>>(new Map());

// Initialize selectedMonthKey after monthItems is computed
onMounted(() => {
    selectedMonthKey.value = monthItems.value[2]?.key ?? monthItems.value[0]?.key ?? '';
    if (selectedMonthKey.value) {
        loadAccountsForMonth(selectedMonthKey.value);
    }
});

const formatBRL = (value: number) =>
    new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL', minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(value);

const loadAccountsForMonth = async (monthKey: string) => {
    const accountsKey = monthKey;
    const cardsKey = `cards-${monthKey}`;

    if (accountsDataByMonth.value.has(accountsKey) && accountsDataByMonth.value.has(cardsKey)) {
        return;
    }

    try {
        const [year, month] = monthKey.split('-').map(Number);

        // Load bank accounts and wallets
        if (!accountsDataByMonth.value.has(accountsKey)) {
            const accountsResponse = await requestJson<{ accounts: any[]; mode?: string }>(`/api/contas-by-month?year=${year}&month=${month}`, {
                method: 'GET',
            });
            const accounts = (accountsResponse as any)?.accounts ?? (accountsResponse as any)?.contas ?? [];
            accountsDataByMonth.value.set(accountsKey, Array.isArray(accounts) ? accounts : []);
            const mode = String((accountsResponse as any)?.mode ?? '');
            if (mode) accountsModeByMonth.value.set(accountsKey, mode);
        }

        // Load credit cards
        if (!accountsDataByMonth.value.has(cardsKey)) {
            const cardsResponse = await requestJson<{ cartoes: any[] }>(`/api/cartoes-by-month?year=${year}&month=${month}`, {
                method: 'GET',
            });
            const cards = (cardsResponse as any)?.cartoes ?? (cardsResponse as any)?.cards ?? [];
            accountsDataByMonth.value.set(cardsKey, Array.isArray(cards) ? cards : []);
        }
    } catch {
        // Fallback to bootstrap data if API call fails
        console.error('Failed to load accounts for month');
    }
};

const bankAccounts = computed(() => {
    const monthKey = selectedMonthKey.value;
    const hasMonthData = Boolean(monthKey) && accountsDataByMonth.value.has(monthKey);
    const monthData = hasMonthData ? (accountsDataByMonth.value.get(monthKey) ?? []) : null;

    if (Array.isArray(monthData)) {
        return monthData
            .filter((a: any) => (a.type ?? a.tipo) !== 'credit_card')
            .map((a: any) => {
                const type = (a.type ?? a.tipo) as string | undefined;
                return {
                    id: a.id,
                    name: a.name ?? a.nome,
                    subtitle: a.subtitle ?? a.subtitulo ?? (type === 'wallet' ? 'Dinheiro físico' : type === 'bank' ? 'Corrente' : 'Conta'),
                    balance: Number(a.current_balance ?? a.saldo_atual ?? a.saldo ?? 0),
                    color: a.color ?? a.cor ?? '#14B8A6',
                    icon: a.icon ?? a.icone ?? (type === 'wallet' ? 'wallet' : 'bank'),
                    hasData: Boolean(a.has_data ?? true),
                    balanceKind: String(a.balance_kind ?? ''),
                };
            });
    }

    if (!monthKey || accountsDataByMonth.value.has(monthKey)) return [];

    return (bootstrap.value.accounts ?? [])
        .filter((a) => a.type !== 'credit_card')
        .map((a) => ({
            id: a.id,
            name: a.name,
            subtitle: a.type === 'wallet' ? 'Dinheiro físico' : a.type === 'bank' ? 'Corrente' : 'Conta',
            balance: Number(a.current_balance ?? 0),
            color: (a as any).color ?? '#14B8A6',
            icon: a.icon ?? (a.type === 'wallet' ? 'wallet' : 'bank'),
            hasData: true,
            balanceKind: '',
        }));
});

const creditCards = computed(() => {
    const monthKey = selectedMonthKey.value;
    const cardsKey = `cards-${monthKey}`;
    const hasMonthData = Boolean(monthKey) && accountsDataByMonth.value.has(cardsKey);
    const monthData = hasMonthData ? (accountsDataByMonth.value.get(cardsKey) ?? []) : null;

    if (Array.isArray(monthData)) {
        return monthData.map((c: any) => ({
            id: c.id,
            name: c.name ?? c.nome,
            balance: Math.max(0, Number(c.limite_usado ?? c.current_balance ?? 0)),
            limit: Number(c.limite ?? c.credit_limit ?? 0),
            color: c.cor ?? c.color ?? '#8B5CF6',
            brand: c.bandeira ?? c.card_brand ?? 'visa',
            closingDay: Number(c.dia_fechamento ?? c.closing_day ?? 0) || null,
            dueDay: Number(c.dia_vencimento ?? c.due_day ?? 0) || null,
        }));
    }

    if (!monthKey || accountsDataByMonth.value.has(cardsKey)) return [];

    return (bootstrap.value.accounts ?? [])
        .filter((a) => a.type === 'credit_card')
        .map((a) => ({
            id: a.id,
            name: a.name,
            balance: Math.max(0, Number(a.current_balance ?? 0)),
            limit: Number(a.credit_limit ?? 0),
            color: (a as any).color ?? '#8B5CF6',
            brand: String((a as any).card_brand ?? 'visa'),
            closingDay: Number(a.closing_day ?? 0) || null,
            dueDay: Number((a as any).due_day ?? 0) || null,
        }));
});

const creditCardsDisplay = computed(() => {
    const normalize = (value: string) => String(value ?? '').trim().toLowerCase();
    const grouped = new Map<string, Array<(typeof creditCards.value)[number]>>();

    for (const card of creditCards.value) {
        const key = normalize(card.name);
        const items = grouped.get(key) ?? [];
        items.push(card);
        grouped.set(key, items);
    }

    const result: Array<(typeof creditCards.value)[number] & { displayName: string }> = [];
    for (const [key, group] of grouped.entries()) {
        if (group.length === 1) {
            result.push({ ...group[0]!, displayName: group[0]!.name });
            continue;
        }

        const sorted = [...group].sort((a, b) => String(a.id).localeCompare(String(b.id)));
        const hasBrandDiff = new Set(sorted.map((c) => String(c.brand ?? '').toLowerCase())).size > 1;
        const hasDueDiff = new Set(sorted.map((c) => c.dueDay ?? null)).size > 1;
        const hasClosingDiff = new Set(sorted.map((c) => c.closingDay ?? null)).size > 1;

        sorted.forEach((card, index) => {
            const parts: string[] = [];
            if (hasBrandDiff && card.brand) parts.push(String(card.brand).toUpperCase());
            if (hasDueDiff && card.dueDay) parts.push(`Venc. ${card.dueDay}`);
            if (hasClosingDiff && card.closingDay) parts.push(`Fecha ${card.closingDay}`);

            const displayName = parts.length ? `${card.name} • ${parts.join(' • ')}` : `${card.name} (${index + 1})`;
            result.push({ ...card, displayName });
        });
    }

    const indexById = new Map(creditCards.value.map((c, idx) => [String(c.id), idx]));
    return result.sort((a, b) => (indexById.get(String(a.id)) ?? 0) - (indexById.get(String(b.id)) ?? 0));
});

const totalBankBalance = computed(() => bankAccounts.value.reduce((sum, a) => sum + a.balance, 0));
const totalCardsBalance = computed(() => creditCards.value.reduce((sum, c) => sum + c.balance, 0));
const netWorth = computed(() => totalBankBalance.value - totalCardsBalance.value);

const selectedMonthMode = computed(() => {
    const key = selectedMonthKey.value;
    if (!key) return '';
    return String(accountsModeByMonth.value.get(key) ?? '');
});

const toastOpen = ref(false);
const toastMessage = ref('');
const showToast = (message: string) => {
    toastMessage.value = message;
    toastOpen.value = true;
};

const createAccountOpen = ref(false);
const createAccountWithWallet = ref(false);
const creditCardModalOpen = ref(false);
const createCreditCardFlowOpen = ref(false);
const accountMenuOpen = ref(false);

const openAccountMenuOption = (option: 'bank' | 'wallet' | 'card') => {
    accountMenuOpen.value = false;
    if (option === 'bank') {
        createAccountWithWallet.value = false;
        createAccountOpen.value = true;
    } else if (option === 'wallet') {
        createAccountWithWallet.value = true;
        createAccountOpen.value = true;
    } else if (option === 'card') {
        createCreditCardFlowOpen.value = true;
    }
};

const handleCreateCreditCardFlowSave = () => {
    window.location.reload();
};

const saveCreditCard = async (payload: CreditCardModalPayload) => {
    try {
        await requestJson('/api/cartoes', {
            method: 'POST',
            body: JSON.stringify({ ...payload, icone: 'credit-card' }),
        });
        showToast('Cartão adicionado com sucesso!');
        creditCardModalOpen.value = false;
        window.location.reload();
    } catch {
        showToast('Não foi possível adicionar o cartão');
    }
};

const closingLabel = (closingDay: number | null) => {
    if (!closingDay) return '';
    const now = new Date();
    const d = new Date(now.getFullYear(), now.getMonth(), closingDay);
    const label = new Intl.DateTimeFormat('pt-BR', { day: '2-digit', month: 'short' }).format(d).replace('.', '').toUpperCase();
    return `Fecha em ${label}`;
};

// Watch for month changes and load data
watch(
    () => selectedMonthKey.value,
    (newMonthKey) => {
        if (newMonthKey) {
            loadAccountsForMonth(newMonthKey);
        }
    }
);
</script>

<template>
    <Head title="Minhas Contas" />

    <component :is="Shell" v-bind="shellProps">
        <template v-if="!isMobile" #headerActions>
            <div class="relative">
                <button
                    type="button"
                    class="flex h-11 w-11 items-center justify-center rounded-2xl bg-white text-slate-600 ring-1 ring-slate-200/60"
                    aria-label="Menu"
                    @click="accountMenuOpen = !accountMenuOpen"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="currentColor">
                        <circle cx="12" cy="5" r="2" />
                        <circle cx="12" cy="12" r="2" />
                        <circle cx="12" cy="19" r="2" />
                    </svg>
                </button>

                <div v-if="accountMenuOpen" class="fixed inset-0 z-[65]" @click="accountMenuOpen = false">
                    <div
                        class="absolute right-5 top-16 w-56 overflow-hidden rounded-2xl bg-white shadow-2xl ring-1 ring-slate-200/70"
                        @click.stop
                    >
                        <button
                            type="button"
                            class="w-full rounded-t-2xl border-b border-slate-100 px-4 py-3 text-left text-sm font-semibold text-slate-900 hover:bg-slate-50"
                            @click="openAccountMenuOption('bank')"
                        >
                            Adicionar Conta Bancária
                        </button>
                        <button
                            type="button"
                            class="w-full border-b border-slate-100 px-4 py-3 text-left text-sm font-semibold text-slate-900 hover:bg-slate-50"
                            @click="openAccountMenuOption('wallet')"
                        >
                            Criar Carteira
                        </button>
                        <button
                            type="button"
                            class="w-full rounded-b-2xl px-4 py-3 text-left text-sm font-semibold text-slate-900 hover:bg-slate-50"
                            @click="openAccountMenuOption('card')"
                        >
                            Adicionar Cartão de Crédito
                        </button>
                    </div>
                </div>
            </div>
        </template>

        <header v-if="isMobile" class="flex items-center justify-between pt-2">
            <Link
                :href="route('dashboard')"
                class="flex h-10 w-10 items-center justify-center rounded-2xl bg-white text-slate-600 shadow-sm ring-1 ring-slate-200/60"
                aria-label="Voltar"
            >
                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M15 18l-6-6 6-6" />
                </svg>
            </Link>

            <div class="text-center">
                <div class="text-lg font-semibold text-slate-900">Minhas Contas</div>
            </div>

            <div class="relative">
                <button
                    type="button"
                    class="flex h-10 w-10 items-center justify-center rounded-2xl bg-white text-slate-600 shadow-sm ring-1 ring-slate-200/60"
                    aria-label="Menu"
                    @click="accountMenuOpen = !accountMenuOpen"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="currentColor">
                        <circle cx="12" cy="5" r="2" />
                        <circle cx="12" cy="12" r="2" />
                        <circle cx="12" cy="19" r="2" />
                    </svg>
                </button>

                <div v-if="accountMenuOpen" class="fixed inset-0 z-[65]" @click="accountMenuOpen = false">
                    <div
                        class="absolute right-5 top-16 w-56 overflow-hidden rounded-2xl bg-white shadow-2xl ring-1 ring-slate-200/70"
                        @click.stop
                    >
                        <button
                            type="button"
                            class="w-full text-left px-4 py-3 text-sm font-semibold text-slate-900 hover:bg-slate-50 rounded-t-2xl border-b border-slate-100"
                            @click="openAccountMenuOption('bank')"
                        >
                            Adicionar Conta Bancária
                        </button>
                        <button
                            type="button"
                            class="w-full text-left px-4 py-3 text-sm font-semibold text-slate-900 hover:bg-slate-50 border-b border-slate-100"
                            @click="openAccountMenuOption('wallet')"
                        >
                            Criar Carteira
                        </button>
                        <button
                            type="button"
                            class="w-full text-left px-4 py-3 text-sm font-semibold text-slate-900 hover:bg-slate-50 rounded-b-2xl"
                            @click="openAccountMenuOption('card')"
                        >
                            Adicionar Cartão de Crédito
                        </button>
                    </div>
                </div>
            </div>
        </header>

        <div class="mt-6">
            <div class="flex gap-4 overflow-x-auto pb-2 text-xs font-bold text-slate-300">
                <button
                    v-for="m in monthItems"
                    :key="m.key"
                    type="button"
                    class="relative shrink-0 px-2 py-1"
                    :class="m.key === selectedMonthKey ? 'text-[#14B8A6]' : ''"
                    @click="selectedMonthKey = m.key"
                >
                    {{ m.label }}
                    <span v-if="m.key === selectedMonthKey" class="absolute inset-x-0 -bottom-1 mx-auto h-1 w-4 rounded-full bg-[#14B8A6]"></span>
                </button>
            </div>
        </div>

        <section class="mt-6 rounded-3xl bg-gradient-to-br from-[#14B8A6] to-[#0D9488] p-5 text-white shadow-lg shadow-teal-600/20">
            <div class="text-[11px] font-bold uppercase tracking-wide text-white/80">Patrimônio líquido</div>
            <div class="mt-2 text-3xl font-bold tracking-tight">{{ formatBRL(netWorth) }}</div>
        </section>

	        <section class="mt-8">
	            <div class="flex items-center justify-between">
	                <div class="text-xs font-bold uppercase tracking-wide text-slate-400">Contas e carteiras</div>
	                <div class="text-xs font-bold text-emerald-600">{{ formatBRL(totalBankBalance) }}</div>
	            </div>

            <div class="mt-4 space-y-3">
                <Link
                    v-for="account in bankAccounts"
                    :key="account.id"
                    :href="route('accounts.show', { accountKey: account.id })"
                    class="flex items-center justify-between rounded-3xl bg-white px-4 py-4 shadow-sm ring-1 ring-slate-200/60"
                >
                    <div class="flex items-center gap-3">
                        <span class="flex h-12 w-12 items-center justify-center rounded-2xl text-white" :style="{ backgroundColor: account.color }">
                            <svg v-if="account.icon === 'wallet'" class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M4 7h16v12H4z" />
                                <path d="M4 7V5h12v2" />
                                <path d="M16 12h4" />
                            </svg>
                            <svg v-else class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M3 10h18" />
                                <path d="M5 10V8l7-5 7 5v2" />
                                <path d="M6 10v9" />
                                <path d="M18 10v9" />
                            </svg>
                        </span>
                        <div>
                            <div class="text-sm font-semibold text-slate-900">{{ account.name }}</div>
                            <div class="flex flex-wrap items-center gap-1 text-[11px] font-semibold uppercase tracking-wide text-slate-400">
                                <span>{{ account.subtitle }}</span>
                                <span v-if="selectedMonthMode === 'past' && account.hasData === false">(SEM DADOS)</span>
                                <span v-if="selectedMonthMode === 'future'">(PROJEÇÃO)</span>
                            </div>
                        </div>
                    </div>
                    <div class="text-sm font-semibold text-slate-900">{{ formatBRL(account.balance) }}</div>
                </Link>
            </div>
        </section>

        <section class="mt-8 pb-[calc(2rem+env(safe-area-inset-bottom))]">
            <div class="flex items-center justify-between">
                <div class="text-xs font-bold uppercase tracking-wide text-slate-400">Cartões de crédito</div>
                <div class="rounded-full bg-slate-100 px-3 py-1 text-xs font-bold text-slate-600">{{ formatBRL(totalCardsBalance) }}</div>
            </div>

            <div class="mt-4 space-y-3">
                <Link
                    v-for="card in creditCardsDisplay"
                    :key="card.id"
                    :href="route('credit-cards.show', { account: card.id })"
                    class="flex items-center justify-between rounded-3xl bg-white px-4 py-4 shadow-sm ring-1 ring-slate-200/60"
                >
                    <div class="flex items-center gap-3">
                        <span class="flex h-12 w-12 items-center justify-center rounded-2xl text-white" :style="{ backgroundColor: card.color }">
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="5" width="18" height="14" rx="3" />
                                <path d="M3 10h18" />
                            </svg>
                        </span>
                        <div>
                            <div class="text-sm font-semibold text-slate-900">{{ card.displayName }}</div>
                            <div class="text-[11px] font-semibold uppercase tracking-wide text-slate-400">{{ closingLabel(card.closingDay) }}</div>
                        </div>
                    </div>
                    <div class="text-right">
                        <div class="text-sm font-semibold text-slate-900">{{ formatBRL(card.balance) }}</div>
                        <div class="text-[11px] font-semibold text-slate-400">Limite: {{ card.limit ? `${Math.round(card.limit / 1000)}k` : '-' }}</div>
                    </div>
                </Link>
            </div>
        </section>

        <MobileToast :show="toastOpen" :message="toastMessage" @dismiss="toastOpen = false" />
        <CreateAccountFlowModal :open="createAccountOpen" :start-with-wallet="createAccountWithWallet" @close="() => { createAccountOpen = false; createAccountWithWallet = false; }" @toast="showToast" />
        <CreateCreditCardFlowModal :open="createCreditCardFlowOpen" @close="createCreditCardFlowOpen = false" @save="handleCreateCreditCardFlowSave" />
        <CreditCardModal :open="creditCardModalOpen" @close="creditCardModalOpen = false" @save="saveCreditCard" />
    </component>
</template>
