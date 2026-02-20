<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';

const props = defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const modules = [
    {
        id: 'contas',
        title: 'Contas e saldos',
        description:
            'Organize conta corrente, poupanca, carteira e investimentos para consolidar a base de leitura do seu caixa.',
        bullets: ['Historico por conta', 'Consolidado de saldos', 'Base para projecao diaria'],
    },
    {
        id: 'cartoes',
        title: 'Cartoes e ciclo de fatura',
        description:
            'Controle limite, fechamento, vencimento e parcelamentos sem depender de sincronizacao bancaria.',
        bullets: ['Ciclo de fatura', 'Parcelamento em N vezes', 'Impacto no vencimento correto'],
    },
    {
        id: 'metas',
        title: 'Metas financeiras',
        description:
            'Transforme objetivos em rotina acompanhando valor alvo, prazo e ritmo de progresso.',
        bullets: ['Meta por valor e prazo', 'Depositos incrementais', 'Status de evolucao'],
    },
    {
        id: 'projecao',
        title: 'Projecao de caixa',
        description:
            'A visualizacao principal mostra quando o saldo aperta e quanto cada decisao altera o resultado do mes.',
        bullets: ['Linha diaria futura', 'Dias de risco destacados', 'Leitura orientada a acao'],
    },
];

const personas = [
    {
        title: 'Freelancers com receita variavel',
        text: 'Para quem recebe em ciclos irregulares e precisa antecipar os dias de maior pressao de caixa.',
    },
    {
        title: 'Casais organizando financas em conjunto',
        text: 'Para sincronizar compromissos e evitar surpresa com vencimentos ou recorrencias esquecidas.',
    },
    {
        title: 'Quem quer sair do vermelho com previsao',
        text: 'Para tomar decisoes de curto prazo com base em cenarios de saldo projetado.',
    },
    {
        title: 'Quem largou planilhas, mas quer controle',
        text: 'Para manter disciplina com menos atrito e mais clareza operacional no dia a dia.',
    },
];
</script>

<template>
    <Head title="Produto | Kitamo">
        <meta
            name="description"
            content="Tour do produto Kitamo com modulos de contas, cartoes, metas e projecao de caixa para decisao financeira." 
        />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[1320px] px-5 pb-14 pt-10 md:px-6 md:pb-20 md:pt-16">
            <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Produto</p>
            <h1 class="mt-5 max-w-5xl text-5xl leading-[0.9] tracking-[-0.03em] text-slate-950 md:text-7xl">
                Tudo que voce precisa para
                <span class="font-serif italic text-emerald-600">projetar o mes</span>
            </h1>
            <p class="mt-6 max-w-3xl text-lg leading-relaxed text-slate-600 md:text-xl">
                O Kitamo transforma dados financeiros em contexto operacional para voce decidir antes do problema acontecer.
            </p>
        </section>

        <section id="demo" class="mx-auto w-full max-w-[1320px] px-5 pb-16 md:px-6 md:pb-20">
            <div class="stage-shell relative overflow-hidden rounded-[2.5rem] border border-slate-200 bg-slate-950 p-5 md:p-8">
                <div class="absolute -right-16 top-0 h-72 w-72 rounded-full bg-emerald-500/20 blur-3xl"></div>
                <div class="grid items-center gap-8 md:grid-cols-12">
                    <div class="md:col-span-7">
                        <div class="stage-screen flex min-h-[360px] items-center justify-center rounded-[1.75rem] border border-white/10 bg-slate-900 p-8 text-center text-sm text-slate-400 md:min-h-[420px]">
                            Screenshot: visao geral do dashboard
                            <br />
                            <!-- TODO: substituir por screenshot real da tela principal -->
                        </div>
                    </div>
                    <div class="md:col-span-5">
                        <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-emerald-300">Tour visual</p>
                        <h2 class="mt-3 text-4xl leading-[0.95] tracking-tight text-white md:text-5xl">Painel desenhado para acao</h2>
                        <ul class="mt-5 space-y-4 text-sm text-slate-300 md:text-base">
                            <li class="border-b border-white/10 pb-4">Saldo projetado: leitura diaria de risco e folga.</li>
                            <li class="border-b border-white/10 pb-4">Alertas: eventos criticos por data.</li>
                            <li class="pb-1">Ultimas movimentacoes: contexto rapido para decisao.</li>
                        </ul>
                    </div>
                </div>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 pb-14 md:px-6 md:pb-20">
            <div class="grid gap-10 lg:grid-cols-12 lg:gap-14">
                <aside class="lg:col-span-4 lg:sticky lg:top-28 lg:h-fit">
                    <p class="text-xs font-bold uppercase tracking-[0.16em] text-slate-500">Modulos em detalhe</p>
                    <h2 class="mt-3 text-4xl leading-[0.95] tracking-[-0.03em] text-slate-950 md:text-5xl">
                        Estrutura operacional do produto
                    </h2>
                    <p class="mt-4 text-base leading-relaxed text-slate-600 md:text-lg">
                        Cada modulo reduz incerteza em uma camada diferente da rotina financeira.
                    </p>
                </aside>

                <div class="lg:col-span-8">
                    <article
                        v-for="(module, index) in modules"
                        :id="module.id"
                        :key="module.id"
                        class="module-row"
                    >
                        <div class="grid items-start gap-8 md:grid-cols-12">
                            <div class="md:col-span-7">
                                <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">0{{ index + 1 }} / modulo</p>
                                <h3 class="mt-2 text-4xl leading-tight tracking-tight text-slate-950 md:text-5xl">{{ module.title }}</h3>
                                <p class="mt-4 text-base leading-relaxed text-slate-600 md:text-lg">{{ module.description }}</p>
                                <ul class="mt-4 space-y-2">
                                    <li
                                        v-for="bullet in module.bullets"
                                        :key="bullet"
                                        class="flex items-start gap-2 text-sm font-medium text-slate-700 md:text-base"
                                    >
                                        <span class="mt-1 h-2 w-2 rounded-full bg-emerald-500"></span>
                                        <span>{{ bullet }}</span>
                                    </li>
                                </ul>
                            </div>
                            <div class="md:col-span-5">
                                <div class="module-preview flex min-h-[190px] items-center justify-center p-6 text-center text-sm text-slate-500">
                                    Preview do modulo
                                    <br />
                                    <!-- TODO: substituir por screenshot real -->
                                </div>
                            </div>
                        </div>
                    </article>
                </div>
            </div>
        </section>

        <section class="relative overflow-hidden bg-slate-950 py-16 text-white md:py-20">
            <div class="absolute left-16 top-0 h-64 w-64 rounded-full bg-emerald-500/20 blur-3xl"></div>
            <div class="mx-auto w-full max-w-[1320px] px-5 md:px-6">
                <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-emerald-300">Para quem e o Kitamo</p>
                <h2 class="mt-4 max-w-4xl text-4xl leading-[0.95] tracking-[-0.03em] md:text-5xl">Perfis que ganham mais previsibilidade com o produto</h2>
                <div class="mt-8 grid gap-3 md:grid-cols-2">
                    <article
                        v-for="item in personas"
                        :key="item.title"
                        class="border-b border-white/15 pb-5"
                    >
                        <h3 class="text-2xl tracking-tight text-white">{{ item.title }}</h3>
                        <p class="mt-2 text-sm leading-relaxed text-slate-300 md:text-base">{{ item.text }}</p>
                    </article>
                </div>
                <div class="mt-8 flex flex-wrap gap-3">
                    <Link
                        :href="props.canRegister ? '/register' : '/login'"
                        class="inline-flex h-11 items-center justify-center rounded-full bg-white px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-slate-950 transition hover:bg-emerald-300"
                    >
                        Comecar gratis
                    </Link>
                    <Link
                        :href="route('site.contact')"
                        class="inline-flex h-11 items-center justify-center rounded-full border border-white/30 px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-white transition hover:border-white"
                    >
                        Falar com a equipe
                    </Link>
                </div>
            </div>
        </section>
    </SiteLayout>
</template>

<style scoped>
.stage-shell {
    background:
        radial-gradient(24rem 24rem at 8% 0%, rgba(16, 185, 129, 0.15), transparent 70%),
        linear-gradient(180deg, #020617 0%, #020617 100%);
}

.stage-screen {
    background:
        radial-gradient(20rem 20rem at 80% 10%, rgba(16, 185, 129, 0.18), transparent 75%),
        linear-gradient(180deg, rgba(15, 23, 42, 0.96), rgba(15, 23, 42, 0.96));
}

.module-row {
    border-top: 1px solid rgba(148, 163, 184, 0.35);
    padding: 2.4rem 0;
}

.module-row:first-child {
    border-top: 0;
    padding-top: 0;
}

.module-preview {
    border-radius: 1.5rem;
    border: 1px dashed rgba(148, 163, 184, 0.8);
    background:
        radial-gradient(14rem 14rem at 25% 10%, rgba(16, 185, 129, 0.16), transparent 72%),
        linear-gradient(180deg, rgba(255, 255, 255, 0.92), rgba(241, 245, 249, 0.92));
}
</style>
