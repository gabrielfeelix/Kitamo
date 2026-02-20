<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';

const sections = [
    { id: 'acesso', label: 'Acesso e licenca' },
    { id: 'responsabilidade', label: 'Responsabilidade de uso' },
    { id: 'assinaturas', label: 'Assinaturas e reembolso' },
    { id: 'encerramento', label: 'Suspensao e encerramento' },
    { id: 'foro', label: 'Foro e legislacao' },
];

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();
</script>

<template>
    <Head title="Termos de Uso | Kitamo">
        <meta name="description" content="Termos de uso da plataforma Kitamo com regras claras de acesso e assinatura." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[980px] px-5 pb-20 pt-10 md:px-6 md:pb-24 md:pt-16">
            <div class="mb-8">
                <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Termos de uso</p>
                <h1 class="mt-4 text-5xl leading-[0.92] tracking-[-0.03em] text-slate-950 md:text-6xl">
                    Termos de uso da plataforma
                </h1>
                <p class="mt-5 max-w-3xl text-lg leading-relaxed text-slate-600 md:text-xl">
                    Regras objetivas para uso do Kitamo, cobrancas, limites de responsabilidade e base legal do contrato.
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
                <article id="acesso" class="rounded-3xl border border-slate-200 bg-white/80 p-6 md:p-8">
                    <h2 class="text-3xl tracking-tight text-slate-950">1. Acesso e licenca</h2>
                    <p class="mt-4 text-base leading-relaxed text-slate-600">
                        O Kitamo concede licenca pessoal, limitada, nao exclusiva e revogavel para uso da plataforma web, respeitando estes termos.
                    </p>
                </article>

                <article id="responsabilidade" class="rounded-3xl border border-slate-200 bg-white/80 p-6 md:p-8">
                    <h2 class="text-3xl tracking-tight text-slate-950">2. Responsabilidade de uso</h2>
                    <p class="mt-4 text-base leading-relaxed text-slate-600">
                        O Kitamo e software de organizacao e projecao financeira, nao consultoria juridica, contabil ou recomendacao de investimento.
                    </p>
                </article>

                <article id="assinaturas" class="rounded-3xl border border-slate-200 bg-white/80 p-6 md:p-8">
                    <h2 class="text-3xl tracking-tight text-slate-950">3. Assinaturas e reembolso</h2>
                    <p class="mt-4 text-base leading-relaxed text-slate-600">
                        Planos pagos seguem ciclo de cobranca informado no ato da assinatura. Em caso de cancelamento, o acesso premium permanece ate o fim do periodo pago.
                    </p>
                    <p class="mt-3 text-base leading-relaxed text-slate-600">
                        Para contratacoes online, aplicamos o prazo legal de arrependimento de 7 dias, conforme CDC.
                    </p>
                </article>

                <article id="encerramento" class="rounded-3xl border border-slate-200 bg-white/80 p-6 md:p-8">
                    <h2 class="text-3xl tracking-tight text-slate-950">4. Suspensao e encerramento</h2>
                    <p class="mt-4 text-base leading-relaxed text-slate-600">
                        Contas podem ser suspensas em caso de fraude, uso abusivo, violacao de seguranca ou descumprimento material destes termos.
                    </p>
                </article>

                <article id="foro" class="rounded-3xl border border-slate-200 bg-white/80 p-6 md:p-8">
                    <h2 class="text-3xl tracking-tight text-slate-950">5. Foro e legislacao</h2>
                    <p class="mt-4 text-base leading-relaxed text-slate-600">
                        Estes termos sao regidos pelas leis brasileiras. Fica eleito o foro da Comarca de Sao Paulo/SP, salvo disposicao legal em contrario.
                    </p>
                    <p class="mt-4 text-base leading-relaxed text-slate-600">
                        Para solicitar versoes anteriores deste documento, acione o suporte oficial.
                    </p>
                    <Link
                        :href="route('site.contact')"
                        class="mt-5 inline-flex h-11 items-center justify-center rounded-full bg-slate-950 px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-white transition hover:bg-emerald-500 hover:text-slate-950"
                    >
                        Solicitar versoes anteriores
                    </Link>
                </article>
            </div>
        </section>
    </SiteLayout>
</template>
