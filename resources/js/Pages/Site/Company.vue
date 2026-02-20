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
        bio: 'Responsavel por produto, estrategia e operacao comercial.',
    },
    {
        initials: 'CT',
        name: '[Nome da Lideranca Tecnica]',
        role: 'CTO',
        bio: 'Responsavel por arquitetura, seguranca e evolucao da plataforma.',
    },
    {
        initials: 'CP',
        name: '[Nome do Lider de Produto]',
        role: 'Product Lead',
        bio: 'Responsavel por pesquisa com usuarios e evolucao da experiencia.',
    },
];

const values = [
    {
        title: 'Clareza sobre volume',
        description: 'Voce precisa de informacao acionavel para decidir, nao de dashboards infinitos.',
    },
    {
        title: 'Controle manual, resultados reais',
        description: 'Input manual significa dados confiaveis e previsao consistente sob seu controle.',
    },
    {
        title: 'Privacidade como padrao',
        description: 'Nossa receita vem de assinatura. Nao vendemos dados nem dependemos de publicidade.',
    },
];

const stats = [
    {
        value: '[X] usuarios ativos',
        note: 'TODO: inserir numero real de usuarios ativos',
    },
    {
        value: 'Desde [ANO]',
        note: 'TODO: inserir ano real de fundacao',
    },
    {
        value: '100% brasileiro',
        note: 'Produto desenvolvido para rotina financeira no Brasil',
    },
    {
        value: '[X] transacoes projetadas',
        note: 'TODO: inserir volume real de projecoes processadas',
    },
];
</script>

<template>
    <Head title="Empresa | Kitamo">
        <meta
            name="description"
            content="Conheca a historia, os valores e o time por tras do Kitamo, produto brasileiro de projecao financeira pessoal."
        />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[1240px] px-5 pb-14 pt-10 md:px-6 md:pb-20 md:pt-16">
            <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Empresa</p>
            <h1 class="mt-5 max-w-4xl text-5xl leading-[0.92] tracking-[-0.03em] text-slate-950 md:text-6xl">
                Sobre o Kitamo
            </h1>
            <p class="mt-6 max-w-3xl text-lg leading-relaxed text-slate-600 md:text-xl">
                Um produto brasileiro para quem quer saber com antecedencia se o dinheiro do mes sustenta os proximos compromissos.
            </p>
        </section>

        <section class="mx-auto w-full max-w-[1240px] px-5 py-6 md:px-6 md:py-8">
            <div class="rounded-3xl border border-slate-200 bg-white/80 p-7 md:p-10">
                <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Nossa historia</p>
                <div class="mt-5 space-y-4 text-base leading-relaxed text-slate-600 md:text-lg">
                    <p>
                        O Kitamo nasceu da frustracao com apps que mostram onde voce gastou, mas nao ajudam a planejar o que vem pela frente.
                    </p>
                    <p>
                        Em [ano], escolhemos construir uma plataforma focada em uma pergunta objetiva: a projeção do seu caixa sustenta o restante do mes?
                    </p>
                    <p>
                        Desde entao, o produto evolui com foco em previsibilidade, controle manual confiavel e linguagem direta para tomada de decisao.
                    </p>
                </div>
                <!-- TODO: adicionar historia real dos fundadores -->
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1240px] px-5 py-12 md:px-6 md:py-16">
            <div class="mb-8">
                <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Quem faz o Kitamo</p>
                <h2 class="mt-3 text-3xl leading-tight tracking-tight text-slate-950 md:text-4xl">Time fundador e lideranca</h2>
            </div>
            <div class="grid gap-4 md:grid-cols-3">
                <article
                    v-for="member in team"
                    :key="member.role"
                    class="rounded-3xl border border-slate-200 bg-white/80 p-6"
                >
                    <div class="flex h-14 w-14 items-center justify-center rounded-full bg-slate-200 text-base font-bold text-slate-700">
                        {{ member.initials }}
                    </div>
                    <h3 class="mt-4 text-xl tracking-tight text-slate-950">{{ member.name }}</h3>
                    <p class="mt-1 text-sm font-semibold uppercase tracking-[0.12em] text-emerald-700">{{ member.role }}</p>
                    <p class="mt-3 text-sm leading-relaxed text-slate-600">{{ member.bio }}</p>
                    <!-- TODO: adicionar fotos e bios reais -->
                </article>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1240px] px-5 py-4 md:px-6 md:py-8">
            <div class="rounded-3xl bg-slate-950 p-7 text-white md:p-10">
                <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-emerald-300">Nossos valores</p>
                <div class="mt-6 grid gap-4 md:grid-cols-3">
                    <article
                        v-for="item in values"
                        :key="item.title"
                        class="rounded-2xl border border-white/10 bg-white/5 p-5"
                    >
                        <h3 class="text-2xl tracking-tight">{{ item.title }}</h3>
                        <p class="mt-3 text-sm leading-relaxed text-slate-300">{{ item.description }}</p>
                    </article>
                </div>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1240px] px-5 py-12 md:px-6 md:py-16">
            <div class="mb-8">
                <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Kitamo em numeros</p>
                <h2 class="mt-3 text-3xl leading-tight tracking-tight text-slate-950 md:text-4xl">Indicadores institucionais</h2>
            </div>
            <div class="grid gap-4 md:grid-cols-4">
                <article
                    v-for="item in stats"
                    :key="item.value"
                    class="rounded-3xl border border-slate-200 bg-white/80 p-6"
                >
                    <p class="text-xl font-semibold tracking-tight text-slate-950">{{ item.value }}</p>
                    <p class="mt-2 text-xs leading-relaxed uppercase tracking-[0.12em] text-slate-500">{{ item.note }}</p>
                </article>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1240px] px-5 pb-20 pt-6 md:px-6 md:pb-24 md:pt-10">
            <div class="rounded-3xl border border-slate-200 bg-white p-7 md:p-10">
                <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Carreiras</p>
                <h2 class="mt-3 text-3xl leading-tight tracking-tight text-slate-950 md:text-4xl">Faca parte do time</h2>
                <p class="mt-4 max-w-3xl text-base leading-relaxed text-slate-600 md:text-lg">
                    Estamos sempre buscando pessoas que compartilham nossa visao de financas pessoais simples, transparentes e orientadas a decisao.
                </p>
                <div class="mt-7 flex flex-wrap gap-3">
                    <Link
                        :href="route('site.contact')"
                        class="inline-flex h-11 items-center justify-center rounded-full bg-slate-950 px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-white transition hover:bg-emerald-500 hover:text-slate-950"
                    >
                        Ver vagas abertas
                    </Link>
                </div>
                <!-- TODO: criar pagina de carreiras quando houver vagas -->
            </div>
        </section>
    </SiteLayout>
</template>
