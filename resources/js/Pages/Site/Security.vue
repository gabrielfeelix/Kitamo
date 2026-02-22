<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';
import MotionSection from '@/Components/site/MotionSection.vue';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const controls = [
    {
        title: 'Criptografia em trânsito e em repouso',
        description: 'Todo tráfego entre você e a gente rola em TLS 1.3. O que fica armazenado tá blindado com AES-256. Simples e direto.',
    },
    {
        title: 'Isolamento por conta',
        description: 'Seus dados não se misturam com os de ninguém. Cada pessoa tem sua própria base lógica separada, do jeito que tem que ser.',
    },
    {
        title: 'Sem Open Finance enxerido',
        description: 'O Kitamo não conecta no seu banco sem você saber. O controle é seu, manual e intencional. Ninguém escaneia suas compras pra te vender coisas.',
    },
    {
        title: 'Infra que não te deixa na mão',
        description: 'A gente tem monitoramento pesado, redundância e backups automáticos. Se der pau de um lado, do outro o barco tá rodando 100%.',
    },
];

const securityFlow = [
    {
        step: '01',
        title: 'Prevenir',
        text: 'Nossa estrutura é programada pra barrar a porta de entrada. Só entra quem tem que entrar.',
    },
    {
        step: '02',
        title: 'Detectar',
        text: 'Monitoramento silencioso. Se der zebra, a gente sabe antes de o bicho pegar.',
    },
    {
        step: '03',
        title: 'Responder',
        text: 'Se o alerta tocar, nosso time entra atirando no problema. Sem espera.',
    },
    {
        step: '04',
        title: 'Evoluir',
        text: 'Aprendeu, atualizou. A segurança tá sempre um passo à frente da ameaça.',
    },
];

const lgpd = [
    'Clicou em excluir? A gente pulveriza tudo. Sem letras miúdas.',
    'Você pode checar, alterar e levar seus dados pra onde quiser na hora que quiser.',
    'Nós NUNCA vamos vender seus dados. Seu dinheiro, sua privacidade.',
];
</script>

<template>
    <Head title="Segurança | Kitamo">
        <meta name="description" content="Segurança pesada, dados isolados e controle 100% seu." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <!-- Hero Section -->
        <MotionSection class="relative min-h-[60vh] w-full overflow-hidden bg-slate-950 text-white flex flex-col justify-center pt-32 pb-20 border-b border-white/5">
            <div class="absolute inset-0 opacity-[0.02] mix-blend-overlay pointer-events-none" style="background-image: url('data:image/svg+xml,%3Csvg viewBox=%220 0 200 200%22 xmlns=%22http://www.w3.org/2000/svg%22%3E%3Cfilter id=%22noiseFilter%22%3E%3CfeTurbulence type=%22fractalNoise%22 baseFrequency=%220.8%22 numOctaves=%224%22 stitchTiles=%22stitch%22/%3E%3C/filter%3E%3Crect width=%22100%25%22 height=%22100%25%22 filter=%22url(%23noiseFilter)%22/%3E%3C/svg%3E');"></div>
            
            <div class="pointer-events-none absolute -top-20 left-1/2 -translate-x-1/2 w-[600px] h-[600px] bg-teal-600/20 blur-[150px] rounded-full mix-blend-screen opacity-50"></div>
            
            <div class="relative z-10 mx-auto w-full max-w-[1440px] px-6 md:px-12 text-center flex flex-col items-center">
                <p class="inline-flex items-center space-x-2 text-[11px] font-bold uppercase tracking-[0.2em] text-teal-400 mb-6 drop-shadow-sm bg-teal-400/10 px-4 py-2 rounded-full border border-teal-400/20">Sem Enrolação</p>
                <h1 class="text-5xl sm:text-6xl lg:text-[5.5rem] leading-[0.95] tracking-tighter mix-blend-lighten text-slate-100 font-extrabold max-w-4xl">
                    Segurança levada a<br>
                    <span class="text-transparent bg-clip-text bg-gradient-to-r from-teal-300 to-green-400 font-serif italic pr-2">sério de verdade.</span>
                </h1>
                <p class="mt-8 text-xl leading-relaxed text-slate-400 font-medium max-w-2xl mx-auto">
                    A gente blinda o seu controle financeiro. Sem rastreio escondido.
                </p>

                <div class="mt-10 flex flex-wrap gap-4 justify-center items-center">
                    <Link
                        :href="route('site.contact')"
                        class="inline-flex h-12 w-auto items-center justify-center rounded-2xl bg-teal-500 px-8 text-[12px] font-extrabold uppercase tracking-[0.15em] text-slate-950 transition-all hover:bg-teal-400 hover:scale-105 shadow-[0_0_20px_theme(colors.teal.500/40)]"
                    >
                        Chama o Suporte
                    </Link>
                    <Link
                        :href="route('site.privacy')"
                        class="inline-flex h-12 w-auto items-center justify-center rounded-2xl bg-white/10 px-8 text-[12px] font-extrabold uppercase tracking-[0.15em] text-slate-200 transition-all hover:bg-white/20 backdrop-blur-sm border border-white/20 hover:scale-105"
                    >
                        Nossa Privacidade
                    </Link>
                </div>
            </div>
        </MotionSection>

        <!-- Controls Section -->
        <MotionSection class="bg-gray-50 py-24 pb-32">
            <div class="mx-auto w-full max-w-[1440px] px-6 md:px-12 grid gap-16 lg:grid-cols-12">
                <div class="lg:col-span-5 lg:sticky lg:top-32 h-fit">
                    <h2 class="text-4xl sm:text-5xl font-extrabold tracking-tighter text-slate-900 leading-[1.05]">
                        Base técnica <span class="text-teal-500 font-serif italic">inteligente.</span>
                    </h2>
                    <p class="mt-6 text-lg text-slate-500 font-medium leading-relaxed max-w-sm">
                        Do código ao banco de dados, cada etapa é desenhada pra você não ter dor de cabeça com vazamentos ou surpresas idiotas.
                    </p>
                </div>

                <div class="lg:col-span-7 flex flex-col gap-6">
                    <article
                        v-for="(item, index) in controls"
                        :key="item.title"
                        class="group p-8 md:p-10 rounded-[2rem] border border-slate-200 bg-white hover:border-teal-300 hover:shadow-xl transition-all duration-300 flex flex-col md:flex-row gap-6 relative overflow-hidden"
                    >
                        <div class="absolute -right-10 -bottom-10 text-[10rem] font-bold text-slate-50 opacity-50 select-none group-hover:text-teal-50 group-hover:scale-110 transition-transform duration-500">
                            0{{ index + 1 }}
                        </div>
                        <div class="relative z-10 mt-2">
                             <div class="h-10 w-10 bg-teal-100 rounded-xl flex items-center justify-center text-teal-600 font-extrabold text-lg">{{ index + 1 }}</div>
                        </div>
                        <div class="relative z-10 flex-1">
                            <h3 class="text-2xl font-extrabold tracking-tight text-slate-950 mb-3 group-hover:text-teal-600 transition-colors">{{ item.title }}</h3>
                            <p class="text-lg leading-relaxed text-slate-600 font-medium">{{ item.description }}</p>
                        </div>
                    </article>
                </div>
            </div>
        </MotionSection>

        <!-- Use Cases Section / Flow -->
        <MotionSection class="bg-white py-24 relative overflow-hidden border-y border-slate-100">
             <div class="mx-auto w-full max-w-[1440px] px-6 md:px-12">
                <div class="grid gap-16 rounded-[2.5rem] bg-slate-950 text-white p-10 md:p-16 lg:grid-cols-12 relative overflow-hidden shadow-2xl">
                     <div class="absolute inset-0 opacity-[0.05] mix-blend-screen pointer-events-none" style="background-image: url('data:image/svg+xml,%3Csvg viewBox=%220 0 200 200%22 xmlns=%22http://www.w3.org/2000/svg%22%3E%3Cfilter id=%22noiseFilter%22%3E%3CfeTurbulence type=%22fractalNoise%22 baseFrequency=%220.8%22 numOctaves=%224%22 stitchTiles=%22stitch%22/%3E%3C/filter%3E%3Crect width=%22100%25%22 height=%22100%25%22 filter=%22url(%23noiseFilter)%22/%3E%3C/svg%3E');"></div>
                    
                    <div class="lg:col-span-6 relative z-10 flex flex-col justify-center">
                        <p class="text-[11px] font-bold uppercase tracking-[0.2em] text-teal-400 mb-4 inline-block bg-white/5 border border-white/10 px-4 py-2 rounded-lg">Ciclo Constante</p>
                        <h2 class="text-4xl sm:text-5xl font-extrabold tracking-tighter text-white leading-[1.05]">A rotina <span class="text-green-400 font-serif italic">inquebrável</span> do sistema.</h2>

                        <ol class="mt-12 space-y-8 relative before:absolute before:inset-y-0 before:left-6 before:w-[2px] before:bg-gradient-to-b before:from-teal-500/50 before:to-transparent">
                            <li v-for="step in securityFlow" :key="step.step" class="relative pl-16">
                                <span class="absolute left-2 top-0 inline-flex flex-col h-8 w-8 items-center justify-center rounded-full bg-teal-500 text-xs font-bold text-slate-950 shadow-[0_0_15px_theme(colors.teal.500/30)] z-10">
                                </span>
                                <h3 class="text-2xl tracking-tight text-white font-bold">{{ step.title }}</h3>
                                <p class="mt-2 text-base leading-relaxed text-slate-400 font-medium">{{ step.text }}</p>
                            </li>
                        </ol>
                    </div>

                    <div class="lg:col-span-6 relative z-10">
                        <div class="grid grid-cols-2 gap-4 h-full">
                            <img
                                src="https://images.pexels.com/photos/3184418/pexels-photo-3184418.jpeg?auto=compress&cs=tinysrgb&w=900"
                                alt="Foco total no monitor"
                                class="h-64 sm:h-[400px] lg:h-full w-full rounded-[1.5rem] object-cover transition duration-700 hover:scale-[1.03] filter grayscale hover:grayscale-0 hover:saturate-150"
                                loading="lazy"
                            />
                            <img
                                src="https://images.pexels.com/photos/3184338/pexels-photo-3184338.jpeg?auto=compress&cs=tinysrgb&w=900"
                                alt="Revisão de dados constantes"
                                class="h-64 sm:h-[400px] lg:h-full w-full rounded-[1.5rem] object-cover transition duration-700 hover:scale-[1.03] filter grayscale hover:grayscale-0 hover:saturate-150 mt-8"
                                loading="lazy"
                            />
                        </div>
                    </div>
                </div>
            </div>
        </MotionSection>

        <!-- Conformity / LGPD Section -->
        <MotionSection class="bg-gray-50 py-24 border-b border-slate-200">
            <div class="mx-auto grid w-full max-w-[1440px] px-6 md:px-12 lg:grid-cols-12 gap-16">
                <div class="lg:col-span-5 flex flex-col justify-center lg:sticky lg:top-32 h-fit">
                    <h2 class="mt-4 text-4xl sm:text-5xl font-extrabold tracking-tighter text-slate-950 leading-[1.05]">Privacidade é coisa <span class="text-teal-500 font-serif italic">óbvia.</span></h2>
                    <p class="mt-6 text-lg leading-relaxed text-slate-600 font-medium">
                        A LGPD aqui não é só pra inglês ver. É filosofia de código real, praticada do servidor até o seu clique na tela.
                    </p>
                </div>
                <div class="lg:col-span-7 flex flex-col gap-4">
                    <article v-for="item in lgpd" :key="item" class="p-6 md:p-8 rounded-2xl border border-slate-200 bg-white hover:border-teal-200 hover:shadow-lg transition-all flex items-center gap-6">
                        <div class="shrink-0 w-12 h-12 bg-teal-50 text-teal-600 rounded-full flex items-center justify-center font-bold">
                            <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/></svg>
                        </div>
                        <p class="text-lg leading-relaxed text-slate-700 font-bold max-w-lg">{{ item }}</p>
                    </article>
                    
                    <div class="mt-8 flex gap-4">
                        <Link
                            :href="route('site.privacy')"
                            class="inline-flex h-12 items-center justify-center rounded-xl bg-slate-950 px-6 text-[12px] font-extrabold uppercase tracking-[0.15em] text-white hover:bg-teal-500 hover:text-slate-950 transition-all active:scale-95"
                        >
                            Ver a Política Completa
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
