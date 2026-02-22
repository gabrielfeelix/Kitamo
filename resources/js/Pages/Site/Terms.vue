<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';
import MotionSection from '@/Components/site/MotionSection.vue';

const sections = [
    {
        id: 'acesso',
        label: 'A chave da casa',
        title: '1. Acesso e Uso Limpo',
        content: [
            'Basicamente: você assina, e a gente te dá a chave digital da plataforma. O acesso é seu, não transfere pro cunhado e não dá direito a hackear, desmontar ou vender nossa tela como se fosse sua.',
            'O uso é pra gente normal que quer arrumar a grana. Quem tentar usar de má fé, invadir sistema de terceiros ou forçar barra com robô nas nossas rotas vai bater de frente com a parede de bloqueio automático.',
        ],
    },
    {
        id: 'responsabilidade',
        label: 'O Volante é Seu',
        title: '2. Quem decide é você',
        content: [
            'O Kitamo te dá uma bússola e um mapa impecáveis. Mas quem pilota e faz as manobras no extrato bancário lá fora é você. Nós não somos corretora, fundo de investimento, nem conselheiros matrimoniais pra grana.',
            'Se você errar um zero na hora de lançar uma despesa e estourar a meta do mês, a responsabilidade de consertar o que quebrou é inteiramente sua. A gente não aprova, não repassa e nem toca no seu dinheiro de verdade.',
        ],
    },
    {
        id: 'assinaturas',
        label: 'O combinado na grana',
        title: '3. Assinatura, Cancelamento e Estorno',
        content: [
            'Assinou? Fechou. A gente cobra o ciclo combinado (mensal ou anual) até você decidir que não quer mais e mandar parar. Não amarramos você no pé da mesa.',
            'Entrou, olhou e não curtiu? Relaxa. Pela lei do Brasil tem os 7 dias sagrados de arrependimento pra compras online. Apertou o botão de cancelar lá dentro em até 7 dias, grana devolvida, sem choro.',
        ],
    },
    {
        id: 'encerramento',
        label: 'Cartão Vermelho',
        title: '4. Se pisar na bola...',
        content: [
            'Ninguém gosta de expulsar gente, mas se houver fraude explícita de cartão, ataque no nosso servidor ou desrespeito feio às regras de não revender nossa ferramenta... a gente derruba a conta.',
            'E não rola papinho. Atitudes que botem a segurança dos outros usuários ou do nosso código em risco tomam suspensão imediata e ban sem estorno.',
        ],
    },
    {
        id: 'foro',
        label: 'Onde brigamos',
        title: '5. Foro e Lei Bruta',
        content: [
            'A lei que manda aqui é a Brasileira. Nada de paraíso fiscal sem regulação.',
            'Se a coisa ficar feia de verdade e precisarmos chamar o juiz pro lance, o campo de jogo oficial é a Comarca de São Paulo/SP, a menos que a justiça ou o CDC mande a gente jogar na sua cidade.',
        ],
    },
];

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();
</script>

<template>
    <Head title="Termos de Uso | Kitamo">
        <meta name="description" content="Nossas regras do jogo. Acesso, responsabilidades e como a grana flui. Simples." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <!-- Hero Section -->
        <MotionSection class="relative min-h-[50vh] w-full overflow-hidden bg-slate-950 text-white flex flex-col justify-center pt-32 pb-20 border-b border-white/5">
            <div class="absolute inset-0 opacity-[0.02] mix-blend-overlay pointer-events-none" style="background-image: url('data:image/svg+xml,%3Csvg viewBox=%220 0 200 200%22 xmlns=%22http://www.w3.org/2000/svg%22%3E%3Cfilter id=%22noiseFilter%22%3E%3CfeTurbulence type=%22fractalNoise%22 baseFrequency=%220.8%22 numOctaves=%224%22 stitchTiles=%22stitch%22/%3E%3C/filter%3E%3Crect width=%22100%25%22 height=%22100%25%22 filter=%22url(%23noiseFilter)%22/%3E%3C/svg%3E');"></div>
            
            <div class="pointer-events-none absolute bottom-0 left-1/4 w-[400px] h-[400px] bg-teal-600/20 blur-[130px] rounded-full mix-blend-screen opacity-50"></div>
            
            <div class="relative z-10 mx-auto w-full max-w-[1440px] px-6 md:px-12 grid lg:grid-cols-12 gap-12 items-center">
                <div class="lg:col-span-7">
                    <p class="inline-flex items-center space-x-2 text-[11px] font-bold uppercase tracking-[0.2em] text-teal-400 mb-6 drop-shadow-sm bg-teal-400/10 px-4 py-2 rounded-full border border-teal-400/20">Nosso Combinado</p>
                    <h1 class="text-5xl sm:text-6xl md:text-[5rem] leading-[0.95] tracking-tighter mix-blend-lighten text-slate-100 font-extrabold">
                        As regras do <br>
                        <span class="text-transparent bg-clip-text bg-gradient-to-r from-teal-300 to-green-400 font-serif italic pr-2">jogo Kitamo.</span>
                    </h1>
                    <p class="mt-8 text-xl leading-relaxed text-slate-400 font-medium max-w-2xl text-left">
                        Nada é escondido na página de pagamento em letras tamanho 4. A gente fez um contrato no qual a gente joga pelas pontas e você comanda o meio-campo.
                    </p>
                    
                    <div class="mt-8 flex flex-wrap items-center gap-4 text-xs font-bold uppercase tracking-[0.15em] text-slate-500">
                        <span class="bg-white/5 border border-white/10 px-3 py-1 rounded">Versão 1.1</span>
                        <span>Atualizado em: Fev/2026</span>
                    </div>

                    <div class="mt-10 flex gap-4">
                        <Link
                            :href="route('site.contact')"
                            class="inline-flex h-12 items-center justify-center rounded-2xl bg-teal-500 px-8 text-[12px] font-extrabold uppercase tracking-[0.15em] text-slate-950 transition-all hover:bg-teal-400 hover:scale-105 shadow-[0_0_20px_theme(colors.teal.500/40)]"
                        >
                            Chamar o Suporte Legal
                        </Link>
                    </div>
                </div>

                <div class="lg:col-span-5 hidden lg:block relative group p-6">
                    <div class="absolute inset-0 bg-teal-500/10 blur-3xl rounded-[2rem] transform group-hover:scale-105 transition-transform duration-700"></div>
                     <img
                         src="https://images.pexels.com/photos/3184291/pexels-photo-3184291.jpeg?auto=compress&cs=tinysrgb&w=1200"
                         alt="Documentos limpos"
                         class="relative h-[350px] w-full object-cover rounded-[2.5rem] border border-white/10 shadow-2xl filter grayscale hover:grayscale-0 hover:saturate-150 transition-all duration-700"
                         loading="lazy"
                     />
                </div>
            </div>
        </MotionSection>

        <!-- Document Body -->
        <MotionSection class="bg-gray-50 py-24 pb-32">
            <div class="mx-auto w-full max-w-[1440px] px-6 md:px-12 grid gap-16 lg:grid-cols-12">
                <aside class="lg:col-span-4 lg:sticky lg:top-32 h-fit">
                    <div class="bg-white p-6 rounded-[2rem] border border-slate-200 shadow-sm">
                        <p class="text-[11px] font-bold uppercase tracking-[0.2em] text-slate-400 mb-6">Navegue no Doc</p>
                        <nav class="flex flex-col space-y-2">
                            <a
                                v-for="(item, index) in sections"
                                :key="item.id"
                                :href="`#${item.id}`"
                                class="group flex items-center gap-4 p-3 rounded-xl hover:bg-teal-50 transition-colors"
                            >
                                <span class="flex-shrink-0 w-8 h-8 rounded-lg bg-slate-100 group-hover:bg-teal-100 flex items-center justify-center text-xs font-bold text-slate-500 group-hover:text-teal-600 transition-colors">0{{ index + 1 }}</span>
                                <span class="text-sm font-bold text-slate-700 group-hover:text-slate-950 transition-colors">{{ item.label }}</span>
                            </a>
                        </nav>
                    </div>
                </aside>

                <div class="lg:col-span-8 space-y-12">
                     <article
                         v-for="(item, index) in sections"
                         :id="item.id"
                         :key="item.id"
                         class="bg-white p-8 md:p-12 rounded-[2.5rem] border border-slate-200 shadow-sm relative overflow-hidden group"
                     >
                         <div class="absolute -right-6 -top-6 text-[8rem] font-bold text-slate-50 opacity-40 select-none pointer-events-none group-hover:text-teal-50 group-hover:scale-110 transition-transform duration-700">
                            0{{ index + 1 }}
                         </div>
                         
                         <div class="relative z-10">
                             <h2 class="text-3xl sm:text-4xl font-extrabold tracking-tighter text-slate-900 mb-6">{{ item.title }}</h2>
                             <div class="space-y-6">
                                 <p
                                     v-for="(paragraph, i) in item.content"
                                     :key="i"
                                     class="text-lg leading-relaxed text-slate-600 font-medium"
                                 >
                                     {{ paragraph }}
                                 </p>
                             </div>
                         </div>
                     </article>

                     <div class="mt-8 flex justify-end">
                          <Link
                             :href="route('site.contact')"
                             class="inline-flex h-12 items-center justify-center rounded-2xl border-2 border-slate-200 bg-white px-8 text-[11px] font-bold uppercase tracking-[0.2em] text-slate-600 transition-all hover:bg-slate-100"
                         >
                             Quero ver versões velhas do termo
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
html {
    scroll-behavior: smooth;
}
</style>
