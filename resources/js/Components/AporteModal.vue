<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import type { Investment } from '@/types/kitamo';

export type AportePayload = {
    kind: 'aporte' | 'resgate';
    amount: number;
    occurred_on: string;
    afeta_caixa: boolean;
    account_id: number | null;
};

type ContaOption = { id: string; name: string; balance: number };

const props = defineProps<{
    open: boolean;
    investment: Investment | null;
    accounts: ContaOption[];
}>();

const emit = defineEmits<{
    (event: 'close'): void;
    (event: 'save', payload: AportePayload): void;
}>();

const kind = ref<'aporte' | 'resgate'>('aporte');
const amount = ref('');
const occurredOn = ref('');
const afetaCaixa = ref(true);
const accountId = ref<string>('');

const parseMoney = (value: string) => {
    const normalized = value.replace(/\./g, '').replace(',', '.').replace(/[^\d.-]/g, '');
    const parsed = Number.parseFloat(normalized);
    return Number.isFinite(parsed) ? parsed : 0;
};

const formatBRL = (value: number) =>
    new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value);

watch(
    () => props.open,
    (isOpen) => {
        if (!isOpen) return;

        kind.value = 'aporte';
        amount.value = '';
        occurredOn.value = new Date().toISOString().slice(0, 10);
        afetaCaixa.value = true;
        accountId.value = props.accounts[0]?.id ?? '';
    },
    { immediate: true },
);

const canSave = computed(() => parseMoney(amount.value) > 0 && occurredOn.value !== '');

/** O texto muda com a direção: o usuário precisa saber o que vai acontecer. */
const explicacaoCaixa = computed(() =>
    kind.value === 'aporte'
        ? 'Registra também a saída no seu extrato e desconta o saldo da conta.'
        : 'Registra também a entrada no seu extrato e soma ao saldo da conta.',
);

const submit = () => {
    if (!canSave.value) return;

    emit('save', {
        kind: kind.value,
        amount: parseMoney(amount.value),
        occurred_on: occurredOn.value,
        afeta_caixa: afetaCaixa.value && accountId.value !== '',
        account_id: afetaCaixa.value && accountId.value !== '' ? Number(accountId.value) : null,
    });
};
</script>

<template>
    <Teleport to="body">
        <div v-if="open" class="fixed inset-0 z-50 flex items-end justify-center sm:items-center">
            <div class="absolute inset-0 bg-slate-900/40" @click="emit('close')"></div>

            <div class="relative max-h-[90vh] w-full overflow-y-auto rounded-t-3xl bg-white p-6 shadow-xl sm:max-w-lg sm:rounded-3xl">
                <h2 class="text-lg font-semibold text-slate-900">
                    {{ investment?.name ?? 'Movimentar investimento' }}
                </h2>

                <div class="mt-5 grid grid-cols-2 gap-2 rounded-2xl bg-slate-100 p-1">
                    <button
                        type="button"
                        class="rounded-xl py-2 text-sm font-semibold transition-colors"
                        :class="kind === 'aporte' ? 'bg-white text-slate-900 shadow-sm' : 'text-slate-500'"
                        @click="kind = 'aporte'"
                    >
                        Aportar
                    </button>
                    <button
                        type="button"
                        class="rounded-xl py-2 text-sm font-semibold transition-colors"
                        :class="kind === 'resgate' ? 'bg-white text-slate-900 shadow-sm' : 'text-slate-500'"
                        @click="kind = 'resgate'"
                    >
                        Resgatar
                    </button>
                </div>

                <div class="mt-5 space-y-4">
                    <div>
                        <label for="aporte-amount" class="text-sm font-medium text-slate-700">Valor</label>
                        <input
                            id="aporte-amount"
                            v-model="amount"
                            type="text"
                            inputmode="decimal"
                            placeholder="500,00"
                            class="mt-1 w-full rounded-2xl border-slate-200 text-sm tabular-nums focus:border-emerald-500 focus:ring-emerald-500"
                        />
                    </div>

                    <div>
                        <label for="aporte-date" class="text-sm font-medium text-slate-700">Quando</label>
                        <input
                            id="aporte-date"
                            v-model="occurredOn"
                            type="date"
                            class="mt-1 w-full rounded-2xl border-slate-200 text-sm focus:border-emerald-500 focus:ring-emerald-500"
                        />
                    </div>

                    <div class="rounded-2xl bg-slate-50 p-4">
                        <label class="flex items-start gap-3">
                            <input
                                v-model="afetaCaixa"
                                type="checkbox"
                                class="mt-0.5 rounded border-slate-300 text-emerald-600 focus:ring-emerald-500"
                            />
                            <span class="text-sm">
                                <span class="font-medium text-slate-800">
                                    {{ kind === 'aporte' ? 'O dinheiro saiu de uma conta' : 'O dinheiro voltou para uma conta' }}
                                </span>
                                <span class="mt-0.5 block text-xs text-slate-500">{{ explicacaoCaixa }}</span>
                            </span>
                        </label>

                        <div v-if="afetaCaixa" class="mt-3">
                            <label for="aporte-account" class="text-xs font-medium text-slate-700">Conta</label>
                            <select
                                id="aporte-account"
                                v-model="accountId"
                                class="mt-1 w-full rounded-xl border-slate-200 text-sm focus:border-emerald-500 focus:ring-emerald-500"
                            >
                                <option v-for="conta in accounts" :key="conta.id" :value="conta.id">
                                    {{ conta.name }} — {{ formatBRL(conta.balance) }}
                                </option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="mt-6 flex gap-3">
                    <button
                        type="button"
                        class="flex-1 rounded-2xl border border-slate-200 py-3 text-sm font-semibold text-slate-600 transition-colors hover:bg-slate-50"
                        @click="emit('close')"
                    >
                        Cancelar
                    </button>
                    <button
                        type="button"
                        :disabled="!canSave"
                        class="flex-1 rounded-2xl bg-slate-900 py-3 text-sm font-semibold text-white transition-colors hover:bg-slate-800 disabled:opacity-40"
                        @click="submit"
                    >
                        {{ kind === 'aporte' ? 'Registrar aporte' : 'Registrar resgate' }}
                    </button>
                </div>
            </div>
        </div>
    </Teleport>
</template>
