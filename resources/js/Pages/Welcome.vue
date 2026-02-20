<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import { computed, onMounted, onUnmounted, ref } from 'vue';

const props = defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const isLoaded = ref(false);
const scrollProgress = ref(0);
const activeSectionId = ref('hero');
const activeStepIndex = ref(0);
const activeScenarioIndex = ref(0);
const prefersReducedMotion = ref(false);
const heroTiltX = ref(0);
const heroTiltY = ref(0);
const revealedSections = ref<Record<string, boolean>>({});

let loadTimer: ReturnType<typeof setTimeout> | null = null;
let sectionObserver: IntersectionObserver | null = null;
let stepObserver: IntersectionObserver | null = null;
let reducedMotionMediaQuery: MediaQueryList | null = null;

const navSections = [
    { id: 'hero', label: 'Início' },
    { id: 'pain', label: 'Dor' },
    { id: 'components', label: 'Sistema' },
    { id: 'process', label: 'Fluxo' },
    { id: 'scenarios', label: 'Cenários' },
    { id: 'proof', label: 'Provas' },
    { id: 'faq', label: 'FAQ' },
    { id: 'cta', label: 'Final' }
];

const tickerItems = [
    'Projeção diária',
    'Alerta pré-vencimento',
    'Visão de assinatura',
    'Análise por categoria',
    'Cenário otimista e conservador',
    'Resumo mensal em segundos'
];

const tickerLoop = [...tickerItems, ...tickerItems];

const processSteps = [
    {
        num: '01',
        title: 'Diagnosticar sem atrito',
        desc: 'Você conecta suas contas e o Kitamo organiza o caos em um painel claro no primeiro acesso.',
        bullets: ['Mapa de categorias', 'Linha do tempo de gastos', 'Sinais de risco rápido']
    },
    {
        num: '02',
        title: 'Antecipar antes da dor',
        desc: 'O sistema detecta picos de cobrança, assinaturas esquecidas e datas críticas antes de virar problema.',
        bullets: ['Lembretes inteligentes', 'Janela de vencimentos', 'Alertas de comportamento']
    },
    {
        num: '03',
        title: 'Projetar o dia 30 agora',
        desc: 'A projeção financeira mostra impacto de parcelas, recorrências e novos planos no saldo futuro.',
        bullets: ['Simulação de cenário', 'Impacto acumulado', 'Recomendação de ajuste']
    },
    {
        num: '04',
        title: 'Decidir com confiança',
        desc: 'Você troca achismo por decisão com evidência e já entra no próximo mês no controle.',
        bullets: ['Plano de ação semanal', 'Metas com progresso real', 'Clareza para priorizar']
    }
];

const decisionScenarios = [
    {
        label: 'Essencial',
        title: 'Cortar vazamentos sem sacrificar rotina',
        subtitle: 'Você começa com diagnóstico, remove desperdício e mantém o que importa.',
        impact: '+R$ 640',
        notes: ['Assinaturas não usadas identificadas', 'Reorganização de vencimentos', 'Meta semanal de controle']
    },
    {
        label: 'Controle',
        title: 'Estabilizar fluxo e reduzir ansiedade',
        subtitle: 'A projeção prioriza as decisões críticas e antecipa falta de caixa.',
        impact: '+R$ 1.280',
        notes: ['Calendário de risco por semana', 'Ajustes em parcelas futuras', 'Proteção de saldo mínimo']
    },
    {
        label: 'Expansão',
        title: 'Planejar crescimento com previsibilidade',
        subtitle: 'Depois da base, o foco vira alocar sobra com estratégia e meta.',
        impact: '+R$ 2.100',
        notes: ['Simulação de novos compromissos', 'Planejamento trimestral guiado', 'Reserva com gatilho automático']
    }
];

const testimonials = [
    {
        quote: '"Parei de descobrir problema no susto."',
        body: 'Com três semanas de uso, consegui prever meu pior mês do trimestre e ajustar antes de estourar.',
        name: 'Rafaela A.',
        role: 'Gerente de Produto'
    },
    {
        quote: '"Não é só bonito, é útil todo dia."',
        body: 'A projeção e os alertas mudaram como eu tomo decisão de compra grande.',
        name: 'Leandro M.',
        role: 'Empreendedor'
    },
    {
        quote: '"Finalmente um app que pensa em fluxo."',
        body: 'Hoje eu vejo o próximo mês em minutos e sei exatamente onde cortar sem adivinhação.',
        name: 'Camila T.',
        role: 'Arquiteta'
    }
];

const primaryCtaHref = computed(() => (props.canRegister ? '/register' : '/login'));
const primaryCtaLabel = computed(() => (props.canRegister ? 'Criar conta grátis' : 'Entrar para testar'));
const processProgress = computed(() => ((activeStepIndex.value + 1) / processSteps.length) * 100);
const activeScenario = computed(
    () => decisionScenarios[activeScenarioIndex.value] ?? decisionScenarios[0]
);

const setActiveScenario = (index: number) => {
    activeScenarioIndex.value = index;
};

const markSectionVisible = (sectionId: string) => {
    if (revealedSections.value[sectionId]) {
        return;
    }
    revealedSections.value = {
        ...revealedSections.value,
        [sectionId]: true
    };
};

const isSectionVisible = (sectionId: string) => Boolean(revealedSections.value[sectionId]);

const handleScroll = () => {
    const currentScroll = window.scrollY || document.documentElement.scrollTop;
    const maxScroll = document.documentElement.scrollHeight - document.documentElement.clientHeight;
    scrollProgress.value = maxScroll > 0 ? (currentScroll / maxScroll) * 100 : 0;
};

const initializeSectionObserver = () => {
    const sections = Array.from(document.querySelectorAll<HTMLElement>('[data-observe-section]'));
    if (!sections.length) {
        return;
    }

    if (!('IntersectionObserver' in window)) {
        sections.forEach((section) => {
            const sectionId = section.dataset.observeSection;
            if (sectionId) {
                markSectionVisible(sectionId);
            }
        });
        return;
    }

    sectionObserver = new IntersectionObserver(
        (entries) => {
            entries.forEach((entry) => {
                const element = entry.target as HTMLElement;
                const sectionId = element.dataset.observeSection;
                if (!sectionId) {
                    return;
                }

                if (entry.isIntersecting) {
                    markSectionVisible(sectionId);
                }

                if (entry.isIntersecting && entry.intersectionRatio >= 0.45) {
                    activeSectionId.value = sectionId;
                }
            });
        },
        {
            threshold: [0.2, 0.45, 0.75],
            rootMargin: '-10% 0px -10% 0px'
        }
    );

    sections.forEach((section) => sectionObserver?.observe(section));
};

const initializeStepObserver = () => {
    const panels = Array.from(document.querySelectorAll<HTMLElement>('[data-step-panel]'));
    if (!panels.length || !('IntersectionObserver' in window)) {
        return;
    }

    stepObserver = new IntersectionObserver(
        (entries) => {
            const visibleEntries = entries
                .filter((entry) => entry.isIntersecting)
                .sort((entryA, entryB) => entryB.intersectionRatio - entryA.intersectionRatio);

            if (!visibleEntries.length) {
                return;
            }

            const stepIndex = visibleEntries[0].target.getAttribute('data-step-index');
            if (stepIndex) {
                activeStepIndex.value = Number(stepIndex);
            }
        },
        {
            threshold: [0.35, 0.55, 0.75],
            rootMargin: '-25% 0px -30% 0px'
        }
    );

    panels.forEach((panel) => stepObserver?.observe(panel));
};

const handleReducedMotionChange = (event: MediaQueryListEvent) => {
    prefersReducedMotion.value = event.matches;
};

const handleHeroPointerMove = (event: MouseEvent) => {
    if (prefersReducedMotion.value) {
        return;
    }

    const target = event.currentTarget as HTMLElement | null;
    if (!target) {
        return;
    }

    const bounds = target.getBoundingClientRect();
    const centerX = bounds.left + bounds.width / 2;
    const centerY = bounds.top + bounds.height / 2;

    const offsetX = (event.clientX - centerX) / bounds.width;
    const offsetY = (event.clientY - centerY) / bounds.height;

    heroTiltX.value = Number((offsetY * -9).toFixed(2));
    heroTiltY.value = Number((offsetX * 9).toFixed(2));
};

const resetHeroTilt = () => {
    heroTiltX.value = 0;
    heroTiltY.value = 0;
};

const heroTransformStyle = computed(() => {
    if (prefersReducedMotion.value) {
        return {};
    }

    return {
        transform: `rotateX(${heroTiltX.value}deg) rotateY(${heroTiltY.value}deg) translateZ(0)`
    };
});

onMounted(() => {
    loadTimer = setTimeout(() => {
        isLoaded.value = true;
        markSectionVisible('hero');
    }, 110);

    reducedMotionMediaQuery = window.matchMedia('(prefers-reduced-motion: reduce)');
    prefersReducedMotion.value = reducedMotionMediaQuery.matches;
    reducedMotionMediaQuery.addEventListener('change', handleReducedMotionChange);

    handleScroll();
    window.addEventListener('scroll', handleScroll, { passive: true });

    initializeSectionObserver();
    initializeStepObserver();
});

onUnmounted(() => {
    if (loadTimer) {
        clearTimeout(loadTimer);
    }

    window.removeEventListener('scroll', handleScroll);

    if (sectionObserver) {
        sectionObserver.disconnect();
    }

    if (stepObserver) {
        stepObserver.disconnect();
    }

    if (reducedMotionMediaQuery) {
        reducedMotionMediaQuery.removeEventListener('change', handleReducedMotionChange);
    }
});
</script>

<template>
    <Head title="Kitamo | O fim do mês não precisa ser de terror" />

    <div class="fixed top-0 left-0 h-[3px] z-[70] bg-[#10B981] transition-[width] duration-100 ease-out" :style="{ width: scrollProgress + '%' }"></div>

    <div class="landing-shell min-h-screen text-slate-950 selection:bg-[#10B981] selection:text-white">
        <div class="landing-ambient"></div>
        <div class="landing-grid"></div>

        <header class="fixed top-0 inset-x-0 z-50 border-b border-white/40 bg-[#f7f7f3]/85 backdrop-blur-xl">
            <div class="max-w-[1320px] mx-auto px-6 h-20 flex items-center justify-between gap-4">
                <a href="#hero" class="text-2xl font-bold tracking-[-0.04em]">kitamo</a>
                <nav class="hidden xl:flex items-center gap-5">
                    <a
                        v-for="section in navSections"
                        :key="section.id"
                        :href="`#${section.id}`"
                        class="lp-nav-link"
                        :class="{ 'is-active': activeSectionId === section.id }"
                    >
                        <span class="lp-nav-dot"></span>
                        {{ section.label }}
                    </a>
                </nav>
                <div class="flex items-center gap-3">
                    <Link
                        v-if="canLogin"
                        href="/login"
                        class="hidden sm:inline-flex h-10 px-4 rounded-full border border-slate-300 text-[11px] font-bold uppercase tracking-[0.18em] items-center justify-center transition-colors hover:bg-slate-900 hover:text-white"
                    >
                        Entrar
                    </Link>
                    <Link
                        :href="primaryCtaHref"
                        class="inline-flex h-10 px-5 rounded-full bg-slate-900 text-white text-[11px] font-bold uppercase tracking-[0.16em] items-center justify-center transition-all hover:bg-[#10B981] hover:text-slate-950"
                    >
                        {{ primaryCtaLabel }}
                    </Link>
                </div>
            </div>
        </header>

        <main class="relative z-10">
            <section
                id="hero"
                data-observe-section="hero"
                class="lp-reveal pt-28 md:pt-32"
                :class="{ 'is-visible': isLoaded || isSectionVisible('hero') }"
            >
                <div class="max-w-[1320px] mx-auto px-6 pb-16 md:pb-24">
                    <div class="grid lg:grid-cols-12 gap-12 items-end">
                        <div class="lg:col-span-7">
                            <p class="text-[11px] font-bold uppercase tracking-[0.26em] text-slate-500 mb-7">
                                Financial clarity engine
                            </p>
                            <h1 class="text-[15vw] sm:text-[10vw] lg:text-[7.3rem] leading-[0.86] tracking-[-0.045em] font-semibold text-slate-950">
                                O fim do mês
                                <br />
                                não precisa
                                <br />
                                ser
                                <span class="hero-accent italic font-serif ml-2">terror.</span>
                            </h1>
                            <p class="max-w-[550px] mt-8 text-lg md:text-xl leading-relaxed text-slate-600">
                                O Kitamo transforma fluxo financeiro em decisão: você vê o que vai acontecer, antes de acontecer.
                            </p>
                            <div class="flex flex-wrap items-center gap-4 mt-10">
                                <Link :href="primaryCtaHref" class="lp-main-cta">
                                    {{ primaryCtaLabel }}
                                </Link>
                                <a href="#process" class="inline-flex items-center gap-2 text-sm font-semibold tracking-wide text-slate-700 hover:text-slate-950">
                                    Ver fluxo completo
                                    <span aria-hidden="true">↓</span>
                                </a>
                            </div>
                        </div>

                        <div class="lg:col-span-5">
                            <div
                                class="hero-scene"
                                @mousemove="handleHeroPointerMove"
                                @mouseleave="resetHeroTilt"
                            >
                                <div class="hero-device" :style="heroTransformStyle">
                                    <div class="hero-device-top">
                                        <div class="h-2.5 w-14 rounded-full bg-white/70"></div>
                                        <div class="h-2.5 w-2.5 rounded-full bg-white/60"></div>
                                    </div>
                                    <div class="hero-device-content">
                                        <div class="hero-spark"></div>
                                        <div class="space-y-3 relative z-10">
                                            <div class="h-3 w-32 rounded-full bg-white/50"></div>
                                            <div class="h-10 w-full rounded-xl bg-white/40"></div>
                                            <div class="h-10 w-11/12 rounded-xl bg-white/30"></div>
                                        </div>
                                        <div class="grid grid-cols-4 gap-2 mt-8 relative z-10">
                                            <div class="h-16 rounded-xl bg-white/35"></div>
                                            <div class="h-24 rounded-xl bg-white/50"></div>
                                            <div class="h-12 rounded-xl bg-white/25"></div>
                                            <div class="h-20 rounded-xl bg-white/40"></div>
                                        </div>
                                        <div class="hero-device-footer relative z-10">
                                            <div class="h-2.5 w-20 rounded-full bg-white/50"></div>
                                            <div class="h-2.5 w-12 rounded-full bg-white/40"></div>
                                        </div>
                                    </div>
                                </div>

                                <div class="hero-float-card hero-float-1">
                                    <p class="text-[10px] uppercase tracking-[0.18em] text-slate-500 mb-1">Projeção</p>
                                    <p class="text-xl font-semibold tracking-tight">+R$ 2.430</p>
                                </div>
                                <div class="hero-float-card hero-float-2">
                                    <p class="text-[10px] uppercase tracking-[0.18em] text-slate-500 mb-1">Vencimentos críticos</p>
                                    <p class="text-xl font-semibold tracking-tight">03 alertas</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="mt-14 rounded-2xl border border-slate-200/80 bg-white/70 overflow-hidden">
                        <div class="ticker-track">
                            <div class="ticker-group">
                                <span v-for="(item, index) in tickerLoop" :key="`ticker-${index}`" class="ticker-pill">
                                    {{ item }}
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <section
                id="pain"
                data-observe-section="pain"
                class="lp-reveal py-16 md:py-24"
                :class="{ 'is-visible': isSectionVisible('pain') }"
            >
                <div class="max-w-[1320px] mx-auto px-6">
                    <div class="grid lg:grid-cols-12 gap-10 items-start">
                        <div class="lg:col-span-4">
                            <p class="text-[11px] font-bold uppercase tracking-[0.24em] text-slate-500 mb-6">Onde dói</p>
                            <h2 class="text-4xl md:text-5xl leading-[1.04] tracking-[-0.03em]">
                                Caos financeiro não é falta de esforço. É falta de leitura do sistema.
                            </h2>
                        </div>
                        <div class="lg:col-span-8">
                            <div class="comparison-shell">
                                <div class="comparison-card">
                                    <p class="comparison-title">Sem Kitamo</p>
                                    <ul class="comparison-list">
                                        <li>Descobre problemas tarde</li>
                                        <li>Decisão por impulso de saldo</li>
                                        <li>Assinaturas invisíveis no mês</li>
                                    </ul>
                                </div>
                                <div class="comparison-divider">→</div>
                                <div class="comparison-card comparison-card-positive">
                                    <p class="comparison-title">Com Kitamo</p>
                                    <ul class="comparison-list">
                                        <li>Antecipação de eventos críticos</li>
                                        <li>Projeção no dia 30 em segundos</li>
                                        <li>Plano semanal de ajuste</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <section
                id="components"
                data-observe-section="components"
                class="lp-reveal py-16 md:py-24"
                :class="{ 'is-visible': isSectionVisible('components') }"
            >
                <div class="max-w-[1320px] mx-auto px-6">
                    <div class="flex flex-wrap justify-between items-end gap-6 mb-10">
                        <div>
                            <p class="text-[11px] font-bold uppercase tracking-[0.24em] text-slate-500 mb-4">Componentes de impacto</p>
                            <h2 class="text-4xl md:text-5xl tracking-[-0.03em] leading-[1.06]">Estrutura visual para guiar decisão</h2>
                        </div>
                        <p class="max-w-md text-slate-600 leading-relaxed">
                            A seção combina blocos “editorial + produto” com microinterações para manter ritmo sem perder clareza.
                        </p>
                    </div>

                    <div class="bento-grid stagger-grid">
                        <article class="bento-card bento-card-xl">
                            <p class="bento-tag">Hero Motion</p>
                            <h3>Headline cinemático com leitura em camadas</h3>
                            <p>Tipografia grande, acento visual e movimento sutil de profundidade no mockup principal.</p>
                        </article>
                        <article class="bento-card">
                            <p class="bento-tag">Data Pulse</p>
                            <h3>Cards que respiram dados</h3>
                            <p>Componentes com hierarquia de informação para contexto rápido.</p>
                        </article>
                        <article class="bento-card">
                            <p class="bento-tag">Flow Guard</p>
                            <h3>Transições que contam história</h3>
                            <p>Entradas por seção com reveal progressivo e ritmo de scroll consistente.</p>
                        </article>
                        <article class="bento-card bento-card-wide">
                            <p class="bento-tag">Narrative Blocks</p>
                            <h3>Bento editorial + funcional</h3>
                            <p>Conteúdo dividido entre dor, solução e prova social para segurar atenção até o final.</p>
                        </article>
                        <article class="bento-card">
                            <p class="bento-tag">Signal UI</p>
                            <h3>Alertas com prioridade visual</h3>
                            <p>Elementos de status em contraste alto para risco e oportunidade.</p>
                        </article>
                        <article class="bento-card">
                            <p class="bento-tag">CTA Engine</p>
                            <h3>Conversão sem ruído</h3>
                            <p>Chamadas repetidas em pontos-chave com copy orientada à ação.</p>
                        </article>
                    </div>
                </div>
            </section>

            <section
                id="process"
                data-observe-section="process"
                class="lp-reveal py-16 md:py-24"
                :class="{ 'is-visible': isSectionVisible('process') }"
            >
                <div class="max-w-[1320px] mx-auto px-6">
                    <div class="grid lg:grid-cols-12 gap-8">
                        <div class="lg:col-span-4">
                            <div class="lg:sticky lg:top-28 space-y-6">
                                <div>
                                    <p class="text-[11px] font-bold uppercase tracking-[0.24em] text-slate-500 mb-4">Fluxo da LP</p>
                                    <h2 class="text-4xl md:text-5xl tracking-[-0.03em] leading-[1.05]">Ordem de fatores até converter</h2>
                                </div>
                                <div class="step-progress-rail" aria-hidden="true">
                                    <span :style="{ width: `${processProgress}%` }"></span>
                                </div>
                                <div class="space-y-3">
                                    <div
                                        v-for="(step, index) in processSteps"
                                        :key="`bullet-${step.num}`"
                                        class="step-chip"
                                        :class="{ 'is-active': activeStepIndex === index }"
                                    >
                                        <span>{{ step.num }}</span>
                                        {{ step.title }}
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="lg:col-span-8 space-y-6">
                            <article
                                v-for="(step, index) in processSteps"
                                :key="step.num"
                                :data-step-index="index"
                                data-step-panel
                                class="process-card"
                                :class="{ 'is-active': activeStepIndex === index }"
                            >
                                <div class="process-content">
                                    <p class="text-[11px] uppercase tracking-[0.22em] text-slate-500 font-bold mb-4">Etapa {{ step.num }}</p>
                                    <h3 class="text-3xl md:text-4xl tracking-[-0.025em] leading-tight mb-5">{{ step.title }}</h3>
                                    <p class="text-slate-600 leading-relaxed text-lg mb-6">{{ step.desc }}</p>
                                    <ul class="space-y-2">
                                        <li v-for="bullet in step.bullets" :key="bullet" class="process-bullet">
                                            <span class="process-bullet-dot"></span>
                                            {{ bullet }}
                                        </li>
                                    </ul>
                                </div>
                                <div class="process-visual">
                                    <template v-if="index === 0">
                                        <div class="visual-grid-bars">
                                            <span class="h-[32%]"></span>
                                            <span class="h-[55%]"></span>
                                            <span class="h-[76%]"></span>
                                            <span class="h-[48%]"></span>
                                            <span class="h-[62%]"></span>
                                        </div>
                                    </template>
                                    <template v-else-if="index === 1">
                                        <div class="alert-stack">
                                            <div class="alert-item">Fatura Nubank vence em 2 dias</div>
                                            <div class="alert-item">Assinatura anual detectada amanhã</div>
                                            <div class="alert-item">Saldo projetado abaixo da meta</div>
                                        </div>
                                    </template>
                                    <template v-else-if="index === 2">
                                        <div class="projection-ring">
                                            <div class="projection-center">30</div>
                                        </div>
                                    </template>
                                    <template v-else>
                                        <div class="decision-lane">
                                            <span class="decision-point is-on"></span>
                                            <span class="decision-point"></span>
                                            <span class="decision-point is-on"></span>
                                            <span class="decision-point"></span>
                                            <span class="decision-point is-on"></span>
                                        </div>
                                    </template>
                                </div>
                            </article>
                        </div>
                    </div>
                </div>
            </section>

            <section
                id="scenarios"
                data-observe-section="scenarios"
                class="lp-reveal py-16 md:py-24"
                :class="{ 'is-visible': isSectionVisible('scenarios') }"
            >
                <div class="max-w-[1320px] mx-auto px-6">
                    <div class="grid lg:grid-cols-12 gap-8 items-start">
                        <div class="lg:col-span-4">
                            <p class="text-[11px] font-bold uppercase tracking-[0.24em] text-slate-500 mb-4">Cenários interativos</p>
                            <h2 class="text-4xl md:text-5xl tracking-[-0.03em] leading-[1.05] mb-6">
                                Simule resultado antes da decisão.
                            </h2>
                            <p class="text-slate-600 leading-relaxed mb-7">
                                Componente inspirado em showcases Awwwards: você alterna contextos e vê impacto imediato sem sair da narrativa.
                            </p>
                            <div class="space-y-2">
                                <button
                                    v-for="(scenario, index) in decisionScenarios"
                                    :key="scenario.label"
                                    type="button"
                                    class="scenario-tab"
                                    :class="{ 'is-active': activeScenarioIndex === index }"
                                    @mouseenter="setActiveScenario(index)"
                                    @focus="setActiveScenario(index)"
                                    @click="setActiveScenario(index)"
                                >
                                    <span>{{ scenario.label }}</span>
                                    <strong>{{ scenario.impact }}</strong>
                                </button>
                            </div>
                        </div>

                        <div class="lg:col-span-8">
                            <article class="scenario-panel">
                                <p class="scenario-kicker">{{ activeScenario.label }}</p>
                                <h3>{{ activeScenario.title }}</h3>
                                <p class="scenario-subtitle">{{ activeScenario.subtitle }}</p>
                                <div class="scenario-impact">
                                    <span>Impacto mensal estimado</span>
                                    <strong>{{ activeScenario.impact }}</strong>
                                </div>
                                <ul class="scenario-notes">
                                    <li v-for="note in activeScenario.notes" :key="note">
                                        <span class="scenario-note-dot"></span>
                                        {{ note }}
                                    </li>
                                </ul>
                            </article>
                        </div>
                    </div>

                    <div class="quick-convert-strip">
                        <p>Entrada grátis • Configuração em minutos • Fluxo orientado por prioridade</p>
                        <Link :href="primaryCtaHref" class="quick-convert-cta">
                            {{ primaryCtaLabel }}
                        </Link>
                    </div>
                </div>
            </section>

            <section
                id="proof"
                data-observe-section="proof"
                class="lp-reveal py-16 md:py-24"
                :class="{ 'is-visible': isSectionVisible('proof') }"
            >
                <div class="max-w-[1320px] mx-auto px-6">
                    <div class="grid lg:grid-cols-12 gap-8 mb-10">
                        <div class="lg:col-span-4">
                            <p class="text-[11px] font-bold uppercase tracking-[0.24em] text-slate-500 mb-4">Provas e confiança</p>
                            <h2 class="text-4xl md:text-5xl tracking-[-0.03em] leading-[1.05]">
                                Design bonito é meio.
                                <br />
                                Resultado previsível é fim.
                            </h2>
                        </div>
                        <div class="lg:col-span-8 grid sm:grid-cols-3 gap-4">
                            <div class="metric-card">
                                <p>Leitura de fluxo</p>
                                <strong>+3x</strong>
                                <span>Mais rapidez para entender o mês</span>
                            </div>
                            <div class="metric-card">
                                <p>Antecipação de risco</p>
                                <strong>-41%</strong>
                                <span>Menos surpresas em vencimentos críticos</span>
                            </div>
                            <div class="metric-card">
                                <p>Decisão segura</p>
                                <strong>+62%</strong>
                                <span>Mais ações preventivas antes do fechamento</span>
                            </div>
                        </div>
                    </div>

                    <div class="grid md:grid-cols-3 gap-4 stagger-grid">
                        <article v-for="item in testimonials" :key="item.name" class="quote-card">
                            <p class="quote-title">{{ item.quote }}</p>
                            <p class="quote-body">{{ item.body }}</p>
                            <div>
                                <p class="quote-name">{{ item.name }}</p>
                                <p class="quote-role">{{ item.role }}</p>
                            </div>
                        </article>
                    </div>
                </div>
            </section>

            <section
                id="faq"
                data-observe-section="faq"
                class="lp-reveal py-16 md:py-24"
                :class="{ 'is-visible': isSectionVisible('faq') }"
            >
                <div class="max-w-[920px] mx-auto px-6">
                    <p class="text-[11px] font-bold uppercase tracking-[0.24em] text-slate-500 mb-4">Objeções comuns</p>
                    <h2 class="text-4xl md:text-5xl tracking-[-0.03em] leading-[1.06] mb-8">Perguntas que travam decisão</h2>
                    <div class="space-y-3">
                        <details class="faq-item" open>
                            <summary>Isso é só um app bonito?</summary>
                            <p>Não. O foco é decisão prática: projeção + alerta + plano semanal de ajuste no mesmo fluxo.</p>
                        </details>
                        <details class="faq-item">
                            <summary>Precisa alimentar manualmente todo dia?</summary>
                            <p>O Kitamo prioriza automação de leitura e organização. Você só entra para decidir, não para sofrer cadastro.</p>
                        </details>
                        <details class="faq-item">
                            <summary>Se eu nunca controlei finanças, funciona?</summary>
                            <p>Sim. A estrutura da LP e do produto é desenhada para reduzir carga cognitiva: contexto, prioridade e próxima ação.</p>
                        </details>
                    </div>
                </div>
            </section>

            <section
                id="cta"
                data-observe-section="cta"
                class="lp-reveal py-20 md:py-28"
                :class="{ 'is-visible': isSectionVisible('cta') }"
            >
                <div class="max-w-[1320px] mx-auto px-6">
                    <div class="final-cta-shell">
                        <p class="text-[11px] font-bold uppercase tracking-[0.24em] text-white/70 mb-6">Decisão final</p>
                        <h2 class="text-[12vw] sm:text-[7.5vw] leading-[0.86] tracking-[-0.04em] font-semibold text-white">
                            Pronto para
                            <br />
                            viver com
                            <span class="text-[#5eead4] italic font-serif">folga?</span>
                        </h2>
                        <p class="max-w-xl mt-7 text-white/80 text-lg leading-relaxed">
                            Você já viu a ordem: dor, clareza, projeção e ação. Agora falta só ativar seu fluxo com o Kitamo.
                        </p>
                        <div class="mt-10 flex flex-wrap gap-4">
                            <Link :href="primaryCtaHref" class="lp-main-cta lp-main-cta-light">
                                {{ primaryCtaLabel }}
                            </Link>
                            <Link
                                v-if="canLogin"
                                href="/login"
                                class="inline-flex h-12 px-7 rounded-full border border-white/35 text-white font-semibold tracking-wide items-center justify-center hover:bg-white hover:text-slate-900 transition-colors"
                            >
                                Já tenho conta
                            </Link>
                        </div>
                    </div>
                    <p class="mt-6 text-[11px] uppercase tracking-[0.22em] text-slate-500">© {{ new Date().getFullYear() }} Kitamo</p>
                </div>
            </section>
        </main>

        <div class="mobile-cta-dock sm:hidden">
            <div class="mobile-cta-shell">
                <p>Ative seu fluxo financeiro</p>
                <Link :href="primaryCtaHref" class="mobile-cta-link">{{ primaryCtaLabel }}</Link>
            </div>
        </div>
    </div>
</template>

<style scoped>
.landing-shell {
    background: linear-gradient(180deg, #f7f7f3 0%, #f0f2ee 55%, #eceee8 100%);
    position: relative;
    overflow: clip;
}

.landing-ambient,
.landing-grid {
    position: fixed;
    inset: 0;
    pointer-events: none;
}

.landing-ambient {
    background:
        radial-gradient(55rem 55rem at 10% 10%, rgba(16, 185, 129, 0.18), transparent 60%),
        radial-gradient(44rem 44rem at 90% 18%, rgba(15, 23, 42, 0.08), transparent 64%),
        radial-gradient(36rem 36rem at 50% 78%, rgba(2, 132, 199, 0.09), transparent 70%);
    z-index: 0;
}

.landing-grid {
    z-index: 1;
    opacity: 0.32;
    background-image:
        linear-gradient(to right, rgba(15, 23, 42, 0.08) 1px, transparent 1px),
        linear-gradient(to bottom, rgba(15, 23, 42, 0.08) 1px, transparent 1px);
    background-size: 70px 70px;
    mask-image: radial-gradient(circle at center, black, transparent 78%);
}

.lp-reveal {
    opacity: 0;
    transform: translateY(34px);
    transition:
        opacity 0.8s cubic-bezier(0.2, 0.8, 0.2, 1),
        transform 0.8s cubic-bezier(0.2, 0.8, 0.2, 1);
}

.lp-reveal.is-visible {
    opacity: 1;
    transform: none;
}

.stagger-grid > * {
    opacity: 0;
    transform: translateY(18px);
    transition:
        opacity 0.65s cubic-bezier(0.2, 0.8, 0.2, 1),
        transform 0.65s cubic-bezier(0.2, 0.8, 0.2, 1);
}

.lp-reveal.is-visible .stagger-grid > * {
    opacity: 1;
    transform: none;
}

.lp-reveal.is-visible .stagger-grid > *:nth-child(1) {
    transition-delay: 70ms;
}

.lp-reveal.is-visible .stagger-grid > *:nth-child(2) {
    transition-delay: 130ms;
}

.lp-reveal.is-visible .stagger-grid > *:nth-child(3) {
    transition-delay: 190ms;
}

.lp-reveal.is-visible .stagger-grid > *:nth-child(4) {
    transition-delay: 250ms;
}

.lp-reveal.is-visible .stagger-grid > *:nth-child(5) {
    transition-delay: 310ms;
}

.lp-reveal.is-visible .stagger-grid > *:nth-child(6) {
    transition-delay: 370ms;
}

.lp-nav-link {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    font-size: 10px;
    letter-spacing: 0.16em;
    text-transform: uppercase;
    font-weight: 700;
    color: #64748b;
    transition: color 250ms ease;
}

.lp-nav-link:hover,
.lp-nav-link.is-active {
    color: #0f172a;
}

.lp-nav-dot {
    width: 7px;
    height: 7px;
    border-radius: 9999px;
    border: 1px solid currentColor;
    display: inline-block;
}

.lp-nav-link.is-active .lp-nav-dot {
    background: currentColor;
}

.hero-accent {
    color: #0f766e;
}

.lp-main-cta {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    height: 50px;
    padding: 0 28px;
    border-radius: 9999px;
    font-size: 13px;
    text-transform: uppercase;
    letter-spacing: 0.14em;
    font-weight: 800;
    background: #0f172a;
    color: #fff;
    transition:
        transform 220ms ease,
        background-color 220ms ease,
        color 220ms ease,
        box-shadow 220ms ease;
    box-shadow: 0 14px 28px -16px rgba(15, 23, 42, 0.75);
}

.lp-main-cta:hover {
    transform: translateY(-2px);
    background: #10b981;
    color: #052e2c;
    box-shadow: 0 22px 34px -20px rgba(16, 185, 129, 0.75);
}

.lp-main-cta-light {
    background: #ecfeff;
    color: #0f172a;
}

.lp-main-cta-light:hover {
    background: #5eead4;
    color: #042f2e;
}

.hero-scene {
    position: relative;
    min-height: 500px;
}

.hero-device {
    background: linear-gradient(160deg, #0f172a, #1e293b);
    border-radius: 32px;
    border: 1px solid rgba(255, 255, 255, 0.12);
    min-height: 490px;
    padding: 18px;
    transform-style: preserve-3d;
    transition: transform 300ms ease;
    box-shadow:
        0 40px 80px -40px rgba(2, 6, 23, 0.85),
        inset 0 1px 0 rgba(255, 255, 255, 0.25);
}

.hero-device-top {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 14px;
}

.hero-device-content {
    position: relative;
    background: linear-gradient(150deg, rgba(100, 116, 139, 0.4), rgba(30, 41, 59, 0.2));
    border: 1px solid rgba(255, 255, 255, 0.14);
    border-radius: 24px;
    padding: 18px;
    min-height: 420px;
    overflow: hidden;
}

.hero-spark {
    position: absolute;
    inset: -120%;
    background: linear-gradient(130deg, transparent 48%, rgba(255, 255, 255, 0.45), transparent 52%);
    animation: lpSweep 6.3s linear infinite;
}

.hero-device-footer {
    margin-top: 20px;
    display: flex;
    justify-content: space-between;
}

.hero-float-card {
    position: absolute;
    background: rgba(255, 255, 255, 0.88);
    border: 1px solid rgba(15, 23, 42, 0.08);
    box-shadow: 0 20px 35px -24px rgba(15, 23, 42, 0.45);
    border-radius: 18px;
    padding: 12px 14px;
    min-width: 160px;
    animation: lpFloat 4.8s ease-in-out infinite;
}

.hero-float-1 {
    top: 26px;
    left: -28px;
}

.hero-float-2 {
    bottom: 26px;
    right: -26px;
    animation-delay: -2.2s;
}

.ticker-track {
    overflow: hidden;
    position: relative;
}

.ticker-group {
    display: flex;
    align-items: center;
    width: max-content;
    animation: lpTicker 24s linear infinite;
}

.ticker-pill {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    height: 56px;
    padding: 0 26px;
    border-right: 1px solid rgba(148, 163, 184, 0.3);
    font-size: 12px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.12em;
    color: #475569;
}

.comparison-shell {
    display: grid;
    gap: 14px;
    grid-template-columns: 1fr auto 1fr;
    align-items: stretch;
}

.comparison-card {
    background: rgba(255, 255, 255, 0.78);
    border: 1px solid rgba(15, 23, 42, 0.1);
    border-radius: 22px;
    padding: 24px;
}

.comparison-card-positive {
    border-color: rgba(16, 185, 129, 0.5);
    box-shadow: 0 20px 34px -28px rgba(16, 185, 129, 0.65);
}

.comparison-title {
    font-size: 11px;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 0.22em;
    margin-bottom: 18px;
    color: #334155;
}

.comparison-list {
    display: grid;
    gap: 12px;
    color: #1e293b;
    font-weight: 500;
}

.comparison-divider {
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 30px;
    font-weight: 300;
    color: rgba(15, 23, 42, 0.4);
    padding: 0 6px;
}

.bento-grid {
    display: grid;
    grid-template-columns: repeat(12, minmax(0, 1fr));
    gap: 14px;
}

.bento-card {
    grid-column: span 4;
    min-height: 210px;
    border-radius: 24px;
    border: 1px solid rgba(15, 23, 42, 0.12);
    background: rgba(255, 255, 255, 0.78);
    padding: 22px;
    display: flex;
    flex-direction: column;
    justify-content: flex-end;
    transition:
        transform 280ms ease,
        box-shadow 280ms ease,
        border-color 280ms ease;
}

.bento-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 22px 35px -26px rgba(15, 23, 42, 0.48);
    border-color: rgba(15, 23, 42, 0.24);
}

.bento-card h3 {
    font-size: 27px;
    line-height: 1.03;
    letter-spacing: -0.02em;
    margin-bottom: 10px;
}

.bento-card p {
    color: #475569;
    line-height: 1.5;
}

.bento-card .bento-tag {
    margin-bottom: auto;
    color: #64748b;
    font-size: 10px;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 0.2em;
}

.bento-card-xl {
    grid-column: span 6;
    min-height: 280px;
    background: linear-gradient(140deg, rgba(15, 23, 42, 0.9), rgba(15, 118, 110, 0.85));
    color: #ecfeff;
}

.bento-card-xl p,
.bento-card-xl .bento-tag {
    color: rgba(236, 254, 255, 0.83);
}

.bento-card-wide {
    grid-column: span 6;
}

.step-chip {
    border-radius: 9999px;
    border: 1px solid rgba(15, 23, 42, 0.15);
    background: rgba(255, 255, 255, 0.72);
    color: #334155;
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 0.12em;
    font-weight: 700;
    padding: 10px 14px;
    display: flex;
    align-items: center;
    gap: 10px;
    transition:
        border-color 240ms ease,
        color 240ms ease,
        transform 240ms ease;
}

.step-chip span {
    font-size: 10px;
    letter-spacing: 0.16em;
    color: #64748b;
}

.step-chip.is-active {
    border-color: rgba(15, 118, 110, 0.65);
    color: #0f172a;
    transform: translateX(4px);
}

.step-progress-rail {
    width: 100%;
    max-width: 260px;
    height: 4px;
    border-radius: 9999px;
    background: rgba(148, 163, 184, 0.32);
    overflow: hidden;
}

.step-progress-rail span {
    display: block;
    width: 0;
    background: linear-gradient(90deg, #0f766e, #14b8a6);
    height: 100%;
    transition: width 320ms ease;
}

.process-card {
    border-radius: 28px;
    border: 1px solid rgba(15, 23, 42, 0.12);
    background: rgba(255, 255, 255, 0.78);
    padding: 24px;
    display: grid;
    grid-template-columns: 1.3fr 1fr;
    gap: 20px;
    min-height: 340px;
    transition:
        transform 240ms ease,
        border-color 240ms ease,
        box-shadow 240ms ease;
}

.process-card.is-active {
    border-color: rgba(15, 118, 110, 0.62);
    transform: translateY(-2px);
    box-shadow: 0 24px 36px -30px rgba(15, 118, 110, 0.62);
}

.process-bullet {
    display: flex;
    align-items: center;
    gap: 10px;
    font-weight: 600;
    color: #334155;
}

.process-bullet-dot {
    width: 8px;
    height: 8px;
    border-radius: 9999px;
    background: #0f766e;
}

.process-visual {
    border-radius: 20px;
    background: linear-gradient(145deg, rgba(15, 23, 42, 0.92), rgba(15, 118, 110, 0.78));
    border: 1px solid rgba(255, 255, 255, 0.18);
    padding: 18px;
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: hidden;
}

.visual-grid-bars {
    width: 100%;
    height: 180px;
    display: grid;
    grid-template-columns: repeat(5, 1fr);
    align-items: end;
    gap: 10px;
}

.visual-grid-bars span {
    display: block;
    border-radius: 12px 12px 6px 6px;
    background: rgba(236, 253, 245, 0.8);
    animation: lpPulse 2.8s ease-in-out infinite;
}

.visual-grid-bars span:nth-child(2) {
    animation-delay: -0.4s;
}

.visual-grid-bars span:nth-child(3) {
    animation-delay: -0.9s;
}

.visual-grid-bars span:nth-child(4) {
    animation-delay: -0.3s;
}

.visual-grid-bars span:nth-child(5) {
    animation-delay: -1.1s;
}

.alert-stack {
    display: grid;
    gap: 10px;
    width: 100%;
}

.alert-item {
    border-radius: 14px;
    background: rgba(255, 255, 255, 0.9);
    color: #0f172a;
    font-weight: 700;
    font-size: 12px;
    line-height: 1.4;
    padding: 12px;
}

.projection-ring {
    width: 160px;
    height: 160px;
    border-radius: 9999px;
    border: 1px dashed rgba(255, 255, 255, 0.55);
    display: flex;
    align-items: center;
    justify-content: center;
    position: relative;
}

.projection-ring::before {
    content: '';
    position: absolute;
    width: 112px;
    height: 112px;
    border-radius: 9999px;
    border: 1px solid rgba(94, 234, 212, 0.6);
}

.projection-center {
    font-size: 42px;
    font-weight: 500;
    color: #ecfeff;
}

.decision-lane {
    width: 100%;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.decision-point {
    width: 22px;
    height: 22px;
    border-radius: 9999px;
    border: 1px solid rgba(236, 253, 245, 0.65);
}

.decision-point.is-on {
    background: #5eead4;
    border-color: #5eead4;
    box-shadow: 0 0 20px rgba(94, 234, 212, 0.58);
}

.scenario-tab {
    width: 100%;
    border-radius: 16px;
    border: 1px solid rgba(15, 23, 42, 0.13);
    background: rgba(255, 255, 255, 0.72);
    padding: 14px 16px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    color: #334155;
    transition:
        border-color 240ms ease,
        background-color 240ms ease,
        transform 240ms ease;
}

.scenario-tab span {
    font-size: 12px;
    font-weight: 800;
    letter-spacing: 0.16em;
    text-transform: uppercase;
}

.scenario-tab strong {
    font-size: 16px;
    font-weight: 700;
    letter-spacing: -0.01em;
}

.scenario-tab:hover,
.scenario-tab.is-active {
    border-color: rgba(15, 118, 110, 0.7);
    background: rgba(236, 253, 245, 0.95);
    transform: translateX(4px);
}

.scenario-panel {
    border-radius: 30px;
    border: 1px solid rgba(15, 23, 42, 0.12);
    padding: 30px;
    min-height: 420px;
    background:
        radial-gradient(30rem 30rem at 8% 10%, rgba(94, 234, 212, 0.16), transparent 68%),
        linear-gradient(145deg, rgba(255, 255, 255, 0.9), rgba(248, 250, 252, 0.95));
    box-shadow: 0 25px 40px -34px rgba(15, 23, 42, 0.45);
}

.scenario-kicker {
    font-size: 11px;
    font-weight: 800;
    letter-spacing: 0.2em;
    text-transform: uppercase;
    color: #64748b;
    margin-bottom: 12px;
}

.scenario-panel h3 {
    font-size: clamp(2rem, 4vw, 3.25rem);
    line-height: 0.98;
    letter-spacing: -0.025em;
    color: #0f172a;
    margin-bottom: 12px;
}

.scenario-subtitle {
    max-width: 560px;
    color: #475569;
    font-size: 1.05rem;
    line-height: 1.6;
}

.scenario-impact {
    margin-top: 28px;
    border: 1px solid rgba(15, 23, 42, 0.1);
    border-radius: 18px;
    background: rgba(255, 255, 255, 0.8);
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 14px 16px;
}

.scenario-impact span {
    color: #64748b;
    text-transform: uppercase;
    letter-spacing: 0.14em;
    font-size: 11px;
    font-weight: 800;
}

.scenario-impact strong {
    font-size: 2rem;
    letter-spacing: -0.03em;
    color: #0f172a;
}

.scenario-notes {
    margin-top: 20px;
    display: grid;
    gap: 10px;
}

.scenario-notes li {
    display: flex;
    align-items: center;
    gap: 10px;
    color: #334155;
    font-weight: 600;
}

.scenario-note-dot {
    width: 8px;
    height: 8px;
    border-radius: 9999px;
    background: #0f766e;
}

.quick-convert-strip {
    margin-top: 20px;
    border-radius: 20px;
    border: 1px solid rgba(15, 23, 42, 0.12);
    background: rgba(15, 23, 42, 0.92);
    color: rgba(236, 253, 245, 0.92);
    padding: 15px 18px;
    display: flex;
    gap: 16px;
    align-items: center;
    justify-content: space-between;
}

.quick-convert-strip p {
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 0.16em;
    text-transform: uppercase;
    line-height: 1.5;
}

.quick-convert-cta {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    height: 40px;
    padding: 0 20px;
    border-radius: 9999px;
    background: #5eead4;
    color: #042f2e;
    font-weight: 800;
    font-size: 11px;
    letter-spacing: 0.14em;
    text-transform: uppercase;
    transition:
        transform 220ms ease,
        background-color 220ms ease;
}

.quick-convert-cta:hover {
    transform: translateY(-1px);
    background: #99f6e4;
}

.metric-card {
    border-radius: 20px;
    border: 1px solid rgba(15, 23, 42, 0.13);
    background: rgba(255, 255, 255, 0.8);
    padding: 20px;
}

.metric-card p {
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: 0.16em;
    font-weight: 700;
    color: #64748b;
}

.metric-card strong {
    display: block;
    margin: 8px 0 7px;
    font-size: 46px;
    line-height: 1;
    letter-spacing: -0.03em;
    color: #0f172a;
}

.metric-card span {
    color: #475569;
    line-height: 1.45;
}

.quote-card {
    border-radius: 20px;
    border: 1px solid rgba(15, 23, 42, 0.11);
    background: rgba(255, 255, 255, 0.82);
    padding: 22px;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    min-height: 240px;
}

.quote-title {
    font-size: 31px;
    line-height: 1.04;
    letter-spacing: -0.02em;
    margin-bottom: 14px;
    color: #0f172a;
    font-family: ui-serif, Georgia, Cambria, "Times New Roman", Times, serif;
    font-style: italic;
}

.quote-body {
    color: #475569;
    line-height: 1.55;
    margin-bottom: 24px;
}

.quote-name {
    font-size: 12px;
    letter-spacing: 0.16em;
    text-transform: uppercase;
    font-weight: 800;
    color: #0f172a;
}

.quote-role {
    font-size: 10px;
    letter-spacing: 0.19em;
    text-transform: uppercase;
    color: #64748b;
    margin-top: 6px;
}

.faq-item {
    border-radius: 16px;
    border: 1px solid rgba(15, 23, 42, 0.12);
    background: rgba(255, 255, 255, 0.82);
    padding: 16px 18px;
}

.faq-item summary {
    cursor: pointer;
    list-style: none;
    font-weight: 700;
    letter-spacing: -0.01em;
    color: #0f172a;
}

.faq-item summary::-webkit-details-marker {
    display: none;
}

.faq-item p {
    margin-top: 10px;
    color: #475569;
    line-height: 1.55;
}

.final-cta-shell {
    border-radius: 32px;
    border: 1px solid rgba(255, 255, 255, 0.18);
    padding: 32px;
    background:
        radial-gradient(36rem 36rem at 10% 0%, rgba(94, 234, 212, 0.25), transparent 60%),
        radial-gradient(32rem 32rem at 90% 100%, rgba(6, 182, 212, 0.22), transparent 70%),
        linear-gradient(145deg, #0f172a, #0f766e);
    position: relative;
    overflow: hidden;
}

.final-cta-shell::after {
    content: '';
    position: absolute;
    inset: 0;
    background: linear-gradient(120deg, transparent 0%, rgba(255, 255, 255, 0.22) 48%, transparent 54%);
    transform: translateX(-120%);
    animation: lpSweep 7.5s linear infinite;
}

.mobile-cta-dock {
    position: fixed;
    left: 0;
    right: 0;
    bottom: 10px;
    z-index: 60;
    pointer-events: none;
    padding: 0 12px;
}

.mobile-cta-shell {
    pointer-events: auto;
    border: 1px solid rgba(255, 255, 255, 0.22);
    border-radius: 16px;
    backdrop-filter: blur(14px);
    background: rgba(15, 23, 42, 0.9);
    color: rgba(236, 253, 245, 0.88);
    padding: 10px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 8px;
}

.mobile-cta-shell p {
    font-size: 10px;
    text-transform: uppercase;
    letter-spacing: 0.14em;
    font-weight: 700;
}

.mobile-cta-link {
    height: 38px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    border-radius: 9999px;
    background: #5eead4;
    color: #052e2c;
    font-size: 10px;
    text-transform: uppercase;
    letter-spacing: 0.14em;
    font-weight: 800;
    padding: 0 14px;
}

@keyframes lpSweep {
    from {
        transform: translateX(-120%);
    }
    to {
        transform: translateX(120%);
    }
}

@keyframes lpFloat {
    0%,
    100% {
        transform: translateY(0);
    }
    50% {
        transform: translateY(-7px);
    }
}

@keyframes lpTicker {
    from {
        transform: translateX(0);
    }
    to {
        transform: translateX(-50%);
    }
}

@keyframes lpPulse {
    0%,
    100% {
        opacity: 0.42;
    }
    50% {
        opacity: 1;
    }
}

@media (max-width: 1200px) {
    .bento-card,
    .bento-card-xl,
    .bento-card-wide {
        grid-column: span 6;
    }
}

@media (max-width: 1024px) {
    .hero-float-1 {
        top: 14px;
        left: 8px;
    }

    .hero-float-2 {
        right: 8px;
        bottom: 12px;
    }

    .process-card {
        grid-template-columns: 1fr;
    }

    .quick-convert-strip {
        flex-direction: column;
        align-items: flex-start;
    }
}

@media (max-width: 768px) {
    .comparison-shell {
        grid-template-columns: 1fr;
    }

    .comparison-divider {
        font-size: 22px;
    }

    .bento-card,
    .bento-card-xl,
    .bento-card-wide {
        grid-column: span 12;
    }

    .hero-scene {
        min-height: 430px;
    }

    .hero-device {
        min-height: 410px;
    }

    .hero-device-content {
        min-height: 340px;
    }

    .metric-card strong {
        font-size: 38px;
    }

    .quote-title {
        font-size: 27px;
    }

    .final-cta-shell {
        padding: 26px;
    }

    .scenario-panel {
        padding: 24px;
        min-height: 0;
    }

    .scenario-impact {
        flex-direction: column;
        align-items: flex-start;
        gap: 6px;
    }
}

@media (prefers-reduced-motion: reduce) {
    .lp-reveal {
        opacity: 1;
        transform: none;
        transition: none;
    }

    .hero-device,
    .hero-float-card,
    .hero-spark,
    .ticker-group,
    .final-cta-shell::after,
    .visual-grid-bars span,
    .stagger-grid > * {
        animation: none !important;
        transition: none !important;
        transform: none !important;
    }
}
</style>
