<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const timeline = [
    {
        year: '2024',
        text: 'Nascimento do conceito Kitamo com foco em projecao de caixa para pessoa fisica.',
    },
    {
        year: '2025',
        text: 'Primeira versao operacional com contas, cartoes, recorrencias e metas.',
    },
    {
        year: '2026',
        text: 'Evolucao para projecao de longo prazo com estrutura por planos e jornada institucional.',
    },
    {
        year: 'Proximo ciclo',
        text: 'Expansao de inteligencia de alertas, relatorios e experiencia visual orientada a decisao.',
    },
];

const team = [
    {
        image: 'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=700',
        name: '[Nome do Fundador]',
        role: 'Fundador & CEO',
    },
    {
        image: 'https://images.pexels.com/photos/3727462/pexels-photo-3727462.jpeg?auto=compress&cs=tinysrgb&w=700',
        name: '[Nome da Lideranca Tecnica]',
        role: 'CTO',
    },
    {
        image: 'https://images.pexels.com/photos/3760067/pexels-photo-3760067.jpeg?auto=compress&cs=tinysrgb&w=700',
        name: '[Nome de Produto]',
        role: 'Product Lead',
    },
    {
        image: 'https://images.pexels.com/photos/3184465/pexels-photo-3184465.jpeg?auto=compress&cs=tinysrgb&w=700',
        name: '[Nome de Operacoes]',
        role: 'Operations Lead',
    },
    {
        image: 'https://images.pexels.com/photos/3184433/pexels-photo-3184433.jpeg?auto=compress&cs=tinysrgb&w=700',
        name: '[Nome de Growth]',
        role: 'Growth Lead',
    },
];

const stats = [
    { label: '+3.5', value: 'anos no mercado' },
    { label: '+50 mil', value: 'projecoes realizadas' },
    { label: '+500', value: 'rotinas mensais apoiadas' },
    { label: '+200 mil', value: 'alertas processados em 2026' },
];

const values = [
    {
        title: 'Clareza acima de volume',
        description: 'Menos ruído de dashboard e mais contexto para decidir na hora certa.',
    },
    {
        title: 'Controle manual confiavel',
        description: 'Voce domina os dados e constroi previsao com base no que realmente acontece.',
    },
    {
        title: 'Privacidade por padrao',
        description: 'Receita de assinatura. Nao vendemos comportamento e nao dependemos de publicidade.',
    },
];
</script>

<template>
    <Head title="Empresa | Kitamo">
        <meta
            name="description"
            content="Conheca a historia, a equipe e os valores do Kitamo, produto brasileiro de projecao financeira pessoal."
        />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[1320px] px-5 pb-14 pt-10 md:px-6 md:pb-20 md:pt-16">
            <div class="grid items-center gap-8 md:grid-cols-12">
                <div class="md:col-span-7">
                    <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Empresa</p>
                    <h1 class="mt-4 text-6xl leading-[0.88] tracking-[-0.04em] text-slate-950 md:text-7xl">Sobre o Kitamo</h1>
                    <p class="mt-5 max-w-2xl text-lg leading-relaxed text-slate-600 md:text-xl">
                        Construimos um produto brasileiro para quem precisa previsibilidade financeira sem depender de adivinhacao no fim do mes.
                    </p>
                </div>
                <div class="md:col-span-5">
                    <div class="overflow-hidden rounded-[1.8rem] border border-slate-200 bg-white">
                        <img
                            src="https://images.pexels.com/photos/3182812/pexels-photo-3182812.jpeg?auto=compress&cs=tinysrgb&w=1200"
                            alt="Equipe em reuniao de planejamento"
                            class="h-[320px] w-full object-cover"
                            loading="lazy"
                        />
                    </div>
                </div>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 pb-14 md:px-6 md:pb-20">
            <div class="grid gap-8 rounded-[2rem] border border-slate-200 bg-white p-6 md:grid-cols-12 md:p-8">
                <div class="md:col-span-7">
                    <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Linha do tempo</p>
                    <h2 class="mt-3 text-4xl leading-[0.95] tracking-tight text-slate-950 md:text-5xl">Evolucao do produto</h2>

                    <ol class="company-timeline mt-7 space-y-6 pl-8">
                        <li
                            v-for="item in timeline"
                            :key="item.year"
                            class="relative"
                        >
                            <span class="absolute -left-8 top-1 h-3 w-3 rounded-full bg-emerald-500"></span>
                            <p class="text-sm font-bold uppercase tracking-[0.14em] text-emerald-700">{{ item.year }}</p>
                            <p class="mt-1 text-sm leading-relaxed text-slate-600 md:text-base">{{ item.text }}</p>
                        </li>
                    </ol>
                </div>

                <div class="md:col-span-5">
                    <img
                        src="https://images.pexels.com/photos/3183197/pexels-photo-3183197.jpeg?auto=compress&cs=tinysrgb&w=1100"
                        alt="Pessoa apresentando resultado para equipe"
                        class="h-[360px] w-full rounded-[1.4rem] object-cover"
                        loading="lazy"
                    />
                </div>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 pb-14 md:px-6 md:pb-20">
            <div class="rounded-[2rem] border border-slate-200 bg-white p-6 md:p-8">
                <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Quem somos</p>
                <p class="mt-3 max-w-3xl text-base leading-relaxed text-slate-600 md:text-lg">
                    Equipe especializada em produto, dados e experiencia financeira. Nosso foco e conectar clareza de leitura com acao pratica no cotidiano.
                </p>

                <div class="mt-7 grid gap-3 grid-cols-2 md:grid-cols-5">
                    <article
                        v-for="member in team"
                        :key="member.role"
                    >
                        <img
                            :src="member.image"
                            :alt="member.name"
                            class="h-52 w-full rounded-[1.2rem] object-cover"
                            loading="lazy"
                        />
                        <p class="mt-2 text-sm font-semibold text-slate-900">{{ member.name }}</p>
                        <p class="text-xs uppercase tracking-[0.12em] text-slate-500">{{ member.role }}</p>
                    </article>
                </div>
                <!-- TODO: substituir por fotos e nomes reais -->

                <div class="mt-7 grid gap-3 md:grid-cols-4">
                    <article
                        v-for="item in stats"
                        :key="item.label"
                        class="rounded-2xl border border-slate-200 px-4 py-4"
                    >
                        <p class="text-3xl font-semibold tracking-tight text-slate-950">{{ item.label }}</p>
                        <p class="mt-1 text-xs uppercase tracking-[0.12em] text-slate-500">{{ item.value }}</p>
                    </article>
                </div>
                <!-- TODO: substituir indicadores por numeros oficiais -->
            </div>
        </section>

        <section class="relative overflow-hidden bg-slate-950 py-16 text-white md:py-20">
            <div class="absolute -right-10 top-0 h-72 w-72 rounded-full bg-emerald-500/20 blur-3xl"></div>
            <div class="mx-auto w-full max-w-[1320px] px-5 md:px-6">
                <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-emerald-300">Nossa missao</p>
                <h2 class="mt-3 max-w-4xl text-4xl leading-[0.95] tracking-tight md:text-5xl">
                    Maximizar o impacto de cada decisao financeira diaria.
                </h2>
                <p class="mt-4 max-w-4xl text-base leading-relaxed text-slate-300 md:text-lg">
                    Com tecnologia e metodo de produto, transformamos dados de rotina em contexto de acao. O objetivo e reduzir incerteza e melhorar a tomada de decisao.
                </p>

                <div class="mt-7 grid gap-4 md:grid-cols-3">
                    <article
                        v-for="item in values"
                        :key="item.title"
                        class="border-t border-white/20 pt-4"
                    >
                        <h3 class="text-2xl tracking-tight">{{ item.title }}</h3>
                        <p class="mt-2 text-sm leading-relaxed text-slate-300 md:text-base">{{ item.description }}</p>
                    </article>
                </div>

                <div class="mt-8 flex flex-wrap gap-3">
                    <Link
                        :href="route('site.contact')"
                        class="inline-flex h-11 items-center justify-center rounded-full bg-emerald-400 px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-slate-950 transition hover:bg-emerald-300"
                    >
                        Falar com especialista
                    </Link>
                    <Link
                        :href="route('site.contact')"
                        class="inline-flex h-11 items-center justify-center rounded-full border border-white/30 px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-white transition hover:border-white"
                    >
                        Trabalhar com a gente
                    </Link>
                </div>
            </div>
        </section>
    </SiteLayout>
</template>

<style scoped>
.company-timeline {
    position: relative;
}

.company-timeline::before {
    content: '';
    position: absolute;
    left: 5px;
    top: 0;
    bottom: 0;
    width: 2px;
    background: linear-gradient(180deg, rgba(16, 185, 129, 0.12), rgba(16, 185, 129, 0.52), rgba(16, 185, 129, 0.12));
}
</style>
