<script setup lang="ts">
import { Link } from '@inertiajs/vue3';
import { footerProduct, footerCompany, footerResources, footerLegal, footerSocials } from '@/types/site';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();
</script>

<template>
    <footer class="relative z-10 border-t border-slate-200 bg-white pt-24 pb-12 overflow-hidden">
        <!-- Floating shapes for premium detail -->
        <div class="absolute -right-64 -top-64 w-[500px] h-[500px] bg-teal-50 rounded-full blur-3xl opacity-50 pointer-events-none"></div>

        <div class="mx-auto w-full max-w-[1400px] px-6 relative z-10">
            <div class="grid lg:grid-cols-4 gap-12 lg:gap-8 mb-20">
                <!-- Brand Column -->
                <div class="lg:col-span-1 pr-6 flex flex-col gap-6">
                    <p class="text-3xl font-extrabold tracking-tight text-slate-900">kitamo<span class="text-teal-500">.</span></p>
                    <p class="text-base font-medium leading-relaxed text-slate-500">
                        O app que tira a venda dos seus olhos e joga limpo sobre o seu dinheiro. Chega de sofrer no fim do mês.
                    </p>
                    <div class="mt-4 inline-flex items-center gap-2 bg-slate-50 border border-slate-100 px-4 py-2 rounded-xl w-max">
                        <span class="relative flex h-2.5 w-2.5">
                          <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-teal-400 opacity-75"></span>
                          <span class="relative inline-flex rounded-full h-2.5 w-2.5 bg-teal-500"></span>
                        </span>
                        <span class="text-[11px] font-bold uppercase tracking-wider text-slate-600">Sistemas operando 100%</span>
                    </div>
                </div>

                <!-- Navigation Columns -->
                <div class="lg:col-span-3 grid grid-cols-2 md:grid-cols-4 gap-10">
                    <div>
                        <p class="text-[12px] font-bold uppercase tracking-widest text-slate-400 mb-6 drop-shadow-sm">O App</p>
                        <div class="flex flex-col gap-4">
                            <Link v-for="item in footerProduct" :key="item.routeName" :href="route(item.routeName)" class="text-[14px] font-bold text-slate-600 hover:text-teal-500 hover:translate-x-1 transition-all">
                                {{ item.label }}
                            </Link>
                        </div>
                    </div>

                    <div>
                        <p class="text-[12px] font-bold uppercase tracking-widest text-slate-400 mb-6 drop-shadow-sm">Kitamo</p>
                        <div class="flex flex-col gap-4">
                            <Link v-for="item in footerCompany" :key="item.routeName" :href="route(item.routeName)" class="text-[14px] font-bold text-slate-600 hover:text-teal-500 hover:translate-x-1 transition-all">
                                {{ item.label }}
                            </Link>
                        </div>
                    </div>

                    <div>
                        <p class="text-[12px] font-bold uppercase tracking-widest text-slate-400 mb-6 drop-shadow-sm">Recursos</p>
                        <div class="flex flex-col gap-4">
                            <Link v-for="item in footerResources" :key="item.label" :href="route(item.routeName)" class="text-[14px] font-bold text-slate-600 hover:text-teal-500 hover:translate-x-1 transition-all">
                                {{ item.label }}
                            </Link>
                        </div>
                    </div>

                    <div>
                        <p class="text-[12px] font-bold uppercase tracking-widest text-slate-400 mb-6 drop-shadow-sm">Pro lado legal</p>
                        <div class="flex flex-col gap-4">
                            <Link v-for="item in footerLegal" :key="item.routeName" :href="route(item.routeName)" class="text-[14px] font-bold text-slate-600 hover:text-teal-500 hover:translate-x-1 transition-all">
                                {{ item.label }}
                            </Link>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Bottom Footer -->
            <div class="pt-8 border-t border-slate-100 flex flex-col md:flex-row items-center justify-between gap-6">
                <p class="text-[12px] font-bold text-slate-400 uppercase tracking-widest text-center md:text-left">
                    © {{ new Date().getFullYear() }} Kitamo Tech. Feito pra quem se importa.
                </p>
                <div class="flex items-center gap-3">
                    <a
                        v-for="item in footerSocials"
                        :key="item.label"
                        :href="item.href"
                        class="inline-flex h-10 items-center justify-center rounded-xl bg-slate-50 border border-slate-200 px-4 text-[12px] font-bold text-slate-600 transition-all hover:bg-teal-50 hover:text-teal-600 hover:border-teal-200"
                    >
                        {{ item.label }}
                    </a>
                </div>
            </div>
        </div>
    </footer>
</template>
