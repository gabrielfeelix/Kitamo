<script setup lang="ts">
import { ref, computed, watch } from 'vue';
import { formatMoneyInputCentsShift, moneyInputToNumber } from '@/lib/moneyInput';
import { preventNonDigitKeydown } from '@/lib/inputGuards';

const props = defineProps<{
  open: boolean;
  wallet: {
    id: string;
    name: string;
    initial_balance?: number;
    current_balance: number;
    color?: string;
  } | null;
}>();

const emit = defineEmits<{
  (event: 'close'): void;
  (event: 'save', payload: {
    id: string;
    name: string;
    initial_balance: number;
    color: string;
  }): void;
}>();

// State
const name = ref('');
const initialBalance = ref('');
const color = ref('#14B8A6');
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
  emit('save', {
    id: props.wallet.id,
    name: name.value.trim(),
    initial_balance: initialBalanceNumber.value,
    color: color.value,
  });
};

const close = () => emit('close');

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
  }
);
</script>

<template>
  <div v-if="open" class="fixed inset-0 z-[90] bg-white">
    <!-- Header -->
    <header class="flex items-center gap-3 px-5 pb-4 pt-[calc(1rem+env(safe-area-inset-top))]">
      <button
        type="button"
        class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-100 text-slate-600"
        aria-label="Voltar"
        @click="close"
      >
        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M15 18l-6-6 6-6" />
        </svg>
      </button>
      <div class="text-xl font-semibold tracking-tight text-slate-900">Editar Carteira</div>
    </header>

    <!-- Main Content -->
    <main class="mx-auto w-full max-w-md px-5 pb-[calc(6rem+env(safe-area-inset-bottom))]">
      <!-- Wallet Icon (Fixed) -->
      <div class="flex justify-center pt-4 pb-6">
        <div class="flex h-20 w-20 items-center justify-center rounded-3xl bg-teal-50 text-teal-600">
          <svg class="h-10 w-10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <rect x="2" y="5" width="20" height="14" rx="3"/>
            <path d="M2 10h20"/>
            <circle cx="16" cy="14" r="2"/>
          </svg>
        </div>
      </div>

      <!-- Form Fields -->
      <div class="space-y-5">
        <!-- Name Field -->
        <div>
          <div class="mb-2 text-sm font-semibold text-slate-700">Nome da carteira</div>
          <input
            v-model="name"
            type="text"
            placeholder="Ex: Carteira Principal..."
            class="w-full appearance-none rounded-2xl border border-slate-200 bg-slate-50 px-4 py-4 text-sm font-semibold text-slate-700 placeholder:text-slate-400 focus:border-teal-400 focus:outline-none focus:ring-0 focus-visible:outline-none"
          />
        </div>

        <!-- Initial Balance Field -->
        <div>
          <div class="mb-2 text-sm font-semibold text-slate-700">Saldo inicial</div>
          <input
            :value="initialBalance"
            @input="onBalanceInput"
            type="text"
            inputmode="numeric"
            pattern="[0-9]*"
            placeholder="0,00"
            class="w-full appearance-none rounded-2xl border border-slate-200 bg-slate-50 px-4 py-4 text-sm font-semibold text-slate-700 focus:border-teal-400 focus:outline-none focus:ring-0 focus-visible:outline-none"
            @keydown="preventNonDigitKeydown"
            aria-label="Saldo inicial"
          />

          <!-- Warning when balance changed -->
          <div v-if="balanceChanged" class="mt-3 rounded-lg border-l-4 border-amber-500 bg-amber-50 p-3">
            <div class="flex items-start gap-2">
              <div class="text-lg">⚠️</div>
              <div class="flex-1">
                <h3 class="mb-1 text-sm font-semibold text-amber-900">Atenção!</h3>
                <p class="text-xs text-amber-700">
                  Alterar o saldo inicial pode impactar a conciliação de contas.
                  Recomendamos criar uma transação de ajuste ao invés de alterar diretamente.
                </p>
              </div>
            </div>
          </div>
        </div>

        <!-- Color Picker -->
        <div>
          <div class="mb-3 text-sm font-semibold text-slate-700">Cor da carteira</div>
          <div class="flex gap-3">
            <button
              v-for="c in colors"
              :key="c"
              type="button"
              class="h-12 w-12 rounded-xl border-2 transition"
              :style="{ backgroundColor: c }"
              :class="color === c ? 'border-slate-800 shadow-lg' : 'border-slate-200 hover:border-slate-300'"
              @click="color = c"
              :aria-label="`Cor ${c}`"
            />
          </div>
        </div>
      </div>
    </main>

    <!-- Footer -->
    <footer class="fixed inset-x-0 bottom-0 border-t border-slate-200 bg-white px-5 pt-4 pb-[calc(1rem+env(safe-area-inset-bottom))]">
      <button
        type="button"
        class="w-full rounded-2xl bg-teal-500 py-3 text-sm font-semibold text-white shadow-lg shadow-teal-500/20 transition hover:bg-teal-600"
        @click="save"
      >
        Salvar alterações
      </button>
    </footer>
  </div>
</template>
