<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import FaqBlock from '@/Components/site/FaqBlock.vue';
import MotionSection from '@/Components/site/MotionSection.vue';
import PricingBlock from '@/Components/site/PricingBlock.vue';
import SectionShell from '@/Components/site/SectionShell.vue';
import TrustStrip from '@/Components/site/TrustStrip.vue';
import SiteLayout from '@/Layouts/SiteLayout.vue';
import { homeTrustSignals, institutionalFaq, pricingPlans } from '@/types/site';

const props = defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const primaryHref = props.canRegister ? '/register' : '/login';
</script>

<template>
    <Head title="Kitamo | Clareza financeira com decisão antecipada">
        <meta
            name="description"
            content="Website institucional da Kitamo: produto, funcionalidades, segurança e planos para quem quer previsibilidade financeira."
        />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[1240px] px-5 pb-14 pt-4 md:px-6 md:pb-20 md:pt-8">
            <div class="grid items-end gap-10 lg:grid-cols-12">
                <div class="lg:col-span-7">
                    <p class="text-[11px] font-bold uppercase tracking-[0.22em] text-slate-500">
                        Sistema de clareza financeira pessoal
                    </p>
                    <h1 class="mt-6 text-[15vw] leading-[0.86] tracking-[-0.045em] text-slate-950 sm:text-[10vw] lg:text-[6.8rem]">
                        Decida antes
                        <br />
                        do problema
                        <br />
                        virar susto.
                    </h1>
                    <p class="mt-7 max-w-xl text-lg leading-relaxed text-slate-600 md:text-xl">
                        A Kitamo organiza seu fluxo financeiro e mostra o impacto das escolhas com antecedência, para você agir no momento certo.
                    </p>
                    <div class="mt-9 flex flex-wrap items-center gap-3">
                        <Link
                            :href="primaryHref"
                            class="inline-flex h-12 items-center justify-center rounded-full bg-slate-900 px-7 text-xs font-bold uppercase tracking-[0.15em] text-white transition hover:bg-emerald-500 hover:text-slate-950"
                        >
                            Começar grátis
                        </Link>
                        <Link
                            :href="route('site.product')"
                            class="inline-flex h-12 items-center justify-center rounded-full border border-slate-300 px-7 text-xs font-bold uppercase tracking-[0.14em] text-slate-700 transition hover:bg-slate-900 hover:text-white"
                        >
                            Ver produto
                        </Link>
                    </div>
                </div>

                <div class="lg:col-span-5">
                    <div class="rounded-[2rem] border border-white/60 bg-slate-900 p-5 text-white shadow-[0_36px_70px_-50px_rgba(2,6,23,0.8)]">
                        <div class="rounded-2xl border border-white/10 bg-slate-800/70 p-4">
                            <p class="text-[10px] uppercase tracking-[0.16em] text-emerald-200/80">Saldo projetado no fim do mês</p>
                            <div class="mt-3 flex items-end justify-between">
                                <strong class="text-3xl tracking-[-0.02em]">R$ 2.430</strong>
                                <span class="text-xs text-emerald-200/80">Ajuste estável</span>
                            </div>
                            <div class="mt-5 grid h-28 grid-cols-6 items-end gap-2">
                                <span class="rounded-t-md bg-emerald-200/70 h-[32%]"></span>
                                <span class="rounded-t-md bg-emerald-300/70 h-[44%]"></span>
                                <span class="rounded-t-md bg-emerald-400/80 h-[68%]"></span>
                                <span class="rounded-t-md bg-emerald-300/70 h-[58%]"></span>
                                <span class="rounded-t-md bg-emerald-500/85 h-[80%]"></span>
                                <span class="rounded-t-md bg-emerald-300/70 h-[62%]"></span>
                            </div>
                            <div class="mt-5 grid gap-2 text-xs">
                                <div class="flex items-center justify-between rounded-lg border border-white/10 bg-slate-900/40 px-3 py-2">
                                    <span class="text-slate-300">Alertas críticos</span>
                                    <strong>3 hoje</strong>
                                </div>
                                <div class="flex items-center justify-between rounded-lg border border-white/10 bg-slate-900/40 px-3 py-2">
                                    <span class="text-slate-300">Próxima revisão</span>
                                    <strong>Segunda, 09:00</strong>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="mt-10">
                <TrustStrip :items="homeTrustSignals" />
            </div>
        </section>

        <MotionSection class="mx-auto w-full max-w-[1240px] px-5 py-14 md:px-6 md:py-16">
            <SectionShell
                kicker="Como funciona"
                title="Quatro passos para sair do modo reação"
                description="A experiência foi desenhada para reduzir carga cognitiva: entender contexto, priorizar risco, simular impacto e agir com confiança."
            />
            <div class="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
                <article class="rounded-2xl border border-slate-200 bg-white/80 p-5">
                    <p class="text-xs font-bold uppercase tracking-[0.14em] text-slate-500">01 Diagnóstico</p>
                    <h3 class="mt-3 text-2xl tracking-[-0.02em] text-slate-950">Leitura imediata</h3>
                    <p class="mt-2 text-sm leading-relaxed text-slate-600">Você abre e já entende o estado do mês sem perder tempo em telas técnicas.</p>
                </article>
                <article class="rounded-2xl border border-slate-200 bg-white/80 p-5">
                    <p class="text-xs font-bold uppercase tracking-[0.14em] text-slate-500">02 Antecipação</p>
                    <h3 class="mt-3 text-2xl tracking-[-0.02em] text-slate-950">Risco antes do vencimento</h3>
                    <p class="mt-2 text-sm leading-relaxed text-slate-600">Alertas mostram o que pode comprometer seu saldo com tempo para ajuste.</p>
                </article>
                <article class="rounded-2xl border border-slate-200 bg-white/80 p-5">
                    <p class="text-xs font-bold uppercase tracking-[0.14em] text-slate-500">03 Projeção</p>
                    <h3 class="mt-3 text-2xl tracking-[-0.02em] text-slate-950">Cenários reais</h3>
                    <p class="mt-2 text-sm leading-relaxed text-slate-600">Você testa decisões e vê impacto no fechamento mensal antes de comprometer orçamento.</p>
                </article>
                <article class="rounded-2xl border border-slate-200 bg-white/80 p-5">
                    <p class="text-xs font-bold uppercase tracking-[0.14em] text-slate-500">04 Ação</p>
                    <h3 class="mt-3 text-2xl tracking-[-0.02em] text-slate-950">Próximo passo claro</h3>
                    <p class="mt-2 text-sm leading-relaxed text-slate-600">Cada semana termina com um ajuste objetivo, sem ruído e sem paralisia.</p>
                </article>
            </div>
        </MotionSection>

        <MotionSection class="mx-auto w-full max-w-[1240px] px-5 py-14 md:px-6 md:py-16">
            <SectionShell
                kicker="Benefícios práticos"
                title="Um sistema para rotina real, não para planilha infinita"
                description="Estrutura institucional com foco no que move decisão: clareza, antecipação e consistência."
            />
            <div class="grid gap-4 lg:grid-cols-12">
                <article class="rounded-3xl border border-slate-200 bg-slate-900 p-7 text-white lg:col-span-6">
                    <p class="text-xs font-bold uppercase tracking-[0.17em] text-emerald-200/80">Visão do mês</p>
                    <h3 class="mt-3 text-4xl leading-[0.95] tracking-[-0.03em]">Você entende o cenário sem atravessar dez telas.</h3>
                    <p class="mt-4 max-w-lg text-sm leading-relaxed text-slate-200">
                        O resumo inicial entrega contexto e prioridade, para você agir cedo e reduzir decisões por impulso.
                    </p>
                </article>
                <article class="rounded-3xl border border-slate-200 bg-white/80 p-7 lg:col-span-3">
                    <p class="text-xs font-bold uppercase tracking-[0.17em] text-slate-500">Recorrências</p>
                    <h3 class="mt-3 text-2xl leading-tight tracking-[-0.02em] text-slate-950">Assinaturas visíveis</h3>
                    <p class="mt-3 text-sm leading-relaxed text-slate-600">Tudo que se repete entra no radar para evitar vazamentos silenciosos.</p>
                </article>
                <article class="rounded-3xl border border-slate-200 bg-white/80 p-7 lg:col-span-3">
                    <p class="text-xs font-bold uppercase tracking-[0.17em] text-slate-500">Decisão</p>
                    <h3 class="mt-3 text-2xl leading-tight tracking-[-0.02em] text-slate-950">Plano semanal</h3>
                    <p class="mt-3 text-sm leading-relaxed text-slate-600">Você fecha a semana com uma ação clara para melhorar o próximo ciclo.</p>
                </article>
            </div>
        </MotionSection>

        <MotionSection class="mx-auto grid w-full max-w-[1240px] gap-10 px-5 py-14 md:grid-cols-2 md:px-6 md:py-16">
            <div class="rounded-3xl border border-slate-200 bg-white/80 p-7">
                <p class="text-xs font-bold uppercase tracking-[0.17em] text-slate-500">Segurança e privacidade</p>
                <h3 class="mt-3 text-3xl leading-[0.98] tracking-[-0.03em] text-slate-950">
                    Transparência e proteção para dados financeiros sensíveis.
                </h3>
                <p class="mt-4 text-sm leading-relaxed text-slate-600">
                    Conheça práticas de tratamento de dados, autenticação e governança pensadas para uso diário com confiança.
                </p>
                <Link :href="route('site.security')" class="mt-6 inline-flex text-sm font-semibold text-emerald-700 hover:text-emerald-800">
                    Ver página de segurança →
                </Link>
            </div>

            <div class="rounded-3xl border border-slate-200 bg-white/80 p-7">
                <p class="text-xs font-bold uppercase tracking-[0.17em] text-slate-500">Planos</p>
                <h3 class="mt-3 text-3xl leading-[0.98] tracking-[-0.03em] text-slate-950">Escolha o nível de profundidade do seu planejamento.</h3>
                <p class="mt-4 text-sm leading-relaxed text-slate-600">
                    Do essencial ao avançado, com foco em clareza de rotina e consistência nas decisões.
                </p>
                <Link :href="route('site.pricing')" class="mt-6 inline-flex text-sm font-semibold text-emerald-700 hover:text-emerald-800">
                    Ver planos completos →
                </Link>
            </div>
        </MotionSection>

        <MotionSection class="mx-auto w-full max-w-[1240px] px-5 py-14 md:px-6 md:py-16">
            <SectionShell kicker="Planos" title="Escolha o plano que acompanha seu ritmo" />
            <PricingBlock :plans="pricingPlans" :can-register="canRegister" />
        </MotionSection>

        <MotionSection class="mx-auto w-full max-w-[980px] px-5 py-14 md:px-6 md:py-16">
            <SectionShell kicker="Perguntas frequentes" title="Respostas rápidas para objeções comuns" compact />
            <FaqBlock :items="institutionalFaq" />
        </MotionSection>

        <section class="mx-auto w-full max-w-[1240px] px-5 pb-20 pt-8 md:px-6 md:pb-24">
            <div class="rounded-[2rem] border border-white/25 bg-slate-900 p-8 text-white md:p-10">
                <p class="text-xs font-bold uppercase tracking-[0.18em] text-emerald-200/80">Próximo passo</p>
                <h2 class="mt-4 text-[10vw] leading-[0.86] tracking-[-0.04em] sm:text-[3.8rem]">Decida com antecedência, não no limite.</h2>
                <p class="mt-5 max-w-2xl text-base leading-relaxed text-slate-200">
                    Website institucional pronto. Agora o foco volta para o que importa: previsibilidade no seu fluxo financeiro.
                </p>
                <div class="mt-8 flex flex-wrap gap-3">
                    <Link :href="primaryHref" class="inline-flex h-12 items-center justify-center rounded-full bg-emerald-300 px-7 text-xs font-bold uppercase tracking-[0.14em] text-slate-900 hover:bg-emerald-200">
                        Começar grátis
                    </Link>
                    <Link :href="route('site.contact')" class="inline-flex h-12 items-center justify-center rounded-full border border-white/40 px-7 text-xs font-bold uppercase tracking-[0.14em] text-white hover:bg-white hover:text-slate-900">
                        Falar com a equipe
                    </Link>
                </div>
            </div>
        </section>
    </SiteLayout>
</template>
