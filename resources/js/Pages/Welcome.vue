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
    scrolled.value = window.scrollY > 50;
    const reveals = document.querySelectorAll('.reveal');
    reveals.forEach(element => {
        const windowHeight = window.innerHeight;
        const elementTop = element.getBoundingClientRect().top;
        if (elementTop < windowHeight - 100) {
            element.classList.add('active');
        }
    });
};

onMounted(() => {
    setTimeout(() => { isLoaded.value = true; }, 100);
    window.addEventListener('scroll', handleScroll);
    handleScroll();
});

onUnmounted(() => {
    window.removeEventListener('scroll', handleScroll);
});

type Billing = 'monthly' | 'annual';
const billing = ref<Billing>('monthly');

const testimonials = [
    {
        quote: '“Com o Kitamo eu vi que gastava R$ 400 só em café e Uber. Ajustei isso e sobrou pra investir.”',
        name: 'LUCAS MENDES',
        role: 'Designer',
        initials: 'LM',
        color: 'bg-emerald-500/10 text-emerald-400 border-emerald-500/20'
    },
    {
        quote: '“O modo escuro é lindo e a função de recuperação de senha foi a mais rápida que já vi. Recomendo!”',
        name: 'SARAH F.',
        role: 'Dev Front-end',
        initials: 'SF',
        color: 'bg-teal-500/10 text-teal-400 border-teal-500/20'
    },
    {
        quote: '“Em 10 minutos com os relatórios do app, eu já tinha cortado três gastos invisíveis.”',
        name: 'MATEUS R.',
        role: 'Analista',
        initials: 'MR',
        color: 'bg-blue-500/10 text-blue-400 border-blue-500/20'
    }
];

const bentoItems = [
    {
        title: 'Visão de Raio-X',
        desc: 'Saiba exatamente pra onde foi aquele pix de ontem. Categorias automáticas e gráficos simples.',
        span: 'md:col-span-2 md:row-span-2',
        icon: 'M15 12a3 3 0 11-6 0 3 3 0 016 0z M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z',
        visual: 'chart'
    },
    {
        title: 'Notificações que Salvam',
        desc: 'A gente te avisa antes dos juros chegarem implacáveis.',
        span: 'md:col-span-1 md:row-span-1',
        icon: 'M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9',
        visual: 'alert'
    },
    {
        title: 'Metas Possíveis',
        desc: 'Define quanto quer guardar e acompanha a barra encher.',
        span: 'md:col-span-1 md:row-span-1',
        icon: 'M13 10V3L4 14h7v7l9-11h-7z',
        visual: 'target'
    }
];
</script>

<template>
    <Head title="Kitamo | O fim do mês tranquilo" />

    <div class="min-h-screen bg-[#050505] text-slate-300 font-sans selection:bg-teal-500/30 overflow-x-hidden relative">
        <!-- Noise Texture -->
        <div class="fixed inset-0 z-50 pointer-events-none opacity-[0.025] mix-blend-overlay" style="background-image: url('data:image/svg+xml,%3Csvg viewBox=%220 0 200 200%22 xmlns=%22http://www.w3.org/2000/svg%22%3E%3Cfilter id=%22noiseFilter%22%3E%3CfeTurbulence type=%22fractalNoise%22 baseFrequency=%220.65%22 numOctaves=%223%22 stitchTiles=%22stitch%22/%3E%3C/filter%3E%3Crect width=%22100%25%22 height=%22100%25%22 filter=%22url(%23noiseFilter)%22/%3E%3C/svg%3E')"></div>
        
        <!-- Ambient Glows -->
        <div class="absolute top-0 left-1/2 -translate-x-1/2 w-[800px] h-[500px] bg-teal-500/10 rounded-full blur-[120px] pointer-events-none -z-10"></div>
        <div class="absolute bottom-0 left-0 w-[600px] h-[600px] bg-blue-500/10 rounded-full blur-[140px] pointer-events-none -z-10"></div>

        <!-- Navigation -->
        <header :class="['fixed top-0 inset-x-0 z-40 transition-all duration-500', scrolled ? 'py-3' : 'py-6']">
            <div class="max-w-6xl mx-auto px-6">
                <div :class="['flex items-center justify-between rounded-2xl px-6 transition-all duration-500', scrolled ? 'h-14 bg-white/5 border border-white/10 backdrop-blur-md shadow-2xl' : 'h-14 bg-transparent border border-transparent']">
                    <div class="flex items-center gap-3 relative group cursor-pointer">
                        <div class="w-8 h-8 rounded-lg bg-gradient-to-br from-teal-400 to-teal-600 flex items-center justify-center shadow-[0_0_20px_rgba(20,184,166,0.4)] group-hover:shadow-[0_0_30px_rgba(20,184,166,0.6)] transition-all">
                            <span class="text-white font-black text-lg leading-none -ml-0.5">K</span>
                        </div>
                        <span class="text-white font-bold tracking-tight text-lg">Kitamo</span>
                    </div>

                    <nav class="hidden md:flex items-center gap-8 text-sm font-medium text-slate-400">
                        <a href="#vantagens" class="hover:text-white transition-colors">Vantagens</a>
                        <a href="#recursos" class="hover:text-white transition-colors">Recursos</a>
                        <a href="#depoimentos" class="hover:text-white transition-colors">Relatos</a>
                    </nav>

                    <div class="flex items-center gap-4">
                        <Link v-if="canLogin" href="/login" class="text-sm font-medium text-slate-400 hover:text-white transition-colors hidden sm:block">Entrar</Link>
                        <Link v-if="canRegister" href="/register" class="h-9 px-5 rounded-full bg-white text-black text-sm font-bold flex items-center justify-center hover:bg-slate-200 transition-colors shadow-[0_0_15px_rgba(255,255,255,0.1)]">
                            Criar conta
                        </Link>
                    </div>
                </div>
            </div>
        </header>

        <!-- Hero Section -->
        <main class="relative pt-32 pb-20 lg:pt-48 lg:pb-32 px-6">
            <div class="max-w-5xl mx-auto text-center">
                
                <div :class="['inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-white/5 border border-white/10 backdrop-blur-sm transition-all duration-1000 ease-out translate-y-4 opacity-0', isLoaded ? '!translate-y-0 !opacity-100' : '']">
                    <span class="w-1.5 h-1.5 rounded-full bg-teal-400 animate-pulse"></span>
                    <span class="text-xs font-semibold text-slate-300 uppercase tracking-widest">KITAMO 2.0 DISPONÍVEL</span>
                </div>

                <h1 :class="['mt-8 text-5xl sm:text-7xl lg:text-8xl font-extrabold tracking-tighter text-transparent bg-clip-text bg-gradient-to-b from-white via-white to-slate-500 leading-[1.1] sm:leading-[1.1] transition-all duration-1000 delay-100 ease-out translate-y-8 opacity-0', isLoaded ? '!translate-y-0 !opacity-100' : '']">
                    O fim do mês não <br class="hidden sm:block" />
                    precisa ser um filme <br class="hidden sm:block" />
                    <span class="relative">
                        <span class="relative z-10 text-transparent bg-clip-text bg-gradient-to-r from-teal-400 to-emerald-500">de terror.</span>
                        <span class="absolute -bottom-2 left-0 w-full h-3 bg-teal-500/20 blur-md rounded-full -z-10"></span>
                    </span>
                </h1>

                <p :class="['mt-8 max-w-2xl mx-auto text-lg sm:text-xl text-slate-400 font-medium leading-relaxed transition-all duration-1000 delay-200 ease-out translate-y-8 opacity-0', isLoaded ? '!translate-y-0 !opacity-100' : '']">
                    Chega de suar frio no dia 20. O Kitamo organiza tua grana, te avisa antes do boleto vencer e ainda te mostra se vai sobrar pro churrasco.
                </p>

                <div :class="['mt-12 flex flex-col sm:flex-row items-center justify-center gap-4 transition-all duration-1000 delay-300 ease-out translate-y-8 opacity-0', isLoaded ? '!translate-y-0 !opacity-100' : '']">
                    <Link href="/register" class="group relative h-12 inline-flex items-center justify-center px-8 rounded-full bg-teal-500 text-white font-bold text-sm overflow-hidden hover:scale-105 transition-all duration-300 active:scale-95 w-full sm:w-auto shadow-[0_0_40px_rgba(20,184,166,0.3)]">
                        <div class="absolute inset-0 bg-gradient-to-r from-teal-400 to-emerald-500 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                        <span class="relative z-10 flex items-center gap-2">
                            Começar de graça
                            <svg class="w-4 h-4 group-hover:translate-x-1 transition-transform" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
                            </svg>
                        </span>
                    </Link>
                    <a href="#vantagens" class="h-12 inline-flex items-center justify-center px-8 rounded-full bg-white/5 border border-white/10 text-white font-bold text-sm hover:bg-white/10 transition-all w-full sm:w-auto">
                        Ver como funciona
                    </a>
                </div>

                <!-- Product Preview Mockup -->
                <div :class="['mt-24 relative max-w-5xl mx-auto transition-all duration-1000 delay-500 ease-out translate-y-16 opacity-0', isLoaded ? '!translate-y-0 !opacity-100' : '']">
                    <div class="absolute -inset-1 bg-gradient-to-b from-teal-500/20 to-transparent blur-2xl rounded-[40px]"></div>
                    <div class="relative rounded-t-[40px] md:rounded-[40px] border border-white/10 bg-[#0A0A0A] overflow-hidden shadow-2xl flex items-center justify-center aspect-[16/10] sm:aspect-video">
                        <!-- Mockup abstraction -->
                        <div class="absolute inset-0 bg-[linear-gradient(rgba(255,255,255,0.03)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,0.03)_1px,transparent_1px)] bg-[size:40px_40px] [mask-image:radial-gradient(ellipse_60%_60%_at_50%_0%,#000_70%,transparent_100%)]"></div>
                        
                        <div class="relative w-[300px] sm:w-[500px] md:w-[700px] p-6 rounded-2xl bg-[#0F0F0F] border border-white/10 shadow-2xl transform  translate-y-10 grouphover:-translate-y-2 transition-transform duration-700">
                            <!-- Fake App Header -->
                            <div class="flex items-center justify-between border-b border-white/5 pb-4 mb-6">
                                <div class="w-24 h-4 rounded-full bg-white/10"></div>
                                <div class="flex gap-2">
                                    <div class="w-8 h-8 rounded-full bg-teal-500/20 border border-teal-500/30 flex items-center justify-center">
                                        <div class="w-2 h-2 rounded-full bg-teal-400"></div>
                                    </div>
                                </div>
                            </div>
                            <!-- Fake Graph -->
                            <div class="flex gap-4 items-end h-32 mb-6 border-b border-white/5 pb-4">
                                <div class="w-full bg-white/5 rounded-t-sm h-[30%]"></div>
                                <div class="w-full bg-red-500/20 rounded-t-sm h-[60%] border-t border-red-500/50"></div>
                                <div class="w-full bg-emerald-500/20 rounded-t-sm h-[90%] border-t border-emerald-500/50 relative">
                                    <div class="absolute -top-3 left-1/2 -translate-x-1/2 w-4 h-4 bg-emerald-400 rounded-full shadow-[0_0_10px_#34d399] animate-pulse"></div>
                                </div>
                                <div class="w-full bg-white/5 rounded-t-sm h-[40%]"></div>
                                <div class="w-full bg-white/5 rounded-t-sm h-[70%]"></div>
                                <div class="hidden sm:block w-full bg-white/5 rounded-t-sm h-[50%]"></div>
                            </div>
                            <!-- Fake List -->
                            <div class="space-y-3">
                                <div class="flex items-center justify-between p-3 rounded-xl bg-white/5">
                                    <div class="flex items-center gap-3">
                                        <div class="w-10 h-10 rounded-lg bg-teal-500/20"></div>
                                        <div>
                                            <div class="w-20 h-3 rounded bg-white/20 mb-2"></div>
                                            <div class="w-12 h-2 rounded bg-white/10"></div>
                                        </div>
                                    </div>
                                    <div class="w-16 h-4 rounded bg-emerald-400/20"></div>
                                </div>
                                <div class="flex items-center justify-between p-3 rounded-xl bg-white/5">
                                    <div class="flex items-center gap-3">
                                        <div class="w-10 h-10 rounded-lg bg-red-500/20"></div>
                                        <div>
                                            <div class="w-24 h-3 rounded bg-white/20 mb-2"></div>
                                            <div class="w-14 h-2 rounded bg-white/10"></div>
                                        </div>
                                    </div>
                                    <div class="w-16 h-4 rounded bg-red-400/20"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>

        <!-- Logo Cloud -->
        <section class="border-y border-white/5 bg-[#080808] py-12 text-center reveal">
            <p class="text-[10px] font-bold uppercase tracking-[0.3em] text-slate-500 mb-8">A escolha de quem busca paz financeira verdadeira</p>
            <div class="flex flex-wrap justify-center gap-8 sm:gap-16 opacity-50 grayscale hover:grayscale-0 transition-all duration-700">
                <div class="flex items-center gap-2 text-xl font-bold font-serif italic"><span class="w-6 h-6 rounded bg-white/20 flex items-center justify-center shrink-0">✦</span> Vercelio</div>
                <div class="flex items-center gap-2 text-xl font-black tracking-tighter"><span class="w-6 h-6 rounded-full bg-white/20 shrink-0"></span> ACME Corp</div>
                <div class="flex items-center gap-2 text-xl font-medium tracking-widest"><span class="w-6 h-6 shrink-0 rotate-45 bg-white/20"></span> LINEARIS</div>
                <div class="hidden sm:flex items-center gap-2 text-xl font-bold"><span class="w-6 h-6 shrink-0 bg-white/20 rounded-tl-lg rounded-br-lg"></span> GLOBAL</div>
            </div>
        </section>

        <!-- Bento Grid Features -->
        <section id="recursos" class="py-32 px-6 max-w-6xl mx-auto">
            <div class="text-center mb-20 reveal">
                <h2 class="text-3xl sm:text-5xl font-extrabold tracking-tight text-white">Centralize tudo. <br/> <span class="text-slate-500">Controle o futuro.</span></h2>
                <p class="mt-6 text-slate-400 max-w-xl mx-auto text-lg">Seu dinheiro não deve ser um mistério. Construímos ferramentas precisas para você saber exatamente onde pisa.</p>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-6 auto-rows-[300px]">
                <div v-for="(item, i) in bentoItems" :key="item.title" :class="[item.span, 'reveal group relative rounded-[32px] bg-[#0A0A0A] border border-white/10 overflow-hidden hover:border-teal-500/30 transition-colors duration-500 p-8 flex flex-col justify-end']">
                    <div class="absolute inset-0 bg-gradient-to-b from-transparent to-black/60 z-10"></div>
                    
                    <!-- Decorative visuals -->
                    <div class="absolute inset-0 opacity-20 group-hover:opacity-40 transition-opacity duration-700 bg-[radial-gradient(ellipse_at_top_right,_var(--tw-gradient-stops))] from-teal-900 via-transparent to-transparent"></div>
                    
                    <div class="relative z-20">
                        <div class="w-12 h-12 rounded-2xl bg-white/5 border border-white/10 flex items-center justify-center mb-6 text-teal-400">
                            <svg class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="item.icon" />
                            </svg>
                        </div>
                        <h3 class="text-2xl font-bold text-white mb-3">{{ item.title }}</h3>
                        <p class="text-slate-400 text-sm leading-relaxed max-w-md">{{ item.desc }}</p>
                    </div>
                </div>
            </div>
        </section>

        <!-- CTA Section -->
        <section class="py-32 px-6 relative reveal">
            <div class="absolute inset-x-0 bottom-0 h-px bg-gradient-to-r from-transparent via-teal-500/50 to-transparent"></div>
            <div class="max-w-4xl mx-auto rounded-[40px] bg-gradient-to-b from-[#0F0F0F] to-[#050505] border border-white/10 p-12 sm:p-20 text-center relative overflow-hidden">
                <div class="absolute top-0 left-1/2 -translate-x-1/2 w-full h-full bg-[radial-gradient(ellipse_at_top,_var(--tw-gradient-stops))] from-teal-900/40 via-transparent to-transparent"></div>
                
                <h2 class="relative z-10 text-4xl sm:text-6xl font-extrabold tracking-tighter text-white mb-6">Pronto para assumir <br/> o controle?</h2>
                <p class="relative z-10 text-slate-400 text-lg mb-10 max-w-lg mx-auto">Junte-se a milhares de pessoas que deixaram o estresse financeiro no passado e construíram um futuro sólido.</p>
                
                <div class="relative z-10 flex flex-col sm:flex-row items-center justify-center gap-4">
                    <Link href="/register" class="h-14 px-10 inline-flex items-center justify-center rounded-full bg-white text-black font-bold hover:bg-slate-200 transition-colors shadow-[0_0_30px_rgba(255,255,255,0.15)] w-full sm:w-auto">
                        Criar minha conta
                    </Link>
                </div>
            </div>
        </section>

        <footer class="py-12 px-6 border-t border-white/5 text-center text-slate-500 text-sm">
            <div class="flex items-center justify-center gap-2 mb-4">
                <div class="w-6 h-6 rounded bg-teal-500/20 flex items-center justify-center text-teal-400 font-bold text-xs">K</div>
                <span class="font-bold text-white tracking-tight">Kitamo</span>
            </div>
            <p>© {{ new Date().getFullYear() }} Kitamo. Todos os direitos reservados. Feito para quem sabe o valor do seu esforço.</p>
        </footer>
    </div>
</template>

<style>
.reveal {
    opacity: 0;
    transform: translateY(30px);
    transition: all 1s cubic-bezier(0.16, 1, 0.3, 1);
}
.reveal.active {
    opacity: 1;
    transform: translateY(0);
}
</style>
