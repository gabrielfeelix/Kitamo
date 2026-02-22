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
        title: 'Para a Galera CLT',
        subtitle: 'Boleto no dia certo',
        description: 'Faça seu salário render conectando seus gastos com seu ciclo mensal. Zero sustos no dia 5.',
        image: 'https://images.pexels.com/photos/1184572/pexels-photo-1184572.jpeg?auto=compress&cs=tinysrgb&w=900',
        class: 'md:mt-12', 
    },
    {
        title: 'Para Casais',
        subtitle: 'Paz em dose dupla',
        description: 'Juntem as rendas e dividam as contas em um mapa único. Menos treta, mais viagens juntos.',
        image: 'https://images.pexels.com/photos/572056/pexels-photo-572056.jpeg?auto=compress&cs=tinysrgb&w=900',
        class: 'md:-mt-8',
    },
    {
        title: 'Autônomos e Freelas',
        subtitle: 'Domando o imprevisível',
        description: 'Antecipe os meses de vacas magras e prepare o caixa para quando a grana tá alta.',
        image: 'https://images.pexels.com/photos/3760263/pexels-photo-3760263.jpeg?auto=compress&cs=tinysrgb&w=900',
        class: 'md:mt-24', 
    },
];

const flowTimeline = [
    {
        number: '1',
        title: 'Bota a casa em ordem',
        text: 'Cadastre suas contas, cartões e o que você gasta no mês. Não se preocupa, o processo é super fácil.',
    },
    {
        number: '2',
        title: 'Liga o piloto não-tão-automático',
        text: 'Mantenha a rotina e jogue as entradas e saídas no Kitamo. É rapidinho e a clareza entra na sua vida.',
    },
    {
        number: '3',
        title: 'Veja o futuro da conta',
        text: 'O algoritmo lê sua rotina e te fala bem antes se o salário não vai chegar no fim do mês.',
    },
    {
        number: '4',
        title: 'Ajuste a rota no sapatinho',
        text: 'Mova um dinheiro ali, corte um ifood de fim de semana ali, pronto, o mês voltou pros eixos.',
    },
];

const serviceBlocks = [
    {
        title: 'Futuro na Tela',
        description: 'Veja como vai estar seu saldo daqui a 30 dias. Chega de viver só olhando pro que já aconteceu.',
    },
    {
        title: 'Radar contra Perrengue',
        description: 'Identifica gastos que vão te estourar e avisa na hora. É aquele amigo que te salva do cheque especial.',
    },
    {
        title: 'Revisão Modo Turbo',
        description: 'Tire 10 minutinhos no fim de semana e organize a vida sem drama e sem planilhas feias.',
    },
];
</script>

<template>
    <Head title="Kitamo | O Design do Seu Mês">
        <meta name="description" content="Kitamo é a sua paz financeira. Organização focada em antecipação de caixa e decisão rápida." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <!-- Hero Section -->
        <MotionSection class="relative min-h-screen w-full overflow-hidden bg-slate-950 text-white flex flex-col justify-center pt-24 pb-16 border-b border-white/5">
            <!-- Dramatic ambient glow background, premium look -->
            <div class="pointer-events-none absolute -top-[30%] -left-[10%] w-[70%] h-[70%] rounded-full bg-teal-600/30 blur-[140px] mix-blend-screen opacity-60"></div>
            <div class="pointer-events-none absolute bottom-[10%] -right-[10%] w-[60%] h-[60%] rounded-full bg-blue-600/20 blur-[130px] mix-blend-screen opacity-50"></div>
            <!-- Subtly Noise Overlay for texture -->
            <div class="absolute inset-0 opacity-[0.02] mix-blend-overlay pointer-events-none" style="background-image: url('data:image/svg+xml,%3Csvg viewBox=%220 0 200 200%22 xmlns=%22http://www.w3.org/2000/svg%22%3E%3Cfilter id=%22noiseFilter%22%3E%3CfeTurbulence type=%22fractalNoise%22 baseFrequency=%220.8%22 numOctaves=%224%22 stitchTiles=%22stitch%22/%3E%3C/filter%3E%3Crect width=%22100%25%22 height=%22100%25%22 filter=%22url(%23noiseFilter)%22/%3E%3C/svg%3E');"></div>

            <div class="relative z-10 mx-auto w-full max-w-[1440px] px-6 md:px-12 grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
                <div class="lg:col-span-7">
                    <p class="inline-flex items-center space-x-2 text-[11px] font-bold uppercase tracking-[0.2em] text-teal-400 mb-6 drop-shadow-sm bg-teal-400/10 px-4 py-2 rounded-full border border-teal-400/20">
                        <span class="w-1.5 h-1.5 bg-teal-400 rounded-full animate-pulse"></span>
                        <span>Seu dinheiro no modo fácil</span>
                    </p>
                    <h1 class="text-[4rem] sm:text-[5rem] lg:text-[6.5rem] leading-[0.9] tracking-tighter mix-blend-lighten text-slate-100 font-extrabold">
                        O seu mês,<br />
                        <span class="block text-transparent bg-clip-text bg-gradient-to-r from-teal-300 to-green-400 font-serif italic pr-4 mt-2">nas suas regras.</span>
                    </h1>
                    <p class="mt-8 max-w-lg text-lg sm:text-xl leading-relaxed text-slate-400 font-medium">
                        Chega de fechar o mês no susto. Com o Kitamo, você vê o futuro da sua conta e toma as rédeas da parada na palma da mão.
                    </p>

                    <div class="mt-10 flex flex-wrap gap-4 items-center">
                        <Link :href="primaryHref" class="group relative inline-flex h-14 items-center justify-center overflow-hidden rounded-full bg-teal-500 px-8 text-[13px] font-extrabold uppercase tracking-[0.14em] text-slate-950 transition-all hover:scale-105 active:scale-95 shadow-[0_0_40px_-5px_theme(colors.teal.500)]">
                            <span class="absolute inset-0 bg-white/30 translate-y-full transition-transform duration-300 group-hover:translate-y-0"></span>
                            <span class="relative">Acesso Imediato</span>
                        </Link>
                        <Link :href="route('site.product') + '#demo'" class="inline-flex h-14 items-center justify-center rounded-full border border-slate-700 px-8 text-[13px] font-bold uppercase tracking-[0.14em] text-slate-300 backdrop-blur-sm transition-all hover:bg-slate-800 hover:border-slate-500 hover:text-white">
                            Ver como a magia acontece
                        </Link>
                    </div>

                    <div class="mt-12 flex items-center gap-10 border-t border-slate-800 pt-8 max-w-md">
                        <div class="flex flex-col gap-1">
                            <strong class="text-3xl text-teal-400 font-sans tracking-tight leading-none">Zero</strong>
                            <span class="text-[10px] uppercase tracking-widest text-slate-500 font-bold">Surpresas no fim de mês</span>
                        </div>
                        <div class="w-px h-10 bg-slate-800"></div>
                        <div class="flex flex-col gap-1">
                            <strong class="text-3xl text-white font-sans tracking-tight leading-none">30+</strong>
                            <span class="text-[10px] uppercase tracking-widest text-slate-500 font-bold">Dias de Visão de Futuro</span>
                        </div>
                    </div>
                </div>

                <div class="lg:col-span-5 relative hidden lg:flex justify-end perspective-1000">
                    <div class="absolute -inset-4 bg-teal-500/20 rounded-[3rem] blur-2xl transform rotate-3"></div>
                    <div class="relative overflow-hidden rounded-[2.5rem] border border-white/10 bg-slate-900 shadow-2xl transition-all duration-700 hover:rotate-2 hover:scale-[1.03] group w-full max-w-md translate-y-8">
                        <img
                            src="https://images.pexels.com/photos/3184433/pexels-photo-3184433.jpeg?auto=compress&cs=tinysrgb&w=1200"
                            alt="Interface Abstrata"
                            class="h-[500px] w-full object-cover opacity-60 mix-blend-luminosity transition-opacity duration-500 group-hover:opacity-80"
                        />
                        <div class="absolute inset-0 bg-gradient-to-t from-slate-950 via-slate-950/40 to-transparent"></div>
                        
                        <!-- Premium floating UI Card -->
                        <div class="absolute bottom-6 left-6 right-6 rounded-2xl border border-white/10 bg-white/5 p-5 backdrop-blur-xl shadow-2xl translate-y-2 group-hover:translate-y-0 transition-transform duration-500">
                            <div class="flex items-center gap-3 mb-3 pb-3 border-b border-white/10">
                                <span class="flex h-2.5 w-2.5 rounded-full bg-red-400 shadow-[0_0_10px_theme(colors.red.400)] animate-pulse"></span>
                                <span class="text-[10px] font-bold uppercase tracking-widest text-red-300">Alerta de Perrengue</span>
                            </div>
                            <p class="text-sm text-slate-200 font-medium leading-relaxed">Faltam R$ 450 pro boleto da internet da semana que vem. <span class="text-teal-300 font-bold cursor-pointer hover:underline">Resolver com 1 clique?</span></p>
                        </div>
                    </div>
                </div>
            </div>
        </MotionSection>

        <!-- Perfis Section -->
        <MotionSection class="bg-gray-100 py-24 sm:py-32 relative overflow-hidden">
            <div class="mx-auto max-w-[1440px] px-6 md:px-12">
                <div class="flex flex-col md:flex-row md:items-end justify-between gap-8 mb-16">
                    <h2 class="text-5xl sm:text-6xl font-extrabold tracking-tighter text-slate-800 max-w-2xl leading-[1.05]">
                        Feito pra você,<br><span class="text-slate-500">não importa a fase.</span>
                    </h2>
                    <p class="max-w-xs text-xs uppercase tracking-[0.15em] font-bold text-slate-400 text-right">
                        Dinheiro é sua ferramenta<br/>Use a seu favor
                    </p>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
                    <div v-for="item in destinationCards" :key="item.title" :class="['group relative', item.class]">
                        <div class="absolute inset-0 bg-teal-900/5 translate-y-4 translate-x-4 rounded-[2rem] transition-transform duration-500 group-hover:translate-x-6 group-hover:translate-y-6 -z-10"></div>
                        <article class="bg-white rounded-[2rem] overflow-hidden border border-slate-200 shadow-lg hover:shadow-2xl transition-all duration-500 group-hover:-translate-y-2 h-full flex flex-col">
                            <div class="relative h-64 overflow-hidden">
                                <img :src="item.image" :alt="item.title" class="absolute inset-0 w-full h-full object-cover transition-transform duration-1000 group-hover:scale-110 filter saturate-50 group-hover:saturate-100" />
                                <div class="absolute inset-0 bg-gradient-to-t from-slate-900/90 via-slate-900/30 to-transparent"></div>
                                <div class="absolute bottom-6 left-6 right-6 text-white transform translate-y-2 group-hover:translate-y-0 transition-transform duration-500">
                                    <p class="text-[10px] font-bold uppercase tracking-widest text-teal-300 mb-2 drop-shadow-md">{{ item.subtitle }}</p>
                                    <h3 class="text-3xl font-bold tracking-tight">{{ item.title }}</h3>
                                </div>
                            </div>
                            <div class="p-8 flex-grow flex flex-col justify-between bg-white text-slate-600 rounded-b-[2rem]">
                                <p class="text-base font-medium leading-relaxed">{{ item.description }}</p>
                            </div>
                        </article>
                    </div>
                </div>
            </div>
        </MotionSection>

        <!-- Timeline Section -->
        <MotionSection class="bg-white py-32 text-slate-800 relative z-10 border-t border-slate-200">
            <div class="max-w-[1440px] mx-auto px-6 md:px-12 grid grid-cols-1 lg:grid-cols-5 gap-16 lg:gap-24 items-start">
                <div class="lg:sticky lg:top-32 lg:col-span-2">
                    <p class="inline-flex items-center space-x-2 text-[10px] font-bold uppercase tracking-[0.2em] text-teal-600 mb-4 bg-teal-50 px-3 py-1.5 rounded-md border border-teal-100">Como funciona</p>
                    <h2 class="mt-2 text-4xl sm:text-5xl lg:text-6xl font-extrabold tracking-tighter text-slate-900 leading-[1.05]">
                        Sem milagres,<br><span class="text-teal-500">só o básico bem feito.</span>
                    </h2>
                    <p class="mt-6 text-lg font-medium leading-relaxed text-slate-500 max-w-sm">
                        Não enchemos a sua tela com gráficos que você não entende. A nossa parada é te dar clareza no dia a dia, de jeito fácil.
                    </p>
                </div>

                <div class="relative lg:col-span-3">
                    <div class="absolute left-6 top-8 bottom-8 w-1 bg-gradient-to-b from-teal-500/0 via-teal-500 to-teal-500/0 hidden sm:block rounded-full"></div>
                    
                    <div class="flex flex-col gap-12 relative">
                        <div v-for="(step, index) in flowTimeline" :key="step.number" class="group relative sm:pl-20">
                            <!-- Premium Number Bubble -->
                            <div class="absolute left-0 top-0 hidden sm:flex h-12 w-12 items-center justify-center rounded-xl bg-white border-2 border-slate-100 text-xl font-bold text-teal-500 shadow-md transition-all duration-300 group-hover:scale-110 group-hover:border-teal-500 group-hover:text-teal-600 group-hover:shadow-teal-500/20">
                                {{ step.number }}
                            </div>
                            <div class="bg-slate-50 border border-slate-100 p-8 rounded-3xl transition-all duration-300 hover:shadow-xl hover:bg-white hover:border-teal-100">
                                <h3 class="text-2xl font-bold tracking-tight text-slate-900 mb-3">{{ step.title }}</h3>
                                <p class="text-base text-slate-600 font-medium leading-relaxed">{{ step.text }}</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </MotionSection>

        <!-- Service Blocks Deep Comparison Section -->
        <MotionSection class="bg-slate-950 py-32 relative border-t border-slate-800 text-slate-200">
             <div class="absolute inset-0 opacity-[0.03] mix-blend-overlay pointer-events-none" style="background-image: url('data:image/svg+xml,%3Csvg viewBox=%220 0 200 200%22 xmlns=%22http://www.w3.org/2000/svg%22%3E%3Cfilter id=%22noiseFilter%22%3E%3CfeTurbulence type=%22fractalNoise%22 baseFrequency=%220.8%22 numOctaves=%224%22 stitchTiles=%22stitch%22/%3E%3C/filter%3E%3Crect width=%22100%25%22 height=%22100%25%22 filter=%22url(%23noiseFilter)%22/%3E%3C/svg%3E');"></div>
             
            <div class="max-w-[1440px] mx-auto px-6 md:px-12 relative z-10">
                <div class="text-center max-w-3xl mx-auto mb-20">
                    <h2 class="text-4xl sm:text-5xl lg:text-6xl font-extrabold tracking-tighter text-white mb-6">Porque funciona</h2>
                    <p class="text-xl text-slate-400 font-medium">Você tá cansado de olhar pro app do banco e não saber pra onde seu dinheiro tá indo. A gente também tava, então a gente mudou a lógica.</p>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-6 lg:gap-8">
                    <div v-for="(block, index) in serviceBlocks" :key="index" class="bg-slate-900 p-10 rounded-[2rem] border border-slate-800 hover:border-teal-500/50 hover:bg-slate-800/80 transition-all duration-300 relative overflow-hidden group shadow-2xl">
                        <div class="absolute -right-10 -top-10 w-40 h-40 bg-teal-500/10 rounded-full blur-3xl opacity-0 group-hover:opacity-100 transition-opacity duration-700"></div>
                        <span class="inline-flex w-10 h-10 items-center justify-center rounded-lg bg-slate-800 text-teal-400 font-bold mb-6 font-mono text-sm group-hover:bg-teal-500/20 group-hover:text-teal-300 transition-colors">0{{ index + 1 }}</span>
                        <h3 class="text-2xl font-bold tracking-tight text-white mb-4">{{ block.title }}</h3>
                        <p class="text-slate-400 leading-relaxed font-medium">{{ block.description }}</p>
                    </div>
                </div>
            </div>
        </MotionSection>

        <!-- Preços Section -->
        <MotionSection class="bg-gray-100 py-32 relative text-slate-900 rounded-b-[4rem] z-20 overflow-hidden shadow-2xl">
            <div class="max-w-[1440px] mx-auto px-6 md:px-12 relative z-10">
                <div class="text-center max-w-2xl mx-auto mb-16">
                    <p class="text-[12px] font-bold uppercase tracking-[0.2em] text-teal-600 mb-4 bg-teal-100/50 inline-block px-4 py-2 rounded-full border border-teal-200">Quanto vai custar?</p>
                    <h2 class="text-5xl sm:text-6xl font-extrabold tracking-tighter text-slate-900 mb-6">Pague o justo.</h2>
                    <p class="text-lg text-slate-600 font-medium">
                        Tem o plano 0800 pra você organizar a bagunça, e se quiser voar mais alto, os planos pagos ajudam a gente a pagar nossos boletos também.
                    </p>
                </div>

                <div class="max-w-[1100px] mx-auto ring-1 ring-slate-200 rounded-[2.5rem] bg-white p-2">
                    <PricingBlock :plans="pricingPlans" :can-register="canRegister" />
                </div>
            </div>
        </MotionSection>

        <!-- Footer Call to Action -->
        <MotionSection class="bg-teal-500 py-32 relative overflow-hidden flex flex-col items-center justify-center">
            <div class="absolute inset-0 bg-[radial-gradient(circle_at_bottom_left,_var(--tw-gradient-stops))] from-teal-300 to-teal-700 mix-blend-multiply opacity-50"></div>
            <!-- Decorative circle -->
            <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] bg-white/5 rounded-full blur-3xl pointer-events-none"></div>

            <div class="max-w-[1000px] mx-auto px-6 md:px-12 text-center relative z-10">
                <h2 class="text-6xl sm:text-7xl lg:text-[7.5rem] font-extrabold tracking-tighter text-teal-950 leading-[0.9]">
                    Toma o controle.<br><span class="italic font-serif opacity-90 text-teal-900">Agora.</span>
                </h2>
                <p class="mt-8 text-xl font-medium text-teal-950/80 max-w-lg mx-auto">Não deixa pro mês que vem o que você pode ajeitar hoje em 10 minutinhos.</p>
                <div class="mt-12">
                    <Link
                        :href="primaryHref"
                        class="inline-flex h-16 items-center justify-center rounded-full bg-slate-950 px-10 text-[14px] font-extrabold uppercase tracking-[0.16em] text-white transition-all hover:scale-105 hover:bg-slate-900 shadow-[0_20px_40px_-10px_rgba(0,0,0,0.5)] focus:ring-4 focus:ring-slate-900/30"
                    >
                        Criar minha conta Grátis
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
