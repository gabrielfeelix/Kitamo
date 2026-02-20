<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const features = [
    {
        id: 'projecao',
        title: 'Projecao de caixa',
        badge: 'Feature principal',
        description:
            'A projecao organiza saldo atual, receitas futuras, despesas, recorrencias e parcelas em uma linha temporal de decisao. Em vez de reagir ao extrato, voce age antes do risco.',
        bullets: ['Leitura diaria de saldo futuro', 'Alerta de data critica', 'Impacto de cada decisao no fluxo'],
    },
    {
        id: 'contas',
        title: 'Gestao de contas',
        description:
            'Base unica para conta corrente, poupanca, carteira e investimentos com historico organizado por periodo.',
        bullets: ['Estrutura por tipo de conta', 'Historico mensal por conta', 'Consolidado de saldo para visao rapida'],
    },
    {
        id: 'cartoes',
        title: 'Cartoes de credito',
        description:
            'Ciclo de fatura, limite e vencimento entram no planejamento sem friccao, evitando surpresa no fechamento.',
        bullets: ['Controle de fechamento e vencimento', 'Limite e utilizacao em tempo real', 'Fatura refletida na projecao'],
    },
    {
        id: 'parcelamentos',
        title: 'Parcelamentos',
        description:
            'Cada compra parcelada e rastreada item a item para mostrar quanto ainda pesa nos proximos meses.',
        bullets: ['Divisao automatica em N parcelas', 'Rastreio individual de parcelas', 'Aparicao no mes correspondente'],
    },
    {
        id: 'recorrentes',
        title: 'Despesas recorrentes',
        description:
            'Mensal, quinzenal, semanal ou anual: recorrencias entram no fluxo para reduzir retrabalho e esquecimento.',
        bullets: ['Frequencias flexiveis', 'Projecao automatica futura', 'Lembretes de revisao'],
    },
    {
        id: 'metas',
        title: 'Metas financeiras',
        description:
            'Objetivos com valor e prazo para transformar intencao em ritmo de execucao.',
        bullets: ['Status de progresso', 'Depositos incrementais', 'Leitura no ritmo / adiantado / atrasado'],
    },
    {
        id: 'relatorios',
        title: 'Analise e relatorios',
        description:
            'Visualizacao por categoria e comparacao entre periodos com exportacao para rotina de prestacao de contas.',
        bullets: ['Categorias de gasto', 'Comparacao entre meses', 'Exportacao Excel e PDF'],
    },
    {
        id: 'dashboard',
        title: 'Dashboard personalizavel',
        description:
            'Widgets configuraveis para priorizar o que e relevante no seu momento financeiro.',
        bullets: ['Escolha de widgets', 'Seis modulos disponiveis', 'Painel adaptado por prioridade'],
    },
    {
        id: 'notificacoes',
        title: 'Notificacoes inteligentes',
        description:
            'Alertas de saldo baixo, vencimento e resumo semanal para manter consistencia sem excesso de ruído.',
        bullets: ['Saldo baixo', 'Vencimentos criticos', 'Resumo semanal'],
    },
];

const faq = [
    {
        question: 'O Kitamo conecta no meu banco?',
        answer: 'Nao. O Kitamo nao usa Open Finance. O cadastro e manual para manter controle e previsibilidade.',
    },
    {
        question: 'Preciso lancar tudo manualmente?',
        answer: 'Sim, com atalhos como recorrencias e parcelamentos para reduzir tarefas repetitivas.',
    },
    {
        question: 'A projecao considera parcelas futuras?',
        answer: 'Sim. Cada parcela e posicionada no periodo correspondente e impacta a projecao.',
    },
    {
        question: 'Posso usar com mais de uma conta e cartao?',
        answer: 'Sim. Os limites variam por plano e podem ser ampliados com upgrade.',
    },
    {
        question: 'Existe exportacao para relatorios?',
        answer: 'Sim. A plataforma permite exportar dados em Excel e PDF.',
    },
];

const featureVisuals = [
    'https://images.pexels.com/photos/3184291/pexels-photo-3184291.jpeg?auto=compress&cs=tinysrgb&w=1000',
    'https://images.pexels.com/photos/3183197/pexels-photo-3183197.jpeg?auto=compress&cs=tinysrgb&w=1000',
    'https://images.pexels.com/photos/3760067/pexels-photo-3760067.jpeg?auto=compress&cs=tinysrgb&w=1000',
    'https://images.pexels.com/photos/572056/pexels-photo-572056.jpeg?auto=compress&cs=tinysrgb&w=1000',
    'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=1000',
];
</script>

<template>
    <Head title="Funcionalidades | Kitamo">
        <meta
            name="description"
            content="Funcionalidades do Kitamo em profundidade: projecao de caixa, cartoes, recorrencias, metas e notificacoes inteligentes."
        />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[1320px] px-5 pb-14 pt-10 md:px-6 md:pb-16 md:pt-16">
            <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Funcionalidades</p>
            <h1 class="mt-5 max-w-5xl text-5xl leading-[0.9] tracking-[-0.03em] text-slate-950 md:text-7xl">
                Clareza operacional para responder:
                <span class="font-serif italic text-emerald-600">vai fechar no verde?</span>
            </h1>
            <p class="mt-6 max-w-3xl text-lg leading-relaxed text-slate-600 md:text-xl">
                Cada modulo resolve uma parte da rotina financeira e converge para uma decisao unica: manter o caixa sustentavel nos proximos dias.
            </p>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 pb-16 md:px-6 md:pb-20">
            <div class="grid gap-10 lg:grid-cols-12 lg:gap-14">
                <aside class="lg:col-span-4 lg:sticky lg:top-28 lg:h-fit">
                    <p class="text-xs font-bold uppercase tracking-[0.16em] text-slate-500">Mapa de modulos</p>
                    <ul class="mt-4 space-y-2 border-l border-slate-300 pl-4">
                        <li v-for="(item, index) in features" :key="item.id">
                            <a
                                :href="`#${item.id}`"
                                class="group inline-flex items-center gap-2 text-sm font-semibold text-slate-600 transition hover:text-slate-900"
                            >
                                <span class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400 group-hover:text-emerald-700">
                                    0{{ index + 1 }}
                                </span>
                                <span>{{ item.title }}</span>
                            </a>
                        </li>
                    </ul>
                </aside>

                <div class="lg:col-span-8">
                    <article
                        v-for="(item, index) in features"
                        :id="item.id"
                        :key="item.id"
                        class="feature-row"
                    >
                        <div class="grid items-start gap-8 md:grid-cols-12">
                            <div class="md:col-span-7">
                                <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">
                                    0{{ index + 1 }} / modulo
                                </p>
                                <div class="mt-3 flex flex-wrap items-center gap-2">
                                    <h2 class="text-4xl leading-tight tracking-tight text-slate-950 md:text-5xl">{{ item.title }}</h2>
                                    <span
                                        v-if="item.badge"
                                        class="inline-flex rounded-full border border-emerald-300 bg-emerald-50 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.12em] text-emerald-700"
                                    >
                                        {{ item.badge }}
                                    </span>
                                </div>
                                <p class="mt-4 text-base leading-relaxed text-slate-600 md:text-lg">{{ item.description }}</p>
                                <ul class="mt-5 space-y-2">
                                    <li
                                        v-for="point in item.bullets"
                                        :key="point"
                                        class="flex items-start gap-2 text-sm font-medium leading-relaxed text-slate-700 md:text-base"
                                    >
                                        <span class="mt-1 h-2 w-2 rounded-full bg-emerald-500"></span>
                                        <span>{{ point }}</span>
                                    </li>
                                </ul>
                            </div>
                            <div class="md:col-span-5">
                                <img
                                    :src="featureVisuals[index % featureVisuals.length]"
                                    :alt="item.title"
                                    class="h-[220px] w-full rounded-[1.4rem] object-cover"
                                    loading="lazy"
                                />
                            </div>
                        </div>
                    </article>
                </div>
            </div>
        </section>

        <section class="relative overflow-hidden bg-slate-950 py-16 text-white md:py-20">
            <div class="absolute left-1/2 top-0 h-72 w-72 -translate-x-1/2 rounded-full bg-emerald-500/20 blur-3xl"></div>
            <div class="mx-auto grid w-full max-w-[1320px] gap-8 px-5 md:grid-cols-12 md:px-6">
                <div class="md:col-span-4">
                    <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-emerald-300">FAQ</p>
                    <h2 class="mt-4 text-4xl leading-[0.95] tracking-[-0.03em]">Perguntas objetivas</h2>
                    <p class="mt-4 text-base leading-relaxed text-slate-300">
                        Sem resposta vaga: o que o produto faz, o que nao faz e como funciona na pratica.
                    </p>
                </div>
                <div class="md:col-span-8">
                    <details
                        v-for="item in faq"
                        :key="item.question"
                        class="border-b border-white/15 py-4"
                    >
                        <summary class="cursor-pointer list-none text-lg font-semibold tracking-tight">{{ item.question }}</summary>
                        <p class="mt-3 max-w-3xl text-sm leading-relaxed text-slate-300 md:text-base">{{ item.answer }}</p>
                    </details>
                    <div class="mt-7 flex flex-wrap gap-3">
                        <Link
                            :href="route('site.pricing')"
                            class="inline-flex h-11 items-center justify-center rounded-full bg-white px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-slate-950 transition hover:bg-emerald-300"
                        >
                            Ver planos
                        </Link>
                        <Link
                            :href="route('site.contact')"
                            class="inline-flex h-11 items-center justify-center rounded-full border border-white/30 px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-white transition hover:border-white"
                        >
                            Tirar duvidas
                        </Link>
                    </div>
                </div>
            </div>
        </section>
    </SiteLayout>
</template>

<style scoped>
.feature-row {
    border-top: 1px solid rgba(148, 163, 184, 0.35);
    padding: 2.5rem 0;
}

.feature-row:first-child {
    padding-top: 0;
    border-top: 0;
}

</style>
