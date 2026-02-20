<script setup lang="ts">
import { Head } from '@inertiajs/vue3';
import MotionSection from '@/Components/site/MotionSection.vue';
import SectionShell from '@/Components/site/SectionShell.vue';
import SiteLayout from '@/Layouts/SiteLayout.vue';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();
</script>

<template>
    <Head title="Privacidade | Kitamo">
        <meta name="description" content="Política de privacidade da Kitamo em linguagem clara e organizada." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[980px] px-5 pb-8 pt-8 md:px-6 md:pt-10">
            <SectionShell
                kicker="Privacidade"
                title="Compromisso com uso responsável de dados"
                description="Este resumo institucional apresenta os princípios de coleta, uso e proteção de dados na Kitamo."
            />
        </section>

        <MotionSection class="mx-auto w-full max-w-[980px] px-5 pb-20 md:px-6 md:pb-24">
            <div class="space-y-4 rounded-3xl border border-slate-200 bg-white/85 p-7 text-sm leading-relaxed text-slate-700 md:p-8">
                <section>
                    <h2 class="text-lg font-semibold text-slate-950">1. Dados coletados</h2>
                    <p class="mt-2">Coletamos dados necessários para operação da plataforma, autenticação e comunicação solicitada pelo usuário.</p>
                </section>
                <section>
                    <h2 class="text-lg font-semibold text-slate-950">2. Finalidade</h2>
                    <p class="mt-2">Os dados são utilizados para entregar funcionalidades, suporte, segurança operacional e melhoria contínua do serviço.</p>
                </section>
                <section>
                    <h2 class="text-lg font-semibold text-slate-950">3. Compartilhamento</h2>
                    <p class="mt-2">Não compartilhamos dados pessoais fora das hipóteses legais e operacionais estritamente necessárias.</p>
                </section>
                <section>
                    <h2 class="text-lg font-semibold text-slate-950">4. Direitos do titular</h2>
                    <p class="mt-2">Solicitações de revisão, atualização e exclusão podem ser feitas pelo canal institucional de contato.</p>
                </section>
                <section>
                    <h2 class="text-lg font-semibold text-slate-950">5. Atualizações</h2>
                    <p class="mt-2">Este conteúdo pode ser atualizado para refletir evolução regulatória e operacional da plataforma.</p>
                </section>
            </div>
        </MotionSection>
    </SiteLayout>
</template>
