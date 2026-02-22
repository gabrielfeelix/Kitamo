<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';

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
    },
    {
        id: 'cartoes',
        title: 'Domador de faturas',
        description: 'O cartão de crédito não é seu inimigo se você sabe quanto a fatura vai dar antes dela fechar. A gente te mostra isso.',
        bullets: ['Limite sempre sob controle', 'Parcelas na linha do tempo', 'Sem sustos no vencimento'],
        image: 'https://images.pexels.com/photos/3183197/pexels-photo-3183197.jpeg?auto=compress&cs=tinysrgb&w=1000',
    },
    {
        id: 'metas',
        title: 'A grana do futuro',
        description: 'Seja a viagem pro Nordeste ou o conserto do carro, guarde com objetivo e veja a barrinha encher.',
        bullets: ['Prazo + Valor = Foco', 'Guarde aos poucos', 'Progresso visual'],
        image: 'https://images.pexels.com/photos/3760067/pexels-photo-3760067.jpeg?auto=compress&cs=tinysrgb&w=1000',
    },
    {
        id: 'projecao',
        title: 'Visão Raio-X do Mês',
        description: 'Nosso algoritmo cruza o que você ganha com o que gasta e prevê os riscos do mês antes de acontecer.',
        bullets: ['30 dias ou mais pra frente', 'Bandeira vermelha na hora', 'Ação antes do perrengue'],
        image: 'https://images.pexels.com/photos/3182812/pexels-photo-3182812.jpeg?auto=compress&cs=tinysrgb&w=1000',
    },
];

const journey = [
    {
        number: '1',
        title: 'Bota os pingos nos is',
        description: 'Puxa o extrato uma vez, anota as contas fixas e pronto. A fundação tá feita.',
    },
    {
        number: '2',
        title: 'Alimenta o monstrinho',
        description: 'Tirou do bolso? Coloca no Kitamo. É rápido e prático.',
    },
    {
        number: '3',
        title: 'Recebe a real',
        description: 'O Kitamo avisa se faltar grana pro boleto da semana que vem.',
    },
    {
        number: '4',
        title: 'O mês nas suas regras',
        description: 'Você move as peças, enxuga um gasto hoje, e a paz volta.',
    },
];

const personas = [
    'Pra quem a grana pinga em dias diferentes (Freelas)',
    'Pra quem divide casa e boleto (Casais em paz)',
    'Pra quem ganha bem mas gasta mal (Chega de empatar)',
    'Pra quem tá cansado de ser refém de planilha feia',
];
</script>

<template>
    <Head title="Produto | Kitamo">
        <meta name="description" content="Por dentro do Kitamo: veja como a gente faz você parar de sofrer com o fim do mês." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <!-- Hero Section -->
        <MotionSection class="relative min-h-[90vh] w-full overflow-hidden bg-slate-950 text-white flex flex-col justify-center pt-32 pb-20 border-b border-white/5">
            <div class="absolute inset-0 opacity-[0.02] mix-blend-overlay pointer-events-none" style="background-image: url('data:image/svg+xml,%3Csvg viewBox=%220 0 200 200%22 xmlns=%22http://www.w3.org/2000/svg%22%3E%3Cfilter id=%22noiseFilter%22%3E%3CfeTurbulence type=%22fractalNoise%22 baseFrequency=%220.8%22 numOctaves=%224%22 stitchTiles=%22stitch%22/%3E%3C/filter%3E%3Crect width=%22100%25%22 height=%22100%25%22 filter=%22url(%23noiseFilter)%22/%3E%3C/svg%3E');"></div>
            <!-- Dramatic lights -->
            <div class="pointer-events-none absolute top-10 right-10 w-[500px] h-[500px] bg-teal-600/20 blur-[130px] rounded-full mix-blend-screen opacity-50"></div>
            
            <div class="relative z-10 mx-auto w-full max-w-[1440px] px-6 md:px-12 grid gap-16 lg:grid-cols-2 lg:items-center">
                <div>
                    <p class="inline-flex items-center space-x-2 text-[11px] font-bold uppercase tracking-[0.2em] text-teal-400 mb-6 drop-shadow-sm bg-teal-400/10 px-4 py-2 rounded-full border border-teal-400/20">O App por dentro</p>
                    <h1 class="text-5xl sm:text-6xl lg:text-[5.5rem] leading-[0.95] tracking-tighter mix-blend-lighten text-slate-100 font-extrabold max-w-3xl">
                        Design focado no<br>
                        <span class="text-transparent bg-clip-text bg-gradient-to-r from-teal-300 to-green-400 font-serif italic pr-2">que importa.</span>
                    </h1>
                    <p class="mt-8 text-xl leading-relaxed text-slate-400 font-medium max-w-xl">
                        A gente tirou tudo que parecia com o app do banco e deixou só o que você precisa pra mandar no seu dinheiro. Sem complicação.
                    </p>
                    <div class="mt-10">
                         <Link :href="canRegister ? '/register' : '/login'" class="inline-flex h-16 items-center justify-center overflow-hidden rounded-full bg-teal-500 px-10 text-[13px] font-extrabold uppercase tracking-[0.14em] text-slate-950 transition-all hover:scale-105 active:scale-95 shadow-[0_0_40px_-10px_theme(colors.teal.500)]">
                            Criar minha conta
                        </Link>
                    </div>
                </div>

                <div class="relative w-full max-w-xl mx-auto lg:mx-0">
                    <div class="absolute -inset-4 bg-teal-500/20 rounded-[3rem] blur-2xl transform rotate-3"></div>
                    <div class="relative overflow-hidden rounded-[2rem] border border-white/10 bg-slate-900 shadow-2xl transition-all duration-700 hover:rotate-2 group w-full">
                        <img
                            src="https://images.pexels.com/photos/834863/pexels-photo-834863.jpeg?auto=compress&cs=tinysrgb&w=1200"
                            alt="Visão geral do produto"
                            class="h-[460px] w-full object-cover opacity-70 mix-blend-luminosity transition-opacity duration-500 group-hover:opacity-90 grayscale group-hover:grayscale-0"
                            loading="lazy"
                        />
                        <div class="absolute inset-0 bg-gradient-to-t from-slate-950 via-slate-950/20 to-transparent"></div>
                        <div class="absolute bottom-6 left-6 right-6 flex flex-wrap gap-2">
                            <span class="inline-flex rounded-full border border-white/20 bg-black/40 backdrop-blur-md px-4 py-2 text-[10px] font-bold uppercase tracking-[0.14em] text-white">Saldo Predizer</span>
                            <span class="inline-flex rounded-full border border-teal-500/30 bg-teal-500/10 backdrop-blur-md px-4 py-2 text-[10px] font-bold uppercase tracking-[0.14em] text-teal-300">Inteligente</span>
                        </div>
                    </div>
                </div>
            </div>
        </MotionSection>

        <!-- Modulos Section -->
        <MotionSection class="bg-gray-50 py-24 md:py-32 relative">
            <div class="mx-auto w-full max-w-[1440px] px-6 md:px-12 grid gap-16 lg:grid-cols-12 items-start">
                <div class="lg:col-span-4 lg:sticky lg:top-32 h-fit">
                    <h2 class="text-4xl sm:text-5xl font-extrabold tracking-tighter text-slate-900 leading-[1.05]">
                        Suas finanças,<br><span class="text-slate-500">traduzidas.</span>
                    </h2>
                    <p class="mt-6 text-lg text-slate-500 font-medium leading-relaxed max-w-sm">
                        O Kitamo divide o controle do dinheiro em pilares óbvios. Sem gráficos confusos. Só o que você precisa ver.
                    </p>
                </div>

                <div class="lg:col-span-8 flex flex-col gap-10 lg:gap-14">
                    <article
                        v-for="(module, index) in modules"
                        :id="module.id"
                        :key="module.id"
                        class="group relative overflow-hidden rounded-[2.5rem] bg-white border border-slate-200 shadow-sm hover:shadow-xl transition-all duration-500 hover:-translate-y-1"
                    >
                        <div class="flex flex-col md:flex-row h-full">
                            <div class="md:w-1/2 p-8 md:p-12 flex flex-col justify-center order-2 md:order-1">
                                <p class="text-[10px] font-bold uppercase tracking-[0.2em] text-teal-600 mb-4 bg-teal-50 inline-block px-3 py-1.5 rounded-lg w-fit border border-teal-100">0{{ index + 1 }}</p>
                                <h3 class="text-3xl font-extrabold tracking-tight text-slate-900 mb-4">{{ module.title }}</h3>
                                <p class="text-base text-slate-600 leading-relaxed font-medium mb-8">{{ module.description }}</p>
                                
                                <ul class="space-y-4">
                                    <li v-for="bullet in module.bullets" :key="bullet" class="flex items-center gap-3 text-sm font-bold text-slate-700">
                                        <svg class="h-5 w-5 text-teal-500 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                                            <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/>
                                        </svg>
                                        {{ bullet }}
                                    </li>
                                </ul>
                            </div>
                            <div class="md:w-1/2 relative h-64 md:h-auto overflow-hidden order-1 md:order-2">
                                <img
                                    :src="module.image"
                                    :alt="module.title"
                                    class="absolute inset-0 w-full h-full object-cover transition-transform duration-700 group-hover:scale-110 filter saturate-50 group-hover:saturate-100"
                                    loading="lazy"
                                />
                                <div class="absolute inset-0 bg-gradient-to-r from-white via-white/50 to-transparent md:block hidden"></div>
                            </div>
                        </div>
                    </article>
                </div>
            </div>
        </MotionSection>

        <!-- Jornada Section -->
        <MotionSection class="bg-slate-900 py-32 text-white relative border-t border-slate-800 z-10 overflow-hidden">
             <!-- Ambient texture -->
             <div class="absolute inset-0 opacity-[0.03] mix-blend-overlay pointer-events-none" style="background-image: url('data:image/svg+xml,%3Csvg viewBox=%220 0 200 200%22 xmlns=%22http://www.w3.org/2000/svg%22%3E%3Cfilter id=%22noiseFilter%22%3E%3CfeTurbulence type=%22fractalNoise%22 baseFrequency=%220.8%22 numOctaves=%224%22 stitchTiles=%22stitch%22/%3E%3C/filter%3E%3Crect width=%22100%25%22 height=%22100%25%22 filter=%22url(%23noiseFilter)%22/%3E%3C/svg%3E');"></div>
             
            <div class="mx-auto w-full max-w-[1440px] px-6 md:px-12 grid gap-16 lg:grid-cols-2 items-center relative z-10">
                <div>
                    <p class="inline-flex items-center space-x-2 text-[10px] font-bold uppercase tracking-[0.2em] text-teal-400 mb-4 bg-slate-800 px-3 py-1.5 rounded-lg border border-slate-700">O Ciclo do Kitamo</p>
                    <h2 class="text-4xl sm:text-5xl font-extrabold tracking-tighter text-white leading-[1.05]">
                        Uma rotina que se<br><span class="text-teal-500">paga em 10 minutos.</span>
                    </h2>
                    
                    <div class="mt-14 flex flex-col gap-10 relative">
                        <div class="absolute left-6 top-8 bottom-8 w-1 bg-gradient-to-b from-teal-500 via-emerald-400 to-transparent hidden sm:block rounded-full"></div>
                        
                        <div v-for="step in journey" :key="step.number" class="group relative sm:pl-20">
                            <div class="absolute left-0 top-0 hidden sm:flex h-12 w-12 items-center justify-center rounded-2xl bg-slate-950 border border-slate-700 text-lg font-bold text-teal-400 shadow-xl transition-all duration-300 group-hover:scale-110 group-hover:border-teal-400 group-hover:bg-slate-800">
                                {{ step.number }}
                            </div>
                            <h3 class="text-2xl font-bold tracking-tight text-white mb-2 group-hover:text-teal-300 transition-colors">{{ step.title }}</h3>
                            <p class="text-base text-slate-400 font-medium leading-relaxed max-w-sm">{{ step.description }}</p>
                        </div>
                    </div>
                </div>

                <div class="relative w-full max-w-xl mx-auto">
                    <div class="absolute -inset-4 bg-teal-500/10 rounded-[2.5rem] blur-2xl"></div>
                    <img
                        src="https://images.pexels.com/photos/1181519/pexels-photo-1181519.jpeg?auto=compress&cs=tinysrgb&w=1200"
                        alt="Uso no dia a dia"
                        class="relative h-[500px] w-full rounded-[2.5rem] object-cover border border-white/5 opacity-80 mix-blend-luminosity hover:mix-blend-normal transition-all duration-700"
                        loading="lazy"
                    />
                </div>
            </div>
        </MotionSection>

        <!-- Personas / CTA Final -->
        <MotionSection class="relative overflow-hidden bg-teal-500 py-32 text-slate-950 z-20">
            <div class="absolute inset-0 bg-[radial-gradient(ellipse_at_top_right,_var(--tw-gradient-stops))] from-teal-300 to-teal-700 mix-blend-multiply opacity-50"></div>
            
            <div class="mx-auto w-full max-w-[1440px] px-6 md:px-12 relative z-10 grid md:grid-cols-2 gap-16 items-center">
                <div>
                    <h2 class="text-4xl sm:text-5xl lg:text-[4rem] font-extrabold tracking-tighter max-w-lg leading-[1.05] text-teal-950">
                        O Kitamo parece ser <br/>pra você?
                    </h2>
                    <ul class="mt-12 grid gap-4">
                        <li
                            v-for="item in personas"
                            :key="item"
                            class="flex items-center gap-4 text-sm sm:text-base font-bold bg-white/20 px-6 py-4 rounded-2xl backdrop-blur-md border border-white/30 text-teal-950 shadow-sm"
                        >
                            <svg class="h-6 w-6 flex-shrink-0 opacity-70" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/></svg>
                            {{ item }}
                        </li>
                    </ul>
                </div>

                <div class="flex flex-col md:items-end justify-center perspective-1000">
                    <div class="bg-slate-950 p-10 lg:p-12 rounded-[2.5rem] w-full max-w-md shadow-2xl relative overflow-hidden border border-slate-800 transition-transform hover:scale-[1.02] duration-500">
                        <div class="absolute top-0 inset-x-0 h-1 bg-gradient-to-r from-teal-400 to-green-500"></div>
                        <h3 class="text-3xl lg:text-4xl font-extrabold text-white mb-4 tracking-tight">Vem pro lado da clareza.</h3>
                        <p class="text-slate-400 font-medium mb-10 text-lg">Pega a rédea do seu mês agora. Rápido, fácil, online.</p>
                        
                        <div class="flex flex-col gap-4">
                            <Link
                                :href="canRegister ? '/register' : '/login'"
                                class="inline-flex h-16 items-center justify-center rounded-2xl bg-teal-500 px-6 text-[14px] font-extrabold uppercase tracking-[0.16em] text-slate-950 transition-all hover:bg-teal-400 hover:scale-105 active:scale-95 w-full text-center shadow-[0_0_20px_theme(colors.teal.500/50)]"
                            >
                                Começar Grátis
                            </Link>
                            <Link
                                :href="route('site.contact')"
                                class="inline-flex h-14 items-center justify-center rounded-2xl border border-white/20 px-6 text-[12px] font-bold uppercase tracking-[0.14em] text-slate-300 transition-colors hover:bg-white/10 hover:text-white w-full text-center"
                            >
                                Falar com Suporte
                            </Link>
                        </div>
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
