<script setup lang="ts">
import { Head } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopSettingsShell from '@/Layouts/DesktopSettingsShell.vue';
import { useIsMobile } from '@/composables/useIsMobile';

const isMobile = useIsMobile();
</script>

<template>
    <Head title="Categorias & Orçamentos" />

    <MobileShell v-if="isMobile" :show-nav="false">
        <div class="rounded-3xl bg-white p-6 shadow-sm ring-1 ring-slate-200/60">
            <div class="text-sm font-semibold text-slate-900">Categorias & Orçamentos</div>
            <div class="mt-2 text-sm text-slate-500">Ainda vamos definir essa tela no mobile.</div>
        </div>
    </MobileShell>

    <DesktopSettingsShell v-else>
        <div class="overflow-hidden rounded-3xl bg-white px-10 py-9 shadow-sm ring-1 ring-slate-200/60">
            <div class="flex items-center justify-between">
                <div class="text-lg font-semibold text-slate-900">Suas Categorias</div>
                <button type="button" class="inline-flex h-11 items-center gap-2 rounded-xl bg-[#14B8A6] px-5 text-sm font-semibold text-white shadow-lg shadow-emerald-500/20">
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M12 5v14" />
                        <path d="M5 12h14" />
                    </svg>
                    Nova Categoria
                </button>
            </div>

            <div class="mt-8 grid grid-cols-2 gap-6">
                <div class="flex items-center justify-between rounded-2xl bg-slate-50 px-6 py-5 ring-1 ring-slate-200/60">
                    <div class="flex items-center gap-4">
                        <span class="flex h-12 w-12 items-center justify-center rounded-2xl bg-amber-50 text-amber-600">
                            <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M6 6h15l-2 7H7L6 6Z" />
                                <path d="M6 6l-2-2H2" />
                                <circle cx="9" cy="18" r="1.5" />
                                <circle cx="17" cy="18" r="1.5" />
                            </svg>
                        </span>
                        <div>
                            <div class="text-sm font-semibold text-slate-900">Alimentação</div>
                            <div class="mt-1 text-xs font-semibold text-slate-400">Meta: R$ 1.200,00</div>
                        </div>
                    </div>
                    <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M9 18l6-6-6-6" />
                    </svg>
                </div>

                <div class="flex items-center justify-between rounded-2xl bg-slate-50 px-6 py-5 ring-1 ring-slate-200/60">
                    <div class="flex items-center gap-4">
                        <span class="flex h-12 w-12 items-center justify-center rounded-2xl bg-blue-50 text-blue-600">
                            <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M3 10.5L12 3l9 7.5" />
                                <path d="M5 10v10h14V10" />
                            </svg>
                        </span>
                        <div>
                            <div class="text-sm font-semibold text-slate-900">Moradia</div>
                            <div class="mt-1 text-xs font-semibold text-slate-400">Meta: R$ 2.500,00</div>
                        </div>
                    </div>
                    <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M9 18l6-6-6-6" />
                    </svg>
                </div>
            </div>
        </div>
    </DesktopSettingsShell>
</template>
