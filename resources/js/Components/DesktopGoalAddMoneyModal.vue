<script setup lang="ts">
import { ref, watch } from 'vue';

const props = defineProps<{
    open: boolean;
}>();

const emit = defineEmits<{
    (event: 'close'): void;
    (event: 'confirm', payload: { amount: string }): void;
}>();

const close = () => emit('close');

const amount = ref('0,00');
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
        amount.value = '0,00';
    },
);
</script>

<template>
    <div v-if="open" class="fixed inset-0 z-[96]">
        <button class="absolute inset-0 bg-black/40 backdrop-blur-sm" type="button" @click="close" aria-label="Fechar"></button>

        <div class="absolute left-1/2 top-1/2 w-[440px] -translate-x-1/2 -translate-y-1/2 overflow-hidden rounded-2xl bg-white shadow-[0_30px_90px_-50px_rgba(15,23,42,0.7)] ring-1 ring-slate-200/60">
            <header class="flex items-center justify-between border-b border-slate-100 px-7 py-5">
                <div class="text-base font-semibold text-slate-900">Adicionar dinheiro</div>
                <button type="button" class="flex h-10 w-10 items-center justify-center rounded-xl bg-slate-50 text-slate-400 hover:bg-slate-100" @click="close" aria-label="Fechar">
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M18 6L6 18" />
                        <path d="M6 6l12 12" />
                    </svg>
                </button>
            </header>

            <div class="px-7 py-6">
                <div class="text-xs font-bold uppercase tracking-wide text-slate-400">Valor</div>
                <div class="mt-3 flex items-center gap-3 rounded-xl bg-slate-50 px-4 py-3 ring-1 ring-slate-200/60">
                    <div class="text-sm font-semibold text-slate-400">R$</div>
                    <input
                        class="w-full bg-transparent text-2xl font-bold tracking-tight text-slate-900 focus:outline-none"
                        inputmode="numeric"
                        :value="amount"
                        @input="onAmountInput"
                        aria-label="Valor"
                    />
                </div>
            </div>

            <footer class="border-t border-slate-100 px-7 py-5">
                <button
                    type="button"
                    class="h-12 w-full rounded-xl bg-[#14B8A6] text-sm font-semibold text-white shadow-lg shadow-emerald-500/20"
                    @click="
                        emit('confirm', { amount });
                        close();
                    "
                >
                    Confirmar depósito
                </button>
            </footer>
        </div>
    </div>
</template>

