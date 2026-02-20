<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';

const sections = [
    { id: 'coleta', label: 'Coleta e uso de dados' },
    { id: 'protecao', label: 'Protecao de dados' },
    { id: 'compartilhamento', label: 'Compartilhamento' },
    { id: 'direitos', label: 'Direitos LGPD' },
    { id: 'contato', label: 'Contato DPO' },
];

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();
</script>

<template>
    <Head title="Privacidade | Kitamo">
        <meta name="description" content="Politica de privacidade da Kitamo com linguagem clara e compromisso com LGPD." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[980px] px-5 pb-20 pt-10 md:px-6 md:pb-24 md:pt-16">
            <div class="mb-8">
                <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Privacidade</p>
                <h1 class="mt-4 text-5xl leading-[0.92] tracking-[-0.03em] text-slate-950 md:text-6xl">
                    Politica de privacidade
                </h1>
                <p class="mt-5 max-w-3xl text-lg leading-relaxed text-slate-600 md:text-xl">
                    Este documento explica como tratamos seus dados de forma transparente, segura e em conformidade com a LGPD.
                </p>
                <div class="mt-6 flex flex-wrap items-center gap-3 text-xs font-semibold uppercase tracking-[0.12em] text-slate-500">
                    <span>Ultima atualizacao: 20 de fevereiro de 2026</span>
                    <span>Versao 1.1</span>
                </div>
            </div>

            <div class="mb-6 rounded-3xl border border-slate-200 bg-white/80 p-5 md:p-6">
                <div class="flex flex-wrap items-center justify-between gap-4">
                    <p class="text-xs font-bold uppercase tracking-[0.14em] text-slate-500">Indice</p>
                    <button
                        type="button"
                        class="inline-flex h-10 items-center justify-center rounded-full border border-slate-300 px-5 text-[11px] font-bold uppercase tracking-[0.14em] text-slate-700 transition hover:border-slate-950"
                    >
                        Baixar PDF
                    </button>
                    <!-- TODO: vincular botao a versao PDF oficial -->
                </div>
                <div class="mt-4 grid gap-2 md:grid-cols-2">
                    <a
                        v-for="item in sections"
                        :key="item.id"
                        :href="`#${item.id}`"
                        class="rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm font-medium text-slate-700 transition hover:border-emerald-300 hover:text-slate-900"
                    >
                        {{ item.label }}
                    </a>
                </div>
            </div>

            <div class="space-y-4">
                <article id="coleta" class="rounded-3xl border border-slate-200 bg-white/80 p-6 md:p-8">
                    <h2 class="text-3xl tracking-tight text-slate-950">1. Coleta e uso de dados</h2>
                    <p class="mt-4 text-base leading-relaxed text-slate-600">
                        Coletamos apenas os dados necessarios para funcionamento da plataforma, suporte e seguranca. O Kitamo nao vende dados pessoais.
                    </p>
                </article>

                <article id="protecao" class="rounded-3xl border border-slate-200 bg-white/80 p-6 md:p-8">
                    <h2 class="text-3xl tracking-tight text-slate-950">2. Protecao de dados</h2>
                    <p class="mt-4 text-base leading-relaxed text-slate-600">
                        O Kitamo nao se conecta a contas bancarias. As informacoes cadastradas manualmente sao protegidas em transito e em repouso com controles tecnicos apropriados.
                    </p>
                </article>

                <article id="compartilhamento" class="rounded-3xl border border-slate-200 bg-white/80 p-6 md:p-8">
                    <h2 class="text-3xl tracking-tight text-slate-950">3. Compartilhamento</h2>
                    <p class="mt-4 text-base leading-relaxed text-slate-600">
                        O compartilhamento ocorre apenas com operadores essenciais de infraestrutura e seguranca, sempre sob obrigacao contratual de confidencialidade.
                    </p>
                </article>

                <article id="direitos" class="rounded-3xl border border-slate-200 bg-white/80 p-6 md:p-8">
                    <h2 class="text-3xl tracking-tight text-slate-950">4. Seus direitos (LGPD)</h2>
                    <p class="mt-4 text-base leading-relaxed text-slate-600">
                        Voce pode solicitar confirmacao de tratamento, acesso, correcao, portabilidade, anonimização e exclusao de dados conforme Art. 18 da LGPD.
                    </p>
                </article>

                <article id="contato" class="rounded-3xl border border-slate-200 bg-white/80 p-6 md:p-8">
                    <h2 class="text-3xl tracking-tight text-slate-950">5. Contato com DPO</h2>
                    <p class="mt-4 text-base leading-relaxed text-slate-600">
                        Para exercicio de direitos e duvidas regulatórias, utilize nosso canal oficial de contato.
                    </p>
                    <Link
                        :href="route('site.contact')"
                        class="mt-5 inline-flex h-11 items-center justify-center rounded-full bg-slate-950 px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-white transition hover:bg-emerald-500 hover:text-slate-950"
                    >
                        Ir para contato
                    </Link>
                </article>
            </div>
        </section>
    </SiteLayout>
</template>
