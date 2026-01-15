<script setup lang="ts">
defineProps<{
  open: boolean;
  title: string;
  message: string;
  warningText?: string;
  danger?: boolean;
  confirmLabel?: string;
  cancelLabel?: string;
}>();

defineEmits<{
  (event: 'confirm'): void;
  (event: 'close'): void;
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

    <div
      class="absolute left-1/2 top-1/2 w-full max-w-sm -translate-x-1/2 -translate-y-1/2 rounded-2xl bg-white p-6 shadow-xl"
      role="dialog"
      aria-modal="true"
    >
      <div class="text-center">
        <div v-if="danger" class="text-4xl">⚠️</div>
        <h2 class="mt-4 text-lg font-semibold text-slate-900">{{ title }}</h2>
        <p class="mt-2 text-sm text-slate-600">{{ message }}</p>

        <div v-if="warningText" class="mt-4 rounded-lg bg-red-50 p-3 text-sm text-red-700">
          {{ warningText }}
        </div>
      </div>

      <div class="mt-6 flex gap-3">
        <button
          class="flex-1 rounded-xl border border-slate-200 py-3 font-semibold text-slate-700 transition hover:bg-slate-50"
          type="button"
          @click="$emit('close')"
        >
          {{ cancelLabel || 'Cancelar' }}
        </button>
        <button
          class="flex-1 rounded-xl py-3 font-semibold text-white transition"
          :class="
            danger ? 'bg-red-600 hover:bg-red-700 shadow-lg shadow-red-600/20' : 'bg-teal-600 hover:bg-teal-700 shadow-lg shadow-teal-600/20'
          "
          type="button"
          @click="$emit('confirm')"
        >
          {{ confirmLabel || 'Confirmar' }}
        </button>
      </div>
    </div>
  </div>
</template>
