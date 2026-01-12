<script setup lang="ts">
const props = defineProps<{
    open: boolean;
}>();

const emit = defineEmits<{
    (event: 'close'): void;
    (event: 'choose', mode: 'csv' | 'invoice' | 'open_finance'): void;
}>();
</script>

<template>
    <div v-if="open" class="fixed inset-0 z-[90]">
        <button class="absolute inset-0 bg-black/40 backdrop-blur-sm" type="button" @click="emit('close')" aria-label="Fechar"></button>

        <div class="absolute left-1/2 top-1/2 w-[680px] -translate-x-1/2 -translate-y-1/2 overflow-hidden rounded-2xl bg-white shadow-[0_30px_80px_-40px_rgba(15,23,42,0.6)] ring-1 ring-slate-200/60">
            <header class="flex items-center justify-between px-8 py-6">
                <div class="text-lg font-semibold text-slate-900">Como deseja importar?</div>
                <button
                    type="button"
                    class="flex h-10 w-10 items-center justify-center rounded-xl bg-slate-50 text-slate-400 hover:bg-slate-100"
                    aria-label="Fechar"
                    @click="emit('close')"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M18 6L6 18" />
                        <path d="M6 6l12 12" />
                    </svg>
                </button>
            </header>

            <div class="grid grid-cols-3 gap-6 px-8 pb-8">
                <button
                    type="button"
                    class="group rounded-2xl border border-slate-200 bg-white px-6 py-8 text-center hover:border-emerald-200 hover:bg-emerald-50/40"
                    @click="emit('choose', 'csv')"
                >
                    <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-slate-50 text-slate-300 group-hover:bg-white">
                        <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
                            <path d="M14 2v6h6" />
                            <path d="M8 13h8" />
                            <path d="M8 17h6" />
                        </svg>
                    </div>
                    <div class="mt-5 text-sm font-semibold text-slate-900">Arquivo CSV</div>
                    <div class="mt-2 text-xs font-semibold text-slate-400">Planilhas do Excel ou<br />Google Sheets</div>
                </button>

                <button
                    type="button"
                    class="group rounded-2xl border border-slate-200 bg-white px-6 py-8 text-center hover:border-emerald-200 hover:bg-emerald-50/40"
                    @click="emit('choose', 'invoice')"
                >
                    <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-slate-50 text-slate-300 group-hover:bg-white">
                        <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M4 7h4l2-2h4l2 2h4v12H4V7Z" />
                            <circle cx="12" cy="13" r="3" />
                        </svg>
                    </div>
                    <div class="mt-5 text-sm font-semibold text-slate-900">Ler Fatura</div>
                    <div class="mt-2 text-xs font-semibold text-slate-400">PDF ou foto de fatura de<br />cartão</div>
                </button>

                <button
                    type="button"
                    class="group rounded-2xl border border-slate-200 bg-white px-6 py-8 text-center hover:border-emerald-200 hover:bg-emerald-50/40"
                    @click="emit('choose', 'open_finance')"
                >
                    <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-slate-50 text-slate-300 group-hover:bg-white">
                        <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M3 10h18" />
                            <path d="M5 10V8l7-5 7 5v2" />
                            <path d="M6 10v9" />
                            <path d="M18 10v9" />
                        </svg>
                    </div>
                    <div class="mt-5 text-sm font-semibold text-slate-900">Open Finance</div>
                    <div class="mt-2 text-xs font-semibold text-slate-400">Conectar conta bancária<br />automaticamente</div>
                </button>
            </div>
        </div>
    </div>
</template>

