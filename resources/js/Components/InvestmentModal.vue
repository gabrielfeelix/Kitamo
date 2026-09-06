<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import type { AssetClass, Investment } from '@/types/kitamo';

export type InvestmentModalPayload = {
    name: string;
    asset_class: AssetClass;
    institution: string | null;
    ticker: string | null;
    current_value: number;
    price_source: 'manual' | 'binance' | 'bcb';
};

const props = defineProps<{
    open: boolean;
    investment: Investment | null;
}>();

const emit = defineEmits<{
    (event: 'close'): void;
    (event: 'save', payload: InvestmentModalPayload): void;
}>();

const CLASSES: { value: AssetClass; label: string; hint: string }[] = [
    { value: 'caixinha', label: 'Caixinha', hint: 'Reserva guardada no banco ou na carteira digital' },
    { value: 'cdb', label: 'CDB', hint: 'Renda fixa emitida por banco' },
    { value: 'tesouro', label: 'Tesouro Direto', hint: 'Títulos públicos' },
    { value: 'acao', label: 'Ações', hint: 'Papéis negociados na bolsa' },
    { value: 'fii', label: 'Fundo imobiliário', hint: 'Cotas de FII' },
    { value: 'cripto', label: 'Cripto', hint: 'Bitcoin, Ethereum e afins' },
    { value: 'outro', label: 'Outro', hint: 'Qualquer outra reserva' },
];

const name = ref('');
const assetClass = ref<AssetClass>('caixinha');
const institution = ref('');
const ticker = ref('');
const currentValue = ref('');

/** Só cripto tem cotação automática legítima e gratuita hoje. */
const aceitaCotacaoAutomatica = computed(() => assetClass.value === 'cripto');
const cotacaoAutomatica = ref(false);

const classeSelecionada = computed(() => CLASSES.find((c) => c.value === assetClass.value));

const parseMoney = (value: string) => {
    const normalized = value.replace(/\./g, '').replace(',', '.').replace(/[^\d.-]/g, '');
    const parsed = Number.parseFloat(normalized);
    return Number.isFinite(parsed) ? parsed : 0;
};

watch(
    () => props.open,
    (isOpen) => {
        if (!isOpen) return;

        const editing = props.investment;
        name.value = editing?.name ?? '';
        assetClass.value = editing?.assetClass ?? 'caixinha';
        institution.value = editing?.institution ?? '';
        ticker.value = editing?.ticker ?? '';
        currentValue.value = editing ? String(editing.currentValue).replace('.', ',') : '';
        cotacaoAutomatica.value = editing?.priceSource === 'binance';
    },
    { immediate: true },
);

const canSave = computed(() => name.value.trim().length > 0 && parseMoney(currentValue.value) >= 0);

const submit = () => {
    if (!canSave.value) return;

    emit('save', {
        name: name.value.trim(),
        asset_class: assetClass.value,
        institution: institution.value.trim() || null,
        ticker: ticker.value.trim().toUpperCase() || null,
        current_value: parseMoney(currentValue.value),
        price_source: aceitaCotacaoAutomatica.value && cotacaoAutomatica.value ? 'binance' : 'manual',
    });
};
</script>

<template>
    <Teleport to="body">
        <div v-if="open" class="fixed inset-0 z-50 flex items-end justify-center sm:items-center">
            <div class="absolute inset-0 bg-slate-900/40" @click="emit('close')"></div>

            <div class="relative max-h-[90vh] w-full overflow-y-auto rounded-t-3xl bg-white p-6 shadow-xl sm:max-w-lg sm:rounded-3xl">
                <h2 class="text-lg font-semibold text-slate-900">
                    {{ investment ? 'Editar investimento' : 'Novo investimento' }}
                </h2>

                <div class="mt-5 space-y-4">
                    <div>
                        <label for="inv-name" class="text-sm font-medium text-slate-700">Nome</label>
                        <input
                            id="inv-name"
                            v-model="name"
                            type="text"
                            placeholder="Caixinha Mercado Pago"
                            class="mt-1 w-full rounded-2xl border-slate-200 text-sm focus:border-emerald-500 focus:ring-emerald-500"
                        />
                    </div>

                    <div>
                        <label for="inv-class" class="text-sm font-medium text-slate-700">Tipo</label>
                        <select
                            id="inv-class"
                            v-model="assetClass"
                            class="mt-1 w-full rounded-2xl border-slate-200 text-sm focus:border-emerald-500 focus:ring-emerald-500"
                        >
                            <option v-for="classe in CLASSES" :key="classe.value" :value="classe.value">
                                {{ classe.label }}
                            </option>
                        </select>
                        <p class="mt-1 text-xs text-slate-500">{{ classeSelecionada?.hint }}</p>
                    </div>

                    <div>
                        <label for="inv-institution" class="text-sm font-medium text-slate-700">
                            Instituição <span class="font-normal text-slate-400">(opcional)</span>
                        </label>
                        <input
                            id="inv-institution"
                            v-model="institution"
                            type="text"
                            placeholder="Mercado Pago"
                            class="mt-1 w-full rounded-2xl border-slate-200 text-sm focus:border-emerald-500 focus:ring-emerald-500"
                        />
                    </div>

                    <div>
                        <label for="inv-value" class="text-sm font-medium text-slate-700">Quanto tem hoje</label>
                        <input
                            id="inv-value"
                            v-model="currentValue"
                            type="text"
                            inputmode="decimal"
                            placeholder="1.628,47"
                            class="mt-1 w-full rounded-2xl border-slate-200 text-sm tabular-nums focus:border-emerald-500 focus:ring-emerald-500"
                        />
                    </div>

                    <div v-if="aceitaCotacaoAutomatica" class="rounded-2xl bg-slate-50 p-4">
                        <label class="flex items-start gap-3">
                            <input
                                v-model="cotacaoAutomatica"
                                type="checkbox"
                                class="mt-0.5 rounded border-slate-300 text-emerald-600 focus:ring-emerald-500"
                            />
                            <span class="text-sm">
                                <span class="font-medium text-slate-800">Atualizar a cotação sozinho</span>
                                <span class="mt-0.5 block text-xs text-slate-500">
                                    Busca o preço uma vez por dia. Você pode corrigir o valor à mão quando quiser.
                                </span>
                            </span>
                        </label>

                        <div v-if="cotacaoAutomatica" class="mt-3">
                            <label for="inv-ticker" class="text-xs font-medium text-slate-700">Sigla</label>
                            <input
                                id="inv-ticker"
                                v-model="ticker"
                                type="text"
                                placeholder="BTC"
                                class="mt-1 w-full rounded-xl border-slate-200 text-sm uppercase focus:border-emerald-500 focus:ring-emerald-500"
                            />
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
                        Salvar
                    </button>
                </div>
            </div>
        </div>
    </Teleport>
</template>
