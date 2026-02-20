<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const checks = [
    { title: "Comunicação Segura (SSL/TLS)", desc: "100% da plataforma transporta dados em túneis blindados. De ponta a ponta." },
    { title: "Arquitetura Isolada", desc: "Seu ID tem um namespace único no banco de dados. Nunca rola mixagem." },
    { OpenFinance: "Sincronização Read-Only", desc: "A API oficial dos bancos é usada sem privilégios de transação via Open Finance regulamentado." },
    { title: "Hospedagem Corporativa", desc: "Infraestrutura escalável via cloud computing robusta, a mesma que os grandes SaaS B2B usam." }
];
</script>

<template>
    <Head title="Segurança | Kitamo">
        <meta name="description" content="Práticas de segurança, privacidade e governança de dados da Kitamo." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        
        <section class="max-w-[1400px] mx-auto px-6 py-24 md:py-32 grid lg:grid-cols-2 gap-20 items-start">
            
            <div class="lg:sticky lg:top-40 mb-10 lg:mb-0">
                <Link :href="route('site.home')" class="text-[10px] font-bold uppercase tracking-widest text-emerald-600 bg-emerald-100 px-4 py-2 rounded-full inline-flex items-center gap-2 mb-10 border border-emerald-500/20"><span class="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-ping"></span> Auditoria On</Link>
                <h1 class="text-5xl md:text-[6rem] leading-[0.8] font-medium tracking-tight mb-8">O Cofre.</h1>
                <p class="text-xl text-slate-500 leading-relaxed font-medium">As fundações de código do Kitamo foram desenhadas como se fôssemos nós mesmos usar (e nós usamos). Zero atalho de segurança.</p>
                <Link :href="route('site.contact')" class="inline-block mt-12 underline underline-offset-8 decoration-emerald-500 decoration-2 font-bold text-slate-900 hover:text-emerald-700 transition-colors uppercase text-sm tracking-widest">Tem dúvidas de T.I.? Fale conosco</Link>
            </div>

            <!-- Big Brute Security Grid -->
            <div>
                 <div class="space-y-6">
                     <div v-for="(check, idx) in checks" :key="idx" class="bg-white p-8 md:p-10 rounded-[2.5rem] border border-slate-200 shadow-[0_20px_40px_rgba(2,6,23,0.02)] relative overflow-hidden group">
                         <div class="absolute -top-10 -right-10 w-40 h-40 bg-slate-100 rounded-full blur-[40px] group-hover:bg-emerald-100 transition-colors duration-700"></div>
                         <h3 class="text-3xl font-medium tracking-tight text-slate-900 mb-4">{{ check.title || check.OpenFinance }}</h3>
                         <p class="text-slate-500 leading-relaxed font-medium">{{ check.desc }}</p>
                     </div>
                 </div>

                 <!-- Documentos Legais Integrados -->
                 <div class="bg-slate-950 text-white mt-8 p-10 rounded-[2.5rem] grid gap-8">
                     <h3 class="text-2xl font-medium tracking-tight">O combo de Leis do jogo.</h3>
                     <div class="flex gap-4 border-t border-slate-800 pt-8 mt-2">
                        <Link :href="route('site.privacy')" class="flex-1 bg-white/5 border border-white/10 p-6 rounded-2xl hover:bg-emerald-500 hover:border-emerald-400 group transition-colors">
                            <span class="text-[10px] font-bold uppercase tracking-widest text-slate-400 group-hover:text-emerald-950 block mb-3">Lei & Regra</span>
                            <span class="text-lg font-medium tracking-tight text-white group-hover:text-slate-950">Privacidade</span>
                        </Link>
                        <Link :href="route('site.terms')" class="flex-1 bg-white/5 border border-white/10 p-6 rounded-2xl hover:bg-amber-400 hover:border-amber-300 group transition-colors">
                            <span class="text-[10px] font-bold uppercase tracking-widest text-slate-400 group-hover:text-amber-950 block mb-3">Contrato</span>
                            <span class="text-lg font-medium tracking-tight text-white group-hover:text-slate-950">Seus Termos</span>
                        </Link>
                     </div>
                 </div>
            </div>

        </section>

    </SiteLayout>
</template>
