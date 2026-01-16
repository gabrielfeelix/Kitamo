<script setup lang="ts">
import { ref, computed } from 'vue';

export type BancoSelecionado = {
  nome: string;
  logo: string;
  cor: string;
};

const props = defineProps<{
  open: boolean;
}>();

const emit = defineEmits<{
  (event: 'close'): void;
  (event: 'select', banco: BancoSelecionado): void;
}>();

const search = ref('');

const bancos = [
  { nome: 'Nubank', logo: '🟣', cor: '#8B10AE' },
  { nome: 'Banco Inter', logo: '🟢', cor: '#FF7A00' },
  { nome: 'Itaú', logo: '🟠', cor: '#EC7000' },
  { nome: 'Bradesco', logo: '🔴', cor: '#CC092F' },
  { nome: 'Banco do Brasil', logo: '🟡', cor: '#FFDD00' },
  { nome: 'Caixa', logo: '🔵', cor: '#0066B3' },
  { nome: 'Santander', logo: '🔴', cor: '#EC0000' },
  { nome: 'C6 Bank', logo: '⚫', cor: '#000000' },
  { nome: 'PicPay', logo: '🟢', cor: '#21C25E' },
  { nome: 'Neon', logo: '🔵', cor: '#00D9E1' },
  { nome: 'Outro banco', logo: '⚪', cor: '#64748B' },
];

const bancosFiltrados = computed(() => {
  const term = search.value.toLowerCase();
  return term ? bancos.filter((b) => b.nome.toLowerCase().includes(term)) : bancos;
});

const selectBanco = (banco: typeof bancos[0]) => {
  emit('select', banco);
};
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
          <button class="h-6 w-6 text-[#6B7280]" type="button" @click="$emit('close')" aria-label="Fechar">
            <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M18 6L6 18" />
              <path d="M6 6l12 12" />
            </svg>
          </button>

          <div class="pointer-events-none absolute inset-0 flex items-center justify-center">
            <div class="text-center text-[14px] font-bold text-[#1F2937]">
              Qual é a instituição financeira?
            </div>
          </div>
        </header>

        <div class="flex-1 overflow-y-auto px-6 pb-6">
          <!-- Search -->
          <div class="mt-4">
            <input
              v-model="search"
              type="text"
              placeholder="🔍 Buscar por nome"
              class="w-full rounded-xl border border-[#E5E7EB] bg-[#F9FAFB] px-4 py-3 text-sm placeholder:text-[#9CA3AF] focus:border-[#14B8A6] focus:outline-none focus:ring-0"
            />
          </div>

          <!-- Banks List -->
          <div class="mt-6 grid grid-cols-2 gap-3">
            <button
              v-for="banco in bancosFiltrados"
              :key="banco.nome"
              type="button"
              class="aspect-[2/3] w-full overflow-hidden rounded-2xl border border-slate-200 bg-white p-4 text-left shadow-sm ring-1 ring-slate-200/60 transition hover:bg-slate-50"
              @click="selectBanco(banco)"
            >
              <div class="flex h-full flex-col">
                <div class="flex items-start justify-between">
                  <span
                    class="flex h-11 w-11 items-center justify-center rounded-2xl text-xl"
                    :style="{ backgroundColor: `${banco.cor}22`, color: banco.cor }"
                    aria-hidden="true"
                  >
                    {{ banco.logo }}
                  </span>
                  <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                    <path d="M9 5l7 7-7 7" />
                  </svg>
                </div>

                <div class="mt-4 flex-1">
                  <div class="line-clamp-2 text-base font-semibold leading-tight text-slate-900">
                    {{ banco.nome }}
                  </div>
                  <div class="mt-2 text-xs font-semibold text-slate-400">Toque para selecionar</div>
                </div>

                <div class="mt-3 h-1 w-full rounded-full bg-slate-100">
                  <div class="h-1 rounded-full" :style="{ width: '35%', backgroundColor: banco.cor }"></div>
                </div>
              </div>
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
