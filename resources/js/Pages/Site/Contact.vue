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
            content="Fale com a equipe Kitamo para duvidas de produto, planos, privacidade e parcerias."
        />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[1320px] px-5 pb-12 pt-10 md:px-6 md:pb-16 md:pt-16">
            <div class="contact-hero relative overflow-hidden rounded-[2.2rem] border border-slate-200 p-6 md:p-8">
                <div class="grid items-center gap-8 md:grid-cols-12">
                    <div class="md:col-span-7 text-white">
                        <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-emerald-300">Canal direto</p>
                        <h1 class="mt-4 text-5xl leading-[0.9] tracking-[-0.03em] md:text-6xl">
                            Nenhum bot.
                            <span class="block font-serif italic text-emerald-300">Conversa humana.</span>
                        </h1>
                        <p class="mt-5 max-w-2xl text-base leading-relaxed text-slate-300 md:text-lg">
                            Atendimento direto para produto, planos, privacidade e parceria. Sem fila automatica para assunto critico.
                        </p>

                        <div class="mt-7 grid max-w-2xl gap-3 sm:grid-cols-3">
                            <div class="rounded-2xl border border-white/15 bg-white/10 px-4 py-3">
                                <p class="text-[10px] font-bold uppercase tracking-[0.12em] text-emerald-300">Duvidas tecnicas</p>
                                <p class="mt-1 text-sm text-white">~ 4 horas</p>
                            </div>
                            <div class="rounded-2xl border border-white/15 bg-white/10 px-4 py-3">
                                <p class="text-[10px] font-bold uppercase tracking-[0.12em] text-emerald-300">Parcerias</p>
                                <p class="mt-1 text-sm text-white">1 dia util</p>
                            </div>
                            <div class="rounded-2xl border border-white/15 bg-white/10 px-4 py-3">
                                <p class="text-[10px] font-bold uppercase tracking-[0.12em] text-emerald-300">LGPD</p>
                                <p class="mt-1 text-sm text-white">Prioridade maxima</p>
                            </div>
                        </div>
                    </div>

                    <div class="md:col-span-5">
                        <img
                            src="https://images.pexels.com/photos/3184360/pexels-photo-3184360.jpeg?auto=compress&cs=tinysrgb&w=1200"
                            alt="Equipe em reuniao por videochamada"
                            class="h-[320px] w-full rounded-[1.6rem] object-cover md:h-[400px]"
                            loading="lazy"
                        />
                    </div>
                </div>
            </div>
        </section>

        <section class="mx-auto grid w-full max-w-[1320px] gap-8 px-5 pb-20 md:grid-cols-12 md:px-6 md:pb-24">
            <aside class="md:col-span-4 md:sticky md:top-28 md:h-fit">
                <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Canais de contato</p>
                <div class="mt-4 space-y-3 border-y border-slate-200 py-5">
                    <div>
                        <p class="text-xs font-bold uppercase tracking-[0.12em] text-slate-500">Email</p>
                        <p class="mt-1 text-base font-medium text-slate-900">contato@kitamo.com.br</p>
                    </div>
                    <div>
                        <p class="text-xs font-bold uppercase tracking-[0.12em] text-slate-500">WhatsApp</p>
                        <p class="mt-1 text-base font-medium text-slate-900">(XX) XXXXX-XXXX</p>
                        <!-- TODO: substituir pelo numero oficial -->
                    </div>
                    <div>
                        <p class="text-xs font-bold uppercase tracking-[0.12em] text-slate-500">Horario</p>
                        <p class="mt-1 text-base font-medium text-slate-900">Seg-Sex, 9h as 18h (Brasilia)</p>
                    </div>
                    <div>
                        <p class="text-xs font-bold uppercase tracking-[0.12em] text-slate-500">Base operacional</p>
                        <p class="mt-1 text-base font-medium text-slate-900">Empresa 100% remota no Brasil</p>
                    </div>
                </div>
            </aside>

            <div class="md:col-span-8">
                <div class="rounded-[1.8rem] border border-slate-200 bg-white p-6 md:p-8">
                    <form class="space-y-6" @submit.prevent="submitContact">
                        <div class="grid gap-4 md:grid-cols-2">
                            <div>
                                <label for="name" class="ml-1 block text-xs font-bold uppercase tracking-[0.14em] text-slate-500">Como te chamamos?</label>
                                <input
                                    id="name"
                                    v-model="contactForm.name"
                                    type="text"
                                    placeholder="Jane Doe"
                                    class="mt-2 h-12 w-full border-0 border-b-2 border-slate-200 bg-slate-50 px-4 text-sm text-slate-900 outline-none transition focus:border-emerald-500"
                                />
                                <p v-if="contactErrors.name" class="mt-2 text-xs font-medium text-red-600">{{ contactErrors.name[0] }}</p>
                            </div>
                            <div>
                                <label for="email" class="ml-1 block text-xs font-bold uppercase tracking-[0.14em] text-slate-500">Melhor e-mail</label>
                                <input
                                    id="email"
                                    v-model="contactForm.email"
                                    type="email"
                                    placeholder="jane@empresa.com"
                                    class="mt-2 h-12 w-full border-0 border-b-2 border-slate-200 bg-slate-50 px-4 text-sm text-slate-900 outline-none transition focus:border-emerald-500"
                                />
                                <p v-if="contactErrors.email" class="mt-2 text-xs font-medium text-red-600">{{ contactErrors.email[0] }}</p>
                            </div>
                        </div>

                        <div>
                            <label for="objective" class="ml-1 block text-xs font-bold uppercase tracking-[0.14em] text-slate-500">O que traz voce aqui?</label>
                            <select
                                id="objective"
                                v-model="contactForm.objective"
                                class="mt-2 h-12 w-full border-0 border-b-2 border-slate-200 bg-slate-50 px-4 text-sm text-slate-900 outline-none transition focus:border-emerald-500"
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
                            <label for="message" class="ml-1 block text-xs font-bold uppercase tracking-[0.14em] text-slate-500">Mensagem</label>
                            <textarea
                                id="message"
                                v-model="contactForm.message"
                                rows="6"
                                placeholder="Explique seu contexto para acelerarmos a resposta..."
                                class="mt-2 w-full border-0 border-b-2 border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-900 outline-none transition focus:border-emerald-500"
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

<style scoped>
.contact-hero {
    background:
        radial-gradient(30rem 24rem at 8% 0%, rgba(16, 185, 129, 0.2), transparent 72%),
        linear-gradient(145deg, #020617 0%, #0f172a 60%, #111827 100%);
}
</style>
