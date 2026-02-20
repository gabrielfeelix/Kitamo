<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, Link } from '@inertiajs/vue3';
import MotionSection from '@/Components/site/MotionSection.vue';
import SectionShell from '@/Components/site/SectionShell.vue';
import SiteLayout from '@/Layouts/SiteLayout.vue';
import { resourceCards } from '@/types/site';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const categories = ['Todos', 'Fundamentos', 'Planejamento', 'Organização'] as const;
const activeCategory = ref<typeof categories[number]>('Todos');

const filteredCards = computed(() => {
    if (activeCategory.value === 'Todos') {
        return resourceCards;
    }
    return resourceCards.filter((card) => card.category === activeCategory.value);
});
</script>

<template>
    <Head title="Recursos | Kitamo">
        <meta
            name="description"
            content="Conteúdo institucional da Kitamo com guias sobre fundamentos, planejamento e organização financeira pessoal."
        />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[1240px] px-5 pb-6 pt-8 md:px-6 md:pt-10">
            <SectionShell
                kicker="Recursos"
                title="Guias práticos para melhorar qualidade de decisão"
                description="Conteúdo curado em linguagem direta para transformar finanças pessoais em rotina previsível."
            />
            <div class="mt-6 flex flex-wrap gap-2">
                <button
                    v-for="category in categories"
                    :key="category"
                    type="button"
                    class="rounded-full border px-4 py-2 text-xs font-bold uppercase tracking-[0.14em] transition"
                    :class="
                        activeCategory === category
                            ? 'border-emerald-400 bg-emerald-50 text-emerald-700'
                            : 'border-slate-300 bg-white text-slate-600 hover:bg-slate-100'
                    "
                    @click="activeCategory = category"
                >
                    {{ category }}
                </button>
            </div>
        </section>

        <MotionSection class="mx-auto w-full max-w-[1240px] px-5 pb-20 md:px-6 md:pb-24">
            <div class="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
                <article
                    v-for="card in filteredCards"
                    :key="card.title"
                    class="rounded-2xl border border-slate-200 bg-white/85 p-6"
                >
                    <p class="text-[11px] font-bold uppercase tracking-[0.15em] text-slate-500">{{ card.category }}</p>
                    <h2 class="mt-3 text-2xl leading-[0.98] tracking-[-0.02em] text-slate-950">{{ card.title }}</h2>
                    <p class="mt-3 text-sm leading-relaxed text-slate-600">{{ card.excerpt }}</p>
                    <div class="mt-6 flex items-center justify-between">
                        <span class="text-xs font-semibold text-slate-500">{{ card.readTime }}</span>
                        <span class="text-xs font-bold uppercase tracking-[0.14em] text-emerald-700">Em breve</span>
                    </div>
                </article>
            </div>

            <div class="mt-8 rounded-2xl border border-slate-200 bg-slate-900 p-6 text-white md:flex md:items-center md:justify-between">
                <div>
                    <p class="text-xs font-bold uppercase tracking-[0.16em] text-emerald-200/80">Newsletter institucional</p>
                    <p class="mt-2 text-sm leading-relaxed text-slate-200">Receba novos materiais práticos com foco em decisão financeira real.</p>
                </div>
                <Link :href="route('site.contact')" class="mt-4 inline-flex h-11 items-center justify-center rounded-full bg-emerald-300 px-6 text-xs font-bold uppercase tracking-[0.14em] text-slate-900 md:mt-0">
                    Quero receber
                </Link>
            </div>
        </MotionSection>
    </SiteLayout>
</template>
