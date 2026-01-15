<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import type { TransactionModalPayload } from '@/Components/TransactionModal.vue';

type TransactionKind = TransactionModalPayload['kind'];
type DateKind = TransactionModalPayload['dateKind'];

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
const dateKind = ref<DateKind>('today');
const dateOther = ref('');
const isInstallment = ref(false);
const installmentCount = ref(1);
const isPaid = ref(false);
const isRecorrente = ref(false);
const periodicidade = ref<'mensal' | 'quinzenal' | 'a_cada_x_dias'>('mensal');
const intervalo_dias = ref<number | null>(null);
const data_fim = ref('');
const fimMode = ref<'sempre' | 'ate'>('sempre');
const recurrenceError = ref<string>('');

watch(periodicidade, (value) => {
    if (value !== 'a_cada_x_dias') intervalo_dias.value = null;
});

watch(fimMode, (value) => {
    if (value !== 'ate') data_fim.value = '';
});

const transferFrom = ref('Banco Inter');
const transferTo = ref('Carteira');
const transferDescription = ref('');

const isExpense = computed(() => localKind.value === 'expense');
const isTransfer = computed(() => localKind.value === 'transfer');

const pillClass = (kind: TransactionKind) => {
    if (localKind.value !== kind) return 'bg-white text-slate-400 ring-1 ring-slate-200';
    if (kind === 'expense') return 'bg-red-50 text-red-500 ring-1 ring-red-100';
    if (kind === 'transfer') return 'bg-blue-50 text-blue-600 ring-1 ring-blue-100';
    return 'bg-emerald-50 text-emerald-600 ring-1 ring-emerald-100';
};

const amountTextClass = computed(() => {
    if (localKind.value === 'expense') return 'text-[#EF4444]';
    if (localKind.value === 'transfer') return 'text-[#3B82F6]';
    return 'text-[#14B8A6]';
});

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

const dateButtonClass = (value: DateKind) => (dateKind.value === value ? 'bg-[#14B8A6] text-white' : 'bg-slate-100 text-slate-500');

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
    isRecorrente.value = draft?.isRecorrente ?? false;
    periodicidade.value = draft?.periodicidade ?? 'mensal';
    intervalo_dias.value = draft?.intervalo_dias ?? null;
    data_fim.value = draft?.data_fim ? toBRDate(draft.data_fim) : '';
    fimMode.value = draft?.data_fim ? 'ate' : 'sempre';
    transferFrom.value = draft?.transferFrom ?? 'Banco Inter';
    transferTo.value = draft?.transferTo ?? 'Carteira';
    transferDescription.value = draft?.transferDescription ?? '';
};

watch(
    () => props.open,
    (isOpen) => {
        if (!isOpen) return;
        reset();
    },
);

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
        isRecorrente: isRecorrente.value,
        periodicidade: periodicidade.value,
        intervalo_dias: intervaloDiasValue,
        data_fim: dataFimISO,
        transferFrom: transferFrom.value,
        transferTo: transferTo.value,
        transferDescription: transferDescription.value.trim(),
    });
    close();
};
</script>

<template>
    <div v-if="open" class="fixed inset-0 z-[92]">
        <button class="absolute inset-0 bg-black/40 backdrop-blur-sm" type="button" @click="close" aria-label="Fechar"></button>

        <div class="absolute left-1/2 top-1/2 w-[560px] -translate-x-1/2 -translate-y-1/2 overflow-hidden rounded-2xl bg-white shadow-[0_30px_90px_-50px_rgba(15,23,42,0.7)] ring-1 ring-slate-200/60">
            <header class="flex items-center justify-between border-b border-slate-100 px-8 py-6">
                <div class="text-lg font-semibold text-slate-900">Nova transação</div>
                <button type="button" class="flex h-10 w-10 items-center justify-center rounded-xl bg-slate-50 text-slate-400 hover:bg-slate-100" aria-label="Fechar" @click="close">
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M18 6L6 18" />
                        <path d="M6 6l12 12" />
                    </svg>
                </button>
            </header>

            <div class="max-h-[70vh] overflow-y-auto px-8 py-7">
                <div class="grid grid-cols-3 gap-3">
                    <button type="button" class="h-11 rounded-xl text-sm font-semibold" :class="pillClass('expense')" @click="localKind = 'expense'">↓ Gasto</button>
                    <button type="button" class="h-11 rounded-xl text-sm font-semibold" :class="pillClass('income')" @click="localKind = 'income'">↑ Receita</button>
                    <button type="button" class="h-11 rounded-xl text-sm font-semibold" :class="pillClass('transfer')" @click="localKind = 'transfer'">⇄ Transf.</button>
                </div>

                <div class="mt-6">
                    <div class="flex items-center justify-center gap-4">
                        <div class="text-base font-semibold text-slate-400">R$</div>
                        <input
                            class="amount-input h-[64px] w-full bg-transparent text-center text-[52px] font-bold tracking-tight focus:outline-none focus:ring-0"
                            :class="amountTextClass"
                            inputmode="numeric"
                            autocomplete="off"
                            spellcheck="false"
                            :value="amount"
                            @input="onAmountInput"
                            aria-label="Valor"
                        />
                        <div class="w-6"></div>
                    </div>

	                    <div v-if="isExpense" class="mt-3 flex items-center justify-center gap-2">
	                        <button type="button" class="group relative inline-flex items-center gap-2" @click="isPaid = !isPaid">
	                            <span class="flex h-5 w-5 items-center justify-center rounded-full border" :class="isPaid ? 'border-transparent bg-[#14B8A6]' : 'border-slate-200 bg-white'">
	                                <svg v-if="isPaid" class="h-3.5 w-3.5 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">
	                                    <path d="M20 6 9 17l-5-5" />
	                                </svg>
	                            </span>
	                            <span class="text-sm font-semibold text-slate-500">Pago</span>
	                            <span
	                                class="absolute bottom-full left-0 mb-2 hidden w-64 rounded-lg bg-slate-800 px-3 py-2 text-xs font-medium text-white shadow-lg group-hover:block"
	                            >
	                                <span class="flex items-start gap-2">
	                                    <span>✅</span>
	                                    <span>Marcar como pago atualiza o saldo da conta imediatamente</span>
	                                </span>
	                                <span class="mt-1 flex items-start gap-2">
	                                    <span>⏳</span>
	                                    <span>Deixar desmarcado: conta aparece em "A pagar"</span>
	                                </span>
	                                <span
	                                    class="absolute top-full left-4 h-0 w-0 border-l-4 border-r-4 border-t-4 border-transparent border-t-slate-800"
	                                ></span>
	                            </span>
	                        </button>
	                    </div>
	                </div>

                <div v-if="isTransfer" class="mt-8 space-y-4">
                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <div class="mb-2 text-xs font-bold uppercase tracking-wide text-slate-400">De (Origem)</div>
                            <select v-model="transferFrom" class="h-11 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm font-semibold text-slate-700 focus:outline-none focus:ring-2 focus:ring-blue-100">
                                <option>Banco Inter</option>
                                <option>Carteira</option>
                                <option>Nubank</option>
                            </select>
                        </div>
                        <div>
                            <div class="mb-2 text-xs font-bold uppercase tracking-wide text-slate-400">Para (Destino)</div>
                            <select v-model="transferTo" class="h-11 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm font-semibold text-slate-700 focus:outline-none focus:ring-2 focus:ring-blue-100">
                                <option>Carteira</option>
                                <option>Banco Inter</option>
                                <option>Nubank</option>
                            </select>
                        </div>
                    </div>

                    <div>
                        <div class="mb-2 text-xs font-bold uppercase tracking-wide text-slate-400">Descrição (opcional)</div>
                        <input v-model="transferDescription" class="h-11 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm font-semibold text-slate-700 focus:outline-none focus:ring-2 focus:ring-blue-100" placeholder="Ex: Saque..." />
                    </div>
                </div>

                <div v-else class="mt-8 space-y-4">
                    <div>
                        <div class="mb-2 text-xs font-bold uppercase tracking-wide text-slate-400">Descrição</div>
                        <input
                            v-model="description"
                            placeholder="Ex: Supermercado, Padaria..."
                            class="h-11 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm font-semibold text-slate-700 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-emerald-100"
                        />
                    </div>

                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <div class="mb-2 text-xs font-bold uppercase tracking-wide text-slate-400">Categoria</div>
                            <select v-model="category" class="h-11 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm font-semibold text-slate-700 focus:outline-none focus:ring-2 focus:ring-emerald-100">
                                <option>Alimentação</option>
                                <option>Moradia</option>
                                <option>Transporte</option>
                                <option>Assinaturas</option>
                                <option>Outros</option>
                            </select>
                        </div>
                        <div>
                            <div class="mb-2 text-xs font-bold uppercase tracking-wide text-slate-400">Conta</div>
                            <select v-model="account" class="h-11 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm font-semibold text-slate-700 focus:outline-none focus:ring-2 focus:ring-emerald-100">
                                <option>Carteira</option>
                                <option>Banco Inter</option>
                                <option>Nubank</option>
                            </select>
                        </div>
                    </div>

                    <div>
                        <div class="mb-2 text-xs font-bold uppercase tracking-wide text-slate-400">Data</div>
                        <div class="grid grid-cols-2 gap-3">
                            <button type="button" class="h-11 rounded-xl text-sm font-semibold" :class="dateButtonClass('today')" @click="dateKind = 'today'">Hoje</button>
                            <button type="button" class="h-11 rounded-xl text-sm font-semibold" :class="dateButtonClass('other')" @click="dateKind = 'other'">Outro</button>
                        </div>
                        <input
                            v-if="dateKind === 'other'"
                            v-model="dateOther"
                            inputmode="numeric"
                            type="text"
                            placeholder="dd/mm/aaaa"
                            class="mt-3 h-11 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm font-semibold text-slate-700 focus:outline-none focus:ring-2 focus:ring-emerald-100"
                        />
                    </div>

	                    <div class="rounded-2xl border border-slate-200 bg-white px-5 py-5">
	                        <div class="flex items-center justify-between">
	                            <div class="text-sm font-semibold text-slate-700">Parcelado?</div>
                            <button
                                type="button"
                                class="relative inline-flex h-6 w-11 items-center rounded-full transition"
                                :class="isInstallment ? 'bg-[#14B8A6]' : 'bg-slate-200'"
                                @click="isInstallment = !isInstallment"
                                aria-label="Parcelado"
                            >
                                <span class="inline-block h-5 w-5 transform rounded-full bg-white transition" :class="isInstallment ? 'translate-x-5' : 'translate-x-0.5'"></span>
                            </button>
                        </div>

	                        <div v-if="isInstallment" class="mt-4 flex items-center justify-between gap-3">
	                            <div class="text-xs font-semibold text-slate-400">Quantas vezes?</div>
	                            <div class="flex items-center gap-3">
	                                <input v-model.number="installmentCount" type="number" min="1" class="h-10 w-20 rounded-xl border border-slate-200 bg-white px-3 text-center text-sm font-semibold text-slate-700 focus:outline-none focus:ring-2 focus:ring-emerald-100" />
	                                <div class="text-sm font-semibold text-slate-400">x de {{ formatBRL2(installmentEach) }}</div>
	                            </div>
	                        </div>
	                    </div>

	                    <div v-if="isExpense" class="rounded-2xl border border-slate-200 bg-white px-5 py-5">
	                        <div class="flex items-center justify-between">
	                            <div class="text-sm font-semibold text-slate-700">É uma despesa recorrente?</div>
	                            <button
	                                type="button"
	                                class="relative inline-flex h-6 w-11 items-center rounded-full transition"
	                                :class="isRecorrente ? 'bg-[#14B8A6]' : 'bg-slate-200'"
	                                @click="isRecorrente = !isRecorrente"
	                                aria-label="Recorrente"
	                            >
	                                <span class="inline-block h-5 w-5 transform rounded-full bg-white transition" :class="isRecorrente ? 'translate-x-5' : 'translate-x-0.5'"></span>
	                            </button>
	                        </div>

	                        <div v-if="isRecorrente" class="mt-4 space-y-4">
	                            <div>
	                                <div class="mb-2 text-xs font-bold uppercase tracking-wide text-slate-400">Repetir</div>
	                                <label class="flex items-center gap-3 text-sm font-semibold text-slate-600">
	                                    <input type="radio" v-model="periodicidade" value="mensal" class="h-4 w-4" />
	                                    Todo mês
	                                </label>
		                                <label class="mt-2 flex items-center gap-3 text-sm font-semibold text-slate-600">
		                                    <input type="radio" v-model="periodicidade" value="a_cada_x_dias" class="h-4 w-4" />
		                                    A cada
		                                    <input
		                                        v-if="periodicidade === 'a_cada_x_dias'"
		                                        v-model.number="intervalo_dias"
		                                        type="number"
		                                        min="1"
		                                        class="h-10 w-20 rounded-xl border border-slate-200 bg-white px-3 text-center text-sm font-semibold text-slate-700 focus:outline-none focus:ring-2 focus:ring-emerald-100"
		                                    />
		                                    <span v-if="periodicidade === 'a_cada_x_dias'">dias</span>
		                                </label>
	                            </div>

	                            <div>
	                                <div class="mb-2 text-xs font-bold uppercase tracking-wide text-slate-400">Até quando</div>
	                                <label class="flex items-center gap-3 text-sm font-semibold text-slate-600">
	                                    <input type="radio" v-model="fimMode" value="sempre" class="h-4 w-4" />
	                                    Sempre
	                                </label>
	                                <label class="mt-2 flex items-center gap-3 text-sm font-semibold text-slate-600">
	                                    <input type="radio" v-model="fimMode" value="ate" class="h-4 w-4" />
	                                    Até
	                                    <input
	                                        v-if="fimMode === 'ate'"
	                                        v-model="data_fim"
	                                        type="text"
	                                        placeholder="dd/mm/aaaa"
	                                        inputmode="numeric"
	                                        class="h-10 w-36 rounded-xl border border-slate-200 bg-white px-3 text-center text-sm font-semibold text-slate-700 focus:outline-none focus:ring-2 focus:ring-emerald-100"
	                                    />
	                                </label>
	                            </div>

	                            <div v-if="recurrenceError" class="text-xs font-semibold text-red-500">
	                                {{ recurrenceError }}
	                            </div>
	                        </div>
	                    </div>
	                </div>
	            </div>

            <footer class="border-t border-slate-100 px-8 py-6">
                <button
                    type="button"
                    class="h-12 w-full rounded-xl text-sm font-semibold text-white shadow-lg"
                    :class="localKind === 'transfer' ? 'bg-blue-600 shadow-blue-500/20' : 'bg-[#14B8A6] shadow-emerald-500/20'"
                    @click="save"
                >
                    {{ localKind === 'transfer' ? 'Transferir' : 'Salvar' }}
                </button>
            </footer>
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
</style>
