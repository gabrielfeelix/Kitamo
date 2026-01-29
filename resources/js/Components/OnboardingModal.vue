<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import { router } from '@inertiajs/vue3';
import ApplicationLogo from '@/Components/ApplicationLogo.vue';
import InstitutionAvatar from '@/Components/InstitutionAvatar.vue';
import InstitutionPickerModal, { type InstitutionPick } from '@/Components/InstitutionPickerModal.vue';
import { getBankSvgPath } from '@/lib/bankLogos';
import { formatMoneyInputCentsShiftAllowNegative, moneyInputToNumber } from '@/lib/moneyInput';
import { preventNonDigitKeydown, preventNonMoneyKeydownAllowNegative } from '@/lib/inputGuards';
import { requestJson } from '@/lib/kitamoApi';

type GoalKey = 'debt' | 'zero' | 'save' | 'organize';
type AccountKind = 'checking' | 'savings' | 'wallet';
type CardUsage = 'problem' | 'controlled' | 'no';
type CardBrand = 'visa' | 'mastercard' | 'elo' | 'amex';

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
const accountKind = ref<AccountKind>('checking');
const accountInstitution = ref<string | null>(null);
const accountColor = ref<string>('#3B82F6');
const accountDescription = ref('');
const accountBalance = ref('');
const accountInstitutionPickerOpen = ref(false);
const accountInstitutionSvgPath = computed(() => (accountInstitution.value ? getBankSvgPath(accountInstitution.value) : null));

// Step 3
const cardUsage = ref<CardUsage>('no');
const cardInstitution = ref<string | null>(null);
const cardInstitutionPickerOpen = ref(false);
const cardInstitutionSvgPath = computed(() => (cardInstitution.value ? getBankSvgPath(cardInstitution.value) : null));
const cardName = ref('');
const cardBrand = ref<CardBrand>('visa');
const cardLimit = ref('');
const cardClosingDay = ref<number>(10);
const cardDueDay = ref<number>(17);
const cardColor = ref<string>('#8B5CF6');
const cardBrands: Array<{ id: CardBrand; label: string }> = [
    { id: 'visa', label: 'Visa' },
    { id: 'mastercard', label: 'Mastercard' },
    { id: 'elo', label: 'Elo' },
    { id: 'amex', label: 'Amex' },
];
const days = Array.from({ length: 31 }, (_, idx) => idx + 1);

const progressLabel = computed(() => {
    if (step.value === 1) return '1/3';
    if (step.value === 2) return '2/3';
    if (step.value === 3) return '3/3';
    return '';
});

const canContinueStep1 = computed(() => goal.value != null);
const canContinueStep2 = computed(() => {
    if (accountKind.value === 'wallet') return true;
    return Boolean(accountInstitution.value);
});
const needsCardDetails = computed(() => cardUsage.value !== 'no');
const canContinueStep3 = computed(() => {
    if (!needsCardDetails.value) return true;
    return (
        Boolean(cardInstitution.value) &&
        cardName.value.trim().length > 0 &&
        Number(cardClosingDay.value) >= 1 &&
        Number(cardDueDay.value) >= 1
    );
});

const dismiss = async () => {
    busy.value = true;
    error.value = '';
    try {
        await requestJson('/api/user/onboarding', { method: 'POST' });
        emit('done');
        emit('close');
    } catch {
        error.value = 'Não foi possível pular agora. Tente novamente.';
    } finally {
        busy.value = false;
    }
};

const handlePickAccountInstitution = (pick: InstitutionPick) => {
    accountInstitution.value = pick.nome;
    accountColor.value = pick.color;
    accountInstitutionPickerOpen.value = false;
};

const handlePickCardInstitution = (pick: InstitutionPick) => {
    cardInstitution.value = pick.nome;
    cardInstitutionPickerOpen.value = false;
};

const goBack = () => {
    error.value = '';
    if (step.value === 3) step.value = 2;
    else if (step.value === 2) step.value = 1;
};

const goNext = () => {
    error.value = '';
    if (step.value === 1 && canContinueStep1.value) step.value = 2;
    else if (step.value === 2 && canContinueStep2.value) step.value = 3;
};

const setAccountBalance = (raw: string) => {
    if (!raw.trim()) {
        accountBalance.value = '';
        return;
    }
    if (raw.trim() === '-') {
        accountBalance.value = '-';
        return;
    }
    accountBalance.value = formatMoneyInputCentsShiftAllowNegative(raw, false);
};

const setCardLimit = (raw: string) => {
    if (!raw.trim()) {
        cardLimit.value = '';
        return;
    }
    cardLimit.value = formatMoneyInputCentsShiftAllowNegative(raw.replace(/^-/, ''), true);
};

const buildAccountPayload = () => {
    const baseName = accountKind.value === 'wallet' ? 'Carteira' : (accountInstitution.value ?? '');
    const suffix = accountDescription.value.trim() ? ` - ${accountDescription.value.trim()}` : '';
    const name = `${baseName}${suffix}`.trim();
    const balanceNumber = moneyInputToNumber(accountBalance.value || '0,00');

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
        institution: accountInstitution.value,
        bank_account_type: bankAccountType,
        initial_balance: balanceNumber,
        color: accountColor.value,
        incluir_soma: true,
        is_primary: true,
    };
};

const buildCardPayload = () => {
    const limitNumber = Math.max(0, moneyInputToNumber(cardLimit.value || '0,00'));
    return {
        nome: cardName.value.trim(),
        bandeira: cardBrand.value,
        limite: limitNumber,
        dia_fechamento: Number(cardClosingDay.value) || 10,
        dia_vencimento: Number(cardDueDay.value) || 17,
        cor: cardColor.value,
        icone: 'credit-card',
        institution: cardInstitution.value,
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
            await requestJson('/api/cartoes', {
                method: 'POST',
                body: JSON.stringify(buildCardPayload()),
            });
        }

        await requestJson('/api/user/onboarding', {
            method: 'POST',
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
    const baseName = accountKind.value === 'wallet' ? 'Carteira' : (accountInstitution.value ?? '');
    const suffix = accountDescription.value.trim() ? ` - ${accountDescription.value.trim()}` : '';
    const name = `${baseName}${suffix}`.trim();
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
        accountKind.value = 'checking';
        accountInstitution.value = null;
        accountColor.value = '#3B82F6';
        accountDescription.value = '';
        accountBalance.value = '';
        accountInstitutionPickerOpen.value = false;
        cardUsage.value = 'no';
        cardInstitution.value = null;
        cardInstitutionPickerOpen.value = false;
        cardName.value = '';
        cardBrand.value = 'visa';
        cardLimit.value = '';
        cardClosingDay.value = 10;
        cardDueDay.value = 17;
        cardColor.value = '#8B5CF6';
    },
);
</script>

<template>
    <div v-if="open" class="fixed inset-0 z-[95] bg-white">
        <header class="flex items-center justify-between px-5 pt-[calc(1rem+env(safe-area-inset-top))]">
            <button v-if="step > 1 && step < 4" type="button" class="text-sm font-semibold text-slate-600" @click="goBack">Voltar</button>
            <div v-else class="h-6"></div>

            <div class="flex items-center gap-3">
                <div v-if="progressLabel" class="text-xs font-bold text-slate-400">{{ progressLabel }}</div>
                <button
                    type="button"
                    class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-100 text-slate-600 disabled:opacity-60"
                    :disabled="busy"
                    @click="dismiss"
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
                    <button
                        type="button"
                        class="mt-4 w-full text-center text-sm font-semibold text-slate-400 transition hover:text-slate-600 disabled:opacity-50"
                        :disabled="busy"
                        @click="dismiss"
                    >
                        Pular
                    </button>
                </div>
            </div>

            <!-- Step 2 -->
            <div v-else-if="step === 2" class="flex flex-1 min-h-0 flex-col">
                <div class="mt-6 text-xl font-semibold tracking-tight text-slate-900">Qual sua conta principal?</div>
                <div class="mt-1 text-sm font-semibold text-slate-500">(onde cai seu salário)</div>
                <div class="mt-6 flex-1 min-h-0 overflow-y-auto pb-6">
                    <div class="space-y-5">
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

                        <div v-if="accountKind !== 'wallet'">
                            <div class="mb-2 text-xs font-semibold text-slate-500">Instituição financeira</div>
                            <button
                                type="button"
                                class="flex h-14 w-full items-center justify-between rounded-2xl border border-slate-200 bg-slate-50 px-4 text-left"
                                @click="accountInstitutionPickerOpen = true"
                            >
                                <div class="flex min-w-0 items-center gap-3">
                                    <InstitutionAvatar
                                        :institution="accountInstitution"
                                        :svg-path="accountInstitutionSvgPath"
                                        fallback-icon="account"
                                        container-class="flex h-10 w-10 items-center justify-center overflow-hidden rounded-2xl bg-white"
                                        img-class="h-7 w-7 object-contain"
                                        fallback-icon-class="h-5 w-5 text-slate-500"
                                    />
                                    <div class="min-w-0">
                                        <div class="truncate text-sm font-semibold text-slate-900">
                                            {{ accountInstitution ?? 'Selecione o banco' }}
                                        </div>
                                        <div class="text-xs font-semibold text-slate-400">Toque para escolher</div>
                                    </div>
                                </div>
                                <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M9 18l6-6-6-6" />
                                </svg>
                            </button>
                        </div>

                        <div>
                            <label class="text-xs font-semibold text-slate-500">Descrição (opcional)</label>
                            <input
                                v-model="accountDescription"
                                type="text"
                                class="mt-2 h-12 w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 text-sm font-semibold text-slate-700 focus:border-emerald-200 focus:outline-none focus:ring-2 focus:ring-emerald-100"
                                placeholder="Ex: Conta salário, Conta pessoal..."
                                maxlength="80"
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
                                    class="w-full appearance-none border-0 bg-transparent p-0 text-right text-base font-semibold text-slate-900 outline-none"
                                    @keydown="preventNonMoneyKeydownAllowNegative"
                                    @input="(e) => setAccountBalance((e.target as HTMLInputElement).value)"
                                />
                            </div>
                            <div class="mt-2 text-xs font-semibold text-slate-400">(pode ser negativo se tá no cheque especial)</div>
                        </div>

                        <div v-if="error" class="rounded-2xl bg-red-50 px-4 py-3 text-sm font-semibold text-red-600">
                            {{ error }}
                        </div>
                    </div>
                </div>

                <div class="shrink-0 pt-2">
                    <button
                        type="button"
                        class="w-full rounded-2xl bg-[#14B8A6] py-4 text-base font-semibold text-white shadow-lg shadow-teal-500/25 disabled:cursor-not-allowed disabled:opacity-50"
                        :disabled="busy || !canContinueStep2"
                        @click="goNext"
                    >
                        Continuar
                    </button>
                    <button
                        type="button"
                        class="mt-3 w-full text-center text-sm font-semibold text-slate-400 transition hover:text-slate-600 disabled:opacity-50"
                        :disabled="busy"
                        @click="dismiss"
                    >
                        Pular
                    </button>
                </div>
            </div>

            <!-- Step 3 -->
            <div v-else-if="step === 3" class="flex flex-1 min-h-0 flex-col">
                <div class="mt-6 text-xl font-semibold tracking-tight text-slate-900">Você usa cartão de crédito?</div>
                <div class="mt-6 flex-1 min-h-0 overflow-y-auto pb-6">
                    <div class="space-y-5">
                        <div class="space-y-2">
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

                        <div v-if="needsCardDetails" class="space-y-5">
                            <div>
                                <div class="mb-2 text-xs font-semibold text-slate-500">Instituição financeira</div>
                                <button
                                    type="button"
                                    class="flex h-14 w-full items-center justify-between rounded-2xl border border-slate-200 bg-slate-50 px-4 text-left"
                                    @click="cardInstitutionPickerOpen = true"
                                >
                                    <div class="flex min-w-0 items-center gap-3">
                                        <InstitutionAvatar
                                            :institution="cardInstitution"
                                            :svg-path="cardInstitutionSvgPath"
                                            fallback-icon="account"
                                            container-class="flex h-10 w-10 items-center justify-center overflow-hidden rounded-2xl bg-white"
                                            img-class="h-7 w-7 object-contain"
                                            fallback-icon-class="h-5 w-5 text-slate-500"
                                        />
                                        <div class="min-w-0">
                                            <div class="truncate text-sm font-semibold text-slate-900">
                                                {{ cardInstitution ?? 'Selecione o banco' }}
                                            </div>
                                            <div class="text-xs font-semibold text-slate-400">Toque para escolher</div>
                                        </div>
                                    </div>
                                    <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M9 18l6-6-6-6" />
                                    </svg>
                                </button>
                            </div>

                            <div>
                                <label class="text-xs font-semibold text-slate-500">Apelido do cartão</label>
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
                                <div class="text-xs font-semibold text-slate-500">Bandeira</div>
                                <div class="mt-3 grid grid-cols-4 gap-3">
                                    <button
                                        v-for="b in cardBrands"
                                        :key="b.id"
                                        type="button"
                                        class="flex h-14 items-center justify-center rounded-xl border-2 text-xs font-semibold transition"
                                        :class="cardBrand === b.id ? 'border-[#14B8A6] bg-teal-50 text-[#14B8A6]' : 'border-[#E5E7EB] bg-white text-[#6B7280]'"
                                        @click="cardBrand = b.id"
                                    >
                                        {{ b.label }}
                                    </button>
                                </div>
                            </div>

                            <div>
                                <label class="text-xs font-semibold text-slate-500">Limite total</label>
                                <div class="mt-2 flex h-12 items-center gap-2 rounded-2xl bg-slate-50 px-4 ring-1 ring-slate-200/60">
                                    <span class="text-sm font-semibold text-slate-500">R$</span>
                                    <input
                                        :value="cardLimit"
                                        type="text"
                                        inputmode="numeric"
                                        pattern="[0-9]*"
                                        placeholder="0,00"
                                        class="w-full appearance-none border-0 bg-transparent p-0 text-right text-base font-semibold text-slate-900 outline-none"
                                        @keydown="preventNonDigitKeydown"
                                        @input="(e) => setCardLimit((e.target as HTMLInputElement).value)"
                                    />
                                </div>
                            </div>

                            <div>
                                <div class="text-xs font-semibold text-slate-500">Datas</div>
                                <div class="mt-3 grid grid-cols-2 gap-3">
                                    <div>
                                        <label class="mb-2 block text-xs font-semibold text-slate-400">Fechamento</label>
                                        <div class="relative rounded-2xl border border-slate-200 bg-slate-50">
                                            <select
                                                v-model="cardClosingDay"
                                                class="h-12 w-full appearance-none rounded-2xl border-0 bg-transparent bg-none px-4 pr-10 text-sm font-semibold text-slate-700 focus:outline-none focus-visible:outline-none focus:ring-0"
                                            >
                                                <option v-for="d in days" :key="d" :value="d">{{ d }}</option>
                                            </select>
                                            <span class="pointer-events-none absolute inset-y-0 right-4 flex items-center text-slate-400">
                                                <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                    <path d="M6 9l6 6 6-6" />
                                                </svg>
                                            </span>
                                        </div>
                                    </div>
                                    <div>
                                        <label class="mb-2 block text-xs font-semibold text-slate-400">Vencimento</label>
                                        <div class="relative rounded-2xl border border-slate-200 bg-slate-50">
                                            <select
                                                v-model="cardDueDay"
                                                class="h-12 w-full appearance-none rounded-2xl border-0 bg-transparent bg-none px-4 pr-10 text-sm font-semibold text-slate-700 focus:outline-none focus-visible:outline-none focus:ring-0"
                                            >
                                                <option v-for="d in days" :key="d" :value="d">{{ d }}</option>
                                            </select>
                                            <span class="pointer-events-none absolute inset-y-0 right-4 flex items-center text-slate-400">
                                                <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                    <path d="M6 9l6 6 6-6" />
                                                </svg>
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div v-if="error" class="rounded-2xl bg-red-50 px-4 py-3 text-sm font-semibold text-red-600">
                            {{ error }}
                        </div>
                    </div>
                </div>

                <div class="shrink-0 pt-2">
                    <button
                        type="button"
                        class="w-full rounded-2xl bg-[#14B8A6] py-4 text-base font-semibold text-white shadow-lg shadow-teal-500/25 disabled:cursor-not-allowed disabled:opacity-50"
                        :disabled="busy || !canContinueStep3"
                        @click="saveSetupAndShowConfirmation"
                    >
                        {{ busy ? 'Salvando…' : 'Concluir' }}
                    </button>
                    <button
                        type="button"
                        class="mt-3 w-full text-center text-sm font-semibold text-slate-400 transition hover:text-slate-600 disabled:opacity-50"
                        :disabled="busy"
                        @click="dismiss"
                    >
                        Pular
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
	                        Agora bora registrar seus gastos pra gente te ajudar a chegar no fim do mês com tranquilidade.
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

        <InstitutionPickerModal
            :open="accountInstitutionPickerOpen"
            title="Escolher banco"
            :selected="accountInstitution"
            @close="accountInstitutionPickerOpen = false"
            @select="handlePickAccountInstitution"
        />
        <InstitutionPickerModal
            :open="cardInstitutionPickerOpen"
            title="Escolher banco do cartão"
            :selected="cardInstitution"
            @close="cardInstitutionPickerOpen = false"
            @select="handlePickCardInstitution"
        />
    </div>
</template>
