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
import { requestJson } from '@/lib/kitamoApi';
import { useIsMobile } from '@/composables/useIsMobile';

type AccountType = 'wallet' | 'bank' | 'card';

const props = defineProps<{
    accountKey: string;
}>();

const isMobile = useIsMobile();
const page = usePage();
const bootstrap = computed(
    () => (page.props.bootstrap ?? { entries: [], goals: [], accounts: [], categories: [], tags: [] }) as BootstrapData,
);

const account = computed(() => bootstrap.value.accounts.find((item) => item.id === props.accountKey));
const accountName = computed(() => account.value?.name ?? 'Conta');
const balancesByMonth = ref<Map<string, number>>(new Map());
const modeByMonth = ref<Map<string, string>>(new Map());

const loadBalanceForMonth = async (monthKey: string) => {
    if (!monthKey) return;
    if (balancesByMonth.value.has(monthKey)) return;
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
    } catch {
        // fallback: usa saldo do bootstrap
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

        // Se for carteira, mostra apenas meses passados + atual
        if (account.value?.type === 'wallet') {
            // Começar de 5 meses atrás até o mês atual
            for (let i = 5; i >= 0; i -= 1) {
                const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
                const label = new Intl.DateTimeFormat('pt-BR', { month: 'short' })
                    .format(d)
                    .replace('.', '')
                    .toUpperCase();
                items.push({ key: `${d.getFullYear()}-${d.getMonth()}`, label, date: d });
            }
        } else {
            // Bancos e cartões mantêm lógica original (2 passados + atual + 3 futuros)
            for (let i = 2; i >= -3; i -= 1) {
                const d = new Date(now.getFullYear(), now.getMonth() + i, 1);
                const label = new Intl.DateTimeFormat('pt-BR', { month: 'short' })
                    .format(d)
                    .replace('.', '')
                    .toUpperCase();
                items.push({ key: `${d.getFullYear()}-${d.getMonth()}`, label, date: d });
            }
        }
        return items;
    });

    const selectedMonthKey = ref(
        months.value.find((m) => m.date.getMonth() === new Date().getMonth())?.key ?? months.value[0]?.key ?? '',
    );
    const selectedMonth = computed(() => months.value.find((m) => m.key === selectedMonthKey.value) ?? months.value[0]);

watch(
    selectedMonthKey,
    (key) => {
        void loadBalanceForMonth(key);
    },
    { immediate: true },
);

const balance = computed(() => balancesByMonth.value.get(selectedMonthKey.value) ?? account.value?.current_balance ?? 0);

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
        const currentBalance = balance.value;
        // Balanço final = saldo atual
        // Balanço inicial = saldo atual - (entradas - saídas do mês)
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

    const formatDayLabel = (entry: Entry) => {
        const date = entry.transactionDate ? new Date(entry.transactionDate) : new Date();
        const day = String(date.getDate()).padStart(2, '0');
        const month = date.toLocaleString('pt-BR', { month: 'short' }).replace('.', '').toUpperCase();
        return `${day} ${month}`;
    };

    const transactions = computed(() =>
        entriesForAccount.value.map((entry) => ({
            id: entry.id,
            day: formatDayLabel(entry),
            title: entry.title,
            amount: entry.amount,
            kind: entry.kind,
        })),
    );

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

		    <MobileShell v-if="isMobile" :show-nav="false">
                <header class="flex items-center justify-between pt-2">
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
	                        <div class="text-lg font-semibold text-slate-900">{{ accountName }}</div>
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
    
                <div class="mt-6">
                    <div class="flex gap-4 overflow-x-auto pb-2 text-xs font-bold text-slate-300">
                        <button
                            v-for="m in months"
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

                <!-- Alerta de saldo negativo (apenas para carteiras no mês atual) -->
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
    
                <section class="mt-6 rounded-3xl bg-white p-5 shadow-sm ring-1 ring-slate-200/60">
                    <div class="text-[11px] font-bold uppercase tracking-wide text-slate-400">
                        {{ isCurrentMonth ? 'Saldo atual' : 'Balanço final' }}
                    </div>
                    <div class="mt-2 text-3xl font-bold tracking-tight text-slate-900">{{ formatMoney(balance) }}</div>
                    <div v-if="!isCurrentMonth && account?.type === 'wallet'" class="mt-2 text-xs text-slate-400">
                        (início: {{ selectedMonth?.date?.getDate() === 1 ? '01' : String(selectedMonth?.date?.getDate()).padStart(2, '0') }} - final: {{ new Date(selectedMonth?.date?.getFullYear() ?? 2024, (selectedMonth?.date?.getMonth() ?? 0) + 1, 0).getDate() }})
                    </div>
    
                    <div class="mt-5 grid grid-cols-2 gap-3">
                        <div class="rounded-2xl bg-emerald-50 p-4 ring-1 ring-emerald-100">
                            <div class="flex items-center justify-between text-[10px] font-semibold uppercase tracking-wide text-emerald-700">
                                <span>Entrou</span>
                                <span>›</span>
                            </div>
                            <div class="mt-1 text-base font-semibold text-emerald-700">{{ formatMoney(monthIncome) }}</div>
                        </div>
                        <div class="rounded-2xl bg-red-50 p-4 ring-1 ring-red-100">
                            <div class="flex items-center justify-between text-[10px] font-semibold uppercase tracking-wide text-red-600">
                                <span>Saiu</span>
                                <span>›</span>
                            </div>
                            <div class="mt-1 text-base font-semibold text-red-600">{{ formatMoney(monthExpense) }}</div>
                        </div>
                    </div>
                </section>
    
                <section class="mt-8 pb-[calc(2rem+env(safe-area-inset-bottom))]">
                    <div class="text-lg font-semibold text-slate-900">Movimentações</div>
    
                    <div v-if="grouped.length === 0" class="mt-4 rounded-3xl border border-dashed border-slate-200 bg-slate-50 px-5 py-10 text-center">
                        <div class="text-sm font-semibold text-slate-900">Sem lançamentos</div>
                        <div class="mt-1 text-xs text-slate-500">Quando houver movimentações, elas aparecem aqui.</div>
                    </div>
    
                    <div v-else class="mt-4 space-y-4">
                        <div v-for="group in grouped" :key="group.dateLabel" class="rounded-3xl bg-white shadow-sm ring-1 ring-slate-200/60">
                            <div class="px-5 py-4 text-xs font-bold uppercase tracking-wide text-slate-400">{{ group.dateLabel }}</div>
                            <div class="divide-y divide-slate-100">
                                <div v-for="entry in group.list" :key="entry.id" class="flex items-center justify-between gap-4 px-5 py-4">
                                    <div class="min-w-0">
                                        <div class="truncate text-sm font-semibold text-slate-900">{{ entry.title }}</div>
                                        <div class="mt-1 text-xs font-semibold text-slate-400">{{ entry.categoryLabel }}</div>
                                    </div>
                                    <div class="text-right text-sm font-semibold" :class="entry.kind === 'income' ? 'text-emerald-600' : 'text-red-500'">
                                        {{ entry.kind === 'income' ? '+' : '-' }} {{ formatMoney(entry.amount) }}
                                        <div v-if="entry.installment" class="mt-1 text-[11px] font-semibold text-slate-400">{{ entry.installment }}</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
    
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
		    </MobileShell>

	    <DesktopShell v-else :title="accountName" subtitle="Detalhes da conta" :show-search="false" :show-new-action="false">
	        <div class="space-y-8">
	            <div class="flex items-center justify-between">
	                <Link
	                    :href="route('accounts.index')"
	                    class="inline-flex h-11 w-11 items-center justify-center rounded-full border border-slate-200 bg-white text-slate-600 shadow-sm hover:bg-slate-50"
	                    aria-label="Voltar"
	                >
	                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
	                        <path d="M15 18l-6-6 6-6" />
	                    </svg>
	                </Link>

	                <div class="flex items-center gap-3">
	                    <button
	                        type="button"
	                        class="inline-flex h-11 items-center gap-2 rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-600 hover:bg-slate-50"
	                        @click="editOpen = true"
	                    >
	                        Editar
	                    </button>
	                    <button
	                        type="button"
	                        class="inline-flex h-11 items-center gap-2 rounded-xl border border-red-200 bg-white px-4 text-sm font-semibold text-red-600 hover:bg-red-50"
	                        @click="deleteOpen = true"
	                    >
	                        Excluir
	                    </button>
	                </div>
	            </div>

	            <div class="grid gap-6 xl:grid-cols-[420px_1fr]">
	                <div class="rounded-2xl bg-white p-7 shadow-sm ring-1 ring-slate-200/60">
	                    <div class="text-xs font-semibold uppercase tracking-wide text-slate-400">Saldo atual</div>
	                    <div class="mt-3 text-3xl font-bold tracking-tight text-slate-900">
	                        {{ formatMoney(balance).replace('R$', 'R$') }}
	                    </div>
	                    <div class="mt-6 rounded-2xl bg-slate-50 p-4 text-sm font-semibold text-slate-600">
	                        Tipo: {{ account?.type ?? '-' }}
	                    </div>
	                </div>

	                <div class="rounded-2xl bg-white p-7 shadow-sm ring-1 ring-slate-200/60">
	                    <div class="flex items-center justify-between">
	                        <div class="text-base font-semibold text-slate-900">Transações desta conta</div>
	                        <Link :href="route('accounts.index')" class="text-sm font-semibold text-[#14B8A6]">Ver todas</Link>
	                    </div>

	                    <div v-if="transactions.length" class="mt-6 space-y-3">
	                        <div v-for="t in transactions" :key="t.id" class="flex items-center justify-between rounded-2xl border border-slate-100 bg-white px-5 py-4">
	                            <div class="min-w-0">
	                                <div class="truncate text-sm font-semibold text-slate-900">{{ t.title }}</div>
	                                <div class="mt-1 text-xs font-semibold text-slate-400">{{ t.day }}</div>
	                            </div>
	                            <div class="text-sm font-semibold" :class="t.kind === 'income' ? 'text-emerald-600' : 'text-red-500'">
	                                {{ t.kind === 'income' ? '+' : '-' }}{{ formatMoney(t.amount).replace('R$', 'R$') }}
	                            </div>
	                        </div>
	                    </div>
	                    <div v-else class="mt-6 rounded-2xl border border-dashed border-slate-200 bg-slate-50 px-6 py-10 text-center">
	                        <div class="text-sm font-semibold text-slate-900">Sem lançamentos</div>
	                        <div class="mt-1 text-xs text-slate-500">Adicione movimentações para ver o extrato.</div>
	                    </div>
	                </div>
	            </div>
	        </div>

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
	        <MobileToast :show="toastOpen" :message="toastMessage" @dismiss="toastOpen = false" />
	    </DesktopShell>
</template>
