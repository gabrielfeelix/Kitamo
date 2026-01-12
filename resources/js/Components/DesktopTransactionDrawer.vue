<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import type { Entry } from '@/stores/localStore';

const props = defineProps<{
    open: boolean;
    entry: Entry | null;
}>();

const emit = defineEmits<{
    (event: 'close'): void;
    (event: 'edit'): void;
    (event: 'delete'): void;
    (event: 'mark-paid'): void;
}>();

const formatMoney = (value: number) =>
    new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL',
    }).format(value);

const isExpense = computed(() => (props.entry?.kind ?? 'expense') === 'expense');
const amountPrefix = computed(() => (isExpense.value ? '-' : '+'));
const amountClass = computed(() => (isExpense.value ? 'text-red-500' : 'text-emerald-600'));
const showMarkPaid = computed(() => isExpense.value);
const markPaidLabel = computed(() => ((props.entry?.status ?? 'pending') === 'paid' ? 'Marcar como Pendente' : 'Marcar como Pago'));

const iconType = computed(() => {
    const title = (props.entry?.title ?? '').toLowerCase();
    if (title.includes('netflix')) return 'play';
    if (title.includes('aluguel') || (props.entry?.categoryKey ?? '') === 'home') return 'home';
    if ((props.entry?.categoryKey ?? '') === 'food') return 'cart';
    return 'dot';
});

const tags = computed(() => props.entry?.tags ?? []);
const displayTags = computed<string[]>(() => (tags.value.length ? tags.value : ['Compras']));

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
    <div v-if="open" class="fixed inset-0 z-[95]">
        <button class="absolute inset-0 bg-black/35 backdrop-blur-sm" type="button" @click="emit('close')" aria-label="Fechar"></button>

        <aside class="absolute right-0 top-0 h-full w-[440px] bg-white shadow-[-18px_0_60px_-40px_rgba(15,23,42,0.6)]">
            <header class="flex items-center justify-between border-b border-slate-100 px-8 py-6">
                <div class="text-base font-semibold text-slate-900">Detalhes da Transação</div>
                <button
                    type="button"
                    class="flex h-10 w-10 items-center justify-center rounded-xl bg-slate-50 text-slate-400 hover:bg-slate-100"
                    aria-label="Fechar"
                    @click="emit('close')"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M18 6L6 18" />
                        <path d="M6 6l12 12" />
                    </svg>
                </button>
            </header>

            <div class="h-[calc(100vh-160px)] overflow-y-auto px-8 py-8">
                <div class="flex flex-col items-center">
                    <div
                        class="flex h-20 w-20 items-center justify-center rounded-full ring-1"
                        :class="
                            iconType === 'play'
                                ? 'bg-red-50 text-red-500 ring-red-100'
                                : iconType === 'home'
                                  ? 'bg-blue-50 text-blue-600 ring-blue-100'
                                  : iconType === 'cart'
                                    ? 'bg-amber-50 text-amber-600 ring-amber-100'
                                    : 'bg-slate-50 text-slate-500 ring-slate-200'
                        "
                    >
                        <svg v-if="iconType === 'play'" class="h-10 w-10" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M9 7v10l9-5-9-5Z" />
                        </svg>
                        <svg v-else-if="iconType === 'home'" class="h-10 w-10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M3 10.5L12 3l9 7.5" />
                            <path d="M5 10v10h14V10" />
                        </svg>
                        <svg v-else-if="iconType === 'cart'" class="h-10 w-10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M6 6h15l-2 7H7L6 6Z" />
                            <path d="M6 6l-2-2H2" />
                            <circle cx="9" cy="18" r="1.5" />
                            <circle cx="17" cy="18" r="1.5" />
                        </svg>
                        <div v-else class="h-3 w-3 rounded-full bg-red-500"></div>
                    </div>

                    <div class="mt-6 text-2xl font-semibold text-slate-900">{{ entry?.title }}</div>
                    <div class="mt-3 text-3xl font-bold tracking-tight" :class="amountClass">{{ amountPrefix }}{{ formatMoney(entry?.amount ?? 0) }}</div>
                    <div class="mt-4 inline-flex rounded-full bg-slate-100 px-3 py-1 text-xs font-semibold text-slate-500">11 Dez 2025</div>
                </div>

                <div class="mt-5 flex flex-wrap justify-center gap-2">
                    <span
                        v-for="tag in displayTags"
                        :key="tag"
                        class="inline-flex items-center rounded-full bg-white px-3 py-1 text-xs font-semibold text-slate-600 ring-1 ring-slate-200"
                    >
                        {{ tag }}
                    </span>
                </div>

                <div class="mt-8 grid grid-cols-2 gap-4">
                    <div class="rounded-2xl bg-slate-50 px-5 py-4">
                        <div class="text-[11px] font-bold uppercase tracking-wide text-slate-400">Valor</div>
                        <div class="mt-2 text-sm font-semibold" :class="amountClass">{{ amountPrefix }}{{ formatMoney(entry?.amount ?? 0) }}</div>
                    </div>
                    <div class="rounded-2xl bg-slate-50 px-5 py-4">
                        <div class="text-[11px] font-bold uppercase tracking-wide text-slate-400">Conta</div>
                        <div class="mt-2 text-sm font-semibold text-slate-700">{{ entry?.accountLabel }}</div>
                    </div>
                    <div class="rounded-2xl bg-slate-50 px-5 py-4">
                        <div class="text-[11px] font-bold uppercase tracking-wide text-slate-400">Categoria</div>
                        <div class="mt-2 text-sm font-semibold text-slate-700">{{ entry?.categoryLabel }}</div>
                    </div>
                    <div class="rounded-2xl bg-slate-50 px-5 py-4">
                        <div class="text-[11px] font-bold uppercase tracking-wide text-slate-400">Recorrência</div>
                        <div class="mt-2 text-sm font-semibold text-slate-700">{{ entry?.tags?.includes('Recorrente') ? 'Mensal' : '1/1' }}</div>
                    </div>
                </div>

                <div class="mt-8">
                    <div class="flex items-center gap-2 text-xs font-semibold text-slate-600">
                        <svg class="h-4 w-4 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M21.44 11.05 12.25 20.24a6 6 0 0 1-8.49-8.49l9.19-9.19a4 4 0 0 1 5.66 5.66l-9.2 9.2a2 2 0 1 1-2.82-2.83l8.49-8.48" />
                        </svg>
                        Comprovantes / Anexos
                    </div>

                    <input ref="receiptInput" class="hidden" type="file" @change="onReceiptChange" />
                    <button
                        v-if="!receipt"
                        type="button"
                        class="mt-3 flex h-[110px] w-full flex-col items-center justify-center rounded-2xl border border-dashed border-slate-200 bg-white text-slate-400 hover:bg-slate-50"
                        @click="pickReceipt"
                    >
                        <svg class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M20 17.5a4.5 4.5 0 0 0-1-8.8A6 6 0 0 0 5 9.2a3.5 3.5 0 0 0 .5 7.3" />
                            <path d="M12 13v6" />
                            <path d="m9 16 3-3 3 3" />
                        </svg>
                        <div class="mt-3 text-xs font-semibold">Clique para adicionar arquivo</div>
                    </button>

                    <div v-else class="mt-3 flex items-center justify-between gap-4 rounded-2xl border border-slate-200 bg-white px-4 py-4">
                        <div class="flex min-w-0 items-center gap-3">
                            <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-slate-100 text-slate-400">
                                <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <rect x="3" y="4" width="18" height="16" rx="2" />
                                    <path d="M7 14l2-2 3 3 2-2 3 3" />
                                    <circle cx="9" cy="9" r="1" />
                                </svg>
                            </div>
                            <div class="min-w-0">
                                <div class="truncate text-sm font-semibold text-slate-700">{{ receipt.name }}</div>
                                <div class="mt-1 text-xs font-semibold text-slate-400">Anexo</div>
                            </div>
                        </div>
                        <button type="button" class="flex h-10 w-10 items-center justify-center rounded-xl bg-slate-50 text-slate-400" aria-label="Remover" @click="receipt = null">
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

                <div class="mt-8 border-t border-slate-100 pt-6">
                    <div class="text-[11px] font-bold uppercase tracking-wide text-slate-400">Anotações</div>
                    <textarea
                        class="mt-3 h-24 w-full resize-none rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm font-semibold text-slate-600 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-emerald-200"
                        placeholder="Sem anotações..."
                    ></textarea>
                </div>
            </div>

            <footer class="border-t border-slate-100 px-8 py-6">
                <button
                    v-if="showMarkPaid"
                    type="button"
                    class="flex h-12 w-full items-center justify-center gap-2 rounded-xl bg-[#14B8A6] text-sm font-semibold text-white shadow-lg shadow-emerald-500/20"
                    @click="emit('mark-paid')"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M20 6 9 17l-5-5" />
                    </svg>
                    {{ markPaidLabel }}
                </button>

                <div class="mt-4 grid grid-cols-2 gap-4">
                    <button type="button" class="h-11 rounded-xl border border-red-200 bg-white text-sm font-semibold text-red-500" @click="emit('delete')">
                        Excluir
                    </button>
                    <button
                        type="button"
                        class="h-11 rounded-xl bg-[#14B8A6] text-sm font-semibold text-white shadow-lg shadow-emerald-500/20"
                        @click="emit('edit')"
                    >
                        Editar
                    </button>
                </div>
            </footer>
        </aside>
    </div>
</template>
