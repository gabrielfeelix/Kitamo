<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import { ref, onMounted, onUnmounted } from 'vue';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const isLoaded = ref(false);
const scrolled = ref(false);

const handleScroll = () => {
    scrolled.value = window.scrollY > 30;
    const reveals = document.querySelectorAll('.reveal');
    reveals.forEach(element => {
        const windowHeight = window.innerHeight;
        const elementTop = element.getBoundingClientRect().top;
        if (elementTop < windowHeight - 100) {
            element.classList.add('active');
        }
    });

    // Parallax effect for floating elements
    const floaters = document.querySelectorAll('.parallax');
    floaters.forEach((el) => {
        const speed = parseFloat((el as HTMLElement).dataset.speed || '0.1');
        const yPos = -(window.scrollY * speed);
        (el as HTMLElement).style.transform = `translateY(${yPos}px)`;
    });
};

onMounted(() => {
    setTimeout(() => { isLoaded.value = true; }, 100);
    window.addEventListener('scroll', handleScroll, { passive: true });
    handleScroll();
});

onUnmounted(() => {
    window.removeEventListener('scroll', handleScroll);
});

const features = [
    {
        title: 'Raio-X da Carteira',
        desc: 'Para de olhar o saldo e não saber pra onde a grana foi. O Kitamo categoriza tudo automaticamente.',
        icon: 'M15 12a3 3 0 11-6 0 3 3 0 016 0z M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z',
        color: 'text-teal-500',
        bg: 'bg-teal-50',
    },
    {
        title: 'Avisos Salva-Vidas',
        desc: 'Boleto vencendo amanhã? Assinatura que você não usa cobrando? A gente te avisa antes do pior.',
        icon: 'M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9',
        color: 'text-amber-500',
        bg: 'bg-amber-50',
    },
    {
        title: 'Máquina do Tempo',
        desc: 'A primeira projeção que realmente funciona. Saiba como vai estar seu saldo no dia 30, hoje.',
        icon: 'M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z',
        color: 'text-emerald-500',
        bg: 'bg-emerald-50',
    }
];
</script>

<template>
    <Head title="Kitamo | O fim do mês não precisa ser um filme de terror" />

    <div class="min-h-screen bg-[#FDFDFD] text-slate-900 font-sans selection:bg-teal-500 selection:text-white overflow-x-hidden relative">

        <!-- Background Ambient Shapes (Light Mode) -->
        <div class="fixed top-[-20%] left-[-10%] w-[60%] h-[60%] rounded-full bg-teal-100/50 blur-[120px] pointer-events-none -z-10 mix-blend-multiply"></div>
        <div class="fixed bottom-[-10%] right-[-10%] w-[50%] h-[50%] rounded-full bg-emerald-100/40 blur-[100px] pointer-events-none -z-10 mix-blend-multiply"></div>

        <!-- Navigation -->
        <header :class="['fixed top-0 inset-x-0 z-50 transition-all duration-500', scrolled ? 'py-4' : 'py-6']">
            <div class="max-w-7xl mx-auto px-6">
                <div :class="['flex items-center justify-between transition-all duration-500 rounded-3xl px-6', scrolled ? 'h-16 bg-white/80 backdrop-blur-xl border border-slate-200/50 shadow-[0_8px_30px_rgb(0,0,0,0.04)]' : 'h-16 bg-transparent']">
                    
                    <div class="flex items-center gap-3 relative group cursor-pointer">
                        <div class="w-10 h-10 rounded-[14px] bg-[#14B8A6] flex items-center justify-center shadow-[0_4px_14px_rgba(20,184,166,0.3)] group-hover:shadow-[0_6px_20px_rgba(20,184,166,0.4)] transition-all">
                            <span class="text-white font-extrabold text-xl leading-none -ml-0.5">K</span>
                        </div>
                        <span class="font-extrabold tracking-tight text-xl text-slate-900">Kitamo</span>
                    </div>

                    <nav class="hidden md:flex items-center gap-10">
                        <a href="#proposito" class="text-sm font-bold text-slate-500 hover:text-slate-900 transition-colors">Propósito</a>
                        <a href="#como-funciona" class="text-sm font-bold text-slate-500 hover:text-slate-900 transition-colors">Como funciona</a>
                        <a href="#quem-usa" class="text-sm font-bold text-slate-500 hover:text-slate-900 transition-colors">Quem usa</a>
                    </nav>

                    <div class="flex items-center gap-4">
                        <Link v-if="canLogin" href="/login" class="text-sm font-bold text-slate-600 hover:text-slate-900 transition-colors hidden sm:block">Entrar</Link>
                        <Link v-if="canRegister" href="/register" class="h-11 px-6 rounded-2xl bg-slate-900 text-white text-sm font-bold flex items-center justify-center hover:bg-slate-800 transition-colors shadow-lg shadow-slate-900/10">
                            Abrir conta grátis
                        </Link>
                    </div>
                </div>
            </div>
        </header>

        <!-- Hero Section -->
        <main class="relative pt-40 pb-24 lg:pt-56 lg:pb-32 px-6">
            <div class="max-w-5xl mx-auto text-center relative z-10">
                
                <div :class="['inline-flex items-center gap-2 mb-8 px-4 py-2 rounded-full bg-teal-50 border border-teal-100/50 shadow-sm transition-all duration-1000 ease-out translate-y-4 opacity-0', isLoaded ? '!translate-y-0 !opacity-100' : '']">
                    <span class="relative flex h-2 w-2">
                      <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-teal-400 opacity-75"></span>
                      <span class="relative inline-flex rounded-full h-2 w-2 bg-teal-500"></span>
                    </span>
                    <span class="text-[11px] font-bold text-teal-700 uppercase tracking-widest">A nova geração de Controle Financeiro</span>
                </div>

                <h1 :class="['text-[3.5rem] sm:text-7xl lg:text-[6.5rem] font-extrabold tracking-[-0.03em] text-slate-900 leading-[0.95] transition-all duration-1000 delay-100 ease-out translate-y-8 opacity-0', isLoaded ? '!translate-y-0 !opacity-100' : '']">
                    O fim do mês<br class="hidden sm:block" /> não precisa ser<br />
                    <span class="relative inline-block mt-2">
                        <span class="relative z-10 text-teal-500">um filme de terror.</span>
                        <span class="absolute bottom-1 left-0 w-full h-[0.3em] bg-teal-100 -z-10 -rotate-1 origin-left rounded-sm"></span>
                    </span>
                </h1>

                <p :class="['mt-10 max-w-2xl mx-auto text-lg sm:text-2xl text-slate-500 font-medium leading-relaxed tracking-tight transition-all duration-1000 delay-200 ease-out translate-y-8 opacity-0', isLoaded ? '!translate-y-0 !opacity-100' : '']">
                    Chega de suar frio no dia 20. O Kitamo organiza tua grana, te avisa antes do boleto vencer e mostra, <span class="text-slate-900 font-bold border-b border-slate-300">hoje</span>, se vai sobrar pro churrasco.
                </p>

                <div :class="['mt-12 flex flex-col sm:flex-row items-center justify-center gap-4 transition-all duration-1000 delay-300 ease-out translate-y-8 opacity-0', isLoaded ? '!translate-y-0 !opacity-100' : '']">
                    <Link href="/register" class="group relative h-14 inline-flex items-center justify-center px-8 rounded-2xl bg-[#14B8A6] text-white font-extrabold text-base overflow-hidden hover:-translate-y-0.5 transition-all duration-300 active:translate-y-0 w-full sm:w-auto shadow-[0_12px_30px_-10px_rgba(20,184,166,0.6)]">
                        Começar gratuitamente
                        <svg class="w-5 h-5 ml-2 group-hover:translate-x-1 transition-transform" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M14 5l7 7m0 0l-7 7m7-7H3" />
                        </svg>
                    </Link>
                    <a href="#proposito" class="h-14 inline-flex items-center justify-center px-8 rounded-2xl bg-white border border-slate-200 text-slate-700 font-extrabold text-base hover:bg-slate-50 hover:border-slate-300 transition-all w-full sm:w-auto shadow-sm">
                        Não acredito, me mostra
                    </a>
                </div>
            </div>

            <!-- Dashboard Float Preview Narrative -->
            <div :class="['mt-24 lg:mt-32 relative max-w-[1200px] mx-auto transition-all duration-1000 delay-500 ease-out translate-y-16 opacity-0 h-[300px] sm:h-[500px] lg:h-[600px]', isLoaded ? '!translate-y-0 !opacity-100' : '']">
                
                <!-- Main App Window Frame -->
                <div class="absolute inset-x-4 sm:inset-x-10 bottom-0 top-10 rounded-t-[40px] bg-white border-t border-x border-slate-200 shadow-[0_-20px_80px_-20px_rgba(0,0,0,0.08)] overflow-hidden flex flex-col parallax" data-speed="0.05">
                    
                    <!-- App Head -->
                    <div class="h-16 border-b border-slate-100 flex items-center px-6 gap-2 bg-slate-50/50">
                        <div class="flex gap-1.5">
                            <div class="w-3 h-3 rounded-full bg-red-400"></div>
                            <div class="w-3 h-3 rounded-full bg-amber-400"></div>
                            <div class="w-3 h-3 rounded-full bg-emerald-400"></div>
                        </div>
                        <div class="mx-auto w-48 h-6 bg-white rounded-md border border-slate-200"></div>
                    </div>
                    
                    <!-- App Body (Abstract Interface) -->
                    <div class="flex-1 p-8 sm:p-12 relative bg-[#F8FAFC]">
                        <!-- Title Area -->
                        <div class="w-1/3 h-8 rounded-lg bg-slate-200 mb-4"></div>
                        <div class="w-1/4 h-4 rounded-md bg-slate-200/60 mb-12"></div>
                        
                        <!-- Grid Area -->
                        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                            <div class="h-32 rounded-2xl bg-white border border-slate-100 shadow-sm p-5 flex flex-col justify-between">
                                <div class="w-10 h-10 rounded-full bg-emerald-50"></div>
                                <div>
                                    <div class="w-1/2 h-3 rounded bg-slate-100 mb-2"></div>
                                    <div class="w-3/4 h-6 rounded bg-slate-200"></div>
                                </div>
                            </div>
                            <div class="h-32 rounded-2xl bg-white border border-slate-100 shadow-sm p-5 flex flex-col justify-between">
                                <div class="w-10 h-10 rounded-full bg-red-50"></div>
                                <div>
                                    <div class="w-1/2 h-3 rounded bg-slate-100 mb-2"></div>
                                    <div class="w-3/4 h-6 rounded bg-slate-200"></div>
                                </div>
                            </div>
                            <div class="hidden md:flex h-32 rounded-2xl bg-white border border-slate-100 shadow-sm p-5 flex-col justify-between">
                                <div class="w-10 h-10 rounded-full bg-teal-50"></div>
                                <div>
                                    <div class="w-1/2 h-3 rounded bg-slate-100 mb-2"></div>
                                    <div class="w-3/4 h-6 rounded bg-slate-200"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Floating Interactive Widgets (Creative Storytelling) -->
                
                <!-- Widget 1: Alerta Saldo -->
                <div class="absolute -left-4 sm:left-4 lg:left-0 top-0 sm:top-20 z-20 w-[260px] sm:w-[320px] rounded-3xl bg-white p-6 shadow-[0_20px_50px_-12px_rgba(239,68,68,0.2)] border border-red-100 parallax transform rotate-[-3deg]" data-speed="0.15">
                    <div class="flex items-start gap-4">
                        <div class="flex-shrink-0 w-12 h-12 rounded-2xl bg-red-50 flex items-center justify-center text-2xl">⚠️</div>
                        <div>
                            <div class="text-sm font-bold text-slate-900 leading-tight">Chefe, o cinto vai apertar</div>
                            <div class="mt-1 text-xs font-semibold text-slate-500">Seu saldo vai negativar dia 22 por conta do IPVA.</div>
                        </div>
                    </div>
                </div>

                <!-- Widget 2: Metas -->
                <div class="absolute -right-4 sm:right-4 lg:-right-4 top-32 lg:top-10 z-20 w-[240px] sm:w-[280px] rounded-3xl bg-teal-400 p-6 shadow-[0_20px_50px_-12px_rgba(20,184,166,0.3)] text-white parallax transform rotate-[4deg]" data-speed="0.1">
                    <div class="text-[10px] font-extrabold uppercase tracking-widest text-teal-100 mb-1">Passagem Itália</div>
                    <div class="text-2xl font-black mb-4">R$ 5.400</div>
                    <div class="h-2 w-full rounded-full bg-black/20 overflow-hidden">
                        <div class="h-full w-[80%] bg-white rounded-full"></div>
                    </div>
                    <div class="mt-2 text-xs font-bold text-teal-100 text-right">80% guardado. Falta pouco!</div>
                </div>

                <!-- Widget 3: Gasto supérfluo -->
                <div class="hidden sm:block absolute left-1/2 -translate-x-1/2 lg:left-auto lg:translate-x-0 lg:-right-10 bottom-10 z-20 w-[280px] rounded-3xl bg-white p-5 shadow-[0_20px_50px_-12px_rgba(0,0,0,0.1)] border border-slate-100 parallax" data-speed="0.2">
                    <div class="flex items-center justify-between mb-3">
                        <div class="text-xs font-extrabold text-slate-400 uppercase tracking-wider">iFood da Madrugada</div>
                        <div class="text-sm font-black text-red-500">-R$ 84,90</div>
                    </div>
                    <div class="flex items-center gap-2">
                        <div class="text-xl">🍔</div>
                        <div class="text-xs font-semibold text-slate-500">Tá virando rotina, não?</div>
                    </div>
                </div>

            </div>
        </main>

        <!-- The "Why" - Propósito -->
        <section id="proposito" class="py-24 sm:py-32 bg-white relative reveal">
            <div class="max-w-7xl mx-auto px-6">
                <!-- Large Typography Header -->
                <div class="max-w-4xl">
                    <h2 class="text-4xl sm:text-6xl font-extrabold tracking-tighter text-slate-900 leading-[1.05]">
                        O sistema tradicional quer você endividado. <span class="text-slate-400">Nós queremos que você viaje.</span>
                    </h2>
                </div>
                
                <div class="mt-16 sm:mt-24 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                    <!-- Feature Cards with playful aesthetics -->
                    <div v-for="(feat, i) in features" :key="feat.title" class="group p-8 rounded-[32px] bg-slate-50 border border-slate-100 hover:bg-white hover:shadow-[0_20px_40px_-15px_rgba(0,0,0,0.05)] hover:border-slate-200 transition-all duration-300">
                        <div :class="['w-14 h-14 rounded-[20px] flex items-center justify-center mb-8 transition-transform group-hover:scale-110 group-hover:-rotate-3 duration-300', feat.bg, feat.color]">
                            <svg class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="feat.icon" />
                            </svg>
                        </div>
                        <h3 class="text-2xl font-bold text-slate-900 mb-3 tracking-tight">{{ feat.title }}</h3>
                        <p class="text-slate-500 font-medium leading-relaxed">{{ feat.desc }}</p>
                    </div>
                </div>
            </div>
        </section>

        <!-- Value Proposition / UI Showcase -->
        <section id="como-funciona" class="py-24 sm:py-32 overflow-hidden reveal">
            <div class="max-w-7xl mx-auto px-6">
                <div class="grid grid-cols-1 lg:grid-cols-2 gap-16 lg:gap-24 items-center">
                    
                    <div class="order-2 lg:order-1 relative">
                        <!-- Abstract Representation of UI Cards cascading -->
                        <div class="relative w-full aspect-square md:aspect-auto md:h-[600px] flex items-center justify-center">
                            
                            <div class="absolute right-0 sm:right-10 top-10 sm:top-20 z-10 w-[280px] sm:w-[340px] bg-white p-6 rounded-3xl border border-slate-100 shadow-[0_20px_40px_-15px_rgba(0,0,0,0.1)] transform rotate-3 transition-transform hover:rotate-0 duration-500">
                                <div class="flex items-center gap-4 mb-6">
                                    <div class="w-12 h-12 rounded-full bg-slate-900 flex items-center justify-center text-white"><span class="font-bold">K</span></div>
                                    <div>
                                        <div class="text-sm font-bold text-slate-900">Salário / Nubank</div>
                                        <div class="text-xs font-semibold text-emerald-500">+ R$ 6.200,00</div>
                                    </div>
                                </div>
                                <div class="space-y-3">
                                    <div class="flex justify-between items-center bg-slate-50 p-3 rounded-2xl">
                                        <span class="text-xs font-bold text-slate-500">Aluguel</span>
                                        <span class="text-sm font-bold text-slate-900">- R$ 2.100,00</span>
                                    </div>
                                    <div class="flex justify-between items-center bg-slate-50 p-3 rounded-2xl">
                                        <span class="text-xs font-bold text-slate-500">Cartão Black</span>
                                        <span class="text-sm font-bold text-slate-900">- R$ 1.840,00</span>
                                    </div>
                                </div>
                                <div class="mt-4 pt-4 border-t border-slate-100 flex justify-between items-center">
                                    <span class="text-xs font-extrabold uppercase tracking-wide text-slate-400">Sobra Livre</span>
                                    <span class="text-lg font-black text-teal-500">R$ 2.260,00</span>
                                </div>
                            </div>

                            <div class="absolute left-0 sm:left-10 bottom-10 sm:bottom-20 z-20 w-[240px] sm:w-[280px] bg-slate-900 p-6 rounded-3xl shadow-[0_20px_40px_-15px_rgba(20,184,166,0.3)] transform -rotate-3 transition-transform hover:rotate-0 duration-500">
                                <div class="w-10 h-10 rounded-xl bg-teal-500 flex items-center justify-center mb-6">
                                    <svg class="w-5 h-5 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" /></svg>
                                </div>
                                <div class="text-sm font-bold text-white mb-1">Projeção 30 dias</div>
                                <div class="text-xs font-medium text-slate-400 mb-4">Você está gastando menos que mês passado! Mantenha o ritmo.</div>
                                <div class="h-2 w-full bg-slate-800 rounded-full overflow-hidden">
                                    <div class="h-full w-2/3 bg-teal-400 rounded-full"></div>
                                </div>
                            </div>

                        </div>
                    </div>

                    <div class="order-1 lg:order-2">
                        <div class="inline-flex items-center gap-2 mb-6 px-3 py-1 rounded-full bg-slate-100 text-xs font-bold text-slate-600 uppercase tracking-widest">
                            Inteligência Brutal
                        </div>
                        <h2 class="text-4xl sm:text-5xl font-extrabold tracking-tighter text-slate-900 leading-[1.05] mb-6">
                            Você diz o que ganha.<br/> Nós dizemos como viver.
                        </h2>
                        <p class="text-lg text-slate-500 font-medium leading-relaxed mb-8 max-w-lg">
                            Analisamos suas faturas, contas fixas e variáveis contínuas em um motor preditivo. Nossa promessa é simples: você vai abrir o app e saber, em 5 segundos, se aquele iFood extra da noite vai comprometer o seu final de semana.
                        </p>
                        
                        <ul class="space-y-4 mb-10">
                            <li class="flex items-center gap-3 text-slate-700 font-bold">
                                <span class="w-6 h-6 rounded-full bg-teal-100 text-teal-600 flex items-center justify-center">✓</span>
                                Algoritmo de projeção até 365 dias
                            </li>
                            <li class="flex items-center gap-3 text-slate-700 font-bold">
                                <span class="w-6 h-6 rounded-full bg-teal-100 text-teal-600 flex items-center justify-center">✓</span>
                                Metas com cálculo dinâmico
                            </li>
                            <li class="flex items-center gap-3 text-slate-700 font-bold">
                                <span class="w-6 h-6 rounded-full bg-teal-100 text-teal-600 flex items-center justify-center">✓</span>
                                Tudo criptografado, ninguém vê além de você.
                            </li>
                        </ul>
                    </div>

                </div>
            </div>
        </section>

        <!-- Social Proof Marquee / Testimonials -->
        <section id="quem-usa" class="py-24 sm:py-32 bg-slate-50 border-y border-slate-100 reveal">
            <div class="max-w-7xl mx-auto px-6 text-center mb-16">
                <h2 class="text-3xl sm:text-5xl font-extrabold tracking-tight text-slate-900">Histórias reais de quem <br/> <span class="text-teal-500">virou o jogo.</span></h2>
            </div>
            
            <!-- Cards Ticker -->
            <div class="flex overflow-hidden group pb-4">
                <!-- Ticker Track -->
                <div class="flex gap-6 animate-none sm:animate-leftward px-6 sm:px-0">
                    <!-- Manual duplicate for infinite scroll illusion if desired, for now just static flex warp -->
                    <div class="flex sm:flex-nowrap flex-wrap sm:w-auto gap-6 sm:pl-6 justify-center w-full">
                        <div v-for="i in [1]" :key="i" class="flex flex-wrap sm:flex-nowrap gap-6 w-full">
                            
                            <div class="w-full sm:w-[400px] flex-shrink-0 p-8 rounded-3xl bg-white border border-slate-100 shadow-sm hover:shadow-md transition-shadow">
                                <div class="flex text-amber-400 mb-6">★★★★★</div>
                                <p class="text-lg font-bold text-slate-800 leading-snug mb-8">
                                    "Foi tipo tirar uma venda dos olhos. Eu rodava em cheque especial todo mês. Três meses de Kitamo e consegui fazer minha primeira viagem sem usar cartão."
                                </p>
                                <div class="flex items-center gap-3">
                                    <div class="w-10 h-10 rounded-full bg-blue-100 text-blue-700 font-bold flex items-center justify-center">DR</div>
                                    <div>
                                        <div class="text-sm font-bold text-slate-900">Diego Ribeiro</div>
                                        <div class="text-xs text-slate-500">Engenheiro</div>
                                    </div>
                                </div>
                            </div>

                            <div class="w-full sm:w-[400px] flex-shrink-0 p-8 rounded-3xl bg-white border border-slate-100 shadow-sm hover:shadow-md transition-shadow">
                                <div class="flex text-amber-400 mb-6">★★★★★</div>
                                <p class="text-lg font-bold text-slate-800 leading-snug mb-8">
                                    "A interface mais linda que já vi num app de finanças no Brasil. É o Notion do controle financeiro. Fico querendo abrir o tempo todo."
                                </p>
                                <div class="flex items-center gap-3">
                                    <div class="w-10 h-10 rounded-full bg-rose-100 text-rose-700 font-bold flex items-center justify-center">ML</div>
                                    <div>
                                        <div class="text-sm font-bold text-slate-900">Marina L.</div>
                                        <div class="text-xs text-slate-500">Product Designer</div>
                                    </div>
                                </div>
                            </div>

                            <div class="w-full sm:w-[400px] flex-shrink-0 p-8 rounded-3xl bg-white border border-slate-100 shadow-sm hover:shadow-md transition-shadow">
                                <div class="flex text-amber-400 mb-6">★★★★★</div>
                                <p class="text-lg font-bold text-slate-800 leading-snug mb-8">
                                    "O fato dele projetar pro futuro em vez de só me dizer onde eu já errei no passado. Isso muda o jogo mentalmente. Muito bom real!"
                                </p>
                                <div class="flex items-center gap-3">
                                    <div class="w-10 h-10 rounded-full bg-emerald-100 text-emerald-700 font-bold flex items-center justify-center">CM</div>
                                    <div>
                                        <div class="text-sm font-bold text-slate-900">Caio M.</div>
                                        <div class="text-xs text-slate-500">Empreendedor</div>
                                    </div>
                                </div>
                            </div>

                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Final Call to Action -->
        <section class="py-32 px-6 relative reveal">
            <div class="max-w-5xl mx-auto">
                <div class="relative rounded-[40px] bg-slate-900 p-12 sm:p-24 text-center overflow-hidden shadow-2xl">
                    <!-- Abstract glowing circles -->
                    <div class="absolute top-0 right-0 w-64 h-64 bg-teal-500 rounded-full mix-blend-screen filter blur-[80px] opacity-40 transform translate-x-1/2 -translate-y-1/2"></div>
                    <div class="absolute bottom-0 left-0 w-64 h-64 bg-amber-500 rounded-full mix-blend-screen filter blur-[80px] opacity-20 transform -translate-x-1/2 translate-y-1/2"></div>

                    <h2 class="relative z-10 text-4xl sm:text-6xl font-extrabold tracking-tighter text-white mb-6">
                        Sua independência <br/> começa hoje.
                    </h2>
                    <p class="relative z-10 text-slate-300 text-lg sm:text-xl font-medium max-w-xl mx-auto mb-10">
                        Zero burocracia, zero julgamento. Apenas você, seus números organizados e clareza absoluta sobre o amanhã.
                    </p>
                    
                    <div class="relative z-10 flex justify-center">
                        <Link href="/register" class="group relative h-16 inline-flex items-center justify-center px-10 rounded-2xl bg-white text-slate-900 font-extrabold text-lg overflow-hidden transition-all duration-300 hover:scale-[1.02] shadow-xl w-full sm:w-auto">
                            Abrir minha conta gratuita
                            <svg class="w-5 h-5 ml-3 text-slate-900 group-hover:translate-x-1 transition-transform" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M14 5l7 7m0 0l-7 7m7-7H3" />
                            </svg>
                        </Link>
                    </div>
                </div>
            </div>
        </section>

        <footer class="py-12 px-6 bg-white border-t border-slate-100 text-center text-slate-400 text-sm font-medium">
            <div class="flex items-center justify-center gap-3 mb-6">
                <div class="w-8 h-8 rounded-lg bg-teal-50 flex items-center justify-center text-teal-500 font-extrabold text-sm">K</div>
                <span class="font-extrabold text-slate-800 tracking-tight text-lg">Kitamo</span>
            </div>
            <p>© {{ new Date().getFullYear() }} Kitamo Financial. Feito para quem sabe o valor do seu corre.</p>
        </footer>

    </div>
</template>

<style>
.reveal {
    opacity: 0;
    transform: translateY(40px);
    transition: all 1.2s cubic-bezier(0.16, 1, 0.3, 1);
}
.reveal.active {
    opacity: 1;
    transform: translateY(0);
}

/* Optional horizontal scroll animation for desktop if you want to implement the true ticker */
@screen sm {
    .animate-leftward {
        /* If we had duplicated lists, we'd uncomment this for infinite loop */
        /* animation: scrollLeft 40s linear infinite; */
    }
}
@keyframes scrollLeft {
    0% { transform: translateX(0); }
    100% { transform: translateX(-50%); }
}
</style>
