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

        contactSuccess.value = 'Mensagem enviada com sucesso. Retornaremos em ate 24 horas uteis.';
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
            contactErrors.value = { form: ['Tivemos um problema de rede. Poderia tentar novamente?'] };
        }
    } finally {
        contactSending.value = false;
    }
};
</script>

<template>
    <Head title="Contato | Kitamo">
        <meta
            name="description"
            content="Entre em contato com a equipe Kitamo para duvidas de produto, planos, privacidade e parcerias."
        />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto grid w-full max-w-[1240px] gap-10 px-5 pb-16 pt-10 md:grid-cols-12 md:px-6 md:pb-20 md:pt-16">
            <div class="md:col-span-5 md:sticky md:top-32 md:h-fit">
                <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Canal aberto</p>
                <h1 class="mt-5 text-5xl leading-[0.92] tracking-[-0.03em] text-slate-950 md:text-6xl">
                    Fale direto com a equipe
                </h1>
                <p class="mt-6 text-lg leading-relaxed text-slate-600 md:text-xl">
                    Suporte humano para produto, planos, privacidade e parceria. Sem fila automatica para assuntos criticos.
                </p>

                <div class="mt-8 rounded-3xl border border-slate-200 bg-white/80 p-6">
                    <h2 class="text-xs font-bold uppercase tracking-[0.14em] text-slate-500">Canais de contato</h2>
                    <ul class="mt-4 space-y-3 text-sm text-slate-700">
                        <li class="rounded-2xl bg-slate-50 p-4">
                            <p class="font-semibold text-slate-900">Email</p>
                            <p>contato@kitamo.com.br</p>
                        </li>
                        <li class="rounded-2xl bg-slate-50 p-4">
                            <p class="font-semibold text-slate-900">WhatsApp</p>
                            <p>(XX) XXXXX-XXXX</p>
                            <!-- TODO: substituir pelo numero oficial -->
                        </li>
                        <li class="rounded-2xl bg-slate-50 p-4">
                            <p class="font-semibold text-slate-900">Horario de atendimento</p>
                            <p>Segunda a sexta, 9h as 18h (horario de Brasilia)</p>
                        </li>
                    </ul>
                </div>

                <div class="mt-4 rounded-3xl border border-slate-200 bg-white/80 p-6">
                    <h2 class="text-xs font-bold uppercase tracking-[0.14em] text-slate-500">Localizacao</h2>
                    <p class="mt-3 text-sm leading-relaxed text-slate-700">
                        Somos uma empresa 100% remota, baseada no Brasil.
                    </p>
                </div>

                <div class="mt-4 rounded-3xl border border-slate-200 bg-slate-50 p-6">
                    <h2 class="text-xs font-bold uppercase tracking-[0.14em] text-slate-500">Tempos de resposta (SLA)</h2>
                    <ul class="mt-4 space-y-3 text-sm text-slate-700">
                        <li class="flex items-center justify-between border-b border-slate-200 pb-3">
                            <span>Duvidas tecnicas</span>
                            <span class="font-semibold text-slate-900">~ 4 horas</span>
                        </li>
                        <li class="flex items-center justify-between border-b border-slate-200 pb-3">
                            <span>Parcerias / B2B</span>
                            <span class="font-semibold text-slate-900">1 dia util</span>
                        </li>
                        <li class="flex items-center justify-between">
                            <span>Revisao de dados (LGPD)</span>
                            <span class="font-bold text-red-700">Prioridade maxima</span>
                        </li>
                    </ul>
                </div>
            </div>

            <div class="md:col-span-7">
                <div class="rounded-3xl border border-slate-200 bg-white p-7 md:p-10">
                    <form class="space-y-6" @submit.prevent="submitContact">
                        <div class="grid gap-4 md:grid-cols-2">
                            <div>
                                <label for="name" class="ml-1 block text-xs font-bold uppercase tracking-[0.14em] text-slate-500">
                                    Como te chamamos?
                                </label>
                                <input
                                    id="name"
                                    v-model="contactForm.name"
                                    type="text"
                                    placeholder="Jane Doe"
                                    class="mt-2 h-12 w-full rounded-xl border border-slate-200 bg-slate-50 px-4 text-sm text-slate-900 outline-none transition focus:border-emerald-500"
                                />
                                <p v-if="contactErrors.name" class="mt-2 text-xs font-medium text-red-600">{{ contactErrors.name[0] }}</p>
                            </div>
                            <div>
                                <label for="email" class="ml-1 block text-xs font-bold uppercase tracking-[0.14em] text-slate-500">
                                    Melhor e-mail
                                </label>
                                <input
                                    id="email"
                                    v-model="contactForm.email"
                                    type="email"
                                    placeholder="jane@empresa.com"
                                    class="mt-2 h-12 w-full rounded-xl border border-slate-200 bg-slate-50 px-4 text-sm text-slate-900 outline-none transition focus:border-emerald-500"
                                />
                                <p v-if="contactErrors.email" class="mt-2 text-xs font-medium text-red-600">{{ contactErrors.email[0] }}</p>
                            </div>
                        </div>

                        <div>
                            <label for="objective" class="ml-1 block text-xs font-bold uppercase tracking-[0.14em] text-slate-500">
                                O que traz voce aqui?
                            </label>
                            <select
                                id="objective"
                                v-model="contactForm.objective"
                                class="mt-2 h-12 w-full rounded-xl border border-slate-200 bg-slate-50 px-4 text-sm text-slate-900 outline-none transition focus:border-emerald-500"
                            >
                                <option value="" disabled>Selecione um topico...</option>
                                <option value="duvida-produto">Duvida sobre o produto</option>
                                <option value="duvida-planos">Duvida sobre planos e cobranca</option>
                                <option value="privacidade-dados">Solicitacao LGPD</option>
                                <option value="parceria">Parceria comercial</option>
                            </select>
                            <p v-if="contactErrors.objective" class="mt-2 text-xs font-medium text-red-600">{{ contactErrors.objective[0] }}</p>
                        </div>

                        <div>
                            <label for="message" class="ml-1 block text-xs font-bold uppercase tracking-[0.14em] text-slate-500">
                                Mensagem
                            </label>
                            <textarea
                                id="message"
                                v-model="contactForm.message"
                                rows="6"
                                placeholder="Explique seu contexto para acelerarmos a resposta..."
                                class="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-900 outline-none transition focus:border-emerald-500"
                            ></textarea>
                            <p v-if="contactErrors.message" class="mt-2 text-xs font-medium text-red-600">{{ contactErrors.message[0] }}</p>
                        </div>

                        <input
                            v-model="contactForm.company"
                            type="text"
                            autocomplete="off"
                            tabindex="-1"
                            class="hidden"
                            aria-hidden="true"
                        />

                        <div class="flex flex-col gap-4 border-t border-slate-100 pt-5">
                            <p v-if="contactErrors.form" class="rounded-xl bg-red-50 px-4 py-3 text-sm font-semibold text-red-700">
                                {{ contactErrors.form[0] }}
                            </p>
                            <p v-if="contactSuccess" class="rounded-xl bg-emerald-50 px-4 py-3 text-sm font-semibold text-emerald-700">
                                {{ contactSuccess }}
                            </p>
                            <button
                                type="submit"
                                :disabled="contactSending"
                                class="inline-flex h-12 items-center justify-center rounded-full bg-slate-950 px-8 text-[11px] font-bold uppercase tracking-[0.14em] text-white transition hover:bg-emerald-500 hover:text-slate-950 disabled:cursor-not-allowed disabled:opacity-50"
                            >
                                {{ contactSending ? 'Enviando...' : 'Enviar mensagem' }}
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </section>
    </SiteLayout>
</template>
