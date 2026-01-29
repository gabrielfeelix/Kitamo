<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import { router } from '@inertiajs/vue3';
import ApplicationLogo from '@/Components/ApplicationLogo.vue';
import { formatMoneyInput, formatMoneyInputCentsShift, moneyInputToNumber } from '@/lib/moneyInput';
import { preventNonDigitKeydown, preventNonMoneyKeydownAllowNegative } from '@/lib/inputGuards';
import { requestJson } from '@/lib/kitamoApi';

type GoalKey = 'debt' | 'zero' | 'save' | 'organize';
type AccountKind = 'checking' | 'savings' | 'wallet';
type CardUsage = 'problem' | 'controlled' | 'no';

const props = defineProps<{
    open: boolean;
}>();

const emit = defineEmits<{
    (event: 'close'): void;
    (event: 'done'): void;
    (event: 'add-first-expense'): void;
}>();

const step = ref<1 | 2 | 3 | 4>(1);
const busy = ref(false);
const error = ref('');

// Step 1
const goal = ref<GoalKey | null>(null);
const goalOptions: Array<{ key: GoalKey; label: string }> = [
    { key: 'debt', label: 'Tô no vermelho (dívidas)' },
    { key: 'zero', label: 'Tô zerado todo mês' },
    { key: 'save', label: 'Quero juntar grana' },
    { key: 'organize', label: 'Só organizar melhor' },
];

// Step 2
const accountName = ref('');
const accountBalance = ref('');
const accountKind = ref<AccountKind>('checking');

// Step 3
const cardUsage = ref<CardUsage>('no');
const cardName = ref('');
const cardLimit = ref('');

const progressLabel = computed(() => {
    if (step.value === 1) return '1/3';
    if (step.value === 2) return '2/3';
    if (step.value === 3) return '3/3';
    return '';
});

const canContinueStep1 = computed(() => goal.value != null);
const canContinueStep2 = computed(() => accountName.value.trim().length > 0);
const needsCardDetails = computed(() => cardUsage.value !== 'no');
const canContinueStep3 = computed(() => {
    if (!needsCardDetails.value) return true;
    return cardName.value.trim().length > 0 && cardLimit.value.trim().length > 0;
});

const close = () => emit('close');

const goBack = () => {
    error.value = '';
    if (step.value === 3) step.value = 2;
    else if (step.value === 2) step.value = 1;
};

const skip = async () => {
    busy.value = true;
    error.value = '';
    try {
        await requestJson('/api/user/onboarding', { method: 'PATCH', body: JSON.stringify({ goal: goal.value }) });
        emit('done');
    } catch {
        error.value = 'Não foi possível pular agora. Tente novamente.';
    } finally {
        busy.value = false;
    }
};

const goNext = () => {
    error.value = '';
    if (step.value === 1 && canContinueStep1.value) step.value = 2;
    else if (step.value === 2 && canContinueStep2.value) step.value = 3;
};

const setAccountBalance = (raw: string) => {
    accountBalance.value = formatMoneyInput(raw);
};

const setCardLimit = (raw: string) => {
    cardLimit.value = formatMoneyInputCentsShift(raw);
};

const buildAccountPayload = () => {
    const name = accountName.value.trim();
    const balanceNumber = moneyInputToNumber(accountBalance.value || '0');

    if (accountKind.value === 'wallet') {
        return {
            name,
            type: 'wallet',
            icon: 'wallet',
            institution: null,
            bank_account_type: null,
            initial_balance: balanceNumber,
            color: '#14B8A6',
            incluir_soma: true,
            is_primary: true,
        };
    }

    const bankAccountType = accountKind.value === 'savings' ? 'poupanca' : 'corrente';
    return {
        name,
        type: 'bank',
        icon: 'bank',
        institution: name,
        bank_account_type: bankAccountType,
        initial_balance: balanceNumber,
        color: '#3B82F6',
        incluir_soma: true,
        is_primary: true,
    };
};

const buildCardPayload = () => {
    const cardLabel = cardName.value.trim();
    const limitNumber = moneyInputToNumber(cardLimit.value || '0');
    const institution =
        accountKind.value === 'wallet'
            ? (cardLabel || null)
            : (accountName.value.trim() || cardLabel || null);

    return {
        name: cardLabel,
        type: 'credit_card',
        icon: 'credit',
        institution,
        initial_balance: 0,
        credit_limit: Math.max(0, limitNumber),
        incluir_soma: false,
        is_primary: false,
    };
};

const saveSetupAndShowConfirmation = async () => {
    busy.value = true;
    error.value = '';
    try {
        await requestJson('/api/contas', {
            method: 'POST',
            body: JSON.stringify(buildAccountPayload()),
        });

        if (needsCardDetails.value) {
            await requestJson('/api/contas', {
                method: 'POST',
                body: JSON.stringify(buildCardPayload()),
            });
        }

        await requestJson('/api/user/onboarding', {
            method: 'PATCH',
            body: JSON.stringify({ goal: goal.value }),
        });

        step.value = 4;
    } catch {
        error.value = 'Não foi possível salvar suas configurações. Tente novamente.';
    } finally {
        busy.value = false;
    }
};

const finishAndOpenFirstExpense = () => {
    busy.value = true;
    error.value = '';
    router.reload({
        only: ['bootstrap'],
        onFinish: () => {
            emit('add-first-expense');
            emit('done');
            busy.value = false;
        },
    });
};

const summaryAccountLine = computed(() => {
    const name = accountName.value.trim();
    const value = accountBalance.value.trim() || '0,00';
    return `${name} · R$ ${value}`;
});

const summaryCardLine = computed(() => {
    const name = cardName.value.trim();
    const value = cardLimit.value.trim() || '0,00';
    return `${name} · Limite R$ ${value}`;
});

watch(
    () => props.open,
    (isOpen) => {
        if (!isOpen) return;
        step.value = 1;
        busy.value = false;
        error.value = '';

        goal.value = null;
        accountName.value = '';
        accountBalance.value = '';
        accountKind.value = 'checking';
        cardUsage.value = 'no';
        cardName.value = '';
        cardLimit.value = '';
    },
);
</script>

<template>
    <div v-if="open" class="fixed inset-0 z-[95] bg-white">
        <header class="flex items-center justify-between px-5 pt-[calc(1rem+env(safe-area-inset-top))]">
            <button v-if="step > 1 && step < 4" type="button" class="text-sm font-semibold text-slate-600" @click="goBack">Voltar</button>
            <button v-else-if="step < 4" type="button" class="text-sm font-semibold text-slate-400" :disabled="busy" @click="skip">Pular</button>
            <div v-else class="h-10"></div>

            <div class="flex items-center gap-3">
                <div v-if="progressLabel" class="text-xs font-bold text-slate-400">{{ progressLabel }}</div>
                <button
                    type="button"
                    class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-100 text-slate-600 disabled:opacity-60"
                    :disabled="busy"
                    @click="close"
                    aria-label="Fechar"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M18 6L6 18" />
                        <path d="M6 6l12 12" />
                    </svg>
                </button>
            </div>
        </header>

        <main class="mx-auto flex h-[calc(100vh-5rem)] w-full max-w-md min-h-0 flex-col px-6 pb-[calc(2rem+env(safe-area-inset-bottom))]">
            <!-- Step 1 -->
            <div v-if="step === 1" class="flex flex-1 min-h-0 flex-col">
                <div class="mt-6 flex justify-center">
                    <div class="flex h-16 w-16 items-center justify-center rounded-3xl bg-slate-50 ring-1 ring-slate-200/60">
                        <ApplicationLogo class="h-10 w-10 text-slate-900" />
                    </div>
                </div>

                <div class="mt-8 text-center text-2xl font-semibold tracking-tight text-slate-900">Fala! Vamos começar? 🤟</div>
                <div class="mt-6 text-center text-sm font-semibold text-slate-600">Qual seu maior desafio com dinheiro agora?</div>

                <div class="mt-6 space-y-3">
                    <button
                        v-for="opt in goalOptions"
                        :key="opt.key"
                        type="button"
                        class="w-full rounded-2xl border px-4 py-4 text-left text-sm font-semibold transition"
                        :class="goal === opt.key ? 'border-[#14B8A6] bg-[#E6FFFB] text-[#0F766E]' : 'border-slate-200 bg-white text-slate-800 hover:bg-slate-50'"
                        @click="goal = opt.key"
                    >
                        {{ opt.label }}
                    </button>
                </div>

                <div v-if="error" class="mt-4 rounded-2xl bg-red-50 px-4 py-3 text-sm font-semibold text-red-600">
                    {{ error }}
                </div>

                <div class="mt-auto pt-6">
                    <button
                        type="button"
                        class="w-full rounded-2xl bg-[#14B8A6] py-4 text-base font-semibold text-white shadow-lg shadow-teal-500/25 disabled:cursor-not-allowed disabled:opacity-50"
                        :disabled="busy || !canContinueStep1"
                        @click="goNext"
                    >
                        Continuar
                    </button>
                </div>
            </div>

            <!-- Step 2 -->
            <div v-else-if="step === 2" class="flex flex-1 min-h-0 flex-col">
                <div class="mt-6 text-xl font-semibold tracking-tight text-slate-900">Qual sua conta principal?</div>
                <div class="mt-1 text-sm font-semibold text-slate-500">(onde cai seu salário)</div>

                <div class="mt-6 space-y-5">
                    <div>
                        <label class="text-xs font-semibold text-slate-500">Nome da conta</label>
                        <input
                            v-model="accountName"
                            type="text"
                            class="mt-2 h-12 w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 text-sm font-semibold text-slate-700 focus:border-emerald-200 focus:outline-none focus:ring-2 focus:ring-emerald-100"
                            placeholder='Ex: "Nubank", "Itaú", "Carteira"'
                            maxlength="60"
                            autocomplete="off"
                        />
                    </div>

                    <div>
                        <label class="text-xs font-semibold text-slate-500">Quanto tem nela AGORA?</label>
                        <div class="mt-2 flex h-12 items-center gap-2 rounded-2xl bg-slate-50 px-4 ring-1 ring-slate-200/60">
                            <span class="text-sm font-semibold text-slate-500">R$</span>
                            <input
                                :value="accountBalance"
                                type="text"
                                inputmode="decimal"
                                placeholder="0,00"
                                class="w-full bg-transparent text-right text-base font-semibold text-slate-900 outline-none"
                                @keydown="preventNonMoneyKeydownAllowNegative"
                                @input="(e) => setAccountBalance((e.target as HTMLInputElement).value)"
                            />
                        </div>
                        <div class="mt-2 text-xs font-semibold text-slate-400">(pode ser negativo se tá no cheque especial)</div>
                    </div>

                    <div>
                        <div class="text-xs font-semibold text-slate-500">Tipo de conta</div>
                        <div class="mt-3 space-y-2">
                            <label class="flex items-center gap-3 rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-700">
                                <input v-model="accountKind" type="radio" value="checking" class="h-4 w-4 text-[#14B8A6]" />
                                Conta corrente
                            </label>
                            <label class="flex items-center gap-3 rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-700">
                                <input v-model="accountKind" type="radio" value="savings" class="h-4 w-4 text-[#14B8A6]" />
                                Poupança
                            </label>
                            <label class="flex items-center gap-3 rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-700">
                                <input v-model="accountKind" type="radio" value="wallet" class="h-4 w-4 text-[#14B8A6]" />
                                Carteira (dinheiro físico)
                            </label>
                        </div>
                    </div>
                </div>

                <div v-if="error" class="mt-4 rounded-2xl bg-red-50 px-4 py-3 text-sm font-semibold text-red-600">
                    {{ error }}
                </div>

                <div class="mt-auto pt-6">
                    <button
                        type="button"
                        class="w-full rounded-2xl bg-[#14B8A6] py-4 text-base font-semibold text-white shadow-lg shadow-teal-500/25 disabled:cursor-not-allowed disabled:opacity-50"
                        :disabled="busy || !canContinueStep2"
                        @click="goNext"
                    >
                        Continuar
                    </button>
                </div>
            </div>

            <!-- Step 3 -->
            <div v-else-if="step === 3" class="flex flex-1 min-h-0 flex-col">
                <div class="mt-6 text-xl font-semibold tracking-tight text-slate-900">Você usa cartão de crédito?</div>

                <div class="mt-6 space-y-2">
                    <label class="flex items-center gap-3 rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-700">
                        <input v-model="cardUsage" type="radio" value="problem" class="h-4 w-4 text-[#14B8A6]" />
                        Sim, e é meu maior problema
                    </label>
                    <label class="flex items-center gap-3 rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-700">
                        <input v-model="cardUsage" type="radio" value="controlled" class="h-4 w-4 text-[#14B8A6]" />
                        Sim, mas tá controlado
                    </label>
                    <label class="flex items-center gap-3 rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-700">
                        <input v-model="cardUsage" type="radio" value="no" class="h-4 w-4 text-[#14B8A6]" />
                        Não uso
                    </label>
                </div>

                <div v-if="needsCardDetails" class="mt-6 space-y-5">
                    <div>
                        <label class="text-xs font-semibold text-slate-500">Nome do cartão</label>
                        <input
                            v-model="cardName"
                            type="text"
                            class="mt-2 h-12 w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 text-sm font-semibold text-slate-700 focus:border-emerald-200 focus:outline-none focus:ring-2 focus:ring-emerald-100"
                            placeholder='Ex: "Nubank Roxo"'
                            maxlength="60"
                            autocomplete="off"
                        />
                    </div>

                    <div>
                        <label class="text-xs font-semibold text-slate-500">Qual o limite total do cartão?</label>
                        <div class="mt-2 flex h-12 items-center gap-2 rounded-2xl bg-slate-50 px-4 ring-1 ring-slate-200/60">
                            <span class="text-sm font-semibold text-slate-500">R$</span>
                            <input
                                :value="cardLimit"
                                type="text"
                                inputmode="numeric"
                                pattern="[0-9]*"
                                placeholder="0,00"
                                class="w-full bg-transparent text-right text-base font-semibold text-slate-900 outline-none"
                                @keydown="preventNonDigitKeydown"
                                @input="(e) => setCardLimit((e.target as HTMLInputElement).value)"
                            />
                        </div>
                    </div>
                </div>

                <div v-if="error" class="mt-4 rounded-2xl bg-red-50 px-4 py-3 text-sm font-semibold text-red-600">
                    {{ error }}
                </div>

                <div class="mt-auto pt-6">
                    <button
                        type="button"
                        class="w-full rounded-2xl bg-[#14B8A6] py-4 text-base font-semibold text-white shadow-lg shadow-teal-500/25 disabled:cursor-not-allowed disabled:opacity-50"
                        :disabled="busy || !canContinueStep3"
                        @click="saveSetupAndShowConfirmation"
                    >
                        {{ busy ? 'Salvando…' : 'Concluir' }}
                    </button>
                </div>
            </div>

            <!-- Step 4 -->
            <div v-else class="flex flex-1 min-h-0 flex-col justify-center text-center">
                <div class="mx-auto flex h-14 w-14 items-center justify-center rounded-3xl bg-emerald-50 text-emerald-700 ring-1 ring-emerald-100">
                    ✅
                </div>
                <div class="mt-5 text-2xl font-semibold tracking-tight text-slate-900">Pronto!</div>

                <div class="mt-6 rounded-3xl bg-slate-50 p-4 text-left ring-1 ring-slate-200/60">
                    <div class="text-xs font-bold uppercase tracking-wide text-slate-400">Resumo</div>
                    <div class="mt-2 text-sm font-semibold text-slate-900">{{ summaryAccountLine }}</div>
                    <div v-if="needsCardDetails" class="mt-2 text-sm font-semibold text-slate-900">{{ summaryCardLine }}</div>

                    <div class="my-4 h-px bg-slate-200/70"></div>

                    <div class="text-sm font-semibold text-slate-700">
                        Agora bora lançar seus gastos pra gente te mostrar se vai dar até o fim do mês!
                    </div>
                </div>

                <div v-if="error" class="mt-4 rounded-2xl bg-red-50 px-4 py-3 text-sm font-semibold text-red-600">
                    {{ error }}
                </div>

                <button
                    type="button"
                    class="mt-6 w-full rounded-2xl bg-[#14B8A6] py-4 text-base font-semibold text-white shadow-lg shadow-teal-500/25 disabled:cursor-not-allowed disabled:opacity-50"
                    :disabled="busy"
                    @click="finishAndOpenFirstExpense"
                >
                    {{ busy ? 'Carregando…' : 'Adicionar meu primeiro gasto' }}
                </button>
            </div>
        </main>
    </div>
</template>

