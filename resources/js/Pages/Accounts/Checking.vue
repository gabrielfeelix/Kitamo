<script setup lang="ts">
import { computed } from 'vue';
import { Link, usePage } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import KitamoLayout from '@/Layouts/KitamoLayout.vue';
import { useMediaQuery } from '@/composables/useMediaQuery';

const page = usePage();
const userName = computed(() => page.props.auth?.user?.name ?? 'Gabriel');
const isMobile = useMediaQuery('(max-width: 767px)');
</script>

<template>
    <MobileShell v-if="isMobile">
        <header class="flex items-center gap-3 pt-2">
            <Link
                :href="route('accounts.index')"
                class="flex h-10 w-10 items-center justify-center rounded-2xl bg-white text-slate-600 shadow-sm ring-1 ring-slate-200/60"
                aria-label="Voltar"
            >
                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M15 18l-6-6 6-6" />
                </svg>
            </Link>
            <div class="text-xl font-semibold tracking-tight text-slate-900">Nubank C/C</div>
        </header>

        <div class="mt-6 space-y-3">
            <div class="rounded-3xl bg-white p-5 shadow-sm ring-1 ring-slate-200/60">
                <div class="text-[11px] font-semibold uppercase tracking-wide text-slate-400">Saldo atual</div>
                <div class="mt-3 text-3xl font-semibold text-slate-900">R$ 2345.67</div>
            </div>

            <div class="rounded-3xl bg-white p-5 shadow-sm ring-1 ring-slate-200/60">
                <div class="text-[11px] font-semibold uppercase tracking-wide text-slate-400">Extrato</div>
                <div class="mt-4 space-y-3">
                    <div class="flex items-center justify-between">
                        <div>
                            <div class="text-sm font-semibold text-slate-900">Starbucks</div>
                            <div class="text-xs text-slate-400">Alimentação • Hoje</div>
                        </div>
                        <div class="text-sm font-semibold text-slate-900">-25.00</div>
                    </div>
                </div>
            </div>
        </div>
    </MobileShell>

    <KitamoLayout v-else title="Visão Geral" :subtitle="`Bem-vindo de volta, ${userName}.`">
        <div class="space-y-6">
            <div class="flex items-center gap-4">
                <Link
                    :href="route('accounts.index')"
                    class="flex h-11 w-11 items-center justify-center rounded-full border border-slate-200 bg-white text-slate-600 shadow-sm hover:bg-slate-50"
                    aria-label="Voltar"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M15 18l-6-6 6-6" />
                    </svg>
                </Link>
                <div class="text-2xl font-semibold text-slate-900">Nubank C/C</div>
            </div>

            <div class="grid gap-6 xl:grid-cols-[420px_1fr]">
                <div class="rounded-[28px] border border-white/70 bg-white p-6 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)]">
                    <div class="text-xs font-semibold uppercase tracking-wide text-slate-400">Saldo atual</div>
                    <div class="mt-4 text-4xl font-semibold text-slate-900">R$ 2345.67</div>
                </div>

                <div>
                    <div class="px-2 text-xs font-semibold uppercase tracking-wide text-slate-400">Extrato de movimentações</div>
                    <div class="mt-4 rounded-[28px] border border-white/70 bg-white p-4 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)]">
                        <div class="flex items-center justify-between rounded-2xl px-4 py-5 shadow-sm">
                            <div class="flex items-center gap-4">
                                <span class="flex h-12 w-12 items-center justify-center rounded-2xl bg-red-50 text-red-500">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <rect x="5" y="4" width="14" height="16" rx="4" />
                                        <path d="M8 8h8" />
                                    </svg>
                                </span>
                                <div>
                                    <div class="text-sm font-semibold text-slate-900">Starbucks</div>
                                    <div class="text-xs text-slate-500">Alimentação • Hoje</div>
                                </div>
                            </div>
                            <div class="text-sm font-semibold text-slate-900">-25.00</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </KitamoLayout>
</template>
