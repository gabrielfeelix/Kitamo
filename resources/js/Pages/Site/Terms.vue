<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();
</script>

<template>
    <Head title="Termos de Uso | Kitamo">
        <meta name="description" content="Termos de uso institucionais da plataforma Kitamo." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        
        <section class="max-w-[900px] mx-auto px-6 py-24 md:py-32">
            
            <div class="mb-20">
                <Link :href="route('site.home')" class="text-[10px] font-bold uppercase tracking-widest text-slate-400 hover:text-emerald-500 transition-colors mb-6 inline-block">← Voltar</Link>
                <h1 class="text-5xl md:text-[6rem] leading-[0.9] font-medium tracking-tight mb-8">Nossas regras <span class="text-emerald-500 italic font-serif">de Campo.</span></h1>
                <p class="text-xl text-slate-500">Termos curtos e justos. Sem letras miúdas debaixo do tapete.</p>
                <div class="mt-8 flex gap-4 border-t border-slate-200 pt-6 text-xs font-bold uppercase tracking-widest text-slate-400">
                    <span>Última atualização: Julho, 2026</span>
                    <span>•</span>
                    <span>Versão 1.5</span>
                </div>
            </div>

            <div class="prose prose-lg prose-slate max-w-none font-medium leading-relaxed prose-h2:text-3xl prose-h2:tracking-tight prose-h2:font-medium prose-h2:mb-6 prose-p:text-slate-600 prose-p:mb-8 font-sans">
                <h2>1. Seu Acesso</h2>
                <p>Nós fornecemos uma licença individual, revogável, não-exclusiva e instransferível para usar o Kitamo via nossa aplicação Web Criptografada. Você não pode copiar, embutir, fazer engenharia reversa ou sublicenciar sua conta para uma tia chata.</p>

                <h2>2. Conselhos Fiscais</h2>
                <p>A Kitamo é um <strong>software, não o seu contador mágico nem consultor financeiro</strong> registrado. Ações tomadas com base nas nossas projeções ou gráficos vermelhos piscando são de sua exclusiva responsabilidade no fim do dia.</p>

                <h2>3. Pagamentos e Planos Essenciais</h2>
                <p>Não há pegadinhas. Você seleciona o plano, insere um método de faturamento (processado majoritariamente pela Stripe), e cobraremos no ciclo acordado. Se o banco recursar no dia de corte, o sistema rebaixa você automaticamente ao Essencial (Nível Grátis) limitando sincronizações até você consertar seu cartão. Você não fica endividado com a gente.</p>

                <h2>4. O quebrar das regras</h2>
                <p>Nós não banimos usuários a não ser que exista abuso grave contra nossas APIs de sincronização através de proxies não convencionais (bots invasivos). Em caso de rompimento flagrante desta regra, cortamos sua assinatura e encerramos a conta. Dinheiro não reembolsável nessas péssimas exceções.</p>
                
                <h2 class="mt-16 text-slate-900 border-t border-slate-200 pt-10">Aceite Amigável</h2>
                <p>Quando você marca a caixa <em>"De acordo"</em> lá na página de Cadastro, estamos fazendo um pacto digital de cavalheiros de que você entende o jogo: Nós construímos segurança e projeções matemáticas para seu benefício dentro da legislação brasileira, e você faz o uso honesto do sistema.</p>
            </div>

        </section>

    </SiteLayout>
</template>
