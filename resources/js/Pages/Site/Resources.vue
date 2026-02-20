<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';
import { resourceCards } from '@/types/site';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const selectedCategory = ref<'Todos' | string>('Todos');

const categories = computed(() => ['Todos', ...new Set(resourceCards.map((item) => item.category))]);

const filteredCards = computed(() => {
    if (selectedCategory.value === 'Todos') return resourceCards;
    return resourceCards.filter((item) => item.category === selectedCategory.value);
});

const editorialTimeline = [
    {
        year: '2026',
        title: 'Serie Projecao na Pratica',
        description: 'Guias curtos focados em risco de saldo, rotina semanal e tomada de decisao.',
    },
    {
        year: '2026',
        title: 'Playbooks por Perfil',
        description: 'Conteudos para autonomos, casais e profissionais CLT com cenarios reais.',
    },
    {
        year: '2026',
        title: 'Newsletter Operacional',
        description: 'Resumo quinzenal com ajustes praticos para manter previsibilidade financeira.',
    },
];

const visuals = [
    'https://images.pexels.com/photos/3183150/pexels-photo-3183150.jpeg?auto=compress&cs=tinysrgb&w=1200',
    'https://images.pexels.com/photos/3184338/pexels-photo-3184338.jpeg?auto=compress&cs=tinysrgb&w=1200',
    'https://images.pexels.com/photos/3184418/pexels-photo-3184418.jpeg?auto=compress&cs=tinysrgb&w=1200',
    'https://images.pexels.com/photos/669615/pexels-photo-669615.jpeg?auto=compress&cs=tinysrgb&w=1200',
    'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=1200',
    'https://images.pexels.com/photos/1181690/pexels-photo-1181690.jpeg?auto=compress&cs=tinysrgb&w=1200',
];

const socialLinks = [
    { label: 'Instagram', note: '@kitamo (TODO)' },
    { label: 'LinkedIn', note: '/company/kitamo (TODO)' },
    { label: 'YouTube', note: '/kitamo (TODO)' },
];
</script>

<template>
    <Head title="Recursos | Kitamo">
        <meta
            name="description"
            content="Guias, playbooks e newsletter da Kitamo para projecao de caixa e organizacao financeira pessoal."
        />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="relative mx-auto w-full max-w-[1360px] px-5 pb-14 pt-10 md:px-6 md:pb-20 md:pt-16">
            <div class="pointer-events-none absolute bottom-12 left-0 top-12 hidden w-10 rounded-r-2xl bg-emerald-100/85 xl:block"></div>
            <div class="pointer-events-none absolute bottom-12 right-0 top-12 hidden w-10 rounded-l-2xl bg-emerald-100/60 xl:block"></div>

            <div class="resources-shell relative overflow-hidden rounded-[2.2rem] border border-slate-200 p-6 md:p-8">
                <div class="grid items-center gap-8 md:grid-cols-12">
                    <div class="md:col-span-7 text-white">
                        <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-emerald-300">Recursos, guias e newsletter</p>
                        <h1 class="mt-4 text-5xl leading-[0.9] tracking-[-0.03em] md:text-6xl">
                            Conteudo para
                            <span class="block font-serif italic text-emerald-300">decidir antes do aperto</span>
                        </h1>
                        <p class="mt-5 max-w-2xl text-base leading-relaxed text-slate-300 md:text-lg">
                            Material editorial direto ao ponto para transformar controle manual em previsibilidade diaria de caixa.
                        </p>

                        <div class="mt-7 flex flex-wrap gap-3">
                            <button
                                type="button"
                                class="inline-flex h-11 items-center justify-center rounded-full bg-emerald-400 px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-slate-950 transition hover:bg-emerald-300"
                            >
                                Assinar newsletter
                            </button>
                            <!-- TODO: integrar assinatura real da newsletter -->
                            <Link
                                :href="route('site.product')"
                                class="inline-flex h-11 items-center justify-center rounded-full border border-white/30 px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-white transition hover:border-white"
                            >
                                Ver produto
                            </Link>
                        </div>

                        <div class="mt-8 flex flex-wrap gap-2">
                            <span
                                v-for="tag in ['Guias praticos', 'Playbooks', 'Operacao semanal']"
                                :key="tag"
                                class="inline-flex rounded-full border border-white/20 bg-white/10 px-4 py-2 text-[11px] font-bold uppercase tracking-[0.12em]"
                            >
                                {{ tag }}
                            </span>
                        </div>
                    </div>

                    <div class="md:col-span-5">
                        <div class="relative overflow-hidden rounded-[1.8rem] border border-white/10 bg-slate-900">
                            <div class="resource-glow absolute -right-14 -top-20 h-[150%] w-[75%]"></div>
                            <img
                                src="https://images.pexels.com/photos/3184292/pexels-photo-3184292.jpeg?auto=compress&cs=tinysrgb&w=1400"
                                alt="Equipe revisando planejamento financeiro"
                                class="relative z-10 h-[360px] w-full object-cover object-center md:h-[430px]"
                                loading="lazy"
                            />
                            <div class="absolute bottom-4 left-4 right-4 z-20 rounded-2xl border border-white/15 bg-slate-950/75 p-4 backdrop-blur">
                                <p class="text-[11px] font-bold uppercase tracking-[0.14em] text-emerald-300">Edicao atual</p>
                                <p class="mt-1 text-sm text-slate-200">Ritual financeiro de 20 minutos para revisar risco e realocar gastos.</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 pb-10 md:px-6 md:pb-14">
            <div class="flex flex-wrap gap-2">
                <button
                    v-for="category in categories"
                    :key="category"
                    type="button"
                    class="inline-flex h-10 items-center justify-center rounded-full border px-4 text-[11px] font-bold uppercase tracking-[0.14em] transition"
                    :class="selectedCategory === category ? 'border-slate-950 bg-slate-950 text-white' : 'border-slate-300 bg-white text-slate-700 hover:border-slate-950'"
                    @click="selectedCategory = category"
                >
                    {{ category }}
                </button>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 pb-14 md:px-6 md:pb-20">
            <div class="grid gap-10 lg:grid-cols-12">
                <aside class="lg:col-span-4">
                    <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Linha editorial</p>
                    <h2 class="mt-3 text-4xl leading-[0.95] tracking-tight text-slate-950 md:text-5xl">Trilha de conteudo em evolucao continua</h2>
                    <ol class="timeline mt-7 space-y-6 pl-8">
                        <li v-for="item in editorialTimeline" :key="item.title" class="relative">
                            <span class="absolute -left-8 top-1 h-3 w-3 rounded-full bg-emerald-500"></span>
                            <p class="text-xs font-bold uppercase tracking-[0.14em] text-slate-500">{{ item.year }}</p>
                            <h3 class="mt-1 text-2xl leading-tight tracking-tight text-slate-950">{{ item.title }}</h3>
                            <p class="mt-2 text-sm leading-relaxed text-slate-600 md:text-base">{{ item.description }}</p>
                        </li>
                    </ol>
                </aside>

                <div class="lg:col-span-8">
                    <article
                        v-for="(card, idx) in filteredCards"
                        :key="card.title"
                        class="group grid gap-4 border-t border-slate-200 py-6 first:border-t-0 first:pt-0 md:grid-cols-[220px_minmax(0,1fr)] md:items-center"
                    >
                        <div class="relative h-44 overflow-hidden rounded-[1.2rem]">
                            <img
                                :src="visuals[idx % visuals.length]"
                                :alt="card.title"
                                class="h-full w-full object-cover transition duration-700 group-hover:scale-105"
                                loading="lazy"
                            />
                            <span class="absolute left-3 top-3 rounded-full bg-white/90 px-3 py-1 text-[11px] font-bold uppercase tracking-[0.12em] text-slate-800">{{ card.readTime }}</span>
                        </div>

                        <div>
                            <p class="text-[11px] font-bold uppercase tracking-[0.14em] text-emerald-700">{{ card.category }}</p>
                            <h3 class="mt-2 text-3xl leading-tight tracking-tight text-slate-950">{{ card.title }}</h3>
                            <p class="mt-3 max-w-3xl text-sm leading-relaxed text-slate-600 md:text-base">{{ card.excerpt }}</p>
                            <div class="mt-4 flex flex-wrap items-center gap-3">
                                <button
                                    type="button"
                                    class="inline-flex h-10 items-center justify-center rounded-full bg-slate-950 px-4 text-[11px] font-bold uppercase tracking-[0.14em] text-white transition hover:bg-emerald-500 hover:text-slate-950"
                                >
                                    Ler guia
                                </button>
                                <span class="text-xs font-semibold uppercase tracking-[0.12em] text-slate-500">Publicado em breve</span>
                            </div>
                        </div>
                    </article>
                </div>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 pb-14 md:px-6 md:pb-20">
            <div class="grid gap-4 md:grid-cols-12">
                <article class="relative overflow-hidden rounded-[1.8rem] border border-slate-200 bg-white p-6 md:col-span-7 md:p-7">
                    <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Canal da comunidade</p>
                    <h2 class="mt-3 text-4xl leading-[0.95] tracking-tight text-slate-950 md:text-5xl">Acompanhe a evolucao do produto e dos guias</h2>
                    <p class="mt-4 max-w-2xl text-base leading-relaxed text-slate-600 md:text-lg">
                        Compartilhamos bastidores, melhorias de interface, decisoes de produto e material pratico para quem usa projecao no dia a dia.
                    </p>

                    <div class="mt-6 grid gap-3 sm:grid-cols-3">
                        <div
                            v-for="social in socialLinks"
                            :key="social.label"
                            class="rounded-2xl border border-slate-200 bg-slate-50 p-4"
                        >
                            <p class="text-xs font-bold uppercase tracking-[0.14em] text-slate-600">{{ social.label }}</p>
                            <p class="mt-2 text-sm text-slate-500">{{ social.note }}</p>
                        </div>
                    </div>
                </article>

                <article class="overflow-hidden rounded-[1.8rem] bg-slate-950 text-white md:col-span-5">
                    <img
                        src="https://images.pexels.com/photos/7654580/pexels-photo-7654580.jpeg?auto=compress&cs=tinysrgb&w=1200"
                        alt="Pessoa produzindo conteudo em estudio"
                        class="h-56 w-full object-cover"
                        loading="lazy"
                    />
                    <div class="p-6">
                        <p class="text-[11px] font-bold uppercase tracking-[0.14em] text-emerald-300">Newsletter quinzenal</p>
                        <p class="mt-3 text-sm leading-relaxed text-slate-300">
                            Insights praticos para reduzir surpresa financeira sem adicionar complexidade desnecessaria.
                        </p>
                        <Link
                            :href="route('site.contact')"
                            class="mt-5 inline-flex h-10 items-center justify-center rounded-full border border-white/30 px-4 text-[11px] font-bold uppercase tracking-[0.14em] text-white transition hover:border-white"
                        >
                            Entrar na lista
                        </Link>
                    </div>
                </article>
            </div>
        </section>
    </SiteLayout>
</template>

<style scoped>
.resources-shell {
    background:
        radial-gradient(34rem 24rem at 12% 0%, rgba(16, 185, 129, 0.2), transparent 72%),
        linear-gradient(140deg, #030712 0%, #0f172a 58%, #111827 100%);
}

.resource-glow {
    background: linear-gradient(145deg, rgba(16, 185, 129, 0.65), rgba(99, 102, 241, 0.6));
    transform: rotate(-18deg);
    border-radius: 2rem;
}

.timeline {
    position: relative;
}

.timeline::before {
    content: '';
    position: absolute;
    left: 5px;
    top: 6px;
    bottom: 6px;
    width: 2px;
    background: linear-gradient(180deg, rgba(16, 185, 129, 0.1), rgba(16, 185, 129, 0.45), rgba(16, 185, 129, 0.1));
}
</style>
