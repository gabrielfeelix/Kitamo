<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopSettingsShell from '@/Layouts/DesktopSettingsShell.vue';
import { useIsMobile } from '@/composables/useIsMobile';

const isMobile = useIsMobile();
</script>

<template>
    <Head title="Sobre" />

    <MobileShell v-if="isMobile" :show-nav="false">
        <header class="flex items-center gap-3 pt-2">
            <Link
                :href="route('settings')"
                class="flex h-10 w-10 items-center justify-center rounded-2xl bg-white text-slate-600 shadow-sm ring-1 ring-slate-200/60"
                aria-label="Voltar"
            >
                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M15 18l-6-6 6-6" />
                </svg>
            </Link>
            <div class="text-xl font-semibold tracking-tight text-slate-900">Sobre</div>
        </header>

        <div class="mt-10 flex flex-col items-center">
            <div class="flex h-20 w-20 items-center justify-center rounded-[26px] bg-[#14B8A6] text-white shadow-xl shadow-black/10">
                <svg class="h-10 w-10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <rect x="4" y="6" width="16" height="12" rx="3" />
                    <path d="M7 10h4" />
                    <path d="M7 14h6" />
                </svg>
            </div>

            <div class="mt-6 text-2xl font-bold text-slate-900">Financas</div>
            <div class="mt-2 text-center text-sm font-semibold text-slate-500">Controle financeiro simples e eficiente</div>
            <div class="mt-3 rounded-full bg-slate-100 px-4 py-1 text-xs font-semibold text-slate-500">Versão 1.0.0</div>
        </div>

        <div class="mt-10 overflow-hidden rounded-3xl bg-white shadow-sm ring-1 ring-slate-200/60">
            <button type="button" class="flex w-full items-center justify-between px-5 py-4 text-left">
                <div class="text-sm font-semibold text-slate-900">Termos de uso</div>
                <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M9 18l6-6-6-6" />
                </svg>
            </button>
            <div class="border-t border-slate-100">
                <button type="button" class="flex w-full items-center justify-between px-5 py-4 text-left">
                    <div class="text-sm font-semibold text-slate-900">Política de privacidade</div>
                    <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M9 18l6-6-6-6" />
                    </svg>
                </button>
            </div>
            <div class="border-t border-slate-100">
                <button type="button" class="flex w-full items-center justify-between px-5 py-4 text-left">
                    <div class="text-sm font-semibold text-slate-900">Licenças de código aberto</div>
                    <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M9 18l6-6-6-6" />
                    </svg>
                </button>
            </div>
        </div>

        <div class="mt-10">
            <div class="text-base font-semibold text-slate-900">Siga-nos</div>
            <div class="mt-4 flex items-center justify-center gap-5">
                <button type="button" class="flex h-12 w-12 items-center justify-center rounded-full bg-white shadow-sm ring-1 ring-slate-200/60" aria-label="Instagram">
                    <svg class="h-5 w-5 text-pink-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <rect x="4" y="4" width="16" height="16" rx="4" />
                        <circle cx="12" cy="12" r="3.5" />
                        <path d="M17.5 6.5h.01" />
                    </svg>
                </button>
                <button type="button" class="flex h-12 w-12 items-center justify-center rounded-full bg-white shadow-sm ring-1 ring-slate-200/60" aria-label="Twitter">
                    <svg class="h-5 w-5 text-sky-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M22 5.8c-.7.3-1.5.5-2.3.6.8-.5 1.4-1.2 1.7-2.1-.8.5-1.7.8-2.6 1A3.6 3.6 0 0 0 10 6.8c0 .3 0 .6.1.9-3-.2-5.7-1.6-7.5-3.9-.3.6-.4 1.3-.4 2 0 1.2.6 2.4 1.6 3.1-.6 0-1.1-.2-1.6-.4v.1c0 1.8 1.3 3.3 3 3.7-.3.1-.7.1-1.1.1-.2 0-.5 0-.7-.1.5 1.6 2 2.7 3.8 2.7A7.3 7.3 0 0 1 2 18.4 10.4 10.4 0 0 0 7.6 20c6.8 0 10.5-5.7 10.5-10.6v-.5c.7-.5 1.4-1.1 1.9-1.8Z" />
                    </svg>
                </button>
                <button type="button" class="flex h-12 w-12 items-center justify-center rounded-full bg-white shadow-sm ring-1 ring-slate-200/60" aria-label="Facebook">
                    <svg class="h-5 w-5 text-blue-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M14 9h3V6h-3a4 4 0 0 0-4 4v3H7v3h3v6h3v-6h3l1-3h-4v-3a1 1 0 0 1 1-1Z" />
                    </svg>
                </button>
            </div>
        </div>

        <div class="mt-10 rounded-3xl bg-[#E6FFFB] p-6 text-center ring-1 ring-emerald-100">
            <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-white text-[#14B8A6] shadow-sm">
                <svg class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M12 2l3 7h7l-5.5 4 2 7L12 16l-6.5 4 2-7L2 9h7l3-7Z" />
                </svg>
            </div>
            <div class="mt-4 text-sm font-semibold text-slate-900">Está gostando do app?</div>
            <button type="button" class="mt-4 inline-flex h-10 items-center justify-center rounded-full bg-[#14B8A6] px-6 text-sm font-semibold text-white shadow-lg shadow-black/10">
                Avaliar na loja
            </button>
        </div>

        <div class="mt-10 pb-[calc(2rem+env(safe-area-inset-bottom))] text-center text-xs font-semibold text-slate-300">
            <div>Feito com ❤️ no Brasil</div>
            <div class="mt-2">© 2026 - Todos os direitos reservados</div>
        </div>
    </MobileShell>

    <DesktopSettingsShell v-else>
        <div class="rounded-3xl bg-white px-10 py-9 shadow-sm ring-1 ring-slate-200/60">
            <div class="text-lg font-semibold text-slate-900">Sobre</div>
            <div class="mt-6 text-sm font-semibold text-slate-500">Página em construção para desktop.</div>
        </div>
    </DesktopSettingsShell>
</template>
