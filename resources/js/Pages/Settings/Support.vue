<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, Link } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import SorsLayout from '@/Layouts/SorsLayout.vue';
import { useMediaQuery } from '@/composables/useMediaQuery';

const isMobile = useMediaQuery('(max-width: 767px)');
const query = ref('');

type Faq = { id: string; title: string; body: string };

const faqs = ref<Faq[]>([
    {
        id: 'add-transaction',
        title: 'Como adicionar uma transação?',
        body: 'Para adicionar uma transação, toque no botão verde (+) na parte inferior da tela. Preencha os campos e toque em Salvar.',
    },
    { id: 'edit-account', title: 'Como editar uma conta?', body: 'Abra Configurações, toque em uma conta e selecione Editar conta.' },
    { id: 'installments', title: 'Como funciona o parcelamento?', body: 'Ative “Parcelado?”, escolha a quantidade de vezes e o app calcula o valor de cada parcela.' },
]);

const openId = ref<string>('add-transaction');
const toggle = (id: string) => (openId.value = openId.value === id ? '' : id);

const filteredFaqs = computed(() => {
    const q = query.value.trim().toLowerCase();
    if (!q) return faqs.value;
    return faqs.value.filter((f) => f.title.toLowerCase().includes(q) || f.body.toLowerCase().includes(q));
});
</script>

<template>
    <Head title="Ajuda e Suporte" />

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
            <div class="text-xl font-semibold tracking-tight text-slate-900">Ajuda e Suporte</div>
        </header>

        <div class="mt-6">
            <div class="flex h-12 items-center gap-2 rounded-2xl bg-white px-4 shadow-sm ring-1 ring-slate-200/60">
                <svg class="h-5 w-5 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <circle cx="11" cy="11" r="7" />
                    <path d="M20 20l-3.5-3.5" />
                </svg>
                <input
                    v-model="query"
                    type="text"
                    placeholder="Buscar ajuda..."
                    class="w-full bg-transparent text-sm font-semibold text-slate-700 placeholder:text-slate-300 focus:outline-none"
                    aria-label="Buscar ajuda"
                />
            </div>
        </div>

        <div class="mt-7">
            <div class="text-base font-semibold text-slate-900">Perguntas frequentes</div>

            <div class="mt-3 space-y-3">
                <div v-for="faq in filteredFaqs" :key="faq.id" class="overflow-hidden rounded-3xl bg-white shadow-sm ring-1 ring-slate-200/60">
                    <button type="button" class="flex w-full items-center justify-between gap-4 px-5 py-4 text-left" @click="toggle(faq.id)">
                        <div class="text-sm font-semibold text-slate-900">{{ faq.title }}</div>
                        <svg class="h-5 w-5 text-slate-300 transition" :class="openId === faq.id ? 'rotate-180' : ''" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M6 9l6 6 6-6" />
                        </svg>
                    </button>
                    <div v-if="openId === faq.id" class="border-t border-slate-100 px-5 py-4 text-sm font-medium leading-relaxed text-slate-500">
                        {{ faq.body }}
                    </div>
                </div>
            </div>
        </div>

        <div class="mt-8">
            <div class="text-base font-semibold text-slate-900">Tutorial do app</div>
            <div class="mt-3 overflow-hidden rounded-3xl bg-white shadow-sm ring-1 ring-slate-200/60">
                <div class="flex items-center gap-4 px-5 py-4">
                    <span class="flex h-12 w-12 items-center justify-center rounded-2xl bg-emerald-50 text-emerald-600">
                        <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M22 10 12 5 2 10l10 5 10-5Z" />
                            <path d="M6 12v5c0 1.7 2.7 3 6 3s6-1.3 6-3v-5" />
                        </svg>
                    </span>
                    <div class="flex-1">
                        <div class="text-sm font-semibold text-slate-900">Aprenda a usar o app</div>
                        <button type="button" class="mt-1 text-xs font-semibold text-[#14B8A6]">Ver tutorial</button>
                    </div>
                </div>
            </div>
        </div>

        <div class="mt-8 pb-[calc(2rem+env(safe-area-inset-bottom))]">
            <div class="text-base font-semibold text-slate-900">Falar conosco</div>
            <div class="mt-3 grid grid-cols-2 gap-3">
                <button type="button" class="flex h-12 items-center justify-center gap-2 rounded-2xl border border-[#14B8A6] bg-white text-sm font-semibold text-[#14B8A6]">
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M4 6h16v12H4V6Z" />
                        <path d="m4 7 8 6 8-6" />
                    </svg>
                    Enviar email
                </button>
                <button type="button" class="flex h-12 items-center justify-center gap-2 rounded-2xl border border-emerald-200 bg-white text-sm font-semibold text-emerald-600">
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M7 3h10v18H7z" />
                        <path d="M9 7h6" />
                        <path d="M9 11h6" />
                        <path d="M10 19h4" />
                    </svg>
                    WhatsApp
                </button>
            </div>
        </div>
    </MobileShell>

    <SorsLayout v-else title="Ajuda e Suporte" subtitle="Mobile-first por enquanto.">
        <div class="rounded-[28px] border border-white/70 bg-white p-8 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)]">
            <div class="text-sm font-semibold text-slate-900">Ajuda e Suporte (desktop/tablet)</div>
            <div class="mt-2 text-sm text-slate-500">Vamos adaptar essa tela depois da versão mobile.</div>
        </div>
    </SorsLayout>
</template>

