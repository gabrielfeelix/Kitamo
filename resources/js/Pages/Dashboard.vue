<script setup lang="ts">
import { computed } from 'vue';
import { usePage } from '@inertiajs/vue3';
import SorsLayout from '@/Layouts/SorsLayout.vue';

const page = usePage();
const userName = computed(() => page.props.auth?.user?.name ?? 'Gabriel');
</script>

<template>
    <SorsLayout title="Visão Geral" :subtitle="`Bem-vindo de volta, ${userName}.`">
        <div class="grid gap-6 xl:grid-cols-[1.6fr_0.9fr]">
            <div class="space-y-6">
                <div class="rounded-[28px] bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900 p-6 text-white shadow-[0_30px_60px_-40px_rgba(15,23,42,0.8)]">
                    <div class="flex flex-wrap items-center justify-between gap-4">
                        <div class="flex items-center gap-3 text-sm font-semibold text-slate-200">
                            <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-white/10">
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <rect x="3" y="4" width="18" height="14" rx="3" />
                                    <path d="M3 10h18" />
                                </svg>
                            </span>
                            SALDO TOTAL
                        </div>
                        <div class="flex items-center gap-3">
                            <div class="rounded-2xl bg-emerald-500/15 px-4 py-2 text-sm text-emerald-300">
                                <div class="text-xs">Receitas</div>
                                <div class="text-base font-semibold">+5.240</div>
                            </div>
                            <div class="rounded-2xl bg-red-500/15 px-4 py-2 text-sm text-red-300">
                                <div class="text-xs">Gastos</div>
                                <div class="text-base font-semibold">-1.420</div>
                            </div>
                        </div>
                    </div>
                    <div class="mt-6 text-4xl font-semibold tracking-tight">R$ 15.345,67</div>
                    <p class="mt-2 text-sm text-slate-300">Atualizado em tempo real</p>
                </div>

                <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
                    <div class="rounded-2xl border border-slate-100 bg-white p-4 text-center shadow-sm">
                        <div class="mx-auto flex h-11 w-11 items-center justify-center rounded-2xl bg-slate-100 text-slate-600">
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <circle cx="12" cy="12" r="7" />
                                <circle cx="12" cy="12" r="3" />
                            </svg>
                        </div>
                        <div class="mt-3 text-sm font-semibold text-slate-700">Metas</div>
                    </div>
                    <div class="rounded-2xl border border-slate-100 bg-white p-4 text-center shadow-sm">
                        <div class="mx-auto flex h-11 w-11 items-center justify-center rounded-2xl bg-slate-100 text-slate-600">
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M12 6v6l4 2" />
                                <circle cx="12" cy="12" r="9" />
                            </svg>
                        </div>
                        <div class="mt-3 text-sm font-semibold text-slate-700">Orçamentos</div>
                    </div>
                    <div class="rounded-2xl border border-slate-100 bg-white p-4 text-center shadow-sm">
                        <div class="mx-auto flex h-11 w-11 items-center justify-center rounded-2xl bg-slate-100 text-slate-600">
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="4" y="5" width="16" height="16" rx="3" />
                                <path d="M8 3v4" />
                                <path d="M16 3v4" />
                            </svg>
                        </div>
                        <div class="mt-3 text-sm font-semibold text-slate-700">Fixos</div>
                    </div>
                    <div class="rounded-2xl border border-slate-100 bg-white p-4 text-center shadow-sm">
                        <div class="mx-auto flex h-11 w-11 items-center justify-center rounded-2xl bg-slate-100 text-slate-600">
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M7 3h8l4 4v14H7z" />
                                <path d="M15 3v4h4" />
                            </svg>
                        </div>
                        <div class="mt-3 text-sm font-semibold text-slate-700">Relatórios</div>
                    </div>
                </div>

                <div class="rounded-[28px] border border-white/70 bg-white p-6 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)]">
                    <div class="flex items-center justify-between">
                        <h2 class="text-lg font-semibold text-slate-900">Últimas atividades</h2>
                        <button class="text-sm font-semibold text-blue-600" type="button">Ver histórico completo</button>
                    </div>
                    <div class="mt-6 space-y-5">
                        <div class="flex items-center justify-between border-b border-slate-100 pb-4">
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
                        <div class="flex items-center justify-between border-b border-slate-100 pb-4">
                            <div class="flex items-center gap-4">
                                <span class="flex h-12 w-12 items-center justify-center rounded-2xl bg-emerald-50 text-emerald-500">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M12 3v18" />
                                        <path d="M7 7h5a3 3 0 1 1 0 6H7" />
                                    </svg>
                                </span>
                                <div>
                                    <div class="text-sm font-semibold text-slate-900">Salário</div>
                                    <div class="text-xs text-slate-500">Receita • Ontem</div>
                                </div>
                            </div>
                            <div class="text-sm font-semibold text-emerald-600">+5000.00</div>
                        </div>
                        <div class="flex items-center justify-between border-b border-slate-100 pb-4">
                            <div class="flex items-center gap-4">
                                <span class="flex h-12 w-12 items-center justify-center rounded-2xl bg-red-50 text-red-500">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <rect x="5" y="4" width="14" height="16" rx="4" />
                                        <path d="M8 8h8" />
                                    </svg>
                                </span>
                                <div>
                                    <div class="text-sm font-semibold text-slate-900">Uber</div>
                                    <div class="text-xs text-slate-500">Transporte • Ontem</div>
                                </div>
                            </div>
                            <div class="text-sm font-semibold text-slate-900">-23.00</div>
                        </div>
                        <div class="flex items-center justify-between border-b border-slate-100 pb-4">
                            <div class="flex items-center gap-4">
                                <span class="flex h-12 w-12 items-center justify-center rounded-2xl bg-slate-100 text-slate-400">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <rect x="5" y="4" width="14" height="16" rx="4" />
                                        <path d="M8 8h8" />
                                    </svg>
                                </span>
                                <div>
                                    <div class="flex items-center gap-2 text-sm font-semibold text-slate-400">
                                        Spotify
                                        <span class="rounded-full bg-slate-100 px-2 py-1 text-[10px] font-semibold text-slate-400">PENDENTE</span>
                                    </div>
                                    <div class="text-xs text-slate-400">Assinatura • 04/01</div>
                                </div>
                            </div>
                            <div class="text-sm font-semibold text-slate-400">-21.90</div>
                        </div>
                        <div class="flex items-center justify-between">
                            <div class="flex items-center gap-4">
                                <span class="flex h-12 w-12 items-center justify-center rounded-2xl bg-red-50 text-red-500">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <rect x="5" y="4" width="14" height="16" rx="4" />
                                        <path d="M8 8h8" />
                                    </svg>
                                </span>
                                <div>
                                    <div class="text-sm font-semibold text-slate-900">Amazon AWS</div>
                                    <div class="text-xs text-slate-500">Serviços • 03/01</div>
                                </div>
                            </div>
                            <div class="text-sm font-semibold text-slate-900">-150.00</div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="space-y-6">
                <div class="rounded-[28px] border border-white/70 bg-white p-6 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)]">
                    <div class="flex items-center justify-between">
                        <h3 class="text-lg font-semibold text-slate-900">Minhas Contas</h3>
                        <button class="rounded-2xl p-2 text-slate-400 hover:bg-slate-100" type="button" aria-label="Adicionar conta">
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M12 5v14" />
                                <path d="M5 12h14" />
                            </svg>
                        </button>
                    </div>
                    <div class="mt-5 space-y-4">
                        <div class="flex items-center justify-between rounded-2xl border border-slate-100 px-4 py-3">
                            <div class="flex items-center gap-3">
                                <span class="flex h-11 w-11 items-center justify-center rounded-2xl bg-slate-100 text-slate-600">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M12 2l7 7-7 7-7-7 7-7Z" />
                                    </svg>
                                </span>
                                <div>
                                    <div class="text-sm font-semibold text-slate-900">Nubank C/C</div>
                                    <div class="text-xs text-slate-500">Saldo atual</div>
                                </div>
                            </div>
                            <div class="text-sm font-semibold text-slate-900">R$ 2345.67</div>
                        </div>
                        <div class="flex items-center justify-between rounded-2xl border border-slate-100 px-4 py-3">
                            <div class="flex items-center gap-3">
                                <span class="flex h-11 w-11 items-center justify-center rounded-2xl bg-emerald-50 text-emerald-500">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M12 3v18" />
                                        <path d="M8 7h8a3 3 0 1 1 0 6H8" />
                                    </svg>
                                </span>
                                <div>
                                    <div class="text-sm font-semibold text-slate-900">Dinheiro</div>
                                    <div class="text-xs text-slate-500">Saldo atual</div>
                                </div>
                            </div>
                            <div class="text-sm font-semibold text-slate-900">R$ 500.00</div>
                        </div>
                        <div class="flex items-center justify-between rounded-2xl border border-slate-100 px-4 py-3">
                            <div class="flex items-center gap-3">
                                <span class="flex h-11 w-11 items-center justify-center rounded-2xl bg-slate-900 text-white">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <rect x="3" y="5" width="18" height="14" rx="3" />
                                        <path d="M3 10h18" />
                                    </svg>
                                </span>
                                <div>
                                    <div class="text-sm font-semibold text-slate-900">Nubank Cartão</div>
                                    <div class="text-xs text-slate-500">Fatura aberta</div>
                                </div>
                            </div>
                            <div class="text-sm font-semibold text-slate-900">R$ 1450.00</div>
                        </div>
                    </div>
                    <button class="mt-4 w-full rounded-2xl border border-dashed border-slate-200 py-3 text-sm font-semibold text-slate-500" type="button">
                        Ver todas as contas
                    </button>
                </div>

                <div class="rounded-[28px] border border-white/70 bg-white p-6 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)]">
                    <div class="text-sm font-semibold text-slate-400">Balanço</div>
                    <div class="mt-4 h-2 w-full rounded-full bg-slate-100">
                        <div class="h-2 w-3/4 rounded-full bg-slate-400"></div>
                    </div>
                    <p class="mt-3 text-xs text-slate-400">Você economizou 15% mais que no mês passado.</p>
                </div>
            </div>
        </div>
    </SorsLayout>
</template>

