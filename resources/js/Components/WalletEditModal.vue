<script setup lang="ts">
import { ref, computed, watch } from 'vue';
import { formatMoneyInputCentsShift, moneyInputToNumber } from '@/lib/moneyInput';

const props = defineProps<{
    open: boolean;
    wallet: {
        id: string;
        name: string;
        initial_balance?: number;
        current_balance: number;
        color?: string;
        incluir_soma?: boolean;
    } | null;
}>();

const emit = defineEmits<{
    (event: 'close'): void;
    (event: 'save', payload: {
        id: string;
        name: string;
        initial_balance: number;
        color: string;
        incluir_soma?: boolean;
    }): void;
}>();

// State
const name = ref('');
const initialBalance = ref('');
const color = ref('#14B8A6');
const incluirSoma = ref(true);
const originalBalance = ref(0);

// Colors
const colors = ['#14B8A6', '#10B981', '#3B82F6', '#8B5CF6', '#F59E0B', '#EF4444'];

// Computed
const balanceChanged = computed(() => {
    const current = moneyInputToNumber(initialBalance.value);
    return current !== originalBalance.value;
});

const initialBalanceNumber = computed(() => {
    return moneyInputToNumber(initialBalance.value);
});

// Methods
const onBalanceInput = (event: Event) => {
    const target = event.target as HTMLInputElement;
    initialBalance.value = formatMoneyInputCentsShift(target.value);
};

const save = () => {
    if (!props.wallet) return;
    const payload: any = {
        id: props.wallet.id,
        name: name.value.trim(),
        initial_balance: initialBalanceNumber.value,
        color: color.value,
    };
    if (props.wallet.incluir_soma !== undefined) {
        payload.incluir_soma = incluirSoma.value;
    }
    emit('save', payload);
};

// Watch modal open
watch(
    () => props.open,
    (isOpen) => {
        if (!isOpen || !props.wallet) return;
        name.value = props.wallet.name;
        const balance = props.wallet.initial_balance ?? props.wallet.current_balance;
        originalBalance.value = balance;
        initialBalance.value = formatMoneyInputCentsShift(String(balance * 100));
        color.value = props.wallet.color ?? '#14B8A6';
        incluirSoma.value = props.wallet.incluir_soma ?? true;
    }
);
</script>

<template>
    <div v-if="open" class="fixed inset-0 z-[90] bg-white flex flex-col">
        <!-- Header -->
        <header class="border-b border-slate-200/70 px-5 pt-[calc(1rem+env(safe-area-inset-top))] pb-4 flex items-center gap-4">
            <button
                type="button"
                class="text-slate-600 hover:text-slate-900 transition"
                @click="emit('close')"
            >
                <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M19 12H5M12 19l-7-7 7-7" />
                </svg>
            </button>
            <h1 class="text-lg font-semibold text-slate-900">Editar Carteira</h1>
        </header>

        <!-- Main Content -->
        <main class="flex-1 overflow-y-auto px-5 py-6 max-w-md mx-auto w-full">
            <!-- Wallet Icon (Fixed) -->
            <div class="flex justify-center mb-8">
                <div class="flex h-20 w-20 items-center justify-center rounded-3xl bg-teal-50">
                    <svg class="h-10 w-10 text-teal-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M21 12V7H5a2 2 0 0 1 0-4h14v4" />
                        <path d="M3 5v14a2 2 0 0 0 2 2h16v-5" />
                        <path d="M18 12a2 2 0 0 0 0 4h4v-4Z" />
                    </svg>
                </div>
            </div>

            <!-- Name Field -->
            <div class="mb-6">
                <label class="block text-sm font-semibold text-slate-900 mb-2">Nome da carteira</label>
                <input
                    v-model="name"
                    type="text"
                    placeholder="Ex: Carteira Principal"
                    class="w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-slate-900 placeholder-slate-400 transition focus:border-emerald-500 focus:outline-none"
                />
            </div>

            <!-- Initial Balance Field -->
            <div class="mb-6">
                <label class="block text-sm font-semibold text-slate-900 mb-2">Saldo inicial</label>
                <input
                    :value="initialBalance"
                    type="text"
                    inputmode="decimal"
                    placeholder="R$ 0,00"
                    class="w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-slate-900 placeholder-slate-400 transition focus:border-emerald-500 focus:outline-none"
                    @input="onBalanceInput"
                />

                <!-- Warning if balance changed -->
                <div v-if="balanceChanged" class="mt-3 rounded-lg border-l-4 border-amber-400 bg-amber-50 p-4">
                    <div class="flex gap-2">
                        <span class="flex-shrink-0 text-amber-600">⚠️</span>
                        <div class="flex-1">
                            <p class="text-sm font-semibold text-amber-900">Atenção!</p>
                            <p class="mt-1 text-sm text-amber-800">Alterar o saldo inicial pode impactar a conciliação de contas. Recomendamos criar uma transação de ajuste ao invés de alterar diretamente.</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Color Picker -->
            <div class="mb-8">
                <label class="block text-sm font-semibold text-slate-900 mb-3">Cor da carteira</label>
                <div class="flex gap-3">
                    <button
                        v-for="c in colors"
                        :key="c"
                        type="button"
                        :style="{ backgroundColor: c }"
                        :class="[
                            'h-12 w-12 rounded-2xl border-2 transition',
                            color === c
                                ? 'border-slate-900 ring-2 ring-white ring-offset-2 ring-offset-slate-900'
                                : 'border-transparent hover:border-slate-200'
                        ]"
                        @click="color = c"
                        :aria-label="`Select color ${c}`"
                    />
                </div>
            </div>

            <!-- Include in Summary Toggle -->
            <div class="rounded-xl border border-slate-200 bg-slate-50 p-4 mb-4">
                <div class="flex items-center justify-between">
                    <label class="text-sm font-semibold text-slate-900">Incluir na soma da tela inicial</label>
                    <button
                        type="button"
                        class="relative inline-flex h-6 w-11 items-center rounded-full transition"
                        :class="incluirSoma ? 'bg-emerald-500' : 'bg-slate-300'"
                        @click="incluirSoma = !incluirSoma"
                        :aria-label="incluirSoma ? 'Ativado' : 'Desativado'"
                    >
                        <span
                            class="inline-block h-5 w-5 transform rounded-full bg-white transition"
                            :class="incluirSoma ? 'translate-x-5' : 'translate-x-0.5'"
                        ></span>
                    </button>
                </div>
            </div>
        </main>

        <!-- Footer -->
        <footer class="border-t border-slate-200/70 bg-white px-5 py-4 max-w-md mx-auto w-full">
            <button
                type="button"
                @click="save"
                class="w-full rounded-xl bg-emerald-500 py-3 font-semibold text-white transition hover:bg-emerald-600 active:bg-emerald-700"
            >
                Salvar alterações
            </button>
        </footer>
    </div>
</template>
