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
        answer: 'Sim! O plano Essencial é de graça e te dá visão de 30 dias pra frente. Ideal pra começar a organizar a casa sem botar a mão no bolso.',
    },
    {
        question: 'Posso mudar de plano a qualquer momento?',
        answer: 'Lógico. Sentiu que precisa de mais visão de futuro? Sobe de plano. Apertou? Desce.',
    },
    {
        question: 'Como cancelo um plano pago?',
        answer: 'Sem botão escondido ou ligação chata. Você cancela com 2 cliques na sua conta e o plano volta pro gratuito no mês seguinte.',
    },
    {
        question: 'Aceita PIX?',
        answer: 'Sim, dependendo da tela de checkout ativa no momento. Boleto e Cartão de Crédito também sempre salvam.',
    },
    {
        question: 'Tem desconto anual?',
        answer: 'Se tiver campanha rodando você vai ver gigante na tela. Fica de olho.',
    },
    {
        question: 'O Kitamo conecta no meu banco?',
        answer: 'Não. O controle é seu, manual e intencional. Sem open finance fuçando onde não deve. Tirou do bolso, põe no app.',
    },
];

const openFaqIndex = ref<number | null>(0);

const planShowcase = [
    {
        title: 'Essencial',
        subtitle: 'Pra arrumar a bagunça do primeiro mês',
        description: '30 dias de visão pra frente. Chega de tomar susto quando a fatura fecha.',
        image: 'https://images.pexels.com/photos/3760263/pexels-photo-3760263.jpeg?auto=compress&cs=tinysrgb&w=900',
    },
    {
        title: 'Pro',
        subtitle: 'Pra quem o negócio já tá rodando',
        description: 'Amplie a visão pra 90 dias, coloque os gastos da casa toda no automático.',
        image: 'https://images.pexels.com/photos/3183197/pexels-photo-3183197.jpeg?auto=compress&cs=tinysrgb&w=900',
    },
    {
        title: 'Visionário',
        subtitle: 'Pra planejar lá na frente',
        description: 'Projeção de até 5 anos. Quer saber quando dá pra comprar o carro? Vem pra cá.',
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
    <Head title="Preços | Kitamo">
        <meta name="description" content="Planos Kitamo: transparente, sem pegadinhas." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <!-- Hero Section -->
        <MotionSection class="relative min-h-[70vh] w-full overflow-hidden bg-slate-950 text-white flex flex-col justify-center pt-32 pb-20 border-b border-white/5">
            <div class="absolute inset-0 opacity-[0.02] mix-blend-overlay pointer-events-none" style="background-image: url('data:image/svg+xml,%3Csvg viewBox=%220 0 200 200%22 xmlns=%22http://www.w3.org/2000/svg%22%3E%3Cfilter id=%22noiseFilter%22%3E%3CfeTurbulence type=%22fractalNoise%22 baseFrequency=%220.8%22 numOctaves=%224%22 stitchTiles=%22stitch%22/%3E%3C/filter%3E%3Crect width=%22100%25%22 height=%22100%25%22 filter=%22url(%23noiseFilter)%22/%3E%3C/svg%3E');"></div>
            
            <div class="pointer-events-none absolute top-10 left-10 w-[500px] h-[500px] bg-teal-600/20 blur-[130px] rounded-full mix-blend-screen opacity-50"></div>
            
            <div class="relative z-10 mx-auto w-full max-w-[1440px] px-6 md:px-12 text-center flex flex-col items-center">
                <p class="inline-flex items-center space-x-2 text-[11px] font-bold uppercase tracking-[0.2em] text-teal-400 mb-6 drop-shadow-sm bg-teal-400/10 px-4 py-2 rounded-full border border-teal-400/20">Sem letrinhas miúdas</p>
                <h1 class="text-5xl sm:text-6xl lg:text-[5.5rem] leading-[0.95] tracking-tighter mix-blend-lighten text-slate-100 font-extrabold max-w-4xl">
                    Preços pro seu<br>
                    <span class="text-transparent bg-clip-text bg-gradient-to-r from-teal-300 to-green-400 font-serif italic pr-2">momento financeiro.</span>
                </h1>
                <p class="mt-8 text-xl leading-relaxed text-slate-400 font-medium max-w-2xl mx-auto">
                    Estrutura justa e direta. Você escolhe quão longe quer ver o seu dinheiro.
                </p>

                <div class="mt-12 inline-flex items-center gap-2 rounded-full border border-white/20 bg-white/5 p-1.5 backdrop-blur-md">
                    <span class="rounded-full bg-teal-500 px-6 py-2.5 text-xs font-bold uppercase tracking-widest text-slate-950 shadow-sm transition-all hover:bg-teal-400 cursor-pointer">Mensal</span>
                    <span class="px-6 py-2.5 text-xs font-bold uppercase tracking-widest text-white/60 cursor-not-allowed">Anual (Em breve)</span>
                </div>
            </div>
        </MotionSection>

        <!-- Pricing Cards Section -->
        <MotionSection class="bg-gray-50 py-24 relative -mt-10 overflow-hidden">
            <div class="mx-auto w-full max-w-[1440px] px-6 md:px-12">
                <div class="grid lg:grid-cols-3 gap-8">
                    <article
                        v-for="plan in pricingPlans"
                        :key="plan.name"
                        class="relative rounded-[2.5rem] border p-8 md:p-10 transition-transform duration-500 hover:-translate-y-2 flex flex-col"
                        :class="plan.highlighted ? 'bg-slate-950 text-white border-slate-800 shadow-2xl scale-[1.02] lg:scale-[1.05] z-10' : 'bg-white text-slate-900 border-slate-200 shadow-sm hover:shadow-xl'"
                    >
                        <div v-if="plan.highlighted" class="absolute -top-4 left-1/2 -translate-x-1/2 rounded-full bg-gradient-to-r from-teal-400 to-emerald-500 px-5 py-2 text-[10px] font-extrabold uppercase tracking-[0.2em] text-slate-950 shadow-lg whitespace-nowrap">
                            A galera prefere
                        </div>
                        
                        <p class="text-[12px] font-bold uppercase tracking-[0.2em] mb-4" :class="plan.highlighted ? 'text-teal-400' : 'text-slate-500'">{{ plan.name }}</p>
                        
                        <div class="mb-6 flex items-baseline gap-2">
                            <span class="text-2xl font-bold" :class="plan.highlighted ? 'text-slate-400' : 'text-slate-400'">R$</span>
                            <h2 class="text-6xl font-extrabold tracking-tighter" :class="plan.highlighted ? 'text-white' : 'text-slate-950'">{{ plan.monthly }}</h2>
                            <span class="text-lg font-medium" :class="plan.highlighted ? 'text-slate-400' : 'text-slate-500'">/mês</span>
                        </div>
                        
                        <p class="text-sm leading-relaxed mb-8 flex-grow font-medium" :class="plan.highlighted ? 'text-slate-300' : 'text-slate-600'">{{ plan.subtitle }}</p>
                        
                        <ul class="space-y-4 mb-10">
                            <li
                                v-for="feature in plan.features"
                                :key="feature"
                                class="flex items-center gap-3 text-sm font-bold"
                                :class="plan.highlighted ? 'text-slate-200' : 'text-slate-700'"
                            >
                                <svg class="h-5 w-5 flex-shrink-0" :class="plan.highlighted ? 'text-teal-400' : 'text-teal-500'" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/>
                                </svg>
                                {{ feature }}
                            </li>
                        </ul>
                        
                        <Link
                            :href="canRegister ? '/register' : '/login'"
                            class="mt-auto inline-flex h-14 w-full items-center justify-center rounded-2xl px-6 text-[13px] font-extrabold uppercase tracking-[0.15em] transition-all active:scale-95"
                            :class="plan.highlighted ? 'bg-teal-500 text-slate-950 hover:bg-teal-400 hover:scale-105 shadow-[0_0_20px_theme(colors.teal.500/40)]' : 'bg-slate-100 text-slate-900 hover:bg-slate-200 hover:scale-105'"
                        >
                            {{ plan.ctaLabel }}
                        </Link>
                    </article>
                </div>
            </div>
        </MotionSection>

        <!-- Use Cases Section -->
        <MotionSection class="bg-gray-50 py-24 pb-32">
            <div class="mx-auto w-full max-w-[1440px] px-6 md:px-12 grid gap-16 lg:grid-cols-12">
                <div class="lg:col-span-5 lg:sticky lg:top-32 h-fit">
                    <h2 class="text-4xl sm:text-5xl font-extrabold tracking-tighter text-slate-900 leading-[1.05]">
                        Qual plano combina com  a sua <span class="text-teal-500 font-serif italic">vibe?</span>
                    </h2>
                    <p class="mt-6 text-lg text-slate-500 font-medium leading-relaxed max-w-sm">
                        Os planos foram desenhados para a sua fase lógica e financeira. Não importa por onde comece, a base de dados evolui com você.
                    </p>
                </div>

                <div class="lg:col-span-7 flex flex-col gap-8">
                    <article
                        v-for="item in planShowcase"
                        :key="item.title"
                        class="group overflow-hidden rounded-[2rem] border border-slate-200 bg-white grid sm:grid-cols-2 hover:shadow-xl transition-all duration-300"
                    >
                        <div class="relative h-48 sm:h-full overflow-hidden">
                            <img
                                :src="item.image"
                                :alt="item.title"
                                class="absolute inset-0 h-full w-full object-cover transition duration-700 group-hover:scale-110 filter saturate-50 group-hover:saturate-100"
                                loading="lazy"
                            />
                            <div class="absolute inset-0 bg-gradient-to-t from-slate-900/60 to-transparent sm:hidden"></div>
                            <span class="absolute left-6 top-6 rounded-full bg-white/95 px-4 py-1.5 text-[10px] font-extrabold uppercase tracking-[0.15em] text-slate-900 shadow-sm backdrop-blur-sm">{{ item.title }}</span>
                        </div>
                        <div class="p-8 md:p-10 flex flex-col justify-center">
                            <p class="text-[11px] font-bold uppercase tracking-[0.15em] text-teal-600 mb-2">{{ item.subtitle }}</p>
                            <p class="text-base font-medium leading-relaxed text-slate-600">{{ item.description }}</p>
                        </div>
                    </article>
                </div>
            </div>
        </MotionSection>

        <!-- Comparation Table Section -->
        <MotionSection class="bg-white py-24 border-y border-slate-100">
             <div class="mx-auto w-full max-w-[1440px] px-6 md:px-12 flex flex-col items-center">
                <div class="text-center mb-16">
                     <p class="text-[11px] font-bold uppercase tracking-[0.2em] text-slate-400 mb-4 inline-block bg-slate-50 px-4 py-2 border border-slate-100 rounded-lg">Papo Reto</p>
                     <h2 class="text-3xl sm:text-4xl font-extrabold tracking-tighter text-slate-900">Comparativo no detalhe</h2>
                </div>
                
                <div class="w-full overflow-x-auto pb-4">
                    <table class="w-full text-sm">
                        <thead>
                            <tr class="border-b-2 border-slate-950 text-left text-[11px] font-extrabold uppercase tracking-[0.15em] text-slate-400">
                                <th class="pb-6 pr-4 pl-4 w-1/4">Funcionalidade</th>
                                <th class="pb-6 pr-4 w-1/4">Essencial</th>
                                <th class="pb-6 pr-4 w-1/4 text-teal-600">Pro</th>
                                <th class="pb-6 pr-4 w-1/4">Visionário</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr v-for="feature in pricingFeatureComparisons" :key="feature.name" class="border-b border-slate-100 hover:bg-slate-50 transition-colors">
                                <td class="py-5 pr-4 pl-4 font-bold text-slate-700">{{ feature.name }}</td>
                                <td class="py-5 pr-4 text-slate-500 font-medium">{{ feature.status[0] }}</td>
                                <td class="py-5 pr-4 text-slate-900 font-bold bg-teal-50/30">{{ feature.status[1] }}</td>
                                <td class="py-5 pr-4 text-slate-500 font-medium">{{ feature.status[2] }}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <div class="mt-16 flex flex-wrap justify-center gap-4">
                    <span
                        v-for="item in guarantees"
                        :key="item"
                        class="inline-flex items-center gap-2 rounded-xl border border-teal-100 bg-teal-50 px-5 py-3 text-[11px] font-extrabold uppercase tracking-[0.15em] text-teal-800"
                    >
                        <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                        {{ item }}
                    </span>
                </div>
            </div>
        </MotionSection>

        <!-- FAQ Section -->
        <MotionSection class="relative overflow-hidden bg-slate-950 py-32 text-white">
            <div class="absolute inset-0 opacity-[0.02] mix-blend-overlay pointer-events-none" style="background-image: url('data:image/svg+xml,%3Csvg viewBox=%220 0 200 200%22 xmlns=%22http://www.w3.org/2000/svg%22%3E%3Cfilter id=%22noiseFilter%22%3E%3CfeTurbulence type=%22fractalNoise%22 baseFrequency=%220.8%22 numOctaves=%224%22 stitchTiles=%22stitch%22/%3E%3C/filter%3E%3Crect width=%22100%25%22 height=%22100%25%22 filter=%22url(%23noiseFilter)%22/%3E%3C/svg%3E');"></div>
            <div class="absolute right-10 top-0 h-96 w-96 rounded-full bg-teal-500/10 blur-[100px]"></div>
            
            <div class="mx-auto grid w-full max-w-[1440px] gap-16 px-6 lg:grid-cols-12 md:px-12 relative z-10">
                <div class="lg:col-span-4 lg:sticky lg:top-32 h-fit">
                    <p class="inline-flex items-center space-x-2 text-[10px] font-bold uppercase tracking-[0.2em] text-teal-400 mb-4 bg-slate-800 px-3 py-1.5 rounded-lg border border-slate-700">FAQ</p>
                    <h2 class="text-4xl sm:text-5xl font-extrabold tracking-tighter text-white leading-[1.05]">
                        Dúvidas na<br>hora de assinar?
                    </h2>
                    <p class="mt-6 text-lg text-slate-400 font-medium leading-relaxed">
                        A real, sem curva. Tudo que a galera mais pergunta antes de fechar com a gente.
                    </p>
                </div>
                
                <div class="lg:col-span-8 flex flex-col gap-4">
                    <article
                        v-for="(faq, index) in billingFaq"
                        :key="faq.question"
                        class="border border-white/10 bg-white/5 rounded-2xl overflow-hidden transition-all duration-300"
                        :class="openFaqIndex === index ? 'bg-white/10 ring-1 ring-teal-500/30' : 'hover:bg-white/10'"
                    >
                        <button
                            type="button"
                            class="flex w-full items-center justify-between gap-5 p-6 md:p-8 text-left outline-none"
                            @click="openFaqIndex = openFaqIndex === index ? null : index"
                        >
                            <h3 class="text-lg md:text-xl font-bold tracking-tight pr-8" :class="openFaqIndex === index ? 'text-teal-300' : 'text-slate-200'">{{ faq.question }}</h3>
                            <div 
                                class="flex-shrink-0 flex items-center justify-center w-8 h-8 rounded-full border border-white/20 transition-transform duration-300"
                                :class="openFaqIndex === index ? 'rotate-180 bg-teal-500/20 border-teal-500/30' : ''"
                            >
                                <svg class="w-4 h-4" :class="openFaqIndex === index ? 'text-teal-300' : 'text-white'" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"/>
                                </svg>
                            </div>
                        </button>
                        <div 
                            class="grid transition-all duration-300 ease-in-out"
                            :class="openFaqIndex === index ? 'grid-rows-[1fr] opacity-100' : 'grid-rows-[0fr] opacity-0'"
                        >
                            <div class="overflow-hidden">
                                <p class="px-6 md:px-8 pb-6 md:pb-8 text-base leading-relaxed text-slate-300 font-medium">
                                    {{ faq.answer }}
                                </p>
                            </div>
                        </div>
                    </article>
                </div>
            </div>
        </MotionSection>
    </SiteLayout>
</template>

<style scoped>
h1, h2, h3 {
    font-feature-settings: "salt" on, "ss01" on;
}
</style>
