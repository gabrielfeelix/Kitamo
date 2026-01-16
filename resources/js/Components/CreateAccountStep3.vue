<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import type { BancoSelecionado } from './CreateAccountStep1.vue';
import { formatMoneyInputCentsShift, moneyInputToNumber } from '@/lib/moneyInput';

export type AccountPayload = {
  banco_nome: string;
  banco_cor: string;
  saldo_inicial: number;
  descricao: string;
  tipo: string;
  cor: string;
  incluir_soma_inicial: boolean;
};

const props = defineProps<{
  open: boolean;
  banco: BancoSelecionado | null;
}>();

const emit = defineEmits<{
  (event: 'back'): void;
  (event: 'close'): void;
  (event: 'save', payload: AccountPayload, createNew: boolean): void;
}>();

// State
const saldo = ref('');
const descricao = ref('');
const tipo = ref('corrente');
const cor = ref('#14B8A6');
const incluirSoma = ref(true);

// Tipos de conta
const tipos = [
  { id: 'corrente', nome: 'Conta corrente', icone: '🏛️' },
  { id: 'dinheiro', nome: 'Dinheiro', icone: '💵' },
  { id: 'poupanca', nome: 'Poupança', icone: '📊' },
  { id: 'investimentos', nome: 'Investimentos', icone: '📈' },
  { id: 'vr_va', nome: 'VR/VA', icone: '🎫' },
  { id: 'outros', nome: 'Outros', icone: '⋯' },
];

// Cores
const cores = ['#14B8A6', '#8B10AE', '#10B981', '#FF7A00'];

const onSaldoInput = (event: Event) => {
  const target = event.target as HTMLInputElement;
  saldo.value = formatMoneyInputCentsShift(target.value);
};

const saldoNumber = computed(() => {
  return moneyInputToNumber(saldo.value);
});

const tipoSelecionado = computed(() => tipos.find((t) => t.id === tipo.value));

const reset = () => {
  saldo.value = '';
  descricao.value = '';
  tipo.value = 'corrente';
  cor.value = '#14B8A6';
  incluirSoma.value = true;
};

const save = (createNew: boolean = false) => {
  if (!props.banco) return;

  emit('save', {
    banco_nome: props.banco.nome,
    banco_cor: props.banco.cor,
    saldo_inicial: saldoNumber.value,
    descricao: descricao.value.trim(),
    tipo: tipo.value,
    cor: cor.value,
    incluir_soma_inicial: incluirSoma.value,
  }, createNew);

  if (!createNew) {
    emit('close');
  } else {
    reset();
    emit('back'); // Volta para ETAPA 1
  }
};

watch(
  () => props.open,
  (isOpen) => {
    if (isOpen) {
      reset();
    }
  }
);
</script>

<template>
  <div v-if="open" class="fixed inset-0 z-[60]">
    <button
      class="absolute inset-0 bg-black/50 backdrop-blur-sm"
      type="button"
      @click="$emit('close')"
      aria-label="Fechar"
    ></button>

    <div
      class="absolute inset-x-0 bottom-0 max-h-[calc(100vh-150px)] w-full overflow-hidden rounded-t-[24px] bg-white shadow-[0_-4px_20px_rgba(0,0,0,0.25)]"
      role="dialog"
      aria-modal="true"
    >
      <div class="flex h-full flex-col">
        <header class="relative flex h-14 items-center px-4">
          <button class="h-6 w-6 text-[#6B7280]" type="button" @click="$emit('back')" aria-label="Voltar">
            <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M15 18l-6-6 6-6" />
            </svg>
          </button>

          <div class="pointer-events-none absolute inset-0 flex items-center justify-center">
            <div class="text-[14px] font-bold text-[#1F2937]">Nova conta</div>
          </div>

          <button class="ml-auto h-6 w-6 text-[#6B7280]" type="button" @click="$emit('close')" aria-label="Fechar">
            <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M18 6L6 18" />
              <path d="M6 6l12 12" />
            </svg>
          </button>
        </header>

        <div class="flex-1 overflow-y-auto px-6 pb-6">
          <!-- Saldo Display -->
          <div class="mt-6 flex items-center justify-center py-6">
            <div class="text-center">
              <div class="text-4xl font-bold text-[#14B8A6]">R$</div>
              <input
                class="mt-2 w-full bg-transparent text-center text-3xl font-bold text-slate-900 focus:outline-none focus:ring-0"
                inputmode="numeric"
                :value="saldo"
                @input="onSaldoInput"
                placeholder="0,00"
                aria-label="Saldo inicial"
              />
            </div>
          </div>

          <!-- Banco -->
          <div v-if="banco" class="mt-6">
            <div class="mb-2 text-xs font-semibold uppercase text-slate-500">Instituição financeira</div>
            <button
              type="button"
              class="w-full rounded-2xl border border-slate-200 bg-white p-4 text-left transition hover:bg-slate-50"
              @click="$emit('back')"
            >
              <div class="flex items-center justify-between">
                <div class="flex items-center gap-2">
                  <span class="text-2xl">{{ banco.logo }}</span>
                  <span class="font-semibold text-slate-900">{{ banco.nome }}</span>
                </div>
                <svg class="h-5 w-5 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M9 5l7 7-7 7" />
                </svg>
              </div>
            </button>
          </div>

          <!-- Descrição -->
          <div class="mt-6">
            <div class="mb-2 text-xs font-semibold uppercase text-slate-500">Descrição (opcional)</div>
            <input
              v-model="descricao"
              type="text"
              placeholder="Ex: Conta salário, Conta pessoal..."
              class="w-full rounded-xl border border-[#E5E7EB] bg-[#F9FAFB] px-4 py-3 text-sm placeholder:text-[#9CA3AF] focus:border-[#14B8A6] focus:outline-none focus:ring-0"
            />
          </div>

          <!-- Tipo de Conta -->
          <div class="mt-6">
            <div class="mb-3 text-xs font-semibold uppercase text-slate-500">Tipo de conta</div>
            <div class="relative rounded-xl border border-[#E5E7EB] bg-[#F9FAFB]">
              <select
                v-model="tipo"
                class="relative w-full appearance-none rounded-xl border-0 bg-transparent px-4 py-3 text-sm text-slate-900 focus:outline-none focus:ring-0"
              >
                <option v-for="t in tipos" :key="t.id" :value="t.id">
                  {{ t.icone }} {{ t.nome }}
                </option>
              </select>
              <span class="pointer-events-none absolute inset-y-0 right-3 flex items-center text-slate-400">
                <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M6 9l6 6 6-6" />
                </svg>
              </span>
            </div>
          </div>

          <!-- Cor -->
          <div class="mt-6">
            <div class="mb-3 text-xs font-semibold uppercase text-slate-500">Cor da conta</div>
            <div class="flex gap-2">
              <button
                v-for="c in cores"
                :key="c"
                type="button"
                class="h-10 w-10 rounded-lg border-2 transition"
                :style="{ backgroundColor: c }"
                :class="cor === c ? 'border-gray-800' : 'border-transparent'"
                @click="cor = c"
                :aria-label="`Cor ${c}`"
              ></button>
            </div>
          </div>

          <!-- Include in Summary -->
          <div class="mt-6 rounded-xl border border-[#E5E7EB] bg-[#F9FAFB] p-4">
            <div class="flex items-center justify-between">
              <div class="text-sm text-slate-700">Incluir na soma da tela inicial</div>
              <button
                type="button"
                class="relative inline-flex h-6 w-11 items-center rounded-full transition"
                :class="incluirSoma ? 'bg-[#14B8A6]' : 'bg-[#E5E7EB]'"
                @click="incluirSoma = !incluirSoma"
                aria-label="Incluir na soma"
              >
                <span
                  class="inline-block h-5 w-5 transform rounded-full bg-white transition"
                  :class="incluirSoma ? 'translate-x-5' : 'translate-x-0.5'"
                ></span>
              </button>
            </div>
          </div>
        </div>

        <footer class="px-6 pt-4 pb-[calc(24px+env(safe-area-inset-bottom))]">
          <div class="flex gap-3">
            <button
              class="flex-1 rounded-xl border border-[#E5E7EB] py-3 text-sm font-semibold text-[#6B7280] transition hover:bg-slate-50"
              type="button"
              @click="save(false)"
            >
              Salvar
            </button>
            <button
              class="flex-1 rounded-xl bg-[#14B8A6] py-3 text-sm font-semibold text-white shadow-lg shadow-teal-500/20 transition hover:bg-[#0D9488]"
              type="button"
              @click="save(true)"
            >
              Salvar e Criar Nova
            </button>
          </div>
        </footer>
      </div>
    </div>
  </div>
</template>

<style scoped>
select {
  background-image: none !important;
  -webkit-appearance: none !important;
  -moz-appearance: none !important;
  appearance: none !important;
}
</style>
