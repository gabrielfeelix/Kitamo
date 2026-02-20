<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import { onMounted, onUnmounted, ref } from 'vue';
import SiteLayout from '@/Layouts/SiteLayout.vue';
import PricingBlock from '@/Components/site/PricingBlock.vue';
import FaqBlock from '@/Components/site/FaqBlock.vue';
import { institutionalFaq, pricingPlans } from '@/types/site';

const props = defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const primaryHref = props.canRegister ? '/register' : '/login';

const activeFeatureIndex = ref(0);
let observer: IntersectionObserver | null = null;

onMounted(() => {
    if ('IntersectionObserver' in window) {
        observer = new IntersectionObserver(
            (entries) => {
                entries.forEach((entry) => {
                    if (entry.isIntersecting) {
                        const index = entry.target.getAttribute('data-index');
                        if (index !== null) activeFeatureIndex.value = parseInt(index, 10);
                    }
                });
            },
            { rootMargin: '-40% 0px -40% 0px' }
        );
        document.querySelectorAll('.feature-text').forEach((el) => observer?.observe(el));
    }
});

onUnmounted(() => {
    if (observer) observer.disconnect();
});
</script>

<template>
    <Head title="Kitamo | O sistema financeiro de quem pensa no futuro">
        <meta name="description" content="Saia do controle financeiro focado no passado. A Kitamo projeta seu saldo, antecipa riscos e dá clareza total das suas decisões." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <!-- HERO AWWARDS STYLE -->
        <section class="relative mx-auto w-full max-w-[1400px] overflow-hidden px-6 pt-16 md:pt-32 pb-24 md:pb-40">
            <div class="grid lg:grid-cols-12 gap-12 items-center">
                <div class="lg:col-span-6 z-10 relative">
                    <p class="text-[10px] md:text-[11px] font-bold uppercase tracking-[0.25em] text-slate-500 mb-6">
                        Personal Finance Intelligence
                    </p>
                    <h1 class="text-[12vw] sm:text-[6rem] lg:text-[7.5rem] leading-[0.88] tracking-[-0.04em] text-slate-950 font-medium">
                        Não olhe pra trás. <br/> Projete o <span class="hero-accent italic font-serif text-emerald-600">dia 30.</span>
                    </h1>
                    <p class="mt-8 max-w-xl text-lg md:text-xl font-medium leading-relaxed text-slate-600">
                        Por que olhar para gastos antigos se os boletos de amanhã continuam chegando? O Kitamo antecipa o seu fluxo de caixa para você agir antes da dor.
                    </p>
                    <div class="mt-12 flex flex-wrap items-center gap-4">
                        <Link :href="primaryHref" class="awwwards-cta">
                            Começar grátis
                        </Link>
                        <span class="text-[11px] uppercase tracking-[0.1em] text-slate-400 font-bold ml-4">Leitura expressa do mês</span>
                    </div>
                </div>

                <!-- Abstract App Explosion -->
                <div class="lg:col-span-6 relative h-[500px] hidden md:block z-0">
                    <div class="absolute top-10 right-0 w-[420px] h-[480px] bg-slate-950 rounded-[2.5rem] p-6 shadow-[0_40px_80px_rgba(2,6,23,0.15)] transform rotate-2 hover:rotate-0 transition-transform duration-700">
                        <div class="h-full border border-white/10 rounded-[1.5rem] bg-slate-900/50 p-6 flex flex-col justify-between overflow-hidden relative">
                            <div class="absolute inset-0 bg-gradient-to-br from-emerald-500/10 to-transparent"></div>
                            <div>
                                <h3 class="text-white/40 text-[10px] uppercase font-bold tracking-[0.2em] mb-2">Saldo Projetado</h3>
                                <p class="text-[3.5rem] text-white tracking-tighter leading-none mb-6">R$ 5.420</p>
                                <div class="w-full h-[1px] bg-white/10 mb-6"></div>
                                <div class="space-y-4">
                                    <div class="flex items-center justify-between">
                                        <div class="w-40 h-3 bg-white/5 rounded-full"><div class="w-[70%] h-full bg-emerald-400 rounded-full"></div></div>
                                        <span class="text-white/60 text-xs font-medium">Estável</span>
                                    </div>
                                    <div class="flex items-center justify-between">
                                        <div class="w-40 h-3 bg-white/5 rounded-full"><div class="w-[30%] h-full bg-amber-400 rounded-full"></div></div>
                                        <span class="text-white/60 text-xs font-medium">Atenção</span>
                                    </div>
                                </div>
                            </div>
                            <div class="bg-white/10 backdrop-blur-md rounded-2xl p-4 border border-white/10">
                                <div class="flex items-center gap-3">
                                    <div class="w-10 h-10 rounded-full bg-red-500/20 text-red-400 flex items-center justify-center font-bold">!</div>
                                    <div>
                                        <p class="text-white text-sm font-semibold">Assinatura Anual</p>
                                        <p class="text-white/60 text-xs">Cobra em 3 dias</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Floating abstract widgets -->
                    <div class="absolute -left-12 top-40 bg-white p-5 rounded-2xl shadow-2xl border border-slate-100 transform -rotate-6 z-20">
                        <p class="text-[10px] text-slate-400 font-bold uppercase tracking-[0.2em] mb-1">Redução no mês</p>
                        <p class="text-3xl text-emerald-500 tracking-tighter">- R$ 340</p>
                    </div>
                </div>
            </div>
        </section>

        <!-- FULL BLEED DARK SECTION: THE PROJECTION -->
        <section class="bg-[#0f172a] text-white py-32 rounded-[3rem] mx-4 my-10 overflow-hidden relative">
            <div class="absolute top-0 right-0 w-[800px] h-[800px] bg-emerald-500/10 blur-[120px] rounded-full pointer-events-none -translate-y-1/2 translate-x-1/2"></div>
            
            <div class="max-w-[1300px] mx-auto px-6 relative z-10 text-center">
                <p class="text-emerald-400 text-[11px] font-bold uppercase tracking-[0.25em] mb-8">O Super-poder</p>
                <h2 class="text-5xl md:text-[6rem] leading-[0.9] tracking-[-0.04em] font-medium max-w-4xl mx-auto mb-10">
                    A primeira <span class="italic font-serif text-emerald-300">máquina do tempo</span> financeira que realmente funciona.
                </h2>
                <p class="text-slate-300 text-xl font-medium max-w-2xl mx-auto mb-16">
                    A maioria dos apps desenha gráficos coloridos do que você já gastou. O Kitamo desenha o que <u class="underline-offset-4 decoration-emerald-500 text-white">vai sobrar</u> no fim do mês.
                </p>
                
                <!-- Massive visual data representation -->
                <div class="w-full h-80 relative flex items-end justify-center gap-1 sm:gap-2 md:gap-4 px-2 sm:px-4 overflow-hidden">
                    <!-- Fake bars -->
                    <!-- Past -->
                    <div class="w-10 sm:w-16 md:w-24 h-[40%] bg-slate-800 rounded-t-lg sm:rounded-t-xl relative group"><span class="absolute -top-8 left-1/2 -translate-x-1/2 text-slate-400 text-[10px] sm:text-base font-bold opacity-0 group-hover:opacity-100 hidden sm:block">Sem 1</span></div>
                    <div class="w-10 sm:w-16 md:w-24 h-[55%] bg-slate-800 rounded-t-lg sm:rounded-t-xl relative group"><span class="absolute -top-8 left-1/2 -translate-x-1/2 text-slate-400 text-[10px] sm:text-base font-bold opacity-0 group-hover:opacity-100 hidden sm:block">Sem 2</span></div>
                    <!-- Present -->
                    <div class="w-10 sm:w-16 md:w-24 h-[65%] bg-slate-500 rounded-t-lg sm:rounded-t-xl relative group"><span class="absolute -top-8 left-1/2 -translate-x-1/2 text-white text-[10px] sm:text-base font-bold opacity-0 group-hover:opacity-100 hidden sm:block">Hoje</span>
                        <div class="absolute bottom-0 left-0 w-full h-[6px] bg-white rounded-t-xl"></div>
                    </div>
                    <!-- Future Projection -->
                    <div class="w-10 sm:w-16 md:w-24 h-[80%] bg-emerald-900/40 border border-emerald-500/30 rounded-t-lg sm:rounded-t-[1rem] border-dashed border-b-0 relative group"><span class="absolute -top-8 left-1/2 -translate-x-1/2 text-emerald-400 text-[10px] sm:text-base font-bold hidden sm:block">+20%</span></div>
                    <div class="w-10 sm:w-16 md:w-24 h-[95%] bg-emerald-900/40 border border-emerald-500/30 rounded-t-lg sm:rounded-t-[1rem] border-dashed border-b-0 relative group">
                        <div class="absolute -top-14 left-1/2 -translate-x-1/2 bg-emerald-400 text-slate-900 px-4 py-2 rounded-full font-bold text-sm whitespace-nowrap shadow-[0_0_30px_rgba(52,211,153,0.4)]">Meta do mês!</div>
                    </div>
                    
                    <div class="absolute bottom-0 left-0 w-full h-[1px] bg-slate-800"></div>
                </div>
            </div>
        </section>

        <!-- STICKY SCROLL STORYTELLING -->
        <section class="py-32 relative hidden md:block">
            <div class="max-w-[1300px] mx-auto px-6 grid grid-cols-12 gap-16">
                <!-- Text scrolling col -->
                <div class="col-span-12 md:col-span-5 pb-[50vh]">
                    <p class="text-[11px] font-bold uppercase tracking-[0.25em] text-slate-500 mb-20 sticky top-32">
                        Workflow de decisão
                    </p>
                    
                    <div class="space-y-[60vh]">
                        <div class="feature-text" data-index="0">
                            <h3 class="text-4xl md:text-5xl font-medium tracking-tight mb-6">Diagnóstico cirúrgico em 5 segundos.</h3>
                            <p class="text-slate-600 text-xl leading-relaxed">Você entra no app e não vê uma tela de configurações, vê a saúde do seu mês traduzida numa única métrica confiável.</p>
                        </div>
                        <div class="feature-text" data-index="1">
                            <h3 class="text-4xl md:text-5xl font-medium tracking-tight mb-6">Assinaturas sob vigilância.</h3>
                            <p class="text-slate-600 text-xl leading-relaxed">Aquela assinatura anual misteriosa? O Kitamo pega e joga na sua cara antes do cartão processar a compra.</p>
                        </div>
                        <div class="feature-text" data-index="2">
                            <h3 class="text-4xl md:text-5xl font-medium tracking-tight mb-6">Plano de ataque guiado.</h3>
                            <p class="text-slate-600 text-xl leading-relaxed">De nada servem gráficos lindos se você não sabe o que fazer. Entregamos a ação exata que você precisa tomar nesta semana para ficar verde no dia 30.</p>
                        </div>
                    </div>
                </div>

                <!-- Sticky Visuals Col -->
                <div class="col-span-12 md:col-span-7 h-screen sticky top-0 flex items-center justify-center">
                    <div class="w-full aspect-square md:aspect-[4/3] rounded-[3rem] bg-slate-100 flex items-center justify-center relative overflow-hidden transition-all duration-700">
                        <div class="absolute inset-0 transition-opacity duration-700 flex items-center justify-center" :class="activeFeatureIndex === 0 ? 'opacity-100' : 'opacity-0 scale-95'">
                            <!-- UI abstract 01 -->
                            <div class="bg-white p-8 rounded-3xl shadow-2xl w-3/4">
                                <div class="w-16 h-16 rounded-full bg-emerald-100 text-emerald-500 flex items-center justify-center text-2xl font-bold mb-6">OK</div>
                                <div class="w-full h-4 bg-slate-100 rounded-full mb-3"></div>
                                <div class="w-2/3 h-4 bg-slate-100 rounded-full mb-8"></div>
                                <div class="w-1/2 h-8 bg-emerald-500 rounded-full"></div>
                            </div>
                        </div>
                        <div class="absolute inset-0 transition-opacity duration-700 flex items-center justify-center" :class="activeFeatureIndex === 1 ? 'opacity-100' : 'opacity-0 scale-105'">
                            <!-- UI abstract 02 -->
                            <div class="bg-slate-900 p-8 rounded-3xl shadow-2xl w-[85%] border-2 border-red-500/20 transform rotate-2">
                                <div class="text-red-400 font-bold uppercase tracking-widest text-xs mb-4">Alerta de vazamento</div>
                                <div class="flex items-center gap-4 bg-white/5 p-4 rounded-xl">
                                    <div class="w-12 h-12 bg-white/10 rounded-full"></div>
                                    <div>
                                        <div class="w-24 h-3 bg-white/20 rounded-full mb-2"></div>
                                        <div class="w-16 h-3 bg-white/10 rounded-full"></div>
                                    </div>
                                    <div class="ml-auto text-white font-bold text-xl">R$99</div>
                                </div>
                            </div>
                        </div>
                        <div class="absolute inset-0 transition-opacity duration-700 flex items-center justify-center" :class="activeFeatureIndex === 2 ? 'opacity-100' : 'opacity-0 scale-95'">
                            <!-- UI abstract 03 -->
                            <div class="w-3/4 flex flex-col gap-4">
                                <div class="bg-white p-5 rounded-2xl shadow-xl border border-slate-100 flex items-center gap-4 transform -translate-x-8">
                                    <div class="w-6 h-6 rounded-full border-2 border-slate-300"></div>
                                    <div class="w-1/2 h-3 bg-slate-200 rounded-full"></div>
                                </div>
                                <div class="bg-white p-5 rounded-2xl shadow-xl border-l-4 border-emerald-500 flex items-center gap-4 z-10">
                                    <div class="w-6 h-6 rounded-full bg-emerald-500 flex items-center justify-center text-white text-xs">✓</div>
                                    <div class="w-2/3 h-3 bg-slate-800 rounded-full"></div>
                                </div>
                                <div class="bg-white p-5 rounded-2xl shadow-xl border border-slate-100 flex items-center gap-4 transform translate-x-8 opacity-50">
                                    <div class="w-6 h-6 rounded-full border-2 border-slate-300"></div>
                                    <div class="w-1/3 h-3 bg-slate-200 rounded-full"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Z-PATTERN FOR MOBILE (Fallback) -->
        <section class="py-16 md:hidden px-6 space-y-24">
            <div class="space-y-6">
                 <div class="w-full aspect-square rounded-3xl bg-slate-100 flex items-center justify-center p-6">
                     <div class="bg-white p-6 rounded-2xl shadow-xl w-full">
                         <div class="w-12 h-12 rounded-full bg-emerald-100 mb-4"></div>
                         <div class="w-full h-3 bg-slate-100 rounded-full mb-2"></div>
                         <div class="w-2/3 h-3 bg-slate-100 rounded-full"></div>
                     </div>
                 </div>
                 <h3 class="text-3xl font-medium tracking-tight">Diagnóstico veloz.</h3>
                 <p class="text-slate-600 text-lg">Direto ao ponto, sem planilhas infinitas.</p>
            </div>
            <div class="space-y-6">
                 <div class="w-full aspect-square rounded-3xl bg-slate-900 border border-slate-800 flex items-center justify-center p-6">
                      <div class="bg-red-500/10 p-6 rounded-2xl border border-red-500/20 w-full flex items-center gap-4">
                          <div class="w-12 h-12 rounded-full bg-red-500/20"></div>
                          <div class="flex-1 space-y-2">
                              <div class="w-full h-3 bg-white/20 rounded-full"></div>
                              <div class="w-1/2 h-3 bg-white/10 rounded-full"></div>
                          </div>
                      </div>
                 </div>
                 <h3 class="text-3xl font-medium tracking-tight">Assinaturas sob vigilância.</h3>
                 <p class="text-slate-600 text-lg">Corte os vampiros do seu orçamento antes que o mês vire.</p>
            </div>
        </section>


        <!-- PRICING Z-PATTERN FULL BLEED INTEGRATION -->
        <section class="bg-white py-32 rounded-t-[3rem] border-t border-slate-200">
             <div class="max-w-[1300px] mx-auto px-6">
                 <div class="text-center mb-16">
                     <p class="text-[11px] font-bold uppercase tracking-[0.25em] text-slate-500 mb-4">Escolha a sua profundidade</p>
                     <h2 class="text-5xl font-medium tracking-tight text-slate-950">Transparência como regra.</h2>
                 </div>
                 
                 <!-- We use the PricingBlock but wrapping it beautifully -->
                 <div class="relative z-10">
                     <PricingBlock :plans="pricingPlans" :can-register="canRegister" />
                 </div>
             </div>
        </section>

        <!-- BRUTALIST CTA -->
        <section class="bg-[#10b981] py-40 text-slate-950 text-center relative overflow-hidden">
             <div class="absolute inset-0 bg-[url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAiIGhlaWdodD0iMjAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PGNpcmNsZSBjeD0iMiIgY3k9IjIiIHI9IjEiIGZpbGw9IiMwNDJmMmUiIGZpbGwtb3BhY2l0eT0iMC4xNSIvPjwvc3ZnPg==')] opacity-40"></div>
             
             <div class="max-w-[1000px] mx-auto px-6 relative z-10 flex flex-col items-center">
                 <h2 class="text-[12vw] sm:text-[8rem] leading-[0.8] tracking-[-0.05em] font-medium mb-12 uppercase mix-blend-multiply">
                     Reassuma<br/> o <span class="text-white">comando.</span>
                 </h2>
                 <Link :href="primaryHref" class="bg-slate-950 text-white hover:bg-white hover:text-slate-950 px-10 py-6 rounded-full text-lg font-bold tracking-[0.15em] uppercase transition-all duration-300 shadow-[0_20px_40px_rgba(2,6,23,0.2)] hover:scale-105">
                     Criar conta gratuita
                 </Link>
                 <p class="mt-8 font-semibold text-slate-950/60 uppercase tracking-widest text-xs">Sem necessidade de cartão de crédito para iniciar.</p>
             </div>
        </section>

    </SiteLayout>
</template>

<style scoped>

.awwwards-cta {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    height: 56px;
    padding: 0 36px;
    border-radius: 9999px;
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: 0.2em;
    font-weight: 800;
    background: #020617;
    color: #fff;
    transition: all 400ms cubic-bezier(0.2, 0.8, 0.2, 1);
}

.awwwards-cta:hover {
    background: #10b981;
    color: #020617;
    box-shadow: 0 20px 40px -10px rgba(16, 185, 129, 0.4);
    transform: translateY(-2px);
}

</style>
