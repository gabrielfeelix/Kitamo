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
</script>

<template>
    <Head title="Recursos | Kitamo">
        <meta
            name="description"
            content="Guias, artigos e materiais praticos da Kitamo para planejamento financeiro com foco em projecao de caixa."
        />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[1240px] px-5 pb-14 pt-10 md:px-6 md:pb-20 md:pt-16">
            <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Recursos</p>
            <h1 class="mt-5 max-w-4xl text-5xl leading-[0.92] tracking-[-0.03em] text-slate-950 md:text-6xl">
                Conteudo pratico para quem quer previsibilidade financeira
            </h1>
            <p class="mt-6 max-w-3xl text-lg leading-relaxed text-slate-600 md:text-xl">
                Materiais curtos e diretos para melhorar sua rotina de controle, projecao e tomada de decisao.
            </p>
        </section>

        <section class="mx-auto w-full max-w-[1240px] px-5 py-2 md:px-6 md:py-4">
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

        <section class="mx-auto w-full max-w-[1240px] px-5 py-8 md:px-6 md:py-10">
            <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
                <article
                    v-for="card in filteredCards"
                    :key="card.title"
                    class="rounded-3xl border border-slate-200 bg-white/80 p-6"
                >
                    <p class="text-[11px] font-bold uppercase tracking-[0.14em] text-emerald-700">{{ card.category }}</p>
                    <h2 class="mt-3 text-2xl leading-tight tracking-tight text-slate-950">{{ card.title }}</h2>
                    <p class="mt-3 text-sm leading-relaxed text-slate-600">{{ card.excerpt }}</p>
                    <div class="mt-5 flex items-center justify-between">
                        <span class="text-xs font-semibold uppercase tracking-[0.12em] text-slate-500">{{ card.readTime }}</span>
                        <button
                            type="button"
                            class="inline-flex h-9 items-center justify-center rounded-full border border-slate-300 px-4 text-[11px] font-bold uppercase tracking-[0.14em] text-slate-700 transition hover:border-slate-950"
                        >
                            Em breve
                        </button>
                    </div>
                </article>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1240px] px-5 pb-20 pt-6 md:px-6 md:pb-24 md:pt-10">
            <div class="rounded-3xl border border-slate-200 bg-white p-7 md:p-10">
                <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Newsletter</p>
                <h2 class="mt-3 text-3xl leading-tight tracking-tight text-slate-950 md:text-4xl">
                    Receba novos guias da Kitamo
                </h2>
                <p class="mt-4 max-w-2xl text-base leading-relaxed text-slate-600">
                    Atualizacoes sobre projecao de caixa, rotina financeira e melhorias do produto.
                </p>
                <div class="mt-7 flex flex-wrap gap-3">
                    <Link
                        :href="route('site.contact')"
                        class="inline-flex h-11 items-center justify-center rounded-full bg-slate-950 px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-white transition hover:bg-emerald-500 hover:text-slate-950"
                    >
                        Quero receber
                    </Link>
                </div>
                <!-- TODO: integrar captura real de newsletter -->
            </div>
        </section>
    </SiteLayout>
</template>
