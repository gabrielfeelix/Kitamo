<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const team = [
    {
        initials: 'GF',
        name: '[Nome do Fundador]',
        role: 'Fundador & CEO',
        bio: 'Responsavel por estrategia, produto e relacionamento com clientes.',
    },
    {
        initials: 'CT',
        name: '[Nome da Lideranca Tecnica]',
        role: 'CTO',
        bio: 'Responsavel por arquitetura de dados, seguranca e evolucao tecnica.',
    },
    {
        initials: 'PL',
        name: '[Nome de Produto]',
        role: 'Product Lead',
        bio: 'Responsavel por pesquisa com usuarios e desenvolvimento de experiencia.',
    },
];

const values = [
    {
        title: 'Clareza sobre volume',
        description: 'Informacao acionavel vale mais que excesso de dashboard.',
    },
    {
        title: 'Controle manual, resultado real',
        description: 'Input manual garante previsao consistente e dados sob seu dominio.',
    },
    {
        title: 'Privacidade como padrao',
        description: 'Receita de assinatura, nao de publicidade e venda de dados.',
    },
];

const stats = [
    '[X] usuarios ativos',
    'Desde [ANO]',
    '100% brasileiro',
    '[X] transacoes projetadas',
];
</script>

<template>
    <Head title="Empresa | Kitamo">
        <meta
            name="description"
            content="Conheca a historia, os valores e a equipe do Kitamo, plataforma brasileira de projecao financeira pessoal."
        />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[1320px] px-5 pb-14 pt-10 md:px-6 md:pb-20 md:pt-16">
            <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Empresa</p>
            <h1 class="mt-5 max-w-5xl text-6xl leading-[0.88] tracking-[-0.04em] text-slate-950 md:text-7xl">
                Sobre o Kitamo
            </h1>
            <p class="mt-6 max-w-3xl text-lg leading-relaxed text-slate-600 md:text-xl">
                Um produto brasileiro para quem quer previsibilidade financeira sem depender de planilhas interminaveis.
            </p>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 pb-14 md:px-6 md:pb-20">
            <div class="grid gap-10 border-y border-slate-200 py-12 md:grid-cols-12">
                <div class="md:col-span-4">
                    <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Nossa historia</p>
                    <h2 class="mt-3 text-4xl leading-[0.95] tracking-tight text-slate-950 md:text-5xl">
                        A origem da plataforma
                    </h2>
                </div>
                <div class="md:col-span-8 space-y-4 text-base leading-relaxed text-slate-600 md:text-lg">
                    <p>
                        O Kitamo nasceu da frustracao com apps que explicam o passado, mas nao ajudam a planejar o que vem pela frente.
                    </p>
                    <p>
                        Em [ano], decidimos focar em uma pergunta unica: o fluxo de caixa projetado sustenta os compromissos do mes?
                    </p>
                    <p>
                        Desde entao evoluimos em cima de tres pilares: previsibilidade, controle manual confiavel e linguagem direta para decisao.
                    </p>
                    <!-- TODO: adicionar historia real dos fundadores -->
                </div>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 pb-14 md:px-6 md:pb-20">
            <div class="mb-6">
                <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Quem faz</p>
                <h2 class="mt-3 text-4xl leading-[0.95] tracking-tight text-slate-950 md:text-5xl">Equipe principal</h2>
            </div>
            <div class="border-y border-slate-200">
                <article
                    v-for="member in team"
                    :key="member.role"
                    class="grid gap-5 border-b border-slate-200 py-6 last:border-b-0 md:grid-cols-12 md:items-center"
                >
                    <div class="md:col-span-3 flex items-center gap-4">
                        <div class="flex h-12 w-12 items-center justify-center rounded-full bg-slate-200 text-sm font-bold text-slate-700">
                            {{ member.initials }}
                        </div>
                        <div>
                            <p class="text-lg font-semibold tracking-tight text-slate-950">{{ member.name }}</p>
                            <p class="text-xs font-bold uppercase tracking-[0.12em] text-emerald-700">{{ member.role }}</p>
                        </div>
                    </div>
                    <p class="md:col-span-9 text-sm leading-relaxed text-slate-600 md:text-base">{{ member.bio }}</p>
                    <!-- TODO: adicionar fotos e bios reais -->
                </article>
            </div>
        </section>

        <section class="relative overflow-hidden bg-slate-950 py-16 text-white md:py-20">
            <div class="absolute -left-14 top-0 h-72 w-72 rounded-full bg-emerald-500/20 blur-3xl"></div>
            <div class="mx-auto w-full max-w-[1320px] px-5 md:px-6">
                <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-emerald-300">Valores</p>
                <div class="mt-6 grid gap-6 md:grid-cols-3 md:gap-8">
                    <article
                        v-for="item in values"
                        :key="item.title"
                        class="border-t border-white/20 pt-5"
                    >
                        <h3 class="text-3xl leading-tight tracking-tight">{{ item.title }}</h3>
                        <p class="mt-3 text-sm leading-relaxed text-slate-300 md:text-base">{{ item.description }}</p>
                    </article>
                </div>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 py-14 md:px-6 md:py-20">
            <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Kitamo em numeros</p>
            <div class="mt-4 grid gap-4 border-y border-slate-200 py-6 md:grid-cols-4">
                <p
                    v-for="item in stats"
                    :key="item"
                    class="text-2xl leading-tight tracking-tight text-slate-950 md:text-3xl"
                >
                    {{ item }}
                </p>
            </div>
            <p class="mt-3 text-xs uppercase tracking-[0.12em] text-slate-500">
                TODO: substituir indicadores por numeros oficiais
            </p>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 pb-20 md:px-6 md:pb-24">
            <div class="border-y border-slate-200 py-10">
                <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Carreiras</p>
                <h2 class="mt-3 text-4xl leading-[0.95] tracking-tight text-slate-950 md:text-5xl">Faca parte do time</h2>
                <p class="mt-4 max-w-3xl text-base leading-relaxed text-slate-600 md:text-lg">
                    Buscamos pessoas que compartilham nossa visao de financas pessoais simples, transparentes e orientadas a decisao.
                </p>
                <Link
                    :href="route('site.contact')"
                    class="mt-7 inline-flex h-11 items-center justify-center rounded-full bg-slate-950 px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-white transition hover:bg-emerald-500 hover:text-slate-950"
                >
                    Ver vagas abertas
                </Link>
                <!-- TODO: criar pagina de carreiras quando houver vagas -->
            </div>
        </section>
    </SiteLayout>
</template>
