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

const planShowcase = [
    {
        title: 'Essencial',
        subtitle: 'Para quem esta organizando o primeiro ciclo',
        description: 'Comece com previsao de 30 dias e estrutura basica para ganhar clareza.',
        image: 'https://images.pexels.com/photos/3760263/pexels-photo-3760263.jpeg?auto=compress&cs=tinysrgb&w=900',
    },
    {
        title: 'Pro',
        subtitle: 'Para rotina financeira ativa',
        description: 'Amplie para 90 dias, recorrencias e backup para operacao constante.',
        image: 'https://images.pexels.com/photos/3183197/pexels-photo-3183197.jpeg?auto=compress&cs=tinysrgb&w=900',
    },
    {
        title: 'Visionario',
        subtitle: 'Para planejamento de longo prazo',
        description: 'Projecao de ate 5 anos com suporte prioritario para cenarios avancados.',
        image: 'https://images.pexels.com/photos/3727462/pexels-photo-3727462.jpeg?auto=compress&cs=tinysrgb&w=900',
    },
];

const guarantees = [
    '7 dias de garantia incondicional',
    'Cancele quando quiser',
    'Seus dados sao seus',
];
</script>

<template>
    <Head title="Precos | Kitamo">
        <meta name="description" content="Planos Kitamo com comparativo claro, cenarios de uso e condicoes transparentes." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[1320px] px-5 pb-14 pt-10 md:px-6 md:pb-20 md:pt-16">
            <div class="pricing-hero relative overflow-hidden rounded-[2.2rem] border border-slate-200 p-6 md:p-8">
                <div class="grid items-center gap-8 md:grid-cols-12">
                    <div class="md:col-span-6 text-white">
                        <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-emerald-300">Precos</p>
                        <h1 class="mt-4 text-5xl leading-[0.9] tracking-[-0.03em] md:text-6xl">
                            Um plano para cada
                            <span class="font-serif italic text-emerald-300">fase financeira</span>
                        </h1>
                        <p class="mt-5 max-w-xl text-base leading-relaxed text-slate-300 md:text-lg">
                            Estrutura transparente para voce escolher profundidade de projecao sem surpresa de cobranca.
                        </p>

                        <div class="mt-7 inline-flex rounded-full border border-white/20 bg-white/10 p-1 text-[11px] font-bold uppercase tracking-[0.14em]">
                            <span class="rounded-full bg-white px-4 py-2 text-slate-950">Mensal</span>
                            <span class="px-4 py-2 text-white/85">Anual (em breve)</span>
                        </div>
                    </div>

                    <div class="md:col-span-6">
                        <img
                            src="https://images.pexels.com/photos/3184433/pexels-photo-3184433.jpeg?auto=compress&cs=tinysrgb&w=1200"
                            alt="Equipe analisando dados financeiros"
                            class="h-[340px] w-full rounded-[1.6rem] object-cover md:h-[400px]"
                            loading="lazy"
                        />
                    </div>
                </div>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 pb-14 md:px-6 md:pb-20">
            <div class="overflow-hidden rounded-[2rem] border border-slate-200 bg-white">
                <div class="grid md:grid-cols-3 md:divide-x md:divide-slate-200">
                    <article
                        v-for="plan in pricingPlans"
                        :key="plan.name"
                        class="relative px-5 py-8 md:px-8"
                        :class="plan.highlighted ? 'bg-slate-950 text-white' : 'bg-white text-slate-900'"
                    >
                        <span
                            v-if="plan.highlighted"
                            class="absolute right-5 top-5 rounded-full bg-emerald-400 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.12em] text-slate-950"
                        >
                            Mais popular
                        </span>
                        <p class="text-[11px] font-bold uppercase tracking-[0.16em]" :class="plan.highlighted ? 'text-emerald-300' : 'text-slate-500'">{{ plan.name }}</p>
                        <h2 class="mt-3 text-5xl tracking-tight" :class="plan.highlighted ? 'text-white' : 'text-slate-950'">
                            R$ {{ plan.monthly }}
                            <span class="text-base font-medium" :class="plan.highlighted ? 'text-slate-300' : 'text-slate-500'">/mes</span>
                        </h2>
                        <p class="mt-3 text-sm leading-relaxed" :class="plan.highlighted ? 'text-slate-300' : 'text-slate-600'">{{ plan.subtitle }}</p>
                        <ul class="mt-5 space-y-2">
                            <li
                                v-for="feature in plan.features"
                                :key="feature"
                                class="flex items-start gap-2 text-sm font-medium"
                                :class="plan.highlighted ? 'text-slate-200' : 'text-slate-700'"
                            >
                                <span class="mt-1 h-2 w-2 rounded-full" :class="plan.highlighted ? 'bg-emerald-300' : 'bg-emerald-500'"></span>
                                <span>{{ feature }}</span>
                            </li>
                        </ul>
                        <Link
                            :href="canRegister ? '/register' : '/login'"
                            class="mt-7 inline-flex h-11 items-center justify-center rounded-full px-6 text-[11px] font-bold uppercase tracking-[0.14em] transition"
                            :class="plan.highlighted ? 'bg-white text-slate-950 hover:bg-emerald-300' : 'border border-slate-300 text-slate-700 hover:border-slate-950'"
                        >
                            {{ plan.ctaLabel }}
                        </Link>
                    </article>
                </div>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 pb-14 md:px-6 md:pb-20">
            <div class="grid gap-6 md:grid-cols-12 md:items-end">
                <div class="md:col-span-5">
                    <h2 class="text-4xl leading-[0.95] tracking-tight text-slate-950 md:text-5xl">Qual plano combina com seu momento?</h2>
                </div>
                <p class="md:col-span-4 text-base leading-relaxed text-slate-600">
                    Cada tier foi desenhado para uma fase de maturidade financeira. Voce evolui sem refazer sua base de controle.
                </p>
                <p class="md:col-span-3 text-sm font-bold uppercase tracking-[0.14em] text-slate-700 md:text-right">Casos de uso</p>
            </div>

            <div class="mt-7 grid gap-4 md:grid-cols-3">
                <article
                    v-for="item in planShowcase"
                    :key="item.title"
                    class="group overflow-hidden rounded-[1.6rem] border border-slate-200 bg-white"
                >
                    <div class="relative h-56 overflow-hidden">
                        <img
                            :src="item.image"
                            :alt="item.title"
                            class="h-full w-full object-cover transition duration-700 group-hover:scale-105"
                            loading="lazy"
                        />
                        <span class="absolute left-3 top-3 rounded-full bg-white/90 px-3 py-1 text-[11px] font-bold uppercase tracking-[0.12em] text-slate-800">{{ item.title }}</span>
                    </div>
                    <div class="p-5">
                        <p class="text-xs font-bold uppercase tracking-[0.12em] text-emerald-700">{{ item.subtitle }}</p>
                        <p class="mt-3 text-sm leading-relaxed text-slate-600">{{ item.description }}</p>
                    </div>
                </article>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 pb-14 md:px-6 md:pb-20">
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

            <div class="mt-6 flex flex-wrap gap-3">
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
                    <h2 class="mt-4 text-4xl leading-[0.95] tracking-[-0.03em] md:text-5xl">Duvidas de assinatura</h2>
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

<style scoped>
.pricing-hero {
    background:
        radial-gradient(30rem 24rem at 10% 0%, rgba(16, 185, 129, 0.2), transparent 70%),
        linear-gradient(145deg, #020617 0%, #0f172a 60%, #111827 100%);
}
</style>
