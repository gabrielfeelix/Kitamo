<script setup lang="ts">
import { ref } from 'vue';
import type { BancoSelecionado } from './CreateAccountStep1.vue';

const props = defineProps<{
  open: boolean;
  banco: BancoSelecionado | null;
}>();

const emit = defineEmits<{
  (event: 'back'): void;
  (event: 'close'): void;
  (event: 'selectMethod', method: 'manual' | 'automatic'): void;
}>();

const showComingSoon = ref(false);

const selectMethod = (method: 'manual' | 'automatic') => {
  if (method === 'automatic') {
    showComingSoon.value = true;
  } else {
    emit('selectMethod', method);
    emit('close');
  }
};
</script>

<template>
  <div v-if="open && !showComingSoon" class="fixed inset-0 z-[60]">
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
          <!-- Banco Selecionado -->
          <div v-if="banco" class="mt-4 rounded-2xl border border-slate-200 bg-white p-4">
            <div class="flex items-center gap-2">
              <span class="text-2xl">{{ banco.logo }}</span>
              <span class="font-semibold text-slate-900">{{ banco.nome }}</span>
            </div>
          </div>

          <!-- Question -->
          <div class="mt-6">
            <div class="text-sm font-semibold text-slate-900">De que forma você quer adicionar essa conta?</div>
          </div>

          <!-- Option 1: Automatic -->
          <button
            type="button"
            class="mt-4 w-full rounded-2xl border border-slate-200 bg-white p-4 text-left transition hover:bg-slate-50"
            @click="selectMethod('automatic')"
          >
            <div class="font-semibold text-slate-900">Automática</div>
            <p class="mt-2 text-xs text-slate-600">
              As receitas e despesas serão atualizadas automaticamente uma vez ao dia, cabendo a você somente categorizá-las.
            </p>
          </button>

          <!-- Option 2: Manual -->
          <button
            type="button"
            class="mt-3 w-full rounded-2xl border border-slate-200 bg-white p-4 text-left transition hover:bg-slate-50"
            @click="selectMethod('manual')"
          >
            <div class="font-semibold text-slate-900">Manual</div>
            <p class="mt-2 text-xs text-slate-600">
              As receitas, despesas e categorizações das transações terão que ser adicionadas manualmente.
            </p>
          </button>
        </div>
      </div>
    </div>
  </div>

  <!-- Coming Soon Modal -->
  <div v-if="open && showComingSoon" class="fixed inset-0 z-[60]">
    <button
      class="absolute inset-0 bg-black/50 backdrop-blur-sm"
      type="button"
      @click="showComingSoon = false"
      aria-label="Fechar"
    ></button>

    <div
      class="absolute left-1/2 top-1/2 w-full max-w-sm -translate-x-1/2 -translate-y-1/2 rounded-2xl bg-white p-6 shadow-xl"
      role="dialog"
      aria-modal="true"
    >
      <div class="text-center">
        <div class="text-4xl">ℹ️</div>
        <h2 class="mt-4 text-lg font-semibold text-slate-900">Em breve!</h2>
        <p class="mt-2 text-sm text-slate-600">
          A conexão automática via Open Finance estará disponível em breve. Por enquanto, utilize o modo manual.
        </p>
      </div>

      <button
        class="mt-6 w-full rounded-xl bg-[#14B8A6] py-3 font-semibold text-white hover:bg-[#0D9488]"
        type="button"
        @click="showComingSoon = false"
      >
        Entendi
      </button>
    </div>
  </div>
</template>
