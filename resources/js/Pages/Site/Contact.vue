<script setup lang="ts">
import { reactive, ref } from 'vue';
import axios from 'axios';
import { Head } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';
import MotionSection from '@/Components/site/MotionSection.vue';

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

        contactSuccess.value = 'Mensagem enviada com sucesso. Respondemos em até 24h úteis.';
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
            contactErrors.value = { form: [`Muitas tentativas. Tente novamente em ${retryAfter} segundos.`] };
        } else {
            contactErrors.value = { form: ['Algo deu errado na conexão. Tente novamente.'] };
        }
    } finally {
        contactSending.value = false;
    }
};
</script>

<template>
    <Head title="Contato | Kitamo">
        <meta name="description" content="Fale com a equipe do Kitamo. Atendimento direto, sem robô." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <!-- Hero Section — Dark, consistent with the rest of the site -->
        <MotionSection class="relative min-h-[45vh] w-full overflow-hidden bg-slate-950 text-white flex flex-col justify-end pt-32 pb-20">
            <!-- Background elements -->
            <div class="absolute inset-0 overflow-hidden pointer-events-none">
                <div class="absolute inset-0 opacity-[0.03] mix-blend-overlay" style="background-image: url('data:image/svg+xml,%3Csvg viewBox=%220 0 200 200%22 xmlns=%22http://www.w3.org/2000/svg%22%3E%3Cfilter id=%22noiseFilter%22%3E%3CfeTurbulence type=%22fractalNoise%22 baseFrequency=%220.8%22 numOctaves=%224%22 stitchTiles=%22stitch%22/%3E%3C/filter%3E%3Crect width=%22100%25%22 height=%22100%25%22 filter=%22url(%23noiseFilter)%22/%3E%3C/svg%3E');"></div>
                <div class="absolute -top-40 -right-20 w-[500px] h-[500px] rounded-full bg-teal-600/15 blur-[130px] mix-blend-screen opacity-50 animate-pulse"></div>
                <div class="absolute bottom-0 left-1/4 w-[400px] h-[400px] bg-cyan-600/10 blur-[100px] rounded-full mix-blend-screen opacity-40"></div>
            </div>
            
            <div class="relative z-10 mx-auto w-full max-w-[1440px] px-6 md:px-12">
                <div class="max-w-3xl">
                    <p class="inline-flex items-center gap-2 text-[11px] font-extrabold uppercase tracking-[0.2em] text-teal-400 mb-6 px-4 py-2 rounded-full border border-teal-500/20 bg-teal-500/10 w-fit">
                        <span class="w-1.5 h-1.5 rounded-full bg-teal-400 animate-pulse"></span>
                        Fale Conosco
                    </p>
                    <h1 class="text-5xl sm:text-6xl lg:text-[5.5rem] leading-[0.95] tracking-tighter text-slate-50 font-extrabold max-w-4xl">
                        Atendimento<br>
                        <span class="text-transparent bg-clip-text bg-gradient-to-r from-teal-400 to-emerald-300 font-serif italic pr-2">humano.</span>
                    </h1>
                    <p class="mt-8 text-xl leading-relaxed text-slate-400 font-medium max-w-2xl">
                        Sem chatbot, sem fila. Mande sua mensagem e a gente responde pessoalmente em até 24 horas úteis.
                    </p>
                </div>
            </div>
        </MotionSection>

        <!-- Form and Contacts Section -->
        <MotionSection class="bg-slate-50 py-24 pb-32">
            <div class="mx-auto w-full max-w-[1440px] px-6 md:px-12 grid gap-16 lg:grid-cols-12">
                <aside class="lg:col-span-4 lg:sticky lg:top-32 h-fit">
                    <h2 class="text-4xl sm:text-5xl font-extrabold tracking-tighter text-slate-900 leading-[1.05]">
                        Canais de<br><span class="text-teal-500 font-serif italic">contato.</span>
                    </h2>
                    
                    <div class="mt-12 space-y-6">
                        <!-- Email -->
                        <div class="bg-white rounded-[2rem] border border-slate-200 p-6 hover:shadow-lg transition-shadow">
                            <div class="flex items-center gap-4">
                                <div class="w-12 h-12 rounded-2xl bg-teal-50 flex items-center justify-center flex-shrink-0">
                                    <svg class="w-5 h-5 text-teal-600" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" /></svg>
                                </div>
                                <div>
                                    <p class="text-[10px] font-extrabold uppercase tracking-[0.2em] text-teal-600 mb-1">E-mail</p>
                                    <p class="text-lg font-extrabold text-slate-900">contato@kitamo.com.br</p>
                                </div>
                            </div>
                        </div>
                        
                        <!-- WhatsApp (coming soon) -->
                        <div class="bg-white rounded-[2rem] border border-slate-200 p-6 opacity-60 relative group">
                            <div class="flex items-center gap-4">
                                <div class="w-12 h-12 rounded-2xl bg-slate-100 flex items-center justify-center flex-shrink-0">
                                    <svg class="w-5 h-5 text-slate-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" /></svg>
                                </div>
                                <div>
                                    <p class="text-[10px] font-extrabold uppercase tracking-[0.2em] text-slate-400 mb-1">WhatsApp</p>
                                    <p class="text-lg font-bold text-slate-400">Em breve</p>
                                </div>
                            </div>
                            <div class="absolute right-4 top-1/2 -translate-y-1/2 bg-slate-900 text-white px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-widest opacity-0 group-hover:opacity-100 transition-opacity">Em breve</div>
                        </div>

                        <!-- Location -->
                        <div class="bg-white rounded-[2rem] border border-slate-200 p-6">
                            <div class="flex items-center gap-4">
                                <div class="w-12 h-12 rounded-2xl bg-slate-100 flex items-center justify-center flex-shrink-0">
                                    <svg class="w-5 h-5 text-slate-500" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" /><path stroke-linecap="round" stroke-linejoin="round" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" /></svg>
                                </div>
                                <div>
                                    <p class="text-[10px] font-extrabold uppercase tracking-[0.2em] text-slate-400 mb-1">Operação</p>
                                    <p class="text-base font-bold text-slate-700">100% remoto · Brasil</p>
                                    <p class="text-sm font-medium text-slate-500 mt-0.5">Seg–Sex, 9h às 18h</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </aside>

                <div class="lg:col-span-8">
                    <div class="rounded-[2.5rem] border border-slate-200 bg-white p-8 md:p-12 shadow-[0_20px_50px_-12px_rgba(0,0,0,0.05)]">
                        <div class="mb-8">
                            <h3 class="text-2xl font-extrabold text-slate-900 tracking-tight">Envie sua mensagem</h3>
                            <p class="text-sm text-slate-500 font-medium mt-1">Preencha o formulário e respondemos o mais rápido possível.</p>
                        </div>

                        <form class="space-y-8" @submit.prevent="submitContact">
                            <div class="grid gap-8 md:grid-cols-2">
                                <div class="relative group">
                                    <label for="name" class="block text-[11px] font-bold uppercase tracking-[0.2em] text-slate-400 mb-2 transition-colors group-focus-within:text-teal-600">Seu nome</label>
                                    <input
                                        id="name"
                                        v-model="contactForm.name"
                                        type="text"
                                        placeholder="Ex: João Silva"
                                        class="h-14 w-full rounded-2xl border-2 border-slate-100 bg-slate-50 px-5 text-base font-bold text-slate-900 outline-none transition-all placeholder:text-slate-300 focus:border-teal-400 focus:bg-white focus:ring-4 focus:ring-teal-400/10"
                                    />
                                    <p v-if="contactErrors.name" class="mt-2 text-xs font-bold text-red-500">{{ contactErrors.name[0] }}</p>
                                </div>
                                <div class="relative group">
                                    <label for="email" class="block text-[11px] font-bold uppercase tracking-[0.2em] text-slate-400 mb-2 transition-colors group-focus-within:text-teal-600">Seu e-mail</label>
                                    <input
                                        id="email"
                                        v-model="contactForm.email"
                                        type="email"
                                        placeholder="joao@empresa.com"
                                        class="h-14 w-full rounded-2xl border-2 border-slate-100 bg-slate-50 px-5 text-base font-bold text-slate-900 outline-none transition-all placeholder:text-slate-300 focus:border-teal-400 focus:bg-white focus:ring-4 focus:ring-teal-400/10"
                                    />
                                    <p v-if="contactErrors.email" class="mt-2 text-xs font-bold text-red-500">{{ contactErrors.email[0] }}</p>
                                </div>
                            </div>

                            <div class="relative group">
                                <label for="objective" class="block text-[11px] font-bold uppercase tracking-[0.2em] text-slate-400 mb-2 transition-colors group-focus-within:text-teal-600">Assunto</label>
                                <select
                                    id="objective"
                                    v-model="contactForm.objective"
                                    class="h-14 w-full rounded-2xl border-2 border-slate-100 bg-slate-50 px-5 text-base font-bold text-slate-900 outline-none transition-all focus:border-teal-400 focus:bg-white focus:ring-4 focus:ring-teal-400/10 appearance-none cursor-pointer"
                                    style="background-image: url('data:image/svg+xml;charset=US-ASCII,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2224%22%20height%3D%2224%22%20viewBox%3D%220%200%2024%2024%22%20fill%3D%22none%22%20stroke%3D%22%2394a3b8%22%20stroke-width%3D%222%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%3E%3Cpolyline%20points%3D%226%209%2012%2015%2018%209%22%3E%3C%2Fpolyline%3E%3C%2Fsvg%3E'); background-repeat: no-repeat; background-position: right 1rem center; background-size: 1.2em;"
                                >
                                    <option value="" disabled>Escolha o motivo do contato</option>
                                    <option value="duvida-produto">Dúvida sobre o produto</option>
                                    <option value="duvida-planos">Dúvida sobre planos e preços</option>
                                    <option value="privacidade-dados">Privacidade e dados (LGPD)</option>
                                    <option value="parceria">Proposta de parceria</option>
                                </select>
                                <p v-if="contactErrors.objective" class="mt-2 text-xs font-bold text-red-500">{{ contactErrors.objective[0] }}</p>
                            </div>

                            <div class="relative group">
                                <label for="message" class="block text-[11px] font-bold uppercase tracking-[0.2em] text-slate-400 mb-2 transition-colors group-focus-within:text-teal-600">Mensagem</label>
                                <textarea
                                    id="message"
                                    v-model="contactForm.message"
                                    rows="6"
                                    placeholder="Descreva sua dúvida ou sugestão em detalhes..."
                                    class="w-full rounded-2xl border-2 border-slate-100 bg-slate-50 px-5 py-4 text-base font-bold text-slate-900 outline-none transition-all placeholder:text-slate-300 focus:border-teal-400 focus:bg-white focus:ring-4 focus:ring-teal-400/10 resize-y"
                                ></textarea>
                                <p v-if="contactErrors.message" class="mt-2 text-xs font-bold text-red-500">{{ contactErrors.message[0] }}</p>
                            </div>

                            <input
                                v-model="contactForm.company"
                                type="text"
                                autocomplete="off"
                                tabindex="-1"
                                class="hidden"
                                aria-hidden="true"
                            />

                            <div class="flex flex-col gap-4 pt-4 border-t border-slate-100">
                                <transition name="fade">
                                    <div v-if="contactErrors.form" class="rounded-2xl border border-red-200 bg-red-50 px-5 py-4 flex items-center gap-4">
                                         <svg class="h-6 w-6 text-red-500 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>
                                         <p class="text-sm font-bold text-red-800">{{ contactErrors.form[0] }}</p>
                                    </div>
                                </transition>
                                
                                <transition name="fade">
                                    <div v-if="contactSuccess" class="rounded-2xl border border-teal-200 bg-teal-50 px-5 py-4 flex items-center gap-4">
                                         <svg class="h-6 w-6 text-teal-500 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                                         <p class="text-sm font-bold text-teal-800">{{ contactSuccess }}</p>
                                    </div>
                                </transition>

                                <button
                                    type="submit"
                                    :disabled="contactSending"
                                    class="inline-flex h-16 w-full items-center justify-center rounded-2xl bg-slate-950 px-8 text-[13px] font-extrabold uppercase tracking-[0.15em] text-white transition-all hover:bg-teal-500 hover:text-slate-950 disabled:cursor-not-allowed disabled:opacity-50 hover:shadow-[0_0_20px_theme(colors.teal.500/40)] hover:scale-[1.02] active:scale-95"
                                >
                                    <span v-if="contactSending" class="flex items-center gap-3">
                                        <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-current" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>
                                        Enviando...
                                    </span>
                                    <span v-else>Enviar Mensagem</span>
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </MotionSection>
    </SiteLayout>
</template>

<style scoped>
h1, h2, h3 {
    font-feature-settings: "salt" on, "ss01" on;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}
</style>
