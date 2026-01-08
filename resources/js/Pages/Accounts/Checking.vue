<script setup lang="ts">
import { computed } from 'vue';
import { Link, usePage } from '@inertiajs/vue3';
import SorsLayout from '@/Layouts/SorsLayout.vue';

const page = usePage();
const userName = computed(() => page.props.auth?.user?.name ?? 'Gabriel');
</script>

<template>
    <SorsLayout title="Visão Geral" :subtitle="`Bem-vindo de volta, ${userName}.`">
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
    </SorsLayout>
</template>

