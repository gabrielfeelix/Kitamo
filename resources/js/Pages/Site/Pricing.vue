<script setup lang="ts">
import { ref } from 'vue';
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';
import MotionSection from '@/Components/site/MotionSection.vue';
import { pricingPlans, pricingFeatureComparisons, type SiteFaqItem } from '@/types/site';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const billingFaq: SiteFaqItem[] = [
    {
        question: 'Existe plano gratuito pra sempre?',
        answer: 'Sim! O plano Essencial é gratuito e sempre será. Ele oferece visão de 30 dias à frente — ideal para começar a organizar suas finanças sem compromisso.',
    },
    {
        question: 'Posso mudar de ideia (e de plano) depois?',
        answer: 'Com certeza. Seu momento financeiro muda e o Kitamo acompanha. O upgrade ou downgrade é feito direto nas configurações, em poucos cliques.',
    },
    {
        question: 'Como cancelo um plano pago se eu não curtir?',
        answer: 'Sem botão escondido e sem ligação para telemarketing. Dois cliques nas configurações e você volta ao plano gratuito.',
    },
    {
        question: 'Aceita meu dezenove no PIX?',
        answer: 'Aceitamos PIX, Boleto Bancário e Cartão de Crédito. Você escolhe a melhor opção.',
    },
    {
        question: 'O Kitamo vai fuçar no meu banco limitando meu acesso?',
        answer: 'Nunca. Não utilizamos Open Finance invasivo. Seus dados ficam sob seu controle total — você decide o que entra na plataforma.',
    },
];

const openFaqIndex = ref<number | null>(0);

const planShowcase = [
    {
        title: 'Essencial',
        subtitle: 'Para organizar o primeiro mês',
        description: '30 dias de visão à frente. Chega de tomar susto quando a fatura fecha. Ideal para quem está começando a se organizar.',
        image: 'https://images.pexels.com/photos/3760263/pexels-photo-3760263.jpeg?auto=compress&cs=tinysrgb&w=900',
    },
    {
        title: 'Pro',
        subtitle: 'Para quem já mantém a rotina',
        description: 'Amplie a visão para 90 dias. Gerencie toda a casa com recorrências automáticas. Para quem já tem o hábito de organização.',
        image: 'https://images.pexels.com/photos/3183197/pexels-photo-3183197.jpeg?auto=compress&cs=tinysrgb&w=900',
    },
    {
        title: 'Visionário',
        subtitle: 'Para planejar o longo prazo',
        description: 'Projeção de até 5 anos. Quer saber quando dá para comprar o carro ou financiar o apartamento? Seu painel de controle está aqui.',
        image: 'https://images.pexels.com/photos/3727462/pexels-photo-3727462.jpeg?auto=compress&cs=tinysrgb&w=900',
    },
];

const guarantees = [
    { text: '7 dias incondicionais', icon: 'M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z', accent: 'teal' },
    { text: 'Cancelamento sem estresse', icon: 'M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15', accent: 'cyan' },
    { text: 'Controle de dados 100% seu', icon: 'M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z', accent: 'emerald' },
];
</script>

<template>
    <Head title="Preços da Ferramenta | Kitamo">
        <meta name="description" content="Planos flexíveis do Kitamo. Pague por quanto planejamento você precisa. Sem pegadinhas e letras miúdas." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <!-- Ultra Hero Section (Dark & Emotive) -->
        <MotionSection class="relative min-h-[80vh] w-full overflow-hidden bg-slate-950 text-white flex flex-col justify-center items-center py-32 border-b border-white/5">
            <template #background>
                <!-- Noise Overlay -->
                <div class="absolute inset-0 opacity-[0.02] mix-blend-overlay pointer-events-none" style="background-image: url('data:image/svg+xml,%3Csvg viewBox=%220 0 200 200%22 xmlns=%22http://www.w3.org/2000/svg%22%3E%3Cfilter id=%22noiseFilter%22%3E%3CfeTurbulence type=%22fractalNoise%22 baseFrequency=%220.8%22 numOctaves=%224%22 stitchTiles=%22stitch%22/%3E%3C/filter%3E%3Crect width=%22100%25%22 height=%22100%25%22 filter=%22url(%23noiseFilter)%22/%3E%3C/svg%3E');"></div>
                
                <div class="pointer-events-none absolute top-0 inset-x-0 h-[600px] bg-[radial-gradient(ellipse_at_top,_var(--tw-gradient-stops))] from-teal-900/40 via-slate-950 to-slate-950 opacity-80 blur-3xl"></div>
                
                <!-- Bottom decorative fade -->
                <div class="absolute bottom-0 inset-x-0 h-32 bg-gradient-to-t from-slate-50 to-transparent pointer-events-none z-0"></div>
            </template>
            
            <div class="relative z-10 mx-auto w-full max-w-[1440px] px-6 md:px-12 text-center flex flex-col items-center">
                <p class="inline-flex items-center space-x-2 text-[10px] sm:text-[11px] font-extrabold uppercase tracking-[0.25em] text-emerald-400 mb-8 px-5 py-2.5 rounded-full border border-emerald-500/20 bg-emerald-500/10 backdrop-blur-sm shadow-[0_0_20px_theme(colors.emerald.500/15)]">Transparência Total</p>
                <h1 class="text-6xl sm:text-7xl lg:text-[7rem] leading-[0.9] tracking-tighter text-slate-100 font-extrabold max-w-5xl mx-auto drop-shadow-2xl">
                    Planejamento no<br>
                    <span class="text-transparent bg-clip-text bg-gradient-to-r from-teal-400 to-emerald-400 font-serif italic pr-2">seu tamanho.</span>
                </h1>
                <p class="mt-10 text-xl sm:text-2xl leading-relaxed text-slate-400 font-medium max-w-3xl mx-auto">
                    Escolha a abrangência do seu radar financeiro. Comece de graça, evolua conforme sua necessidade. Sem pegadinhas.
                </p>

                <div class="mt-14 inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/5 p-2 backdrop-blur-md shadow-2xl">
                    <span class="rounded-full bg-teal-500 px-8 py-3 text-[12px] font-extrabold uppercase tracking-widest text-slate-950 shadow-[0_0_15px_theme(colors.teal.500/50)] transition-all hover:bg-teal-400 cursor-pointer">Mensal</span>
                    <span class="px-8 py-3 text-[12px] font-extrabold uppercase tracking-widest text-slate-500/80 cursor-not-allowed hidden sm:inline-block">Anual (Em breve)</span>
                </div>
            </div>
            
        </MotionSection>

        <!-- Dynamic Pricing Cards Grid -->
        <MotionSection class="bg-slate-50 py-20 pb-40 relative">
            <template #background>
                <div class="absolute top-0 inset-x-0 h-[200px] bg-slate-50 -mt-[200px] z-0"></div>
            </template>
            
            <div class="mx-auto w-full max-w-[1440px] px-6 md:px-12 relative -mt-32 sm:-mt-24 lg:-mt-16 z-20">
                <div class="grid lg:grid-cols-3 gap-6 xl:gap-10 items-end">
                    
                    <!-- Essential Plan -->
                    <article class="bg-white rounded-[2.5rem] p-10 lg:p-12 border border-slate-200 shadow-xl shadow-slate-200/50 hover:shadow-2xl hover:-translate-y-2 transition-all duration-500 flex flex-col items-start min-h-[500px]">
                        <p class="text-[12px] font-extrabold uppercase tracking-[0.2em] text-slate-400 mb-6 bg-slate-100 px-4 py-1.5 rounded-lg border border-slate-200">Básico e Limpo</p>
                        <h3 class="text-3xl font-extrabold text-slate-900 mb-2">{{ pricingPlans[0].name }}</h3>
                        <p class="text-sm text-slate-500 font-medium leading-relaxed mb-8 min-h-[40px]">{{ pricingPlans[0].subtitle }}</p>
                        
                        <div class="mb-10 flex items-start gap-1 text-slate-900">
                            <span class="text-2xl font-bold mt-2 text-slate-400">R$</span>
                            <span class="text-[4.5rem] font-extrabold tracking-tighter leading-none">{{ pricingPlans[0].monthly }}</span>
                            <span class="text-lg font-bold text-slate-400 self-end mb-2">/mês</span>
                        </div>
                        
                        <ul class="space-y-5 w-full mb-12">
                            <li v-for="feature in pricingPlans[0].features" :key="feature" class="flex items-center gap-4 text-base font-bold text-slate-700">
                                <span class="flex-shrink-0 w-6 h-6 rounded-full bg-slate-100 text-slate-400 flex items-center justify-center">
                                    <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/></svg>
                                </span>
                                {{ feature }}
                            </li>
                        </ul>
                        
                        <Link :href="canRegister ? '/register' : '/login'" class="mt-auto w-full h-16 rounded-2xl border-2 border-slate-200 bg-white flex items-center justify-center text-[13px] font-extrabold uppercase tracking-[0.2em] text-slate-600 hover:text-slate-900 hover:border-slate-300 transition-colors">
                            {{ pricingPlans[0].ctaLabel }}
                        </Link>
                    </article>

                    <!-- Pro Plan (Hero Highlighted) -->
                    <article class="bg-slate-950 rounded-[3rem] p-10 lg:p-14 border border-slate-900 shadow-2xl shadow-teal-900/40 relative z-30 flex flex-col items-start min-h-[600px] transform lg:scale-105">
                        <div class="absolute inset-0 bg-gradient-to-br from-teal-500/10 to-transparent rounded-[3rem] pointer-events-none"></div>
                        
                        <!-- Floating Highlight Tag -->
                        <div class="absolute -top-5 left-1/2 -translate-x-1/2 bg-teal-500 text-slate-950 px-6 py-2 rounded-full text-[11px] font-extrabold uppercase tracking-[0.2em] shadow-[0_0_30px_theme(colors.teal.500/60)] whitespace-nowrap">
                            A Escolha da Galera
                        </div>

                        <p class="text-[12px] font-extrabold uppercase tracking-[0.2em] text-teal-400 mb-6 bg-teal-950 px-4 py-1.5 rounded-lg border border-teal-800">Custo x Benefício</p>
                        <h3 class="text-4xl font-extrabold text-white mb-2">{{ pricingPlans[1].name }}</h3>
                        <p class="text-sm text-slate-400 font-medium leading-relaxed mb-8 min-h-[40px]">{{ pricingPlans[1].subtitle }}</p>
                        
                        <div class="mb-10 flex items-start gap-1 text-white">
                            <span class="text-2xl font-bold mt-2 text-teal-500">R$</span>
                            <span class="text-[5.5rem] font-extrabold tracking-tighter leading-none">{{ pricingPlans[1].monthly }}</span>
                            <span class="text-lg font-bold text-slate-500 self-end mb-3">/mês</span>
                        </div>
                        
                        <ul class="space-y-6 w-full mb-12">
                            <li v-for="feature in pricingPlans[1].features" :key="feature" class="flex items-center gap-4 text-base font-bold text-slate-200">
                                <span class="flex-shrink-0 w-8 h-8 rounded-full bg-teal-500/20 text-teal-400 flex items-center justify-center">
                                    <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/></svg>
                                </span>
                                {{ feature }}
                            </li>
                        </ul>
                        
                        <Link :href="canRegister ? '/register' : '/login'" class="mt-auto w-full h-16 rounded-2xl bg-teal-500 shadow-[0_0_25px_theme(colors.teal.500/40)] flex items-center justify-center text-[13px] font-extrabold uppercase tracking-[0.2em] text-slate-950 hover:bg-teal-400 hover:scale-[1.03] transition-all">
                            {{ pricingPlans[1].ctaLabel }}
                        </Link>
                    </article>

                    <!-- Visionary Plan -->
                    <article class="bg-white rounded-[2.5rem] p-10 lg:p-12 border border-slate-200 shadow-xl shadow-slate-200/50 hover:shadow-2xl hover:-translate-y-2 transition-all duration-500 flex flex-col items-start min-h-[500px]">
                        <p class="text-[12px] font-extrabold uppercase tracking-[0.2em] text-amber-500 mb-6 bg-amber-50 px-4 py-1.5 rounded-lg border border-amber-100">Visão Longo Prazo</p>
                        <h3 class="text-3xl font-extrabold text-slate-900 mb-2">{{ pricingPlans[2].name }}</h3>
                        <p class="text-sm text-slate-500 font-medium leading-relaxed mb-8 min-h-[40px]">{{ pricingPlans[2].subtitle }}</p>
                        
                        <div class="mb-10 flex items-start gap-1 text-slate-900">
                            <span class="text-2xl font-bold mt-2 text-slate-400">R$</span>
                            <span class="text-[4.5rem] font-extrabold tracking-tighter leading-none">{{ pricingPlans[2].monthly }}</span>
                            <span class="text-lg font-bold text-slate-400 self-end mb-2">/mês</span>
                        </div>
                        
                        <ul class="space-y-5 w-full mb-12">
                            <li v-for="feature in pricingPlans[2].features" :key="feature" class="flex items-center gap-4 text-base font-bold text-slate-700">
                                <span class="flex-shrink-0 w-6 h-6 rounded-full bg-slate-100 text-amber-500 flex items-center justify-center">
                                    <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/></svg>
                                </span>
                                {{ feature }}
                            </li>
                        </ul>
                        
                        <Link :href="canRegister ? '/register' : '/login'" class="mt-auto w-full h-16 rounded-2xl border-2 border-slate-200 bg-white flex items-center justify-center text-[13px] font-extrabold uppercase tracking-[0.2em] text-slate-600 hover:text-slate-900 hover:border-slate-300 transition-colors">
                            {{ pricingPlans[2].ctaLabel }}
                        </Link>
                    </article>
                </div>

                <!-- Trust Guarantees row below pricing cards -->
                <div class="mt-20 flex flex-wrap items-center justify-center gap-6 md:gap-8 w-full max-w-4xl mx-auto border-t border-slate-200 pt-16">
                    <div
                        v-for="item in guarantees"
                        :key="item.text"
                        class="flex items-center gap-4 bg-white rounded-2xl border border-slate-200 px-6 py-5 shadow-sm hover:shadow-md hover:-translate-y-0.5 transition-all duration-300"
                    >
                        <span class="flex-shrink-0 flex items-center justify-center w-11 h-11 rounded-xl" :class="`bg-${item.accent}-50`">
                            <svg class="h-5 w-5" :class="`text-${item.accent}-500`" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" :d="item.icon"/></svg>
                        </span>
                        <span class="font-extrabold text-slate-700 text-[13px] uppercase tracking-widest">{{ item.text }}</span>
                    </div>
                </div>
            </div>
        </MotionSection>

        <!-- Staggered Use Cases (Massive Imagery Layout) -->
        <MotionSection class="bg-slate-950 py-32 rounded-t-[4rem] text-white overflow-hidden relative border-t border-slate-800 z-10">
            <template #background>
                <div class="absolute inset-0 opacity-[0.03] mix-blend-overlay pointer-events-none" style="background-image: url('data:image/svg+xml,%3Csvg viewBox=%220 0 200 200%22 xmlns=%22http://www.w3.org/2000/svg%22%3E%3Cfilter id=%22noiseFilter%22%3E%3CfeTurbulence type=%22fractalNoise%22 baseFrequency=%220.8%22 numOctaves=%224%22 stitchTiles=%22stitch%22/%3E%3C/filter%3E%3Crect width=%22100%25%22 height=%22100%25%22 filter=%22url(%23noiseFilter)%22/%3E%3C/svg%3E');"></div>
                 
                 <!-- Glowing orb background effect -->
                 <div class="absolute top-0 right-0 w-[800px] h-[800px] bg-[radial-gradient(circle_at_center,rgba(20,184,166,0.15)_0,transparent_60%)] pointer-events-none"></div>
            </template>

            <div class="mx-auto w-full max-w-[1440px] px-6 md:px-12 relative z-10 flex flex-col gap-24">
                <div class="text-center mb-6">
                    <h2 class="text-4xl sm:text-5xl lg:text-7xl font-extrabold tracking-tighter text-white leading-[1.05] max-w-4xl mx-auto">
                        Identifique onde sua vida<br>tá pegando <span class="text-teal-400 font-serif italic pr-2">fogo financeiro.</span>
                    </h2>
                    <p class="mt-8 text-xl text-slate-400 font-medium leading-relaxed max-w-2xl mx-auto">
                         Nenhum usuário começa querendo organizar 5 anos de uma vez. Encontre seu estágio atual:
                    </p>
                </div>

                <div class="grid lg:grid-cols-3 gap-6 md:gap-10">
                    <div 
                        v-for="(item, idx) in planShowcase" 
                        :key="item.title"
                        class="group bg-slate-900 rounded-[2.5rem] border border-slate-800 overflow-hidden flex flex-col transition-all duration-500 hover:border-slate-700 hover:shadow-2xl hover:-translate-y-2 relative"
                    >
                         <!-- Dynamic Glow per card index logic -->
                        <div class="absolute inset-x-0 bottom-0 h-1/2 bg-gradient-to-t" :class="idx === 1 ? 'from-teal-900/40' : (idx === 2 ? 'from-amber-900/30' : 'from-slate-800/40')"></div>

                        <div class="h-64 sm:h-80 relative overflow-hidden">
                            <img
                                :src="item.image"
                                :alt="item.title"
                                class="absolute inset-0 w-full h-full object-cover filter saturate-50 group-hover:saturate-110 group-hover:scale-105 transition-all duration-700"
                                loading="lazy"
                            />
                            <div class="absolute inset-0 bg-slate-950/20 group-hover:bg-transparent transition-colors"></div>
                            
                            <div class="absolute top-6 left-6 bg-slate-950/70 backdrop-blur-md px-4 py-2 rounded-xl border border-white/10 text-white font-extrabold text-[10px] uppercase tracking-[0.2em] shadow-lg">
                                Base: {{ item.title }}
                            </div>
                        </div>

                        <div class="p-8 md:p-10 relative z-10 flex flex-col flex-grow">
                            <h3 class="text-2xl font-extrabold text-white mb-3 tracking-tight group-hover:text-teal-300 transition-colors">{{ item.subtitle }}</h3>
                            <p class="text-slate-400 font-medium leading-relaxed">{{ item.description }}</p>
                        </div>
                    </div>
                </div>
            </div>
        </MotionSection>

        <!-- Feature Detailed Comparison -->
        <MotionSection class="bg-white py-32 border-b border-slate-200">
             <div class="mx-auto w-full max-w-[1200px] px-6 md:px-12 flex flex-col">
                <div class="text-center mb-20">
                     <p class="text-[12px] font-extrabold uppercase tracking-[0.2em] text-emerald-600 mb-6 inline-block bg-emerald-50 px-5 py-2.5 border border-emerald-100 rounded-full shadow-sm">Detalhe por detalhe</p>
                     <h2 class="text-4xl sm:text-5xl lg:text-6xl font-extrabold tracking-tighter text-slate-900">A balança de<br><span class="font-serif italic text-teal-600 pr-2">funcionalidades.</span></h2>
                </div>
                
                <div class="w-full bg-slate-50 border border-slate-200 rounded-[3rem] p-6 sm:p-10 md:p-14 overflow-hidden shadow-xl">
                    <div class="overflow-x-auto">
                        <table class="w-full text-base min-w-[700px]">
                            <thead>
                                <tr class="text-left text-[12px] font-extrabold uppercase tracking-[0.2em] text-slate-400">
                                    <th class="pb-8 pr-4 w-[40%] text-slate-900">Funcionalidade Core</th>
                                    <th class="pb-8 pr-4 w-[20%] text-slate-400">Essencial</th>
                                    <th class="pb-8 pr-4 px-4 w-[20%] text-teal-600 bg-teal-50/50 rounded-t-2xl">Pro</th>
                                    <th class="pb-8 pl-4 w-[20%] text-amber-500">Visionário</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-slate-100/80">
                                <tr v-for="(feature, index) in pricingFeatureComparisons" :key="feature.name" class="group hover:bg-white transition-colors">
                                    <td class="py-6 pr-4 font-bold text-slate-800">{{ feature.name }}</td>
                                    
                                    <td class="py-6 pr-4 text-slate-500 font-medium">
                                        <span v-if="feature.status[0] !== '-' && feature.status[0] !== 'Ilimitado'">{{ feature.status[0] }}</span>
                                        <span v-else-if="feature.status[0] === 'Ilimitado'" class="text-slate-800 font-bold px-3 py-1 bg-slate-100 rounded-md text-[11px] uppercase tracking-wider">Livre</span>
                                        <svg v-else class="h-5 w-5 text-slate-300" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M20 12H4"/></svg>
                                    </td>
                                    
                                    <td class="py-6 px-4 bg-teal-50/50 text-slate-900 font-bold group-hover:bg-teal-50 transition-colors" :class="index === pricingFeatureComparisons.length - 1 ? 'rounded-b-2xl' : ''">
                                        <span v-if="feature.status[1] !== '-' && feature.status[1] !== 'Ilimitado'">{{ feature.status[1] }}</span>
                                        <span v-else-if="feature.status[1] === 'Ilimitado'" class="text-teal-800 font-extrabold px-3 py-1 bg-teal-100 rounded-md text-[11px] uppercase tracking-wider">Livre</span>
                                        <svg v-else class="h-5 w-5 text-slate-300" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M20 12H4"/></svg>
                                    </td>
                                    
                                    <td class="py-6 pl-4 text-slate-500 font-medium">
                                        <span v-if="feature.status[2] !== '-' && feature.status[2] !== 'Ilimitado'">{{ feature.status[2] }}</span>
                                        <span v-else-if="feature.status[2] === 'Ilimitado'" class="text-amber-700 font-bold px-3 py-1 bg-amber-50 rounded-md text-[11px] uppercase tracking-wider border border-amber-100">Livre</span>
                                        <svg v-else class="h-5 w-5 text-slate-300" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M20 12H4"/></svg>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </MotionSection>

        <!-- Dynamic Broad FAQ Section (Replaces the sticky side layout) -->
        <MotionSection class="bg-slate-50 py-32">
            <div class="mx-auto flex flex-col items-center w-full max-w-[1000px] px-6 md:px-12">
                <div class="text-center mb-16">
                    <h2 class="text-4xl sm:text-5xl lg:text-6xl font-extrabold tracking-tighter text-slate-900 leading-[1.05]">
                        Tira-Teima.
                    </h2>
                    <p class="mt-6 text-xl text-slate-500 font-medium leading-relaxed max-w-2xl mx-auto">
                        As perguntas mais comuns sobre planos, pagamentos e privacidade.
                    </p>
                </div>
                
                <div class="w-full space-y-4">
                    <article
                        v-for="(faq, index) in billingFaq"
                        :key="faq.question"
                        class="border border-slate-200 bg-white rounded-3xl overflow-hidden transition-all duration-300 shadow-sm"
                        :class="openFaqIndex === index ? 'ring-2 ring-teal-500 shadow-lg scale-[1.01]' : 'hover:border-slate-300 hover:shadow-md'"
                    >
                        <button
                            type="button"
                            class="flex w-full items-center justify-between gap-6 p-6 sm:p-8 text-left outline-none"
                            @click="openFaqIndex = openFaqIndex === index ? null : index"
                        >
                            <h3 class="text-xl sm:text-2xl font-bold tracking-tight pr-4" :class="openFaqIndex === index ? 'text-teal-600' : 'text-slate-800'">{{ faq.question }}</h3>
                            <div 
                                class="flex-shrink-0 flex items-center justify-center w-12 h-12 rounded-2xl border transition-all duration-500"
                                :class="openFaqIndex === index ? 'rotate-180 bg-teal-500 border-teal-500 shadow-[0_0_15px_theme(colors.teal.500/30)]' : 'bg-slate-50 border-slate-200 text-slate-400 hover:bg-slate-100'"
                            >
                                <svg class="w-5 h-5 transition-colors" :class="openFaqIndex === index ? 'text-slate-950' : ''" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"/>
                                </svg>
                            </div>
                        </button>
                        <div 
                            class="grid transition-all duration-500 ease-in-out"
                            :class="openFaqIndex === index ? 'grid-rows-[1fr] opacity-100' : 'grid-rows-[0fr] opacity-0'"
                        >
                            <div class="overflow-hidden">
                                <p class="px-6 sm:px-8 pb-6 sm:pb-8 text-lg leading-relaxed text-slate-600 font-medium">
                                    {{ faq.answer }}
                                </p>
                            </div>
                        </div>
                    </article>
                </div>

                <div class="mt-16 bg-slate-900 rounded-[2.5rem] w-full p-10 flex flex-col sm:flex-row items-center justify-between gap-8 text-white shadow-xl">
                    <div>
                        <h4 class="text-2xl font-bold tracking-tight mb-2">Ainda na dúvida?</h4>
                        <p class="text-slate-400 font-medium">Mande uma mensagem no fale conosco. Respondemos pessoalmente.</p>
                    </div>
                    <Link
                        :href="route('site.contact')"
                        class="flex-shrink-0 inline-flex h-14 items-center justify-center rounded-2xl bg-white px-8 text-[12px] font-extrabold uppercase tracking-[0.15em] text-slate-900 transition-all hover:bg-teal-500 hover:scale-105"
                    >
                        Chamar Suporte
                    </Link>
                </div>
            </div>
        </MotionSection>
    </SiteLayout>
</template>

<style scoped>
h1, h2, h3, h4 {
    font-feature-settings: "salt" on, "ss01" on;
}
</style>
