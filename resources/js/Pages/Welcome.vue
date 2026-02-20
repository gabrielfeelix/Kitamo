<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import { ref, onMounted, onUnmounted } from 'vue';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const isLoaded = ref(false);
const scrollProgress = ref(0);

const handleScroll = () => {
    const winScroll = document.body.scrollTop || document.documentElement.scrollTop;
    const height = document.documentElement.scrollHeight - document.documentElement.clientHeight;
    scrollProgress.value = (winScroll / height) * 100;
};

onMounted(() => {
    setTimeout(() => { isLoaded.value = true; }, 100);
    window.addEventListener('scroll', handleScroll, { passive: true });
});

onUnmounted(() => {
    window.removeEventListener('scroll', handleScroll);
});

const steps = [
    {
        num: '01',
        title: 'Visão de Raio-X',
        desc: 'Para de olhar o saldo e não saber pra onde a grana foi. O Kitamo categoriza tudo automaticamente.',
        features: ['Categorização por IA', 'Histórico visual', 'Tags customizadas'],
        activeBg: 'bg-white',
        activeText: 'text-slate-900'
    },
    {
        num: '02',
        title: 'Avisos Salva-Vidas',
        desc: 'Boleto vencendo amanhã? Assinatura que você não usa cobrando? A gente te avisa antes do pior.',
        features: ['Alertas de vencimento', 'Previsão de saldo', 'Notificações push'],
        activeBg: 'bg-[#14B8A6]',
        activeText: 'text-white'
    },
    {
        num: '03',
        title: 'A Máquina do Tempo',
        desc: 'A primeira projeção que realmente funciona. Saiba como vai estar seu saldo no dia 30, hoje.',
        features: ['Simulação de cenário', 'Impacto de parcelas', 'Gráficos de tendência'],
        activeBg: 'bg-slate-900',
        activeText: 'text-white'
    }
];
</script>

<template>
    <Head title="Kitamo | O fim do mês não precisa ser de terror" />

    <!-- Progress Bar (Adelt style minimal touch) -->
    <div class="fixed top-0 left-0 h-1 bg-[#14B8A6] z-[60] transition-all duration-75 ease-out" :style="{ width: scrollProgress + '%' }"></div>

    <div class="min-h-screen bg-[#F6F6F4] text-slate-900 font-sans selection:bg-[#14B8A6] selection:text-white">

        <!-- Nav - Very minimal -->
        <header class="fixed top-0 inset-x-0 z-50 mix-blend-difference text-white">
            <div class="max-w-[1400px] mx-auto px-6 h-24 flex items-center justify-between">
                <div class="flex items-center gap-2 group cursor-pointer">
                    <span class="font-extrabold text-2xl tracking-tighter">kitamo</span>
                </div>
                
                <div class="flex items-center gap-8">
                    <Link v-if="canLogin" href="/login" class="text-[11px] font-bold uppercase tracking-[0.2em] hover:opacity-70 transition-opacity hidden sm:block">Entrar</Link>
                    <Link v-if="canRegister" href="/register" class="h-10 px-6 rounded-full border border-white flex items-center justify-center text-[11px] font-bold uppercase tracking-[0.2em] hover:bg-white hover:text-black transition-all">
                        Começar
                    </Link>
                </div>
            </div>
        </header>

        <!-- Sidebar Fixed Elements (Adelt style) -->
        <div class="hidden lg:flex fixed left-6 top-1/2 -translate-y-1/2 flex-col gap-6 z-40 mix-blend-difference text-white">
            <div class="w-[1px] h-12 bg-white/20 mx-auto"></div>
            <a href="#proposito" class="text-[9px] uppercase tracking-[0.3em] rotate-180" style="writing-mode: vertical-rl;">Propósito</a>
            <a href="#funciona" class="text-[9px] uppercase tracking-[0.3em] rotate-180" style="writing-mode: vertical-rl;">Features</a>
        </div>

        <!-- Hero -->
        <main class="relative min-h-[90vh] flex flex-col justify-center px-6 pt-32 pb-20 max-w-[1400px] mx-auto">
            <div class="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
                <div class="lg:col-span-8">
                    <p class="text-[11px] font-bold text-slate-500 uppercase tracking-[0.25em] mb-8">Aplicativo de projeção financeira</p>
                    <h1 class="text-[12vw] sm:text-[8vw] lg:text-[7.5rem] font-medium leading-[0.85] tracking-[-0.04em] text-slate-900">
                        O fim do mês<br/> não precisa<br/>
                        ser de <span class="italic font-serif text-[#14B8A6]">terror.</span>
                    </h1>
                </div>
                <div class="lg:col-span-4 flex flex-col justify-end lg:h-full lg:pb-10">
                    <p class="text-base lg:text-lg text-slate-600 font-medium leading-relaxed max-w-sm mb-10">
                        Chega de suar frio no dia 20. O Kitamo organiza tua grana, avisa sobre boletos e mostra se vai sobrar pro churrasco.
                    </p>
                    <div>
                        <Link href="/register" class="group relative inline-flex items-center justify-center h-16 w-16 rounded-full bg-slate-900 text-white hover:bg-[#14B8A6] hover:scale-110 mb-4 transition-all duration-300">
                            <svg class="w-6 h-6 -rotate-45 group-hover:rotate-0 transition-transform duration-300" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M14 5l7 7m0 0l-7 7m7-7H3"/></svg>
                        </Link>
                        <div class="text-[10px] font-bold uppercase tracking-[0.2em] text-slate-900">Criar conta grátis</div>
                    </div>
                </div>
            </div>
        </main>

        <!-- Divider -->
        <div class="max-w-[1400px] mx-auto px-6">
            <div class="w-full h-[1px] bg-slate-200"></div>
        </div>

        <!-- Problem Statement - Big Typography -->
        <section id="proposito" class="py-32 px-6 max-w-[1400px] mx-auto">
            <div class="flex flex-col md:flex-row gap-12 md:gap-24">
                <div class="md:w-1/3">
                    <h2 class="text-[11px] font-bold text-slate-500 uppercase tracking-[0.25em] sticky top-32">
                        A Verdade
                    </h2>
                </div>
                <div class="md:w-2/3">
                    <h3 class="text-3xl sm:text-5xl lg:text-[4rem] font-medium leading-[1.1] tracking-[-0.03em] text-slate-900">
                        O sistema tradicional quer você vivendo no limite. <br/><br/>
                        <span class="text-slate-400">Nossa missão é construir a clareza que eles te escondem. Para você focar no que importa.</span>
                    </h3>
                </div>
            </div>
        </section>

        <!-- Sticky Stacked Sections (Adelt inspired mechanic) -->
        <section id="funciona" class="relative pb-32">
            <!-- Container needs height to allow scrolling -->
            <div class="max-w-[1400px] mx-auto relative">
                
                <div class="px-6 mb-16 flex justify-between items-end">
                    <h2 class="text-[11px] font-bold text-slate-500 uppercase tracking-[0.25em]">Como Funciona</h2>
                    <div class="text-[11px] font-bold text-slate-500 uppercase tracking-[0.25em]">3 Passos</div>
                </div>

                <!-- Sticky Cards -->
                <div class="space-y-0 h-auto px-6">
                    <div v-for="(step, index) in steps" :key="step.num" 
                         class="sticky top-0 pt-24 pb-8 min-h-[80vh] flex flex-col"
                         :style="{ top: `calc(${index * 40}px + 4rem)` }">
                        
                        <div :class="['flex-1 rounded-[2rem] p-8 md:p-16 flex flex-col md:flex-row gap-12 shadow-[0_-10px_40px_rgba(0,0,0,0.02)] transition-colors duration-500 ease-in-out', step.activeBg, step.activeText]">
                            <!-- Left Info -->
                            <div class="md:w-1/2 flex flex-col justify-between">
                                <div>
                                    <div class="text-sm font-bold uppercase tracking-[0.2em] mb-12 opacity-50">{{ step.num }}</div>
                                    <h3 class="text-5xl sm:text-7xl font-medium tracking-tight mb-8">{{ step.title }}</h3>
                                    <p class="text-xl opacity-80 max-w-md font-medium leading-relaxed">{{ step.desc }}</p>
                                </div>
                                <div class="mt-12">
                                    <ul class="space-y-4">
                                        <li v-for="feat in step.features" :key="feat" class="flex items-center gap-4 font-bold text-sm tracking-wide">
                                            <span class="w-1.5 h-1.5 rounded-full bg-current opacity-50"></span>
                                            {{ feat }}
                                        </li>
                                    </ul>
                                </div>
                            </div>
                            
                            <!-- Right Visual Mockup (Abstract) -->
                            <div class="md:w-1/2 relative bg-black/5 rounded-[1.5rem] flex items-center justify-center min-h-[300px] overflow-hidden">
                                <template v-if="index === 0">
                                    <!-- Visual Bar Chart -->
                                    <div class="flex items-end gap-4 h-48">
                                        <div class="w-12 bg-current rounded-t-xl opacity-20 h-[40%]"></div>
                                        <div class="w-12 bg-current rounded-t-xl opacity-40 h-[70%]"></div>
                                        <div class="w-12 bg-current rounded-t-xl opacity-100 h-[100%] shadow-[0_0_30px_rgba(0,0,0,0.1)] -translate-y-4"></div>
                                        <div class="w-12 bg-current rounded-t-xl opacity-20 h-[50%]"></div>
                                    </div>
                                </template>
                                <template v-else-if="index === 1">
                                    <!-- Visual Notification -->
                                    <div class="bg-white text-slate-900 rounded-2xl p-6 w-[80%] shadow-2xl transform rotate-3">
                                        <div class="flex gap-4 items-center mb-4">
                                            <div class="w-10 h-10 rounded-full bg-red-100 flex items-center justify-center text-red-500">!</div>
                                            <div class="h-4 w-32 bg-slate-200 rounded"></div>
                                        </div>
                                        <div class="h-2 w-full bg-slate-100 rounded mb-2"></div>
                                        <div class="h-2 w-2/3 bg-slate-100 rounded"></div>
                                    </div>
                                </template>
                                <template v-else>
                                    <!-- Visual Line Chart Target -->
                                    <div class="absolute inset-x-0 top-1/2 -translate-y-1/2 h-[2px] bg-white/20"></div>
                                    <div class="w-32 h-32 rounded-full border-2 border-white border-dashed flex items-center justify-center opacity-80 backdrop-blur-md">
                                        <div class="text-3xl font-medium tracking-tighter">30</div>
                                    </div>
                                </template>
                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </section>

        <!-- Clean Grid Social Proof -->
        <section class="border-t border-slate-200 py-32 bg-[#F6F6F4]">
            <div class="max-w-[1400px] mx-auto px-6">
                <div class="grid grid-cols-1 md:grid-cols-3 gap-px bg-slate-200 border border-slate-200">
                    <div class="bg-[#F6F6F4] p-12 lg:p-16 flex flex-col justify-between">
                        <div class="mb-12">
                            <h4 class="text-4xl font-serif italic text-[#14B8A6] mb-6">"Uma revelação."</h4>
                            <p class="text-lg text-slate-600 leading-relaxed font-medium">Três meses de Kitamo e consegui fazer minha primeira viagem sem usar cartão.</p>
                        </div>
                        <div>
                            <div class="text-sm font-bold uppercase tracking-wider text-slate-900">Diego Ribeiro</div>
                            <div class="text-[11px] font-bold uppercase tracking-widest text-slate-400 mt-1">Engenheiro</div>
                        </div>
                    </div>
                    
                    <div class="bg-[#F6F6F4] p-12 lg:p-16 flex flex-col justify-between">
                        <div class="mb-12">
                            <h4 class="text-4xl font-serif italic text-[#14B8A6] mb-6">"Impecável."</h4>
                            <p class="text-lg text-slate-600 leading-relaxed font-medium">É o Notion do controle financeiro. Fico querendo abrir o app o tempo todo.</p>
                        </div>
                        <div>
                            <div class="text-sm font-bold uppercase tracking-wider text-slate-900">Marina L.</div>
                            <div class="text-[11px] font-bold uppercase tracking-widest text-slate-400 mt-1">Product Designer</div>
                        </div>
                    </div>
                    
                    <div class="bg-[#F6F6F4] p-12 lg:p-16 flex flex-col justify-between">
                        <div class="mb-12">
                            <h4 class="text-4xl font-serif italic text-[#14B8A6] mb-6">"Game changer."</h4>
                            <p class="text-lg text-slate-600 leading-relaxed font-medium">Projetar pro futuro em vez de só me dizer onde eu já errei no passado. Isso muda o jogo mentalmente.</p>
                        </div>
                        <div>
                            <div class="text-sm font-bold uppercase tracking-wider text-slate-900">Caio M.</div>
                            <div class="text-[11px] font-bold uppercase tracking-widest text-slate-400 mt-1">Empreendedor</div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Massive Footer CTA -->
        <section class="py-0 relative overflow-hidden bg-slate-900 text-white">
            <div class="max-w-[1400px] mx-auto px-6 py-32 md:py-48 flex flex-col items-center justify-center text-center">
                <h2 class="text-[10vw] sm:text-[8rem] font-medium leading-[0.85] tracking-tight mb-12">
                    Pronto pra <br/>
                    <span class="italic font-serif text-[#14B8A6]">sobrar?</span>
                </h2>
                
                <Link href="/register" class="group relative flex items-center gap-6 pb-2 border-b-2 border-[#14B8A6] hover:border-white transition-colors duration-300">
                    <span class="text-2xl font-medium tracking-tight">Criar Conta Gratuita</span>
                    <div class="w-10 h-10 rounded-full bg-[#14B8A6] flex items-center justify-center group-hover:bg-white group-hover:text-black transition-all">
                        <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3"/></svg>
                    </div>
                </Link>
            </div>
            
            <div class="absolute bottom-6 left-6 text-[10px] font-bold uppercase tracking-[0.2em] text-slate-500">
                © {{ new Date().getFullYear() }} Kitamo.
            </div>
        </section>

    </div>
</template>

<style>
/* Smooth out the scroll */
html {
    scroll-behavior: smooth;
}
</style>
