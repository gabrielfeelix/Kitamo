<script setup lang="ts">
import { ref } from 'vue';
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';
import { pricingPlans, pricingFeatureComparisons, type SiteFaqItem } from '@/types/site';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const billingFaq: SiteFaqItem[] = [
    {
        question: 'Existe plano gratuito?',
        answer: 'Sim. O Essencial e gratuito e inclui projecao de 30 dias com limites de uso.',
    },
    {
        question: 'Posso mudar de plano a qualquer momento?',
        answer: 'Sim. Upgrade e downgrade ficam disponiveis conforme sua necessidade.',
    },
    {
        question: 'Como cancelo um plano pago?',
        answer: 'O cancelamento e direto e o plano retorna ao Essencial no ciclo seguinte.',
    },
    {
        question: 'Aceita PIX?',
        answer: 'Depende do metodo habilitado no momento da assinatura. Consulte o suporte para detalhe comercial.',
    },
    {
        question: 'Tem desconto anual?',
        answer: 'Pode haver campanha pontual. Quando existir, ela aparece explicitamente no checkout.',
    },
    {
        question: 'O Kitamo conecta no meu banco?',
        answer: 'Nao. O controle e manual e nao utiliza Open Finance.',
    },
];

const openFaqIndex = ref<number | null>(0);

const guarantees = [
    '7 dias de garantia incondicional',
    'Cancele quando quiser',
    'Seus dados sao seus',
];
</script>

<template>
    <Head title="Precos | Kitamo">
        <meta name="description" content="Planos Kitamo com comparativo claro de recursos e condicoes transparentes." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[1320px] px-5 pb-10 pt-10 md:px-6 md:pb-14 md:pt-16">
            <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Precos</p>
            <h1 class="mt-5 max-w-5xl text-5xl leading-[0.9] tracking-[-0.03em] text-slate-950 md:text-7xl">
                Transparencia de plano,
                <span class="font-serif italic text-emerald-600">sem surpresa de cobranca</span>
            </h1>
            <p class="mt-6 max-w-3xl text-lg leading-relaxed text-slate-600 md:text-xl">
                Escolha o nivel de profundidade da projecao e evolua quando sua rotina exigir mais alcance.
            </p>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 pb-12 md:px-6 md:pb-16">
            <div class="border-y border-slate-200">
                <div class="grid md:grid-cols-3 md:divide-x md:divide-slate-200">
                    <article
                        v-for="plan in pricingPlans"
                        :key="plan.name"
                        class="border-b border-slate-200 px-2 py-8 last:border-b-0 md:border-b-0 md:px-8"
                    >
                        <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">{{ plan.name }}</p>
                        <h2 class="mt-3 text-5xl tracking-tight text-slate-950">
                            R$ {{ plan.monthly }}
                            <span class="text-base font-medium text-slate-500">/mes</span>
                        </h2>
                        <p class="mt-3 text-sm leading-relaxed text-slate-600 md:text-base">{{ plan.subtitle }}</p>
                        <ul class="mt-5 space-y-2">
                            <li
                                v-for="feature in plan.features"
                                :key="feature"
                                class="flex items-start gap-2 text-sm font-medium text-slate-700"
                            >
                                <span class="mt-1 h-2 w-2 rounded-full bg-emerald-500"></span>
                                <span>{{ feature }}</span>
                            </li>
                        </ul>
                        <Link
                            :href="canRegister ? '/register' : '/login'"
                            class="mt-7 inline-flex h-11 items-center justify-center rounded-full px-6 text-[11px] font-bold uppercase tracking-[0.14em] transition"
                            :class="plan.highlighted ? 'bg-slate-950 text-white hover:bg-emerald-500 hover:text-slate-950' : 'border border-slate-300 text-slate-700 hover:border-slate-950'"
                        >
                            {{ plan.ctaLabel }}
                        </Link>
                    </article>
                </div>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 pb-12 md:px-6 md:pb-16">
            <div class="overflow-x-auto border-y border-slate-200 py-8">
                <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Comparativo tecnico</p>
                <table class="mt-4 min-w-full text-sm">
                    <thead>
                        <tr class="border-b border-slate-200 text-left text-xs uppercase tracking-[0.14em] text-slate-500">
                            <th class="pb-3 pr-4">Funcionalidade</th>
                            <th class="pb-3 pr-4">Essencial</th>
                            <th class="pb-3 pr-4">Pro</th>
                            <th class="pb-3">Visionario</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="feature in pricingFeatureComparisons" :key="feature.name" class="border-b border-slate-100">
                            <td class="py-3 pr-4 font-medium text-slate-900">{{ feature.name }}</td>
                            <td class="py-3 pr-4 text-slate-600">{{ feature.status[0] }}</td>
                            <td class="py-3 pr-4 text-slate-600">{{ feature.status[1] }}</td>
                            <td class="py-3 text-slate-600">{{ feature.status[2] }}</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 pb-12 md:px-6 md:pb-16">
            <div class="flex flex-wrap items-center gap-3 border-y border-slate-200 py-6">
                <span
                    v-for="item in guarantees"
                    :key="item"
                    class="inline-flex rounded-full border border-emerald-300 bg-emerald-50 px-4 py-2 text-[11px] font-bold uppercase tracking-[0.14em] text-emerald-700"
                >
                    {{ item }}
                </span>
            </div>
        </section>

        <section class="relative overflow-hidden bg-slate-950 py-16 text-white md:py-20">
            <div class="absolute right-10 top-0 h-72 w-72 rounded-full bg-emerald-500/20 blur-3xl"></div>
            <div class="mx-auto grid w-full max-w-[1320px] gap-10 px-5 md:grid-cols-12 md:px-6">
                <div class="md:col-span-4">
                    <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-emerald-300">FAQ</p>
                    <h2 class="mt-4 text-4xl leading-[0.95] tracking-[-0.03em] md:text-5xl">Dúvidas de assinatura</h2>
                    <p class="mt-4 text-base leading-relaxed text-slate-300">
                        Respostas diretas para voce decidir com seguranca.
                    </p>
                </div>
                <div class="md:col-span-8">
                    <article
                        v-for="(faq, index) in billingFaq"
                        :key="faq.question"
                        class="border-b border-white/15 py-4"
                    >
                        <button
                            type="button"
                            class="flex w-full items-center justify-between gap-5 text-left"
                            @click="openFaqIndex = openFaqIndex === index ? null : index"
                        >
                            <h3 class="text-lg font-semibold tracking-tight">{{ faq.question }}</h3>
                            <span class="text-xl leading-none text-slate-400" :class="openFaqIndex === index ? 'rotate-45 text-emerald-300' : ''">+</span>
                        </button>
                        <p v-if="openFaqIndex === index" class="mt-3 text-sm leading-relaxed text-slate-300 md:text-base">{{ faq.answer }}</p>
                    </article>
                </div>
            </div>
        </section>
    </SiteLayout>
</template>
