<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, Link, router, usePage } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import KitamoLayout from '@/Layouts/KitamoLayout.vue';
import { useIsMobile } from '@/composables/useIsMobile';
import type { BootstrapData, Entry } from '@/types/kitamo';
import TransactionModal, { type TransactionModalPayload } from '@/Components/TransactionModal.vue';
import CreditCardModal, { type CreditCardModalPayload } from '@/Components/CreditCardModal.vue';
import ConfirmationModal from '@/Components/ConfirmationModal.vue';
import MobileToast from '@/Components/MobileToast.vue';
import InstallmentInvoiceSheet from '@/Components/InstallmentInvoiceSheet.vue';
import { requestJson } from '@/lib/kitamoApi';
import { buildTransactionRequest } from '@/lib/transactions';

const props = defineProps<{
    accountId: string;
}>();

const isMobile = useIsMobile();
const page = usePage();
const bootstrap = computed(
    () => (page.props.bootstrap ?? { entries: [], goals: [], accounts: [], categories: [] }) as BootstrapData,
);

const account = computed(() => bootstrap.value.accounts.find((a) => a.id === props.accountId) ?? null);
const accountName = computed(() => account.value?.name ?? 'Cartão de crédito');
const brand = computed(() => String((account.value as any)?.card_brand ?? 'visa'));
const brandLabel = computed(() => (brand.value === 'mastercard' ? 'Mastercard' : brand.value === 'elo' ? 'Elo' : brand.value === 'amex' ? 'Amex' : 'Visa'));
const cardColor = computed(() => String((account.value as any)?.color ?? '#8B5CF6'));
const limit = computed(() => Number(account.value?.credit_limit ?? 0));
const usedLimit = computed(() => Math.max(0, Number(account.value?.current_balance ?? 0)));
const availableLimit = computed(() => (limit.value ? Math.max(0, limit.value - usedLimit.value) : 0));
const closingDay = computed(() => Number(account.value?.closing_day ?? 0) || null);
const dueDay = computed(() => Number(account.value?.due_day ?? 0) || null);

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

const selectedMonthKey = ref(months.value.find((m) => m.date.getMonth() === new Date().getMonth())?.key ?? months.value[0]?.key ?? '');
const selectedMonth = computed(() => months.value.find((m) => m.key === selectedMonthKey.value) ?? months.value[0]);

const entriesForCard = computed(() => {
    const name = account.value?.name;
    if (!name) return [];
    return (bootstrap.value.entries ?? []).filter((e) => e.accountLabel === name);
});

const entriesForMonth = computed(() => {
    const month = selectedMonth.value?.date?.getMonth();
    const year = selectedMonth.value?.date?.getFullYear();
    if (month == null || year == null) return [];
    return entriesForCard.value.filter((e) => {
        if (!e.transactionDate) return true;
        const d = new Date(e.transactionDate);
        return d.getMonth() === month && d.getFullYear() === year;
    });
});

const currentInvoiceTotal = computed(() =>
    entriesForMonth.value
        .filter((e) => e.kind === 'expense')
        .reduce((sum, e) => sum + (Number(e.amount) || 0), 0),
);

const invoiceStatus = computed(() => {
    const now = new Date();
    if (!closingDay.value) return 'Aberta';
    return now.getDate() > closingDay.value ? 'Fechada' : 'Aberta';
});

const percentUsed = computed(() => (limit.value ? Math.min(100, Math.max(0, (usedLimit.value / limit.value) * 100)) : 0));
const percentLabel = computed(() => `${percentUsed.value.toFixed(2)}%`);

const dueDateLabel = computed(() => {
    if (!dueDay.value) return '';
    const now = new Date();
    const year = now.getFullYear();
    const month = now.getMonth();
    const targetMonth = now.getDate() <= dueDay.value ? month : month + 1;
    const lastDay = new Date(year, targetMonth + 1, 0).getDate();
    const day = Math.min(dueDay.value, lastDay);
    const d = new Date(year, targetMonth, day);
    const dd = String(d.getDate()).padStart(2, '0');
    const mon = new Intl.DateTimeFormat('pt-BR', { month: 'short' }).format(d).replace('.', '').toUpperCase();
    return `${dd} ${mon}`;
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

const formatBRL = (value: number) =>
    new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL', minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(value);

const actionsOpen = ref(false);
const transactionOpen = ref(false);
const transactionInitial = ref<TransactionModalPayload | null>(null);
const editOpen = ref(false);
const deleteOpen = ref(false);
const installmentOpen = ref(false);

const toastOpen = ref(false);
const toastMessage = ref('');
const showToast = (message: string) => {
    toastMessage.value = message;
    toastOpen.value = true;
};

const openAddTransaction = () => {
    actionsOpen.value = false;
    transactionInitial.value = {
        kind: 'expense',
        amount: 0,
        description: '',
        category: 'Alimentação',
        account: accountName.value,
        dateKind: 'today',
        dateOther: '',
        isInstallment: false,
        installmentCount: 1,
        isPaid: false,
        transferFrom: '',
        transferTo: '',
        transferDescription: '',
    };
    transactionOpen.value = true;
};

const openEditCard = () => {
    actionsOpen.value = false;
    editOpen.value = true;
};

const openDeleteCard = () => {
    actionsOpen.value = false;
    deleteOpen.value = true;
};

const editInitial = computed<CreditCardModalPayload | null>(() => {
    if (!account.value) return null;
    return {
        id: String(account.value.id),
        nome: account.value.name ?? 'Cartão',
        bandeira: (brand.value as any) ?? 'visa',
        limite: Number(account.value.credit_limit ?? 0),
        dia_fechamento: Number(account.value.closing_day ?? 10),
        dia_vencimento: Number(account.value.due_day ?? 17),
        cor: cardColor.value,
    };
});

const onTransactionSave = async (payload: TransactionModalPayload) => {
    try {
        const response = await requestJson<{ entry: Entry }>(route('transactions.store'), {
            method: 'POST',
            body: JSON.stringify(buildTransactionRequest(payload)),
        });
        showToast('Movimentação adicionada');
        router.reload({ only: ['bootstrap'] });
        return response;
    } catch {
        showToast('Não foi possível adicionar');
        return null;
    }
};

const onSaveCard = async (payload: CreditCardModalPayload) => {
    if (!payload.id) return;
    try {
        await requestJson(`/api/cartoes/${payload.id}`, {
            method: 'PATCH',
            body: JSON.stringify(payload),
        });
        showToast('Cartão atualizado');
        router.reload({ only: ['bootstrap'] });
    } catch {
        showToast('Não foi possível atualizar');
    }
};

const confirmDelete = async () => {
    if (!account.value) return;
    try {
        await requestJson(`/api/cartoes/${account.value.id}`, { method: 'DELETE' });
        showToast('Cartão excluído');
        router.visit(route('dashboard'));
    } catch {
        showToast('Não foi possível excluir');
    } finally {
        deleteOpen.value = false;
    }
};

const openInstallments = () => {
    installmentOpen.value = true;
};

const confirmInstallments = (_payload: { installments: number; interestRate: number; fee: number }) => {
    installmentOpen.value = false;
    showToast('Em breve: parcelamento de fatura');
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
                <div class="text-[11px] font-bold uppercase tracking-wide text-slate-400">Cartão de crédito</div>
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

                <div
                    v-if="actionsOpen"
                    class="absolute right-0 top-12 w-56 overflow-hidden rounded-2xl bg-white shadow-lg ring-1 ring-slate-200/70"
                >
                    <button type="button" class="flex w-full items-center gap-3 px-4 py-3 text-left text-sm font-semibold text-slate-700 hover:bg-slate-50" @click="openAddTransaction">
                        <span class="flex h-9 w-9 items-center justify-center rounded-xl bg-emerald-50 text-emerald-600">
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M12 5v14" />
                                <path d="M5 12h14" />
                            </svg>
                        </span>
                        Adicionar movimentação
                    </button>
                    <button type="button" class="flex w-full items-center gap-3 px-4 py-3 text-left text-sm font-semibold text-slate-700 hover:bg-slate-50" @click="openEditCard">
                        <span class="flex h-9 w-9 items-center justify-center rounded-xl bg-slate-100 text-slate-600">
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M12 20h9" />
                                <path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4Z" />
                            </svg>
                        </span>
                        Editar cartão
                    </button>
                    <button type="button" class="flex w-full items-center gap-3 px-4 py-3 text-left text-sm font-semibold text-red-600 hover:bg-red-50" @click="openDeleteCard">
                        <span class="flex h-9 w-9 items-center justify-center rounded-xl bg-red-50 text-red-500">
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M3 6h18" />
                                <path d="M8 6V4h8v2" />
                                <path d="M6 6l1 16h10l1-16" />
                            </svg>
                        </span>
                        Excluir cartão
                    </button>
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
            <div class="flex items-start justify-between">
                <div>
                    <div class="text-[11px] font-bold uppercase tracking-wide text-slate-400">Fatura atual</div>
                    <div class="mt-2 text-3xl font-bold tracking-tight text-slate-900">{{ formatBRL(currentInvoiceTotal) }}</div>
                </div>
                <span class="rounded-full px-3 py-1 text-[11px] font-bold" :style="{ backgroundColor: `${cardColor}22`, color: cardColor }">
                    {{ invoiceStatus }}
                </span>
            </div>

            <div class="mt-5 grid grid-cols-2 gap-4 text-xs font-semibold text-slate-500">
                <div>
                    Usado: <span class="text-slate-900">{{ formatBRL(usedLimit) }}</span>
                </div>
                <div class="text-right">
                    Disp: <span class="text-slate-900">{{ formatBRL(availableLimit) }}</span>
                </div>
            </div>

            <div class="mt-3 h-2 overflow-hidden rounded-full bg-slate-100">
                <div class="h-2 rounded-full" :style="{ width: `${percentUsed}%`, backgroundColor: cardColor }"></div>
            </div>
            <div class="mt-2 flex items-center justify-between text-[11px] font-semibold text-slate-400">
                <span></span>
                <span>{{ percentLabel }}</span>
            </div>

            <div v-if="dueDateLabel" class="mt-4 flex items-center gap-2 text-xs font-semibold text-slate-500">
                <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <rect x="3" y="4" width="18" height="18" rx="3" />
                    <path d="M8 2v4" />
                    <path d="M16 2v4" />
                    <path d="M3 10h18" />
                </svg>
                Vence em {{ dueDateLabel }}
                <span class="ml-auto inline-flex items-center gap-2 rounded-full bg-slate-50 px-3 py-1 text-[11px] font-bold text-slate-500 ring-1 ring-slate-200/60">
                    {{ brandLabel }}
                </span>
            </div>
        </section>

        <section class="mt-8 pb-[calc(7rem+env(safe-area-inset-bottom))]">
            <div class="text-lg font-semibold text-slate-900">Histórico da fatura</div>

            <div v-if="grouped.length === 0" class="mt-4 rounded-3xl border border-dashed border-slate-200 bg-slate-50 px-5 py-10 text-center">
                <div class="text-sm font-semibold text-slate-900">Sem lançamentos</div>
                <div class="mt-1 text-xs text-slate-500">Quando houver compras, elas aparecem aqui.</div>
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
                            <div class="text-right text-sm font-semibold text-slate-900">
                                {{ formatBRL(entry.amount) }}
                                <div v-if="entry.installment" class="mt-1 text-[11px] font-semibold text-slate-400">{{ entry.installment }}</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <footer class="fixed inset-x-0 bottom-0 bg-white px-5 pb-[calc(1rem+env(safe-area-inset-bottom))] pt-3 shadow-[0_-18px_40px_-32px_rgba(15,23,42,0.45)]">
            <div class="mx-auto flex w-full max-w-md gap-3">
                <button type="button" class="h-[52px] flex-1 rounded-2xl bg-slate-100 text-sm font-semibold text-slate-500" @click="openInstallments">
                    Parcelar
                </button>
                <button type="button" class="h-[52px] flex-[1.2] rounded-2xl text-sm font-semibold text-white" :style="{ backgroundColor: cardColor }">
                    Pagar fatura
                </button>
            </div>
        </footer>

        <TransactionModal
            :open="transactionOpen"
            kind="expense"
            :initial="transactionInitial"
            @close="transactionOpen = false"
            @save="onTransactionSave"
        />

        <CreditCardModal :open="editOpen" :initial="editInitial" @close="editOpen = false" @save="onSaveCard" />

        <ConfirmationModal
            :open="deleteOpen"
            title="Excluir cartão de crédito?"
            :message="`Tem certeza que deseja excluir o cartão “${accountName}”?`"
            warningText="ATENÇÃO: Isso irá excluir também todas as transações vinculadas a este cartão. Esta ação não pode ser desfeita."
            danger
            confirmLabel="Excluir"
            @close="deleteOpen = false"
            @confirm="confirmDelete"
        />

        <InstallmentInvoiceSheet
            :open="installmentOpen"
            :original-amount="currentInvoiceTotal"
            :accent-color="cardColor"
            @close="installmentOpen = false"
            @confirm="confirmInstallments"
        />

        <MobileToast :show="toastOpen" :message="toastMessage" @dismiss="toastOpen = false" />
    </MobileShell>

    <KitamoLayout v-else title="Cartão de crédito" :subtitle="accountName">
        <div class="rounded-2xl bg-white p-6 shadow-sm ring-1 ring-slate-200/60">
            <div class="text-sm font-semibold text-slate-900">Abra no mobile para ver o layout completo.</div>
        </div>
    </KitamoLayout>
</template>
