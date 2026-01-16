<script setup lang="ts">
	import { computed, ref, watch } from 'vue';
import { formatMoneyInputCentsShift, moneyInputToNumber, numberToMoneyInput } from '@/lib/moneyInput';

type TransactionKind = 'expense' | 'income' | 'transfer';
type DateKind = 'today' | 'other';

export type TransactionModalPayload = {
    id?: string;
    kind: TransactionKind;
    amount: number;
    description: string;
    category: string;
    account: string;
    dateKind: DateKind;
    dateOther?: string;
    isInstallment: boolean;
    installmentCount: number;
    isPaid: boolean;
    transferFrom: string;
    transferTo: string;
    transferDescription: string;
    isRecorrente?: boolean;
    periodicidade?: 'mensal' | 'quinzenal' | 'a_cada_x_dias';
    intervalo_dias?: number | null;
    data_fim?: string | null;
};

const props = defineProps<{
    open: boolean;
    kind: TransactionKind;
    initial?: TransactionModalPayload | null;
}>();

const emit = defineEmits<{
    (event: 'close'): void;
    (event: 'save', payload: TransactionModalPayload): void;
}>();

const close = () => emit('close');

const localKind = ref<TransactionKind>(props.kind);
const initialId = ref<string | undefined>(undefined);
const amount = ref('');
const description = ref('');
const category = ref('Alimentação');
const account = ref('Carteira');
const transferFrom = ref('Banco Inter');
const transferTo = ref('Carteira');
const transferDescription = ref('');
const dateKind = ref<DateKind>('today');
const dateOther = ref<string>('');
const isInstallment = ref(false);
const installmentCount = ref(1);
const isPaid = ref(false);
const isRecorrente = ref(false);
	const periodicidade = ref<'mensal' | 'quinzenal' | 'a_cada_x_dias'>('mensal');
	const intervalo_dias = ref<number | null>(null);
	const data_fim = ref<string>('');
	const fimMode = ref<'sempre' | 'ate'>('sempre');
	const recurrenceError = ref<string>('');

	watch(periodicidade, (value) => {
	    if (value !== 'a_cada_x_dias') intervalo_dias.value = null;
	});

	watch(fimMode, (value) => {
	    if (value !== 'ate') data_fim.value = '';
	});

const isExpense = computed(() => localKind.value === 'expense');
const isTransfer = computed(() => localKind.value === 'transfer');
const showAdvanced = ref(false);
const amountTextClass = computed(() => {
    if (localKind.value === 'expense') return 'text-[#EF4444]';
    if (localKind.value === 'transfer') return 'text-[#3B82F6]';
    return 'text-[#14B8A6]';
});

const pillClass = (kind: TransactionKind) => {
    if (localKind.value !== kind) return 'bg-transparent text-[#9CA3AF] border border-[#E5E7EB]';
    if (kind === 'expense') return 'bg-[#FEE2E2] text-[#EF4444] border border-transparent';
    if (kind === 'transfer') return 'bg-[#DBEAFE] text-[#2563EB] border border-transparent';
    return 'bg-[#E6FFFB] text-[#14B8A6] border border-transparent';
};

const onAmountInput = (event: Event) => {
    const target = event.target as HTMLInputElement;
    amount.value = formatMoneyInputCentsShift(target.value);
};

const amountNumber = computed(() => {
    return moneyInputToNumber(amount.value);
});

const formatBRL2 = (value: number) =>
    new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL',
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
    }).format(value);

const installmentEach = computed(() => {
    const count = Math.max(1, Math.floor(installmentCount.value || 1));
    return amountNumber.value / count;
});

const dateButtonClass = (value: DateKind) => (dateKind.value === value ? 'bg-[#14B8A6] text-white' : 'bg-[#F3F4F6] text-[#6B7280]');

const toISODate = (brDate: string) => {
    const match = brDate.trim().match(/^(\d{2})\/(\d{2})\/(\d{4})$/);
    if (!match) return '';
    const [, dd, mm, yyyy] = match;
    return `${yyyy}-${mm}-${dd}`;
};

const toBRDate = (isoDate: string) => {
    const match = isoDate.trim().match(/^(\d{4})-(\d{2})-(\d{2})$/);
    if (!match) return isoDate;
    const [, yyyy, mm, dd] = match;
    return `${dd}/${mm}/${yyyy}`;
};

const reset = () => {
    const draft = props.initial ?? null;

    initialId.value = draft?.id;
    localKind.value = draft?.kind ?? props.kind;
    amount.value = draft ? numberToMoneyInput(draft.amount) : '';
    description.value = draft?.description ?? '';
    category.value = draft?.category ?? 'Alimentação';
    account.value = draft?.account ?? 'Carteira';
    dateKind.value = draft?.dateKind ?? 'today';
    dateOther.value = draft?.dateOther ? toBRDate(draft.dateOther) : '';
    isInstallment.value = draft?.isInstallment ?? false;
    installmentCount.value = draft?.installmentCount ?? 1;
    isPaid.value = draft?.isPaid ?? false;
    showAdvanced.value = Boolean(draft?.isInstallment || draft?.isRecorrente);

    transferFrom.value = draft?.transferFrom ?? 'Banco Inter';
    transferTo.value = draft?.transferTo ?? 'Carteira';
    transferDescription.value = draft?.transferDescription ?? '';
    isRecorrente.value = draft?.isRecorrente ?? false;
    periodicidade.value = draft?.periodicidade ?? 'mensal';
    intervalo_dias.value = draft?.intervalo_dias ?? null;
    data_fim.value = draft?.data_fim ? toBRDate(draft.data_fim) : '';
    fimMode.value = draft?.data_fim ? 'ate' : 'sempre';
};

	const save = () => {
	    recurrenceError.value = '';
	    const dateOtherISO = dateKind.value === 'other' ? toISODate(dateOther.value) : '';
	    if (isRecorrente.value && periodicidade.value === 'a_cada_x_dias') {
	        const interval = Number(intervalo_dias.value ?? 0);
	        if (!Number.isFinite(interval) || interval < 1) {
	            recurrenceError.value = 'Informe um intervalo válido (mínimo 1 dia).';
	            return;
	        }
	    }
	    if (isRecorrente.value && fimMode.value === 'ate') {
	        const iso = toISODate(data_fim.value);
	        if (!iso) {
	            recurrenceError.value = 'Informe uma data final válida (dd/mm/aaaa).';
	            return;
	        }
	    }
	    const dataFimISO = isRecorrente.value && fimMode.value === 'ate' && data_fim.value ? toISODate(data_fim.value) : null;
	    const intervaloDiasValue = isRecorrente.value && periodicidade.value === 'a_cada_x_dias' ? intervalo_dias.value : null;
	    emit('save', {
        id: initialId.value,
        kind: localKind.value,
        amount: amountNumber.value,
        description: description.value.trim(),
        category: category.value,
        account: account.value,
        dateKind: dateKind.value,
        dateOther: dateOtherISO,
        isInstallment: isInstallment.value,
        installmentCount: installmentCount.value,
        isPaid: isPaid.value,
        transferFrom: transferFrom.value,
        transferTo: transferTo.value,
        transferDescription: transferDescription.value.trim(),
        isRecorrente: isRecorrente.value,
        periodicidade: periodicidade.value,
        intervalo_dias: intervaloDiasValue,
        data_fim: dataFimISO,
    });
    close();
};

watch(
    () => props.open,
    (isOpen) => {
        if (!isOpen) return;
        reset();
    },
);
</script>

<template>
    <div v-if="open" class="transaction-modal fixed inset-0 z-[60] bg-white" role="dialog" aria-modal="true">
        <div class="flex h-full flex-col">
                <header class="relative flex h-14 items-center px-4 pt-[env(safe-area-inset-top)]">
                    <button class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-50 text-[#6B7280]" type="button" @click="close" aria-label="Fechar">
                        <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M18 6L6 18" />
                            <path d="M6 6l12 12" />
                        </svg>
                    </button>

                    <div class="pointer-events-none absolute inset-0 flex items-center justify-center">
                        <div class="text-[18px] font-bold text-[#1F2937]">Nova movimentação</div>
                    </div>
                </header>

            <div class="flex-1 overflow-y-auto">
                <div class="px-5 pt-4">
                    <div class="rounded-2xl bg-slate-50 p-2 ring-1 ring-slate-200/70">
                        <div class="grid grid-cols-3 gap-2">
                            <button type="button" class="flex h-11 items-center justify-center rounded-xl text-sm font-semibold" :class="pillClass('expense')" @click="localKind = 'expense'">
                                Gasto
                            </button>
                            <button type="button" class="flex h-11 items-center justify-center rounded-xl text-sm font-semibold" :class="pillClass('income')" @click="localKind = 'income'">
                                Receita
                            </button>
                            <button type="button" class="flex h-11 items-center justify-center rounded-xl text-sm font-semibold" :class="pillClass('transfer')" @click="localKind = 'transfer'">
                                Transf.
                            </button>
                        </div>
                    </div>
                </div>

                <div class="mt-6 px-5">
                    <div class="text-center text-xs font-bold uppercase tracking-wide text-slate-300">Valor da transação</div>
                    <div class="mt-2 flex items-center justify-center gap-3">
                        <div class="text-2xl font-bold" :class="amountTextClass">R$</div>
                        <input
                            class="amount-input w-[240px] bg-transparent text-center text-[56px] font-bold leading-none tracking-tight text-slate-200 placeholder:text-slate-200 focus:outline-none focus:ring-0"
                            :class="amountTextClass"
                            inputmode="numeric"
                            autocomplete="off"
                            spellcheck="false"
                            :value="amount"
                            @input="onAmountInput"
                            placeholder="0,00"
                            aria-label="Valor"
                        />
                    </div>
                </div>

                <div v-if="!isTransfer" class="mt-6 space-y-4 px-5">
                    <div class="rounded-2xl bg-slate-50 px-4 py-4 ring-1 ring-slate-200/70">
                        <div class="flex items-center gap-3">
                            <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-white text-slate-400 ring-1 ring-slate-200/60">
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M4 7h16" />
                                    <path d="M4 12h10" />
                                    <path d="M4 17h14" />
                                </svg>
                            </span>
                            <input
                                v-model="description"
                                type="text"
                                placeholder="Descrição (ex: Almoço de domingo)"
                                class="w-full appearance-none border-0 bg-transparent text-sm font-semibold text-slate-700 placeholder:text-slate-300 outline-none focus:outline-none focus:ring-0"
                            />
                        </div>
                    </div>

                    <div class="grid grid-cols-2 gap-3">
                        <button type="button" class="rounded-2xl bg-slate-50 px-4 py-4 text-left ring-1 ring-slate-200/70">
                            <div class="flex items-center gap-3">
                                <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-amber-100 text-amber-600">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M4 3v7" />
                                        <path d="M8 3v7" />
                                        <path d="M6 3v7" />
                                        <path d="M14 3v7c0 2 1 3 3 3v8" />
                                        <path d="M20 3v7" />
                                    </svg>
                                </span>
                                <div class="min-w-0 flex-1">
                                    <div class="text-[10px] font-bold uppercase tracking-wide text-slate-400">Categoria</div>
                                    <div class="truncate text-sm font-semibold text-slate-900">{{ category }}</div>
                                </div>
                                <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                                    <path d="M6 9l6 6 6-6" />
                                </svg>
                            </div>
                        </button>

                        <button type="button" class="rounded-2xl bg-slate-50 px-4 py-4 text-left ring-1 ring-slate-200/70">
                            <div class="flex items-center gap-3">
                                <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-purple-100 text-purple-600">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M3 10h18" />
                                        <path d="M5 10V8l7-5 7 5v2" />
                                        <path d="M6 10v9" />
                                        <path d="M18 10v9" />
                                    </svg>
                                </span>
                                <div class="min-w-0 flex-1">
                                    <div class="text-[10px] font-bold uppercase tracking-wide text-slate-400">Conta</div>
                                    <div class="truncate text-sm font-semibold text-slate-900">{{ account }}</div>
                                </div>
                                <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                                    <path d="M6 9l6 6 6-6" />
                                </svg>
                            </div>
                        </button>
                    </div>

                    <div class="grid grid-cols-2 gap-3">
                        <button type="button" class="rounded-2xl bg-slate-50 px-4 py-4 text-left ring-1 ring-slate-200/70" @click="dateKind = dateKind === 'today' ? 'other' : 'today'">
                            <div class="flex items-center gap-3">
                                <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-200 text-slate-500">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <rect x="3" y="4" width="18" height="18" rx="3" />
                                        <path d="M8 2v4" />
                                        <path d="M16 2v4" />
                                        <path d="M3 10h18" />
                                    </svg>
                                </span>
                                <div class="min-w-0 flex-1">
                                    <div class="text-[10px] font-bold uppercase tracking-wide text-slate-400">Data</div>
                                    <div class="truncate text-sm font-semibold text-slate-900">{{ dateKind === 'today' ? 'Hoje' : dateOther || 'Outra' }}</div>
                                </div>
                            </div>
                        </button>

                        <div class="rounded-2xl bg-slate-50 px-4 py-4 ring-1 ring-slate-200/70">
                            <div class="flex items-center justify-between gap-3">
                                <div>
                                    <div class="text-[10px] font-bold uppercase tracking-wide text-slate-400">Pago?</div>
                                    <div class="text-sm font-semibold text-slate-900">{{ isPaid ? 'Sim' : 'Não' }}</div>
                                </div>
                                <button
                                    type="button"
                                    class="relative inline-flex h-7 w-12 items-center rounded-full transition"
                                    :class="isPaid ? 'bg-[#14B8A6]' : 'bg-slate-300'"
                                    @click="isPaid = !isPaid"
                                    aria-label="Pago"
                                >
                                    <span
                                        class="inline-block h-6 w-6 transform rounded-full bg-white transition"
                                        :class="isPaid ? 'translate-x-5' : 'translate-x-1'"
                                    ></span>
                                </button>
                            </div>
                        </div>
                    </div>

                    <div v-if="dateKind === 'other'" class="rounded-2xl bg-slate-50 px-4 py-4 ring-1 ring-slate-200/70">
                        <input
                            v-model="dateOther"
                            inputmode="numeric"
                            type="text"
                            placeholder="dd/mm/aaaa"
                            class="h-11 w-full rounded-xl bg-white px-4 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60 focus:outline-none focus:ring-2 focus:ring-emerald-100"
                            aria-label="Data"
                        />
                    </div>

                    <button
                        type="button"
                        class="flex w-full items-center justify-between rounded-2xl bg-white px-4 py-4 text-left text-sm font-bold tracking-wide text-emerald-600 ring-1 ring-slate-200/60"
                        @click="showAdvanced = !showAdvanced"
                    >
                        <span>OPÇÕES AVANÇADAS</span>
                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                            <path d="M6 9l6 6 6-6" />
                        </svg>
                    </button>

                    <div v-if="showAdvanced" class="space-y-4 pb-4">
                        <div class="rounded-2xl bg-white p-4 ring-1 ring-slate-200/60">
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-3">
                                    <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-100 text-slate-500">
                                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M12 2l7 7-7 7-7-7 7-7Z" />
                                            <path d="M12 16l7 7H5l7-7Z" />
                                        </svg>
                                    </span>
                                    <div class="text-sm font-semibold text-slate-900">Parcelamento</div>
                                </div>
                                <button
                                    type="button"
                                    class="relative inline-flex h-7 w-12 items-center rounded-full transition"
                                    :class="isInstallment ? 'bg-[#14B8A6]' : 'bg-slate-300'"
                                    @click="isInstallment = !isInstallment"
                                    aria-label="Parcelado"
                                >
                                    <span class="inline-block h-6 w-6 transform rounded-full bg-white transition" :class="isInstallment ? 'translate-x-5' : 'translate-x-1'"></span>
                                </button>
                            </div>

                            <div v-if="isInstallment" class="mt-4 grid grid-cols-2 gap-3">
                                <div>
                                    <div class="text-[10px] font-bold uppercase tracking-wide text-slate-400">Qtd.</div>
                                    <input
                                        v-model.number="installmentCount"
                                        type="number"
                                        min="1"
                                        class="mt-2 h-11 w-full rounded-xl bg-slate-50 px-4 text-center text-sm font-bold text-slate-900 ring-1 ring-slate-200/60 focus:outline-none focus:ring-2 focus:ring-emerald-100"
                                    />
                                </div>
                                <div>
                                    <div class="text-[10px] font-bold uppercase tracking-wide text-slate-400">Valor parcela</div>
                                    <div class="mt-2 flex h-11 items-center justify-center rounded-xl bg-slate-50 text-sm font-bold text-slate-400 ring-1 ring-slate-200/60">
                                        {{ formatBRL2(installmentEach) }}
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="rounded-2xl bg-white p-4 ring-1 ring-slate-200/60">
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-3">
                                    <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-100 text-slate-500">
                                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M21 12a9 9 0 0 1-9 9" />
                                            <path d="M3 12a9 9 0 0 1 9-9" />
                                            <path d="M8 12h8" />
                                        </svg>
                                    </span>
                                    <div class="text-sm font-semibold text-slate-900">Recorrência</div>
                                </div>
                                <button
                                    type="button"
                                    class="relative inline-flex h-7 w-12 items-center rounded-full transition"
                                    :class="isRecorrente ? 'bg-[#14B8A6]' : 'bg-slate-300'"
                                    @click="isRecorrente = !isRecorrente"
                                    aria-label="Recorrente"
                                >
                                    <span class="inline-block h-6 w-6 transform rounded-full bg-white transition" :class="isRecorrente ? 'translate-x-5' : 'translate-x-1'"></span>
                                </button>
                            </div>

                            <div v-if="isRecorrente" class="mt-4 grid grid-cols-2 gap-3">
                                <div>
                                    <div class="text-[10px] font-bold uppercase tracking-wide text-slate-400">Frequência</div>
                                    <select v-model="periodicidade" class="mt-2 h-11 w-full rounded-xl bg-slate-50 px-4 text-sm font-bold text-slate-700 ring-1 ring-slate-200/60 focus:outline-none">
                                        <option value="mensal">Mensal</option>
                                        <option value="quinzenal">Quinzenal</option>
                                        <option value="a_cada_x_dias">A cada X dias</option>
                                    </select>
                                    <input
                                        v-if="periodicidade === 'a_cada_x_dias'"
                                        v-model.number="intervalo_dias"
                                        type="number"
                                        min="1"
                                        placeholder="Dias"
                                        class="mt-2 h-11 w-full rounded-xl bg-white px-4 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60 focus:outline-none focus:ring-2 focus:ring-emerald-100"
                                    />
                                </div>
                                <div>
                                    <div class="text-[10px] font-bold uppercase tracking-wide text-slate-400">Duração</div>
                                    <select v-model="fimMode" class="mt-2 h-11 w-full rounded-xl bg-slate-50 px-4 text-sm font-bold text-slate-700 ring-1 ring-slate-200/60 focus:outline-none">
                                        <option value="sempre">Sempre</option>
                                        <option value="ate">Até data</option>
                                    </select>
                                    <input
                                        v-if="fimMode === 'ate'"
                                        v-model="data_fim"
                                        type="text"
                                        placeholder="dd/mm/aaaa"
                                        inputmode="numeric"
                                        class="mt-2 h-11 w-full rounded-xl bg-white px-4 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60 focus:outline-none focus:ring-2 focus:ring-emerald-100"
                                    />
                                </div>
                            </div>
                            <div v-if="recurrenceError" class="mt-3 text-xs font-semibold text-red-500">
                                {{ recurrenceError }}
                            </div>
                        </div>
                    </div>
                </div>

                <div v-if="isTransfer" class="mt-6 space-y-4 px-5 pb-6">
                    <div class="grid grid-cols-[1fr_auto_1fr] items-start gap-3">
                        <div>
                            <div class="mb-2 text-sm font-bold text-[#374151]">De (Origem)</div>
                            <button type="button" class="w-full rounded-2xl border border-slate-200 bg-white px-4 py-4 text-left shadow-sm">
                                <div class="flex items-start gap-3">
                                    <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-100 text-slate-600">
                                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M3 10h18" />
                                            <path d="M5 10V8l7-5 7 5v2" />
                                            <path d="M6 10v9" />
                                            <path d="M18 10v9" />
                                        </svg>
                                    </span>
                                    <div class="min-w-0">
                                        <div class="truncate text-sm font-semibold text-slate-900">{{ transferFrom }}</div>
                                        <div class="mt-1 text-xs font-semibold text-slate-400">Saldo: R$ 1.000</div>
                                    </div>
                                </div>
                            </button>
                        </div>
                        <div class="pt-9 text-slate-300">
                            <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M9 18l6-6-6-6" />
                            </svg>
                        </div>
                        <div>
                            <div class="mb-2 text-sm font-bold text-[#374151]">Para (Destino)</div>
                            <button type="button" class="w-full rounded-2xl border border-slate-200 bg-white px-4 py-4 text-left shadow-sm">
                                <div class="flex items-start gap-3">
                                    <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-amber-50 text-amber-600">
                                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M4 7h16v12H4z" />
                                            <path d="M4 7V5h12v2" />
                                            <path d="M16 12h4" />
                                        </svg>
                                    </span>
                                    <div class="min-w-0">
                                        <div class="truncate text-sm font-semibold text-slate-900">{{ transferTo }}</div>
                                        <div class="mt-1 text-xs font-semibold text-slate-400">Saldo: R$ 450</div>
                                    </div>
                                </div>
                            </button>
                        </div>
                    </div>

                    <div>
                        <div class="mb-2 text-sm font-bold text-[#374151]">Descrição (opcional)</div>
                        <input
                            v-model="transferDescription"
                            type="text"
                            placeholder="Ex: Saque..."
                            class="h-11 w-full rounded-lg border border-[#E5E7EB] bg-[#F9FAFB] px-3 text-base text-[#374151] placeholder:text-[#9CA3AF] focus:border-[#3B82F6] focus:outline-none focus:ring-0"
                        />
                    </div>
                </div>
                </div>

                <footer class="px-6 pt-4 pb-[calc(24px+env(safe-area-inset-bottom))]">
                    <button
                        class="h-[52px] w-full rounded-xl text-base font-bold text-white"
                        :class="localKind === 'transfer' ? 'bg-[#3B82F6] shadow-[0_2px_8px_rgba(59,130,246,0.25)]' : 'bg-[#14B8A6] shadow-[0_2px_8px_rgba(20,184,166,0.25)]'"
                        type="button"
                        @click="save"
                    >
                        {{ localKind === 'transfer' ? 'Transferir' : 'Salvar' }}
                    </button>
                </footer>
        </div>
    </div>
</template>

<style scoped>
.transaction-modal input,
.transaction-modal select,
.transaction-modal textarea {
    outline: none !important;
    box-shadow: none !important;
    border: 0 !important;
}
.transaction-modal input:focus,
.transaction-modal input:focus-visible,
.transaction-modal select:focus,
.transaction-modal select:focus-visible,
.transaction-modal textarea:focus,
.transaction-modal textarea:focus-visible {
    outline: none !important;
    box-shadow: none !important;
    border: 0 !important;
}

.amount-input {
    outline: none !important;
    box-shadow: none !important;
    border: 0 !important;
    background: transparent !important;
    -webkit-appearance: none;
    -webkit-text-stroke: 0 transparent;
    text-shadow: none !important;
}
.amount-input:focus,
.amount-input:focus-visible {
    outline: none !important;
    box-shadow: none !important;
    border: 0 !important;
}

.select-clean {
    background-image: none !important;
    -webkit-appearance: none !important;
    -moz-appearance: none !important;
    appearance: none !important;
}
</style>
