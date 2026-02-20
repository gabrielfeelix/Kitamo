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
    <Head title="Termos de Uso | Kitamo">
        <meta name="description" content="Termos de uso institucionais da plataforma Kitamo." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[980px] px-5 pb-8 pt-8 md:px-6 md:pt-10">
            <SectionShell
                kicker="Termos de uso"
                title="Condições gerais de uso da plataforma"
                description="Resumo institucional das condições para acesso e uso da Kitamo."
            />
        </section>

        <MotionSection class="mx-auto w-full max-w-[980px] px-5 pb-20 md:px-6 md:pb-24">
            <div class="space-y-4 rounded-3xl border border-slate-200 bg-white/85 p-7 text-sm leading-relaxed text-slate-700 md:p-8">
                <section>
                    <h2 class="text-lg font-semibold text-slate-950">1. Aceite</h2>
                    <p class="mt-2">Ao utilizar a plataforma, o usuário concorda com estes termos e com a política de privacidade vigente.</p>
                </section>
                <section>
                    <h2 class="text-lg font-semibold text-slate-950">2. Uso permitido</h2>
                    <p class="mt-2">A plataforma deve ser utilizada para fins lícitos e em conformidade com as regras operacionais da Kitamo.</p>
                </section>
                <section>
                    <h2 class="text-lg font-semibold text-slate-950">3. Conta e segurança</h2>
                    <p class="mt-2">O usuário é responsável por manter credenciais seguras e comunicar imediatamente suspeitas de acesso indevido.</p>
                </section>
                <section>
                    <h2 class="text-lg font-semibold text-slate-950">4. Limitações</h2>
                    <p class="mt-2">As informações disponibilizadas auxiliam decisões financeiras, mas não substituem orientação profissional especializada quando aplicável.</p>
                </section>
                <section>
                    <h2 class="text-lg font-semibold text-slate-950">5. Revisões dos termos</h2>
                    <p class="mt-2">Os termos podem ser ajustados para refletir mudanças de produto, segurança e requisitos regulatórios.</p>
                </section>
            </div>
        </MotionSection>
    </SiteLayout>
</template>
