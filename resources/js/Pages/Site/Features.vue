<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import MotionSection from '@/Components/site/MotionSection.vue';
import SectionShell from '@/Components/site/SectionShell.vue';
import SiteLayout from '@/Layouts/SiteLayout.vue';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const matrix = [
    { title: 'Controle diário', summary: 'Visão rápida do mês', points: ['Saldo projetado', 'Categorias prioritárias', 'Pendências críticas'] },
    { title: 'Recorrências', summary: 'Menos vazamento silencioso', points: ['Assinaturas visíveis', 'Cobranças periódicas', 'Alertas de revisão'] },
    { title: 'Projeção', summary: 'Impacto antes da decisão', points: ['Cenários de parcela', 'Comparação de rota', 'Leitura de risco'] },
    { title: 'Ritual semanal', summary: 'Consistência sem esforço extra', points: ['Próxima ação definida', 'Checklist de ajuste', 'Prioridade da semana'] },
];
</script>

<template>
    <Head title="Funcionalidades | Kitamo">
        <meta name="description" content="Funcionalidades da Kitamo para controle diário, recorrências, projeção e rotina de decisão financeira." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[1240px] px-5 pb-6 pt-8 md:px-6 md:pt-10">
            <SectionShell
                kicker="Funcionalidades"
                title="Cada recurso responde uma necessidade prática"
                description="A arquitetura foi desenhada para transformar dados em ação com menor atrito de entendimento."
            />
        </section>

        <MotionSection class="mx-auto w-full max-w-[1240px] px-5 pb-8 md:px-6">
            <div class="grid gap-4 md:grid-cols-2">
                <article
                    v-for="item in matrix"
                    :key="item.title"
                    class="rounded-2xl border border-slate-200 bg-white/80 p-6"
                >
                    <p class="text-xs font-bold uppercase tracking-[0.16em] text-slate-500">{{ item.title }}</p>
                    <h2 class="mt-3 text-3xl leading-[0.96] tracking-[-0.03em] text-slate-950">{{ item.summary }}</h2>
                    <ul class="mt-5 space-y-2">
                        <li
                            v-for="point in item.points"
                            :key="point"
                            class="flex items-center gap-2 text-sm font-semibold text-slate-700"
                        >
                            <span class="h-2 w-2 rounded-full bg-emerald-500"></span>
                            {{ point }}
                        </li>
                    </ul>
                </article>
            </div>
        </MotionSection>

        <MotionSection class="mx-auto grid w-full max-w-[1240px] gap-5 px-5 py-14 md:grid-cols-2 md:px-6 md:py-16">
            <article class="rounded-3xl border border-slate-200 bg-white/80 p-7">
                <p class="text-xs font-bold uppercase tracking-[0.16em] text-slate-500">Para quem é</p>
                <ul class="mt-4 space-y-3 text-sm font-medium leading-relaxed text-slate-700">
                    <li>Quem quer clareza de decisão sem depender de planilhas extensas.</li>
                    <li>Quem precisa antecipar risco de vencimento e fluxo.</li>
                    <li>Quem busca rotina semanal objetiva para manter consistência.</li>
                </ul>
            </article>

            <article class="rounded-3xl border border-slate-200 bg-white/80 p-7">
                <p class="text-xs font-bold uppercase tracking-[0.16em] text-slate-500">Para quem não é</p>
                <ul class="mt-4 space-y-3 text-sm font-medium leading-relaxed text-slate-700">
                    <li>Quem prefere operar apenas no histórico sem olhar cenário futuro.</li>
                    <li>Quem não quer executar nenhuma rotina de revisão semanal.</li>
                    <li>Quem procura ferramenta exclusivamente empresarial no v1.</li>
                </ul>
            </article>
        </MotionSection>

        <section class="mx-auto w-full max-w-[1240px] px-5 pb-20 md:px-6 md:pb-24">
            <div class="rounded-3xl border border-slate-200 bg-slate-900 p-8 text-white md:p-10">
                <h2 class="text-4xl leading-[0.95] tracking-[-0.03em]">Funcionalidade só vale quando vira decisão.</h2>
                <div class="mt-7 flex flex-wrap gap-3">
                    <Link :href="route('site.product')" class="inline-flex h-11 items-center justify-center rounded-full bg-emerald-300 px-6 text-xs font-bold uppercase tracking-[0.14em] text-slate-900">
                        Ver visão do produto
                    </Link>
                    <Link :href="route('site.contact')" class="inline-flex h-11 items-center justify-center rounded-full border border-white/40 px-6 text-xs font-bold uppercase tracking-[0.14em] text-white">
                        Tirar dúvidas
                    </Link>
                </div>
            </div>
        </section>
    </SiteLayout>
</template>
