<script setup lang="ts">
import { computed, ref, watch } from 'vue';

const props = withDefaults(
    defineProps<{
        open: boolean;
        originalAmount: number;
        accentColor?: string;
    }>(),
    {
        accentColor: '#14B8A6',
    },
);

const emit = defineEmits<{
    (event: 'close'): void;
    (event: 'confirm', payload: { installments: number; interestRate: number; fee: number }): void;
}>();

const installments = ref(3);
const showFees = ref(false);
const interestRate = ref(4.5);
const fee = ref(12);

watch(
    () => props.open,
    (open) => {
        if (!open) return;
        installments.value = 3;
        showFees.value = false;
        interestRate.value = 4.5;
        fee.value = 12;
    },
);

const formatBRL = (value: number) =>
    new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL', minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(value);

const charges = computed(() => {
    const months = Math.max(2, Math.min(12, installments.value));
    const rate = Math.max(0, Number(interestRate.value) || 0) / 100;
    const fees = Math.max(0, Number(fee.value) || 0);
    return props.originalAmount * rate * months + fees;
});

const totalToPay = computed(() => Math.max(0, props.originalAmount + charges.value));
const installmentValue = computed(() => (installments.value ? totalToPay.value / installments.value : 0));

const close = () => emit('close');
const confirm = () => emit('confirm', { installments: installments.value, interestRate: Number(interestRate.value) || 0, fee: Number(fee.value) || 0 });
</script>

<template>
    <div v-if="open" class="fixed inset-0 z-[70]">
        <button type="button" class="absolute inset-0 bg-black/40 backdrop-blur-sm" aria-label="Fechar" @click="close"></button>

        <div class="absolute inset-x-0 bottom-0 rounded-t-3xl bg-white pb-[calc(env(safe-area-inset-bottom)+1rem)] shadow-2xl">
            <div class="mx-auto mt-2 h-1.5 w-12 rounded-full bg-slate-200"></div>

            <div class="px-5 pt-5">
                <div class="mx-auto flex h-14 w-14 items-center justify-center rounded-2xl bg-amber-50 text-amber-600">
                    <svg class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M12 1v22" />
                        <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7H14a3.5 3.5 0 0 1 0 7H6" />
                    </svg>
                </div>

                <div class="mt-4 text-center">
                    <div class="text-xl font-semibold text-slate-900">Parcelar fatura</div>
                    <div class="mt-1 text-sm font-semibold text-slate-400">Simule o parcelamento e veja os juros.</div>
                </div>

                <div class="mt-6 rounded-3xl bg-slate-50 p-5 ring-1 ring-slate-200/60">
                    <div class="flex items-center justify-between">
                        <div class="text-sm font-semibold text-slate-600">Número de parcelas</div>
                        <div class="text-2xl font-semibold" :style="{ color: accentColor }">{{ installments }}×</div>
                    </div>

                    <input
                        v-model.number="installments"
                        type="range"
                        min="2"
                        max="12"
                        step="1"
                        class="mt-5 h-2 w-full cursor-pointer appearance-none rounded-full bg-slate-200 accent-[#14B8A6]"
                        :style="{ accentColor: accentColor }"
                    />
                    <div class="mt-3 flex items-center justify-between text-xs font-semibold text-slate-400">
                        <span>2×</span>
                        <span>12×</span>
                    </div>
                </div>

                <button
                    type="button"
                    class="mt-5 flex w-full items-center justify-between rounded-2xl px-2 py-3 text-sm font-semibold"
                    :class="showFees ? 'text-slate-700' : 'text-[#14B8A6]'"
                    @click="showFees = !showFees"
                >
                    <span class="uppercase tracking-wide">Personalizar taxas</span>
                    <svg class="h-5 w-5 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path v-if="showFees" d="M6 15l6-6 6 6" />
                        <path v-else d="M6 9l6 6 6-6" />
                    </svg>
                </button>

                <div v-if="showFees" class="mt-3 grid grid-cols-2 gap-3">
                    <div class="rounded-2xl bg-white p-4 ring-1 ring-slate-200/60">
                        <div class="text-[11px] font-bold uppercase tracking-wide text-slate-400">Juros (a.m)</div>
                        <div class="mt-2 flex items-center gap-2">
                            <input
                                v-model.number="interestRate"
                                inputmode="decimal"
                                class="w-full appearance-none border-0 bg-transparent text-base font-semibold text-slate-900 outline-none ring-0 focus:ring-0 focus-visible:outline-none"
                            />
                            <span class="text-sm font-semibold text-slate-500">%</span>
                        </div>
                    </div>
                    <div class="rounded-2xl bg-white p-4 ring-1 ring-slate-200/60">
                        <div class="text-[11px] font-bold uppercase tracking-wide text-slate-400">Multa/IOF</div>
                        <div class="mt-2 flex items-center gap-2">
                            <span class="text-sm font-semibold text-slate-500">R$</span>
                            <input
                                v-model.number="fee"
                                inputmode="decimal"
                                class="w-full appearance-none border-0 bg-transparent text-base font-semibold text-slate-900 outline-none ring-0 focus:ring-0 focus-visible:outline-none"
                            />
                        </div>
                    </div>
                </div>

                <div class="mt-5 rounded-3xl bg-slate-50 p-5 ring-1 ring-slate-200/60">
                    <div class="flex items-center justify-between text-sm font-semibold text-slate-500">
                        <span>Valor original</span>
                        <span class="text-slate-700">{{ formatBRL(originalAmount) }}</span>
                    </div>
                    <div class="mt-2 flex items-center justify-between text-sm font-semibold text-slate-500">
                        <span>Encargos (Juros + Multa)</span>
                        <span class="text-amber-600">+ {{ formatBRL(charges) }}</span>
                    </div>

                    <div class="mt-4 border-t border-slate-200/70 pt-4">
                        <div class="flex items-center justify-between text-sm font-semibold text-slate-500">
                            <span>Valor da parcela</span>
                            <span class="text-lg font-semibold text-slate-900">{{ formatBRL(installmentValue) }}</span>
                        </div>
                        <div class="mt-2 flex items-center justify-between text-sm font-semibold text-slate-500">
                            <span>Total a pagar</span>
                            <span class="text-slate-700">{{ formatBRL(totalToPay) }}</span>
                        </div>
                    </div>
                </div>

                <button
                    type="button"
                    class="mt-6 h-14 w-full rounded-2xl text-base font-semibold text-white shadow-lg shadow-teal-600/25"
                    :style="{ backgroundColor: accentColor }"
                    @click="confirm"
                >
                    Confirmar parcelamento
                </button>
            </div>
        </div>
    </div>
</template>

