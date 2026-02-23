<script setup lang="ts">
import { onMounted, onUnmounted } from 'vue';
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';
import MotionSection from '@/Components/site/MotionSection.vue';
import AnimatedDashboardMockup from '@/Components/site/AnimatedDashboardMockup.vue';

const props = defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

// Scroll-stagger animation for rhythm cards (Todoist-style)
const cardObservers: IntersectionObserver[] = [];

function registerCard(el: HTMLElement | null, index: number) {
    if (!el) return;
    // Set initial hidden state
    el.style.opacity = '0';
    el.style.transform = 'translateY(48px)';
    el.style.transition = `opacity 0.65s cubic-bezier(0.16, 1, 0.3, 1) ${index * 120}ms, transform 0.65s cubic-bezier(0.16, 1, 0.3, 1) ${index * 120}ms`;

    const obs = new IntersectionObserver(
        (entries) => {
            if (entries[0].isIntersecting) {
                el.style.opacity = '1';
                el.style.transform = 'translateY(0)';
                obs.disconnect();
            }
        },
        { threshold: 0.15 }
    );
    obs.observe(el);
    cardObservers.push(obs);
}

// Fade-in observer for persona content (NOT background)
function registerFadeElement(el: HTMLElement | null, delay: number = 0) {
    if (!el) return;
    el.style.opacity = '0';
    el.style.transform = 'translateY(32px)';
    el.style.transition = `opacity 0.6s cubic-bezier(0.16, 1, 0.3, 1) ${delay}ms, transform 0.6s cubic-bezier(0.16, 1, 0.3, 1) ${delay}ms`;

    const obs = new IntersectionObserver(
        (entries) => {
            if (entries[0].isIntersecting) {
                el.style.opacity = '1';
                el.style.transform = 'translateY(0)';
                obs.disconnect();
            }
        },
        { threshold: 0.15 }
    );
    obs.observe(el);
    cardObservers.push(obs);
}

onUnmounted(() => cardObservers.forEach(o => o.disconnect()));

const primaryHref = props.canRegister ? '/register' : '/login';

// Persona data - for the horizontally-scrolling "scenario tickets"
const personaCards = [
    {
        title: 'A Galera CLT',
        subtitle: 'Boleto no Dia Certo',
        description: 'Conecte seus gastos ao ciclo do pagamento. Semana a semana, sem cheque especial.',
        accent: '#14B8A6',
        accentLabel: 'teal',
        icon: 'M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z',
        stat: { label: 'R$ 2.700', sub: 'sobrando esta semana', progress: 56 },
    },
    {
        title: 'Para Casais',
        subtitle: 'Paz Conjugal',
        description: 'Juntem as rendas num mapa único. Zero briga por extrato surpresa.',
        accent: '#06B6D4',
        accentLabel: 'cyan',
        icon: 'M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z',
        stat: { label: 'R$ 6.000', sub: 'conta compartilhada', progress: 100 },
    },
    {
        title: 'Freelas & Autônomos',
        subtitle: 'Domando o Imprevisível',
        description: 'Ganhou bem? Joga pra frente. O Kitamo nivela a montanha-russa.',
        accent: '#F59E0B',
        accentLabel: 'amber',
        icon: 'M13 10V3L4 14h7v7l9-11h-7z',
        stat: { label: 'R$ 6.900', sub: 'média mensal', progress: 73 },
    },
];

const serviceBlocks = [
    {
        title: 'Previsão Pura',
        description: 'Seu saldo em 30, 60 ou 90 dias.',
        icon: 'M13 7h8m0 0v8m0-8l-8 8-4-4-6 6',
        col: 'md:col-span-4'
    },
    {
        title: 'Zero Planilhas Feias',
        description: 'Adeus formatações condicionais que sempre quebram.',
        icon: 'M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z',
        col: 'md:col-span-4'
    },
    {
        title: 'Multicontas reais',
        description: 'Tudo num lugar só, mas separado do seu jeito.',
        icon: 'M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 002-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10',
        col: 'md:col-span-4'
    },
];
</script>

<template>
    <Head title="Kitamo | O Design do Seu Mês">
        <meta name="description" content="Kitamo é a sua paz financeira. Organização focada em antecipação de caixa e decisão rápida." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        
        <!-- ================= HERO ================= -->
        <MotionSection class="relative min-h-[100vh] w-full bg-slate-950 text-white flex flex-col justify-center pt-32">
            <!-- Background Container to clip orbs -->
            <div class="absolute inset-0 overflow-hidden pointer-events-none">
                <!-- Noise Texture -->
                <div class="absolute inset-0 opacity-[0.025] mix-blend-overlay" style="background-image: url('data:image/svg+xml,%3Csvg viewBox=%220 0 200 200%22 xmlns=%22http://www.w3.org/2000/svg%22%3E%3Cfilter id=%22noiseFilter%22%3E%3CfeTurbulence type=%22fractalNoise%22 baseFrequency=%220.8%22 numOctaves=%224%22 stitchTiles=%22stitch%22/%3E%3C/filter%3E%3Crect width=%22100%25%22 height=%22100%25%22 filter=%22url(%23noiseFilter)%22/%3E%3C/svg%3E');"></div>
                
                <!-- Dynamic Orbs -->
                <div class="absolute -top-40 -left-40 w-[600px] h-[600px] rounded-full bg-teal-600/20 blur-[150px] mix-blend-screen opacity-70 animate-pulse"></div>
                <div class="absolute bottom-0 right-0 w-[500px] h-[500px] rounded-full bg-cyan-600/10 blur-[130px] mix-blend-screen opacity-50"></div>
            </div>

            <div class="relative z-10 mx-auto w-full max-w-[1440px] px-6 md:px-12 flex flex-col items-center text-center">
                <!-- Status Badge -->
                <div class="inline-flex items-center gap-3 bg-white/5 border border-white/10 px-5 py-2.5 rounded-full backdrop-blur-md mb-8 group hover:bg-white/10 transition-colors cursor-pointer shadow-lg shadow-black/20">
                    <span class="relative flex h-3 w-3">
                        <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-teal-400 opacity-75"></span>
                        <span class="relative inline-flex rounded-full h-3 w-3 bg-teal-500"></span>
                    </span>
                    <span class="text-[11px] font-extrabold uppercase tracking-[0.2em] text-teal-300">O fim das planilhas</span>
                </div>

                <!-- Epic Typography -->
                <h1 class="text-[4.5rem] sm:text-[6rem] lg:text-[8.5rem] leading-[0.85] tracking-tighter text-slate-50 font-extrabold max-w-5xl">
                    Seu dinheiro.<br>
                    <span class="text-transparent bg-clip-text bg-gradient-to-r from-teal-400 via-cyan-300 to-emerald-400 font-serif italic pr-4">Visível hoje.</span>
                </h1>
                
                <p class="mt-8 text-xl sm:text-2xl leading-relaxed text-slate-400 font-medium max-w-2xl mx-auto drop-shadow-sm">
                    Antecipe furos, controle faturas e feche o mês com tranquilidade. Totalmente online.
                </p>

                <!-- Dual Action Hero -->
                <div class="mt-14 flex flex-col items-center w-full">
                    <div class="flex flex-col sm:flex-row gap-5 items-center w-full sm:w-auto">
                        <Link :href="primaryHref" class="w-full sm:w-auto inline-flex h-16 items-center justify-center rounded-[2rem] bg-teal-500 px-10 text-[13px] font-extrabold uppercase tracking-[0.15em] text-slate-950 transition-[transform,background-color,box-shadow] hover:bg-teal-400 hover:scale-105 active:scale-95 shadow-[0_0_40px_theme(colors.teal.500/40)] focus-visible:ring-4 focus-visible:ring-teal-400">
                            Assumir o Controle
                        </Link>
                        <Link :href="route('site.product')" class="w-full sm:w-auto inline-flex h-16 items-center justify-center rounded-[2rem] border-2 border-slate-700 bg-transparent px-10 text-[13px] font-extrabold uppercase tracking-[0.15em] text-slate-300 transition-[border-color,color,background-color] hover:border-slate-500 hover:text-white hover:bg-white/5 active:scale-95 focus-visible:ring-4 focus-visible:ring-slate-500">
                            Como a máquina roda?
                        </Link>
                    </div>
                    <div class="mt-8 flex flex-col items-center gap-3">
                        <p class="text-slate-400 text-[13px] font-medium tracking-wide">Leva 2 minutos. Sem cartão de crédito.</p>
                    </div>
                </div>
            </div>

            <!-- Floating UI Preview (Breaks the next section) -->
            <div class="relative mx-auto w-[90%] max-w-[1200px] z-20 perspective-1000 mt-20 sm:mt-24 lg:mt-32 -mb-32 sm:-mb-40 lg:-mb-56">
                <div class="absolute inset-0 bg-teal-500/10 rounded-[4rem] blur-3xl transform -translate-y-10"></div>
                <div class="relative rounded-[2.5rem] sm:rounded-[4rem] border border-white/10 bg-slate-900/80 backdrop-blur-sm shadow-[0_30px_60px_-15px_rgba(0,0,0,0.8)] overflow-hidden transition-transform duration-1000 transform hover:-translate-y-4 rotate-x-6 hover:rotate-x-0 group">
                    <AnimatedDashboardMockup />
                    <div class="absolute inset-x-0 bottom-0 h-16 bg-gradient-to-t from-slate-950/60 to-transparent pointer-events-none"></div>
                </div>
            </div>
        </MotionSection>

        <!-- Spacer for the intersecting hero image -->
        <div class="bg-slate-50 h-32 sm:h-48 lg:h-64 border-t border-slate-200"></div>

        <!-- ================= QUEM USA O KITAMO — Scenario Tickets ================= -->
        <!-- NO MotionSection wrapper — background is always slate-50, only inner content fades -->
        <section class="bg-slate-50 py-24 pb-40">
            <div class="mx-auto w-full max-w-[1440px] px-6 md:px-12">
                <!-- Header with fade-in -->
                <div :ref="(el) => registerFadeElement(el as HTMLElement, 0)" class="flex flex-col md:flex-row items-end justify-between gap-10 mb-20 text-slate-900 border-b border-slate-200 pb-16">
                    <div class="max-w-3xl">
                        <p class="text-[12px] font-extrabold uppercase tracking-[0.2em] text-teal-600 mb-6 drop-shadow-sm bg-teal-50 px-4 py-2 rounded-full border border-teal-100 w-fit">Qual a sua dor hoje?</p>
                        <h2 class="text-5xl lg:text-[5rem] font-extrabold tracking-tighter leading-[0.95]">
                            Uma ferramenta.<br><span class="font-serif italic text-slate-500">Múltiplas vidas salvas.</span>
                        </h2>
                    </div>
                    <p class="max-w-sm text-lg font-medium text-slate-500 leading-relaxed md:text-right">A inteligência do Kitamo se adapta ao formato da sua bagunça financeira.</p>
                </div>

                <!-- Scenario Ticket Strip — horizontal cards with unique visual per persona -->
                <div :ref="(el) => registerFadeElement(el as HTMLElement, 150)" class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                    <div 
                        v-for="card in personaCards" 
                        :key="card.title" 
                        class="group relative overflow-hidden rounded-[2rem] border border-slate-200 bg-white cursor-pointer hover:shadow-2xl hover:-translate-y-1 transition-all duration-500"
                    >
                        <!-- Accent top stripe -->
                        <div class="h-1.5 w-full" :style="`background: ${card.accent}`"></div>
                        
                        <div class="p-8 pb-6">
                            <!-- Badge + Icon row -->
                            <div class="flex items-center gap-3 mb-5">
                                <div class="w-11 h-11 rounded-2xl flex items-center justify-center" :style="`background: ${card.accent}12`">
                                    <svg class="w-5 h-5" :style="`color: ${card.accent}`" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" :d="card.icon" /></svg>
                                </div>
                                <span class="text-[10px] font-extrabold uppercase tracking-[0.2em] px-3 py-1 rounded-full border" :style="`color: ${card.accent}; background: ${card.accent}08; border-color: ${card.accent}25`">{{ card.subtitle }}</span>
                            </div>
                            
                            <!-- Title -->
                            <h3 class="text-2xl font-extrabold tracking-tight text-slate-900 mb-2">{{ card.title }}</h3>
                            <p class="text-sm text-slate-500 font-medium leading-relaxed mb-6">{{ card.description }}</p>
                            
                            <!-- Inline stat mockup -->
                            <div class="bg-slate-50 rounded-2xl p-5 border border-slate-100">
                                <div class="flex items-baseline justify-between mb-3">
                                    <span class="text-2xl font-extrabold tracking-tight" :style="`color: ${card.accent}`">{{ card.stat.label }}</span>
                                    <span class="text-[10px] font-bold uppercase tracking-widest text-slate-400">{{ card.stat.sub }}</span>
                                </div>
                                <div class="h-2 bg-slate-200 rounded-full overflow-hidden">
                                    <div class="h-full rounded-full transition-all duration-1000 group-hover:brightness-110" :style="`width: ${card.stat.progress}%; background: ${card.accent}`"></div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Bottom CTA -->
                        <div class="px-8 pb-6">
                            <Link :href="primaryHref" class="inline-flex h-10 items-center text-[11px] font-extrabold uppercase tracking-[0.15em] text-slate-500 group-hover:text-slate-900 transition-colors gap-2">
                                Começar agora
                                <svg class="w-4 h-4 group-hover:translate-x-1 transition-transform" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M14 5l7 7m0 0l-7 7m7-7H3"/></svg>
                            </Link>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- ================= O RITMO — reimagined (Linear/Stripe-style) ================= -->
        <section class="bg-slate-950 relative text-white overflow-hidden">
            <!-- Noise texture -->
            <div class="absolute inset-0 opacity-[0.02] mix-blend-overlay pointer-events-none" style="background-image: url('data:image/svg+xml,%3Csvg viewBox=%220 0 200 200%22 xmlns=%22http://www.w3.org/2000/svg%22%3E%3Cfilter id=%22n%22%3E%3CfeTurbulence type=%22fractalNoise%22 baseFrequency=%220.9%22 numOctaves=%224%22 stitchTiles=%22stitch%22/%3E%3C/filter%3E%3Crect width=%22100%25%22 height=%22100%25%22 filter=%22url(%23n)%22/%3E%3C/svg%3E');"></div>

            <div class="max-w-[1440px] mx-auto px-6 md:px-12 relative z-10">

                <!-- Section header -->
                <div class="pt-32 pb-20 lg:pb-28 max-w-3xl">
                    <p class="inline-flex items-center gap-2 text-[11px] font-extrabold uppercase tracking-[0.25em] text-teal-400 mb-8 px-4 py-2 rounded-full border border-teal-500/20 bg-teal-500/10 w-fit">
                        <span class="w-1.5 h-1.5 rounded-full bg-teal-400 animate-pulse"></span>
                        O sistema de 4 passos
                    </p>
                    <h2 class="text-5xl lg:text-[5.5rem] font-extrabold tracking-tighter text-white leading-[0.88] mb-8">
                        O<br><span class="text-transparent bg-clip-text bg-gradient-to-br from-teal-300 to-emerald-400">ritmo.</span>
                    </h2>
                    <p class="text-xl text-slate-400 font-medium leading-relaxed max-w-lg">
                        Não é disciplina, é sistema. Cada passo resolve uma peça — e a engrenagem roda sozinha.
                    </p>
                </div>

                <!-- ═══════ STEP 01 — A FUNDAÇÃO ═══════ -->
                <div
                    :ref="(el) => registerCard(el as HTMLElement, 0)"
                    class="group grid grid-cols-1 lg:grid-cols-2 gap-0 rounded-[2.5rem] overflow-hidden border border-white/[0.06] mb-6 cursor-default"
                >
                    <!-- Text side -->
                    <div class="p-10 sm:p-14 lg:p-16 flex flex-col justify-center bg-gradient-to-br from-slate-900/80 to-slate-900/40">
                        <div class="flex items-center gap-3 mb-6">
                            <span class="text-[11px] font-extrabold uppercase tracking-[0.2em] text-teal-400 bg-teal-500/10 px-3 py-1.5 rounded-lg border border-teal-500/20">Passo 01</span>
                        </div>
                        <h3 class="text-4xl sm:text-5xl font-extrabold tracking-tight text-white leading-[0.95] mb-5">
                            A Fundação
                        </h3>
                        <p class="text-lg text-slate-400 font-medium leading-relaxed max-w-md mb-8">
                            Cadastre contas e dívidas em segundos. Um clique, e o mapa financeiro tá montado.
                        </p>
                        <div class="flex items-center gap-2 text-[12px] font-bold text-teal-400/70">
                            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M12 6v6l4 2" /></svg>
                            Leva menos de 1 minuto
                        </div>
                    </div>
                    <!-- Video side — dark bg wrapper to prevent white bleed -->
                    <div class="relative bg-slate-950 flex items-center justify-center min-h-[320px] overflow-hidden">
                        <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[400px] h-[400px] rounded-full bg-teal-500/[0.06] blur-[80px] pointer-events-none"></div>
                        <div class="w-full h-full max-w-[600px] p-6">
                            <div class="rounded-2xl overflow-hidden border border-white/[0.08] shadow-2xl">
                                <video src="/videos/ritmo-fundacao.mp4" autoplay loop muted playsinline class="w-full h-auto object-cover pointer-events-none"></video>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ═══════ STEP 02 — O HÁBITO ═══════ -->
                <div
                    :ref="(el) => registerCard(el as HTMLElement, 1)"
                    class="group grid grid-cols-1 lg:grid-cols-5 gap-0 rounded-[2.5rem] overflow-hidden border border-white/[0.06] mb-6 cursor-default"
                >
                    <!-- Phone mockup (narrow) — LEFT side -->
                    <div class="lg:col-span-2 relative bg-slate-900/60 flex items-center justify-center p-8 sm:p-10 lg:p-12 min-h-[400px] lg:min-h-0 order-2 lg:order-1">
                        <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[300px] h-[300px] rounded-full bg-cyan-500/[0.06] blur-[80px] pointer-events-none"></div>
                        <div class="relative w-[200px]">
                            <div class="rounded-[2rem] overflow-hidden border-[3px] border-slate-700 bg-slate-900 group-hover:border-cyan-500/30 transition-colors duration-700 shadow-2xl">
                                <div class="absolute top-2 inset-x-0 h-4 flex justify-center z-10"><div class="w-8 h-3 bg-slate-950 rounded-full"></div></div>
                                <video src="/videos/ritmo-habito.mp4" autoplay loop muted playsinline class="w-full h-auto aspect-[9/16] object-cover pointer-events-none"></video>
                            </div>
                        </div>
                    </div>
                    <!-- Text side (wider) — RIGHT side -->
                    <div class="lg:col-span-3 p-10 sm:p-14 lg:p-16 flex flex-col justify-center bg-gradient-to-bl from-slate-900/80 to-slate-900/40 order-1 lg:order-2">
                        <div class="flex items-center gap-3 mb-6">
                            <span class="text-[11px] font-extrabold uppercase tracking-[0.2em] text-cyan-400 bg-cyan-500/10 px-3 py-1.5 rounded-lg border border-cyan-500/20">Passo 02</span>
                            <span class="text-[11px] font-bold text-slate-600 bg-white/5 px-3 py-1.5 rounded-lg">5 segundos ⚡</span>
                        </div>
                        <h3 class="text-4xl sm:text-5xl font-extrabold tracking-tight text-white leading-[0.95] mb-5">
                            O Hábito
                        </h3>
                        <p class="text-lg text-slate-400 font-medium leading-relaxed max-w-md mb-8">
                            Tirou do bolso? Joga no app. O lançamento é tão rápido que vira reflexo — como trancar a porta.
                        </p>
                        <!-- Mini inline mockup: typing preview -->
                        <div class="bg-white/[0.04] border border-white/[0.08] rounded-xl px-5 py-4 max-w-sm group-hover:border-cyan-500/20 transition-all duration-500">
                            <div class="flex items-center justify-between mb-2">
                                <span class="text-[11px] text-slate-500 font-bold">LANÇAR RÁPIDO</span>
                                <div class="w-2 h-2 rounded-full bg-cyan-400 animate-pulse"></div>
                            </div>
                            <div class="text-white font-semibold text-sm">Pizza com a galera</div>
                            <div class="text-red-400 font-bold text-lg mt-1">-R$ 89,00</div>
                        </div>
                    </div>
                </div>

                <!-- ═══════ STEP 03 — O RADAR ═══════ -->
                <div
                    :ref="(el) => registerCard(el as HTMLElement, 2)"
                    class="group grid grid-cols-1 lg:grid-cols-2 gap-0 rounded-[2.5rem] overflow-hidden border border-white/[0.06] mb-6 cursor-default"
                >
                    <!-- Text side — LEFT -->
                    <div class="p-10 sm:p-14 lg:p-16 flex flex-col justify-center bg-gradient-to-br from-slate-900/80 to-slate-900/40">
                        <div class="flex items-center gap-3 mb-6">
                            <span class="text-[11px] font-extrabold uppercase tracking-[0.2em] text-amber-400 bg-amber-500/10 px-3 py-1.5 rounded-lg border border-amber-500/20">Passo 03</span>
                        </div>
                        <h3 class="text-4xl sm:text-5xl font-extrabold tracking-tight text-white leading-[0.95] mb-5">
                            O Radar
                        </h3>
                        <p class="text-lg text-slate-400 font-medium leading-relaxed max-w-md mb-8">
                            O sinal vermelho acende antes do furo acontecer. Você vê semana a semana o que vem pela frente.
                        </p>
                        <!-- Alert inline preview -->
                        <div class="bg-red-500/[0.06] border border-red-500/20 rounded-xl px-5 py-4 max-w-sm opacity-0 group-hover:opacity-100 transition-all duration-700">
                            <div class="flex items-center gap-3">
                                <div class="w-2 h-2 rounded-full bg-red-500 animate-pulse"></div>
                                <span class="text-[12px] font-bold text-red-400">Fatura do cartão vence em 5 dias</span>
                            </div>
                            <div class="text-[12px] text-slate-500 mt-1">Saldo insuficiente · faltam <span class="text-red-400 font-bold">R$ 1.800</span></div>
                        </div>
                    </div>
                    <!-- Video side — RIGHT -->
                    <div class="relative bg-slate-900/60 flex items-center justify-center min-h-[320px] overflow-hidden">
                        <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[400px] h-[400px] rounded-full bg-amber-500/[0.04] blur-[80px] pointer-events-none"></div>
                        <video src="/videos/ritmo-radar.mp4" autoplay loop muted playsinline class="w-full h-full object-cover pointer-events-none"></video>
                    </div>
                </div>

                <!-- ═══════ STEP 04 — A PAZ (INVERTED: video LEFT, text RIGHT — zigzag) ═══════ -->
                <div
                    :ref="(el) => registerCard(el as HTMLElement, 3)"
                    class="group grid grid-cols-1 lg:grid-cols-2 gap-0 rounded-[2.5rem] overflow-hidden border border-white/[0.06] mb-32 cursor-default"
                >
                    <!-- Video side — LEFT (zigzag: inverted from Step 03) -->
                    <div class="relative bg-gradient-to-br from-emerald-950/40 to-slate-900/60 flex items-center justify-center p-8 sm:p-10 lg:p-12 min-h-[380px] order-2 lg:order-1 overflow-hidden">
                        <div class="absolute -right-20 -bottom-20 w-[500px] h-[500px] rounded-full bg-emerald-500/[0.06] blur-[120px] pointer-events-none"></div>
                        <div class="relative z-10 w-full max-w-[450px] rounded-2xl overflow-hidden border border-emerald-500/15 group-hover:border-emerald-500/30 transition-colors duration-500 shadow-2xl">
                            <video src="/videos/ritmo-paz.mp4" autoplay loop muted playsinline class="w-full h-auto object-cover pointer-events-none"></video>
                        </div>
                    </div>
                    <!-- Text side — RIGHT -->
                    <div class="p-10 sm:p-14 lg:p-16 flex flex-col justify-center bg-gradient-to-bl from-slate-900/80 to-emerald-950/30 order-1 lg:order-2">
                        <div class="flex items-center gap-3 mb-6">
                            <span class="text-[11px] font-extrabold uppercase tracking-[0.2em] text-emerald-400 bg-emerald-500/10 px-3 py-1.5 rounded-lg border border-emerald-500/20">Passo 04</span>
                        </div>
                        <h3 class="text-4xl sm:text-5xl lg:text-6xl font-extrabold tracking-tight text-white leading-[0.92] mb-5">
                            A Paz
                        </h3>
                        <p class="text-lg sm:text-xl text-slate-400 font-medium leading-relaxed max-w-md mb-8">
                            Ajuste a rota, corte o que der, e o mês volta pro azul na sua frente. Sem surpresas, sem estresse.
                        </p>
                        <!-- CTA -->
                        <Link :href="primaryHref" class="inline-flex w-fit h-14 items-center justify-center rounded-2xl bg-emerald-500 px-8 text-[13px] font-extrabold uppercase tracking-[0.1em] text-slate-950 hover:bg-emerald-400 hover:scale-105 active:scale-95 transition-all shadow-[0_0_30px_theme(colors.emerald.500/30)]">
                            Quero essa paz
                        </Link>
                    </div>
                </div>

            </div>
        </section>


        <!-- ================= BRAWNY SERVICE BLOCKS ================= -->
        <section class="bg-slate-50 pt-0 pb-16 relative z-20">
            <div class="mx-auto max-w-[1440px] px-6 md:px-12">
                <MotionSection class="bg-white rounded-[3rem] border border-slate-200 shadow-[0_-20px_50px_rgba(0,0,0,0.08)] px-6 md:px-12 pt-24 pb-20">
                     <div class="text-center mb-20">
                         <p class="text-[12px] font-extrabold uppercase tracking-[0.2em] text-slate-400 mb-6 drop-shadow-sm bg-slate-100 px-4 py-2 rounded-full border border-slate-200 inline-block">Sem Firulas</p>
                         <h2 class="text-5xl lg:text-[4.5rem] font-extrabold tracking-tighter leading-[0.95] text-slate-900"><span class="italic font-serif text-teal-500 pr-2">Por que</span> Kitamo?</h2>
                     </div>
                     
                     <div class="grid grid-cols-1 md:grid-cols-12 gap-8">
                          <div 
                              v-for="(block, idx) in serviceBlocks" 
                              :key="block.title" 
                              class="bg-slate-50 border border-slate-200 rounded-[2rem] p-10 sm:p-14 hover:shadow-2xl hover:-translate-y-2 transition-all duration-500 group flex flex-col"
                              :class="block.col"
                          >
                               <div class="w-20 h-20 bg-white border border-slate-200 rounded-[1.5rem] shadow-sm flex items-center justify-center mb-10 group-hover:bg-teal-500 group-hover:border-teal-600 transition-colors duration-500">
                                   <svg class="h-8 w-8 text-slate-500 group-hover:text-white transition-colors duration-500" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" :d="block.icon"/></svg>
                               </div>
                               <h3 class="text-3xl font-extrabold tracking-tight text-slate-900 mb-4">{{ block.title }}</h3>
                               <p class="text-lg text-slate-500 font-medium leading-relaxed mt-auto">{{ block.description }}</p>
                          </div>
                     </div>
                     
                     <div class="mt-20 flex justify-center">
                         <Link :href="route('site.pricing')" class="group relative inline-flex items-center gap-4 text-xl font-extrabold tracking-tight text-slate-900 hover:text-teal-600 transition-colors">
                             Ver planos de assinatura
                             <span class="flex items-center justify-center w-12 h-12 bg-slate-100 rounded-full group-hover:bg-teal-100 transition-colors">
                                 <svg class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M14 5l7 7m0 0l-7 7m7-7H3"/></svg>
                             </span>
                         </Link>
                     </div>
                </MotionSection>
            </div>
        </section>

        <!-- ================= SOCIAL PROOF: DEPOIMENTOS ================= -->
        <MotionSection class="bg-slate-50 py-32 border-b border-slate-200">
            <div class="mx-auto w-full max-w-[1440px] px-6 md:px-12">
                <div class="text-center mb-20 relative">
                    <div class="absolute inset-x-0 -top-10 h-32 bg-[radial-gradient(ellipse_at_top,_var(--tw-gradient-stops))] from-teal-100/50 to-transparent pointer-events-none"></div>
                    <p class="relative text-[12px] font-extrabold uppercase tracking-[0.2em] text-teal-600 mb-6 drop-shadow-sm bg-teal-50 px-4 py-2 rounded-full border border-teal-100 inline-block">Quem tá usando e não larga mais</p>
                    <h2 class="relative text-5xl lg:text-[4.5rem] font-extrabold tracking-tighter leading-[0.95] text-slate-900">
                        O impacto real.<br>
                        <span class="italic font-serif text-slate-500">Pessoas reais.</span>
                    </h2>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-8 text-left">
                    <div class="bg-white border border-slate-200 p-8 rounded-[2.5rem] shadow-sm hover:shadow-xl transition-[shadow,transform] hover:-translate-y-1">
                        <div class="flex items-center gap-4 mb-6">
                            <img src="https://images.pexels.com/photos/1181686/pexels-photo-1181686.jpeg?auto=compress&cs=tinysrgb&w=150" alt="Avatar Usuário" width="60" height="60" class="w-14 h-14 rounded-full object-cover">
                            <div>
                                <h4 class="font-extrabold text-slate-900 leading-tight">Camila Martins</h4>
                                <span class="text-sm font-medium text-slate-500">Designer Freelancer</span>
                            </div>
                        </div>
                        <p class="text-lg text-slate-700 font-medium">"Pela primeira vez dormi tranquila sabendo que o dinheiro ia dar. A visão que o app me dá 3 meses lá na frente acabou com os sustos dos boletos aleatórios."</p>
                    </div>

                    <div class="bg-slate-950 border border-slate-800 p-8 rounded-[2.5rem] shadow-lg shadow-teal-900/20 hover:shadow-2xl transition-[shadow,transform] hover:-translate-y-1 transform md:-translate-y-4">
                        <div class="flex items-center gap-4 mb-6">
                            <img src="https://images.pexels.com/photos/837358/pexels-photo-837358.jpeg?auto=compress&cs=tinysrgb&w=150" alt="Avatar Usuário" width="60" height="60" class="w-14 h-14 rounded-full object-cover border-2 border-slate-800">
                            <div>
                                <h4 class="font-extrabold text-white leading-tight">Lucas Andrade</h4>
                                <span class="text-sm font-medium text-teal-500">Casado, 2 filhos</span>
                            </div>
                        </div>
                        <p class="text-lg text-slate-300 font-medium">"Eu e minha esposa não brigamos mais por causa do extrato. O Kitamo deixa as regras do jogo visíveis na hora de organizar a conta. Zero aborrecimento."</p>
                    </div>

                    <div class="bg-white border border-slate-200 p-8 rounded-[2.5rem] shadow-sm hover:shadow-xl transition-[shadow,transform] hover:-translate-y-1">
                        <div class="flex items-center gap-4 mb-6">
                            <img src="https://images.pexels.com/photos/3764545/pexels-photo-3764545.jpeg?auto=compress&cs=tinysrgb&w=150" alt="Avatar Usuário" width="60" height="60" class="w-14 h-14 rounded-full object-cover">
                            <div>
                                <h4 class="font-extrabold text-slate-900 leading-tight">Mariana Reis</h4>
                                <span class="text-sm font-medium text-slate-500">Gestora de Projetos</span>
                            </div>
                        </div>
                        <p class="text-lg text-slate-700 font-medium">"Eu não sento mais com planilha de domingo à noite. Bato o olho no app de manhã pegando o metrô e em 50 segundos decido o orçamento da semana. Mágico."</p>
                    </div>
                </div>
            </div>
        </MotionSection>

        <!-- ================= THE MASSIVE FOOTER CTA ================= -->
        <MotionSection class="bg-teal-500 py-40 sm:py-52 relative overflow-hidden -mt-20 pt-48 flex flex-col items-center justify-center text-center">
            <!-- Organic overlay -->
            <div class="absolute inset-0 bg-[radial-gradient(circle_at_bottom_right,_var(--tw-gradient-stops))] from-teal-400 to-teal-700 mix-blend-multiply opacity-60 pointer-events-none"></div>
            
            <div class="max-w-[1200px] mx-auto px-6 md:px-12 relative z-10 flex flex-col items-center">
                <span class="inline-block px-6 py-2 bg-slate-950/20 backdrop-blur-md rounded-full text-white font-extrabold text-[12px] uppercase tracking-[0.2em] mb-10 shadow-lg border border-white/20">O Jogo Virou</span>
                
                <h2 class="text-[5rem] sm:text-[7rem] lg:text-[9rem] font-extrabold tracking-tighter text-teal-950 leading-[0.85] w-full break-words px-4 drop-shadow-[0_10px_20px_theme(colors.teal.600)]">
                    Controle.<br><span class="opacity-70">Agora.</span>
                </h2>
                
                <p class="mt-12 text-2xl font-bold text-teal-950/80 max-w-2xl mx-auto px-4">Não espere mais 30 dias para mudar sua realidade financeira. Comece agora.</p>
                
                <div class="mt-16 sm:mt-20 w-full sm:w-auto px-6">
                    <Link
                        :href="primaryHref"
                        class="flex w-full sm:w-auto h-20 sm:h-24 px-12 sm:px-20 items-center justify-center rounded-[3rem] bg-slate-950 text-[16px] sm:text-[18px] font-extrabold uppercase tracking-[0.2em] text-white transition-all duration-300 hover:scale-[1.03] hover:bg-slate-900 shadow-[0_30px_60px_-15px_rgba(0,0,0,0.6)] focus:ring-4 focus:ring-slate-950/30"
                    >
                        Criar Conta Grátis
                    </Link>
                </div>
            </div>
        </MotionSection>
    </SiteLayout>
</template>

<style scoped>
h1, h2, h3, strong {
    font-feature-settings: "salt" on, "ss01" on;
}
html {
    scroll-behavior: smooth;
}
</style>
