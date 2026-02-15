<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import { Head, Link, router, usePage } from '@inertiajs/vue3';
import type { BootstrapData, Entry } from '@/types/kitamo';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import MobileToast from '@/Components/MobileToast.vue';
import ConfirmationModal from '@/Components/ConfirmationModal.vue';
import NewAccountModal from '@/Components/NewAccountModal.vue';
import WalletEditModal from '@/Components/WalletEditModal.vue';
import MonthNavigator from '@/Components/MonthNavigator.vue';
import { requestJson } from '@/lib/kitamoApi';
import InstitutionAvatar from '@/Components/InstitutionAvatar.vue';
import { getBankSvgPath } from '@/lib/bankLogos';
import { useIsMobile } from '@/composables/useIsMobile';

type AccountType = 'wallet' | 'bank' | 'card';

const props = defineProps<{
    accountKey: string;
}>();

const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const page = usePage();
const bootstrap = computed(
    () => (page.props.bootstrap ?? { entries: [], goals: [], accounts: [], categories: [], tags: [] }) as BootstrapData,
);

const account = computed(() => bootstrap.value.accounts.find((item) => item.id === props.accountKey));
const accountName = computed(() => account.value?.name ?? 'Conta');
const institution = computed(() => (account.value as any)?.institution ?? null);
const svgPath = computed(() => ((account.value as any)?.svgPath ?? getBankSvgPath(institution.value ?? accountName.value ?? null)) as string | null);
const isWallet = computed(() => account.value?.type === 'wallet' || account.value?.icon === 'wallet');

const shellProps = computed(() =>
    isMobile.value
        ? { showNav: false }
        : {
              title: accountName.value,
              subtitle: 'Detalhes da conta',
              showSearch: false,
              showNewAction: false,
              headerActions: null, // Custom header actions in template if needed
          },
);


const balancesByMonth = ref<Map<string, number>>(new Map());
const modeByMonth = ref<Map<string, string>>(new Map());
const isLoadingMonth = ref<Map<string, boolean>>(new Map());

const loadBalanceForMonth = async (monthKey: string) => {
    if (!monthKey) return;

    // Clear previous data for this month to avoid showing stale data
    balancesByMonth.value.delete(monthKey);
    modeByMonth.value.delete(monthKey);

    // Mark as loading
    isLoadingMonth.value.set(monthKey, true);

    try {
        const [year, month] = monthKey.split('-').map(Number);
        const response = await requestJson<{ accounts?: any[]; contas?: any[]; mode?: string }>(`/api/contas-by-month?year=${year}&month=${month}`, {
            method: 'GET',
        });
        const list = (response as any)?.accounts ?? (response as any)?.contas ?? [];
        const row = Array.isArray(list) ? list.find((a: any) => String(a.id) === String(props.accountKey)) : null;
        const value = Number(row?.current_balance ?? row?.saldo_atual ?? row?.saldo ?? 0);
        balancesByMonth.value.set(monthKey, Number.isFinite(value) ? value : 0);
        if ((response as any)?.mode) modeByMonth.value.set(monthKey, String((response as any).mode));
    } catch (error) {
        console.error('Failed to load balance for month', error);
        // Set to 0 on error to prevent showing bootstrap data
        balancesByMonth.value.set(monthKey, 0);
    } finally {
        // Mark as loaded
        isLoadingMonth.value.set(monthKey, false);
    }
};
const entries = computed(() => bootstrap.value.entries ?? []);

const formatMoney = (value: number) =>
    new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL',
    }).format(value);

const months = computed(() => {
    const now = new Date();
    const items: Array<{ key: string; label: string; date: Date }> = [];
    for (let i = -120; i <= 120; i += 1) {
        const d = new Date(now.getFullYear(), now.getMonth() + i, 1);
        const label = new Intl.DateTimeFormat('pt-BR', { month: 'short' }).format(d).replace('.', '').toUpperCase();
        items.push({ key: `${d.getFullYear()}-${d.getMonth()}`, label, date: d });
    }
    return items;
});

const currentMonthKey = `${new Date().getFullYear()}-${new Date().getMonth()}`;
const selectedMonthKey = ref(months.value.find((m) => m.key === currentMonthKey)?.key ?? months.value[0]?.key ?? '');
const selectedMonth = computed(() => months.value.find((m) => m.key === selectedMonthKey.value) ?? months.value[0]);

watch(
    selectedMonthKey,
    (key) => {
        void loadBalanceForMonth(key);
    },
    { immediate: true },
);

const balance = computed(() => {
    const monthKey = selectedMonthKey.value;
    if (isLoadingMonth.value.get(monthKey)) return null;
    if (balancesByMonth.value.has(monthKey)) return balancesByMonth.value.get(monthKey) ?? 0;
    return null;
});

const isLoading = computed(() => {
    const monthKey = selectedMonthKey.value;
    if (!monthKey) return false;
    return isLoadingMonth.value.get(monthKey) ?? false;
});

const entriesForAccount = computed(() => {
    const name = accountName.value;
    if (!name) return [];
    return (entries.value ?? []).filter((e) => e.accountLabel === name);
});

const entriesForMonth = computed(() => {
    const month = selectedMonth.value?.date?.getMonth();
    const year = selectedMonth.value?.date?.getFullYear();
    if (month == null || year == null) return [];
    const filtered = entriesForAccount.value.filter((e) => {
        if (!e.transactionDate) return true;
        const d = new Date(e.transactionDate);
        return d.getMonth() === month && d.getFullYear() === year;
    });
    // Sort in descending order (most recent first)
    return filtered.sort((a, b) => {
        const dateA = a.transactionDate ? new Date(a.transactionDate).getTime() : 0;
        const dateB = b.transactionDate ? new Date(b.transactionDate).getTime() : 0;
        return dateB - dateA;
    });
});

const monthIncome = computed(() =>
    entriesForMonth.value.filter((e) => e.kind === 'income').reduce((sum, e) => sum + (Number(e.amount) || 0), 0),
);
const monthExpense = computed(() =>
    entriesForMonth.value.filter((e) => e.kind === 'expense').reduce((sum, e) => sum + (Number(e.amount) || 0), 0),
);

const isCurrentMonth = computed(() => {
    const now = new Date();
    const selected = selectedMonth.value?.date;
    if (!selected) return true;
    return selected.getMonth() === now.getMonth() && selected.getFullYear() === now.getFullYear();
});

const monthStartBalance = computed(() => {
    if (!account.value) return 0;
    const currentBalance = balance.value ?? 0;
    return currentBalance - (monthIncome.value - monthExpense.value);
});

const monthEndBalance = computed(() => {
    return monthStartBalance.value + monthIncome.value - monthExpense.value;
});

const hasNegativeBalance = computed(() => {
    if (account.value?.type !== 'wallet') return false;
    if (!isCurrentMonth.value) return false;
    return monthExpense.value > monthIncome.value;
});

const grouped = computed(() => {
    const groups = new Map<string, Entry[]>();
    for (const entry of entriesForMonth.value) {
        const key = entry.dateLabel ?? 'SEM DATA';
        const list = groups.get(key) ?? [];
        list.push(entry);
        groups.set(key, list);
    }
    return Array.from(groups.entries()).map(([dateLabel, list]) => ({ dateLabel, list }));
});


const toastOpen = ref(false);
const toastMessage = ref('');
const showToast = (message: string) => {
    toastMessage.value = message;
    toastOpen.value = true;
};

const actionsOpen = ref(false);
const editOpen = ref(false);
const walletEditOpen = ref(false);
const deleteOpen = ref(false);

const editInitial = computed(() => {
    if (!account.value) return null;
    if (account.value.type !== 'bank') return null;
    return {
        id: String(account.value.id),
        name: account.value.name,
        icon: account.value.icon ?? 'bank',
        current_balance: Number(account.value.current_balance ?? 0),
        color: account.value.color ?? '#14B8A6',
        incluir_soma: account.value.incluir_soma ?? true,
        institution: (account.value as any).institution ?? null,
        bank_account_type: (account.value as any).bank_account_type ?? null,
    };
});

const deleteMessage = computed(() => `Tem certeza que deseja excluir a conta "${accountName.value}"?`);
const deleteWarningText = 'Isso irá excluir também todas as transações vinculadas a esta conta. Esta ação não pode ser desfeita.';

const saveAccountEdit = async (payload: {
    id: string;
    name: string;
    icon: string;
    current_balance: number;
    color: string;
    incluir_soma: boolean;
    institution: string | null;
    bank_account_type: string;
}) => {
    if (!payload.id) return;
    try {
        await requestJson(`/api/contas/${payload.id}`, {
            method: 'PATCH',
            body: JSON.stringify({
                name: payload.name,
                icon: payload.icon,
                type: 'bank',
                current_balance: payload.current_balance,
                color: payload.color,
                incluir_soma: payload.incluir_soma,
                institution: payload.institution,
                bank_account_type: payload.bank_account_type,
            }),
        });
        showToast('Conta atualizada');
        editOpen.value = false;
        router.reload();
    } catch {
        showToast('Não foi possível atualizar a conta');
    }
};

const confirmDelete = async () => {
    if (!account.value) return;
    try {
        await requestJson(`/api/contas/${account.value.id}`, { method: 'DELETE' });
        showToast('Conta excluída');
        router.visit(route('accounts.index'));
    } catch {
        showToast('Não foi possível excluir a conta');
    } finally {
        deleteOpen.value = false;
    }
};

const transactionModalOpen = ref(false);
const transactionModalKind = ref<'income' | 'expense' | 'transfer'>('income');
const transactionModalInitial = ref<{ account: string } | null>(null);

const handleAddMoney = () => {
    transactionModalKind.value = 'income';
    transactionModalInitial.value = { account: accountName.value };
    transactionModalOpen.value = true;
};

const handleCreateTransfer = () => {
    transactionModalKind.value = 'transfer';
    transactionModalInitial.value = { account: accountName.value };
    transactionModalOpen.value = true;
};

const saveWalletEdit = async (payload: { id: string; name: string; initial_balance: number; color: string; incluir_soma?: boolean }) => {
    try {
        const body: any = {
            name: payload.name,
            type: 'wallet',
            icon: 'wallet',
            initial_balance: payload.initial_balance,
            color: payload.color,
        };
        if (payload.incluir_soma !== undefined) {
            body.incluir_soma = payload.incluir_soma;
        }
        await requestJson(`/api/contas/${payload.id}`, {
            method: 'PATCH',
            body: JSON.stringify(body),
        });
        showToast('Carteira atualizada');
        walletEditOpen.value = false;
        router.reload();
    } catch {
        showToast('Não foi possível atualizar a carteira');
    }
};
</script>


<template>
    <Head :title="accountName" />

    <component :is="Shell" v-bind="shellProps">
        <!-- Actions Button Only for Desktop via Slot, or Main Content -->
        <template v-if="!isMobile" #headerActions>
             <div class="flex items-center gap-2">
                 <button
                    type="button"
                    class="rounded-xl border border-slate-200 bg-white px-3 py-1.5 text-xs font-bold text-slate-600 hover:bg-slate-50 transition"
                    @click="account?.type === 'wallet' ? (walletEditOpen = true) : (editOpen = true)"
                >
                    Editar
                </button>
                 <button
                    type="button"
                    class="rounded-xl border border-red-100 bg-red-50 px-3 py-1.5 text-xs font-bold text-red-600 hover:bg-red-100 transition"
                    @click="deleteOpen = true"
                >
                    Excluir
                </button>
             </div>
        </template>

        <!-- Header Mobile (Back+Title+Actions) -->
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
                <div v-if="account?.type !== 'wallet'" class="text-[11px] font-bold uppercase tracking-wide text-slate-400">Conta</div>
                <div v-else class="text-[11px] font-bold uppercase tracking-wide text-slate-400">Carteira</div>
                <div class="mt-1 flex items-center justify-center gap-2">
                    <InstitutionAvatar
                        :institution="institution ?? accountName"
                        :svg-path="svgPath"
                        :is-wallet="isWallet"
                        :fallback-icon="isWallet ? 'wallet' : 'account'"
                        container-class="flex h-9 w-9 items-center justify-center overflow-hidden rounded-2xl bg-white ring-1 ring-slate-200/60"
                        img-class="h-6 w-6 object-contain"
                        fallback-icon-class="h-5 w-5 text-slate-500"
                    />
                    <div class="text-lg font-semibold text-slate-900">{{ accountName }}</div>
                </div>
            </div>

            <div class="relative">
                <button
                    type="button"
                    class="flex h-10 w-10 items-center justify-center rounded-2xl bg-white text-slate-600 shadow-sm ring-1 ring-slate-200/60"
                    aria-label="Ações"
                    @click="actionsOpen = !actionsOpen"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M12 20a1 1 0 1 0 0-2 1 1 0 0 0 0 2Z" />
                        <path d="M12 13a1 1 0 1 0 0-2 1 1 0 0 0 0 2Z" />
                        <path d="M12 6a1 1 0 1 0 0-2 1 1 0 0 0 0 2Z" />
                    </svg>
                </button>

                <div v-if="actionsOpen" class="fixed inset-0 z-[65]" @click="actionsOpen = false">
                    <div
                        class="absolute right-5 top-16 w-56 overflow-hidden rounded-2xl bg-white shadow-2xl ring-1 ring-slate-200/70"
                        @click.stop
                    >
                        <button
                            type="button"
                            class="flex w-full items-center gap-3 px-4 py-3 text-left text-sm font-semibold text-slate-700 hover:bg-slate-50"
                            @click="account?.type === 'wallet' ? (walletEditOpen = true, actionsOpen = false) : (editOpen = true, actionsOpen = false)"
                        >
                            <span class="flex h-9 w-9 items-center justify-center rounded-xl bg-slate-100 text-slate-600">
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M12 20h9" />
                                    <path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4Z" />
                                </svg>
                            </span>
                            {{ account?.type === 'wallet' ? 'Editar carteira' : 'Editar conta' }}
                        </button>
                        <button
                            type="button"
                            class="flex w-full items-center gap-3 px-4 py-3 text-left text-sm font-semibold text-red-600 hover:bg-red-50"
                            @click="deleteOpen = true; actionsOpen = false"
                        >
                            <span class="flex h-9 w-9 items-center justify-center rounded-xl bg-red-50 text-red-500">
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M3 6h18" />
                                    <path d="M8 6V4h8v2" />
                                    <path d="M6 6l1 16h10l1-16" />
                                </svg>
                            </span>
                            Excluir conta
                        </button>
                    </div>
                </div>
            </div>
        </header>

        <!-- Main Layout -->
         <div :class="[isMobile ? 'contents' : 'mt-8 grid grid-cols-1 lg:grid-cols-12 gap-8 items-start']">
             
            <!-- Left Column: Transactions List (Desktop main, Mobile flow) -->
            <div :class="[isMobile ? 'contents' : 'lg:col-span-8 lg:order-1']">
                 
                 <!-- Month Nav (In flow for both) -->
                <div class="mt-6">
                    <MonthNavigator v-model="selectedMonthKey" :months="months" />
                </div>

                <!-- Alert Negative Balance -->
                <div v-if="hasNegativeBalance" class="mt-6 rounded-lg border-l-4 border-amber-500 bg-amber-50 p-3">
                    <div class="flex items-start gap-2">
                        <div class="text-lg">⚠️</div>
                        <div class="flex-1">
                            <h3 class="text-sm font-semibold text-amber-900">
                                Você registrou mais gastos do que tinha na carteira
                            </h3>
                            <div class="mt-3 grid grid-cols-2 gap-3">
                                <button
                                    type="button"
                                    class="flex items-center justify-center rounded-lg bg-white px-3 py-2 text-center text-sm font-semibold text-amber-700 hover:bg-amber-100"
                                    @click="handleAddMoney"
                                >
                                    <span>Adicionar dinheiro</span>
                                </button>
                                <button
                                    type="button"
                                    class="flex items-center justify-center rounded-lg bg-white px-3 py-2 text-center text-sm font-semibold text-amber-700 hover:bg-amber-100"
                                    @click="handleCreateTransfer"
                                >
                                    <span>Criar transferência</span>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Transactions GROUPED List -->
                 <section class="mt-8 pb-[calc(2rem+env(safe-area-inset-bottom))]">
                    <div class="text-lg font-semibold text-slate-900 mb-4">Movimentações</div>
    
                    <div v-if="grouped.length === 0" class="rounded-3xl border border-dashed border-slate-200 bg-slate-50 px-5 py-10 text-center">
                        <div class="text-sm font-semibold text-slate-900">Sem lançamentos</div>
                        <div class="mt-1 text-xs text-slate-500">Quando houver movimentações, elas aparecem aqui.</div>
                    </div>
    
                    <div v-else class="space-y-4">
                        <div v-for="group in grouped" :key="group.dateLabel" class="overflow-hidden rounded-3xl bg-white shadow-sm ring-1 ring-slate-200/60">
                            <div class="bg-slate-50 px-5 py-2 text-xs font-bold uppercase tracking-wide text-slate-400 border-b border-slate-100">{{ group.dateLabel }}</div>
                            <div class="divide-y divide-slate-100">
                                <div v-for="entry in group.list" :key="entry.id" class="flex items-center justify-between gap-4 px-5 py-4 hover:bg-slate-50 transition cursor-default">
                                    <div class="min-w-0">
                                        <div class="truncate text-sm font-bold text-slate-900">{{ entry.title }}</div>
                                        <div class="mt-1 flex items-center gap-2">
                                            <span class="inline-flex rounded-md bg-slate-100 px-1.5 py-0.5 text-[10px] font-bold text-slate-500">{{ entry.categoryLabel }}</span>
                                        </div>
                                    </div>
                                    <div class="text-right">
                                        <div class="text-sm font-bold" :class="entry.kind === 'income' ? 'text-emerald-600' : 'text-red-500'">
                                            {{ entry.kind === 'income' ? '+' : '-' }} {{ formatMoney(Math.abs(entry.amount)) }}
                                        </div>
                                        <div v-if="entry.installment" class="mt-0.5 text-[10px] font-semibold text-slate-400">{{ entry.installment }}</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
            </div>

            <!-- Right Column: Summary Sidebar (Desktop) -->
            <div :class="[isMobile ? 'order-first' : 'lg:col-span-4 lg:order-2 lg:sticky lg:top-24 mt-6 lg:mt-0']">
                 <section class="rounded-3xl bg-white p-5 shadow-sm ring-1 ring-slate-200/60 transition hover:ring-slate-300/80">
                    <div class="flex items-center justify-between mb-4">
                        <div class="text-[11px] font-bold uppercase tracking-wide text-slate-400">
                            {{ isCurrentMonth ? 'Saldo atual' : 'Balanço final' }}
                        </div>
                        <InstitutionAvatar
                            v-if="!isMobile"
                            :institution="institution ?? accountName"
                            :svg-path="svgPath"
                            :is-wallet="isWallet"
                            :fallback-icon="isWallet ? 'wallet' : 'account'"
                            container-class="flex h-8 w-8 items-center justify-center overflow-hidden rounded-full bg-slate-50"
                            img-class="h-5 w-5 object-contain"
                            fallback-icon-class="h-4 w-4 text-slate-500"
                        />
                    </div>
                    
                    <div v-if="isLoading" class="mt-2 h-10 w-48 animate-pulse rounded-lg bg-slate-200"></div>
                    <div v-else class="mt-2 text-3xl font-bold tracking-tight text-slate-900">{{ formatMoney(balance ?? 0) }}</div>
                    
                    <div v-if="!isCurrentMonth && account?.type === 'wallet'" class="mt-2 text-xs text-slate-400">
                        (início: {{ selectedMonth?.date?.getDate() === 1 ? '01' : String(selectedMonth?.date?.getDate()).padStart(2, '0') }} - final: {{ new Date(selectedMonth?.date?.getFullYear() ?? 2024, (selectedMonth?.date?.getMonth() ?? 0) + 1, 0).getDate() }})
                    </div>

                    <div v-if="isLoading" class="mt-6 grid grid-cols-2 gap-3">
                         <div class="h-16 animate-pulse rounded-2xl bg-emerald-50"></div>
                         <div class="h-16 animate-pulse rounded-2xl bg-red-50"></div>
                    </div>

                    <div v-else class="mt-6 grid grid-cols-2 gap-3">
                        <div class="rounded-2xl bg-emerald-50 p-4 ring-1 ring-emerald-100 transition hover:bg-emerald-100/50">
                            <div class="flex items-center justify-between text-[10px] font-bold uppercase tracking-wide text-emerald-700 mb-1">
                                <span>Entrou</span>
                                <svg class="h-3 w-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><path d="M12 19V5"/><path d="M5 12l7-7 7 7"/></svg>
                            </div>
                            <div class="text-base font-bold text-emerald-700">{{ formatMoney(monthIncome) }}</div>
                        </div>
                        <div class="rounded-2xl bg-red-50 p-4 ring-1 ring-red-100 transition hover:bg-red-100/50">
                            <div class="flex items-center justify-between text-[10px] font-bold uppercase tracking-wide text-red-600 mb-1">
                                <span>Saiu</span>
                                <svg class="h-3 w-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><path d="M12 5v14"/><path d="M19 12l-7 7-7-7"/></svg>
                            </div>
                            <div class="text-base font-bold text-red-600">{{ formatMoney(monthExpense) }}</div>
                        </div>
                    </div>
                </section>
                
                 <!-- Desktop only Tip -->
                 <div v-if="!isMobile" class="mt-6 rounded-3xl bg-slate-50 p-6 border border-slate-100">
                     <p class="text-xs text-slate-500 leading-relaxed text-center">
                         O saldo exibido considera todas as transações (pagas e pendentes) desta conta até o final do mês selecionado.
                     </p>
                 </div>
            </div>
         </div>

        <MobileToast :show="toastOpen" :message="toastMessage" @dismiss="toastOpen = false" />
        <NewAccountModal :open="editOpen" :initial="editInitial" @close="editOpen = false" @save="saveAccountEdit" />
        <WalletEditModal
            :open="walletEditOpen"
            :wallet="account ? {
                id: account.id,
                name: account.name,
                initial_balance: account.initial_balance,
                current_balance: account.current_balance,
                color: account.color ?? '#14B8A6',
                incluir_soma: account.incluir_soma ?? true,
            } : null"
            @close="walletEditOpen = false"
            @save="saveWalletEdit"
        />
        <ConfirmationModal
            :open="deleteOpen"
            title="Excluir conta?"
            :message="deleteMessage"
            :warningText="deleteWarningText"
            danger
            confirmLabel="Excluir"
            @close="deleteOpen = false"
            @confirm="confirmDelete"
        />
    </component>
</template>
