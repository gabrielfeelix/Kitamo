<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';
import MotionSection from '@/Components/site/MotionSection.vue';
import AnimatedDashboardMockup from '@/Components/site/AnimatedDashboardMockup.vue';

const props = defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const primaryHref = props.canRegister ? '/register' : '/login';

// Reimagined Destination Cards for an Asymmetrical Bento Grid
const destinationCards = [
    {
        title: 'A Galera CLT',
        subtitle: 'Boleto no Dia Certo',
        description: 'Faça seu salário render conectando seus gastos com o ciclo mensal do pagamento.',
        image: 'https://images.pexels.com/photos/1184572/pexels-photo-1184572.jpeg?auto=compress&cs=tinysrgb&w=1000',
        wrapperClass: 'md:col-span-8',
        heightClass: 'h-[450px]',
    },
    {
        title: 'Para Casais',
        subtitle: 'Paz Conjugal',
        description: 'Juntem as rendas num mapa único e acabem com as brigas por extrato surpresa.',
        image: 'https://images.pexels.com/photos/572056/pexels-photo-572056.jpeg?auto=compress&cs=tinysrgb&w=1000',
        wrapperClass: 'md:col-span-4',
        heightClass: 'h-[450px]',
    },
    {
        title: 'Autônomos e Freelas',
        subtitle: 'Domando o Imprevisível',
        description: 'Ganhou bem esse mês? Joga pra frente. A antecipação te salva na vaca magra.',
        image: 'https://images.pexels.com/photos/3760263/pexels-photo-3760263.jpeg?auto=compress&cs=tinysrgb&w=1400',
        wrapperClass: 'md:col-span-12',
        heightClass: 'h-[400px] sm:h-[500px]',
    },
];

const flowTimeline = [
    {
        number: '01',
        title: 'A Fundação',
        text: 'Cadastre contas e dívidas. Um clique, e sua base tá pronta.',
    },
    {
        number: '02',
        title: 'O Hábito',
        text: 'Tirou do bolso? Joga no app. 5 segundos pro hábito virar rotina.',
    },
    {
        number: '03',
        title: 'O Radar',
        text: 'O sinal vermelho acende se faltar grana pro boleto de semana que vem.',
    },
    {
        number: '04',
        title: 'A Paz',
        text: 'Ajuste a rota, corte o que der, e o mês volta pro azul na sua frente.',
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
                    Antecipe furos, dome faturas e pouse o avião no fim do mês com paz de espírito. Totalmente online.
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
                    <p class="mt-5 text-slate-400 text-sm font-medium tracking-wide">Leva 2 minutos. Sem cartão de crédito.</p>
                </div>
            </div>

            <!-- Floating UI Preview (Breaks the next section) -->
            <div class="relative mx-auto w-[90%] max-w-[1200px] z-20 perspective-1000 mt-20 sm:mt-24 lg:mt-32 -mb-32 sm:-mb-40 lg:-mb-56">
                <div class="absolute inset-0 bg-teal-500/10 rounded-[4rem] blur-3xl transform -translate-y-10"></div>
                <div class="relative rounded-[2.5rem] sm:rounded-[4rem] border border-white/10 bg-slate-900/80 backdrop-blur-sm shadow-[0_30px_60px_-15px_rgba(0,0,0,0.8)] overflow-hidden transition-transform duration-1000 transform hover:-translate-y-4 rotate-x-6 hover:rotate-x-0 group">
                    <AnimatedDashboardMockup />
                    <div class="absolute inset-x-0 bottom-0 h-40 bg-gradient-to-t from-slate-950 to-transparent pointer-events-none"></div>
                </div>
            </div>
        </MotionSection>

        <!-- Spacer for the intersecting hero image -->
        <div class="bg-slate-50 h-32 sm:h-48 lg:h-64 border-t border-slate-200"></div>

        <!-- ================= BENTO GRID DESTINATIONS ================= -->
        <MotionSection class="bg-slate-50 py-24 pb-40">
            <div class="mx-auto w-full max-w-[1440px] px-6 md:px-12">
                <div class="flex flex-col md:flex-row items-end justify-between gap-10 mb-20 text-slate-900 border-b border-slate-200 pb-16">
                    <div class="max-w-3xl">
                        <p class="text-[12px] font-extrabold uppercase tracking-[0.2em] text-teal-600 mb-6 drop-shadow-sm bg-teal-50 px-4 py-2 rounded-full border border-teal-100 w-fit">Qual a sua dor hoje?</p>
                        <h2 class="text-5xl lg:text-[5rem] font-extrabold tracking-tighter leading-[0.95]">
                            Uma ferramenta.<br><span class="font-serif italic text-slate-500">Múltiplas vidas salvas.</span>
                        </h2>
                    </div>
                    <p class="max-w-sm text-lg font-medium text-slate-500 leading-relaxed md:text-right">A inteligência do Kitamo se adapta ao formato da sua bagunça financeira.</p>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-12 gap-6 lg:gap-8">
                    <div 
                        v-for="card in destinationCards" 
                        :key="card.title" 
                        class="group relative overflow-hidden rounded-[3rem] bg-slate-900 border border-slate-200 shadow-xl"
                        :class="[card.wrapperClass, card.heightClass]"
                    >
                        <!-- Dynamic Image -->
                        <img 
                            :src="card.image" 
                            :alt="card.title" 
                            class="absolute inset-0 w-full h-full object-cover opacity-60 mix-blend-luminosity filter group-hover:mix-blend-normal group-hover:opacity-100 group-hover:scale-105 transition-all duration-700"
                        />
                        <!-- Soft Gradients -->
                        <div class="absolute inset-0 bg-gradient-to-t from-slate-950 via-slate-900/50 to-transparent group-hover:from-slate-950/90 transition-colors duration-500"></div>
                        
                        <!-- Intersecting Content -->
                        <div class="absolute inset-0 p-10 lg:p-14 flex flex-col justify-end text-white outline-none">
                            <div class="transform group-hover:-translate-y-4 transition-transform duration-500">
                                <p class="text-[11px] font-extrabold uppercase tracking-[0.25em] text-teal-400 mb-4 drop-shadow-md bg-slate-950/50 backdrop-blur w-fit px-3 py-1.5 rounded-lg border border-white/10">{{ card.subtitle }}</p>
                                <h3 class="text-4xl lg:text-5xl font-extrabold tracking-tighter mb-4">{{ card.title }}</h3>
                                <p class="text-lg text-slate-300 font-medium max-w-lg leading-relaxed opacity-0 group-hover:opacity-100 transition-opacity duration-500 delay-100">{{ card.description }}</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </MotionSection>

        <!-- ================= VERTICAL SNAKE TIMELINE ================= -->
        <MotionSection class="bg-slate-950 py-40 relative text-white overflow-hidden border-t-[8px] border-teal-500 shadow-2xl">
            <!-- Background organic blob -->
            <div class="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-[1000px] h-[1000px] bg-[radial-gradient(circle_at_center,rgba(20,184,166,0.08)_0,transparent_70%)] pointer-events-none"></div>

            <div class="max-w-[1440px] mx-auto px-6 md:px-12 relative z-10 flex flex-col lg:flex-row gap-20">
                <div class="lg:w-1/3 lg:sticky lg:top-40 h-fit">
                    <h2 class="text-5xl lg:text-[4.5rem] font-extrabold tracking-tighter text-white leading-[0.95] mb-8">O ritmo.</h2>
                    <p class="text-xl text-slate-400 font-medium leading-relaxed">Não force o controle financeiro a ser uma punição diária. Siga os 4 passos viscerais que mantêm a engrenagem limpa gastando minutos.</p>
                </div>
                
                <div class="lg:w-2/3 flex flex-col gap-12 sm:gap-6">
                    <article 
                        v-for="(step, index) in flowTimeline" 
                        :key="step.number"
                        class="relative group rounded-[3rem] bg-white/5 border border-white/10 p-10 sm:p-14 hover:bg-white/10 transition-colors duration-500 backdrop-blur-sm overflow-hidden"
                        :class="index % 2 !== 0 ? 'sm:ml-20' : 'sm:mr-20'"
                    >
                         <!-- Giant Background Number -->
                         <div class="absolute right-8 top-8 text-[8rem] sm:text-[10rem] font-extrabold leading-none text-white/5 pointer-events-none select-none group-hover:text-teal-500/10 group-hover:rotate-12 transition-[color,transform] duration-700">
                             {{ step.number }}
                         </div>
                         
                         <div class="relative z-10 flex flex-col xl:flex-row gap-8 items-start xl:items-center">
                             <div class="flex-1">
                                 <div class="h-16 w-16 bg-slate-900 border border-slate-700 rounded-2xl flex items-center justify-center font-extrabold text-2xl text-teal-400 mb-8 shadow-inner group-hover:scale-110 group-hover:border-teal-500 transition-[transform,border-color] duration-300">
                                     {{ step.number }}
                                 </div>
                                 <h3 class="text-3xl sm:text-4xl font-extrabold tracking-tight text-white mb-6 group-hover:text-teal-300 transition-colors">{{ step.title }}</h3>
                                 <p class="text-lg sm:text-xl text-slate-400 font-medium leading-relaxed max-w-md">{{ step.text }}</p>
                             </div>
                             
                             <!-- Micro-animation specific for step 2 "O Hábito" -->
                             <div v-if="step.number === '02'" class="xl:w-[250px] flex-shrink-0 mt-6 xl:mt-0 relative perspective-1000">
                                 <div class="absolute inset-0 bg-teal-500/10 blur-xl rounded-full scale-150 group-hover:animate-pulse transition-all duration-700 pointer-events-none"></div>
                                 <div class="relative bg-slate-900/80 p-5 border border-white/10 rounded-[2rem] shadow-2xl backdrop-blur-md transform rotate-y-[-10deg] rotate-x-[5deg] group-hover:rotate-0 group-hover:translate-y-[-5px] transition-[transform,box-shadow] duration-700 overflow-hidden">
                                     <div class="absolute top-0 inset-x-0 h-1 bg-gradient-to-r from-transparent via-teal-500 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-1000"></div>
                                     <div class="flex flex-col gap-4">
                                         <div class="flex items-center gap-3">
                                             <div class="w-10 h-10 rounded-full bg-slate-800 flex items-center justify-center shadow-inner">
                                                 <span class="text-red-400 text-lg">🍔</span>
                                             </div>
                                             <div class="flex flex-col gap-1">
                                                 <div class="h-2 w-16 bg-slate-700 rounded-full"></div>
                                                 <div class="h-1.5 w-10 bg-slate-800 rounded-full"></div>
                                             </div>
                                         </div>
                                         <div class="h-16 bg-slate-950/50 rounded-xl border border-white/5 flex flex-col items-center justify-center relative overflow-hidden group-hover:border-teal-500/30 transition-colors duration-700">
                                             <div class="absolute inset-0 bg-gradient-to-b from-teal-500/5 to-transparent"></div>
                                             <span class="text-teal-400 font-bold text-xl relative z-10 font-[tabular-nums] tracking-tight">- R$ 45,00</span>
                                         </div>
                                         <div class="h-10 bg-teal-500 rounded-xl flex items-center justify-center shadow-[0_5px_15px_theme(colors.teal.500/20)] relative overflow-hidden hover:bg-teal-400 transition-colors cursor-pointer group/btn">
                                             <div class="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent translate-x-[-100%] group-hover/btn:translate-x-[100%] transition-transform duration-1000"></div>
                                             <span class="text-slate-950 font-extrabold text-[11px] uppercase tracking-widest relative z-10 flex items-center gap-1">Lançar <svg class="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/></svg></span>
                                         </div>
                                     </div>
                                 </div>
                             </div>
                         </div>
                    </article>
                </div>
            </div>
        </MotionSection>

        <!-- ================= BRAWNY SERVICE BLOCKS ================= -->
        <MotionSection class="bg-white py-32 rounded-t-[4rem] rounded-b-[4rem] relative z-20 shadow-[0_-20px_50px_rgba(0,0,0,0.3)] border-b border-slate-200">
             <div class="mx-auto max-w-[1440px] px-6 md:px-12 text-center mb-20">
                 <p class="text-[12px] font-extrabold uppercase tracking-[0.2em] text-slate-400 mb-6 drop-shadow-sm bg-slate-100 px-4 py-2 rounded-full border border-slate-200 inline-block">Sem Firulas</p>
                 <h2 class="text-5xl lg:text-[4.5rem] font-extrabold tracking-tighter leading-[0.95] text-slate-900"><span class="italic font-serif text-teal-500 pr-2">Por que</span> Kitamo?</h2>
             </div>
             
             <div class="mx-auto max-w-[1440px] px-6 md:px-12 grid grid-cols-1 md:grid-cols-12 gap-8">
                  <div 
                      v-for="(block, idx) in serviceBlocks" 
                      :key="block.title" 
                      class="bg-slate-50 border border-slate-200 rounded-[3rem] p-10 sm:p-14 hover:shadow-2xl hover:-translate-y-2 transition-all duration-500 group flex flex-col"
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
                
                <p class="mt-12 text-2xl font-bold text-teal-950/80 max-w-2xl mx-auto px-4">Não espere mais 30 dias para mudar sua realidade. Feche o vazamento hoje.</p>
                
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
