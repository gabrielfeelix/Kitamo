<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, Link } from '@inertiajs/vue3';
import MotionSection from '@/Components/site/MotionSection.vue';
import SectionShell from '@/Components/site/SectionShell.vue';
import SiteLayout from '@/Layouts/SiteLayout.vue';

const props = defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const scenarios = [
    {
        name: 'Controle básico',
        title: 'Organizar o mês sem sobrecarga',
        details: 'Você ganha leitura imediata do cenário e identifica os pontos críticos da semana.',
        bullets: ['Resumo diário direto', 'Risco de vencimento em destaque', 'Categorias essenciais'],
    },
    {
        name: 'Ajuste preventivo',
        title: 'Corrigir rota antes do fechamento',
        details: 'A projeção mostra impacto de decisões e orienta cortes com menor atrito.',
        bullets: ['Simulação de despesas futuras', 'Alertas de pressão no saldo', 'Plano de ação semanal'],
    },
    {
        name: 'Planejamento avançado',
        title: 'Decidir crescimento com previsibilidade',
        details: 'Cenários ajudam a equilibrar metas, compromissos e margem para o próximo ciclo.',
        bullets: ['Mapa de prioridades', 'Rotina de revisão contínua', 'Maior previsibilidade de caixa'],
    },
];

const activeScenarioIndex = ref(0);
const activeScenario = computed(() => scenarios[activeScenarioIndex.value]);
</script>

<template>
    <Head title="Produto | Kitamo">
        <meta
            name="description"
            content="Conheça o produto Kitamo: módulos de leitura financeira, alertas, projeção e plano de ação semanal."
        />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        
        <!-- HERO FULL BLEED PRODUCT SHOT -->
        <section class="max-w-[1400px] mx-auto px-6 py-24 text-center">
            <h1 class="text-6xl md:text-[5rem] tracking-[-0.04em] font-medium leading-[0.9] mb-8">
                Fluxo de caixa guiado.<br/>
                <span class="text-emerald-500 italic font-serif">Ação clara.</span>
            </h1>
            <p class="text-xl text-slate-500 max-w-2xl mx-auto mb-16">O Kitamo transforma um amontoado de transações em uma linha direta de decisões de próxima semana.</p>
            
            <div class="relative w-full aspect-video max-h-[700px] rounded-[3rem] bg-[#020617] p-4 shadow-[0_40px_100px_rgba(2,6,23,0.3)] overflow-hidden border border-slate-800">
                <div class="absolute inset-0 bg-gradient-to-tr from-emerald-500/10 to-transparent"></div>
                <!-- Fake Dashboard Frame -->
                <div class="w-full h-full bg-slate-900 rounded-[2.5rem] border border-white/10 flex flex-col overflow-hidden relative z-10">
                    <div class="h-16 border-b border-white/5 flex items-center px-8 gap-4">
                        <div class="w-3 h-3 rounded-full bg-red-500"></div><div class="w-3 h-3 rounded-full bg-amber-500"></div><div class="w-3 h-3 rounded-full bg-emerald-500"></div>
                        <div class="w-64 h-8 bg-black/40 rounded-full mx-auto"></div>
                    </div>
                    <div class="flex-1 p-8 grid grid-cols-12 gap-6 relative overflow-hidden">
                        <div class="absolute -top-40 -right-40 w-96 h-96 bg-emerald-500/10 blur-[100px] rounded-full"></div>
                        
                        <!-- Left bar -->
                        <div class="col-span-3 space-y-4">
                            <div class="h-24 bg-white/5 rounded-2xl border border-white/5 p-4 flex flex-col justify-center">
                                <div class="w-20 h-3 bg-white/10 rounded-full mb-2"></div>
                                <div class="w-32 h-6 bg-white/20 rounded-full"></div>
                            </div>
                            <div class="h-48 bg-white/5 rounded-2xl border border-white/5 p-4 space-y-3">
                                <div class="w-full h-4 bg-white/5 rounded-full"></div>
                                <div class="w-[80%] h-4 bg-white/5 rounded-full"></div>
                                <div class="w-[90%] h-4 bg-white/5 rounded-full"></div>
                            </div>
                        </div>
                        
                        <!-- Main Content -->
                        <div class="col-span-9 flex flex-col gap-6">
                            <div class="h-40 bg-white/5 rounded-2xl border border-white/5 p-6 flex flex-col justify-between relative overflow-hidden">
                                <div class="absolute inset-0 bg-gradient-to-r from-emerald-500/10 to-transparent"></div>
                                <div class="w-32 h-4 bg-emerald-400/50 rounded-full mb-2 z-10"></div>
                                <div class="w-64 h-12 bg-white/20 rounded-full z-10"></div>
                            </div>
                            
                            <!-- Graph area -->
                            <div class="flex-1 bg-white/5 rounded-2xl border border-white/5 p-6 flex items-end gap-3">
                                <div class="w-full h-[30%] bg-emerald-500/30 rounded-t-xl"></div>
                                <div class="w-full h-[50%] bg-emerald-500/30 rounded-t-xl"></div>
                                <div class="w-full h-[40%] bg-emerald-500/30 rounded-t-xl"></div>
                                <div class="w-full h-[70%] bg-emerald-500/50 rounded-t-xl"></div>
                                <div class="w-full h-[60%] bg-emerald-500/50 rounded-t-xl opacity-50 border-t-2 border-dashed border-emerald-400"></div>
                                <div class="w-full h-[80%] bg-emerald-500/50 rounded-t-xl opacity-50 border-t-2 border-dashed border-emerald-400 relative">
                                    <div class="absolute -top-10 left-1/2 -translate-x-1/2 bg-white text-black px-3 py-1 text-xs font-bold rounded-full">Projeção</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="mt-8 flex items-center justify-center gap-6 text-sm font-bold text-slate-400 uppercase tracking-widest">
                <div class="flex items-center gap-2"><span class="w-2 h-2 rounded-full bg-emerald-400"></span> Projeção ao vivo</div>
                <div class="flex items-center gap-2"><span class="w-2 h-2 rounded-full bg-emerald-400"></span> Simulação de crédito</div>
            </div>
        </section>

        <!-- FLOATING PIE CHART / ASYMMETRIC GRID -->
        <section class="max-w-[1400px] mx-auto px-6 py-24">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-16 items-center">
                <!-- Visual Box -->
                <div class="w-full aspect-square md:aspect-auto md:h-[500px] bg-[#f6f6f4] rounded-[3rem] p-6 md:p-12 relative flex items-center justify-center border border-slate-200 overflow-hidden md:overflow-visible">
                    <div class="absolute inset-0 bg-[radial-gradient(circle_at_center,rgba(16,185,129,0.05)_0%,transparent_60%)]"></div>
                    
                    <div class="relative w-52 h-52 md:w-64 md:h-64">
                        <!-- Conic Gradient Pie Chart -->
                        <div class="w-full h-full rounded-full shadow-[0_20px_40px_rgba(0,0,0,0.05)] border-4 border-white" style="background: conic-gradient(#10b981 0% 45%, #f59e0b 45% 70%, #ef4444 70% 85%, #cbd5e1 85% 100%);"></div>
                        
                        <!-- Inner floating circle -->
                        <div class="absolute inset-0 m-auto w-32 h-32 md:w-40 md:h-40 bg-white rounded-full flex flex-col items-center justify-center shadow-inner">
                            <span class="text-slate-400 text-[10px] uppercase font-bold tracking-widest">Gasto Total</span>
                            <span class="text-2xl md:text-3xl font-medium tracking-tighter text-slate-900 mt-1">R$ 3.200</span>
                        </div>
                        
                        <!-- Floating Tags Component (Copilot style) -->
                        <div class="absolute -right-6 md:-right-12 top-6 md:top-10 bg-white p-2 md:p-3 rounded-2xl shadow-xl flex items-center gap-2 md:gap-3 border border-slate-100 z-10">
                            <div class="w-2 md:w-3 h-2 md:h-3 rounded-full bg-emerald-500"></div>
                            <div class="text-xs md:text-sm font-bold whitespace-nowrap">Essenciais <span class="text-slate-400 font-normal ml-1 md:ml-2">45%</span></div>
                        </div>
                        <div class="absolute -left-6 md:-left-16 bottom-10 md:bottom-16 bg-white p-2 md:p-3 rounded-2xl shadow-xl flex items-center gap-2 md:gap-3 border border-slate-100 z-10">
                            <div class="w-2 md:w-3 h-2 md:h-3 rounded-full bg-amber-500"></div>
                            <div class="text-xs md:text-sm font-bold whitespace-nowrap">Estilo de vida <span class="text-slate-400 font-normal ml-1 md:ml-2">25%</span></div>
                        </div>
                    </div>
                </div>

                <!-- Content Box -->
                <div>
                    <h2 class="text-[11px] font-bold uppercase tracking-[0.25em] text-slate-500 mb-6">Categorização Automática</h2>
                    <h3 class="text-4xl md:text-5xl font-medium tracking-tight leading-[1.05] mb-8">Pare de catalogar pão de queijo. Deixe os algoritmos trabalharem.</h3>
                    <p class="text-lg text-slate-600 leading-relaxed mb-8">Nosso motor não apenas categoriza suas contas, mas aprende de qual padaria você compra para criar um mapa de calor invisível. Focar menos e descobrir mais.</p>
                    <ul class="space-y-4">
                        <li class="flex items-center gap-4 text-slate-900 font-bold">
                            <span class="w-6 h-6 rounded-full bg-emerald-100 text-emerald-600 flex items-center justify-center text-xs">✓</span> Agrupamento inteligente
                        </li>
                        <li class="flex items-center gap-4 text-slate-900 font-bold">
                            <span class="w-6 h-6 rounded-full bg-emerald-100 text-emerald-600 flex items-center justify-center text-xs">✓</span> Tags cruzadas de metas
                        </li>
                    </ul>
                </div>
            </div>
        </section>

        <!-- COPILOT SCENARIO SHIFT (Redesigned) -->
        <MotionSection class="bg-slate-900 text-white py-32 mt-20 rounded-[3rem] mx-4 overflow-hidden relative">
            <div class="absolute bottom-0 right-0 w-full h-[500px] bg-gradient-to-t from-emerald-900/30 to-transparent pointer-events-none"></div>

            <div class="max-w-[1300px] mx-auto px-6">
                <SectionShell
                    kicker="Contexto ao vivo"
                    title="Seu app muda de forma junto com a sua prioridade do mês."
                    description="O Kitamo entende que dia 5 (salário) e dia 28 (desespero) precisam de interfaces diferentes."
                />

                <div class="grid gap-12 lg:grid-cols-12 mt-16">
                    <!-- Scenario Tabs - Dark mode styled -->
                    <div class="space-y-3 lg:col-span-5 relative z-10">
                        <button
                            v-for="(scenario, index) in scenarios"
                            :key="scenario.name"
                            type="button"
                            class="w-full rounded-2xl border px-6 py-5 text-left transition-all duration-300"
                            :class="activeScenarioIndex === index ? 'border-emerald-500/50 bg-slate-800 shadow-[0_0_30px_rgba(16,185,129,0.1)]' : 'border-slate-800 bg-transparent text-slate-400 hover:bg-slate-800/50'"
                            :aria-pressed="activeScenarioIndex === index"
                            @click="activeScenarioIndex = index"
                        >
                            <p class="text-[10px] font-bold uppercase tracking-[0.2em]" :class="activeScenarioIndex === index ? 'text-emerald-400' : 'text-slate-500'">{{ scenario.name }}</p>
                            <p class="mt-2 text-xl font-medium tracking-tight" :class="activeScenarioIndex === index ? 'text-white' : 'text-slate-300'">{{ scenario.title }}</p>
                        </button>
                    </div>

                    <!-- Immersive Scenario Display -->
                    <div class="lg:col-span-7 h-[450px] relative mt-10 lg:mt-0 perspective-[1000px] z-10">
                        <Transition name="scenario-3d-fade" mode="out-in">
                            <div :key="activeScenario.name" class="w-full h-full bg-slate-800/80 backdrop-blur-xl border border-white/10 rounded-[2rem] p-10 flex flex-col justify-center">
                                <div class="w-16 h-1 bg-emerald-500 rounded-full mb-8"></div>
                                <h3 class="text-4xl md:text-5xl font-medium tracking-tight text-white leading-tight mb-6">{{ activeScenario.title }}</h3>
                                <p class="text-xl text-slate-300 leading-relaxed mb-10">{{ activeScenario.details }}</p>
                                <div class="grid grid-cols-1 md:grid-cols-3 gap-6 border-t border-slate-700/50 pt-8 mt-auto">
                                    <div v-for="bullet in activeScenario.bullets" :key="bullet" class="text-sm font-bold text-slate-400">
                                        {{ bullet }}
                                    </div>
                                </div>
                            </div>
                        </Transition>
                    </div>
                </div>
            </div>
        </MotionSection>

        <!-- CTA Final Simplificado e Reto -->
        <section class="py-32 text-center px-6">
            <h2 class="text-4xl font-medium tracking-tight mb-10">Pronto para visualizar o futuro?</h2>
            <Link :href="props.canRegister ? '/register' : '/login'" class="inline-flex h-16 items-center justify-center rounded-full bg-slate-950 px-10 text-sm font-bold uppercase tracking-[0.14em] text-white hover:bg-emerald-500 hover:text-slate-950 transition-colors shadow-2xl">
                Começar agora gratuitamente
            </Link>
        </section>

    </SiteLayout>
</template>

<style scoped>
.perspective-[1000px] {
    perspective: 1000px;
}

.scenario-3d-fade-enter-active,
.scenario-3d-fade-leave-active {
    transition: all 400ms cubic-bezier(0.2, 0.8, 0.2, 1);
}

.scenario-3d-fade-enter-from {
    opacity: 0;
    transform: rotateX(-5deg) translateY(20px);
}

.scenario-3d-fade-leave-to {
    opacity: 0;
    transform: rotateX(5deg) translateY(-20px);
}
</style>
