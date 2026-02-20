<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();
</script>

<template>
    <Head title="Empresa | Kitamo">
        <meta name="description" content="A visão institucional e as crenças da Kitamo, fundadores e missão B2C." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        
        <!-- Manifesto Cover -->
        <section class="max-w-[1400px] mx-auto px-6 py-32 md:py-48 grid lg:grid-cols-2 gap-16 items-center">
            
            <div>
                <Link :href="route('site.home')" class="text-[10px] font-bold uppercase tracking-widest text-slate-400 hover:text-emerald-500 transition-colors mb-6 inline-block">← Início</Link>
                <h1 class="text-6xl md:text-[7rem] leading-[0.85] font-medium tracking-tight mb-8">Nós fervemos as <span class="bg-emerald-50 text-emerald-600 block italic font-serif mt-2 px-2">planilhas antigas.</span></h1>
            </div>

            <div class="prose prose-lg prose-slate font-medium text-slate-600 leading-relaxed border-l-4 border-emerald-500 pl-8 md:pl-12">
                <p>O Kitamo nasceu de uma frustração brutal da nossa equipe fundadora: os softwares de finanças não queriam ajudar a resolver os problemas, queriam que preenchêssemos formulários.</p>
                <p>Nós construímos essa máquina para pessoas que querem <strong class="text-slate-900 bg-emerald-200/50 px-1">decidir e sair da frente do computador</strong>, não para contadores apaixonados por categorizar café 500 vezes por ano.</p>
            </div>

        </section>

        <!-- Our Core Beliefs - Asymmetric Grid -->
        <section class="bg-[#0f172a] py-32 text-white">
             <div class="max-w-[1300px] mx-auto px-6">
                 
                 <div class="flex flex-col md:flex-row md:items-end justify-between mb-20 pb-16 border-b border-slate-800">
                     <h2 class="text-5xl md:text-[5rem] tracking-tight font-medium max-w-2xl leading-[0.9]">Pilares que não <span class="text-emerald-500 italic font-serif">negociamos.</span></h2>
                     <p class="text-lg font-bold uppercase tracking-widest text-slate-500 max-w-xs mt-8 md:mt-0">O Kitamo Operations Standard (KOS)</p>
                 </div>

                 <div class="grid md:grid-cols-3 gap-16 md:gap-12">
                     <div class="space-y-6 lg:mt-0">
                         <div class="w-16 h-16 rounded-full bg-white/5 border border-white/10 flex items-center justify-center text-emerald-400 font-bold text-2xl">I</div>
                         <h3 class="text-3xl font-medium tracking-tight">Clareza no lugar do volume.</h3>
                         <p class="text-slate-400 leading-relaxed font-medium">Você precisa saber o seu saldo projetado para o dia 30 e os alertas vermelhos de amanhã. O resto, nossa inteligência e automação abafam nos bastidores.</p>
                     </div>
                     
                     <div class="space-y-6 lg:mt-20">
                         <div class="w-16 h-16 rounded-full bg-white/5 border border-white/10 flex items-center justify-center text-emerald-400 font-bold text-2xl">II</div>
                         <h3 class="text-3xl font-medium tracking-tight">O Fim da Planilha manual.</h3>
                         <p class="text-slate-400 leading-relaxed font-medium">Uma equipe enxuta escrevendo código Open Finance resiliente. Nós pagamos o pedágio bancário para que você só tenha que aprovar o que nossos robôs já categorizaram com precisão clínica.</p>
                     </div>
                     
                     <div class="space-y-6 lg:mt-40">
                         <div class="w-16 h-16 rounded-full bg-white/5 border border-white/10 flex items-center justify-center text-emerald-400 font-bold text-2xl">III</div>
                         <h3 class="text-3xl font-medium tracking-tight">Privacidade Brutal.</h3>
                         <p class="text-slate-400 leading-relaxed font-medium">Nós somos uma empresa de software, não uma agência de mídia. Nosso dinheiro vem puramente daqueles que veem valor na ferramenta SaaS.</p>
                     </div>
                 </div>

             </div>
        </section>

        <!-- Huge Connect Block -->
         <section class="max-w-[1400px] mx-auto px-6 py-32 text-center">
              <h2 class="text-4xl md:text-[4.5rem] leading-[0.85] font-medium tracking-tight mb-10 max-w-4xl mx-auto">Quer bater um papo no WhatsApp com o C-Level?</h2>
              <p class="text-xl text-slate-500 max-w-2xl mx-auto mb-12">Sem robôs e burocracia, acesse nossa comunicação corporativa oficial.</p>
              
              <Link :href="route('site.contact')" class="inline-flex h-20 items-center justify-center rounded-full bg-[#25D366] px-12 text-sm font-bold uppercase tracking-[0.14em] text-white hover:bg-[#128C7E] transition-all shadow-[0_20px_40px_rgba(37,211,102,0.3)] hover:-translate-y-2">
                  Chamar no Contato Oficial
              </Link>
         </section>

    </SiteLayout>
</template>
