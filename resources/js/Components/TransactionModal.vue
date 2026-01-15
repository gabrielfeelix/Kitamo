<script setup lang="ts">
import { computed, ref, watch } from 'vue';

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
    periodicidade?: 'mensal' | 'semanal' | 'diaria';
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
const amount = ref('0,00');
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
const periodicidade = ref<'mensal' | 'semanal' | 'diaria'>('mensal');
const intervalo_dias = ref<number | null>(null);
const data_fim = ref<string>('');

const isExpense = computed(() => localKind.value === 'expense');
const isTransfer = computed(() => localKind.value === 'transfer');
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

const normalizeMoneyInput = (raw: string) => {
    const digits = raw.replace(/[^\d]/g, '');
    const padded = digits.padStart(3, '0');
    const cents = padded.slice(-2);
    const whole = padded.slice(0, -2).replace(/^0+/, '') || '0';
    return `${whole},${cents}`;
};

const toMoneyInput = (value: number) => {
    const normalized = Number.isFinite(value) ? value : 0;
    const fixed = normalized.toFixed(2).replace('.', ',');
    const [whole, cents] = fixed.split(',');
    const withThousands = whole.replace(/\B(?=(\d{3})+(?!\d))/g, '.');
    return `${withThousands},${cents}`;
};

const onAmountInput = (event: Event) => {
    const target = event.target as HTMLInputElement;
    amount.value = normalizeMoneyInput(target.value);
};

const amountNumber = computed(() => {
    const normalized = amount.value.replace(/\./g, '').replace(',', '.');
    const value = Number(normalized);
    return Number.isFinite(value) ? value : 0;
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
    amount.value = draft ? toMoneyInput(draft.amount) : '0,00';
    description.value = draft?.description ?? '';
    category.value = draft?.category ?? 'Alimentação';
    account.value = draft?.account ?? 'Carteira';
    dateKind.value = draft?.dateKind ?? 'today';
    dateOther.value = draft?.dateOther ? toBRDate(draft.dateOther) : '';
    isInstallment.value = draft?.isInstallment ?? false;
    installmentCount.value = draft?.installmentCount ?? 1;
    isPaid.value = draft?.isPaid ?? false;

    transferFrom.value = draft?.transferFrom ?? 'Banco Inter';
    transferTo.value = draft?.transferTo ?? 'Carteira';
    transferDescription.value = draft?.transferDescription ?? '';
    isRecorrente.value = draft?.isRecorrente ?? false;
    periodicidade.value = draft?.periodicidade ?? 'mensal';
    intervalo_dias.value = draft?.intervalo_dias ?? null;
    data_fim.value = draft?.data_fim ? toBRDate(draft.data_fim) : '';
};

const save = () => {
    const dateOtherISO = dateKind.value === 'other' ? toISODate(dateOther.value) : '';
    const dataFimISO = isRecorrente.value && data_fim.value ? toISODate(data_fim.value) : null;
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
        intervalo_dias: null,
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
    <div v-if="open" class="fixed inset-0 z-[60]">
        <button class="absolute inset-0 bg-black/50 backdrop-blur-sm" type="button" @click="close" aria-label="Fechar"></button>

        <div
            class="absolute inset-x-0 bottom-0 h-[650px] max-h-[calc(100vh-150px)] w-full overflow-hidden rounded-t-[24px] bg-white shadow-[0_-4px_20px_rgba(0,0,0,0.25)]"
            role="dialog"
            aria-modal="true"
        >
            <div class="flex h-full flex-col">
                <header class="relative flex h-14 items-center px-4">
                    <button class="h-6 w-6 text-[#6B7280]" type="button" @click="close" aria-label="Fechar">
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
                    <div class="px-6 pt-4">
                        <div class="grid grid-cols-3 gap-2">
                            <button type="button" class="flex h-11 items-center justify-center rounded-xl text-sm font-semibold" :class="pillClass('expense')" @click="localKind = 'expense'">
                                <span class="inline-flex items-center gap-2">
                                    <span class="text-[16px] leading-none">↓</span>
                                    Gasto
                                </span>
                            </button>
                            <button type="button" class="flex h-11 items-center justify-center rounded-xl text-sm font-semibold" :class="pillClass('income')" @click="localKind = 'income'">
                                <span class="inline-flex items-center gap-2">
                                    <span class="text-[16px] leading-none">↑</span>
                                    Receita
                                </span>
                            </button>
                            <button type="button" class="flex h-11 items-center justify-center rounded-xl text-sm font-semibold" :class="pillClass('transfer')" @click="localKind = 'transfer'">
                                <span class="inline-flex items-center gap-2">
                                    <span class="text-[16px] leading-none">⇄</span>
                                    Transf.
                                </span>
                            </button>
                        </div>
                    </div>

                    <div class="mt-6 px-6">
                        <div class="flex h-[120px] items-center">
                            <div class="w-10 text-base text-[#6B7280]">R$</div>
                            <input
                                class="amount-input h-[72px] w-full flex-1 bg-transparent text-center text-[56px] font-bold leading-none tracking-tight focus:outline-none focus:ring-0"
                                :class="amountTextClass"
                                inputmode="numeric"
                                autocomplete="off"
                                spellcheck="false"
                                :value="amount"
                                @input="onAmountInput"
                                aria-label="Valor"
                            />
                            <div class="w-10"></div>
                        </div>

                        <div v-if="isExpense" class="relative mx-auto mt-2 inline-flex items-center gap-2 group cursor-pointer">
                            <button type="button" class="inline-flex items-center gap-2" @click="isPaid = !isPaid" aria-label="Marcar como pago">
                                <span class="flex h-5 w-5 items-center justify-center rounded-full border" :class="isPaid ? 'border-transparent bg-[#14B8A6]' : 'border-[#E5E7EB] bg-white'">
                                    <svg v-if="isPaid" class="h-3.5 w-3.5 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">
                                        <path d="M20 6 9 17l-5-5" />
                                    </svg>
                                </span>
                                <span class="text-sm font-semibold text-[#6B7280]">Já paguei</span>
                            </button>
                            <!-- Tooltip -->
                            <div class="absolute bottom-full left-0 mb-2 hidden group-hover:block z-50 bg-slate-800 text-white text-xs rounded-lg px-3 py-2 w-56 shadow-lg">
                                <div class="flex items-start gap-2">
                                    <span>✅</span>
                                    <span>Marcar como pago atualiza o saldo da conta imediatamente</span>
                                </div>
                                <div class="flex items-start gap-2 mt-1">
                                    <span>⏳</span>
                                    <span>Deixar desmarcado: conta aparece em "A pagar"</span>
                                </div>
                                <!-- Arrow -->
                                <div class="absolute top-full left-6 w-0 h-0 border-l-4 border-r-4 border-t-4 border-transparent border-t-slate-800"></div>
                            </div>
                        </div>
                    </div>

                    <div class="px-6 pb-6 pt-6">
                        <div v-if="isTransfer" class="space-y-4">
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

                            <div class="rounded-2xl border border-slate-200 bg-slate-50 p-4">
                                <div class="text-xs font-bold uppercase tracking-wide text-slate-400">Após a transferência</div>
                                <div class="mt-4 space-y-2 text-sm font-semibold text-slate-700">
                                    <div class="flex items-center justify-between">
                                        <div>{{ transferFrom }}</div>
                                        <div>R$ 1.000 <span class="text-slate-400">→</span> <span class="text-red-500">R$ 500</span></div>
                                    </div>
                                    <div class="flex items-center justify-between">
                                        <div>{{ transferTo }}</div>
                                        <div>R$ 450 <span class="text-slate-400">→</span> <span class="text-emerald-600">R$ 950</span></div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div v-else class="space-y-4">
                            <div>
                                <div class="mb-2 text-sm font-bold text-[#374151]">Descrição</div>
                                <input
                                    v-model="description"
                                    type="text"
                                    placeholder="Ex: Supermercado, Padaria..."
                                    class="h-11 w-full rounded-lg border border-[#E5E7EB] bg-[#F9FAFB] px-3 text-base text-[#374151] placeholder:text-[#9CA3AF] focus:border-[#14B8A6] focus:outline-none focus:ring-0"
                                />
                            </div>

                            <div>
                                <div class="mb-2 text-sm font-bold text-[#374151]">Categoria</div>
                                <div class="relative flex h-11 items-center gap-1 rounded-lg border border-[#E5E7EB] bg-[#F9FAFB] px-3">
                                    <span class="flex items-center justify-center text-[#6B7280]">
                                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M6 6h15l-2 7H7L6 6Z" />
                                            <path d="M6 6l-2-2H2" />
                                            <circle cx="9" cy="18" r="1.5" />
                                            <circle cx="17" cy="18" r="1.5" />
                                        </svg>
                                    </span>
                                    <select v-model="category" class="select-clean h-full w-full flex-1 appearance-none bg-transparent pr-8 text-base text-[#374151] focus:outline-none">
                                        <option>Alimentação</option>
                                        <option>Moradia</option>
                                        <option>Transporte</option>
                                        <option>Lazer</option>
                                        <option v-if="localKind === 'income'">Salário</option>
                                        <option v-if="localKind === 'income'">Outros</option>
                                    </select>
                                    <span class="pointer-events-none absolute inset-y-0 right-3 flex items-center text-[#9CA3AF]">
                                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M6 9l6 6 6-6" />
                                        </svg>
                                    </span>
                                </div>
                            </div>

                            <div>
                                <div class="mb-2 text-sm font-bold text-[#374151]">Data</div>
                                <div class="grid grid-cols-2 gap-3">
                                    <button type="button" class="h-11 rounded-lg px-3 text-sm font-semibold" :class="dateButtonClass('today')" @click="dateKind = 'today'">
                                        Hoje
                                    </button>
                                    <button type="button" class="h-11 rounded-lg px-3 text-sm font-semibold" :class="dateButtonClass('other')" @click="dateKind = 'other'">
                                        Outro
                                    </button>
                                </div>
                                <input
                                    v-if="dateKind === 'other'"
                                    v-model="dateOther"
                                    inputmode="numeric"
                                    type="text"
                                    placeholder="dd/mm/aaaa"
                                    class="mt-3 h-11 w-full rounded-lg border border-[#E5E7EB] bg-[#F9FAFB] px-3 text-base text-[#374151] focus:border-[#14B8A6] focus:outline-none focus:ring-0"
                                    aria-label="Data"
                                />
                            </div>

                            <div class="rounded-lg border border-[#E5E7EB] bg-[#F9FAFB] p-4">
                                <div class="flex items-center justify-between">
                                    <div class="text-base text-[#374151]">Parcelado?</div>
                                    <button
                                        type="button"
                                        class="relative inline-flex h-6 w-11 items-center rounded-full transition"
                                        :class="isInstallment ? 'bg-[#14B8A6]' : 'bg-[#E5E7EB]'"
                                        @click="isInstallment = !isInstallment"
                                        aria-label="Parcelado"
                                    >
                                        <span class="inline-block h-5 w-5 transform rounded-full bg-white transition" :class="isInstallment ? 'translate-x-5' : 'translate-x-0.5'"></span>
                                    </button>
                                </div>

                                <div v-if="isInstallment" class="mt-4 flex items-center justify-between gap-3">
                                    <div class="text-xs text-[#6B7280]">Quantas vezes?</div>
                                    <div class="flex items-center gap-3">
                                        <input
                                            v-model.number="installmentCount"
                                            type="number"
                                            min="1"
                                            class="h-10 w-20 rounded-lg border border-[#E5E7EB] bg-white px-3 text-center text-base text-[#374151] focus:border-[#14B8A6] focus:outline-none focus:ring-0"
                                            aria-label="Quantidade de parcelas"
                                        />
                                        <div class="text-sm text-[#6B7280]">x de {{ formatBRL2(installmentEach) }}</div>
                                    </div>
                                </div>
                            </div>

                            <!-- Recorrência -->
                            <div class="rounded-lg border border-[#E5E7EB] bg-[#F9FAFB] p-4">
                                <div class="flex items-center justify-between">
                                    <div class="text-base text-[#374151]">É uma despesa recorrente?</div>
                                    <button
                                        type="button"
                                        class="relative inline-flex h-6 w-11 items-center rounded-full transition"
                                        :class="isRecorrente ? 'bg-[#14B8A6]' : 'bg-[#E5E7EB]'"
                                        @click="isRecorrente = !isRecorrente"
                                        aria-label="Recorrente"
                                    >
                                        <span class="inline-block h-5 w-5 transform rounded-full bg-white transition" :class="isRecorrente ? 'translate-x-5' : 'translate-x-0.5'"></span>
                                    </button>
                                </div>

                                <div v-if="isRecorrente" class="mt-4 space-y-4">
                                    <!-- Periodicidade -->
                                    <div>
                                        <div class="mb-2 text-xs text-[#6B7280]">Repetir:</div>
                                        <div class="space-y-2">
                                            <label class="flex items-center gap-3">
                                                <input type="radio" v-model="periodicidade" value="mensal" class="h-4 w-4" />
                                                <span class="text-sm text-[#374151]">Todo mês</span>
                                            </label>
                                            <label class="flex items-center gap-3">
                                                <input type="radio" v-model="periodicidade" value="semanal" class="h-4 w-4" />
                                                <span class="text-sm text-[#374151]">Toda semana</span>
                                            </label>
                                            <label class="flex items-center gap-3">
                                                <input type="radio" v-model="periodicidade" value="diaria" class="h-4 w-4" />
                                                <span class="text-sm text-[#374151]">Diária</span>
                                            </label>
                                        </div>
                                    </div>

                                    <!-- Até quando -->
                                    <div>
                                        <div class="mb-2 text-xs text-[#6B7280]">Até quando:</div>
                                        <div class="space-y-2">
                                            <label class="flex items-center gap-3">
                                                <input type="radio" v-model="data_fim" value="" class="h-4 w-4" />
                                                <span class="text-sm text-[#374151]">Sempre</span>
                                            </label>
                                            <label class="flex items-center gap-3">
                                                <input type="radio" :value="data_fim || 'temp'" @change="data_fim = ''" class="h-4 w-4" />
                                                <span class="text-sm text-[#374151]">Até</span>
                                                <input
                                                    v-if="data_fim"
                                                    v-model="data_fim"
                                                    type="date"
                                                    class="ml-2 h-8 rounded border border-[#E5E7EB] px-2 text-sm"
                                                />
                                            </label>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div>
                                <div class="mb-2 text-sm font-bold text-[#374151]">Conta</div>
                                <div class="relative flex h-11 items-center gap-1 rounded-lg border border-[#E5E7EB] bg-[#F9FAFB] px-3">
                                    <span class="flex items-center justify-center text-[#6B7280]">
                                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M4 7h16v12H4z" />
                                            <path d="M4 7V5h12v2" />
                                            <path d="M16 12h4" />
                                        </svg>
                                    </span>
                                    <select v-model="account" class="select-clean h-full w-full flex-1 appearance-none bg-transparent pr-8 text-base text-[#374151] focus:outline-none">
                                        <option>Carteira</option>
                                        <option>Nubank C/C</option>
                                        <option>Nubank Cartão</option>
                                    </select>
                                    <span class="pointer-events-none absolute inset-y-0 right-3 flex items-center text-[#9CA3AF]">
                                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M6 9l6 6 6-6" />
                                        </svg>
                                    </span>
                                </div>
                            </div>
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
    </div>
</template>

<style scoped>
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
