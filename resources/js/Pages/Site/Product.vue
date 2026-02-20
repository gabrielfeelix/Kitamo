<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';

const props = defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const modules = [
    {
        title: 'Contas e saldos',
        summary: 'Base financeira organizada por conta para leitura real do fluxo.',
        bullets: [
            'Cadastro de conta corrente, poupanca, carteira e investimentos',
            'Historico por conta para revisar origem e destino do dinheiro',
            'Saldo consolidado para apoiar decisao diaria',
        ],
    },
    {
        title: 'Cartoes de credito',
        summary: 'Ciclo de fatura e parcelamentos conectados ao planejamento.',
        bullets: [
            'Controle de limite, fechamento e vencimento',
            'Parcelamento automatico em N vezes com rastreio individual',
            'Impacto da fatura refletido na data correta da projecao',
        ],
    },
    {
        title: 'Metas financeiras',
        summary: 'Objetivos com ritmo visual para manter consistencia.',
        bullets: [
            'Definicao de valor alvo e prazo',
            'Acompanhamento de progresso com status claro',
            'Depositos incrementais registrados com historico',
        ],
    },
    {
        title: 'Projecao de caixa',
        summary: 'Visibilidade de risco futuro para agir antes do problema.',
        bullets: [
            'Linha diaria com saldo projetado para frente',
            'Considera receitas, despesas, recorrencias e parcelas',
            'Alertas de pressao de caixa por data critica',
        ],
    },
];

const personas = [
    'Freelancers que recebem de forma irregular',
    'Casais organizando financas em conjunto',
    'Quem quer sair do vermelho com visibilidade diaria',
    'Pessoas que abandonaram planilhas mas querem controle',
];
</script>

<template>
    <Head title="Produto | Kitamo">
        <meta
            name="description"
            content="Conheca os modulos do Kitamo para projecao de caixa, contas, cartoes e metas financeiras."
        />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[1240px] px-5 pb-16 pt-10 text-center md:px-6 md:pb-20 md:pt-16">
            <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Produto</p>
            <h1 class="mx-auto mt-5 max-w-4xl text-5xl leading-[0.92] tracking-[-0.03em] text-slate-950 md:text-6xl">
                Tudo que voce precisa para projetar seu mes
            </h1>
            <p class="mx-auto mt-6 max-w-3xl text-lg leading-relaxed text-slate-600 md:text-xl">
                O Kitamo combina controle manual confiavel com uma leitura diaria de futuro para voce tomar decisoes com antecedencia.
            </p>
        </section>

        <section id="demo" class="mx-auto w-full max-w-[1240px] px-5 py-6 md:px-6 md:py-10">
            <div class="rounded-3xl border border-slate-200 bg-slate-950 p-6 text-white md:p-10">
                <h2 class="text-3xl tracking-tight md:text-4xl">Tour visual do dashboard</h2>
                <div class="mt-6 rounded-2xl border border-dashed border-slate-600 bg-slate-900 p-10 text-center text-sm text-slate-400">
                    Screenshot: visao geral do dashboard
                    <br />
                    <!-- TODO: substituir por captura real da visao geral -->
                </div>
                <div class="mt-6 grid gap-3 text-sm md:grid-cols-3">
                    <div class="rounded-2xl border border-white/10 bg-white/5 p-4">Saldo projetado: visao diaria do mes</div>
                    <div class="rounded-2xl border border-white/10 bg-white/5 p-4">Alertas: datas com pressao de caixa</div>
                    <div class="rounded-2xl border border-white/10 bg-white/5 p-4">Ultimas movimentacoes: contexto rapido</div>
                </div>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1240px] px-5 py-12 md:px-6 md:py-16">
            <div class="mb-10">
                <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Modulos em detalhe</p>
                <h2 class="mt-3 text-3xl leading-[1.02] tracking-[-0.03em] text-slate-950 md:text-4xl">Recursos pensados para rotina de decisao</h2>
            </div>

            <div class="space-y-6 md:space-y-8">
                <article
                    v-for="(module, index) in modules"
                    :key="module.title"
                    class="grid items-stretch gap-4 rounded-3xl border border-slate-200 bg-white/80 p-6 md:grid-cols-12 md:p-8"
                >
                    <div class="md:col-span-6" :class="index % 2 === 1 ? 'md:order-2' : ''">
                        <h3 class="text-3xl tracking-tight text-slate-950">{{ module.title }}</h3>
                        <p class="mt-3 text-base leading-relaxed text-slate-600">{{ module.summary }}</p>
                        <ul class="mt-5 space-y-2">
                            <li
                                v-for="bullet in module.bullets"
                                :key="bullet"
                                class="flex items-start gap-2 text-sm font-medium text-slate-700"
                            >
                                <span class="mt-1 h-2 w-2 rounded-full bg-emerald-500"></span>
                                <span>{{ bullet }}</span>
                            </li>
                        </ul>
                    </div>
                    <div class="md:col-span-6" :class="index % 2 === 1 ? 'md:order-1' : ''">
                        <div class="flex h-full min-h-48 items-center justify-center rounded-2xl border border-dashed border-slate-300 bg-slate-50 p-6 text-center text-sm text-slate-500">
                            Screenshot do modulo
                            <br />
                            <!-- TODO: substituir por screenshot real do modulo -->
                        </div>
                    </div>
                </article>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1240px] px-5 pb-20 pt-8 md:px-6 md:pb-24 md:pt-10">
            <div class="rounded-3xl border border-slate-200 bg-white p-8 md:p-10">
                <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Para quem e o Kitamo</p>
                <h2 class="mt-3 text-3xl leading-[1.02] tracking-[-0.03em] text-slate-950 md:text-4xl">Perfis que extraem mais valor da projecao</h2>
                <div class="mt-6 grid gap-3 md:grid-cols-2">
                    <article
                        v-for="persona in personas"
                        :key="persona"
                        class="rounded-2xl border border-slate-200 bg-slate-50 p-5 text-sm font-medium text-slate-700"
                    >
                        {{ persona }}
                    </article>
                </div>
                <div class="mt-8 flex flex-wrap gap-3">
                    <Link
                        :href="props.canRegister ? '/register' : '/login'"
                        class="inline-flex h-11 items-center justify-center rounded-full bg-slate-950 px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-white transition hover:bg-emerald-500 hover:text-slate-950"
                    >
                        Comecar gratis
                    </Link>
                    <Link
                        :href="route('site.contact')"
                        class="inline-flex h-11 items-center justify-center rounded-full border border-slate-300 px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-slate-700 transition hover:border-slate-950"
                    >
                        Falar com a equipe
                    </Link>
                </div>
            </div>
        </section>
    </SiteLayout>
</template>
