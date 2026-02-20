<script setup lang="ts">
import { Link } from '@inertiajs/vue3';
import { footerProduct, footerCompany, footerResources, footerLegal, footerSocials } from '@/types/site';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();
</script>

<template>
    <footer class="relative z-10 border-t border-slate-200 bg-[#eef1ea]">
        <div class="mx-auto w-full max-w-[1400px] px-6 py-20 md:py-32">
            
            <!-- Brutalist Footer Layout -->
            <div class="grid lg:grid-cols-12 gap-16 lg:gap-8 mb-20 text-slate-900 border-b border-slate-300 pb-20">
                
                <div class="lg:col-span-4 pr-10">
                    <p class="text-4xl font-bold tracking-[-0.05em] mb-6">kitamo<span class="text-emerald-500">.</span></p>
                    <p class="text-lg leading-relaxed text-slate-600 font-medium max-w-sm">
                        Sistema de clareza financeira pessoal focado no que você pode mudar amanhã.
                    </p>
                </div>

                <div class="lg:col-span-8 grid grid-cols-2 md:grid-cols-2 lg:grid-cols-4 gap-10 lg:gap-8">
                    
                    <div>
                        <p class="text-[10px] font-bold uppercase tracking-[0.2em] text-slate-600 mb-6">A Plataforma</p>
                        <div class="flex flex-col gap-4">
                            <Link v-for="item in footerProduct" :key="item.routeName" :href="route(item.routeName)" class="text-sm font-bold text-slate-700 hover:text-emerald-600 transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-emerald-500 focus-visible:ring-offset-2 focus-visible:ring-offset-[#eef1ea] rounded-md">
                                {{ item.label }}
                            </Link>
                        </div>
                    </div>

                    <div>
                        <p class="text-[10px] font-bold uppercase tracking-[0.2em] text-slate-600 mb-6">A Companhia</p>
                        <div class="flex flex-col gap-4">
                            <Link v-for="item in footerCompany" :key="item.routeName" :href="route(item.routeName)" class="text-sm font-bold text-slate-700 hover:text-emerald-600 transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-emerald-500 focus-visible:ring-offset-2 focus-visible:ring-offset-[#eef1ea] rounded-md">
                                {{ item.label }}
                            </Link>
                        </div>
                    </div>

                    <div>
                        <p class="text-[10px] font-bold uppercase tracking-[0.2em] text-slate-600 mb-6">Recursos</p>
                        <div class="flex flex-col gap-4">
                            <Link v-for="item in footerResources" :key="item.label" :href="route(item.routeName)" class="text-sm font-bold text-slate-700 hover:text-emerald-600 transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-emerald-500 focus-visible:ring-offset-2 focus-visible:ring-offset-[#eef1ea] rounded-md">
                                {{ item.label }}
                            </Link>
                        </div>
                    </div>

                    <div>
                        <p class="text-[10px] font-bold uppercase tracking-[0.2em] text-slate-600 mb-6">Transparência</p>
                        <div class="flex flex-col gap-4">
                            <Link v-for="item in footerLegal" :key="item.routeName" :href="route(item.routeName)" class="text-sm font-bold text-slate-700 hover:text-emerald-600 transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-emerald-500 focus-visible:ring-offset-2 focus-visible:ring-offset-[#eef1ea] rounded-md">
                                {{ item.label }}
                            </Link>
                        </div>
                    </div>

                </div>
            </div>

            <!-- Pre-Footer Badges & Copy -->
            <div class="flex flex-col gap-6 md:flex-row md:items-center md:justify-between">
                <div class="flex items-center gap-4">
                    <div class="px-4 py-2 rounded-full border border-slate-300 text-[10px] font-bold uppercase tracking-widest text-slate-600 flex items-center gap-2">
                        <span class="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span> Servidores Online
                    </div>
                </div>
                
                <div class="flex flex-col items-start gap-3 md:items-end">
                    <div class="flex flex-wrap items-center gap-2">
                        <a
                            v-for="item in footerSocials"
                            :key="item.label"
                            :href="item.href"
                            class="inline-flex h-9 items-center justify-center rounded-full border border-slate-300 bg-white px-4 text-[10px] font-bold uppercase tracking-[0.14em] text-slate-700 transition hover:border-slate-950 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-emerald-500 focus-visible:ring-offset-2 focus-visible:ring-offset-[#eef1ea]"
                        >
                            {{ item.label }}
                        </a>
                    </div>
                    <p class="text-[10px] font-semibold uppercase tracking-[0.12em] text-slate-500">
                        TODO: definir links oficiais de redes sociais
                    </p>
                    <div class="text-[11px] font-semibold text-slate-600 uppercase tracking-widest">© {{ new Date().getFullYear() }} Kitamo Tech</div>
                </div>
            </div>

        </div>
    </footer>
</template>
