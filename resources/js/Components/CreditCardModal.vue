<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import { formatMoneyInputCentsShift, moneyInputToNumber, numberToMoneyInput } from '@/lib/moneyInput';

export type CreditCardModalPayload = {
  id?: string;
  nome: string;
  bandeira: 'visa' | 'mastercard' | 'elo' | 'amex';
  limite: number;
  dia_fechamento: number;
  dia_vencimento: number;
  cor: string;
};

const props = defineProps<{
  open: boolean;
  initial?: CreditCardModalPayload | null;
}>();

const emit = defineEmits<{
  (event: 'close'): void;
  (event: 'save', payload: CreditCardModalPayload): void;
}>();

const close = () => emit('close');

// State
const initialId = ref<string | undefined>(undefined);
const nome = ref('');
const bandeira = ref<'visa' | 'mastercard' | 'elo' | 'amex'>('visa');
const limite = ref('');
const dia_fechamento = ref<number | null>(null);
const dia_vencimento = ref<number | null>(null);
const cor = ref('#8B5CF6');

// Bandeiras
const bandeiras = [
  { id: 'visa', nome: 'Visa', logo: '💳' },
  { id: 'mastercard', nome: 'Mastercard', logo: '💳' },
  { id: 'elo', nome: 'Elo', logo: '💳' },
  { id: 'amex', nome: 'Amex', logo: '💳' },
];

// Cores
const cores = ['#8B5CF6', '#3B82F6', '#10B981', '#F59E0B', '#EF4444', '#1F2937'];

const onLimiteInput = (event: Event) => {
  const target = event.target as HTMLInputElement;
  limite.value = formatMoneyInputCentsShift(target.value);
};

const limiteNumber = computed(() => {
  return moneyInputToNumber(limite.value);
});

const title = computed(() => (initialId.value ? 'Editar cartão' : 'Adicionar cartão de crédito'));

const reset = () => {
  const draft = props.initial ?? null;
  initialId.value = draft?.id;
  nome.value = draft?.nome ?? '';
  bandeira.value = (draft?.bandeira ?? 'visa') as any;
  limite.value = draft ? numberToMoneyInput(draft.limite) : '';
  dia_fechamento.value = draft?.dia_fechamento ?? null;
  dia_vencimento.value = draft?.dia_vencimento ?? null;
  cor.value = draft?.cor ?? '#8B5CF6';
};

const save = () => {
  if (!nome.value.trim()) return; // Validação mínima
  if (!bandeira.value) return;
  if (!limite.value.trim()) return;
  if (dia_fechamento.value == null) return;
  if (dia_vencimento.value == null) return;
  if (dia_fechamento.value < 1 || dia_fechamento.value > 31) return;
  if (dia_vencimento.value < 1 || dia_vencimento.value > 31) return;

  emit('save', {
    id: initialId.value,
    nome: nome.value.trim(),
    bandeira: bandeira.value,
    limite: limiteNumber.value,
    dia_fechamento: dia_fechamento.value,
    dia_vencimento: dia_vencimento.value,
    cor: cor.value,
  });
  close();
};

watch(
  () => props.open,
  (isOpen) => {
    if (!isOpen) return;
    reset();
  }
);
</script>

<template>
  <div v-if="open" class="fixed inset-0 z-[60]">
    <button
      class="absolute inset-0 bg-black/50 backdrop-blur-sm"
      type="button"
      @click="close"
      aria-label="Fechar"
    ></button>

    <div
      class="absolute inset-x-0 bottom-0 max-h-[calc(100vh-150px)] w-full overflow-hidden rounded-t-[24px] bg-white shadow-[0_-4px_20px_rgba(0,0,0,0.25)]"
      role="dialog"
      aria-modal="true"
    >
      <div class="flex h-full flex-col">
        <header class="relative flex h-14 items-center px-4">
          <button class="h-6 w-6 text-[#6B7280]" type="button" @click="close" aria-label="Fechar">
            <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M18 6L6 18" />
              <path d="M6 6l12 12" />
            </svg>
          </button>

          <div class="pointer-events-none absolute inset-0 flex items-center justify-center">
            <div class="text-[18px] font-bold text-[#1F2937]">{{ title }}</div>
          </div>
        </header>

        <div class="flex-1 overflow-y-auto px-6 pb-6">
          <!-- Nome do Cartão -->
          <div class="mt-6">
            <div class="mb-2 text-sm font-bold text-[#374151]">Nome do cartão</div>
            <input
              v-model="nome"
              type="text"
              placeholder="Ex: Nubank Roxo"
              maxlength="50"
              class="h-11 w-full rounded-lg border border-[#E5E7EB] bg-[#F9FAFB] px-3 text-base text-[#374151] placeholder:text-[#9CA3AF] focus:border-[#14B8A6] focus:outline-none focus:ring-0"
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
                class="h-full w-full flex-1 bg-transparent text-center text-base text-[#374151] focus:outline-none focus:ring-0"
                inputmode="numeric"
                autocomplete="off"
                :value="limite"
                @input="onLimiteInput"
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
                <input
                  :value="dia_fechamento ?? ''"
                  type="number"
                  min="1"
                  max="31"
                  placeholder="Dia"
                  class="h-11 w-full rounded-lg border border-[#E5E7EB] bg-[#F9FAFB] px-3 text-center text-base text-[#374151] placeholder:text-[#9CA3AF] focus:border-[#14B8A6] focus:outline-none focus:ring-0"
                  @input="(e) => { const v = Number((e.target as HTMLInputElement).value); dia_fechamento = Number.isFinite(v) && v > 0 ? v : null }"
                />
              </div>
              <div>
                <label class="mb-2 block text-xs text-[#6B7280]">Vencimento</label>
                <input
                  :value="dia_vencimento ?? ''"
                  type="number"
                  min="1"
                  max="31"
                  placeholder="Dia"
                  class="h-11 w-full rounded-lg border border-[#E5E7EB] bg-[#F9FAFB] px-3 text-center text-base text-[#374151] placeholder:text-[#9CA3AF] focus:border-[#14B8A6] focus:outline-none focus:ring-0"
                  @input="(e) => { const v = Number((e.target as HTMLInputElement).value); dia_vencimento = Number.isFinite(v) && v > 0 ? v : null }"
                />
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
        </div>

        <footer class="px-6 pt-4 pb-[calc(24px+env(safe-area-inset-bottom))]">
          <div class="flex gap-3">
            <button
              class="flex-1 rounded-xl border border-[#E5E7EB] py-3 text-sm font-semibold text-[#6B7280] transition hover:bg-slate-50"
              type="button"
              @click="close"
            >
              Cancelar
            </button>
            <button
              class="flex-1 rounded-xl bg-[#14B8A6] py-3 text-sm font-semibold text-white shadow-lg shadow-teal-500/20 transition hover:bg-[#0D9488]"
              type="button"
              @click="save"
            >
              {{ initialId ? 'Salvar alterações' : 'Adicionar' }}
            </button>
          </div>
        </footer>
      </div>
    </div>
  </div>
</template>
