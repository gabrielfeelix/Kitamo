<script setup lang="ts">
import { computed, ref, watch } from 'vue';

export type TransactionDetail = {
    id?: string;
    title: string;
    amount: number;
    kind: 'expense' | 'income';
    status: 'paid' | 'pending' | 'received';
    categoryLabel: string;
    categoryIcon: 'food' | 'home' | 'car' | 'bolt' | 'pill' | 'briefcase' | 'heart' | 'shirt' | 'cart';
    accountLabel: string;
    accountIcon: 'wallet' | 'bank' | 'card';
    dateLabel: string;
    installmentLabel?: string;
};

const props = defineProps<{
    open: boolean;
    transaction: TransactionDetail | null;
}>();

const emit = defineEmits<{
    (event: 'close'): void;
    (event: 'edit'): void;
    (event: 'duplicate'): void;
    (event: 'delete'): void;
}>();

const close = () => emit('close');

const formatMoney = (value: number) =>
    new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL',
    }).format(value);

const isExpense = computed(() => (props.transaction?.kind ?? 'expense') === 'expense');
const amountClass = computed(() => (isExpense.value ? 'text-[#EF4444]' : 'text-[#14B8A6]'));
const amountPrefix = computed(() => (isExpense.value ? '-' : '+'));

const statusLabel = computed(() => {
    const status = props.transaction?.status ?? 'pending';
    if (status === 'paid') return 'Pago';
    if (status === 'received') return 'Recebido';
    return 'Pendente';
});

const statusPillClass = computed(() => {
    const status = props.transaction?.status ?? 'pending';
    if (status === 'paid' || status === 'received') return 'bg-emerald-50 text-emerald-600';
    return 'bg-slate-100 text-slate-500';
});

const receipt = ref<File | null>(null);
const receiptInput = ref<HTMLInputElement | null>(null);

watch(
    () => props.open,
    (isOpen) => {
        if (!isOpen) return;
        receipt.value = null;
    },
);

const pickReceipt = () => receiptInput.value?.click();
const onReceiptChange = (event: Event) => {
    const target = event.target as HTMLInputElement;
    const selected = target.files?.[0] ?? null;
    receipt.value = selected;
    target.value = '';
};
</script>

<template>
    <div v-if="open" class="fixed inset-0 z-[70]">
        <button class="absolute inset-0 bg-black/50 backdrop-blur-sm" type="button" @click="close" aria-label="Fechar"></button>

        <div class="absolute inset-x-0 bottom-0 w-full max-w-md overflow-hidden rounded-t-[28px] bg-white shadow-[0_-4px_20px_rgba(0,0,0,0.25)]">
            <div class="px-6 pb-[calc(24px+env(safe-area-inset-bottom))] pt-3">
                <div class="relative flex items-center justify-center">
                    <div class="h-1 w-10 rounded-full bg-slate-200"></div>
                    <button
                        type="button"
                        class="absolute right-0 top-0 flex h-10 w-10 items-center justify-center rounded-full bg-slate-100 text-slate-500"
                        aria-label="Fechar"
                        @click="close"
                    >
                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M18 6L6 18" />
                            <path d="M6 6l12 12" />
                        </svg>
                    </button>
                </div>

                <div class="mt-6 flex flex-col items-center">
                    <div class="flex h-16 w-16 items-center justify-center rounded-full bg-amber-100 text-amber-600">
                        <svg v-if="transaction?.categoryIcon === 'cart' || transaction?.categoryIcon === 'food'" class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M6 6h15l-2 7H7L6 6Z" />
                            <path d="M6 6l-2-2H2" />
                            <circle cx="9" cy="18" r="1.5" />
                            <circle cx="17" cy="18" r="1.5" />
                        </svg>
                        <svg v-else-if="transaction?.categoryIcon === 'home'" class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M3 10.5L12 3l9 7.5" />
                            <path d="M5 10v10h14V10" />
                        </svg>
                        <svg v-else-if="transaction?.categoryIcon === 'car'" class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M5 16l1-5 1-3h10l1 3 1 5" />
                            <path d="M7 16h10" />
                            <circle cx="8" cy="17" r="1.5" />
                            <circle cx="16" cy="17" r="1.5" />
                        </svg>
                        <svg v-else class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M4 3v7" />
                            <path d="M8 3v7" />
                            <path d="M6 3v7" />
                            <path d="M14 3v7c0 2 1 3 3 3v8" />
                            <path d="M20 3v7" />
                        </svg>
                    </div>

                    <div class="mt-4 text-lg font-semibold text-slate-900">{{ transaction?.title ?? '' }}</div>
                    <div class="mt-1 text-3xl font-bold" :class="amountClass">
                        {{ amountPrefix }}{{ formatMoney(transaction?.amount ?? 0).replace('R$', 'R$') }}
                    </div>

                    <div class="mt-2 inline-flex items-center gap-2 rounded-full px-3 py-1 text-xs font-semibold" :class="statusPillClass">
                        <span class="h-2 w-2 rounded-full bg-current opacity-60"></span>
                        {{ statusLabel }}
                    </div>
                </div>

                <div class="mt-6 w-full border-t border-slate-100"></div>

                <div class="mt-6 w-full">
                    <div class="text-sm font-bold text-slate-900">Comprovante</div>
                    <div class="mt-3">
                        <input ref="receiptInput" class="hidden" type="file" accept="application/pdf,image/*" @change="onReceiptChange" />

                        <button
                            v-if="!receipt"
                            type="button"
                            class="flex h-11 w-full items-center justify-center gap-2 rounded-xl border-2 border-dashed border-[#14B8A6] bg-white text-sm font-semibold text-[#14B8A6]"
                            @click="pickReceipt"
                        >
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path
                                    d="M21.4 11.6 12.9 20a5 5 0 0 1-7.1-7.1l8.5-8.5a3.5 3.5 0 1 1 5 5l-8.2 8.2a2 2 0 1 1-2.8-2.8l7.3-7.3"
                                />
                            </svg>
                            Anexar comprovante
                        </button>

                        <div v-else class="flex items-center justify-between rounded-xl border border-slate-200 bg-white p-3">
                            <div class="flex items-center gap-3">
                                <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-slate-100 text-slate-400">
                                    <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <rect x="4" y="5" width="16" height="14" rx="2" />
                                        <path d="m8 13 2-2 3 3 3-4 2 3" />
                                    </svg>
                                </div>
                                <div class="text-sm font-semibold text-slate-700">{{ receipt.name }}</div>
                            </div>
                            <button type="button" class="flex h-10 w-10 items-center justify-center rounded-xl bg-slate-100 text-slate-500" aria-label="Remover" @click="receipt = null">
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M3 6h18" />
                                    <path d="M8 6V4h8v2" />
                                    <path d="M19 6l-1 16H6L5 6" />
                                    <path d="M10 11v6" />
                                    <path d="M14 11v6" />
                                </svg>
                            </button>
                        </div>
                    </div>
                </div>

                <div class="mt-6 space-y-3 text-sm">
                    <div class="flex items-center justify-between">
                        <div class="text-slate-400">Categoria</div>
                        <div class="flex items-center gap-2 font-semibold text-slate-700">
                            <span class="text-lg leading-none">🍴</span>
                            {{ transaction?.categoryLabel ?? '' }}
                        </div>
                    </div>
                    <div class="flex items-center justify-between">
                        <div class="text-slate-400">Conta</div>
                        <div class="flex items-center gap-2 font-semibold text-slate-700">
                            <span class="text-lg leading-none">💳</span>
                            {{ transaction?.accountLabel ?? '' }}
                        </div>
                    </div>
                    <div class="flex items-center justify-between">
                        <div class="text-slate-400">Data</div>
                        <div class="font-semibold text-slate-700">{{ transaction?.dateLabel ?? '' }}</div>
                    </div>
                    <div v-if="transaction?.installmentLabel" class="flex items-center justify-between border-t border-slate-100 pt-3">
                        <div class="text-slate-400">Parcelamento</div>
                        <div class="font-semibold text-slate-700">{{ transaction?.installmentLabel }}</div>
                    </div>
                </div>

                <div class="mt-7 grid grid-cols-3 gap-3">
                    <button
                        type="button"
                        class="flex h-12 items-center justify-center gap-2 rounded-xl border border-[#14B8A6] bg-white text-sm font-semibold text-[#14B8A6]"
                        @click="emit('edit')"
                    >
                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M12 20h9" />
                            <path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L8 18l-4 1 1-4 11.5-11.5Z" />
                        </svg>
                        Editar
                    </button>
                    <button
                        type="button"
                        class="flex h-12 items-center justify-center gap-2 rounded-xl border border-slate-200 bg-white text-sm font-semibold text-slate-600"
                        @click="emit('duplicate')"
                    >
                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <rect x="9" y="9" width="10" height="10" rx="2" />
                            <rect x="5" y="5" width="10" height="10" rx="2" />
                        </svg>
                        Duplicar
                    </button>
                    <button
                        type="button"
                        class="flex h-12 items-center justify-center rounded-xl border border-red-200 bg-white text-red-500"
                        aria-label="Excluir"
                        @click="emit('delete')"
                    >
                        <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M3 6h18" />
                            <path d="M8 6V4h8v2" />
                            <path d="M19 6l-1 16H6L5 6" />
                            <path d="M10 11v6" />
                            <path d="M14 11v6" />
                        </svg>
                    </button>
                </div>
            </div>
        </div>
    </div>
</template>
