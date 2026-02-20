<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';
import { pricingPlans, type SiteFaqItem } from '@/types/site';

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
        question: 'E se o aplicativo quebrar minhas contas bancárias?',
        answer: 'Kitamo utiliza Open Finance no modo de "Só Leitura". Impossível movimentar 1 centavo da sua conta através daqui.',
    }
];

// Flat feature matrix
const featureComparisons = [
    { name: "Controle de Saldo ao Vivo", status: ["Sim", "Sim", "Sim"] },
    { name: "Lembrete de Vencimentos", status: ["Sim", "Sim", "Sim"] },
    { name: "Sincronização Bancária Open Finance", status: ["Apenas 2", "Ilimitado", "Ilimitado"] },
    { name: "Dias de Projeção Futura", status: ["Até dia 30.", "Trimestre", "Até 5 anos."] },
    { name: "Alerta de vazamento de assinaturas", status: ["Não", "Sim", "Sim"] },
    { name: "Gestor Dedicado no WhatsApp", status: ["Não", "Não", "Sim"] }
];

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

            <!-- Massive Pricing Table Comparison Instead of Cards -->
            <div class="bg-white rounded-[2rem] md:rounded-[3rem] py-8 md:p-12 shadow-[0_40px_100px_rgba(2,6,23,0.05)] border border-slate-200 relative overflow-hidden">
                <div class="absolute top-0 right-0 w-[300px] md:w-[500px] h-[300px] md:h-[500px] bg-[#fbbf24]/5 blur-[80px] md:blur-[120px] rounded-full"></div>

                <!-- Scroll Wrapper INSIDE the styled container -->
                <div class="w-full overflow-x-auto px-6 md:px-0 scrollbar-hide">
                    <table class="w-full min-w-[700px] md:min-w-[900px] relative z-10">
                        <thead>
                            <tr class="border-b-2 border-slate-100">
                                <th class="text-left w-1/3 pb-8 pr-4 text-[10px] md:text-xs font-bold uppercase tracking-[0.2em] text-slate-400">Funcionalidade Central</th>
                                <th class="w-[22%] pb-8 px-2 md:px-4 text-center">
                                    <h3 class="text-2xl md:text-3xl font-medium text-slate-900">Essencial</h3>
                                    <p class="text-[10px] md:text-sm font-bold mt-2 text-slate-500">R$ 0 <span class="text-[10px] md:text-xs font-normal">/mês</span></p>
                                    <Link :href="canRegister ? '/register' : '/login'" class="w-full inline-flex justify-center py-3 md:py-4 mt-4 md:mt-6 rounded-full border border-slate-200 text-[10px] md:text-xs font-bold uppercase tracking-widest text-slate-600 hover:border-slate-950 transition-colors">Testar</Link>
                                </th>
                                <th class="w-[22%] pb-8 px-2 md:px-4 text-center relative">
                                    <span class="absolute -top-4 md:-top-6 left-1/2 -translate-x-1/2 text-[8px] md:text-[10px] font-bold uppercase tracking-widest text-emerald-600 bg-emerald-100 px-2 flex items-center h-4 md:h-6 whitespace-nowrap md:py-1 rounded-full">Recomendado</span>
                                    <h3 class="text-3xl md:text-4xl font-medium text-slate-900">Pro</h3>
                                    <p class="text-[10px] md:text-sm font-bold mt-2 text-emerald-600">R$ 19 <span class="text-[10px] md:text-xs font-normal">/mês</span></p>
                                    <Link :href="canRegister ? '/register' : '/login'" class="w-full inline-flex justify-center py-3 md:py-4 mt-4 md:mt-6 rounded-full bg-slate-950 text-white text-[10px] md:text-xs font-bold uppercase tracking-widest shadow-xl hover:bg-emerald-500 hover:text-slate-950 transition-colors">Assinar</Link>
                                </th>
                                <th class="w-[22%] pb-8 px-2 md:px-4 text-center">
                                    <h3 class="text-2xl md:text-3xl font-medium text-slate-900">Visionário</h3>
                                    <p class="text-[10px] md:text-sm font-bold mt-2 text-amber-600">R$ 49 <span class="text-[10px] md:text-xs font-normal">/mês</span></p>
                                    <Link :href="canRegister ? '/register' : '/login'" class="w-full inline-flex justify-center py-3 md:py-4 mt-4 md:mt-6 rounded-full border border-slate-200 text-[10px] md:text-xs font-bold uppercase tracking-widest text-slate-600 hover:border-amber-500 hover:text-amber-600 transition-colors">Assinar Elite</Link>
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr v-for="(feature, idx) in featureComparisons" :key="idx" class="border-b border-slate-100/50 hover:bg-slate-50 transition-colors">
                                <td class="py-4 md:py-6 pr-4 text-slate-900 font-medium text-xs md:text-base">{{ feature.name }}</td>
                                <td class="py-4 md:py-6 px-2 md:px-4 text-center text-slate-500 font-bold text-xs md:text-base" v-for="(status, statusIdx) in feature.status" :key="statusIdx" :class="{'text-emerald-500': status === 'Sim', 'text-slate-300': status === 'Não'}">
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
                <!-- Mini FAQ accordion manual to respect dark theme nicely -->
                <div class="space-y-6 pt-10 border-t border-slate-800 md:border-0 md:pt-0">
                     <div v-for="faq in billingFaq" :key="faq.question" class="pb-6 border-b border-slate-800">
                         <h3 class="text-xl font-medium mb-4 text-white hover:text-emerald-400 transition-colors cursor-pointer">{{ faq.question }}</h3>
                         <p class="text-slate-500 leading-relaxed">{{ faq.answer }}</p>
                     </div>
                </div>
            </div>
        </section>

    </SiteLayout>
</template>
