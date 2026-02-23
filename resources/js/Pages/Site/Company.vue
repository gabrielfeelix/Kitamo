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
        <MotionSection class="relative min-h-[70vh] w-full overflow-hidden flex flex-col justify-end pt-32 pb-20">
             <!-- Full Bleed Image Background -->
             <div class="absolute inset-0">
                 <img
                     src="https://images.pexels.com/photos/3182812/pexels-photo-3182812.jpeg?auto=compress&cs=tinysrgb&w=1920"
                     alt="Nossa galera no planejamento"
                     class="w-full h-full object-cover filter saturate-[0.8]"
                 />
                 <!-- Gradient Overlays for readability -->
                 <div class="absolute inset-0 bg-gradient-to-t from-slate-950 via-slate-950/60 to-transparent"></div>
                 <div class="absolute inset-0 bg-teal-900/20 mix-blend-multiply"></div>
             </div>
            
             <div class="relative z-10 mx-auto w-full max-w-[1440px] px-6 md:px-12">
                 <div class="max-w-3xl">
                     <p class="inline-flex items-center space-x-2 text-[11px] font-bold uppercase tracking-[0.2em] text-teal-300 mb-6 drop-shadow-sm bg-black/20 backdrop-blur-md px-4 py-2 rounded-full border border-white/10">Nossas Raízes</p>
                     <h1 class="text-5xl sm:text-6xl md:text-[6rem] leading-[0.95] tracking-tighter text-white font-extrabold drop-shadow-lg">
                         Atrás do <span class="font-serif text-teal-400 italic">código.</span>
                     </h1>
                     <p class="mt-8 text-xl sm:text-2xl leading-relaxed text-slate-300 font-medium max-w-xl text-left drop-shadow">
                         Desenvolvemos uma ferramenta construída no Brasil, feita pra galera que quer dominar o caixa sem ficar engessado num sistema chato.
                     </p>
                 </div>
             </div>
        </MotionSection>

        <!-- Manifesto do Fundador -->
        <MotionSection class="bg-white py-32 border-b border-slate-100 relative overflow-hidden">
            <div class="absolute inset-0 bg-[radial-gradient(circle_at_top_right,_var(--tw-gradient-stops))] from-teal-50 to-transparent pointer-events-none"></div>
            <div class="mx-auto w-full max-w-[1000px] px-6 md:px-12 relative z-10">
                <div class="flex flex-col md:flex-row gap-12 md:gap-20 items-start">
                    <div class="w-full md:w-1/3 flex-shrink-0">
                        <div class="relative rounded-[2rem] overflow-hidden shadow-2xl rotate-3 hover:rotate-0 transition-transform duration-500">
                            <div class="absolute inset-0 bg-teal-900/10 mix-blend-multiply z-10"></div>
                            <img src="https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=800" alt="Fundador do Kitamo" class="w-full aspect-[4/5] object-cover filter grayscale hover:grayscale-0 transition-[filter] duration-700" />
                        </div>
                        <div class="mt-6 text-center md:text-left">
                            <h4 class="font-extrabold text-slate-900 text-xl">Gabriel Félix</h4>
                            <p class="text-sm font-bold uppercase tracking-widest text-teal-600 mt-1">Fundador & CEO</p>
                        </div>
                    </div>
                    
                    <div class="w-full md:w-2/3">
                        <span class="inline-block px-4 py-1.5 bg-slate-100 text-slate-500 font-extrabold text-[12px] uppercase tracking-[0.2em] rounded-full border border-slate-200 mb-8">Nossa Origem</span>
                        <h2 class="text-3xl sm:text-5xl font-extrabold tracking-tighter text-slate-900 mb-10 leading-[1.1]">
                            O KITAMO nasceu da culpa de olhar pro retrovisor.
                        </h2>
                        
                        <div class="space-y-6 text-lg sm:text-xl text-slate-600 font-medium leading-relaxed font-serif">
                            <p>
                                "Eu estava cansado de sentar domingo à noite com uma planilha de 30 abas, olhar para trás e apenas aceitar que o dinheiro tinha ido embora. Era sempre a mesma sensação: culpa e ansiedade (efeito avestruz)."
                            </p>
                            <p>
                                "A indústria inteira de finanças queria me vender aplicativos automáticos, que puxavam tudo sem que eu visse, criando uma gaiola invisível onde eu só olhava para o extrato quando já estava no vermelho."
                            </p>
                            <p>
                                "O KITAMO não surgiu para ser mais um aglomerador de contas. Sugiu porque eu queria um GPS financeiro. Algo que pegasse o meu dinheiro hoje e me deixasse projetá-lo no tempo. Nós trouxemos a responsabilidade de volta para o usuário através da digitação manual, mas fizemos isso com a interface mais linda e rápida do mundo."
                            </p>
                            <p class="text-slate-900 font-extrabold pt-4 text-2xl">
                                "Não confie no banco sozinho. Volte para o volante."
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </MotionSection>

        <!-- Timeline Section -->
        <MotionSection class="bg-slate-50 py-24 pb-32">
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
                         <div class="absolute left-[2.75rem] md:left-[3.75rem] top-12 bottom-12 w-[2px] bg-gradient-to-b from-teal-500/50 to-transparent"></div>
                         
                         <div class="space-y-12 relative z-10">
                             <div v-for="(item, index) in timeline" :key="index" class="relative pl-12 md:pl-16 group">
                                  <div class="absolute left-[0.5rem] md:left-[0.75rem] top-1 h-7 w-7 rounded-full bg-slate-50 border-4 border-teal-500 shadow-[0_0_15px_theme(colors.teal.500/40)] group-hover:scale-125 transition-transform"></div>
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
