<script setup lang="ts">
import { computed } from 'vue';
import { Link, usePage } from '@inertiajs/vue3';
import SorsLayout from '@/Layouts/SorsLayout.vue';

const page = usePage();
const userName = computed(() => page.props.auth?.user?.name ?? 'Gabriel');
</script>

<template>
    <SorsLayout title="Contas" :subtitle="`Bem-vindo de volta, ${userName}.`">
        <div class="grid gap-6 xl:grid-cols-2">
            <Link
                :href="route('accounts.checking')"
                class="rounded-[28px] border border-white/70 bg-white p-6 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)] transition hover:-translate-y-0.5 hover:shadow-[0_30px_70px_-45px_rgba(15,23,42,0.55)]"
            >
                <div class="flex items-center justify-between">
                    <div class="flex items-center gap-4">
                        <span class="flex h-12 w-12 items-center justify-center rounded-2xl bg-slate-100 text-slate-600">
                            <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M12 2l7 7-7 7-7-7 7-7Z" />
                            </svg>
                        </span>
                        <div>
                            <div class="text-base font-semibold text-slate-900">Nubank C/C</div>
                            <div class="text-sm text-slate-500">Saldo atual</div>
                        </div>
                    </div>
                    <div class="text-base font-semibold text-slate-900">R$ 2345.67</div>
                </div>
            </Link>

            <Link
                :href="route('accounts.card')"
                class="rounded-[28px] border border-white/70 bg-white p-6 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)] transition hover:-translate-y-0.5 hover:shadow-[0_30px_70px_-45px_rgba(15,23,42,0.55)]"
            >
                <div class="flex items-center justify-between">
                    <div class="flex items-center gap-4">
                        <span class="flex h-12 w-12 items-center justify-center rounded-2xl bg-slate-900 text-white">
                            <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="5" width="18" height="14" rx="3" />
                                <path d="M3 10h18" />
                            </svg>
                        </span>
                        <div>
                            <div class="text-base font-semibold text-slate-900">Nubank Cartão</div>
                            <div class="text-sm text-slate-500">Fatura aberta</div>
                        </div>
                    </div>
                    <div class="text-base font-semibold text-slate-900">R$ 1450.00</div>
                </div>
            </Link>
        </div>
    </SorsLayout>
</template>

