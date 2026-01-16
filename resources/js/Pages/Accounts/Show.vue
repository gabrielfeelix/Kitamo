<script setup lang="ts">
	import { computed, ref } from 'vue';
	import { Head, Link, router, usePage } from '@inertiajs/vue3';
	import type { BootstrapData, Entry } from '@/types/kitamo';
	import MobileShell from '@/Layouts/MobileShell.vue';
	import KitamoLayout from '@/Layouts/KitamoLayout.vue';
import MobileToast from '@/Components/MobileToast.vue';
import ConfirmationModal from '@/Components/ConfirmationModal.vue';
import NewAccountModal from '@/Components/NewAccountModal.vue';
import { requestJson } from '@/lib/kitamoApi';
import { useIsMobile } from '@/composables/useIsMobile';

type AccountType = 'wallet' | 'bank' | 'card';

const props = defineProps<{
    accountKey: string;
}>();

const isMobile = useIsMobile();
const page = usePage();
const bootstrap = computed(
    () => (page.props.bootstrap ?? { entries: [], goals: [], accounts: [], categories: [] }) as BootstrapData,
);

const account = computed(() => bootstrap.value.accounts.find((item) => item.id === props.accountKey));
const accountName = computed(() => account.value?.name ?? 'Conta');
const balance = computed(() => account.value?.current_balance ?? 0);
const entries = computed(() => bootstrap.value.entries ?? []);

	const formatMoney = (value: number) =>
	    new Intl.NumberFormat('pt-BR', {
	        style: 'currency',
	        currency: 'BRL',
	    }).format(value);

    const months = computed(() => {
        const now = new Date();
        const items: Array<{ key: string; label: string; date: Date }> = [];
        for (let i = 2; i >= -3; i -= 1) {
            const d = new Date(now.getFullYear(), now.getMonth() + i, 1);
            const label = new Intl.DateTimeFormat('pt-BR', { month: 'short' })
                .format(d)
                .replace('.', '')
                .toUpperCase();
            items.push({ key: `${d.getFullYear()}-${d.getMonth()}`, label, date: d });
        }
        return items;
    });

    const selectedMonthKey = ref(
        months.value.find((m) => m.date.getMonth() === new Date().getMonth())?.key ?? months.value[0]?.key ?? '',
    );
    const selectedMonth = computed(() => months.value.find((m) => m.key === selectedMonthKey.value) ?? months.value[0]);

    const entriesForAccount = computed(() => {
        const name = accountName.value;
        if (!name) return [];
        return (entries.value ?? []).filter((e) => e.accountLabel === name);
    });

    const entriesForMonth = computed(() => {
        const month = selectedMonth.value?.date?.getMonth();
        const year = selectedMonth.value?.date?.getFullYear();
        if (month == null || year == null) return [];
        return entriesForAccount.value.filter((e) => {
            if (!e.transactionDate) return true;
            const d = new Date(e.transactionDate);
            return d.getMonth() === month && d.getFullYear() === year;
        });
    });

    const monthIncome = computed(() =>
        entriesForMonth.value.filter((e) => e.kind === 'income').reduce((sum, e) => sum + (Number(e.amount) || 0), 0),
    );
    const monthExpense = computed(() =>
        entriesForMonth.value.filter((e) => e.kind === 'expense').reduce((sum, e) => sum + (Number(e.amount) || 0), 0),
    );

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
	const deleteOpen = ref(false);

	const editInitial = computed(() => {
	    if (!account.value) return null;
	    const mappedType: AccountType = account.value.type === 'bank' ? 'bank' : account.value.type === 'wallet' ? 'wallet' : 'card';
	    return {
	        id: String(account.value.id),
	        name: account.value.name,
	        type: mappedType,
	        icon: account.value.icon ?? 'wallet',
	    };
	});

	const deleteMessage = computed(() => `Tem certeza que deseja excluir a conta "${accountName.value}"?`);
	const deleteWarningText = 'Isso irá excluir também todas as transações vinculadas a esta conta. Esta ação não pode ser desfeita.';

	const saveAccountEdit = async (payload: { id?: string; name: string; type: 'wallet' | 'bank' | 'card'; initialBalance: string; icon: string }) => {
	    if (!payload.id) return;
	    try {
	        await requestJson(`/api/contas/${payload.id}`, {
	            method: 'PATCH',
	            body: JSON.stringify({
	                name: payload.name,
	                type: payload.type,
	                icon: payload.icon,
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
                        <div class="text-[11px] font-bold uppercase tracking-wide text-slate-400">Conta</div>
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
                                    @click="editOpen = true; actionsOpen = false"
                                >
                                    <span class="flex h-9 w-9 items-center justify-center rounded-xl bg-slate-100 text-slate-600">
                                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M12 20h9" />
                                            <path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4Z" />
                                        </svg>
                                    </span>
                                    Editar conta
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
    
                <section class="mt-6 rounded-3xl bg-white p-5 shadow-sm ring-1 ring-slate-200/60">
                    <div class="text-[11px] font-bold uppercase tracking-wide text-slate-400">Saldo atual</div>
                    <div class="mt-2 text-3xl font-bold tracking-tight text-slate-900">{{ formatMoney(balance) }}</div>
    
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

	    <KitamoLayout v-else :title="accountName" subtitle="Detalhes da conta">
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
	    </KitamoLayout>
</template>
