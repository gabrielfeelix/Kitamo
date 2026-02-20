<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();
</script>

<template>
    <Head title="Privacidade | Kitamo">
        <meta name="description" content="Política de privacidade da Kitamo em linguagem clara e organizada." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        
        <section class="max-w-[900px] mx-auto px-6 py-24 md:py-32">
            
            <div class="mb-20">
                <Link :href="route('site.home')" class="text-[10px] font-bold uppercase tracking-widest text-slate-500 hover:text-emerald-500 transition-colors mb-6 inline-block">← Voltar</Link>
                <h1 class="text-5xl md:text-[6rem] leading-[0.9] font-medium tracking-tight mb-8">Nossa lei de <span class="bg-slate-950 text-white px-2 italic font-serif">Privacidade.</span></h1>
                <p class="text-xl text-slate-500">Documento base de como lidamos com a sua vida financeira.</p>
                <div class="mt-8 flex gap-4 border-t border-slate-200 pt-6 text-xs font-bold uppercase tracking-widest text-slate-500">
                    <span>Última atualização: Fevereiro, 2025</span>
                    <span>•</span>
                    <span>Versão 1.0</span>
                </div>
            </div>

            <div class="prose prose-lg prose-slate max-w-none font-medium leading-relaxed prose-h2:text-3xl prose-h2:tracking-tight prose-h2:font-medium prose-h2:mb-6 prose-p:text-slate-600 prose-p:mb-8 font-sans">
                <h2>1. Minimizar, não acumular</h2>
                <p>O Kitamo coleciona o mínimo de dados viável para o serviço existir. Nós não vendemos hábitos de consumo para publicitários, nem alimentamos perfis obscuros de score de crédito a terceiros.</p>

                <h2>2. Open Finance Criptografado</h2>
                <p>Nossas conexões com seus bancos seguem protocolos oficiais do Banco Central. Temos apenas acesso de Leitura aos seus extratos, mascarado de ponta-a-ponta. Seus dados são criptografados <strong>em repouso (at rest) e em trânsito (in transit)</strong> utilizando padrões globais da indústria (AES-256 e TLS 1.3). O Kitamo <strong>não tem</strong> a capacidade técnica de mover centavos em suas contas correntes.</p>

                <h2>3. Com quem compartilhamos</h2>
                <p>Nós rodamos nossa infraestrutura técnica em parceiros como AWS (Amazon) e ferramentas de análise interna anonimizada. Se não for por auditoria de segurança ou infra, nenhum 3º põe as mãos no seu ID.</p>

                <h2>4. O seu botão vermelho</h2>
                <p>Se você assinar, se arrepender, ou simplesmente decidir que não quer mais o sistema: mande um e-mail. Nós ativamos a "destruição nuclear". Todos os seus gráficos, conexões de banco e histórico viram poeira digital em nossos bancos de dados em 24h.</p>
                
                <h2>5. Seus Direitos (LGPD Art. 18)</h2>
                <p>De acordo com a Lei Geral de Proteção de Dados, você tem o direito garantido de confirmar, acessar, corrigir, anonimizar, bloquear ou eliminar os seus dados da nossa base a qualquer instante. Nós respondemos essas requisições como prioridade máxima de SLA.</p>
                
                <h2 class="mt-16 text-slate-900 border-t border-slate-200 pt-10">DPO & Dúvidas Legais</h2>
                <p>Acesse o nosso <Link :href="route('site.contact')" class="text-emerald-600 underline underline-offset-4 font-bold hover:text-emerald-700">Canal de Contato</Link> para debater qualquer trecho deste manifesto ou acionar o nosso Data Protection Officer (DPO) através da opção "Revisão de Dados e Open Finance".</p>
            </div>

        </section>

    </SiteLayout>
</template>
