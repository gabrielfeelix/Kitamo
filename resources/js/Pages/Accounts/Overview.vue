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
import MonthNavigator from '@/Components/MonthNavigator.vue';
import { requestJson } from '@/lib/kitamoApi';
import { getBankSvgPath } from '@/lib/bankLogos';
import TransactionModal, { type TransactionModalPayload } from '@/Components/TransactionModal.vue';
import { executeTransfer } from '@/lib/transactions';
import type { AccountOption } from '@/Components/AccountPickerSheet.vue';
import type { CategoryOption } from '@/Components/CategoryPickerSheet.vue';
import InstitutionAvatar from '@/Components/InstitutionAvatar.vue';

const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() =>
    isMobile.value ? { showNav: false } : { title: 'Minhas Contas', subtitle: 'Resumo', showSearch: false, showNewAction: false },
);
const page = usePage();
const bootstrap = computed(
    () => (page.props.bootstrap ?? { entries: [], goals: [], accounts: [], categories: [], tags: [] }) as BootstrapData,
);

const monthItems = computed(() => {
    const base = new Date();
    const items: Array<{ key: string; label: string; date: Date }> = [];
    for (let i = -120; i <= 120; i += 1) {
        const d = new Date(base.getFullYear(), base.getMonth() + i, 1);
        const label = new Intl.DateTimeFormat('pt-BR', { month: 'short' }).format(d).replace('.', '').toUpperCase();
        items.push({ key: `${d.getFullYear()}-${d.getMonth()}`, label, date: d });
    }
    return items;
});
const selectedMonthKey = ref('');
const accountsDataByMonth = ref<Map<string, any[]>>(new Map());
const accountsModeByMonth = ref<Map<string, string>>(new Map());
const isLoadingMonth = ref<Map<string, boolean>>(new Map());
const balanceNetByMonth = ref<Map<string, number>>(new Map());

// Initialize selectedMonthKey after monthItems is computed
onMounted(() => {
    const key = `${new Date().getFullYear()}-${new Date().getMonth()}`;
    selectedMonthKey.value = monthItems.value.find((m) => m.key === key)?.key ?? monthItems.value[0]?.key ?? '';
});

// Watch for month changes and load data
watch(
    selectedMonthKey,
    (key) => {
        if (key) {
            void loadAccountsForMonth(key);
        }
    },
    { immediate: true },
);

const formatBRL = (value: number) =>
    new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL', minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(value);

const pickerCategories = computed<CategoryOption[]>(() => {
    const unique = new Map<string, CategoryOption>();
    for (const c of bootstrap.value.categories ?? []) {
        const kind = c.type === 'income' ? 'income' : c.type === 'expense' ? 'expense' : undefined;
        const current = unique.get(c.name);
        const mergedKind = current?.kind && kind && current.kind !== kind ? undefined : (current?.kind ?? kind);
        unique.set(c.name, {
            key: c.name,
            label: c.name,
            icon: (c.icon ?? 'other') as any,
            tone: 'slate',
            customColor: c.color ?? undefined,
            kind: mergedKind,
        });
    }
    return Array.from(unique.values());
});

const pickerAccounts = computed<AccountOption[]>(() => {
    const tone = (name: string): AccountOption['tone'] => {
        const n = name.toLowerCase();
        if (n.includes('nubank')) return 'purple';
        if (n.includes('inter')) return 'amber';
        if (n.includes('carteira') || n.includes('dinheiro')) return 'emerald';
        return 'slate';
    };

    return (bootstrap.value.accounts ?? [])
        .filter((a) => a.type !== 'credit_card')
        .map((a) => ({
            key: a.name,
            label: a.name,
            subtitle: a.type === 'wallet' ? 'Carteira' : 'Conta',
            tone: tone(a.name),
            type: a.type as 'bank' | 'wallet',
            balance: Number(a.current_balance ?? 0),
            customColor: (a as any).color ?? undefined,
            icon: a.icon ?? undefined,
        }));
});

const transactionOpen = ref(false);
const transactionKind = ref<'expense' | 'income' | 'transfer'>('transfer');
const transactionInitial = ref<TransactionModalPayload | null>(null);

const openQuickTransfer = () => {
    transactionKind.value = 'transfer';
    transactionInitial.value = null;
    transactionOpen.value = true;
};

const onTransactionSave = async (payload: TransactionModalPayload) => {
    if (payload.kind !== 'transfer') return;
    try {
        await executeTransfer(payload);
        showToast('Transferência realizada');
        transactionOpen.value = false;
        if (selectedMonthKey.value) {
            void loadAccountsForMonth(selectedMonthKey.value);
        }
    } catch {
        showToast('Não foi possível realizar a transferência');
    }
};

const loadAccountsForMonth = async (monthKey: string) => {
    const accountsKey = monthKey;
    const cardsKey = `cards-${monthKey}`;

    // Clear previous data for this month to avoid showing stale data
    accountsDataByMonth.value.delete(accountsKey);
    accountsDataByMonth.value.delete(cardsKey);
    accountsModeByMonth.value.delete(accountsKey);
    balanceNetByMonth.value.delete(accountsKey);

    // Mark as loading
    isLoadingMonth.value.set(monthKey, true);

    try {
        const [year, month] = monthKey.split('-').map(Number);

        // Load both bank accounts and credit cards in parallel
        const [accountsResponse, cardsResponse] = await Promise.all([
            requestJson<{ accounts: any[]; mode?: string }>(`/api/contas-by-month?year=${year}&month=${month}`, {
                method: 'GET',
            }),
            requestJson<{ cartoes: any[] }>(`/api/cartoes-by-month?year=${year}&month=${month}`, {
                method: 'GET',
            }),
        ]);

        // Process bank accounts
        const accounts = (accountsResponse as any)?.accounts ?? (accountsResponse as any)?.contas ?? [];
        accountsDataByMonth.value.set(accountsKey, Array.isArray(accounts) ? accounts : []);
        const mode = String((accountsResponse as any)?.mode ?? '');
        if (mode) accountsModeByMonth.value.set(accountsKey, mode);
        const balanco = Number((accountsResponse as any)?.balanco ?? NaN);
        if (Number.isFinite(balanco)) balanceNetByMonth.value.set(accountsKey, balanco);

        // Process credit cards
        const cards = (cardsResponse as any)?.cartoes ?? (cardsResponse as any)?.cards ?? [];
        accountsDataByMonth.value.set(cardsKey, Array.isArray(cards) ? cards : []);
    } catch (error) {
        console.error('Failed to load accounts for month', error);
        // Set empty arrays on error to prevent showing bootstrap data
        accountsDataByMonth.value.set(accountsKey, []);
        accountsDataByMonth.value.set(cardsKey, []);
        balanceNetByMonth.value.set(accountsKey, 0);
    } finally {
        // Mark as loaded
        isLoadingMonth.value.set(monthKey, false);
    }
};

const bankAccounts = computed(() => {
    const monthKey = selectedMonthKey.value;

    // If loading or no data available yet, return empty array
    if (!monthKey || isLoadingMonth.value.get(monthKey)) {
        return [];
    }

    const hasMonthData = accountsDataByMonth.value.has(monthKey);
    if (!hasMonthData) {
        return [];
    }

    const monthData = accountsDataByMonth.value.get(monthKey) ?? [];

    return monthData
        .filter((a: any) => (a.type ?? a.tipo) !== 'credit_card')
        .map((a: any) => {
            const type = (a.type ?? a.tipo) as string | undefined;
            const institution = a.institution ?? null;
            const svgPath = a.svgPath ?? null;
            const logoName = institution ?? (a.name ?? a.nome) ?? null;
            return {
                id: a.id,
                name: a.name ?? a.nome,
                subtitle: a.subtitle ?? a.subtitulo ?? (type === 'wallet' ? 'Dinheiro físico' : type === 'bank' ? 'Corrente' : 'Conta'),
                balance: Number(a.current_balance ?? a.saldo_atual ?? a.saldo ?? 0),
                color: a.color ?? a.cor ?? '#14B8A6',
                icon: a.icon ?? a.icone ?? (type === 'wallet' ? 'wallet' : 'bank'),
                hasData: Boolean(a.has_data ?? true),
                balanceKind: String(a.balance_kind ?? ''),
                institution,
                svgPath: svgPath ?? getBankSvgPath(logoName),
            };
        });
});

const creditCards = computed(() => {
    const monthKey = selectedMonthKey.value;
    const cardsKey = `cards-${monthKey}`;

    // If loading or no data available yet, return empty array
    if (!monthKey || isLoadingMonth.value.get(monthKey)) {
        return [];
    }

    const hasMonthData = accountsDataByMonth.value.has(cardsKey);
    if (!hasMonthData) {
        return [];
    }

    const monthData = accountsDataByMonth.value.get(cardsKey) ?? [];

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
            const canDisambiguate = hasBrandDiff || hasDueDiff || hasClosingDiff;
            const displayName = canDisambiguate ? card.name : `${card.name} (${index + 1})`;
            result.push({ ...card, displayName });
        });
    }

    const indexById = new Map(creditCards.value.map((c, idx) => [String(c.id), idx]));
    return result.sort((a, b) => (indexById.get(String(a.id)) ?? 0) - (indexById.get(String(b.id)) ?? 0));
});

const totalBankBalance = computed(() => bankAccounts.value.reduce((sum, a) => sum + a.balance, 0));
const balancoMensal = computed(() => {
    const key = selectedMonthKey.value;
    if (!key) return 0;
    return balanceNetByMonth.value.get(key) ?? 0;
});

const saldoTitle = computed(() => (selectedMonthMode.value === 'past' ? 'Final do mês' : selectedMonthMode.value === 'future' ? 'Saldo previsto' : 'Saldo atual'));

const selectedMonthMode = computed(() => {
    const key = selectedMonthKey.value;
    if (!key) return '';
    return String(accountsModeByMonth.value.get(key) ?? '');
});

const isLoading = computed(() => {
    const monthKey = selectedMonthKey.value;
    if (!monthKey) return false;
    return isLoadingMonth.value.get(monthKey) ?? false;
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
             <!-- Desktop actions already in sidebar or implied -->
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

            <div class="flex items-center gap-2">
                <button
                    type="button"
                    class="flex h-10 w-10 items-center justify-center rounded-2xl bg-white text-slate-600 shadow-sm ring-1 ring-slate-200/60"
                    aria-label="Transferência"
                    @click="openQuickTransfer"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M4 8h11" />
                        <path d="M12 5l3 3-3 3" />
                        <path d="M20 16H9" />
                        <path d="M12 13l-3 3 3 3" />
                    </svg>
                </button>

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
                                class="w-full text-left rounded-t-2xl border-b border-slate-100 px-4 py-3 text-sm font-semibold text-slate-900 hover:bg-slate-50"
                                @click="openAccountMenuOption('bank')"
                            >
                                Adicionar Conta Bancária
                            </button>
                            <button
                                type="button"
                                class="w-full text-left rounded-b-2xl px-4 py-3 text-sm font-semibold text-slate-900 hover:bg-slate-50"
                                @click="openAccountMenuOption('wallet')"
                            >
                                Criar Carteira
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </header>

        <div :class="[isMobile ? 'mt-6' : 'mt-8 grid grid-cols-1 lg:grid-cols-12 gap-8 items-start']">
            
            <!-- Left Column: Accounts List -->
            <div :class="[isMobile ? '' : 'lg:col-span-8']">
                <div v-if="!isMobile" class="mb-6 flex items-center justify-between">
                     <h2 class="text-xl font-bold text-slate-900">Contas e Carteiras</h2>
                     <MonthNavigator v-model="selectedMonthKey" :months="monthItems" />
                </div>
                
                <div v-if="isMobile" class="mb-6">
                    <MonthNavigator v-model="selectedMonthKey" :months="monthItems" />
                </div>

                <div v-if="isLoading" class="mt-4" :class="[isMobile ? 'space-y-3' : 'grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3']">
                    <div v-for="i in 3" :key="i" class="flex items-center justify-between rounded-3xl bg-white px-4 py-4 shadow-sm ring-1 ring-slate-200/60">
                        <div class="flex items-center gap-3">
                            <div class="h-12 w-12 animate-pulse rounded-2xl bg-slate-200"></div>
                            <div>
                                <div class="h-4 w-32 animate-pulse rounded bg-slate-200"></div>
                                <div class="mt-1 h-3 w-24 animate-pulse rounded bg-slate-100"></div>
                            </div>
                        </div>
                        <div class="h-4 w-20 animate-pulse rounded bg-slate-200"></div>
                    </div>
                </div>

                <div v-else class="mt-4" :class="[isMobile ? 'space-y-3' : 'grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3']">
                    <Link
                        v-for="account in bankAccounts"
                        :key="account.id"
                        :href="route('accounts.show', { accountKey: account.id })"
                        class="flex items-center justify-between rounded-3xl bg-white px-4 py-4 shadow-sm ring-1 ring-slate-200/60 transition hover:shadow-md hover:ring-slate-300"
                    >
                        <div class="flex items-center gap-3">
                                <InstitutionAvatar
                                    :institution="account.institution ?? account.name"
                                    :svg-path="account.svgPath"
                                    :is-wallet="account.icon === 'wallet'"
                                    :fallback-icon="account.icon === 'wallet' ? 'wallet' : 'account'"
                                    container-class="flex h-12 w-12 items-center justify-center overflow-hidden rounded-2xl bg-white"
                                    img-class="h-10 w-10 object-contain"
                                :fallback-bg-class="'rounded-2xl text-white'"
                                :fallback-icon-class="'h-5 w-5'"
                                :style="account.svgPath ? undefined : { backgroundColor: account.color }"
                            />
                            <div>
                                <div class="text-sm font-bold text-slate-900">{{ account.name }}</div>
                                <div class="flex flex-wrap items-center gap-1 text-[11px] font-semibold uppercase tracking-wide text-slate-400">
                                    <span>{{ account.subtitle }}</span>
                                    <span v-if="selectedMonthMode === 'past' && account.hasData === false">(SEM DADOS)</span>
                                    <span v-if="selectedMonthMode === 'future'">(PROJEÇÃO)</span>
                                </div>
                            </div>
                        </div>
                        <div class="text-sm font-bold text-slate-900">{{ formatBRL(account.balance) }}</div>
                    </Link>
                </div>
            </div>

            <!-- Right Column: Summary & Actions -->
            <div :class="[isMobile ? 'order-first mb-8' : 'lg:col-span-4 lg:sticky lg:top-24 space-y-6']">
                
                <!-- Saldo Card -->
                <div class="rounded-3xl bg-[#0F172A] p-6 shadow-xl text-white">
                    <div class="flex items-start justify-between mb-2">
                        <div class="text-[10px] font-bold uppercase tracking-wider text-slate-400">
                            Saldo consolidado
                        </div>
                         <div class="flex h-6 w-6 items-center justify-center rounded-full bg-white/10">
                            <svg class="h-3 w-3 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">
                                <path d="M12 6v12m-6-6h12"/>
                            </svg>
                        </div>
                    </div>

                    <div v-if="isLoading" class="h-10 w-48 animate-pulse rounded-lg bg-white/10 my-2"></div>
                    <div v-else class="text-3xl font-bold tracking-tight">
                        {{ formatBRL(totalBankBalance) }}
                    </div>

                     <div v-if="!isLoading" class="mt-6 pt-6 border-t border-white/10 grid grid-cols-2 gap-4">
                        <div>
                            <div class="text-[10px] font-bold uppercase tracking-wide text-slate-400 mb-1">
                                {{ saldoTitle }}
                            </div>
                             <div class="text-lg font-bold">
                                {{ formatBRL(totalBankBalance) }}
                            </div>
                        </div>
                        <div>
                            <div class="text-[10px] font-bold uppercase tracking-wide text-slate-400 mb-1">
                                Balanço
                            </div>
                             <div class="text-lg font-bold" :class="balancoMensal >= 0 ? 'text-emerald-400' : 'text-red-400'">
                                {{ balancoMensal >= 0 ? '+' : '-' }} {{ formatBRL(Math.abs(balancoMensal)).replace('R$', '') }}
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Quick Actions (Desktop Only visible as buttons below) -->
                <div v-if="!isMobile" class="rounded-3xl bg-white p-6 shadow-sm ring-1 ring-slate-200/60">
                    <h3 class="text-base font-bold text-slate-900 mb-4">Ações Rápidas</h3>
                    <div class="space-y-3">
                         <button @click="openQuickTransfer" class="flex w-full items-center justify-between rounded-2xl bg-slate-50 px-4 py-3 text-sm font-semibold text-slate-700 hover:bg-slate-100 transition">
                             <span>Transferir valores</span>
                             <svg class="h-5 w-5 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 9l4 4m0 0l-4 4m4-4H3"/></svg>
                         </button>
                         <button @click="openAccountMenuOption('bank')" class="flex w-full items-center justify-between rounded-2xl bg-slate-50 px-4 py-3 text-sm font-semibold text-slate-700 hover:bg-slate-100 transition">
                             <span>Adicionar conta</span>
                             <svg class="h-5 w-5 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 5v14m-7-7h14"/></svg>
                         </button>
                          <button @click="openAccountMenuOption('wallet')" class="flex w-full items-center justify-between rounded-2xl bg-slate-50 px-4 py-3 text-sm font-semibold text-slate-700 hover:bg-slate-100 transition">
                             <span>Criar carteira manual</span>
                             <svg class="h-5 w-5 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 12V8H6a2 2 0 0 1-2-2c0-1.1.9-2 2-2h12v4"/></svg>
                         </button>
                    </div>
                </div>

            </div>
        </div>

        <MobileToast :show="toastOpen" :message="toastMessage" @dismiss="toastOpen = false" />
        <CreateAccountFlowModal :open="createAccountOpen" :start-with-wallet="createAccountWithWallet" @close="() => { createAccountOpen = false; createAccountWithWallet = false; }" @toast="showToast" />
        <CreateCreditCardFlowModal :open="createCreditCardFlowOpen" @close="createCreditCardFlowOpen = false" @save="handleCreateCreditCardFlowSave" />
        <CreditCardModal :open="creditCardModalOpen" @close="creditCardModalOpen = false" @save="saveCreditCard" />
        <TransactionModal
            :open="transactionOpen"
            :kind="transactionKind"
            :initial="transactionInitial"
            :categories="pickerCategories"
            :accounts="pickerAccounts"
            :tags="bootstrap.tags"
            @close="transactionOpen = false"
            @save="onTransactionSave"
        />
    </component>
</template>
