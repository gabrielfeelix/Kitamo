<script setup lang="ts">
import { computed, ref, watch } from 'vue';

const props = defineProps<{
    open: boolean;
    accent?: 'teal' | 'blue';
}>();

const emit = defineEmits<{
    (event: 'close'): void;
    (event: 'confirm', payload: { amount: string; from: string; repeat: boolean }): void;
}>();

const close = () => emit('close');

const amount = ref('0,00');
const from = ref('Banco Inter');
const repeat = ref(false);

watch(
    () => props.open,
    (isOpen) => {
        if (!isOpen) return;
        amount.value = '0,00';
        from.value = 'Banco Inter';
        repeat.value = false;
    },
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

const accentBg = computed(() => (props.accent === 'blue' ? 'bg-[#3B82F6]' : 'bg-[#14B8A6]'));
const accentShadow = computed(() => (props.accent === 'blue' ? 'shadow-[0_2px_8px_rgba(59,130,246,0.25)]' : 'shadow-[0_2px_8px_rgba(20,184,166,0.25)]'));
</script>

<template>
    <div v-if="open" class="fixed inset-0 z-[80]">
        <button class="absolute inset-0 bg-black/50 backdrop-blur-sm" type="button" @click="close" aria-label="Fechar"></button>

        <div class="absolute inset-x-0 bottom-0 h-[650px] max-h-[calc(100vh-150px)] w-full overflow-hidden rounded-t-[24px] bg-white shadow-[0_-4px_20px_rgba(0,0,0,0.25)]">
            <div class="flex h-full flex-col">
                <header class="relative flex h-14 items-center px-4">
                    <button class="h-10 w-10 rounded-full bg-slate-100 text-slate-500" type="button" @click="close" aria-label="Fechar">
                        <svg class="mx-auto h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M18 6L6 18" />
                            <path d="M6 6l12 12" />
                        </svg>
                    </button>
                    <div class="pointer-events-none absolute inset-0 flex items-center justify-center">
                        <div class="text-[16px] font-bold text-[#1F2937]">Adicionar dinheiro</div>
                    </div>
                </header>

                <div class="flex-1 overflow-y-auto px-6 pb-6">
                    <div class="mt-2">
                        <div class="flex h-[120px] items-center">
                            <div class="w-10 text-base text-[#6B7280]">R$</div>
                            <input
                                class="amount-input h-[72px] w-full flex-1 bg-transparent text-center text-[56px] font-bold leading-none tracking-tight focus:outline-none focus:ring-0"
                                inputmode="numeric"
                                autocomplete="off"
                                spellcheck="false"
                                :value="amount"
                                @input="onAmountInput"
                                aria-label="Valor"
                            />
                            <div class="w-10"></div>
                        </div>
                    </div>

                    <div class="mt-2 space-y-4">
                        <div>
                            <div class="mb-2 text-sm font-bold text-[#374151]">Retirar de</div>
                            <button type="button" class="flex w-full items-center justify-between rounded-2xl border border-slate-200 bg-white px-4 py-4 text-left shadow-sm">
                                <div>
                                    <div class="text-sm font-semibold text-slate-900">{{ from }}</div>
                                    <div class="mt-1 text-xs font-semibold text-slate-400">Saldo: R$ 1.450,00</div>
                                </div>
                                <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M9 18l6-6-6-6" />
                                </svg>
                            </button>
                        </div>

                        <div class="flex items-center justify-between rounded-2xl border border-slate-200 bg-white px-4 py-4">
                            <div class="flex items-center gap-3">
                                <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-blue-50 text-blue-600">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <rect x="3" y="4" width="18" height="18" rx="3" />
                                        <path d="M8 2v4" />
                                        <path d="M16 2v4" />
                                        <path d="M3 10h18" />
                                    </svg>
                                </span>
                                <div class="text-sm font-semibold text-slate-900">Repetir esse depósito mensalmente?</div>
                            </div>
                            <input v-model="repeat" type="checkbox" class="h-5 w-5 rounded-md border-slate-300 text-blue-600" />
                        </div>
                    </div>
                </div>

                <footer class="px-6 pt-4 pb-[calc(24px+env(safe-area-inset-bottom))]">
                    <button
                        type="button"
                        class="h-[52px] w-full rounded-2xl text-base font-bold text-white"
                        :class="[accentBg, accentShadow]"
                        @click="emit('confirm', { amount, from, repeat }); close();"
                    >
                        Confirmar depósito
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
</style>

