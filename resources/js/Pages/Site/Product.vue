<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';
import MotionSection from '@/Components/site/MotionSection.vue';

const props = defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const modules = [
    {
        id: 'contas',
        title: 'Tudo num lugar só',
        description: 'Chega de abrir 5 apps de banco pra saber quanto você tem. Conta corrente, poupança, VR... junta tudo aqui.',
        bullets: ['Extrato unificado', 'Quanto entra e quanto sai', 'Separação fácil'],
        image: 'https://images.pexels.com/photos/3184291/pexels-photo-3184291.jpeg?auto=compress&cs=tinysrgb&w=1000',
        align: 'left',
    },
    {
        id: 'cartoes',
        title: 'Domador de faturas',
        description: 'O cartão de crédito não é seu inimigo se você sabe quanto a fatura vai dar antes dela fechar. A gente te mostra isso.',
        bullets: ['Limite sempre sob controle', 'Parcelas na linha do tempo', 'Sem sustos no vencimento'],
        image: 'https://images.pexels.com/photos/3183197/pexels-photo-3183197.jpeg?auto=compress&cs=tinysrgb&w=1000',
        align: 'right',
    },
    {
        id: 'metas',
        title: 'A grana do futuro',
        description: 'Seja a viagem pro Nordeste ou o conserto do carro, guarde com objetivo e veja a barrinha encher.',
        bullets: ['Prazo + Valor = Foco', 'Guarde aos poucos', 'Progresso visual'],
        image: 'https://images.pexels.com/photos/3760067/pexels-photo-3760067.jpeg?auto=compress&cs=tinysrgb&w=1000',
        align: 'left',
    },
    {
        id: 'projecao',
        title: 'Visão Raio-X do Mês',
        description: 'Nosso algoritmo cruza o que você ganha com o que gasta e prevê os riscos do mês antes de acontecer.',
        bullets: ['30 dias ou mais pra frente', 'Bandeira vermelha na hora', 'Ação antes do perrengue'],
        image: 'https://images.pexels.com/photos/3182812/pexels-photo-3182812.jpeg?auto=compress&cs=tinysrgb&w=1000',
        align: 'right',
    },
];

const journey = [
    {
        number: '1',
        title: 'Bota os pingos nos is',
        description: 'Puxa o extrato uma vez, anota as contas fixas e pronto. A fundação tá feita. Zero stress inicial.',
        colSpan: 'col-span-1 md:col-span-2 lg:col-span-3',
        height: 'min-h-[250px]',
    },
    {
        number: '2',
        title: 'Alimenta o monstrinho',
        description: 'Tirou do bolso? Coloca no Kitamo. Rápido, como mandar um zap.',
        colSpan: 'col-span-1 md:col-span-1 lg:col-span-2',
        height: 'min-h-[200px]',
    },
    {
        number: '3',
        title: 'Recebe a real',
        description: 'O painel acende vermelho se for faltar grana.',
        colSpan: 'col-span-1 md:col-span-1 lg:col-span-2',
        height: 'min-h-[200px]',
    },
    {
        number: '4',
        title: 'O mês nas suas regras',
        description: 'Você move as peças, enxuga um gasto hoje, decide cortar assinatura, e a paz volta ao seu bolso.',
        colSpan: 'col-span-1 md:col-span-2 lg:col-span-3',
        height: 'min-h-[250px]',
    },
];

const personas = [
    'Freelas (A grana pinga diferente)',
    'Casais em paz (Chega de briga por extrato)',
    'Ganha bem mas gasta mal (Acabou o empate)',
    'Traumatizados por planilhas feias',
];
</script>

<template>
    <Head title="Produto | Kitamo">
        <meta name="description" content="Por dentro do Kitamo: veja como a gente faz você parar de sofrer com o fim do mês." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <!-- Hero Section - Centered and Immersive -->
        <MotionSection class="relative min-h-screen w-full overflow-hidden bg-slate-950 text-white flex flex-col justify-center items-center pt-32 pb-40">
            <div class="absolute inset-0 opacity-[0.03] mix-blend-overlay pointer-events-none" style="background-image: url('data:image/svg+xml,%3Csvg viewBox=%220 0 200 200%22 xmlns=%22http://www.w3.org/2000/svg%22%3E%3Cfilter id=%22noiseFilter%22%3E%3CfeTurbulence type=%22fractalNoise%22 baseFrequency=%220.8%22 numOctaves=%224%22 stitchTiles=%22stitch%22/%3E%3C/filter%3E%3Crect width=%22100%25%22 height=%22100%25%22 filter=%22url(%23noiseFilter)%22/%3E%3C/svg%3E');"></div>
            
            <div class="absolute top-0 inset-x-0 h-[40vh] bg-gradient-to-b from-teal-900/30 to-transparent blur-3xl mix-blend-screen pointer-events-none"></div>

            <div class="relative z-10 mx-auto w-full max-w-[1000px] px-6 text-center flex flex-col items-center">
                <p class="inline-flex items-center space-x-2 text-[10px] font-bold uppercase tracking-[0.25em] text-teal-400 mb-8 px-4 py-2 rounded-full border border-teal-500/20 bg-teal-500/10 backdrop-blur shadow-[0_0_15px_theme(colors.teal.500/20)]">A Ferramenta</p>
                <h1 class="text-5xl sm:text-6xl md:text-[6.5rem] leading-[0.92] tracking-tighter text-slate-100 font-extrabold max-w-4xl">
                    Design focado no<br>
                    <span class="text-transparent bg-clip-text bg-gradient-to-r from-teal-400 to-emerald-300 font-serif italic pr-2">que importa.</span>
                </h1>
                <p class="mt-8 text-xl sm:text-2xl leading-relaxed text-slate-400 font-medium max-w-2xl mx-auto">
                    Tiramos a gordura dos apps de banco tradicionais. Deixamos só a lâmina que corta o problema e te põe no controle.
                </p>
                
                <div class="mt-12 flex gap-4">
                     <Link :href="canRegister ? '/register' : '/login'" class="inline-flex h-16 items-center justify-center rounded-2xl bg-teal-500 px-10 text-[13px] font-extrabold uppercase tracking-[0.15em] text-slate-950 transition-all hover:bg-teal-400 hover:scale-105 active:scale-95 shadow-[0_0_40px_rgba(20,184,166,0.4)]">
                        Criar minha conta
                    </Link>
                </div>
            </div>

            <!-- Floating Hero Image intercepting next section -->
            <div class="absolute -bottom-32 sm:-bottom-48 md:-bottom-64 left-1/2 -translate-x-1/2 w-[90%] max-w-[1200px] z-20 group perspective-1000">
                <div class="absolute inset-0 bg-teal-500/20 rounded-[3rem] blur-3xl transform group-hover:bg-teal-400/30 transition-colors duration-1000 opacity-60"></div>
                <img
                    src="https://images.pexels.com/photos/834863/pexels-photo-834863.jpeg?auto=compress&cs=tinysrgb&w=1400"
                    alt="Visão geral do produto dashboard"
                    class="relative w-full h-auto aspect-video md:aspect-[21/9] object-cover rounded-[2.5rem] border border-white/10 shadow-2xl filter saturate-[0.8] hover:saturate-110 transition-all duration-700 transform rotate-x-6 hover:rotate-x-0 group-hover:-translate-y-4"
                    style="transform-style: preserve-3d; transform: rotateX(8deg);"
                />
                
                <!-- Floating tags mapping to the image -->
                <div class="absolute top-1/4 left-[10%] hidden md:block bg-slate-950/80 backdrop-blur border border-white/20 text-white px-4 py-2 rounded-2xl text-[10px] font-bold uppercase tracking-[0.2em] transform -translate-y-full shadow-lg group-hover:-translate-y-8 transition-all duration-700 delay-100">Contas</div>
                
                <div class="absolute bottom-1/4 right-[15%] hidden md:block bg-teal-500/90 backdrop-blur border border-teal-300 text-teal-950 px-4 py-2 rounded-2xl text-[10px] font-bold uppercase tracking-[0.2em] transform translate-y-full shadow-[0_0_20px_theme(colors.teal.500/40)] group-hover:translate-y-8 transition-all duration-700 delay-200">Previsão Segura</div>
            </div>
        </MotionSection>

        <!-- Spacer for the floating image -->
        <div class="bg-gray-50 h-32 sm:h-48 md:h-64 border-t border-slate-200"></div>

        <!-- Alternating Modules Section (Zig-Zag dynamic layout) -->
        <MotionSection class="bg-gray-50 py-24 pb-32 overflow-hidden">
            <div class="mx-auto w-full max-w-[1440px] px-6 md:px-12">
                <div class="text-center mb-20 md:mb-32">
                    <p class="inline-flex items-center space-x-2 text-[10px] font-bold uppercase tracking-[0.2em] text-teal-600 mb-4 bg-teal-50 px-4 py-2 rounded-full border border-teal-100">Pilares da Plataforma</p>
                    <h2 class="text-4xl sm:text-5xl font-extrabold tracking-tighter text-slate-900 leading-[1.05]">
                        Toda grana. <br><span class="font-serif italic text-teal-500">Traduzida.</span>
                    </h2>
                </div>

                <div class="space-y-32 lg:space-y-40">
                    <article
                        v-for="(module, index) in modules"
                        :id="module.id"
                        :key="module.id"
                        class="relative group"
                    >
                        <!-- Grid layout flipping order based on align property -->
                        <div class="grid lg:grid-cols-2 gap-12 lg:gap-24 items-center">
                            
                            <div class="order-2 lg:order-none relative" :class="{'lg:col-start-2': module.align === 'right', 'lg:col-start-1': module.align === 'left'}">
                                <!-- Background giant number -->
                                <div class="absolute -top-16 -left-8 text-[12rem] font-bold text-slate-100 opacity-60 leading-none select-none pointer-events-none group-hover:text-teal-50 transition-colors duration-500 z-0">
                                    0{{ index + 1 }}
                                </div>
                                <div class="relative z-10 flex flex-col items-start">
                                    <div class="h-10 w-10 bg-teal-100 text-teal-600 rounded-xl flex items-center justify-center font-extrabold text-sm mb-6">{{ index + 1 }}</div>
                                    <h3 class="text-4xl sm:text-5xl font-extrabold tracking-tight text-slate-900 mb-6 group-hover:text-teal-600 transition-colors duration-300">{{ module.title }}</h3>
                                    <p class="text-xl text-slate-600 leading-relaxed font-medium mb-10 max-w-lg">{{ module.description }}</p>
                                    
                                    <ul class="space-y-4">
                                        <li v-for="bullet in module.bullets" :key="bullet" class="flex items-center gap-4 text-base font-bold text-slate-800">
                                            <span class="flex items-center justify-center w-8 h-8 rounded-full bg-slate-100 group-hover:bg-teal-50 text-slate-400 group-hover:text-teal-500 transition-colors shadow-sm">
                                                <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3">
                                                    <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/>
                                                </svg>
                                            </span>
                                            {{ bullet }}
                                        </li>
                                    </ul>
                                </div>
                            </div>

                            <div class="order-1 lg:order-none" :class="{'lg:col-start-1 lg:row-start-1': module.align === 'right', 'lg:col-start-2 lg:row-start-1': module.align === 'left'}">
                                <div class="relative w-full aspect-[4/3] rounded-[2.5rem] overflow-hidden group-hover:shadow-[0_20px_50px_-15px_rgba(20,184,166,0.3)] transition-all duration-700">
                                    <div class="absolute inset-0 bg-slate-900/10 z-10 group-hover:opacity-0 transition-opacity duration-700"></div>
                                    <img
                                        :src="module.image"
                                        :alt="module.title"
                                        class="absolute inset-0 w-full h-full object-cover filter grayscale opacity-90 group-hover:grayscale-0 group-hover:opacity-100 group-hover:scale-105 transition-all duration-700"
                                        loading="lazy"
                                    />
                                    <!-- Decorative overlapping shape -->
                                    <div class="absolute -bottom-10 -right-10 w-32 h-32 bg-teal-500/20 blur-2xl rounded-full group-hover:bg-teal-400/40 transition-colors duration-500 z-20"></div>
                                </div>
                            </div>
                        </div>
                    </article>
                </div>
            </div>
        </MotionSection>

        <!-- Bento Box Journey Section -->
        <MotionSection class="bg-slate-950 py-32 text-white relative z-10 border-t border-slate-800 rounded-b-[4rem] shadow-2xl">
             <div class="absolute inset-0 opacity-[0.05] mix-blend-overlay pointer-events-none" style="background-image: url('data:image/svg+xml,%3Csvg viewBox=%220 0 200 200%22 xmlns=%22http://www.w3.org/2000/svg%22%3E%3Cfilter id=%22noiseFilter%22%3E%3CfeTurbulence type=%22fractalNoise%22 baseFrequency=%220.8%22 numOctaves=%224%22 stitchTiles=%22stitch%22/%3E%3C/filter%3E%3Crect width=%22100%25%22 height=%22100%25%22 filter=%22url(%23noiseFilter)%22/%3E%3C/svg%3E');"></div>
             
             <!-- Glowing orb background effect -->
             <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] bg-[radial-gradient(circle_at_center,rgba(20,184,166,0.1)_0,transparent_60%)] pointer-events-none"></div>

            <div class="mx-auto w-full max-w-[1440px] px-6 md:px-12 relative z-10">
                <div class="text-center mb-16">
                    <p class="inline-flex items-center space-x-2 text-[10px] font-bold uppercase tracking-[0.2em] text-teal-400 mb-4 bg-slate-900 border border-slate-800 px-4 py-2 rounded-full shadow-[0_0_20px_theme(colors.teal.500/10)] text-center">Fluxo Constante</p>
                    <h2 class="text-4xl sm:text-5xl lg:text-6xl font-extrabold tracking-tighter text-white leading-[1.05] max-w-3xl mx-auto">
                        Uma rotina de 10 minutos que <span class="font-serif italic text-teal-400 pr-2">salva semanas.</span>
                    </h2>
                </div>
                
                <!-- Bento Grid -->
                <div class="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-5 gap-4 auto-rows-[200px] md:auto-rows-[auto]">
                    <div 
                        v-for="step in journey" 
                        :key="step.number" 
                        :class="[step.colSpan, step.height]"
                        class="bg-white/5 border border-white/10 rounded-[2rem] p-8 md:p-10 flex flex-col hover:bg-white/10 transition-colors duration-500 group relative overflow-hidden backdrop-blur-sm"
                    >
                        <div class="absolute -right-10 -top-10 text-[10rem] font-bold text-white/5 group-hover:text-white/10 group-hover:scale-110 transition-transform duration-700 pointer-events-none">{{ step.number }}</div>
                        
                        <div class="flex items-center justify-center w-12 h-12 bg-slate-900 border border-slate-700 rounded-xl text-teal-400 font-extrabold text-lg mb-6 group-hover:border-teal-500 group-hover:bg-slate-800 transition-colors shadow-inner">{{ step.number }}</div>
                        <h3 class="text-2xl lg:text-3xl font-extrabold text-white mb-3 group-hover:text-teal-300 transition-colors z-10">{{ step.title }}</h3>
                        <p class="text-lg text-slate-400 font-medium leading-relaxed max-w-lg z-10">{{ step.description }}</p>
                    </div>
                </div>
            </div>
        </MotionSection>

        <!-- Personas / Horizontal Marquee Style List & CTA Final -->
        <MotionSection class="relative overflow-hidden bg-teal-500 pt-32 pb-40 text-slate-950">
            <div class="absolute inset-0 bg-[radial-gradient(ellipse_at_bottom_left,_var(--tw-gradient-stops))] from-teal-400 to-teal-700 mix-blend-multiply opacity-60"></div>
            
            <div class="mx-auto w-full max-w-[1440px] px-6 md:px-12 relative z-10 grid gap-20">
                <div class="text-center max-w-3xl mx-auto">
                    <h2 class="text-5xl sm:text-6xl lg:text-[5rem] font-extrabold tracking-tighter leading-[0.95] text-teal-950 mb-8 drop-shadow-sm">
                        Quem tá usando<br>e não <span class="font-serif italic text-white pr-2">larga mais?</span>
                    </h2>
                </div>

                <!-- Staggered floating tags for personas instead of standard list -->
                <div class="flex flex-wrap justify-center gap-4 max-w-5xl mx-auto mb-16">
                    <div
                        v-for="item in personas"
                        :key="item"
                        class="flex items-center gap-3 text-sm sm:text-lg font-bold bg-white/20 backdrop-blur-md px-6 py-4 rounded-[1.5rem] border border-white/30 text-teal-950 shadow-sm hover:scale-105 transition-transform"
                    >
                        <span class="w-3 h-3 rounded-full bg-slate-950 flex-shrink-0 animate-pulse"></span>
                        {{ item }}
                    </div>
                </div>

                <!-- Final CTA -->
                <div class="flex flex-col items-center justify-center text-center max-w-2xl mx-auto bg-slate-950 p-10 md:p-14 rounded-[3rem] shadow-2xl relative border border-slate-800 hover:-translate-y-2 transition-transform duration-500">
                    <div class="absolute -top-40 left-1/2 -translate-x-1/2 w-80 h-80 bg-teal-400/30 blur-3xl rounded-full"></div>
                    <h3 class="text-3xl sm:text-4xl font-extrabold text-white mb-4 tracking-tight relative z-10">Larga a planilha feia.</h3>
                    <p class="text-slate-400 font-medium mb-10 text-lg relative z-10">Montar seu mapa financeiro no Kitamo é mais rápido do que formatar célula no Excel.</p>
                    
                    <div class="flex flex-col sm:flex-row gap-4 w-full sm:w-auto relative z-10">
                        <Link
                            :href="canRegister ? '/register' : '/login'"
                            class="inline-flex h-16 items-center justify-center rounded-2xl bg-teal-500 px-10 text-[13px] font-extrabold uppercase tracking-[0.16em] text-slate-950 transition-all hover:bg-teal-400 hover:scale-[1.03] active:scale-95 shadow-[0_0_30px_theme(colors.teal.500/40)]"
                        >
                            Comece Di Grátis
                        </Link>
                        <Link
                            :href="route('site.pricing')"
                            class="inline-flex h-16 items-center justify-center rounded-2xl border border-white/10 bg-white/5 backdrop-blur-md px-10 text-[12px] font-bold uppercase tracking-[0.14em] text-slate-300 transition-colors hover:bg-white/10 hover:text-white"
                        >
                            Ver os Planos
                        </Link>
                    </div>
                </div>
            </div>
        </MotionSection>
    </SiteLayout>
</template>

<style scoped>
h1, h2, h3 {
    font-feature-settings: "salt" on, "ss01" on;
}
</style>
