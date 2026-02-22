<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';
import MotionSection from '@/Components/site/MotionSection.vue';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const features = [
    {
        id: 'projecao',
        title: 'Mestre da Projeção de Caixa',
        badge: 'O Coração',
        description:
            'A parada mais pesada que temos. Pega seu saldo, cruza com tudo que vai sair e entrar pra te dar a visão do futuro. Você age meses antes do problema chegar.',
        bullets: ['Painel diário pra prever o vermelho', 'Sem susto no extrato de amanhã', 'Olhou, decidiu, salvou a pele'],
    },
    {
        id: 'contas',
        title: 'Gestão que Resolve',
        badge: '',
        description:
            'Um HUB só, mas a grana separada do seu jeito: corrente, reserva, carteira, corretora. O histórico fica certinho por período pra você arrastar e revisar rápido.',
        bullets: ['Cria conta e separa a grana', 'Olha pro passado pra aprender o que rolou', 'Visão macro: a soma de tudo num clique'],
    },
    {
        id: 'cartoes',
        title: 'Cartão de Crédito? Domado',
        badge: '',
        description:
            'Aquela bola de neve? Não mais. Jogou aqui e nós rastreamos o ciclo da fatura, o fechamento maldito e o quanto já pegou do seu limite. E o melhor: joga direto na sua projeção de fluxo.',
        bullets: ['Notifica o fechamento da fatura', 'Cobre na Projeção: bate na conta certa na hora certa', 'Limite acompanhado ao vivo'],
    },
    {
        id: 'parcelamentos',
        title: 'Parcelar é bom (se tiver controle)',
        badge: '',
        description:
            'Fez 10x sem juros no telefone? Cadastra a primeira parcela e o sistema empilha o resto sozinho, caindo nos meses certos do seu banco e consumindo seu fôlego financeiro futuro pra você não esquecer.',
        bullets: ['10x, 24x... empilha tudo no automático', 'Bate lá no futuro do gráfico de projeção', 'Edita uma, e altera o resto se errar'],
    },
    {
        id: 'recorrentes',
        title: 'Rotina sem Retrabalho',
        badge: 'Top Uso',
        description:
            'Netflix, academia, conta de luz. Pra que ficar lançando de novo todo mês? Você joga a assinatura na esteira e nós jogamos no seu caixa infinito.',
        bullets: ['Acomoda semanal, quinzenal e mensal', 'Fica engatilhado no calendário sem esforço', 'Lembretes de revisão: tá pagando pra não usar? Cancela'],
    },
    {
        id: 'metas',
        title: 'Bater Metas (de verdade)',
        badge: '',
        description:
            'Trocar de carro ou montar a reserva de segurança. Coloca um nome, um valor alvo, e rastreia como você tá performando pra chegar lá sem virar promessa de ano novo genérica.',
        bullets: ['Acompanhe a barra verde subir', 'Aposte contra vocé mesmo se atrasar', 'Diferencia a grana da meta e o resto do fluxo livre'],
    },
    {
        id: 'relatorios',
        title: 'Raio-X (Relatórios sem Ego)',
        badge: '',
        description:
            'Chega na gringa, bate na reunião com seu parceiro(a) ou com o contador entregando pronto. Comparativo do mês pra saber se tá rasgando grana nas categorias certas ou erradas.',
        bullets: ['Pinga onde você mais gastar na coragem da verdade', 'Mês x Mês com seta pra cima e pra baixo', 'Tira do sistema em CSV e PDF'],
    },
];

const faq = [
    {
        question: 'O Kitamo é um daqueles apps que pede a senha do meu banco?',
        answer: 'Foge disso! Nós não metemos Open Finance e robôs pra fuçar na sua conta. Você lança e a gente trabalha, pra manter seu controle humano soberano e inviolável.',
    },
    {
        question: 'Então tem que adicionar tudo na mão? Cês tão de sacanagem.',
        answer: 'A entrada inicial sim! Depois a mágica vem: coisas recorrentes, boletos fixos e faturas rodam num circuito 100% automático pelos nossos algoritmos.',
    },
    {
        question: 'E se eu parcelar o IPVA do carro velho lá? Empilha sozinho?',
        answer: 'Demais. Ele entende a parcela N de X e avisa você mês a mês sobre como essa parcela tá matando seu saldo na projeção futura.',
    },
    {
        question: 'Meu primo doidão ganha pouco, vai pagar assinatura se apertar?',
        answer: 'Não se você falar do plano essencial que existe hoje! Tem plano que começa bem barato pra ajudar quem tá zerado a virar o jogo antes de pensar na mensalidade robusta.',
    },
    {
        question: 'Eu posso botar planilha excel aí dentro pra não perder o histórico antigo?',
        answer: 'Em breve soltamos o importador pesado pra quem tá vindo de planilha antiga não passar nervoso reconectando.',
    },
];

const featureVisuals = [
    'https://images.pexels.com/photos/3184291/pexels-photo-3184291.jpeg?auto=compress&cs=tinysrgb&w=1000',
    'https://images.pexels.com/photos/3183197/pexels-photo-3183197.jpeg?auto=compress&cs=tinysrgb&w=1000',
    'https://images.pexels.com/photos/3760067/pexels-photo-3760067.jpeg?auto=compress&cs=tinysrgb&w=1000',
    'https://images.pexels.com/photos/572056/pexels-photo-572056.jpeg?auto=compress&cs=tinysrgb&w=1000',
    'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=1000',
];
</script>

<template>
    <Head title="Funcionalidades da Máquina | Kitamo">
        <meta name="description" content="Descubra a máquina por baixo do capô: projeção futurista, gestão raiz de cartões, organização absurda." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <!-- Hero Section -->
        <MotionSection class="relative min-h-[50vh] w-full overflow-hidden bg-gray-50 text-slate-900 flex flex-col justify-center pt-32 pb-20 border-b border-slate-200">
             <div class="absolute inset-0 opacity-[0.4] mix-blend-multiply pointer-events-none" style="background-image: url('data:image/svg+xml,%3Csvg viewBox=%220 0 200 200%22 xmlns=%22http://www.w3.org/2000/svg%22%3E%3Cfilter id=%22noiseFilter%22%3E%3CfeTurbulence type=%22fractalNoise%22 baseFrequency=%220.8%22 numOctaves=%224%22 stitchTiles=%22stitch%22/%3E%3C/filter%3E%3Crect width=%22100%25%22 height=%22100%25%22 filter=%22url(%23noiseFilter)%22/%3E%3C/svg%3E');"></div>
             <div class="pointer-events-none absolute -top-20 -left-20 w-[500px] h-[500px] bg-teal-400/20 blur-[150px] rounded-full mix-blend-multiply opacity-60"></div>
            
             <div class="relative z-10 mx-auto w-full max-w-[1440px] px-6 md:px-12 grid lg:grid-cols-12 gap-12 items-center">
                 <div class="lg:col-span-7">
                     <p class="inline-flex items-center space-x-2 text-[11px] font-bold uppercase tracking-[0.2em] text-teal-600 mb-6 drop-shadow-sm bg-teal-50 px-4 py-2 rounded-full border border-teal-100 shadow-sm">Por Baixo do Capô</p>
                     <h1 class="text-5xl sm:text-6xl md:text-[5rem] leading-[0.95] tracking-tighter text-slate-900 font-extrabold max-w-4xl drop-shadow-sm">
                         A Máquina que<br>
                         <span class="text-teal-600 font-serif italic pr-2">resolve a bronca.</span>
                     </h1>
                     <p class="mt-8 text-xl leading-relaxed text-slate-600 font-medium max-w-2xl text-left">
                         Cada tela foi esculpida pra bater na dor que mais dói. Sai o "quanto que eu gastei no mês?" e entra o "quanto que falta antes de quebrar em outubro?".
                     </p>
                 </div>
                 
                 <div class="lg:col-span-5 relative group">
                     <div class="absolute inset-0 bg-teal-500/10 blur-2xl rounded-[2rem] transform group-hover:scale-105 transition-transform duration-700"></div>
                     <img
                         src="https://images.pexels.com/photos/572056/pexels-photo-572056.jpeg?auto=compress&cs=tinysrgb&w=1200"
                         alt="Kitamo rodando liso"
                         class="relative h-[300px] sm:h-[400px] w-full object-cover rounded-[2rem] border border-slate-200 shadow-2xl filter saturate-[0.8] hover:saturate-150 transition-all duration-700"
                         loading="lazy"
                     />
                 </div>
             </div>
        </MotionSection>

        <!-- Features Matrix Section -->
        <MotionSection class="bg-gray-50 py-24 pb-32">
            <div class="mx-auto w-full max-w-[1440px] px-6 md:px-12 grid gap-16 lg:grid-cols-12">
                <aside class="lg:col-span-4 lg:sticky lg:top-32 h-fit">
                    <p class="text-[11px] font-bold uppercase tracking-[0.2em] text-slate-400 mb-6">Mapa do Tesouro</p>
                    <div class="bg-white rounded-[2rem] border border-slate-200 p-6 shadow-sm overflow-hidden">
                        <ul class="space-y-1">
                            <li v-for="(item, index) in features" :key="item.id">
                                <a
                                    :href="`#${item.id}`"
                                    class="group flex items-center gap-4 px-4 py-3 rounded-2xl transition hover:bg-slate-50"
                                >
                                    <span class="text-[10px] font-extrabold text-slate-300 transition-colors group-hover:text-teal-600">0{{ index + 1 }}</span>
                                    <span class="text-sm font-bold text-slate-600 transition-colors group-hover:text-slate-900">{{ item.title }}</span>
                                </a>
                            </li>
                        </ul>
                    </div>
                </aside>

                <div class="lg:col-span-8 flex flex-col gap-8">
                    <article
                        v-for="(item, index) in features"
                        :id="item.id"
                        :key="item.id"
                        class="bg-white border border-slate-200 rounded-[2.5rem] p-8 md:p-12 shadow-sm transition-all hover:border-teal-300 hover:shadow-xl group overflow-hidden relative"
                    >
                         <div class="absolute -right-10 -bottom-10 text-[8rem] font-bold text-slate-50 opacity-50 select-none pointer-events-none group-hover:text-teal-50 group-hover:scale-110 transition-transform duration-700">
                             0{{ index + 1 }}
                         </div>
                         
                         <div class="grid md:grid-cols-12 gap-10 items-center relative z-10">
                             <div class="md:col-span-8">
                                 <div class="flex items-center gap-3 mb-6">
                                     <h2 class="text-3xl sm:text-4xl font-extrabold tracking-tighter text-slate-900">{{ item.title }}</h2>
                                     <span v-if="item.badge" class="inline-flex items-center px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-[0.15em] bg-teal-100 text-teal-800">{{ item.badge }}</span>
                                 </div>
                                 <p class="text-lg leading-relaxed text-slate-600 font-medium">{{ item.description }}</p>
                                 <ul class="mt-8 space-y-4">
                                     <li v-for="point in item.bullets" :key="point" class="flex items-start gap-3">
                                         <span class="flex-shrink-0 w-6 h-6 rounded-full bg-slate-100 flex items-center justify-center text-teal-600 mt-1">
                                             <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/></svg>
                                         </span>
                                         <span class="text-base font-bold text-slate-700">{{ point }}</span>
                                     </li>
                                 </ul>
                             </div>
                             
                             <div class="md:col-span-4 self-stretch hidden md:block relative bg-slate-100 rounded-2xl overflow-hidden group-hover:shadow-[0_0_30px_rgba(20,184,166,0.15)] transition-shadow duration-700">
                                 <div class="absolute inset-0 bg-slate-900/10 z-10 group-hover:bg-transparent transition-colors"></div>
                                 <img
                                     :src="featureVisuals[index % featureVisuals.length]"
                                     :alt="item.title"
                                     class="absolute inset-0 w-full h-full object-cover filter grayscale group-hover:grayscale-0 group-hover:scale-110 transition-all duration-700"
                                     loading="lazy"
                                 />
                             </div>
                         </div>
                    </article>
                </div>
            </div>
        </MotionSection>

        <!-- Minimal FAQ Section -->
        <MotionSection class="bg-white py-24 relative overflow-hidden border-t border-slate-200">
            <div class="mx-auto w-full max-w-[1440px] px-6 md:px-12 md:w-3/4 lg:w-3/5 text-center">
                <p class="inline-flex items-center space-x-2 text-[11px] font-bold uppercase tracking-[0.2em] text-teal-600 mb-6 drop-shadow-sm bg-teal-50 px-4 py-2 rounded-full border border-teal-200">Perguntas Diretas</p>
                <h2 class="text-4xl sm:text-5xl font-extrabold tracking-tighter text-slate-900 mb-12">FAQ de papo reto</h2>
                
                <div class="text-left space-y-4">
                    <details 
                        v-for="item in faq" 
                        :key="item.question" 
                        class="group bg-slate-50 border border-slate-200 rounded-2xl p-6 open:bg-white open:border-teal-200 open:shadow-lg transition-all"
                    >
                        <summary class="cursor-pointer list-none font-bold text-lg text-slate-800 flex justify-between items-center group-open:text-teal-600">
                            {{ item.question }}
                            <span class="flex-shrink-0 ml-4 h-8 w-8 rounded-full border-2 border-slate-200 flex items-center justify-center group-open:border-teal-500 group-open:bg-teal-50 transition-colors">
                                <svg class="w-4 h-4 text-slate-500 group-open:text-teal-600 transition-transform group-open:rotate-180" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"/></svg>
                            </span>
                        </summary>
                        <p class="mt-6 text-base leading-relaxed text-slate-600 font-medium pl-2 border-l-2 border-teal-200">{{ item.answer }}</p>
                    </details>
                </div>

                <div class="mt-16 flex flex-wrap justify-center gap-4">
                    <Link
                        :href="route('site.pricing')"
                        class="inline-flex h-14 items-center justify-center rounded-2xl bg-slate-950 px-10 text-[12px] font-extrabold uppercase tracking-[0.15em] text-white transition-all hover:bg-teal-500 hover:text-slate-950 hover:shadow-[0_0_20px_theme(colors.teal.500/40)] hover:scale-105 active:scale-95"
                    >
                        Bora ver os planos
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
html {
    scroll-behavior: smooth;
}
</style>
