<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';
import MotionSection from '@/Components/site/MotionSection.vue';

const sections = [
    {
        id: 'coleta',
        label: 'O que entra e sai',
        title: '1. O que coletamos (e por quê)',
        content: [
            'A gente só pede o que é estritamente necessário pra fazer o Kitamo rodar liso pra você: email pra login, dados de conta pra você se organizar, e métricas anônimas de erro pra arrumarmos bugs.',
            'Não somos corretores de dados. O Kitamo ganha dinheiro com a assinatura que você paga, não vendendo sua vida financeira pra fazer anúncio. Simples assim.',
        ],
    },
    {
        id: 'protecao',
        label: 'A tranca do cofre',
        title: '2. Como a gente protege tudo',
        content: [
            'Primeira regra: o Kitamo não espia seu banco. Não ligamos direto na sua conta bancária sem você querer (Open Finance? Só se um dia a gente fizer de um jeito muito transparente). A gente acredita em controle manual, porque o humano no volante é mais confiável do que um robô dedurando suas compras.',
            'Embaixo do capô, tudo que trafega pra gente tá em túnel fechado (TLS 1.3) e tudo que é salvo no banco de dados tá blindado com criptografia pesada (AES-256).',
        ],
    },
    {
        id: 'compartilhamento',
        label: 'Com quem dividimos',
        title: '3. Quem vê seus dados?',
        content: [
            'Basicamente: nós e as máquinas que mantêm o site no ar (servidores, envio de email, gateway de pagamento). Ninguém mais.',
            'Esses parceiros técnicos assinam contratos monstruosos e não podem usar seus dados pra absolutamente nada além de fazer o serviço que a gente contratou.',
        ],
    },
    {
        id: 'direitos',
        label: 'A lei é sua',
        title: '4. Seus Direitos (LGPD sem juridiquês)',
        content: [
            'A LGPD diz que a bola é sua. Isso significa que você bate na nossa porta e pede pra ver o que temos sobre você, corrigir besteiras, exportar tudo pra um Excel ou mandar a gente deletar sua conta inteira da face da Terra.',
            'Pediu a exclusão no aplicativo? A gente roda um script e aterra seus dados. Não tem pegadinha, não tem "reter por 5 anos pra fins publicitários".',
        ],
    },
    {
        id: 'contato',
        label: 'Dúvidas e Broncas',
        title: '5. Fale com a chefia (DPO)',
        content: [
            'Deu alguma zica ou só quer exercer um direito da LGPD? Você tem canal verde.',
            'Manda um chamego lá na página de contato. Assuntos de dados têm "SLA VIP" (ou seja, a gente para o que tá fazendo pra te responder rápido).',
        ],
    },
];

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();
</script>

<template>
    <Head title="Privacidade | Kitamo">
        <meta name="description" content="Sua vida não é mercadoria. Como tratamos seus dados limpo e sem enrolação." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <!-- Hero Section -->
        <MotionSection class="relative min-h-[50vh] w-full overflow-hidden bg-slate-50 text-slate-900 flex flex-col justify-center pt-32 pb-20 border-b border-slate-200">
            <div class="absolute inset-0 opacity-[0.4] mix-blend-multiply pointer-events-none" style="background-image: url('data:image/svg+xml,%3Csvg viewBox=%220 0 200 200%22 xmlns=%22http://www.w3.org/2000/svg%22%3E%3Cfilter id=%22noiseFilter%22%3E%3CfeTurbulence type=%22fractalNoise%22 baseFrequency=%220.8%22 numOctaves=%224%22 stitchTiles=%22stitch%22/%3E%3C/filter%3E%3Crect width=%22100%25%22 height=%22100%25%22 filter=%22url(%23noiseFilter)%22/%3E%3C/svg%3E');"></div>
            
            <div class="pointer-events-none absolute bottom-0 left-1/4 w-[400px] h-[400px] bg-teal-500/10 blur-[130px] rounded-full mix-blend-multiply opacity-60"></div>
            
            <div class="relative z-10 mx-auto w-full max-w-[1440px] px-6 md:px-12 grid lg:grid-cols-12 gap-12 items-center">
                <div class="lg:col-span-7">
                    <p class="inline-flex items-center space-x-2 text-[11px] font-bold uppercase tracking-[0.2em] text-teal-600 mb-6 drop-shadow-sm bg-teal-100 px-4 py-2 rounded-full border border-teal-200 shadow-sm">Seus Dados, Suas Regras</p>
                    <h1 class="text-5xl sm:text-6xl md:text-[5rem] leading-[0.95] tracking-tighter text-slate-900 font-extrabold drop-shadow-sm">
                        O papo reto da <br>
                        <span class="text-teal-600 font-serif italic pr-2">Privacidade.</span>
                    </h1>
                    <p class="mt-8 text-xl leading-relaxed text-slate-600 font-medium max-w-2xl text-left">
                        Nada daquelas 40 páginas de juridiquês que ninguém lê pra esconder roubo de dados. Aqui a gente explica rápido o que entra e o que sai.
                    </p>
                    
                    <div class="mt-8 flex flex-wrap items-center gap-4 text-xs font-bold uppercase tracking-[0.15em] text-slate-500">
                        <span class="bg-white border border-slate-200 px-3 py-1 rounded shadow-sm">Versão 1.1</span>
                        <span>Atualizado em: Fev/2026</span>
                    </div>

                    <div class="mt-10 flex gap-4">
                        <Link
                            :href="route('site.contact')"
                            class="inline-flex h-12 items-center justify-center rounded-2xl bg-teal-500 px-8 text-[12px] font-extrabold uppercase tracking-[0.15em] text-slate-950 transition-all hover:bg-teal-400 hover:scale-105 shadow-[0_0_20px_theme(colors.teal.500/30)]"
                        >
                            Chamar o DPO
                        </Link>
                    </div>
                </div>

                <div class="lg:col-span-5 hidden lg:block relative group p-6">
                    <div class="absolute inset-0 bg-teal-500/10 blur-3xl rounded-[2rem] transform group-hover:scale-105 transition-transform duration-700"></div>
                     <img
                         src="https://images.pexels.com/photos/3184465/pexels-photo-3184465.jpeg?auto=compress&cs=tinysrgb&w=1200"
                         alt="Documentos limpos"
                         class="relative h-[350px] w-full object-cover rounded-[2.5rem] border border-white/10 shadow-2xl filter grayscale hover:grayscale-0 hover:saturate-150 transition-all duration-700"
                         loading="lazy"
                     />
                </div>
            </div>
        </MotionSection>

        <!-- Document Body -->
        <MotionSection class="bg-slate-50 py-24 pb-32">
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
