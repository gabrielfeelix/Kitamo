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
        description: 'Base consolidada de conta corrente, poupanca, carteira e investimentos para leitura clara do caixa.',
        bullets: ['Historico por conta', 'Consolidado mensal', 'Visao por tipo de conta'],
        image: 'https://images.pexels.com/photos/3184291/pexels-photo-3184291.jpeg?auto=compress&cs=tinysrgb&w=1000',
    },
    {
        id: 'cartoes',
        title: 'Cartoes de credito',
        description: 'Fechamento, vencimento e parcelamento entram no fluxo sem depender de sincronizacao bancaria.',
        bullets: ['Controle de limite', 'Parcelamento em N vezes', 'Impacto automatico no vencimento'],
        image: 'https://images.pexels.com/photos/3183197/pexels-photo-3183197.jpeg?auto=compress&cs=tinysrgb&w=1000',
    },
    {
        id: 'metas',
        title: 'Metas financeiras',
        description: 'Objetivos com valor e prazo para acompanhar progresso com ritmo e prioridade.',
        bullets: ['Meta por prazo', 'Depositos incrementais', 'Status de evolucao'],
        image: 'https://images.pexels.com/photos/3760067/pexels-photo-3760067.jpeg?auto=compress&cs=tinysrgb&w=1000',
    },
    {
        id: 'projecao',
        title: 'Projecao de caixa',
        description: 'Linha diaria de saldo futuro para antecipar risco e agir antes da data critica.',
        bullets: ['Visao de 30/90 dias e 5 anos', 'Alerta por data de risco', 'Leitura orientada a acao'],
        image: 'https://images.pexels.com/photos/3182812/pexels-photo-3182812.jpeg?auto=compress&cs=tinysrgb&w=1000',
    },
];

const journey = [
    {
        number: '01',
        title: 'Configurar base financeira',
        description: 'Cadastre contas, cartoes, recorrencias e categorias em uma estrutura unica.',
    },
    {
        number: '02',
        title: 'Ativar rotina de lancamentos',
        description: 'Mantenha entradas e saidas atualizadas com recorrencias e parcelamentos.',
    },
    {
        number: '03',
        title: 'Ler alertas de risco',
        description: 'Visualize os pontos de pressao no saldo antes da data do problema.',
    },
    {
        number: '04',
        title: 'Executar ajuste semanal',
        description: 'Priorize o corte ou redistribuicao de gastos com maior impacto no caixa.',
    },
];

const personas = [
    'Freelancers com receita irregular',
    'Casais organizando financas em conjunto',
    'Quem quer sair do vermelho com visibilidade diaria',
    'Quem saiu da planilha mas ainda quer controle real',
];
</script>

<template>
    <Head title="Produto | Kitamo">
        <meta
            name="description"
            content="Conheca o produto Kitamo: modulos de contas, cartoes, metas e projecao de caixa com foco em decisao financeira." 
        />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[1320px] px-5 pb-14 pt-10 md:px-6 md:pb-20 md:pt-16">
            <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Produto</p>
            <h1 class="mt-5 max-w-5xl text-5xl leading-[0.9] tracking-[-0.03em] text-slate-950 md:text-7xl">
                Uma plataforma para
                <span class="font-serif italic text-emerald-600">projetar o seu mes</span>
            </h1>
            <p class="mt-6 max-w-3xl text-lg leading-relaxed text-slate-600 md:text-xl">
                O Kitamo combina controle manual confiavel com leitura de futuro para voce decidir com antecedencia.
            </p>
        </section>

        <section id="demo" class="mx-auto w-full max-w-[1320px] px-5 pb-14 md:px-6 md:pb-20">
            <div class="product-hero relative overflow-hidden rounded-[2rem] border border-slate-200 p-6 md:p-8">
                <div class="grid items-center gap-8 md:grid-cols-12">
                    <div class="md:col-span-6 text-white">
                        <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-emerald-300">Tour visual</p>
                        <h2 class="mt-3 text-4xl leading-[0.95] tracking-tight md:text-5xl">Visao geral do dashboard</h2>
                        <p class="mt-4 max-w-xl text-base leading-relaxed text-slate-300 md:text-lg">
                            Saldo projetado, alertas por data e ultimas movimentacoes em uma interface de decisao diaria.
                        </p>
                        <div class="mt-7 flex flex-wrap gap-3">
                            <span class="inline-flex rounded-full border border-white/20 bg-white/10 px-4 py-2 text-[11px] font-bold uppercase tracking-[0.14em]">Saldo projetado</span>
                            <span class="inline-flex rounded-full border border-white/20 bg-white/10 px-4 py-2 text-[11px] font-bold uppercase tracking-[0.14em]">Alertas</span>
                            <span class="inline-flex rounded-full border border-white/20 bg-white/10 px-4 py-2 text-[11px] font-bold uppercase tracking-[0.14em]">Acoes semanais</span>
                        </div>
                    </div>
                    <div class="md:col-span-6">
                        <img
                            src="https://images.pexels.com/photos/834863/pexels-photo-834863.jpeg?auto=compress&cs=tinysrgb&w=1200"
                            alt="Pessoa utilizando smartphone"
                            class="h-[360px] w-full rounded-[1.4rem] object-cover md:h-[420px]"
                            loading="lazy"
                        />
                    </div>
                </div>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 pb-14 md:px-6 md:pb-20">
            <div class="grid gap-10 lg:grid-cols-12">
                <aside class="lg:col-span-4 lg:sticky lg:top-28 lg:h-fit">
                    <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Modulos em detalhe</p>
                    <h2 class="mt-3 text-4xl leading-[0.95] tracking-tight text-slate-950 md:text-5xl">Tudo integrado em uma rotina</h2>
                    <p class="mt-4 text-base leading-relaxed text-slate-600 md:text-lg">
                        Cada modulo elimina uma parte da incerteza e fortalece a projecao do fluxo.
                    </p>
                </aside>

                <div class="lg:col-span-8">
                    <article
                        v-for="(module, index) in modules"
                        :id="module.id"
                        :key="module.id"
                        class="border-t border-slate-200 py-8 first:border-t-0 first:pt-0"
                    >
                        <div class="grid items-start gap-6 md:grid-cols-12">
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
                                <img
                                    :src="module.image"
                                    :alt="module.title"
                                    class="h-52 w-full rounded-[1.2rem] object-cover md:h-60"
                                    loading="lazy"
                                />
                            </div>
                        </div>
                    </article>
                </div>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 pb-14 md:px-6 md:pb-20">
            <div class="grid gap-8 rounded-[2rem] border border-slate-200 bg-white p-6 md:grid-cols-12 md:p-8">
                <div class="md:col-span-6">
                    <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Jornada de uso</p>
                    <h2 class="mt-3 text-4xl leading-[0.95] tracking-tight text-slate-950 md:text-5xl">Conectar, organizar e agir</h2>
                    <ol class="journey mt-7 space-y-6 pl-10">
                        <li v-for="step in journey" :key="step.number" class="relative">
                            <span class="absolute -left-10 top-0 inline-flex h-8 w-8 items-center justify-center rounded-full bg-emerald-500 text-xs font-bold text-white shadow-[0_0_0_6px_rgba(16,185,129,0.14)]">
                                {{ step.number }}
                            </span>
                            <h3 class="text-2xl leading-tight tracking-tight text-slate-950">{{ step.title }}</h3>
                            <p class="mt-2 text-sm leading-relaxed text-slate-600 md:text-base">{{ step.description }}</p>
                        </li>
                    </ol>
                </div>
                <div class="md:col-span-6">
                    <img
                        src="https://images.pexels.com/photos/1181519/pexels-photo-1181519.jpeg?auto=compress&cs=tinysrgb&w=1200"
                        alt="Pessoa acompanhando dados em smartphone"
                        class="h-[420px] w-full rounded-[1.3rem] object-cover"
                        loading="lazy"
                    />
                </div>
            </div>
        </section>

        <section class="relative overflow-hidden bg-slate-950 py-16 text-white md:py-20">
            <div class="absolute left-10 top-0 h-72 w-72 rounded-full bg-emerald-500/20 blur-3xl"></div>
            <div class="mx-auto w-full max-w-[1320px] px-5 md:px-6">
                <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-emerald-300">Para quem e o Kitamo</p>
                <h2 class="mt-3 max-w-4xl text-4xl leading-[0.95] tracking-tight md:text-5xl">Perfis que mais aproveitam a projecao</h2>
                <div class="mt-7 grid gap-3 md:grid-cols-2">
                    <p
                        v-for="item in personas"
                        :key="item"
                        class="border-b border-white/15 pb-4 text-base text-slate-200 md:text-lg"
                    >
                        {{ item }}
                    </p>
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
.product-hero {
    background:
        radial-gradient(30rem 24rem at 6% 0%, rgba(16, 185, 129, 0.18), transparent 70%),
        linear-gradient(140deg, #030712 0%, #0f172a 55%, #111827 100%);
}

.journey {
    position: relative;
}

.journey::before {
    content: '';
    position: absolute;
    left: 15px;
    top: 0;
    bottom: 0;
    width: 2px;
    background: linear-gradient(180deg, rgba(16, 185, 129, 0.08), rgba(16, 185, 129, 0.5), rgba(16, 185, 129, 0.08));
}
</style>
