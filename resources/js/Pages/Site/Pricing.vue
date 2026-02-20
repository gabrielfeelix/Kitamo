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
        answer: 'Sim. O Essencial e gratuito e inclui previsao de 30 dias com limites de uso.',
    },
    {
        question: 'Posso mudar de plano a qualquer momento?',
        answer: 'Sim. Upgrade e downgrade podem ser feitos conforme sua necessidade.',
    },
    {
        question: 'Como cancelo um plano pago?',
        answer: 'O cancelamento e simples e pode ser feito sem burocracia. O plano volta ao Essencial no proximo ciclo.',
    },
    {
        question: 'Aceita PIX?',
        answer: 'Depende da forma de pagamento habilitada no momento. Se precisar de validacao comercial, fale com nosso suporte.',
    },
    {
        question: 'Tem desconto anual?',
        answer: 'Pode existir campanha pontual. Quando houver, a condicao aparece de forma explicita na tela de assinatura.',
    },
    {
        question: 'O Kitamo conecta no meu banco?',
        answer: 'Nao. O controle e manual e nao utiliza Open Finance.',
    },
];

const openFaqIndex = ref<number | null>(0);

const guarantees = [
    {
        title: '7 dias de garantia incondicional',
        description: 'Se nao fizer sentido para voce, devolvemos o valor dentro do prazo legal informado.',
    },
    {
        title: 'Cancele quando quiser',
        description: 'Sem contrato travado. O controle da assinatura fica na sua mao.',
    },
    {
        title: 'Seus dados sao seus',
        description: 'Voce pode solicitar acesso, exportacao e exclusao conforme LGPD.',
    },
];
</script>

<template>
    <Head title="Precos | Kitamo">
        <meta name="description" content="Planos da Kitamo com comparacao clara de recursos e politica transparente." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[1240px] px-5 pb-10 pt-10 text-center md:px-6 md:pb-12 md:pt-16">
            <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Precos</p>
            <h1 class="mx-auto mt-5 max-w-4xl text-5xl leading-[0.92] tracking-[-0.03em] text-slate-950 md:text-6xl">
                Precos transparentes. Sem surpresas.
            </h1>
            <p class="mx-auto mt-6 max-w-3xl text-lg leading-relaxed text-slate-600 md:text-xl">
                Escolha o plano certo para seu momento e evolua conforme sua rotina financeira amadurece.
            </p>
        </section>

        <section class="mx-auto w-full max-w-[1240px] px-5 py-6 md:px-6 md:py-8">
            <div class="grid gap-4 md:grid-cols-3">
                <article
                    v-for="plan in pricingPlans"
                    :key="plan.name"
                    class="rounded-3xl border p-6"
                    :class="plan.highlighted ? 'border-emerald-300 bg-emerald-50/70' : 'border-slate-200 bg-white/80'"
                >
                    <p class="text-xs font-bold uppercase tracking-[0.16em] text-slate-500">{{ plan.name }}</p>
                    <h2 class="mt-3 text-4xl tracking-tight text-slate-950">R$ {{ plan.monthly }}<span class="text-sm font-medium text-slate-500">/mes</span></h2>
                    <p class="mt-2 text-sm leading-relaxed text-slate-600">{{ plan.subtitle }}</p>

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
                        class="mt-6 inline-flex h-11 w-full items-center justify-center rounded-full text-[11px] font-bold uppercase tracking-[0.14em] transition"
                        :class="plan.highlighted ? 'bg-slate-950 text-white hover:bg-emerald-500 hover:text-slate-950' : 'border border-slate-300 bg-white text-slate-700 hover:border-slate-950'"
                    >
                        {{ plan.ctaLabel }}
                    </Link>
                </article>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1240px] px-5 py-12 md:px-6 md:py-16">
            <div class="rounded-3xl border border-slate-200 bg-white p-6 md:p-8">
                <h2 class="text-3xl tracking-tight text-slate-950 md:text-4xl">Comparativo de funcionalidades</h2>
                <div class="mt-6 overflow-x-auto">
                    <table class="min-w-full text-sm">
                        <thead>
                            <tr class="border-b border-slate-200 text-left text-xs uppercase tracking-[0.14em] text-slate-500">
                                <th class="pb-3 pr-4">Funcionalidade</th>
                                <th class="pb-3 pr-4">Essencial</th>
                                <th class="pb-3 pr-4">Pro</th>
                                <th class="pb-3">Visionario</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr
                                v-for="feature in pricingFeatureComparisons"
                                :key="feature.name"
                                class="border-b border-slate-100"
                            >
                                <td class="py-3 pr-4 font-medium text-slate-900">{{ feature.name }}</td>
                                <td class="py-3 pr-4 text-slate-600">{{ feature.status[0] }}</td>
                                <td class="py-3 pr-4 text-slate-600">{{ feature.status[1] }}</td>
                                <td class="py-3 text-slate-600">{{ feature.status[2] }}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1240px] px-5 py-4 md:px-6 md:py-6">
            <div class="grid gap-4 md:grid-cols-3">
                <article
                    v-for="item in guarantees"
                    :key="item.title"
                    class="rounded-3xl border border-slate-200 bg-white/80 p-6"
                >
                    <h3 class="text-xl tracking-tight text-slate-900">{{ item.title }}</h3>
                    <p class="mt-3 text-sm leading-relaxed text-slate-600">{{ item.description }}</p>
                </article>
            </div>
        </section>

        <section class="bg-slate-950 py-16 text-white md:py-20">
            <div class="mx-auto grid w-full max-w-[1240px] gap-10 px-5 md:grid-cols-2 md:px-6">
                <div>
                    <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-emerald-300">Perguntas frequentes</p>
                    <h2 class="mt-4 text-4xl leading-[0.96] tracking-tight">Ultimas objecoes e duvidas</h2>
                    <p class="mt-4 text-base leading-relaxed text-slate-300">Respostas diretas para voce escolher plano sem duvida escondida.</p>
                </div>

                <div class="space-y-3">
                    <article
                        v-for="(faq, index) in billingFaq"
                        :key="faq.question"
                        class="rounded-2xl border border-white/10 bg-white/5 px-4 py-3"
                    >
                        <button
                            type="button"
                            class="flex w-full items-center justify-between gap-5 py-2 text-left"
                            @click="openFaqIndex = openFaqIndex === index ? null : index"
                        >
                            <h3 class="text-base font-semibold">{{ faq.question }}</h3>
                            <span class="text-xl leading-none text-slate-400" :class="openFaqIndex === index ? 'rotate-45 text-emerald-300' : ''">+</span>
                        </button>
                        <p v-if="openFaqIndex === index" class="pb-2 text-sm leading-relaxed text-slate-300">{{ faq.answer }}</p>
                    </article>
                </div>
            </div>
        </section>
    </SiteLayout>
</template>
