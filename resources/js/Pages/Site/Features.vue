<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const features = [
    {
        title: 'Projecao de caixa',
        badge: 'Exclusivo Kitamo',
        paragraphs: [
            'A projecao e o centro da experiencia. Em vez de olhar apenas o que ja aconteceu, voce enxerga o saldo diario do periodo futuro.',
            'O calculo considera saldo atual, receitas previstas, despesas pendentes, recorrencias e parcelas abertas.',
            'Com isso, voce identifica com antecedencia os dias em que o caixa aperta e toma acao antes do vencimento.',
        ],
        bullets: [
            'Linha diaria para os proximos dias',
            'Alerta de data de risco',
            'Leitura clara de impacto por decisao',
        ],
    },
    {
        title: 'Gestao de contas',
        paragraphs: [
            'O Kitamo organiza suas contas em uma estrutura unica para consolidar o fluxo de caixa sem perder detalhe.',
        ],
        bullets: [
            'Tipos suportados: corrente, poupanca, carteira e investimentos',
            'Historico mensal por conta',
            'Base preparada para bancos brasileiros via cadastro manual',
        ],
    },
    {
        title: 'Cartoes de credito',
        paragraphs: [
            'Controle completo de ciclo de fatura, fechamento e vencimento para evitar surpresas no fim do mes.',
        ],
        bullets: [
            'Calculo automatico de ciclo de fatura',
            'Visualizacao de limite e utilizacao',
            'Impacto da fatura refletido na projecao',
        ],
    },
    {
        title: 'Parcelamentos',
        paragraphs: [
            'Compras parceladas sao acompanhadas item a item para nao virar ruido oculto no planejamento.',
        ],
        bullets: [
            'Divide compra em N parcelas',
            'Rastreio individual por parcela',
            'Aparece automaticamente na projecao mes a mes',
        ],
    },
    {
        title: 'Despesas recorrentes',
        paragraphs: [
            'Contas fixas entram no fluxo com frequencia correta e reduzem retrabalho do dia a dia.',
        ],
        bullets: [
            'Frequencias mensal, quinzenal, semanal e anual',
            'Projecao automatica para meses futuros',
            'Alertas de renovacao e revisao',
        ],
    },
    {
        title: 'Metas financeiras',
        paragraphs: [
            'Objetivos claros ajudam a transformar disciplina em progresso real ao longo do tempo.',
        ],
        bullets: [
            'Defina valor e prazo',
            'Acompanhe progresso visual',
            'Status no ritmo, adiantado ou atrasado',
        ],
    },
    {
        title: 'Analise e relatorios',
        paragraphs: [
            'As analises apoiam tomada de decisao sem excesso de dashboard e sem linguagem tecnica desnecessaria.',
        ],
        bullets: [
            'Gastos por categoria',
            'Comparacao entre periodos',
            'Exportacao em Excel e PDF',
        ],
    },
    {
        title: 'Dashboard personalizavel',
        paragraphs: [
            'Cada pessoa tem uma rotina. O painel se adapta ao que realmente importa para seu controle.',
        ],
        bullets: [
            'Escolha quais widgets ficam visiveis',
            'Seis widgets disponiveis no painel',
            'Montagem de visao por prioridade',
        ],
    },
    {
        title: 'Notificacoes inteligentes',
        paragraphs: [
            'Alertas pontuais lembram o que exige acao imediata e evitam esquecimentos de custo alto.',
        ],
        bullets: [
            'Alerta de saldo baixo',
            'Lembrete de vencimento',
            'Resumo semanal de acompanhamento',
        ],
    },
];

const faq = [
    {
        question: 'O Kitamo conecta no meu banco?',
        answer: 'Nao. O Kitamo nao usa Open Finance. O modelo e manual para manter previsibilidade e controle total dos dados.',
    },
    {
        question: 'Preciso lancar tudo manualmente?',
        answer: 'Sim, com apoio de atalhos como recorrencias e parcelamentos para reduzir o trabalho repetitivo.',
    },
    {
        question: 'A projecao considera parcelas futuras?',
        answer: 'Sim. Cada parcela entra no mes correspondente e impacta o saldo na data correta.',
    },
    {
        question: 'Posso usar com mais de uma conta e cartao?',
        answer: 'Sim. O plano Essencial tem limites e os planos pagos liberam estrutura ampliada.',
    },
    {
        question: 'Existe exportacao para prestacao de contas?',
        answer: 'Sim. Relatorios podem ser exportados em Excel e PDF.',
    },
    {
        question: 'O foco e pessoa fisica ou empresa?',
        answer: 'O foco principal atual e financa pessoal e familiar.',
    },
];
</script>

<template>
    <Head title="Funcionalidades | Kitamo">
        <meta
            name="description"
            content="Conheca em profundidade as funcionalidades do Kitamo para projecao de caixa, cartoes, metas e controle financeiro manual."
        />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[1240px] px-5 pb-12 pt-10 md:px-6 md:pb-16 md:pt-16">
            <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Funcionalidades</p>
            <h1 class="mt-5 max-w-4xl text-5xl leading-[0.92] tracking-[-0.03em] text-slate-950 md:text-6xl">
                Cada recurso foi pensado para te dar clareza
            </h1>
            <p class="mt-6 max-w-3xl text-lg leading-relaxed text-slate-600 md:text-xl">
                Funcionalidades que respondem uma pergunta pratica: o plano financeiro do mes esta sustentavel?
            </p>
        </section>

        <section class="mx-auto w-full max-w-[1240px] px-5 py-4 md:px-6 md:py-6">
            <div class="space-y-5 md:space-y-6">
                <article
                    v-for="item in features"
                    :key="item.title"
                    class="rounded-3xl border border-slate-200 bg-white/80 p-6 md:p-8"
                >
                    <div class="grid gap-6 md:grid-cols-12 md:gap-8">
                        <div class="md:col-span-7">
                            <div class="flex flex-wrap items-center gap-3">
                                <h2 class="text-3xl leading-tight tracking-tight text-slate-950 md:text-4xl">{{ item.title }}</h2>
                                <span
                                    v-if="item.badge"
                                    class="inline-flex rounded-full border border-emerald-300 bg-emerald-50 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.12em] text-emerald-700"
                                >
                                    {{ item.badge }}
                                </span>
                            </div>
                            <p
                                v-for="paragraph in item.paragraphs"
                                :key="paragraph"
                                class="mt-3 text-base leading-relaxed text-slate-600"
                            >
                                {{ paragraph }}
                            </p>
                            <ul class="mt-5 space-y-2">
                                <li
                                    v-for="point in item.bullets"
                                    :key="point"
                                    class="flex items-start gap-2 text-sm font-medium text-slate-700"
                                >
                                    <span class="mt-1 h-2 w-2 rounded-full bg-emerald-500"></span>
                                    <span>{{ point }}</span>
                                </li>
                            </ul>
                        </div>
                        <div class="md:col-span-5">
                            <div class="flex h-full min-h-48 items-center justify-center rounded-2xl border border-dashed border-slate-300 bg-slate-50 p-6 text-center text-sm text-slate-500">
                                Placeholder visual do modulo
                                <br />
                                <!-- TODO: substituir por screenshot/gif real desta funcionalidade -->
                            </div>
                        </div>
                    </div>
                </article>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1240px] px-5 pb-20 pt-12 md:px-6 md:pb-24 md:pt-16">
            <div class="grid gap-5 rounded-3xl border border-slate-200 bg-white p-7 md:p-9">
                <div>
                    <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">FAQ de funcionalidades</p>
                    <h2 class="mt-3 text-3xl leading-tight tracking-tight text-slate-950 md:text-4xl">Duvidas frequentes</h2>
                </div>
                <div class="space-y-3">
                    <details
                        v-for="item in faq"
                        :key="item.question"
                        class="rounded-2xl border border-slate-200 bg-slate-50 p-4"
                    >
                        <summary class="cursor-pointer list-none text-base font-semibold text-slate-900">{{ item.question }}</summary>
                        <p class="mt-3 text-sm leading-relaxed text-slate-600">{{ item.answer }}</p>
                    </details>
                </div>
                <div class="mt-4 flex flex-wrap gap-3">
                    <Link
                        :href="route('site.pricing')"
                        class="inline-flex h-11 items-center justify-center rounded-full bg-slate-950 px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-white transition hover:bg-emerald-500 hover:text-slate-950"
                    >
                        Ver planos
                    </Link>
                    <Link
                        :href="route('site.contact')"
                        class="inline-flex h-11 items-center justify-center rounded-full border border-slate-300 px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-slate-700 transition hover:border-slate-950"
                    >
                        Falar com suporte
                    </Link>
                </div>
            </div>
        </section>
    </SiteLayout>
</template>
