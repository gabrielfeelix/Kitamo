<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';
import MotionSection from '@/Components/site/MotionSection.vue';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const timeline = [
    {
        year: 'O Começo',
        title: 'Nascimento do Conceito',
        text: 'Começou a incomodar a falta de clareza nas contas. O Kitamo nasceu focado em projeção de caixa que faz sentido pra pessoa física, sem complicação inútil.',
    },
    {
        year: 'Lançamento',
        title: 'A Máquina Roda',
        text: 'Botamos na rua a primeira versão braba. Contas, cartões, metas e recorrências rodando limpo, ajudando a galera a arrumar a casa.',
    },
    {
        year: 'Agora',
        title: 'Expansão e Estrutura',
        text: 'Subimos de nível. Projeção de longo prazo pesada, estrutura de planos justa e uma jornada institucional premium que você tá vendo agora.',
    },
    {
        year: 'Próximos Passos',
        title: 'Inteligência e Escala',
        text: 'O futuro é alerta inteligente, relatórios que falam a sua língua e decisões automatizadas guiando seu próximo passo financeiro.',
    },
];

const team = [
    {
        image: 'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=700',
        name: 'Fundador Desconhecido',
        role: 'CEO & Founder',
    },
    {
        image: 'https://images.pexels.com/photos/3727462/pexels-photo-3727462.jpeg?auto=compress&cs=tinysrgb&w=700',
        name: 'Mestre dos Códigos',
        role: 'CTO',
    },
    {
        image: 'https://images.pexels.com/photos/3760067/pexels-photo-3760067.jpeg?auto=compress&cs=tinysrgb&w=700',
        name: 'Dono do Produto',
        role: 'Product Lead',
    },
    {
        image: 'https://images.pexels.com/photos/3184465/pexels-photo-3184465.jpeg?auto=compress&cs=tinysrgb&w=700',
        name: 'Faz Acontecer',
        role: 'Operations Lead',
    },
    {
        image: 'https://images.pexels.com/photos/3184433/pexels-photo-3184433.jpeg?auto=compress&cs=tinysrgb&w=700',
        name: 'Máquina de Vendas',
        role: 'Growth Lead',
    },
];

const stats = [
    { label: '+3.5', value: 'Anos na Estrada' },
    { label: '+50 mil', value: 'Projeções Batidas' },
    { label: '+500', value: 'Casas Organizadas Mensalmente' },
    { label: '+200 mil', value: 'Alertas Salvos na Hora' },
];

const values = [
    {
        title: 'Ruído Zero',
        description: 'Dashboard enfeitado é pra ego. A gente te dá clareza limpa pra você saber se dá ou não dá pra gastar hoje.',
    },
    {
        title: 'O Volante é Seu',
        description: 'Sem robô fuçando na sua conta bancária e te dando sugestões burras. Controle manual, seguro e absoluto da sua vida.',
    },
    {
        title: 'Grana é Grana',
        description: 'Não vendemos sua rotina pra anunciante, seu comportamento não é mercadoria. Nossa renda vem da nossa assinatura.',
    },
];
</script>

<template>
    <Head title="A Empresa | Kitamo">
        <meta name="description" content="Nossa história, nosso time e porque a gente não vende seus dados." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <!-- Hero Section -->
        <MotionSection class="relative min-h-[60vh] w-full overflow-hidden bg-slate-950 text-white flex flex-col justify-center pt-32 pb-20 border-b border-white/5">
             <div class="absolute inset-0 opacity-[0.02] mix-blend-overlay pointer-events-none" style="background-image: url('data:image/svg+xml,%3Csvg viewBox=%220 0 200 200%22 xmlns=%22http://www.w3.org/2000/svg%22%3E%3Cfilter id=%22noiseFilter%22%3E%3CfeTurbulence type=%22fractalNoise%22 baseFrequency=%220.8%22 numOctaves=%224%22 stitchTiles=%22stitch%22/%3E%3C/filter%3E%3Crect width=%22100%25%22 height=%22100%25%22 filter=%22url(%23noiseFilter)%22/%3E%3C/svg%3E');"></div>
            
             <div class="pointer-events-none absolute top-10 right-10 w-[500px] h-[500px] bg-teal-600/20 blur-[130px] rounded-full mix-blend-screen opacity-50"></div>
            
             <div class="relative z-10 mx-auto w-full max-w-[1440px] px-6 md:px-12 grid lg:grid-cols-2 gap-12 items-center">
                 <div>
                     <p class="inline-flex items-center space-x-2 text-[11px] font-bold uppercase tracking-[0.2em] text-teal-400 mb-6 drop-shadow-sm bg-teal-400/10 px-4 py-2 rounded-full border border-teal-400/20">Quem Somos</p>
                     <h1 class="text-5xl sm:text-6xl md:text-[5rem] leading-[0.95] tracking-tighter mix-blend-lighten text-slate-100 font-extrabold">
                         Muito além do<br>
                         <span class="text-transparent bg-clip-text bg-gradient-to-r from-teal-300 to-green-400 font-serif italic pr-2">básico.</span>
                     </h1>
                     <p class="mt-8 text-xl leading-relaxed text-slate-400 font-medium max-w-xl text-left">
                         Desenvolvemos uma parada construída no Brasil, feita pra galera que quer dominar o caixa sem ficar engessado.
                     </p>
                 </div>
                 
                 <div class="relative group mt-8 lg:mt-0">
                     <div class="absolute inset-0 bg-teal-500/20 blur-2xl rounded-[2rem] transform group-hover:scale-105 transition-transform duration-700"></div>
                     <img
                         src="https://images.pexels.com/photos/3182812/pexels-photo-3182812.jpeg?auto=compress&cs=tinysrgb&w=1200"
                         alt="Nossa galera no planejamento"
                         class="relative h-[300px] sm:h-[400px] w-full object-cover rounded-[2rem] border border-white/10 shadow-2xl filter grayscale hover:grayscale-0 hover:saturate-150 transition-all duration-700"
                         loading="lazy"
                     />
                 </div>
             </div>
        </MotionSection>

        <!-- Timeline Section -->
        <MotionSection class="bg-gray-50 py-24 pb-32">
            <div class="mx-auto w-full max-w-[1440px] px-6 md:px-12 grid gap-16 lg:grid-cols-12">
                <aside class="lg:col-span-5 lg:sticky lg:top-32 h-fit">
                    <h2 class="text-4xl sm:text-5xl font-extrabold tracking-tighter text-slate-900 leading-[1.05]">
                        Nossa <span class="text-teal-500 font-serif italic">correria.</span>
                    </h2>
                    <p class="mt-6 text-lg text-slate-500 font-medium leading-relaxed max-w-sm">
                        De onde viemos e pra onde estamos acelerando. A história do Kitamo rola rápida.
                    </p>
                    <div class="mt-10 overflow-hidden rounded-[2rem] shadow-xl border border-slate-200 group">
                        <img
                            src="https://images.pexels.com/photos/3183197/pexels-photo-3183197.jpeg?auto=compress&cs=tinysrgb&w=1100"
                            alt="Equipe batendo meta"
                            class="h-[250px] w-full object-cover filter grayscale group-hover:grayscale-0 transition-all duration-700"
                            loading="lazy"
                        />
                    </div>
                </aside>

                <div class="lg:col-span-7">
                    <div class="bg-white rounded-[2.5rem] p-8 md:p-12 border border-slate-200 shadow-sm relative overflow-hidden">
                         <div class="absolute left-[3.25rem] md:left-[4.25rem] top-12 bottom-12 w-[2px] bg-gradient-to-b from-teal-500/50 to-transparent"></div>
                         
                         <div class="space-y-12 relative z-10">
                             <div v-for="(item, index) in timeline" :key="index" class="relative pl-16 md:pl-20 group">
                                  <div class="absolute left-0 top-1.5 h-6 w-6 rounded-full bg-slate-50 border-4 border-teal-500 shadow-[0_0_15px_theme(colors.teal.500/40)] group-hover:scale-125 transition-transform"></div>
                                  <p class="text-[11px] font-bold uppercase tracking-[0.2em] text-teal-600 mb-1">{{ item.year }}</p>
                                  <h3 class="text-2xl font-extrabold text-slate-900 mb-2">{{ item.title }}</h3>
                                  <p class="text-base font-medium leading-relaxed text-slate-600">{{ item.text }}</p>
                             </div>
                         </div>
                    </div>
                </div>
            </div>
        </MotionSection>

        <!-- Team & Stats Section -->
        <MotionSection class="bg-white py-24 relative z-10 border-y border-slate-100">
             <div class="mx-auto w-full max-w-[1440px] px-6 md:px-12">
                 <div class="text-center mb-16">
                     <p class="text-[11px] font-bold uppercase tracking-[0.2em] text-slate-400 mb-4 inline-block bg-slate-50 px-4 py-2 border border-slate-100 rounded-lg">Quem Bota Pra Quebrar</p>
                     <h2 class="text-3xl sm:text-4xl font-extrabold tracking-tighter text-slate-900">A galera por trás da tela</h2>
                 </div>

                 <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-6">
                     <article v-for="member in team" :key="member.role" class="group flex flex-col items-center">
                         <div class="w-full aspect-[4/5] rounded-[2rem] overflow-hidden bg-slate-100 mb-4 relative">
                              <div class="absolute inset-0 bg-slate-900/10 group-hover:bg-transparent transition-colors z-10"></div>
                              <img
                                  :src="member.image"
                                  :alt="member.name"
                                  class="w-full h-full object-cover filter grayscale group-hover:grayscale-0 group-hover:scale-105 transition-all duration-700"
                                  loading="lazy"
                              />
                         </div>
                         <p class="text-sm md:text-base font-extrabold text-slate-900 mb-1 group-hover:text-teal-600 transition-colors">{{ member.name }}</p>
                         <p class="text-[10px] md:text-xs font-bold uppercase tracking-[0.15em] text-slate-400">{{ member.role }}</p>
                     </article>
                 </div>
                 
                 <!-- TODO: Inserir fotos e nomes reais depois -->

                 <div class="mt-20 grid grid-cols-2 lg:grid-cols-4 gap-6">
                     <article v-for="item in stats" :key="item.label" class="bg-slate-50 rounded-[2rem] p-8 border border-slate-100 text-center hover:bg-slate-100 hover:scale-105 transition-transform duration-300">
                         <p class="text-4xl md:text-5xl font-extrabold tracking-tighter text-teal-500 mb-3">{{ item.label }}</p>
                         <p class="text-[11px] md:text-xs font-bold uppercase tracking-[0.15em] text-slate-600 leading-relaxed">{{ item.value }}</p>
                     </article>
                 </div>
             </div>
        </MotionSection>

        <!-- Values Section -->
        <MotionSection class="relative overflow-hidden bg-slate-950 py-24 text-white">
            <div class="absolute -left-20 bottom-0 h-96 w-96 rounded-full bg-teal-500/15 blur-[120px]"></div>
            
            <div class="mx-auto w-full max-w-[1440px] px-6 md:px-12 relative z-10">
                <div class="text-center mb-16 max-w-4xl mx-auto">
                    <p class="inline-flex items-center space-x-2 text-[10px] font-bold uppercase tracking-[0.2em] text-teal-400 mb-4 bg-slate-800 px-3 py-1.5 rounded-lg border border-slate-700">Por que a gente faz isso</p>
                    <h2 class="text-4xl sm:text-5xl md:text-6xl font-extrabold leading-[0.95] tracking-tighter text-white">
                        Maximizar o poder da sua <span class="block font-serif italic text-teal-400 mt-2">decisão diária.</span>
                    </h2>
                    <p class="mt-6 text-xl leading-relaxed text-slate-400 font-medium">
                        Pegamos dados bagunçados e transformamos em ação. Acabou a incerteza do começo de mês.
                    </p>
                </div>

                <div class="grid md:grid-cols-3 gap-8">
                    <article v-for="item in values" :key="item.title" class="bg-white/5 border border-white/10 p-8 rounded-[2rem] hover:bg-white/10 transition-colors duration-300 relative overflow-hidden group">
                        <div class="absolute -right-4 -top-4 w-24 h-24 bg-teal-500/20 blur-xl rounded-full group-hover:bg-teal-400/30 transition-colors"></div>
                        <h3 class="text-2xl font-extrabold tracking-tight text-white mb-4 relative z-10">{{ item.title }}</h3>
                        <p class="text-base leading-relaxed text-slate-300 font-medium relative z-10">{{ item.description }}</p>
                    </article>
                </div>

                <div class="mt-16 flex flex-wrap justify-center gap-4">
                    <Link
                        :href="route('site.contact')"
                        class="inline-flex h-14 items-center justify-center rounded-xl bg-teal-500 px-8 text-[12px] font-extrabold uppercase tracking-[0.15em] text-slate-950 transition-all hover:bg-teal-400 hover:scale-105 shadow-[0_0_20px_theme(colors.teal.500/30)]"
                    >
                        Tamo Pronto pra Falar
                    </Link>
                    <Link
                        :href="route('site.contact')"
                        class="inline-flex h-14 items-center justify-center rounded-xl border border-white/20 bg-white/5 backdrop-blur-sm px-8 text-[12px] font-extrabold uppercase tracking-[0.15em] text-slate-200 transition-all hover:bg-white/10 hover:border-white hover:scale-105"
                    >
                        Trabalhe com a Gente
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
