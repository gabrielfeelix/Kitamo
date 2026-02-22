<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';
import PricingBlock from '@/Components/site/PricingBlock.vue';
import MotionSection from '@/Components/site/MotionSection.vue';
import { pricingPlans } from '@/types/site';

const props = defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const primaryHref = props.canRegister ? '/register' : '/login';

const destinationCards = [
    {
        title: 'Autônomos',
        subtitle: 'Renda irregular',
        description: 'Antecipe semanas de maior pressão antes do fechamento de caixa.',
        image: 'https://images.pexels.com/photos/3760263/pexels-photo-3760263.jpeg?auto=compress&cs=tinysrgb&w=900',
        class: 'md:mt-12', 
    },
    {
        title: 'Casais',
        subtitle: 'Planejamento conjunto',
        description: 'Consolidem gastos fixos e variáveis com um plano único de decisão.',
        image: 'https://images.pexels.com/photos/572056/pexels-photo-572056.jpeg?auto=compress&cs=tinysrgb&w=900',
        class: 'md:-mt-8',
    },
    {
        title: 'Profissionais CLT',
        subtitle: 'Ciclo mensal',
        description: 'Conecte salário, fatura e recorrências com previsibilidade diária.',
        image: 'https://images.pexels.com/photos/1184572/pexels-photo-1184572.jpeg?auto=compress&cs=tinysrgb&w=900',
        class: 'md:mt-24', 
    },
];

const flowTimeline = [
    {
        number: '1',
        title: 'Configurar base financeira',
        text: 'Cadastre contas, cartões e categorias em uma estrutura única, conectada com a sua realidade.',
    },
    {
        number: '2',
        title: 'Ativar a rotina de caixa',
        text: 'Mantenha entradas e saídas centralizadas. O atrito desaparece, a clareza se torna a regra.',
    },
    {
        number: '3',
        title: 'Leitura de risco futuro',
        text: 'O algoritmo projeta seus dias. Saiba exatamente quando e onde o seu saldo corre perigo.',
    },
    {
        number: '4',
        title: 'Ajuste cirúrgico semanal',
        text: 'Priorize os cortes ou mova fundos antes que a fatura comprometa a liquidez do mês.',
    },
];

const serviceBlocks = [
    {
        title: 'Leitura em Tempo Real',
        description: 'Visão oblíqua dos próximos dias. Ação em tempo hábil.',
    },
    {
        title: 'Análise de Risco',
        description: 'Identificação imediata de pontos de pressão e ruptura.',
    },
    {
        title: 'Sincronia Semanal',
        description: 'Passos guiados para restabelecer a estabilidade sem pânico.',
    },
];
</script>

<template>
    <Head title="Kitamo | O Design do Seu Mês">
        <meta name="description" content="Kitamo é a arquitetura financeira focada em antecipação de caixa e decisão." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <!-- Hero Section -->
        <MotionSection class="relative min-h-[90vh] w-full overflow-hidden bg-[#0a0f12] text-white flex flex-col justify-center pt-24 pb-16">
            <!-- Dramatic ambient glow background -->
            <div class="pointer-events-none absolute -top-[20%] -left-[10%] w-[60%] h-[60%] rounded-full bg-emerald-600/20 blur-[120px]"></div>
            <div class="pointer-events-none absolute bottom-[10%] -right-[10%] w-[50%] h-[50%] rounded-full bg-blue-600/10 blur-[120px]"></div>

            <div class="relative z-10 mx-auto w-full max-w-[1440px] px-6 md:px-12 grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
                <div class="lg:col-span-7">
                    <p class="text-[12px] font-bold uppercase tracking-[0.2em] text-emerald-400 mb-6 drop-shadow-sm">Engenharia de Caixa</p>
                    <h1 class="text-6xl sm:text-7xl lg:text-[5.5rem] leading-[0.9] tracking-tighter mix-blend-lighten">
                        O mês não<br />
                        <span class="block text-emerald-300 font-serif italic pr-4 mt-2">precisa te surpreender.</span>
                    </h1>
                    <p class="mt-8 max-w-lg text-lg sm:text-xl leading-relaxed text-slate-400 font-light">
                        Esqueça olhar pelo retrovisor. Kitamo é visão preditiva.<br/>O controle do fluxo futuro na ponta dos seus dedos.
                    </p>

                    <div class="mt-10 flex flex-wrap gap-4">
                        <Link :href="primaryHref" class="group relative inline-flex h-14 items-center justify-center overflow-hidden rounded-full bg-emerald-400 px-8 text-[12px] font-extrabold uppercase tracking-[0.14em] text-slate-950 transition-transform hover:scale-105 active:scale-95">
                            <span class="absolute inset-0 bg-white/20 translate-y-full transition-transform duration-300 group-hover:translate-y-0"></span>
                            <span class="relative">Acesso Imediato</span>
                        </Link>
                        <Link :href="route('site.product') + '#demo'" class="inline-flex h-14 items-center justify-center rounded-full border border-white/20 px-8 text-[12px] font-extrabold uppercase tracking-[0.14em] text-white backdrop-blur-sm transition-colors hover:bg-white hover:text-slate-950">
                            Explorar a Dinâmica
                        </Link>
                    </div>

                    <div class="mt-16 flex gap-12 font-mono text-sm tracking-widest text-slate-500 uppercase">
                        <div>
                            <strong class="block text-2xl text-emerald-400 font-sans tracking-tight mb-1">0_</strong>
                            <span class="text-[10px]">Surpresas</span>
                        </div>
                        <div>
                            <strong class="block text-2xl text-white font-sans tracking-tight mb-1">30+</strong>
                            <span class="text-[10px]">Dias de Visão</span>
                        </div>
                    </div>
                </div>

                <div class="lg:col-span-5 relative hidden lg:block">
                    <div class="absolute -inset-4 bg-emerald-500/20 rounded-[3rem] blur-2xl transform rotate-3"></div>
                    <div class="relative overflow-hidden rounded-[2.5rem] border border-white/10 bg-slate-900 shadow-2xl transition-transform duration-700 hover:rotate-2 hover:scale-[1.02]">
                        <img
                            src="https://images.pexels.com/photos/3184433/pexels-photo-3184433.jpeg?auto=compress&cs=tinysrgb&w=1200"
                            alt="Interface Abstrata"
                            class="h-[600px] w-full object-cover opacity-80 mix-blend-luminosity"
                        />
                        <div class="absolute inset-0 bg-gradient-to-t from-slate-950 via-slate-950/20 to-transparent"></div>
                        <div class="absolute bottom-6 left-6 right-6 rounded-2xl border border-white/10 bg-white/5 p-5 backdrop-blur-md">
                            <div class="flex items-center gap-3 mb-2">
                                <span class="flex h-2 w-2 rounded-full bg-rose-500 animate-pulse"></span>
                                <span class="text-xs font-bold uppercase tracking-widest text-rose-300">Ponto de Fricção</span>
                            </div>
                            <p class="text-sm text-slate-300 font-light leading-relaxed">Risco de colapso de liquidez em D+12. Recomendado: diluição de R$ 450.</p>
                        </div>
                    </div>
                </div>
            </div>
        </MotionSection>

        <!-- Perfis Section -->
        <MotionSection class="bg-slate-50 py-24 sm:py-32 relative overflow-hidden">
            <div class="mx-auto max-w-[1440px] px-6 md:px-12">
                <div class="flex flex-col md:flex-row md:items-end justify-between gap-8 mb-16">
                    <h2 class="text-5xl sm:text-6xl font-medium tracking-tighter text-slate-900 max-w-2xl leading-[1.05]">
                        Diferentes arquiteturas<br><span class="text-slate-400">mesma disciplina.</span>
                    </h2>
                    <p class="max-w-xs text-sm uppercase tracking-[0.15em] font-semibold text-slate-500 text-right">
                        Não importa a origem<br/>Importa o destino do recurso
                    </p>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
                    <div v-for="item in destinationCards" :key="item.title" :class="['group relative', item.class]">
                        <div class="absolute inset-0 bg-emerald-900/5 translate-y-4 translate-x-4 rounded-3xl transition-transform duration-500 group-hover:translate-x-6 group-hover:translate-y-6 -z-10"></div>
                        <article class="bg-white rounded-3xl overflow-hidden border border-slate-200/60 shadow-xl shadow-slate-200/50 transition-all duration-500 group-hover:-translate-y-2 h-full flex flex-col">
                            <div class="relative h-64 overflow-hidden">
                                <img :src="item.image" :alt="item.title" class="absolute inset-0 w-full h-full object-cover transition-transform duration-1000 group-hover:scale-110 filter saturate-50 group-hover:saturate-100" />
                                <div class="absolute inset-0 bg-gradient-to-t from-slate-900/90 to-transparent"></div>
                                <div class="absolute bottom-5 left-6 right-6 text-white">
                                    <p class="text-[10px] font-bold uppercase tracking-widest text-emerald-300 mb-2">{{ item.subtitle }}</p>
                                    <h3 class="text-3xl font-medium tracking-tight">{{ item.title }}</h3>
                                </div>
                            </div>
                            <div class="p-6 md:p-8 flex-grow flex flex-col justify-between bg-white text-slate-600">
                                <p class="text-base leading-relaxed">{{ item.description }}</p>
                            </div>
                        </article>
                    </div>
                </div>
            </div>
        </MotionSection>

        <!-- Timeline Section -->
        <MotionSection class="bg-slate-950 py-32 text-slate-300 relative">
            <!-- Decorative noisy overlay -->
            <div class="absolute inset-0 opacity-[0.03]" style="background-image: url('data:image/svg+xml,%3Csvg viewBox=%220 0 200 200%22 xmlns=%22http://www.w3.org/2000/svg%22%3E%3Cfilter id=%22noiseFilter%22%3E%3CfeTurbulence type=%22fractalNoise%22 baseFrequency=%220.65%22 numOctaves=%223%22 stitchTiles=%22stitch%22/%3E%3C/filter%3E%3Crect width=%22100%25%22 height=%22100%25%22 filter=%22url(%23noiseFilter)%22/%3E%3C/svg%3E');"></div>
            
            <div class="max-w-[1440px] mx-auto px-6 md:px-12 grid grid-cols-1 lg:grid-cols-2 gap-20 items-start">
                <div class="lg:sticky lg:top-32">
                    <p class="text-[11px] font-bold uppercase tracking-[0.2em] text-emerald-400">Modelo Operacional</p>
                    <h2 class="mt-4 text-5xl sm:text-6xl font-medium tracking-tighter text-white leading-[1.05]">
                        A coreografia<br><span class="italic font-serif text-slate-500">da precisão.</span>
                    </h2>
                    <p class="mt-8 text-xl font-light leading-relaxed text-slate-400 max-w-md">
                        Abandone a complexidade. A projeção perfeita exige um método rígido, não esforço excessivo. Veja como a rotina funciona no Kitamo.
                    </p>
                </div>

                <div class="relative">
                    <div class="absolute left-8 top-0 bottom-0 w-px bg-gradient-to-b from-emerald-500/0 via-emerald-500/50 to-emerald-500/0 hidden sm:block"></div>
                    
                    <div class="flex flex-col gap-16 relative">
                        <div v-for="(step, index) in flowTimeline" :key="step.number" class="group relative sm:pl-24">
                            <div class="absolute left-0 top-0 hidden sm:flex h-16 w-16 items-center justify-center rounded-2xl bg-slate-900 border border-slate-800 text-2xl font-serif italic text-emerald-400 shadow-2xl transition-transform duration-500 group-hover:scale-110 group-hover:rotate-6 group-hover:bg-emerald-950 group-hover:border-emerald-800">
                                {{ step.number }}
                            </div>
                            <h3 class="text-3xl font-medium tracking-tight text-white mb-4">{{ step.title }}</h3>
                            <p class="text-lg text-slate-400 font-light leading-relaxed group-hover:text-slate-300 transition-colors">{{ step.text }}</p>
                        </div>
                    </div>
                </div>
            </div>
        </MotionSection>

        <!-- Service Blocks Deep Comparison Section -->
        <MotionSection class="bg-slate-50 py-32 relative">
            <div class="max-w-[1440px] mx-auto px-6 md:px-12">
                <div class="text-center max-w-3xl mx-auto mb-20">
                    <h2 class="text-5xl sm:text-6xl font-medium tracking-tighter text-slate-900 mb-6">Mecânicas da<br/>Antecipação</h2>
                    <p class="text-xl text-slate-500 font-light">Se os dados são um fluxo contínuo, analisá-los retrospectivamente é abraçar o erro. O Kitamo muda o vetor temporal do seu dinheiro.</p>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-6 lg:gap-10">
                    <div v-for="(block, index) in serviceBlocks" :key="index" class="bg-white p-10 rounded-[2.5rem] border border-slate-200 hover:shadow-2xl hover:-translate-y-2 transition-all duration-500 relative overflow-hidden group">
                        <div class="absolute -right-10 -top-10 w-40 h-40 bg-emerald-100 rounded-full blur-3xl opacity-0 group-hover:opacity-100 transition-opacity duration-700"></div>
                        <span class="block text-[10px] font-bold tracking-[0.2em] text-slate-400 uppercase mb-4">{{ String(index + 1).padStart(2, '0') }}. Fundamento</span>
                        <h3 class="text-3xl font-medium tracking-tight text-slate-900 mb-4">{{ block.title }}</h3>
                        <p class="text-slate-600 leading-relaxed">{{ block.description }}</p>
                    </div>
                </div>
            </div>
        </MotionSection>

        <!-- Preços Section -->
        <MotionSection class="bg-slate-900 py-32 relative text-white rounded-t-[4rem] sm:rounded-t-[6rem] -mt-10 overflow-hidden z-20">
            <!-- Dramatic ambient glow background -->
            <div class="pointer-events-none absolute top-0 inset-x-0 h-px bg-gradient-to-r from-transparent via-emerald-500/50 to-transparent"></div>
            <div class="absolute inset-0 bg-[radial-gradient(ellipse_at_top,_var(--tw-gradient-stops))] from-emerald-900/10 via-slate-900 to-slate-950"></div>
            
            <div class="max-w-[1440px] mx-auto px-6 md:px-12 relative z-10">
                <div class="text-center max-w-2xl mx-auto mb-20">
                    <p class="text-[11px] font-bold uppercase tracking-[0.2em] text-emerald-400 mb-4">Acesso ao Motor</p>
                    <h2 class="text-5xl sm:text-6xl font-medium tracking-tighter mb-6">Controle seu<br/> ritmo financeiro.</h2>
                    <p class="text-xl text-slate-400 font-light">
                        Comece com o essencial gratuitamente. Escale o modelo preditivo conforme a complexidade da sua vida o exigir.
                    </p>
                </div>

                <div class="max-w-[1100px] mx-auto">
                    <PricingBlock :plans="pricingPlans" :can-register="canRegister" />
                </div>
            </div>
        </MotionSection>

        <!-- Footer Call to Action -->
        <MotionSection class="bg-emerald-500 py-24 sm:py-32 relative overflow-hidden">
            <div class="absolute inset-0 bg-[radial-gradient(circle_at_bottom_left,_var(--tw-gradient-stops))] from-emerald-300 to-emerald-600 mix-blend-multiply opacity-50"></div>
            <div class="max-w-[1440px] mx-auto px-6 md:px-12 text-center relative z-10">
                <h2 class="text-6xl sm:text-7xl lg:text-[7.5rem] font-medium tracking-tighter text-emerald-950 leading-[0.9]">
                    Projete amanhã.<br><span class="italic font-serif opacity-80">Hoje.</span>
                </h2>
                <div class="mt-12">
                    <Link
                        :href="primaryHref"
                        class="inline-flex h-16 items-center justify-center rounded-full bg-slate-950 px-10 text-[13px] font-extrabold uppercase tracking-[0.2em] text-white transition-transform hover:scale-105 hover:bg-slate-900 shadow-2xl"
                    >
                        Iniciar Arquitetura Financeira
                    </Link>
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
