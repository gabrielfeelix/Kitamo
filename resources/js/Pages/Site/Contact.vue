<script setup lang="ts">
import { reactive, ref } from 'vue';
import axios from 'axios';
import { Head } from '@inertiajs/vue3';
import MotionSection from '@/Components/site/MotionSection.vue';
import SectionShell from '@/Components/site/SectionShell.vue';
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

const newsletter = reactive({
    name: '',
    email: '',
});

const newsletterSending = ref(false);
const newsletterSuccess = ref('');
const newsletterError = ref('');

const submitContact = async () => {
    contactSending.value = true;
    contactSuccess.value = '';
    contactErrors.value = {};

    try {
        await axios.post(route('api.site.contact'), {
            ...contactForm,
            source: 'website-contact',
        });

        contactSuccess.value = 'Mensagem enviada com sucesso. Retornaremos em até 1 dia útil.';
        contactForm.name = '';
        contactForm.email = '';
        contactForm.objective = '';
        contactForm.message = '';
        contactForm.company = '';
    } catch (error: any) {
        if (error?.response?.status === 422) {
            contactErrors.value = error.response.data.errors ?? {};
        } else if (error?.response?.status === 429) {
            contactErrors.value = { form: ['Limite de tentativas excedido. Tente novamente em alguns minutos.'] };
        } else {
            contactErrors.value = { form: ['Não foi possível enviar agora. Tente novamente.'] };
        }
    } finally {
        contactSending.value = false;
    }
};

const submitNewsletter = async () => {
    newsletterSending.value = true;
    newsletterError.value = '';
    newsletterSuccess.value = '';

    try {
        await axios.post(route('api.newsletter.subscribe'), {
            name: newsletter.name || null,
            email: newsletter.email,
            source: 'website-newsletter',
        });
        newsletterSuccess.value = 'Inscrição confirmada. Você receberá atualizações institucionais da Kitamo.';
        newsletter.name = '';
        newsletter.email = '';
    } catch (error: any) {
        if (error?.response?.status === 422) {
            newsletterError.value = 'E-mail inválido. Revise e tente novamente.';
        } else {
            newsletterError.value = 'Não foi possível concluir agora. Tente novamente.';
        }
    } finally {
        newsletterSending.value = false;
    }
};
</script>

<template>
    <Head title="Contato | Kitamo">
        <meta
            name="description"
            content="Entre em contato com a Kitamo para dúvidas sobre produto, planos, segurança e parceria institucional."
        />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[1240px] px-5 pb-8 pt-8 md:px-6 md:pt-10">
            <SectionShell
                kicker="Contato"
                title="Fale com a equipe da Kitamo"
                description="Canal institucional para dúvidas comerciais, suporte pré-venda e temas de privacidade."
            />
        </section>

        <MotionSection class="mx-auto grid w-full max-w-[1240px] gap-5 px-5 pb-20 md:grid-cols-2 md:px-6 md:pb-24">
            <article class="rounded-3xl border border-slate-200 bg-white/85 p-6 md:p-7">
                <h2 class="text-2xl leading-[1] tracking-[-0.02em] text-slate-950">Mensagem institucional</h2>
                <p class="mt-2 text-sm text-slate-600">Resposta em até 1 dia útil.</p>

                <form class="mt-6 grid gap-3" @submit.prevent="submitContact">
                    <input
                        v-model="contactForm.name"
                        type="text"
                        placeholder="Nome"
                        class="h-11 rounded-xl border border-slate-200 bg-white px-4 text-sm text-slate-900"
                    />
                    <p v-if="contactErrors.name" class="text-xs font-medium text-red-600">{{ contactErrors.name[0] }}</p>

                    <input
                        v-model="contactForm.email"
                        type="email"
                        placeholder="E-mail"
                        class="h-11 rounded-xl border border-slate-200 bg-white px-4 text-sm text-slate-900"
                    />
                    <p v-if="contactErrors.email" class="text-xs font-medium text-red-600">{{ contactErrors.email[0] }}</p>

                    <select
                        v-model="contactForm.objective"
                        class="h-11 rounded-xl border border-slate-200 bg-white px-4 text-sm text-slate-900"
                    >
                        <option value="" disabled>Objetivo do contato</option>
                        <option value="duvida-produto">Dúvida sobre produto</option>
                        <option value="duvida-planos">Dúvida sobre planos</option>
                        <option value="privacidade-dados">Privacidade e dados</option>
                        <option value="parceria">Parceria</option>
                    </select>
                    <p v-if="contactErrors.objective" class="text-xs font-medium text-red-600">{{ contactErrors.objective[0] }}</p>

                    <textarea
                        v-model="contactForm.message"
                        rows="5"
                        placeholder="Mensagem"
                        class="rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-900"
                    ></textarea>
                    <p v-if="contactErrors.message" class="text-xs font-medium text-red-600">{{ contactErrors.message[0] }}</p>

                    <input
                        v-model="contactForm.company"
                        type="text"
                        autocomplete="off"
                        tabindex="-1"
                        class="hidden"
                        aria-hidden="true"
                    />

                    <p v-if="contactErrors.form" class="text-xs font-medium text-red-600">{{ contactErrors.form[0] }}</p>
                    <p v-if="contactSuccess" class="text-xs font-medium text-emerald-700">{{ contactSuccess }}</p>

                    <button
                        type="submit"
                        class="mt-2 inline-flex h-11 items-center justify-center rounded-full bg-slate-900 text-xs font-bold uppercase tracking-[0.14em] text-white transition hover:bg-emerald-500 hover:text-slate-950 disabled:opacity-70"
                        :disabled="contactSending"
                    >
                        {{ contactSending ? 'Enviando...' : 'Enviar mensagem' }}
                    </button>
                </form>
            </article>

            <article class="rounded-3xl border border-slate-200 bg-white/85 p-6 md:p-7">
                <h2 class="text-2xl leading-[1] tracking-[-0.02em] text-slate-950">Newsletter institucional</h2>
                <p class="mt-2 text-sm text-slate-600">
                    Conteúdo sobre organização, planejamento e decisões financeiras com linguagem prática.
                </p>

                <form class="mt-6 grid gap-3" @submit.prevent="submitNewsletter">
                    <input
                        v-model="newsletter.name"
                        type="text"
                        placeholder="Nome (opcional)"
                        class="h-11 rounded-xl border border-slate-200 bg-white px-4 text-sm text-slate-900"
                    />
                    <input
                        v-model="newsletter.email"
                        type="email"
                        required
                        placeholder="E-mail"
                        class="h-11 rounded-xl border border-slate-200 bg-white px-4 text-sm text-slate-900"
                    />

                    <p v-if="newsletterError" class="text-xs font-medium text-red-600">{{ newsletterError }}</p>
                    <p v-if="newsletterSuccess" class="text-xs font-medium text-emerald-700">{{ newsletterSuccess }}</p>

                    <button
                        type="submit"
                        class="mt-2 inline-flex h-11 items-center justify-center rounded-full border border-slate-300 bg-white text-xs font-bold uppercase tracking-[0.14em] text-slate-700 transition hover:bg-slate-900 hover:text-white disabled:opacity-70"
                        :disabled="newsletterSending"
                    >
                        {{ newsletterSending ? 'Enviando...' : 'Quero receber' }}
                    </button>
                </form>

                <div class="mt-8 rounded-2xl border border-slate-200 bg-slate-50 p-4">
                    <p class="text-xs font-bold uppercase tracking-[0.16em] text-slate-500">SLA de atendimento</p>
                    <p class="mt-2 text-sm leading-relaxed text-slate-700">
                        Retorno institucional em até 1 dia útil. Para temas sensíveis de privacidade, priorizamos encaminhamento no mesmo dia.
                    </p>
                </div>
            </article>
        </MotionSection>
    </SiteLayout>
</template>
