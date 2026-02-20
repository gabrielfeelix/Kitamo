<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import FaqBlock from '@/Components/site/FaqBlock.vue';
import MotionSection from '@/Components/site/MotionSection.vue';
import SectionShell from '@/Components/site/SectionShell.vue';
import SiteLayout from '@/Layouts/SiteLayout.vue';
import type { SiteFaqItem } from '@/types/site';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const trustPoints = [
    {
        title: 'Princípio de mínimo necessário',
        text: 'Coletamos apenas os dados necessários para operação do produto e melhoria da experiência.',
    },
    {
        title: 'Controle de acesso',
        text: 'Sessões autenticadas e camadas de autorização para proteger recursos administrativos.',
    },
    {
        title: 'Rastreabilidade operacional',
        text: 'Ações críticas contam com trilha de registro para auditoria interna.',
    },
    {
        title: 'Transparência legal',
        text: 'Políticas públicas com linguagem clara para privacidade e termos de uso.',
    },
];

const securityFaq: SiteFaqItem[] = [
    {
        question: 'Como a Kitamo trata meus dados de contato?',
        answer: 'Dados de contato são usados para atendimento e comunicação solicitada, seguindo políticas de privacidade da plataforma.',
    },
    {
        question: 'Posso solicitar revisão ou remoção de dados?',
        answer: 'Sim. O canal de contato institucional atende solicitações de revisão, atualização e exclusão conforme política vigente.',
    },
    {
        question: 'A segurança é revisada continuamente?',
        answer: 'A plataforma opera com revisão contínua de práticas operacionais, controle de acesso e monitoramento do ambiente.',
    },
];
</script>

<template>
    <Head title="Segurança | Kitamo">
        <meta
            name="description"
            content="Práticas de segurança, privacidade e governança de dados da Kitamo para uso financeiro pessoal com confiança."
        />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[1240px] px-5 pb-8 pt-8 md:px-6 md:pt-10">
            <SectionShell
                kicker="Segurança e privacidade"
                title="Confiança operacional para decisões financeiras sensíveis"
                description="Proteção de dados e transparência institucional fazem parte da base do produto, não de um bloco secundário."
            />
        </section>

        <MotionSection class="mx-auto w-full max-w-[1240px] px-5 pb-8 md:px-6">
            <div class="grid gap-4 md:grid-cols-2">
                <article
                    v-for="point in trustPoints"
                    :key="point.title"
                    class="rounded-2xl border border-slate-200 bg-white/80 p-6"
                >
                    <h2 class="text-2xl leading-[1] tracking-[-0.02em] text-slate-950">{{ point.title }}</h2>
                    <p class="mt-3 text-sm leading-relaxed text-slate-600">{{ point.text }}</p>
                </article>
            </div>
        </MotionSection>

        <MotionSection class="mx-auto w-full max-w-[980px] px-5 py-14 md:px-6 md:py-16">
            <SectionShell kicker="FAQ de confiança" title="Perguntas frequentes sobre segurança" compact />
            <FaqBlock :items="securityFaq" />
        </MotionSection>

        <section class="mx-auto w-full max-w-[1240px] px-5 pb-20 md:px-6 md:pb-24">
            <div class="rounded-3xl border border-slate-200 bg-white/80 p-7 md:p-8">
                <p class="text-xs font-bold uppercase tracking-[0.16em] text-slate-500">Documentos legais</p>
                <h2 class="mt-3 text-3xl leading-[0.97] tracking-[-0.03em] text-slate-950">Políticas públicas para leitura rápida e sem ambiguidade</h2>
                <div class="mt-6 flex flex-wrap gap-3">
                    <Link :href="route('site.privacy')" class="inline-flex h-11 items-center justify-center rounded-full border border-slate-300 px-6 text-xs font-bold uppercase tracking-[0.14em] text-slate-700 hover:bg-slate-900 hover:text-white">
                        Política de privacidade
                    </Link>
                    <Link :href="route('site.terms')" class="inline-flex h-11 items-center justify-center rounded-full border border-slate-300 px-6 text-xs font-bold uppercase tracking-[0.14em] text-slate-700 hover:bg-slate-900 hover:text-white">
                        Termos de uso
                    </Link>
                </div>
            </div>
        </section>
    </SiteLayout>
</template>
