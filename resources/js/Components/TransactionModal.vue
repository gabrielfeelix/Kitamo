<script setup lang="ts">
import { computed, ref, watch } from 'vue';

type TransactionKind = 'expense' | 'income';

const props = defineProps<{
    open: boolean;
    kind: TransactionKind;
}>();

const emit = defineEmits<{
    (event: 'close'): void;
}>();

const title = computed(() =>
    props.kind === 'expense' ? 'NOVA DESPESA' : 'NOVA RECEITA',
);
const accentColor = computed(() =>
    props.kind === 'expense' ? 'text-red-300' : 'text-emerald-300',
);
const primaryButtonClass = computed(() =>
    props.kind === 'expense'
        ? 'bg-red-500 hover:bg-red-600'
        : 'bg-emerald-500 hover:bg-emerald-600',
);
const primaryButtonLabel = computed(() =>
    props.kind === 'expense' ? 'Pagar Agora' : 'Receber Agora',
);

const status = ref<'primary' | 'pending'>('primary');
const amount = ref('0,00');
const description = ref('');
const repeatMonthly = ref(false);

const statusLabels = computed(() =>
    props.kind === 'expense'
        ? { primary: 'Pago', pending: 'Pendente' }
        : { primary: 'Recebido', pending: 'Pendente' },
);

const normalizeMoneyInput = (raw: string) => {
    const digits = raw.replace(/[^\d]/g, '');
    const padded = digits.padStart(3, '0');
    const cents = padded.slice(-2);
    const whole = padded.slice(0, -2).replace(/^0+/, '') || '0';
    return `${whole},${cents}`;
};

const onAmountInput = (event: Event) => {
    const target = event.target as HTMLInputElement;
    amount.value = normalizeMoneyInput(target.value);
};

watch(
    () => props.open,
    (isOpen) => {
        if (!isOpen) return;
        status.value = 'primary';
        amount.value = '0,00';
        description.value = '';
        repeatMonthly.value = false;
    },
);
</script>

<template>
    <div v-if="open" class="fixed inset-0 z-[60]">
        <button
            class="absolute inset-0 bg-slate-900/35 backdrop-blur-sm"
            type="button"
            @click="emit('close')"
            aria-label="Fechar"
        ></button>

        <div class="relative flex min-h-full items-center justify-center p-4">
            <div class="w-full max-w-[520px] overflow-hidden rounded-[32px] bg-white shadow-2xl">
                <div class="flex items-center justify-between border-b border-slate-100 px-6 py-5">
                    <button
                        class="rounded-2xl p-2 text-slate-400 hover:bg-slate-100"
                        type="button"
                        @click="emit('close')"
                        aria-label="Fechar"
                    >
                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M18 6L6 18" />
                            <path d="M6 6l12 12" />
                        </svg>
                    </button>
                    <div class="text-sm font-semibold tracking-wide text-slate-500">
                        {{ title }}
                    </div>
                    <div class="h-9 w-9"></div>
                </div>

                <div class="px-10 py-8">
                    <div class="flex items-end justify-center gap-4">
                        <div class="text-2xl font-semibold" :class="accentColor">R$</div>
                        <input
                            class="w-[240px] bg-transparent text-center text-6xl font-semibold tracking-tight text-slate-400 focus:outline-none"
                            inputmode="numeric"
                            autocomplete="off"
                            spellcheck="false"
                            :value="amount"
                            @input="onAmountInput"
                            aria-label="Valor"
                        />
                    </div>

                    <div class="mt-6 flex justify-center">
                        <div class="inline-flex rounded-full bg-slate-100 p-1">
                            <button
                                class="rounded-full px-6 py-2 text-sm font-semibold"
                                type="button"
                                :class="status === 'primary' ? (kind === 'expense' ? 'bg-red-500 text-white' : 'bg-emerald-500 text-white') : 'text-slate-500'"
                                @click="status = 'primary'"
                            >
                                {{ statusLabels.primary }}
                            </button>
                            <button
                                class="rounded-full px-6 py-2 text-sm font-semibold"
                                type="button"
                                :class="status === 'pending' ? 'bg-white text-slate-700 shadow-sm' : 'text-slate-500'"
                                @click="status = 'pending'"
                            >
                                {{ statusLabels.pending }}
                            </button>
                        </div>
                    </div>

                    <div class="mt-8 space-y-4">
                        <button
                            class="flex w-full items-center justify-between rounded-2xl bg-slate-50 px-5 py-4 text-left"
                            type="button"
                        >
                            <div class="flex items-center gap-4">
                                <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-white text-slate-400 shadow-sm">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M20 12v7a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h7" />
                                        <path d="M16 3h5v5" />
                                        <path d="M21 3l-8 8" />
                                    </svg>
                                </span>
                                <div class="text-sm font-semibold text-slate-700">Categoria</div>
                            </div>
                            <div class="flex items-center gap-3 text-sm font-semibold text-slate-400">
                                Selecione
                                <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M9 18l6-6-6-6" />
                                </svg>
                            </div>
                        </button>

                        <button
                            class="flex w-full items-center justify-between rounded-2xl bg-slate-50 px-5 py-4 text-left"
                            type="button"
                        >
                            <div class="flex items-center gap-4">
                                <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-white text-slate-400 shadow-sm">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <rect x="3" y="5" width="18" height="14" rx="3" />
                                        <path d="M3 10h18" />
                                    </svg>
                                </span>
                                <div class="text-sm font-semibold text-slate-700">Conta</div>
                            </div>
                            <div class="flex items-center gap-3 text-sm font-semibold text-slate-400">
                                Nubank C/C
                                <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M9 18l6-6-6-6" />
                                </svg>
                            </div>
                        </button>

                        <div class="flex items-center gap-4 rounded-2xl bg-slate-50 px-5 py-4">
                            <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-white text-slate-300 shadow-sm">
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M7 3h8l4 4v14H7z" />
                                    <path d="M15 3v4h4" />
                                </svg>
                            </span>
                            <input
                                v-model="description"
                                type="text"
                                class="w-full bg-transparent text-sm font-semibold text-slate-500 placeholder:text-slate-300 focus:outline-none"
                                placeholder="Descrição (opcional)"
                            />
                        </div>

                        <label class="flex items-center gap-3 px-1 pt-2 text-sm font-semibold text-slate-600">
                            <input v-model="repeatMonthly" type="checkbox" class="h-5 w-5 rounded border-slate-300 text-blue-600 focus:ring-blue-500" />
                            Repetir todo mês
                        </label>
                    </div>
                </div>

                <div class="border-t border-slate-100 p-6">
                    <button
                        class="flex w-full items-center justify-center gap-2 rounded-2xl py-4 text-base font-semibold text-white shadow-sm transition"
                        :class="primaryButtonClass"
                        type="button"
                    >
                        <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M21 12a9 9 0 1 1-9-9" />
                            <path d="M16 3h5v5" />
                            <path d="M21 3l-9 9" />
                        </svg>
                        {{ primaryButtonLabel }}
                    </button>
                </div>
            </div>
        </div>
    </div>
</template>

