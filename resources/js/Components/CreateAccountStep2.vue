<script setup lang="ts">
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
            <div class="text-[14px] font-bold text-[#1F2937]">Nova conta</div>
          </div>

          <button class="ml-auto h-6 w-6 text-[#6B7280]" type="button" @click="$emit('close')" aria-label="Fechar">
            <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M18 6L6 18" />
              <path d="M6 6l12 12" />
            </svg>
          </button>
        </header>

        <div class="flex-1 overflow-y-auto px-6 pb-[calc(1.5rem+env(safe-area-inset-bottom))]">
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
            disabled
            class="mt-4 w-full cursor-not-allowed rounded-2xl border border-dashed border-slate-200 bg-slate-50 p-4 text-left opacity-50"
          >
            <div class="flex items-center justify-between gap-3">
              <div class="font-semibold text-slate-900">Automática</div>
              <span class="rounded-full bg-slate-200 px-2 py-0.5 text-[10px] font-bold tracking-wide text-slate-700">EM BREVE</span>
            </div>
            <p class="mt-2 text-xs text-slate-600">
              As receitas e despesas serão atualizadas automaticamente uma vez ao dia, cabendo a você somente categorizá-las.
            </p>
          </button>

          <!-- Option 2: Manual -->
          <button
            type="button"
            class="mt-3 w-full rounded-2xl border border-slate-200 bg-white p-4 text-left transition hover:bg-slate-50"
            @click="emit('selectMethod', 'manual')"
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
</template>
