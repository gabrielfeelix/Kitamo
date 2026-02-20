<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import MotionSection from '@/Components/site/MotionSection.vue';
import SectionShell from '@/Components/site/SectionShell.vue';
import SiteLayout from '@/Layouts/SiteLayout.vue';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const principles = [
    {
        title: 'Clareza antes de complexidade',
        desc: 'A interface existe para facilitar decisão, não para impressionar com volume de informação.',
    },
    {
        title: 'Ação antes de perfeição',
        desc: 'Toda semana precisa terminar com um próximo passo objetivo e possível de executar.',
    },
    {
        title: 'Confiança como base',
        desc: 'Privacidade, previsibilidade e transparência são pilares de produto e operação.',
    },
];

const timeline = [
    { period: 'Fase 01', title: 'Diagnóstico do problema real', text: 'Mapeamento de dores de quem vive no modo apagar incêndio financeiro.' },
    { period: 'Fase 02', title: 'Estrutura de decisão', text: 'Construção do fluxo de leitura, alerta e projeção com foco em rotina.' },
    { period: 'Fase 03', title: 'Evolução institucional', text: 'Expansão da plataforma para comunicação clara, segurança e confiança de marca.' },
];
</script>

<template>
    <Head title="Empresa | Kitamo">
        <meta name="description" content="Conheça a visão institucional da Kitamo e os princípios por trás do produto." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[1240px] px-5 pb-10 pt-8 md:px-6 md:pt-10">
            <SectionShell
                kicker="Empresa"
                title="Construímos clareza financeira para rotina real"
                description="A Kitamo nasce para transformar confusão financeira em decisões consistentes, com foco em previsibilidade e confiança."
            />
        </section>

        <MotionSection class="mx-auto w-full max-w-[1240px] px-5 pb-10 md:px-6">
            <div class="grid gap-4 md:grid-cols-3">
                <article v-for="principle in principles" :key="principle.title" class="rounded-2xl border border-slate-200 bg-white/80 p-6">
                    <h2 class="text-2xl leading-[0.98] tracking-[-0.02em] text-slate-950">{{ principle.title }}</h2>
                    <p class="mt-3 text-sm leading-relaxed text-slate-600">{{ principle.desc }}</p>
                </article>
            </div>
        </MotionSection>

        <MotionSection class="mx-auto w-full max-w-[1240px] px-5 pb-20 md:px-6 md:pb-24">
            <SectionShell kicker="Trajetória" title="Evolução por etapas de produto e operação" compact />
            <div class="grid gap-3 md:grid-cols-3">
                <article v-for="step in timeline" :key="step.period" class="rounded-2xl border border-slate-200 bg-white/80 p-6">
                    <p class="text-xs font-bold uppercase tracking-[0.16em] text-slate-500">{{ step.period }}</p>
                    <h3 class="mt-2 text-xl leading-tight tracking-[-0.01em] text-slate-950">{{ step.title }}</h3>
                    <p class="mt-3 text-sm leading-relaxed text-slate-600">{{ step.text }}</p>
                </article>
            </div>

            <div class="mt-7 rounded-2xl border border-slate-200 bg-slate-900 p-7 text-white">
                <h3 class="text-3xl leading-[0.98] tracking-[-0.03em]">Marca forte não é promessa vazia, é consistência operacional.</h3>
                <div class="mt-6 flex flex-wrap gap-3">
                    <Link :href="route('site.contact')" class="inline-flex h-11 items-center justify-center rounded-full bg-emerald-300 px-6 text-xs font-bold uppercase tracking-[0.14em] text-slate-900">
                        Falar com a Kitamo
                    </Link>
                    <Link :href="route('site.security')" class="inline-flex h-11 items-center justify-center rounded-full border border-white/35 px-6 text-xs font-bold uppercase tracking-[0.14em] text-white">
                        Ver segurança
                    </Link>
                </div>
            </div>
        </MotionSection>
    </SiteLayout>
</template>
