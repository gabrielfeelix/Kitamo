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
        answer: 'Sim. O Essencial nunca cobra e entrega visão mensal pura.',
    },
    {
        question: 'Como faço upgrade para o Visionário?',
        answer: 'Você pode subir a qualquer momento se achou que precisa projetar mais os seus próximos 12 meses.',
    },
    {
        question: 'O Kitamo conecta na minha conta bancária?',
        answer: 'Não. O Kitamo não usa Open Finance e não conecta aos seus bancos. O controle é manual para manter previsibilidade e consistência.',
    }
];

const openFaqIndex = ref<number | null>(null);

</script>

<template>
    <Head title="Preços | Kitamo">
        <meta name="description" content="Planos da Kitamo com estrutura clara por necessidade de controle." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        
        <section class="max-w-[1400px] mx-auto px-6 py-24 md:py-32">
            <div class="text-center max-w-2xl mx-auto mb-16">
                <p class="text-[11px] font-bold uppercase tracking-[0.25em] text-slate-500 mb-6">Investimento de longo prazo</p>
                <h1 class="text-5xl md:text-[5.5rem] leading-[0.9] font-medium tracking-tight mb-8">O plano se paga em <span class="text-emerald-500 italic font-serif">uma assinatura</span> descoberta.</h1>
                <p class="text-xl text-slate-600 font-medium">Você escolhe seu nível de antecipação. Sem surpresas ou taxas escondidas no meio do caminho.</p>
            </div>

            <!-- Mobile View: Stacked Cards (Hidden on md and up) -->
            <div class="grid gap-8 md:hidden">
                <!-- Essencial Card -->
                <div class="bg-white rounded-[2rem] p-8 border border-slate-200">
                     <h3 class="text-3xl font-medium text-slate-900">{{ pricingPlans[0].name }}</h3>
                     <p class="text-sm font-bold mt-2 text-slate-500">R$ {{ pricingPlans[0].monthly }} <span class="text-xs font-normal">/mês</span></p>
                     <p class="text-sm text-slate-500 mt-4 leading-relaxed font-medium">{{ pricingPlans[0].subtitle }}</p>
                     
                     <div class="mt-8 space-y-4">
                         <div v-for="(feature, idx) in pricingFeatureComparisons" :key="idx" class="flex justify-between items-center text-sm border-b border-slate-50 pb-3">
                             <span class="text-slate-600">{{ feature.name }}</span>
                             <span class="font-bold text-slate-900">
                                 <span v-if="feature.status[0] === 'Sim'" class="text-emerald-500">✓</span>
                                 <span v-else-if="feature.status[0] === 'Não'" class="text-slate-300">—</span>
                                 <span v-else>{{ feature.status[0] }}</span>
                             </span>
                         </div>
                     </div>
                     <Link :href="canRegister ? '/register' : '/login'" class="w-full inline-flex justify-center py-4 mt-8 rounded-full border border-slate-200 text-xs font-bold uppercase tracking-widest text-slate-600 hover:border-slate-950 transition-colors">Testar</Link>
                </div>

                <!-- Pro Card -->
                <div class="bg-slate-950 text-white rounded-[2rem] p-8 border border-slate-800 relative shadow-2xl">
                     <span class="absolute -top-4 left-1/2 -translate-x-1/2 text-[10px] font-bold uppercase tracking-widest text-emerald-950 bg-emerald-400 px-3 py-1 rounded-full">Recomendado</span>
                     <h3 class="text-4xl font-medium">{{ pricingPlans[1].name }}</h3>
                     <p class="text-sm font-bold mt-2 text-emerald-400">R$ {{ pricingPlans[1].monthly }} <span class="text-xs font-normal text-emerald-400/70">/mês</span></p>
                     <p class="text-sm text-slate-400 mt-4 leading-relaxed font-medium">{{ pricingPlans[1].subtitle }}</p>
                     
                     <div class="mt-8 space-y-4">
                         <div v-for="(feature, idx) in pricingFeatureComparisons" :key="idx" class="flex justify-between items-center text-sm border-b border-white/5 pb-3">
                             <span class="text-slate-300">{{ feature.name }}</span>
                             <span class="font-bold text-white">
                                 <span v-if="feature.status[1] === 'Sim'" class="text-emerald-400">✓</span>
                                 <span v-else-if="feature.status[1] === 'Não'" class="text-slate-600">—</span>
                                 <span v-else>{{ feature.status[1] }}</span>
                             </span>
                         </div>
                     </div>
                     <Link :href="canRegister ? '/register' : '/login'" class="w-full inline-flex justify-center py-4 mt-8 rounded-full bg-emerald-500 text-emerald-950 text-xs font-bold uppercase tracking-widest hover:bg-emerald-400 transition-colors">Assinar</Link>
                </div>

                <!-- Visionario Card -->
                <div class="bg-white rounded-[2rem] p-8 border border-amber-200 relative overflow-hidden">
                     <div class="absolute top-0 right-0 w-32 h-32 bg-amber-400/20 blur-3xl rounded-full"></div>
                     <h3 class="text-3xl font-medium text-slate-900">{{ pricingPlans[2].name }}</h3>
                     <p class="text-sm font-bold mt-2 text-amber-600">R$ {{ pricingPlans[2].monthly }} <span class="text-xs font-normal opacity-70">/mês</span></p>
                     <p class="text-sm text-slate-500 mt-4 leading-relaxed font-medium">{{ pricingPlans[2].subtitle }}</p>
                     
                     <div class="mt-8 space-y-4 relative z-10">
                         <div v-for="(feature, idx) in pricingFeatureComparisons" :key="idx" class="flex justify-between items-center text-sm border-b border-slate-50 pb-3">
                             <span class="text-slate-600">{{ feature.name }}</span>
                             <span class="font-bold text-amber-700">
                                 <span v-if="feature.status[2] === 'Sim'">✓</span>
                                 <span v-else-if="feature.status[2] === 'Não'" class="text-slate-300">—</span>
                                 <span v-else>{{ feature.status[2] }}</span>
                             </span>
                         </div>
                     </div>
                     <Link :href="canRegister ? '/register' : '/login'" class="w-full inline-flex justify-center py-4 mt-8 rounded-full border border-amber-200 text-xs font-bold uppercase tracking-widest text-amber-700 hover:border-amber-400 hover:text-amber-800 transition-colors bg-amber-50 relative z-10">Assinar Elite</Link>
                </div>
            </div>

            <!-- Desktop View: Massive Pricing Table Comparison Instead of Cards (Hidden on mobile) -->
            <div class="hidden md:block bg-white rounded-[3rem] p-12 shadow-[0_40px_100px_rgba(2,6,23,0.05)] border border-slate-200 relative overflow-hidden">
                <div class="absolute top-0 right-0 w-[500px] h-[500px] bg-[#fbbf24]/5 blur-[120px] rounded-full"></div>

                <div class="w-full">
                    <table class="w-full relative z-10">
                        <thead>
                            <tr class="border-b-2 border-slate-100">
                                <th class="text-left w-1/3 pb-8 pr-4 text-xs font-bold uppercase tracking-[0.2em] text-slate-400">Funcionalidade Central</th>
                                <th class="w-[22%] pb-8 px-4 text-center">
                                    <h3 class="text-3xl font-medium text-slate-900">{{ pricingPlans[0].name }}</h3>
                                    <p class="text-sm font-bold mt-2 text-slate-500">R$ {{ pricingPlans[0].monthly }} <span class="text-xs font-normal">/mês</span></p>
                                    <Link :href="canRegister ? '/register' : '/login'" class="w-full inline-flex justify-center py-4 mt-6 rounded-full border border-slate-200 text-xs font-bold uppercase tracking-widest text-slate-600 hover:border-slate-950 transition-colors">Testar</Link>
                                </th>
                                <th class="w-[22%] pb-8 px-4 text-center relative">
                                    <span class="absolute -top-6 left-1/2 -translate-x-1/2 text-[10px] font-bold uppercase tracking-widest text-emerald-600 bg-emerald-100 px-3 py-1 rounded-full">Recomendado</span>
                                    <h3 class="text-4xl font-medium text-slate-900">{{ pricingPlans[1].name }}</h3>
                                    <p class="text-sm font-bold mt-2 text-emerald-600">R$ {{ pricingPlans[1].monthly }} <span class="text-xs font-normal">/mês</span></p>
                                    <Link :href="canRegister ? '/register' : '/login'" class="w-full inline-flex justify-center py-4 mt-6 rounded-full bg-slate-950 text-white text-xs font-bold uppercase tracking-widest shadow-xl hover:bg-emerald-500 hover:text-slate-950 transition-colors">Assinar</Link>
                                </th>
                                <th class="w-[22%] pb-8 px-4 text-center">
                                    <h3 class="text-3xl font-medium text-slate-900">{{ pricingPlans[2].name }}</h3>
                                    <p class="text-sm font-bold mt-2 text-amber-600">R$ {{ pricingPlans[2].monthly }} <span class="text-xs font-normal">/mês</span></p>
                                    <Link :href="canRegister ? '/register' : '/login'" class="w-full inline-flex justify-center py-4 mt-6 rounded-full border border-slate-200 text-xs font-bold uppercase tracking-widest text-slate-600 hover:border-amber-500 hover:text-amber-600 transition-colors">Assinar Elite</Link>
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr v-for="(feature, idx) in pricingFeatureComparisons" :key="idx" class="border-b border-slate-100/50 hover:bg-slate-50 transition-colors">
                                <td class="py-6 pr-4 text-slate-900 font-medium text-base">{{ feature.name }}</td>
                                <td class="py-6 px-4 text-center text-slate-500 font-bold text-base" v-for="(status, statusIdx) in feature.status" :key="statusIdx" :class="{'text-emerald-500': status === 'Sim', 'text-slate-300': status === 'Não'}">
                                    <span v-if="status === 'Sim'">✓</span>
                                    <span v-else-if="status === 'Não'">—</span>
                                    <span v-else>{{ status }}</span>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

        </section>

        <!-- FAQs (Asymmetric Block) -->
        <section class="bg-black py-24 text-white">
            <div class="max-w-[1200px] mx-auto px-6 grid md:grid-cols-2 gap-16">
                <div>
                     <h2 class="text-5xl font-medium tracking-tight mb-8">Últimas objeções,<br/> <span class="text-slate-500">dúvidas rápidas.</span></h2>
                     <p class="text-xl text-slate-400">Todo sistema de qualidade exige transparência. Saiba exatamente onde você está entrando.</p>
                </div>
                <!-- FAQ accordion -->
                <div class="space-y-4 pt-10 border-t border-slate-800 md:border-0 md:pt-0">
                     <div v-for="(faq, index) in billingFaq" :key="faq.question" class="border-b border-slate-800">
                         <button @click="openFaqIndex = openFaqIndex === index ? null : index" class="w-full text-left py-6 flex justify-between items-center group">
                             <h3 class="text-xl font-medium text-white group-hover:text-emerald-400 transition-colors pr-8">{{ faq.question }}</h3>
                             <span class="text-slate-600 text-2xl transition-transform duration-300" :class="{'rotate-45 text-emerald-400': openFaqIndex === index}">+</span>
                         </button>
                         <div v-show="openFaqIndex === index" class="pb-6 pr-8">
                             <p class="text-slate-500 leading-relaxed">{{ faq.answer }}</p>
                         </div>
                     </div>
                </div>
            </div>
        </section>

    </SiteLayout>
</template>
