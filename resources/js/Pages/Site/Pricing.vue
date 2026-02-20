<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import FaqBlock from '@/Components/site/FaqBlock.vue';
import MotionSection from '@/Components/site/MotionSection.vue';
import PricingBlock from '@/Components/site/PricingBlock.vue';
import SectionShell from '@/Components/site/SectionShell.vue';
import SiteLayout from '@/Layouts/SiteLayout.vue';
import { pricingPlans, type SiteFaqItem } from '@/types/site';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const billingFaq: SiteFaqItem[] = [
    {
        question: 'Existe plano gratuito?',
        answer: 'Sim. O plano Essencial permite iniciar com visão mensal e estrutura de controle sem custo inicial.',
    },
    {
        question: 'Posso mudar de plano depois?',
        answer: 'Sim. A evolução de plano pode ser ajustada conforme maturidade de uso e necessidade de profundidade.',
    },
    {
        question: 'Preciso cadastrar cartão para começar?',
        answer: 'Não no plano gratuito. Para planos pagos, a cobrança segue fluxo informado na contratação.',
    },
];
</script>

<template>
    <Head title="Preços | Kitamo">
        <meta
            name="description"
            content="Planos da Kitamo com estrutura clara por necessidade de controle, projeção e previsibilidade financeira."
        />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[1240px] px-5 pb-6 pt-8 md:px-6 md:pt-10">
            <SectionShell
                kicker="Preços"
                title="Transparência de planos para cada estágio de controle"
                description="Escolha o nível de profundidade ideal para seu momento, sem sobrecarga de recursos desnecessários."
            />
        </section>

        <MotionSection class="mx-auto w-full max-w-[1240px] px-5 pb-10 md:px-6">
            <PricingBlock :plans="pricingPlans" :can-register="canRegister" />
        </MotionSection>

        <MotionSection class="mx-auto w-full max-w-[980px] px-5 py-10 md:px-6 md:py-14">
            <SectionShell kicker="Cobrança e planos" title="Perguntas frequentes sobre contratação" compact />
            <FaqBlock :items="billingFaq" />
        </MotionSection>

        <section class="mx-auto w-full max-w-[1240px] px-5 pb-20 md:px-6 md:pb-24">
            <div class="rounded-3xl border border-slate-200 bg-slate-900 p-8 text-white md:p-10">
                <h2 class="text-4xl leading-[0.95] tracking-[-0.03em]">Valor real está na consistência da decisão.</h2>
                <p class="mt-4 max-w-2xl text-sm leading-relaxed text-slate-200">
                    Se quiser ajuda para escolher o melhor plano para seu cenário, a equipe pode orientar sem compromisso.
                </p>
                <div class="mt-7 flex flex-wrap gap-3">
                    <Link :href="route('site.contact')" class="inline-flex h-11 items-center justify-center rounded-full bg-emerald-300 px-6 text-xs font-bold uppercase tracking-[0.14em] text-slate-900">
                        Falar com equipe
                    </Link>
                    <Link :href="canRegister ? '/register' : '/login'" class="inline-flex h-11 items-center justify-center rounded-full border border-white/35 px-6 text-xs font-bold uppercase tracking-[0.14em] text-white">
                        Começar grátis
                    </Link>
                </div>
            </div>
        </section>
    </SiteLayout>
</template>
