<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, Link } from '@inertiajs/vue3';
import MotionSection from '@/Components/site/MotionSection.vue';
import SectionShell from '@/Components/site/SectionShell.vue';
import SiteLayout from '@/Layouts/SiteLayout.vue';

const props = defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const modules = [
    {
        title: 'Leitura de fluxo',
        description: 'Painel inicial com contexto do mês para reduzir decisão por impulso.',
    },
    {
        title: 'Alertas priorizados',
        description: 'Sinais de risco e vencimento aparecem no momento certo para ação antecipada.',
    },
    {
        title: 'Projeção orientada',
        description: 'Cenários de impacto para testar escolhas antes de comprometer orçamento.',
    },
    {
        title: 'Plano semanal',
        description: 'Ritmo de revisão com próxima ação objetiva para manter consistência.',
    },
];

const scenarios = [
    {
        name: 'Controle básico',
        title: 'Organizar o mês sem sobrecarga',
        details: 'Você ganha leitura imediata do cenário e identifica os pontos críticos da semana.',
        bullets: ['Resumo diário direto', 'Risco de vencimento em destaque', 'Categorias essenciais'],
    },
    {
        name: 'Ajuste preventivo',
        title: 'Corrigir rota antes do fechamento',
        details: 'A projeção mostra impacto de decisões e orienta cortes com menor atrito.',
        bullets: ['Simulação de despesas futuras', 'Alertas de pressão no saldo', 'Plano de ação semanal'],
    },
    {
        name: 'Planejamento avançado',
        title: 'Decidir crescimento com previsibilidade',
        details: 'Cenários ajudam a equilibrar metas, compromissos e margem para o próximo ciclo.',
        bullets: ['Mapa de prioridades', 'Rotina de revisão contínua', 'Maior previsibilidade de caixa'],
    },
];

const activeScenarioIndex = ref(0);
const activeScenario = computed(() => scenarios[activeScenarioIndex.value]);
</script>

<template>
    <Head title="Produto | Kitamo">
        <meta
            name="description"
            content="Conheça o produto Kitamo: módulos de leitura financeira, alertas, projeção e plano de ação semanal."
        />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[1240px] px-5 pb-8 pt-8 md:px-6 md:pt-10">
            <SectionShell
                kicker="Produto"
                title="Arquitetura de decisão para rotina financeira real"
                description="A experiência do Kitamo combina clareza visual e orientação prática para antecipar risco e agir com confiança."
            />
            <div class="grid gap-4 md:grid-cols-2">
                <article
                    v-for="module in modules"
                    :key="module.title"
                    class="rounded-2xl border border-slate-200 bg-white/80 p-6"
                >
                    <h3 class="text-2xl tracking-[-0.02em] text-slate-950">{{ module.title }}</h3>
                    <p class="mt-3 text-sm leading-relaxed text-slate-600">{{ module.description }}</p>
                </article>
            </div>
        </section>

        <MotionSection class="mx-auto w-full max-w-[1240px] px-5 py-10 md:px-6 md:py-14">
            <SectionShell
                kicker="Cenários interativos"
                title="Entenda impacto antes de decidir"
                description="Transições suaves entre estados mostram como o sistema muda a qualidade da decisão ao longo do mês."
            />
            <div class="grid gap-5 lg:grid-cols-12">
                <div class="space-y-2 lg:col-span-4">
                    <button
                        v-for="(scenario, index) in scenarios"
                        :key="scenario.name"
                        type="button"
                        class="w-full rounded-2xl border px-4 py-3 text-left transition"
                        :class="activeScenarioIndex === index ? 'border-emerald-400 bg-emerald-50 text-emerald-800' : 'border-slate-200 bg-white/75 text-slate-700 hover:border-slate-300'"
                        :aria-pressed="activeScenarioIndex === index"
                        @click="activeScenarioIndex = index"
                    >
                        <p class="text-[11px] font-bold uppercase tracking-[0.15em]">{{ scenario.name }}</p>
                        <p class="mt-1 text-sm font-semibold">{{ scenario.title }}</p>
                    </button>
                </div>

                <div class="lg:col-span-8">
                    <article class="rounded-3xl border border-slate-200 bg-white/85 p-7 md:p-8">
                        <Transition name="scenario-fade" mode="out-in">
                            <div :key="activeScenario.name">
                                <p class="text-[11px] font-bold uppercase tracking-[0.18em] text-slate-500">{{ activeScenario.name }}</p>
                                <h3 class="mt-3 text-4xl leading-[0.96] tracking-[-0.03em] text-slate-950">{{ activeScenario.title }}</h3>
                                <p class="mt-4 max-w-2xl text-base leading-relaxed text-slate-600">{{ activeScenario.details }}</p>
                                <ul class="mt-6 space-y-2">
                                    <li
                                        v-for="bullet in activeScenario.bullets"
                                        :key="bullet"
                                        class="flex items-center gap-2 text-sm font-semibold text-slate-700"
                                    >
                                        <span class="h-2 w-2 rounded-full bg-emerald-500"></span>
                                        {{ bullet }}
                                    </li>
                                </ul>
                            </div>
                        </Transition>
                    </article>
                </div>
            </div>
        </MotionSection>

        <MotionSection class="mx-auto w-full max-w-[1240px] px-5 pb-20 pt-10 md:px-6 md:pb-24">
            <div class="rounded-3xl border border-slate-200 bg-slate-900 p-8 text-white md:p-10">
                <p class="text-xs font-bold uppercase tracking-[0.18em] text-emerald-200/80">Mapa do fluxo</p>
                <div class="mt-5 grid gap-3 md:grid-cols-4">
                    <div class="rounded-2xl border border-white/15 bg-white/5 p-4">Diagnóstico</div>
                    <div class="rounded-2xl border border-white/15 bg-white/5 p-4">Antecipação</div>
                    <div class="rounded-2xl border border-white/15 bg-white/5 p-4">Projeção</div>
                    <div class="rounded-2xl border border-white/15 bg-white/5 p-4">Ação</div>
                </div>
                <div class="mt-7 flex flex-wrap gap-3">
                    <Link :href="route('site.features')" class="inline-flex h-11 items-center justify-center rounded-full bg-emerald-300 px-6 text-xs font-bold uppercase tracking-[0.14em] text-slate-900">
                        Ver funcionalidades
                    </Link>
                    <Link :href="props.canRegister ? '/register' : '/login'" class="inline-flex h-11 items-center justify-center rounded-full border border-white/35 px-6 text-xs font-bold uppercase tracking-[0.14em] text-white">
                        Começar agora
                    </Link>
                </div>
            </div>
        </MotionSection>
    </SiteLayout>
</template>

<style scoped>
.scenario-fade-enter-active,
.scenario-fade-leave-active {
    transition:
        opacity var(--motion-base, 300ms) var(--motion-ease, cubic-bezier(0.2, 0.8, 0.2, 1)),
        transform var(--motion-base, 300ms) var(--motion-ease, cubic-bezier(0.2, 0.8, 0.2, 1));
}

.scenario-fade-enter-from,
.scenario-fade-leave-to {
    opacity: 0;
    transform: translateY(8px);
}

@media (prefers-reduced-motion: reduce) {
    .scenario-fade-enter-active,
    .scenario-fade-leave-active {
        transition: none;
    }
}
</style>
