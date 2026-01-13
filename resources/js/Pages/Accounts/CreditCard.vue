<script setup lang="ts">
import { computed } from 'vue';
import { Link, usePage } from '@inertiajs/vue3';
import type { BootstrapData, Entry } from '@/types/kitamo';
import MobileShell from '@/Layouts/MobileShell.vue';
import KitamoLayout from '@/Layouts/KitamoLayout.vue';
import { useMediaQuery } from '@/composables/useMediaQuery';

const page = usePage();
const bootstrap = computed(
    () => (page.props.bootstrap ?? { entries: [], goals: [], accounts: [], categories: [] }) as BootstrapData,
);
const userName = computed(() => page.props.auth?.user?.name ?? 'Gabriel');
const isMobile = useMediaQuery('(max-width: 767px)');

const account = computed(() => bootstrap.value.accounts.find((item) => item.type === 'credit_card') ?? null);
const accountName = computed(() => account.value?.name ?? 'Cartão');
const creditLimit = computed(() => account.value?.credit_limit ?? 0);
const currentBalance = computed(() => account.value?.current_balance ?? 0);
const usagePct = computed(() => {
    if (!creditLimit.value) return 0;
    const ratio = currentBalance.value / creditLimit.value;
    return Math.min(100, Math.max(0, Math.round(ratio * 100)));
});
const available = computed(() => (creditLimit.value ? Math.max(0, creditLimit.value - currentBalance.value) : 0));

const entries = computed(() => bootstrap.value.entries ?? []);
const formatDayLabel = (entry: Entry) => {
    const date = entry.transactionDate ? new Date(entry.transactionDate) : new Date();
    const day = String(date.getDate()).padStart(2, '0');
    const month = date
        .toLocaleString('pt-BR', { month: 'short' })
        .replace('.', '')
        .toUpperCase();
    return `${day} ${month}`;
};

const transactions = computed(() =>
    entries.value
        .filter((entry) => entry.accountLabel === accountName.value)
        .map((entry) => ({
            id: entry.id,
            day: formatDayLabel(entry),
            title: entry.title,
            amount: entry.amount,
            kind: entry.kind,
            category: entry.categoryLabel,
        })),
);

const formatMoney = (value: number) =>
    new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL',
    }).format(value);
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
            <div class="text-xl font-semibold tracking-tight text-slate-900">{{ accountName }}</div>
        </header>

        <div class="mt-6 space-y-3">
            <div v-if="account" class="rounded-3xl bg-white p-5 shadow-sm ring-1 ring-slate-200/60">
                <div class="text-[11px] font-semibold uppercase tracking-wide text-slate-400">Fatura atual</div>

                <div class="mt-3 text-2xl font-semibold text-slate-900">{{ formatMoney(currentBalance) }}</div>

                <div class="mt-5">
                    <div class="h-2 w-full overflow-hidden rounded-full bg-slate-200">
                        <div class="h-2 bg-blue-600" :style="{ width: `${usagePct}%` }"></div>
                    </div>
                    <div class="mt-3 flex items-center justify-between text-xs font-medium text-slate-400">
                        <div>Usado: {{ usagePct }}%</div>
                        <div>Disponível: {{ formatMoney(available) }}</div>
                    </div>
                </div>

                <button class="mt-5 w-full rounded-2xl bg-slate-900 py-3 text-sm font-semibold text-white disabled:opacity-60" type="button" :disabled="!currentBalance">Pagar fatura</button>
            </div>
            <div v-else class="rounded-3xl border border-dashed border-slate-200 bg-slate-50 px-5 py-8 text-center">
                <div class="text-sm font-semibold text-slate-900">Nenhum cartão cadastrado</div>
                <div class="mt-1 text-xs text-slate-500">Cadastre um cartão para ver a fatura.</div>
            </div>

            <div class="rounded-3xl bg-white p-5 shadow-sm ring-1 ring-slate-200/60">
                <div class="text-[11px] font-semibold uppercase tracking-wide text-slate-400">Extrato</div>
                <div v-if="transactions.length" class="mt-4 space-y-3">
                    <div v-for="t in transactions" :key="t.id" class="flex items-center justify-between">
                        <div>
                            <div class="text-sm font-semibold text-slate-900">{{ t.title }}</div>
                            <div class="text-xs text-slate-400">{{ t.category }} • {{ t.day }}</div>
                        </div>
                        <div class="text-sm font-semibold" :class="t.kind === 'income' ? 'text-emerald-600' : 'text-slate-900'">
                            {{ t.kind === 'income' ? '+' : '-' }}{{ formatMoney(t.amount).replace('R$', 'R$') }}
                        </div>
                    </div>
                </div>
                <div v-else class="mt-4 rounded-2xl border border-dashed border-slate-200 bg-slate-50 px-4 py-6 text-center">
                    <div class="text-sm font-semibold text-slate-900">Sem lançamentos</div>
                    <div class="mt-1 text-xs text-slate-500">Adicione movimentações para ver o extrato.</div>
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
                <div class="text-2xl font-semibold text-slate-900">{{ accountName }}</div>
            </div>

            <div class="grid gap-6 xl:grid-cols-[420px_1fr]">
                <div v-if="account" class="rounded-[28px] border border-white/70 bg-white p-6 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)]">
                    <div class="text-xs font-semibold uppercase tracking-wide text-slate-400">Fatura atual</div>

                    <div class="mt-4 text-3xl font-semibold text-slate-900">{{ formatMoney(currentBalance) }}</div>

                    <div class="mt-8">
                        <div class="h-2 w-full overflow-hidden rounded-full bg-slate-200">
                            <div class="h-2 bg-blue-600" :style="{ width: `${usagePct}%` }"></div>
                        </div>
                        <div class="mt-3 flex items-center justify-between text-xs font-medium text-slate-400">
                            <div>Usado: {{ usagePct }}%</div>
                            <div>Disponível: {{ formatMoney(available) }}</div>
                        </div>
                    </div>

                    <button class="mt-8 w-full rounded-2xl py-3 text-sm font-semibold text-slate-900 disabled:opacity-60" type="button" :disabled="!currentBalance">
                        Pagar Fatura
                    </button>
                </div>
                <div v-else class="rounded-[28px] border border-dashed border-slate-200 bg-slate-50 p-6 text-center">
                    <div class="text-sm font-semibold text-slate-900">Nenhum cartão cadastrado</div>
                    <div class="mt-1 text-xs text-slate-500">Cadastre um cartão para acompanhar a fatura.</div>
                </div>

                <div>
                    <div class="px-2 text-xs font-semibold uppercase tracking-wide text-slate-400">Extrato de movimentações</div>
                    <div class="mt-4 rounded-[28px] border border-white/70 bg-white p-4 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)]">
                        <div v-if="transactions.length" class="space-y-4">
                            <div v-for="t in transactions" :key="t.id" class="flex items-center justify-between rounded-2xl px-4 py-5 shadow-sm">
                                <div class="flex items-center gap-4">
                                    <span class="flex h-12 w-12 items-center justify-center rounded-2xl" :class="t.kind === 'income' ? 'bg-emerald-50 text-emerald-600' : 'bg-red-50 text-red-500'">
                                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <rect x="5" y="4" width="14" height="16" rx="4" />
                                            <path d="M8 8h8" />
                                        </svg>
                                    </span>
                                    <div>
                                        <div class="text-sm font-semibold text-slate-900">{{ t.title }}</div>
                                        <div class="text-xs text-slate-500">{{ t.category }} • {{ t.day }}</div>
                                    </div>
                                </div>
                                <div class="text-sm font-semibold" :class="t.kind === 'income' ? 'text-emerald-600' : 'text-slate-900'">
                                    {{ t.kind === 'income' ? '+' : '-' }}{{ formatMoney(t.amount).replace('R$', 'R$') }}
                                </div>
                            </div>
                        </div>
                        <div v-else class="rounded-2xl border border-dashed border-slate-200 bg-slate-50 px-6 py-8 text-center">
                            <div class="text-sm font-semibold text-slate-900">Sem lançamentos</div>
                            <div class="mt-1 text-xs text-slate-500">Adicione movimentações para ver o extrato.</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </KitamoLayout>
</template>
