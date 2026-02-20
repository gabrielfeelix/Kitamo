<script setup lang="ts">
import { reactive, ref } from 'vue';
import axios from 'axios';
import { Head } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const contactForm = reactive({
    name: '',
    email: '',
    objective: '',
    message: '',
    company: '',
});

const contactErrors = ref<Record<string, string[]>>({});
const contactSending = ref(false);
const contactSuccess = ref('');

const submitContact = async () => {
    contactSending.value = true;
    contactSuccess.value = '';
    contactErrors.value = {};

    try {
        await axios.post(route('api.site.contact'), {
            ...contactForm,
            source: 'website-contact',
        });

        contactSuccess.value = 'Mensagem no cofre! Enquanto aguarda nosso retorno (SLA 24h), explore nossos artigos na página inicial.';
        contactForm.name = '';
        contactForm.email = '';
        contactForm.objective = '';
        contactForm.message = '';
        contactForm.company = '';
    } catch (error: any) {
        if (error?.response?.status === 422) {
            contactErrors.value = error.response.data.errors ?? {};
        } else if (error?.response?.status === 429) {
            const retryAfter = error.response.headers['retry-after'] || '60';
            contactErrors.value = { form: [`Muitos disparos. Respire fundo e tente novamente em ${retryAfter} segundos.`] };
        } else {
            contactErrors.value = { form: ['Tivemos um problema de rede. Poderia tentar novamente?'] };
        }
    } finally {
        contactSending.value = false;
    }
};
</script>

<template>
    <Head title="Contato | Kitamo">
        <meta name="description" content="Precisa de ajuda ou parceria? Acesse o canal direto com a equipe Kitamo." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        
        <section class="max-w-[1400px] mx-auto px-6 py-24 md:py-32 grid lg:grid-cols-12 gap-16 lg:gap-8 xl:gap-24 items-start">
            
            <!-- Left Header -->
            <div class="lg:col-span-5 lg:sticky lg:top-32 mb-10 lg:mb-0">
                <p class="text-[11px] font-bold uppercase tracking-[0.25em] text-slate-500 mb-6 flex items-center gap-3">
                    <span class="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span> Canal Aberto
                </p>
                <h1 class="text-5xl md:text-[5rem] leading-[0.9] font-medium tracking-tight mb-8">Nenhum chatbot em <span class="text-emerald-500 italic font-serif">nosso caminho.</span></h1>
                <p class="text-xl text-slate-600 leading-relaxed mb-12">Quando envolve o seu dinheiro, nós não delegamos o atendimento. Fale direto com a equipe fundadora e de produto.</p>
                
                <div class="bg-slate-50 border border-slate-200 rounded-[2rem] p-8">
                    <h3 class="font-bold text-slate-900 mb-2 uppercase text-xs tracking-widest">Tempos de Resposta (SLA)</h3>
                    <ul class="space-y-4 mt-6">
                        <li class="flex items-center justify-between border-b border-slate-200 pb-4">
                            <span class="text-slate-600">Dúvidas Técnicas</span>
                            <span class="text-slate-900 font-medium">~ 4 horas</span>
                        </li>
                        <li class="flex items-center justify-between border-b border-slate-200 pb-4">
                            <span class="text-slate-600">Parcerias / B2B</span>
                            <span class="text-slate-900 font-medium">1 dia útil</span>
                        </li>
                        <li class="flex items-center justify-between">
                            <span class="text-slate-600">Exclusão de Dados (LGPD)</span>
                            <span class="text-red-700 font-bold">Prioridade Máxima</span>
                        </li>
                    </ul>
                </div>
            </div>

            <!-- Right Interactive Form Block -->
            <div class="lg:col-span-7">
                <div class="bg-white rounded-[3rem] p-8 md:p-12 shadow-[0_40px_100px_rgba(2,6,23,0.05)] border border-slate-200 relative overflow-hidden">
                    <div class="absolute -top-40 -right-40 w-96 h-96 bg-emerald-500/10 blur-[100px] rounded-full"></div>
                    
                    <form @submit.prevent="submitContact" class="relative z-10 w-full space-y-8">
                        
                        <div class="grid md:grid-cols-2 gap-8">
                            <div class="space-y-2">
                                <label for="name" class="block text-xs font-bold uppercase tracking-widest text-slate-500 ml-2">Como te chamamos?</label>
                                <input
                                    id="name"
                                    v-model="contactForm.name"
                                    type="text"
                                    placeholder="Jane Doe"
                                    class="w-full h-14 bg-slate-50 border-0 border-b-2 border-slate-200 px-4 placeholder:text-slate-400 focus:border-emerald-500 focus:ring-0 transition-colors rounded-none font-medium text-slate-900"
                                />
                                <p v-if="contactErrors.name" class="text-xs font-medium text-red-500 mt-2">{{ contactErrors.name[0] }}</p>
                            </div>
                            
                            <div class="space-y-2">
                                <label for="email" class="block text-xs font-bold uppercase tracking-widest text-slate-500 ml-2">Melhor E-mail</label>
                                <input
                                    id="email"
                                    v-model="contactForm.email"
                                    type="email"
                                    placeholder="jane@empresa.com"
                                    class="w-full h-14 bg-slate-50 border-0 border-b-2 border-slate-200 px-4 placeholder:text-slate-400 focus:border-emerald-500 focus:ring-0 transition-colors rounded-none font-medium text-slate-900"
                                />
                                <p v-if="contactErrors.email" class="text-xs font-medium text-red-500 mt-2">{{ contactErrors.email[0] }}</p>
                            </div>
                        </div>

                        <div class="space-y-2">
                            <label for="objective" class="block text-xs font-bold uppercase tracking-widest text-slate-500 ml-2">O que traz você aqui?</label>
                            <select
                                id="objective"
                                v-model="contactForm.objective"
                                class="w-full h-14 bg-slate-50 border-0 border-b-2 border-slate-200 px-4 text-slate-900 font-medium focus:border-emerald-500 focus:ring-0 transition-colors rounded-none"
                            >
                                <option value="" disabled>Selecione um tópico...</option>
                                <option value="duvida-produto">Como o produto funciona</option>
                                <option value="duvida-planos">Custo, Planos ou Setup</option>
                                <option value="privacidade-dados">Revisão de Dados (LGPD)</option>
                                <option value="parceria">Parceria Comercial (Influenciadores)</option>
                            </select>
                            <p v-if="contactErrors.objective" class="text-xs font-medium text-red-500 mt-2">{{ contactErrors.objective[0] }}</p>
                        </div>

                        <div class="space-y-2">
                            <label for="message" class="block text-xs font-bold uppercase tracking-widest text-slate-500 ml-2">Descreva a situação</label>
                            <textarea
                                id="message"
                                v-model="contactForm.message"
                                rows="6"
                                placeholder="Olá equipe Kitamo! Eu estava avaliando o sistema de metas e..."
                                class="w-full bg-slate-50 border-0 border-b-2 border-slate-200 px-4 py-4 placeholder:text-slate-400 focus:border-emerald-500 focus:ring-0 transition-colors rounded-none font-medium text-slate-900 resize-none"
                            ></textarea>
                            <p v-if="contactErrors.message" class="text-xs font-medium text-red-500 mt-2">{{ contactErrors.message[0] }}</p>
                        </div>
                        
                        <!-- Honeypot anti-bot -->
                        <input v-model="contactForm.company" type="text" autocomplete="off" tabindex="-1" class="hidden" aria-hidden="true" />

                        <div class="pt-6 border-t border-slate-100 flex flex-col md:flex-row md:items-center justify-between gap-6">
                            <div>
                                <p v-if="contactErrors.form" class="text-sm font-bold text-red-500 bg-red-50 py-3 px-4 rounded-xl shadow-sm">{{ contactErrors.form[0] }}</p>
                                <p v-if="contactSuccess" class="text-sm font-bold text-emerald-600 bg-emerald-50 py-3 px-4 rounded-xl shadow-sm flex items-center gap-2"><span class="text-lg">✓</span> {{ contactSuccess }}</p>
                            </div>

                            <button
                                type="submit"
                                :disabled="contactSending"
                                class="w-full md:w-auto inline-flex h-16 items-center justify-center rounded-full bg-slate-950 px-10 text-xs font-bold uppercase tracking-[0.15em] text-white hover:bg-emerald-500 hover:text-slate-950 transition-all shadow-[0_20px_40px_rgba(2,6,23,0.1)] hover:shadow-[0_20px_40px_rgba(16,185,129,0.3)] hover:-translate-y-1 disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:translate-y-0"
                            >
                                {{ contactSending ? 'Criptografando...' : 'Assinar & Enviar' }}
                            </button>
                        </div>

                    </form>
                </div>
            </div>

        </section>

    </SiteLayout>
</template>
