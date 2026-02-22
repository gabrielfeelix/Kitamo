<script setup lang="ts">
import { ref, onMounted } from 'vue';

const isVisible = ref(false);

onMounted(() => {
    // Staggered reveal for internal elements
    setTimeout(() => {
        isVisible.value = true;
    }, 100);
});
</script>

<template>
    <div class="relative w-full aspect-video md:aspect-[21/9] rounded-[2.5rem] bg-slate-900 border border-white/10 shadow-2xl overflow-hidden flex transform transition-all duration-700" style="transform-style: preserve-3d;">
        <!-- Mockup Sidebar -->
        <div class="hidden md:flex w-64 bg-slate-950/80 border-r border-white/5 flex-col p-6 backdrop-blur">
            <div class="flex items-center gap-3 mb-10">
                <div class="w-8 h-8 rounded-lg bg-teal-500 shadow-[0_0_15px_theme(colors.teal.500/40)]"></div>
                <div class="h-4 w-24 bg-white/20 rounded"></div>
            </div>
            
            <div class="space-y-4 flex-1">
                <div class="h-8 w-full bg-white/10 rounded-lg flex items-center px-4 gap-3">
                    <div class="w-4 h-4 rounded bg-teal-400"></div>
                    <div class="h-2 w-20 bg-white/30 rounded"></div>
                </div>
                <div class="h-8 w-full bg-transparent border border-white/5 rounded-lg flex items-center px-4 gap-3 overflow-hidden group hover:border-white/10 transition-all">
                    <div class="w-4 h-4 rounded bg-white/20"></div>
                    <div class="h-2 w-16 bg-white/20 rounded"></div>
                </div>
                <div class="h-8 w-full bg-transparent border border-white/5 rounded-lg flex items-center px-4 gap-3">
                    <div class="w-4 h-4 rounded bg-white/20"></div>
                    <div class="h-2 w-24 bg-white/20 rounded"></div>
                </div>
            </div>
            
            <div class="mt-auto pt-6 border-t border-white/5">
                <div class="flex items-center gap-3">
                    <div class="w-10 h-10 rounded-full bg-gradient-to-tr from-teal-400 to-cyan-500"></div>
                    <div>
                        <div class="h-3 w-20 bg-white/30 rounded mb-2"></div>
                        <div class="h-2 w-16 bg-white/10 rounded"></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Mockup Main Content -->
        <div class="flex-1 p-6 md:p-10 flex flex-col relative z-10 bg-gradient-to-br from-slate-900 via-slate-900 to-slate-950 overflow-hidden">
            
            <!-- Dashboard Header -->
            <div class="flex justify-between items-end mb-10">
                <div>
                    <h3 class="text-white/40 text-xs font-bold uppercase tracking-widest mb-2 transition-all duration-700 translate-y-4 opacity-0" :class="{ 'translate-y-0 opacity-100': isVisible }">Saldo Geral</h3>
                    <div class="text-4xl md:text-5xl font-extrabold text-white tracking-tighter transition-all duration-700 delay-100 translate-y-4 opacity-0" :class="{ 'translate-y-0 opacity-100': isVisible }">
                        R$ <span class="text-transparent bg-clip-text bg-gradient-to-r from-teal-400 to-emerald-300">14.050</span>,00
                    </div>
                </div>
                <!-- Fake Buttons -->
                <div class="hidden sm:flex gap-3 transition-all duration-700 delay-200 translate-y-4 opacity-0" :class="{ 'translate-y-0 opacity-100': isVisible }">
                    <div class="w-10 h-10 rounded-xl bg-white/5 border border-white/10"></div>
                    <div class="w-32 h-10 rounded-xl bg-teal-500 shadow-[0_0_20px_theme(colors.teal.500/30)]"></div>
                </div>
            </div>

            <!-- Dashboard Grid -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6 flex-1">
                
                <!-- Main Chart Area -->
                <div class="md:col-span-2 bg-white/5 border border-white/10 rounded-3xl p-6 flex flex-col justify-end relative overflow-hidden transition-all duration-700 delay-300 translate-y-8 opacity-0 group" :class="{ 'translate-y-0 opacity-100': isVisible }">
                    <!-- Chart Lines -->
                    <div class="absolute inset-0 flex flex-col justify-between p-6 pointer-events-none">
                        <div class="w-full border-t border-white/5"></div>
                        <div class="w-full border-t border-white/5"></div>
                        <div class="w-full border-t border-white/5"></div>
                        <div class="w-full border-t border-white/5"></div>
                    </div>
                    
                    <!-- Animated Animated Bars -->
                    <div class="relative z-10 flex items-end justify-between gap-2 h-40 mt-auto">
                        <div v-for="i in 12" :key="i" 
                             class="flex-1 rounded-t-lg bg-teal-500/30 border-t-2 border-teal-400 relative overflow-hidden transition-all duration-1000 ease-out origin-bottom transform scale-y-0 group-hover:bg-teal-500/50"
                             :style="{ 
                                height: `${Math.max(20, Math.random() * 100)}%`,
                                transitionDelay: `${300 + (i * 50)}ms` 
                             }"
                             :class="{ 'scale-y-100': isVisible }">
                             <div class="absolute inset-x-0 bottom-0 h-1/2 bg-gradient-to-t from-teal-500/50 to-transparent"></div>
                        </div>
                    </div>
                </div>

                <!-- Recent Transactions Area -->
                <div class="bg-slate-950/80 border border-white/5 rounded-3xl p-6 flex flex-col transition-all duration-700 delay-500 translate-y-8 opacity-0" :class="{ 'translate-y-0 opacity-100': isVisible }">
                    <div class="h-4 w-32 bg-white/20 rounded mb-8"></div>
                    
                    <div class="space-y-6 flex-1">
                        <!-- Transation Item -->
                        <div v-for="j in 4" :key="j" class="flex items-center gap-4 transition-all duration-700 ease-out transform translate-x-4 opacity-0"
                             :class="{ 'translate-x-0 opacity-100': isVisible }"
                             :style="{ transitionDelay: `${600 + (j * 150)}ms` }">
                            <div class="w-10 h-10 rounded-full bg-white/5 flex-shrink-0 flex items-center justify-center border border-white/10">
                                <div class="w-4 h-4 rounded-full" :class="j % 2 === 0 ? 'bg-rose-400' : 'bg-emerald-400'"></div>
                            </div>
                            <div class="flex-1">
                                <div class="h-3 w-24 bg-white/30 rounded mb-2"></div>
                                <div class="h-2 w-16 bg-white/10 rounded"></div>
                            </div>
                            <div>
                                <div class="h-3 w-16 rounded" :class="j % 2 === 0 ? 'bg-rose-400/80' : 'bg-emerald-400/80'"></div>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>

        <!-- Floating Glass Overlays representing "Cards" and "Goals" to sell the motion -->
        <div class="absolute -right-12 top-20 w-48 h-24 bg-indigo-500/20 backdrop-blur-xl border border-indigo-400/30 rounded-2xl shadow-2xl hidden lg:flex items-center p-4 transition-all duration-1000 delay-[1000ms] transform translate-x-20 opacity-0 animate-bounce" style="animation-duration: 5s;" :class="{ '-translate-x-0 opacity-100': isVisible }">
            <div class="w-10 h-10 rounded-full bg-indigo-400/50 mr-3"></div>
            <div>
                <div class="h-2 w-16 bg-indigo-100 rounded mb-2"></div>
                <div class="h-3 w-20 bg-white rounded"></div>
            </div>
        </div>

        <div class="absolute -left-10 bottom-24 w-56 h-32 bg-teal-900/40 backdrop-blur-xl border border-teal-500/30 rounded-3xl shadow-[0_30px_60px_-15px_rgba(0,0,0,0.8)] hidden lg:flex flex-col justify-center p-5 transition-all duration-1000 delay-[1200ms] transform -translate-x-20 opacity-0 animate-pulse" style="animation-duration: 4s;" :class="{ 'translate-x-0 opacity-100': isVisible }">
             <div class="h-2 w-20 bg-teal-200/50 rounded mb-4"></div>
             <div class="h-4 w-32 bg-white rounded mb-4"></div>
             <div class="w-full h-2 bg-black/40 rounded-full overflow-hidden">
                 <div class="h-full bg-teal-400 w-3/4 shadow-[0_0_10px_theme(colors.teal.400)]"></div>
             </div>
        </div>
    </div>
</template>
