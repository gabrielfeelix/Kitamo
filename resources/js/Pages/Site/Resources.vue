<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';
import MotionSection from '@/Components/site/MotionSection.vue';
import { resourceCards } from '@/types/site';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const selectedCategory = ref<'Todos' | string>('Todos');

const categories = computed(() => ['Todos', ...new Set(resourceCards.map((item) => item.category))]);

const filteredCards = computed(() => {
    if (selectedCategory.value === 'Todos') return resourceCards;
    return resourceCards.filter((item) => item.category === selectedCategory.value);
});

const editorialTimeline = [
    {
        year: '2026',
        title: 'Série: Projeção na Prática',
        description: 'Guias curtos focados no que importa. Risco de saldo, rotina rápida e decisão suja, mas segura.',
    },
    {
        year: '2026',
        title: 'Playbooks: Como a galera joga',
        description: 'Como os autônomos se defendem, como solteiros poupam, como casais param de brigar por extrato.',
    },
    {
        year: '2026',
        title: 'A Nova Newsletter',
        description: 'Esqueça os textões chatos. Pílulas quinzenais de controle visceral pra manter a roda girando limpa.',
    },
];

const visuals = [
    'https://images.pexels.com/photos/3183150/pexels-photo-3183150.jpeg?auto=compress&cs=tinysrgb&w=1200',
    'https://images.pexels.com/photos/3184338/pexels-photo-3184338.jpeg?auto=compress&cs=tinysrgb&w=1200',
    'https://images.pexels.com/photos/3184418/pexels-photo-3184418.jpeg?auto=compress&cs=tinysrgb&w=1200',
    'https://images.pexels.com/photos/669615/pexels-photo-669615.jpeg?auto=compress&cs=tinysrgb&w=1200',
    'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=1200',
    'https://images.pexels.com/photos/1181690/pexels-photo-1181690.jpeg?auto=compress&cs=tinysrgb&w=1200',
];

const socialLinks = [
    { label: 'Instagram', note: 'Em Breve... Construindo' },
    { label: 'LinkedIn', note: 'Em Breve... Bastidores da Equipe' },
    { label: 'YouTube', note: 'Em Breve... Tutorial e Papo Reto' },
];
</script>

<template>
    <Head title="Guias e Radar | Kitamo">
        <meta name="description" content="Conteúdo pra usar na prática: Playbooks reais e linha editorial pra não quebrar a conta." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <!-- Hero Section -->
        <MotionSection class="relative min-h-[50vh] w-full overflow-hidden bg-stone-50 text-stone-900 flex flex-col justify-center pt-32 pb-20 border-b border-stone-200">
             <div class="absolute inset-0 opacity-[0.4] mix-blend-multiply pointer-events-none" style="background-image: url('data:image/svg+xml,%3Csvg viewBox=%220 0 200 200%22 xmlns=%22http://www.w3.org/2000/svg%22%3E%3Cfilter id=%22noiseFilter%22%3E%3CfeTurbulence type=%22fractalNoise%22 baseFrequency=%220.8%22 numOctaves=%224%22 stitchTiles=%22stitch%22/%3E%3C/filter%3E%3Crect width=%22100%25%22 height=%22100%25%22 filter=%22url(%23noiseFilter)%22/%3E%3C/svg%3E');"></div>
            
             <div class="pointer-events-none absolute bottom-0 right-0 w-[500px] h-[500px] bg-stone-200/50 blur-[130px] rounded-full mix-blend-multiply opacity-50"></div>
             
             <div class="relative z-10 mx-auto w-full max-w-[1440px] px-6 md:px-12 grid lg:grid-cols-12 gap-12 items-center">
                 <div class="lg:col-span-7">
                     <p class="inline-flex items-center space-x-2 text-[11px] font-bold uppercase tracking-[0.2em] text-stone-500 mb-6 drop-shadow-sm bg-white px-4 py-2 rounded-full border border-stone-200">Editorial</p>
                     <h1 class="text-5xl sm:text-6xl md:text-[5rem] leading-[0.95] tracking-tighter text-stone-900 font-extrabold max-w-4xl">
                         Conteúdo que<br>
                         <span class="text-stone-600 font-serif italic pr-2">faz diferença.</span>
                     </h1>
                     <p class="mt-8 text-xl leading-relaxed text-stone-600 font-medium max-w-2xl text-left">
                         Menos teoria barata de "guarde no porquinho" e mais playbook no estilo trincheira pra manter a conta sempre no azul.
                     </p>
                     
                     <div class="mt-10 flex gap-4">
                          <Link
                             :href="route('site.contact')"
                             class="inline-flex h-12 w-auto items-center justify-center rounded-2xl bg-stone-900 px-8 text-[12px] font-extrabold uppercase tracking-[0.15em] text-white transition-all hover:bg-stone-800 hover:scale-105 shadow-xl"
                         >
                             Assinar a Newsletter
                         </Link>
                         <Link
                             :href="route('site.product')"
                             class="inline-flex h-12 items-center justify-center rounded-2xl border border-stone-300 bg-white/50 backdrop-blur-sm px-8 text-[12px] font-extrabold uppercase tracking-[0.15em] text-stone-700 transition-all hover:bg-white hover:border-stone-400 hover:scale-105 hidden sm:inline-flex"
                         >
                             Ir pro App
                         </Link>
                     </div>
                 </div>

                 <div class="lg:col-span-5 relative group hidden lg:block">
                     <div class="absolute inset-0 bg-stone-200 blur-2xl rounded-[2rem] transform group-hover:scale-105 transition-transform duration-700 mix-blend-multiply"></div>
                     <img
                         src="https://images.pexels.com/photos/3184292/pexels-photo-3184292.jpeg?auto=compress&cs=tinysrgb&w=1400"
                         alt="Nossas publicações e time editorial"
                         class="relative h-[300px] sm:h-[400px] w-full object-cover rounded-[2rem] border border-stone-200 shadow-xl filter sepia-[0.3] contrast-125 saturate-50 hover:saturate-100 transition-all duration-700 hover:sepia-0"
                         loading="lazy"
                     />
                 </div>
             </div>
        </MotionSection>

        <!-- Dynamic Filter and Catalog -->
        <MotionSection class="bg-gray-50 py-24 pb-32">
            <div class="mx-auto w-full max-w-[1440px] px-6 md:px-12 grid gap-16 lg:grid-cols-12">
                <aside class="lg:col-span-4 lg:sticky lg:top-32 h-fit">
                    <p class="text-[11px] font-bold uppercase tracking-[0.2em] text-slate-400 mb-6 drop-shadow-sm bg-slate-100 px-4 py-2 rounded-full border border-slate-200 inline-block">Navegue pelas rotas</p>
                    <h2 class="text-4xl sm:text-5xl font-extrabold tracking-tighter text-slate-900 leading-[1.05]">
                        O que você <span class="text-teal-500 font-serif italic">precisa hoje?</span>
                    </h2>
                    
                    <div class="mt-10 flex flex-wrap gap-3">
                         <button
                             v-for="category in categories"
                             :key="category"
                             type="button"
                             class="inline-flex h-12 items-center justify-center rounded-full border-2 px-6 text-[12px] font-extrabold uppercase tracking-[0.15em] transition-all hover:scale-105 active:scale-95"
                             :class="selectedCategory === category ? 'border-teal-500 bg-teal-500 text-slate-950 shadow-[0_0_15px_theme(colors.teal.500/30)]' : 'border-slate-200 bg-white text-slate-600 hover:border-slate-300 hover:bg-slate-50'"
                             @click="selectedCategory = category"
                         >
                             {{ category }}
                         </button>
                    </div>

                    <div class="mt-16 bg-slate-950 p-8 rounded-[2rem] text-white overflow-hidden relative group">
                        <div class="absolute -right-20 -top-20 w-[150%] h-[150%] bg-[linear-gradient(145deg,rgba(20,184,166,0.3),transparent)] blur-xl group-hover:rotate-12 transition-transform duration-700"></div>
                        <h3 class="text-2xl font-extrabold text-white mb-2 relative z-10">Agenda Editorial</h3>
                        <div class="space-y-6 mt-8 relative z-10 border-l border-white/10 pl-6">
                            <div v-for="item in editorialTimeline" :key="item.title" class="relative group/timeline">
                                <div class="absolute -left-7 top-1 h-3 w-3 rounded-full bg-teal-500 shadow-[0_0_10px_theme(colors.teal.500/50)] group-hover/timeline:scale-150 transition-transform"></div>
                                <p class="text-[10px] font-bold uppercase tracking-[0.2em] text-teal-400">{{ item.year }}</p>
                                <p class="text-lg font-bold text-white mt-1">{{ item.title }}</p>
                                <p class="text-sm font-medium text-slate-400 leading-relaxed mt-1">{{ item.description }}</p>
                            </div>
                        </div>
                    </div>
                </aside>

                <div class="lg:col-span-8 flex flex-col gap-6">
                     <article
                         v-for="(card, idx) in filteredCards"
                         :key="card.title"
                         class="bg-white rounded-[2rem] border border-slate-200 p-4 shadow-sm hover:shadow-xl hover:border-teal-300 transition-all duration-300 group grid md:grid-cols-[200px_minmax(0,1fr)] gap-6"
                     >
                         <div class="relative w-full aspect-video md:aspect-square overflow-hidden rounded-[1.5rem] bg-slate-100">
                             <img
                                 :src="visuals[idx % visuals.length]"
                                 :alt="card.title"
                                 class="w-full h-full object-cover filter grayscale group-hover:grayscale-0 group-hover:scale-110 transition-all duration-700"
                                 loading="lazy"
                             />
                             <div class="absolute top-2 left-2 bg-slate-950/80 backdrop-blur px-3 py-1 rounded-full text-[10px] font-extrabold uppercase tracking-[0.2em] text-emerald-400">
                                 {{ card.readTime }}
                             </div>
                         </div>

                         <div class="flex flex-col justify-center py-2 md:pr-4">
                             <p class="text-[10px] font-bold uppercase tracking-[0.2em] text-teal-600 mb-2">{{ card.category }}</p>
                             <h3 class="text-2xl font-extrabold text-slate-900 leading-tight mb-3 group-hover:text-teal-600 transition-colors">{{ card.title }}</h3>
                             <p class="text-base text-slate-600 leading-relaxed font-medium mb-6 line-clamp-3">{{ card.excerpt }}</p>
                             
                             <div class="mt-auto flex items-center gap-4">
                                  <button
                                     type="button"
                                     class="inline-flex h-10 items-center justify-center rounded-2xl bg-slate-100 px-6 text-[11px] font-extrabold uppercase tracking-[0.15em] text-slate-600 transition-all hover:bg-slate-950 hover:text-white"
                                 >
                                     Ler Material
                                 </button>
                                 <span class="text-[10px] font-bold uppercase tracking-[0.15em] text-slate-400 bg-slate-50 px-3 py-1 rounded-full border border-slate-100">Cozinhando...</span>
                             </div>
                         </div>
                     </article>

                     <div v-if="filteredCards.length === 0" class="text-center py-20">
                         <h3 class="text-2xl font-bold text-slate-800">Tudo vazio por aqui.</h3>
                         <p class="text-slate-500 mt-2">Nenhum artigo encontrado nessa categoria. Escolha outra ali em cima.</p>
                     </div>
                </div>
            </div>
        </MotionSection>

        <!-- Social Community Footer CTA -->
        <MotionSection class="bg-white relative overflow-hidden border-t border-slate-200">
             <div class="mx-auto w-full max-w-[1440px] px-6 md:px-12 py-24">
                 <div class="grid lg:grid-cols-2 gap-16 items-center">
                     <div>
                         <p class="inline-flex items-center space-x-2 text-[11px] font-bold uppercase tracking-[0.2em] text-teal-600 mb-6 drop-shadow-sm bg-teal-50 px-4 py-2 rounded-full border border-teal-200">Galera da Linha de Frente</p>
                         <h2 class="text-4xl sm:text-5xl font-extrabold tracking-tighter text-slate-900 leading-[1.05]">
                              Acompanhe o <span class="text-transparent bg-clip-text bg-gradient-to-r from-teal-500 to-green-600 font-serif italic pr-2">que tá rolando.</span>
                         </h2>
                         <p class="mt-6 text-xl leading-relaxed text-slate-500 font-medium">
                              Compartilhamos as pancadas, os bastidores, dicas brabas do app e o suor que é rodar um produto focado na galera. Sem palestrante motivacional ensinando a ficar rico.
                         </p>

                         <div class="mt-12 grid sm:grid-cols-3 gap-4">
                              <div v-for="social in socialLinks" :key="social.label" class="bg-slate-50 border border-slate-100 p-6 rounded-2xl hover:bg-slate-100 hover:border-slate-200 transition-colors w-full group">
                                   <p class="text-[12px] font-extrabold uppercase tracking-[0.2em] text-slate-900 group-hover:text-teal-600 transition-colors">{{ social.label }}</p>
                                   <p class="mt-2 text-[10px] font-bold uppercase tracking-[0.15em] text-slate-400 line-clamp-2">{{ social.note }}</p>
                              </div>
                         </div>
                     </div>

                     <div class="bg-slate-950 rounded-[2.5rem] p-10 md:p-14 text-white hover:shadow-2xl transition-all duration-700 group relative overflow-hidden">
                          <div class="absolute inset-0 opacity-[0.05] mix-blend-overlay pointer-events-none" style="background-image: url('data:image/svg+xml,%3Csvg viewBox=%220 0 200 200%22 xmlns=%22http://www.w3.org/2000/svg%22%3E%3Cfilter id=%22noiseFilter%22%3E%3CfeTurbulence type=%22fractalNoise%22 baseFrequency=%220.8%22 numOctaves=%224%22 stitchTiles=%22stitch%22/%3E%3C/filter%3E%3Crect width=%22100%25%22 height=%22100%25%22 filter=%22url(%23noiseFilter)%22/%3E%3C/svg%3E');"></div>
                          <div class="absolute -right-20 -bottom-20 w-[150%] h-[150%] bg-[linear-gradient(145deg,rgba(20,184,166,0.3),transparent)] blur-3xl group-hover:rotate-12 transition-transform duration-1000"></div>
                          
                          <div class="relative z-10 flex flex-col h-full">
                              <p class="inline-flex w-fit items-center space-x-2 text-[10px] font-bold uppercase tracking-[0.2em] text-teal-400 mb-6 px-3 py-1.5 rounded-lg border border-teal-500/20 bg-teal-500/10 backdrop-blur-sm shadow-[0_0_15px_theme(colors.teal.500/20)]">Material Gratuito</p>
                              <h3 class="text-3xl font-extrabold text-white leading-tight">Baixe o Playbook de 30 dias<br><span class="text-teal-400 font-serif italic">para sair do vermelho.</span></h3>
                              <p class="text-slate-400 font-medium leading-relaxed mt-4 mb-8">
                                  Um guia prático e direto ao ponto que ensina o exato método para organizar sua vida financeira, blindar seu orçamento e estancar qualquer furo — em 4 etapas aplicáveis. Receba grátis no seu e-mail.
                              </p>
                              <div class="flex mt-auto">
                                   <!-- Substituted Link for a fake form button -->
                                   <div class="relative w-full">
                                       <input type="email" placeholder="Seu melhor e-mail..." class="w-full h-14 bg-white/5 border border-white/10 rounded-2xl px-5 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-teal-500 focus:ring-1 focus:ring-teal-500 transition-all font-medium pr-32" />
                                       <button
                                          type="button"
                                          class="absolute right-1 top-1 bottom-1 inline-flex items-center justify-center rounded-xl bg-teal-500 px-6 text-[11px] font-extrabold uppercase tracking-[0.15em] text-slate-950 transition-[transform,background-color] hover:bg-teal-400 hover:scale-105 shadow-[0_0_20px_theme(colors.teal.500/30)]"
                                      >
                                          Baixar
                                      </button>
                                   </div>
                              </div>
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
html {
    scroll-behavior: smooth;
}
</style>
