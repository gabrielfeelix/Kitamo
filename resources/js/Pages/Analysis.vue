<script setup lang="ts">
import { computed } from 'vue';
import { usePage } from '@inertiajs/vue3';
import SorsLayout from '@/Layouts/SorsLayout.vue';

const page = usePage();
const userName = computed(() => page.props.auth?.user?.name ?? 'Gabriel');
</script>

<template>
    <SorsLayout title="Análise Financeira" :subtitle="`Bem-vindo de volta, ${userName}.`">
        <div class="space-y-6">
            <div class="flex flex-wrap items-center justify-between gap-4">
                <div class="flex flex-wrap items-center gap-3">
                    <button class="inline-flex items-center gap-2 rounded-2xl border border-slate-100 bg-white px-5 py-3 text-sm font-semibold text-slate-700 shadow-sm" type="button">
                        Este mês
                        <svg class="h-4 w-4 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M6 9l6 6 6-6" />
                        </svg>
                    </button>
                    <button class="inline-flex items-center gap-2 rounded-2xl border border-slate-100 bg-white px-5 py-3 text-sm font-semibold text-slate-700 shadow-sm" type="button">
                        Todas as contas
                        <svg class="h-4 w-4 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M6 9l6 6 6-6" />
                        </svg>
                    </button>
                </div>
                <button class="flex h-11 w-11 items-center justify-center rounded-2xl border border-slate-100 bg-white text-slate-600 shadow-sm" type="button" aria-label="Filtros">
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M4 5h16l-6 7v6l-4 2v-8L4 5Z" />
                    </svg>
                </button>
            </div>

            <div class="grid gap-6 xl:grid-cols-[1.6fr_0.9fr]">
                <div class="space-y-6">
                    <div class="grid gap-6 md:grid-cols-2">
                        <div class="rounded-[28px] border border-white/70 bg-white p-6 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)]">
                            <div class="flex items-start justify-between">
                                <div class="text-xs font-semibold uppercase tracking-wide text-slate-400">Total Entradas</div>
                                <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-emerald-50 text-emerald-600">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M12 21V7" />
                                        <path d="M7 12l5-5 5 5" />
                                    </svg>
                                </span>
                            </div>
                            <div class="mt-5 text-2xl font-semibold text-slate-900">+ R$ 5.250,00</div>
                            <div class="mt-3 inline-flex rounded-xl bg-emerald-50 px-3 py-2 text-xs font-semibold text-emerald-600">+12% vs mês anterior</div>
                        </div>
                        <div class="rounded-[28px] border border-white/70 bg-white p-6 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)]">
                            <div class="flex items-start justify-between">
                                <div class="text-xs font-semibold uppercase tracking-wide text-slate-400">Total Saídas</div>
                                <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-red-50 text-red-500">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M12 3v14" />
                                        <path d="M7 12l5 5 5-5" />
                                    </svg>
                                </span>
                            </div>
                            <div class="mt-5 text-2xl font-semibold text-slate-900">- R$ 1.408,00</div>
                            <div class="mt-2 text-xs font-medium text-slate-400">Dentro do orçamento</div>
                        </div>
                    </div>

                    <div class="rounded-[28px] border border-white/70 bg-white p-6 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)]">
                        <div class="flex h-[320px] items-center justify-center">
                            <div class="text-center">
                                <div class="mx-auto flex h-16 w-16 items-center justify-center rounded-3xl bg-slate-50 text-slate-300">
                                    <svg class="h-10 w-10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M4 19V5" />
                                        <path d="M10 19V9" />
                                        <path d="M16 19V3" />
                                        <path d="M22 19V12" />
                                    </svg>
                                </div>
                                <div class="mt-4 text-sm font-semibold text-slate-400">Gráfico de evolução mensal</div>
                            </div>
                        </div>
                    </div>

                    <div>
                        <div class="px-2 text-xs font-semibold uppercase tracking-wide text-slate-400">Histórico Detalhado</div>
                        <div class="mt-4 rounded-[28px] border border-white/70 bg-white p-4 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)]">
                            <div class="divide-y divide-slate-100">
                                <div class="flex items-center justify-between px-4 py-5">
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
                                <div class="flex items-center justify-between px-4 py-5">
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
                                <div class="flex items-center justify-between px-4 py-5">
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
                                <div class="flex items-center justify-between px-4 py-5">
                                    <div class="flex items-center gap-4">
                                        <span class="flex h-12 w-12 items-center justify-center rounded-2xl bg-slate-50 text-slate-400">
                                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <rect x="5" y="4" width="14" height="16" rx="4" />
                                                <path d="M8 8h8" />
                                            </svg>
                                        </span>
                                        <div>
                                            <div class="flex items-center gap-2 text-sm font-semibold text-slate-500">
                                                Spotify
                                                <span class="rounded-full bg-slate-100 px-2 py-1 text-[10px] font-semibold text-slate-400">PENDENTE</span>
                                            </div>
                                            <div class="text-xs text-slate-400">Assinatura • 04/01</div>
                                        </div>
                                    </div>
                                    <div class="text-sm font-semibold text-slate-500">-21.90</div>
                                </div>
                                <div class="flex items-center justify-between px-4 py-5">
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
                                <div class="flex items-center justify-between px-4 py-5">
                                    <div class="flex items-center gap-4">
                                        <span class="flex h-12 w-12 items-center justify-center rounded-2xl bg-emerald-50 text-emerald-500">
                                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <path d="M12 3v18" />
                                                <path d="M7 7h5a3 3 0 1 1 0 6H7" />
                                            </svg>
                                        </span>
                                        <div>
                                            <div class="text-sm font-semibold text-slate-900">Freela Design</div>
                                            <div class="text-xs text-slate-500">Receita • 02/01</div>
                                        </div>
                                    </div>
                                    <div class="text-sm font-semibold text-emerald-600">+1200.00</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="space-y-6">
                    <div class="rounded-[28px] border border-white/70 bg-white p-6 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)]">
                        <div class="flex items-center gap-2 text-lg font-semibold text-slate-900">
                            <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-50 text-slate-400">
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M12 6v6l4 2" />
                                    <circle cx="12" cy="12" r="9" />
                                </svg>
                            </span>
                            Top Categorias
                        </div>

                        <div class="mt-6 space-y-6">
                            <div class="space-y-2">
                                <div class="flex items-center justify-between text-sm font-semibold text-slate-700">
                                    <span>Alimentação</span>
                                    <span class="text-slate-600">R$ 800</span>
                                </div>
                                <div class="h-3 rounded-full bg-slate-100">
                                    <div class="h-3 w-2/5 rounded-full bg-red-500"></div>
                                </div>
                            </div>

                            <div class="space-y-2">
                                <div class="flex items-center justify-between text-sm font-semibold text-slate-700">
                                    <span>Moradia</span>
                                    <span class="text-slate-600">R$ 600</span>
                                </div>
                                <div class="h-3 rounded-full bg-slate-100">
                                    <div class="h-3 w-[30%] rounded-full bg-blue-600"></div>
                                </div>
                            </div>

                            <div class="space-y-2">
                                <div class="flex items-center justify-between text-sm font-semibold text-slate-700">
                                    <span>Transporte</span>
                                    <span class="text-slate-600">R$ 400</span>
                                </div>
                                <div class="h-3 rounded-full bg-slate-100">
                                    <div class="h-3 w-1/5 rounded-full bg-amber-500"></div>
                                </div>
                            </div>

                            <div class="space-y-2">
                                <div class="flex items-center justify-between text-sm font-semibold text-slate-700">
                                    <span>Lazer</span>
                                    <span class="text-slate-600">R$ 250</span>
                                </div>
                                <div class="h-3 rounded-full bg-slate-100">
                                    <div class="h-3 w-[14%] rounded-full bg-violet-500"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </SorsLayout>
</template>

