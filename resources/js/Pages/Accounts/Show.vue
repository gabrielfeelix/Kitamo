<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, Link } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import SorsLayout from '@/Layouts/SorsLayout.vue';
import MobileToast from '@/Components/MobileToast.vue';
import { useMediaQuery } from '@/composables/useMediaQuery';

const props = defineProps<{
    accountKey: string;
}>();

const isMobile = useMediaQuery('(max-width: 767px)');

const accountName = computed(() => {
    if (props.accountKey === 'inter') return 'Banco Inter';
    if (props.accountKey === 'wallet') return 'Carteira';
    return 'Conta';
});

const balance = computed(() => (props.accountKey === 'inter' ? 1000 : 450));

const formatMoney = (value: number) =>
    new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL',
    }).format(value);

const transactions = computed(() => [
    { id: 't1', day: '25 JAN', title: 'Aluguel', amount: 1200, kind: 'expense' as const },
    { id: 't2', day: '10 JAN', title: 'Salário', amount: 2500, kind: 'income' as const },
]);

const toastOpen = ref(false);
const toastMessage = ref('');
const showToast = (message: string) => {
    toastMessage.value = message;
    toastOpen.value = true;
};
</script>

<template>
    <Head :title="accountName" />

    <MobileShell v-if="isMobile" :show-nav="false">
        <div class="-mx-5 -mt-2 overflow-hidden rounded-b-[36px] bg-[#14B8A6] px-5 pb-10 pt-[calc(1rem+env(safe-area-inset-top))] text-white">
            <div class="flex items-center justify-between">
                <Link
                    :href="route('settings')"
                    class="flex h-10 w-10 items-center justify-center rounded-full bg-white/20 text-white"
                    aria-label="Voltar"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M15 18l-6-6 6-6" />
                    </svg>
                </Link>

                <div class="text-base font-semibold">{{ accountName }}</div>

                <button type="button" class="flex h-10 w-10 items-center justify-center rounded-full bg-white/20" aria-label="Menu">
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M12 5h.01" />
                        <path d="M12 12h.01" />
                        <path d="M12 19h.01" />
                    </svg>
                </button>
            </div>

            <div class="mt-7 flex flex-col items-center">
                <div class="flex h-14 w-14 items-center justify-center rounded-2xl bg-white text-[#14B8A6] shadow-lg shadow-black/10">
                    <svg class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M3 10h18" />
                        <path d="M5 10V8l7-5 7 5v2" />
                        <path d="M6 10v9" />
                        <path d="M18 10v9" />
                    </svg>
                </div>

                <div class="mt-4 text-[11px] font-semibold tracking-wide opacity-80">SALDO ATUAL</div>
                <div class="mt-2 text-3xl font-bold tracking-tight">{{ formatMoney(balance).replace('R$', 'R$') }}</div>
                <div class="mt-2 flex items-center gap-2 text-xs font-semibold opacity-80">
                    <span class="h-2 w-2 rounded-full bg-white/80"></span>
                    Atualizado hoje
                </div>
            </div>
        </div>

        <div class="mt-6">
            <div class="flex items-center justify-between">
                <div class="text-base font-semibold text-slate-900">Transações desta conta</div>
                <Link :href="route('accounts.index')" class="text-xs font-semibold text-[#14B8A6]">Ver todas</Link>
            </div>

            <div class="mt-4 space-y-3">
                <div v-for="t in transactions" :key="t.id" class="flex items-center gap-3 rounded-2xl bg-white px-4 py-4 shadow-sm ring-1 ring-slate-200/60">
                    <div class="flex h-9 w-14 items-center justify-center rounded-xl bg-slate-50 text-[10px] font-bold text-slate-400 ring-1 ring-slate-200/60">
                        {{ t.day }}
                    </div>
                    <div class="flex-1 text-sm font-semibold text-slate-900">{{ t.title }}</div>
                    <div class="text-sm font-semibold" :class="t.kind === 'income' ? 'text-emerald-600' : 'text-red-500'">
                        {{ t.kind === 'income' ? '+' : '-' }}{{ formatMoney(t.amount).replace('R$', 'R$') }}
                    </div>
                </div>
            </div>
        </div>

        <div class="pb-[calc(5rem+env(safe-area-inset-bottom))]"></div>

        <div class="fixed inset-x-0 bottom-0 bg-white px-5 pb-[calc(1rem+env(safe-area-inset-bottom))] pt-3 shadow-[0_-18px_40px_-32px_rgba(15,23,42,0.45)]">
            <div class="mx-auto flex w-full max-w-md gap-3">
                <button
                    type="button"
                    class="h-12 flex-1 rounded-xl border border-[#14B8A6] bg-white text-sm font-semibold text-[#14B8A6]"
                    @click="showToast('Editar conta (em breve)')"
                >
                    Editar conta
                </button>
                <button
                    type="button"
                    class="h-12 flex-1 rounded-xl border border-red-200 bg-white text-sm font-semibold text-red-500"
                    @click="showToast('Excluir conta (em breve)')"
                >
                    Excluir conta
                </button>
            </div>
        </div>

        <MobileToast :show="toastOpen" :message="toastMessage" @dismiss="toastOpen = false" />
    </MobileShell>

    <SorsLayout v-else :title="accountName" subtitle="Mobile-first por enquanto.">
        <div class="rounded-[28px] border border-white/70 bg-white p-8 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)]">
            <div class="text-sm font-semibold text-slate-900">Detalhe de conta (desktop/tablet)</div>
            <div class="mt-2 text-sm text-slate-500">Vamos adaptar essa tela depois da versão mobile.</div>
        </div>
    </SorsLayout>
</template>
