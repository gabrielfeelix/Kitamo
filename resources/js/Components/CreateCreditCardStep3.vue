<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import { formatMoneyInputCentsShift, moneyInputToNumber, numberToMoneyInput } from '@/lib/moneyInput';
import { preventNonDigitKeydown } from '@/lib/inputGuards';
import { requestJson } from '@/lib/kitamoApi';
import type { BancoSelecionado } from './CreateCreditCardStep1.vue';
import type { CreditCardModalPayload } from './CreditCardModal.vue';

const props = defineProps<{
  open: boolean;
  banco: BancoSelecionado | null;
}>();

const emit = defineEmits<{
  (event: 'close'): void;
  (event: 'back'): void;
  (event: 'save'): void;
}>();

// State
const nome = ref('');
const bandeira = ref<'visa' | 'mastercard' | 'elo' | 'amex'>('visa');
const limite = ref('');
const dia_fechamento = ref<number | null>(null);
const dia_vencimento = ref<number | null>(null);
const cor = ref('#8B5CF6');
const is_primary = ref(false);

// Bandeiras
const bandeiras = [
  { id: 'visa', nome: 'Visa', logo: '💳' },
  { id: 'mastercard', nome: 'Mastercard', logo: '💳' },
  { id: 'elo', nome: 'Elo', logo: '💳' },
  { id: 'amex', nome: 'Amex', logo: '💳' },
];

// Cores
const cores = ['#8B5CF6', '#3B82F6', '#10B981', '#F59E0B', '#EF4444', '#1F2937'];
const dias = Array.from({ length: 31 }, (_, idx) => idx + 1);

const onLimiteInput = (event: Event) => {
  const target = event.target as HTMLInputElement;
  limite.value = formatMoneyInputCentsShift(target.value);
};

const limiteNumber = computed(() => {
  return moneyInputToNumber(limite.value);
});

const isFormValid = computed(() => {
  return (
    nome.value.trim() !== '' &&
    bandeira.value !== null &&
    limite.value.trim() !== '' &&
    dia_fechamento.value != null &&
    dia_vencimento.value != null &&
    dia_fechamento.value >= 1 &&
    dia_fechamento.value <= 31 &&
    dia_vencimento.value >= 1 &&
    dia_vencimento.value <= 31
  );
});

const reset = () => {
  nome.value = props.banco?.nome ?? '';
  bandeira.value = 'visa';
  limite.value = '';
  dia_fechamento.value = null;
  dia_vencimento.value = null;
  cor.value = props.banco?.cor ?? '#8B5CF6';
  is_primary.value = false;
};

const isSaving = ref(false);

const save = async () => {
  if (!isFormValid.value) return;

  isSaving.value = true;
  try {
    await requestJson('/api/cartoes', {
      method: 'POST',
      body: JSON.stringify({
        nome: nome.value.trim(),
        bandeira: bandeira.value,
        limite: limiteNumber.value,
        dia_fechamento: dia_fechamento.value,
        dia_vencimento: dia_vencimento.value,
        cor: cor.value,
        icone: 'credit-card',
        is_primary: is_primary.value,
      }),
    });
    emit('save');
  } catch (error) {
    console.error('Erro ao salvar cartão:', error);
  } finally {
    isSaving.value = false;
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

    <div class="absolute inset-0 w-full bg-white" role="dialog" aria-modal="true">
      <div class="flex h-full flex-col">
        <header class="relative flex items-center px-4 pt-[calc(0.5rem+env(safe-area-inset-top))] pb-3">
          <button class="h-6 w-6 text-[#6B7280]" type="button" @click="$emit('back')" aria-label="Voltar">
            <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M15 18l-6-6 6-6" />
            </svg>
          </button>

          <div class="pointer-events-none absolute inset-0 flex items-center justify-center">
            <div class="text-[14px] font-bold text-[#1F2937]">Novo Cartão</div>
          </div>

          <button class="ml-auto h-6 w-6 text-[#6B7280]" type="button" @click="$emit('close')" aria-label="Fechar">
            <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M18 6L6 18" />
              <path d="M6 6l12 12" />
            </svg>
          </button>
        </header>

        <div class="flex-1 overflow-y-auto px-6 pb-[calc(1.5rem+env(safe-area-inset-bottom))]">
          <!-- Banco Info -->
          <div v-if="banco" class="mt-6">
            <div class="mb-2 text-xs font-semibold uppercase text-slate-500">Instituição financeira</div>
            <div class="rounded-2xl border border-slate-200 bg-slate-50 px-4 py-4">
              <div class="flex items-center gap-3">
                <span class="text-3xl">{{ banco.logo }}</span>
                <span class="font-semibold text-slate-900">{{ banco.nome }}</span>
              </div>
            </div>
          </div>

          <!-- Nome do Cartão -->
          <div class="mt-6">
            <div class="mb-2 text-sm font-bold text-[#374151]">Nome do cartão</div>
            <input
              v-model="nome"
              type="text"
              placeholder="Ex: Nubank Roxo"
              maxlength="50"
              class="h-11 w-full appearance-none rounded-lg border border-[#E5E7EB] bg-[#F9FAFB] px-3 text-base text-[#374151] placeholder:text-[#9CA3AF] focus:border-[#14B8A6] focus:outline-none focus:ring-0 focus-visible:outline-none"
            />
          </div>

          <!-- Bandeira -->
          <div class="mt-6">
            <div class="mb-3 text-sm font-bold text-[#374151]">Bandeira</div>
            <div class="grid grid-cols-4 gap-3">
              <button
                v-for="b in bandeiras"
                :key="b.id"
                type="button"
                class="flex h-14 items-center justify-center rounded-xl border-2 font-semibold transition"
                :class="
                  bandeira === b.id
                    ? 'border-[#14B8A6] bg-teal-50 text-[#14B8A6]'
                    : 'border-[#E5E7EB] bg-white text-[#6B7280]'
                "
                @click="bandeira = b.id as any"
              >
                <span class="text-2xl">{{ b.logo }}</span>
              </button>
            </div>
          </div>

          <!-- Limite -->
          <div class="mt-6">
            <div class="mb-2 text-sm font-bold text-[#374151]">Limite total</div>
            <div class="flex h-11 items-center gap-1 rounded-lg border border-[#E5E7EB] bg-[#F9FAFB] px-3">
              <span class="text-base text-[#6B7280]">R$</span>
              <input
                class="h-full w-full flex-1 appearance-none border-0 bg-transparent text-center text-base text-[#374151] outline-none focus:outline-none focus:ring-0 focus-visible:outline-none"
                type="text"
                inputmode="numeric"
                pattern="[0-9]*"
                autocomplete="off"
                :value="limite"
                @input="onLimiteInput"
                @keydown="preventNonDigitKeydown"
                placeholder="0,00"
                aria-label="Limite"
              />
            </div>
          </div>

          <!-- Datas de Fechamento e Vencimento -->
          <div class="mt-6">
            <div class="mb-3 text-sm font-bold text-[#374151]">Datas</div>
            <div class="grid grid-cols-2 gap-3">
              <div>
                <label class="mb-2 block text-xs text-[#6B7280]">Fechamento</label>
                <div class="relative">
                  <select
                    :value="dia_fechamento ?? ''"
                    class="h-11 w-full appearance-none rounded-lg border border-[#E5E7EB] bg-[#F9FAFB] px-3 pr-9 text-center text-base text-[#374151] focus:border-[#14B8A6] focus:outline-none focus:ring-0"
                    @change="(e) => { dia_fechamento = Number((e.target as HTMLSelectElement).value) || null }"
                  >
                    <option value="" disabled>Dia</option>
                    <option v-for="d in dias" :key="d" :value="d">{{ d }}</option>
                  </select>
                  <span class="pointer-events-none absolute inset-y-0 right-3 flex items-center text-slate-400">
                    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                      <path d="M6 9l6 6 6-6" />
                    </svg>
                  </span>
                </div>
              </div>
              <div>
                <label class="mb-2 block text-xs text-[#6B7280]">Vencimento</label>
                <div class="relative">
                  <select
                    :value="dia_vencimento ?? ''"
                    class="h-11 w-full appearance-none rounded-lg border border-[#E5E7EB] bg-[#F9FAFB] px-3 pr-9 text-center text-base text-[#374151] focus:border-[#14B8A6] focus:outline-none focus:ring-0"
                    @change="(e) => { dia_vencimento = Number((e.target as HTMLSelectElement).value) || null }"
                  >
                    <option value="" disabled>Dia</option>
                    <option v-for="d in dias" :key="d" :value="d">{{ d }}</option>
                  </select>
                  <span class="pointer-events-none absolute inset-y-0 right-3 flex items-center text-slate-400">
                    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                      <path d="M6 9l6 6 6-6" />
                    </svg>
                  </span>
                </div>
              </div>
            </div>
          </div>

          <!-- Cores -->
          <div class="mt-6">
            <div class="mb-3 text-sm font-bold text-[#374151]">Cor do cartão</div>
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

          <!-- Is Primary -->
          <div class="mt-6 rounded-xl border border-[#E5E7EB] bg-[#F9FAFB] p-4">
            <div class="flex items-center justify-between">
              <div class="text-sm text-slate-700">Marcar como principal</div>
              <button
                type="button"
                class="relative inline-flex h-6 w-11 items-center rounded-full transition"
                :class="is_primary ? 'bg-[#14B8A6]' : 'bg-[#E5E7EB]'"
                @click="is_primary = !is_primary"
                aria-label="Marcar como principal"
              >
                <span
                  class="inline-block h-5 w-5 transform rounded-full bg-white transition"
                  :class="is_primary ? 'translate-x-5' : 'translate-x-0.5'"
                ></span>
              </button>
            </div>
          </div>
        </div>

        <footer class="shrink-0 border-t border-slate-100 px-6 pt-4 pb-[calc(1rem+env(safe-area-inset-bottom))]">
          <div class="flex gap-3">
            <button
              class="flex-1 rounded-xl border border-[#E5E7EB] py-3 text-sm font-semibold text-[#6B7280] transition hover:bg-slate-50"
              type="button"
              @click="$emit('close')"
            >
              Cancelar
            </button>
            <button
              :disabled="!isFormValid || isSaving"
              class="flex-1 rounded-xl bg-[#14B8A6] py-3 text-sm font-semibold text-white shadow-lg shadow-teal-500/20 transition hover:bg-[#0D9488] disabled:opacity-50 disabled:cursor-not-allowed"
              type="button"
              @click="save"
            >
              {{ isSaving ? 'Adicionando...' : 'Adicionar cartão' }}
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
