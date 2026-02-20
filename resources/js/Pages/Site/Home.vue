<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';
import PricingBlock from '@/Components/site/PricingBlock.vue';
import { pricingPlans } from '@/types/site';

const props = defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const primaryHref = props.canRegister ? '/register' : '/login';

const howItWorks = [
    {
        step: 'Passo 1',
        title: 'Cadastre suas contas e cartões',
        description: 'Organize conta corrente, poupança, carteira e cartões para montar a base da projeção.',
    },
    {
        step: 'Passo 2',
        title: 'Lance receitas e despesas',
        description: 'Registre movimentações do jeito manual confiável: recorrências, parcelas e compromissos futuros.',
    },
    {
        step: 'Passo 3',
        title: 'Veja a projeção dos próximos 30 dias',
        description: 'Enxergue antes quando o saldo aperta e ajuste a rota com antecedência.',
    },
];

const keyFeatures = [
    {
        title: 'Projeção de caixa',
        description: 'Linha diária com risco de saldo negativo e leitura clara de decisão.',
    },
    {
        title: 'Gestão de cartões',
        description: 'Controle ciclo de fatura, parcelamentos e vencimentos sem susto.',
    },
    {
        title: 'Metas financeiras',
        description: 'Acompanhe objetivo, prazo e ritmo de evolução em um só lugar.',
    },
    {
        title: 'Despesas recorrentes',
        description: 'Mensal, semanal, quinzenal e anual entram automaticamente na projeção.',
    },
];

const testimonials = [
    {
        initials: 'MS',
        name: 'Mariana S., 32 anos, Sao Paulo',
        role: 'Designer Freelancer',
        quote: 'Antes eu via apenas o que ja tinha gasto. Agora eu sei o que vai pesar no fim do mes e ajo antes.',
    },
    {
        initials: 'RL',
        name: 'Rafael L., 29 anos, Belo Horizonte',
        role: 'Analista de Operacoes',
        quote: 'A previsao dos proximos dias mudou meu controle. Parei de ser pego de surpresa por fatura e assinatura.',
    },
    {
        initials: 'CT',
        name: 'Camila T., 35 anos, Recife',
        role: 'Empreendedora',
        quote: 'Com rotina de 10 minutos por semana, o Kitamo virou meu painel de decisao do mes.',
    },
];

const comparisonRows = [
    { feature: 'Foco principal', others: 'Historico de gastos', kitamo: 'Projecao de caixa' },
    { feature: 'Integracao bancaria', others: 'Sim (Open Finance)', kitamo: 'Nao (input manual)' },
    { feature: 'Faixa de preco', others: 'R$ 20-45/mes', kitamo: 'Gratis ou R$ 19/mes' },
    { feature: 'Complexidade', others: 'Alta', kitamo: 'Baixa' },
];
</script>

<template>
    <Head title="Kitamo | Projecao financeira para o seu mes">
        <meta
            name="description"
            content="Kitamo e o app de financas pessoais focado em projecao de caixa. Veja seus proximos 30 dias e antecipe risco antes do vencimento."
        />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[1240px] px-5 pb-16 pt-10 md:px-6 md:pb-20 md:pt-16">
            <div class="grid items-center gap-12 lg:grid-cols-12">
                <div class="lg:col-span-7">
                    <p class="text-[11px] font-bold uppercase tracking-[0.18em] text-slate-500">Planejamento financeiro pessoal</p>
                    <h1 class="mt-5 text-5xl leading-[0.92] tracking-[-0.03em] text-slate-950 md:text-6xl">
                        Pare de olhar so para o passado. <span class="font-serif italic text-emerald-600">Projete seu mes.</span>
                    </h1>
                    <p class="mt-6 max-w-2xl text-lg leading-relaxed text-slate-600 md:text-xl">
                        O Kitamo mostra como o saldo evolui nos proximos dias para voce decidir antes do aperto. Menos adivinhacao, mais previsibilidade.
                    </p>
                    <div class="mt-9 flex flex-wrap items-center gap-4">
                        <Link
                            :href="primaryHref"
                            class="inline-flex h-12 items-center justify-center rounded-full bg-slate-950 px-6 text-[11px] font-bold uppercase tracking-[0.16em] text-white transition hover:bg-emerald-500 hover:text-slate-950"
                        >
                            Comecar gratis
                        </Link>
                        <Link
                            :href="route('site.product') + '#demo'"
                            class="inline-flex h-12 items-center justify-center rounded-full border border-slate-300 px-6 text-[11px] font-bold uppercase tracking-[0.16em] text-slate-700 transition hover:border-slate-950 hover:text-slate-950"
                        >
                            Ver demonstracao
                        </Link>
                        <span class="text-xs font-semibold uppercase tracking-[0.13em] text-slate-500">Sem cartao de credito</span>
                    </div>
                </div>

                <div class="lg:col-span-5">
                    <div class="rounded-3xl border border-slate-200 bg-white/80 p-6 shadow-xl md:p-8">
                        <p class="text-[10px] font-bold uppercase tracking-[0.16em] text-slate-500">Painel de previsao</p>
                        <div class="mt-4 rounded-2xl bg-slate-900 p-5 text-white">
                            <p class="text-xs uppercase tracking-[0.12em] text-slate-400">Saldo projetado no dia 30</p>
                            <p class="mt-2 text-4xl tracking-tight">R$ 1.240</p>
                            <div class="mt-4 grid grid-cols-6 gap-2">
                                <div class="h-16 rounded bg-emerald-500/40"></div>
                                <div class="h-20 rounded bg-emerald-500/40"></div>
                                <div class="h-14 rounded bg-emerald-500/40"></div>
                                <div class="h-10 rounded bg-amber-400/50"></div>
                                <div class="h-7 rounded bg-red-500/50"></div>
                                <div class="h-6 rounded bg-red-500/70"></div>
                            </div>
                        </div>
                        <div class="mt-4 rounded-2xl border border-red-200 bg-red-50 p-4">
                            <p class="text-xs font-bold uppercase tracking-[0.14em] text-red-700">Risco identificado</p>
                            <p class="mt-1 text-sm font-medium text-slate-700">Saldo pode ficar negativo em <strong class="text-red-700">27/03</strong> sem ajuste de gastos.</p>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1240px] px-5 py-12 md:px-6 md:py-16">
            <div class="grid gap-8 rounded-3xl border border-slate-200 bg-white/70 p-8 md:grid-cols-12 md:p-10">
                <div class="md:col-span-8">
                    <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">O problema</p>
                    <h2 class="mt-4 text-3xl leading-[1.02] tracking-[-0.03em] text-slate-950 md:text-4xl">
                        Apps financeiros olham pro passado. Voce precisa ver o futuro.
                    </h2>
                    <p class="mt-5 text-lg leading-relaxed text-slate-600">
                        Saber quanto ja saiu da conta nao resolve sozinho. O que falta e previsao diaria de vencimentos, recorrencias e parcelas para voce decidir com antecedencia.
                    </p>
                </div>
                <div class="md:col-span-4">
                    <div class="flex h-full items-center justify-center rounded-2xl border border-dashed border-slate-300 bg-slate-50 p-6 text-center">
                        <p class="text-sm font-semibold text-slate-500">Ilustracao conceitual do problema<br /><!-- TODO: substituir por ilustracao proprietaria --></p>
                    </div>
                </div>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1240px] px-5 py-12 md:px-6 md:py-16">
            <div class="mb-10">
                <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Como funciona</p>
                <h2 class="mt-3 text-3xl leading-[1.02] tracking-[-0.03em] text-slate-950 md:text-4xl">Tres passos para sair da incerteza</h2>
            </div>
            <div class="grid gap-4 md:grid-cols-3">
                <article
                    v-for="item in howItWorks"
                    :key="item.title"
                    class="rounded-3xl border border-slate-200 bg-white/80 p-6"
                >
                    <p class="text-[11px] font-bold uppercase tracking-[0.14em] text-emerald-700">{{ item.step }}</p>
                    <h3 class="mt-3 text-2xl leading-tight tracking-tight text-slate-950">{{ item.title }}</h3>
                    <p class="mt-3 text-sm leading-relaxed text-slate-600">{{ item.description }}</p>
                </article>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1240px] px-5 py-12 md:px-6 md:py-16">
            <div class="grid gap-10 rounded-3xl bg-slate-950 p-8 text-white md:grid-cols-12 md:p-10">
                <div class="md:col-span-5">
                    <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-emerald-300">Projecao visual</p>
                    <h2 class="mt-4 text-3xl leading-tight tracking-tight md:text-4xl">Veja exatamente quando seu saldo pode ficar negativo</h2>
                    <p class="mt-4 text-base leading-relaxed text-slate-300">
                        Um painel simples destaca o dia de risco e o impacto de cada compromisso. Sem confusao, sem sobrecarga.
                    </p>
                </div>
                <div class="md:col-span-7">
                    <div class="rounded-2xl border border-white/10 bg-slate-900 p-6">
                        <div class="rounded-xl border border-dashed border-slate-600 p-6 text-center text-sm text-slate-400">
                            Screenshot do dashboard de projecao
                            <br />
                            <!-- TODO: substituir pelo print real da tela de projecao -->
                        </div>
                        <div class="mt-4 inline-flex rounded-full border border-red-400/40 bg-red-500/10 px-4 py-2 text-xs font-bold uppercase tracking-[0.14em] text-red-300">
                            Alerta: risco de saldo negativo em 4 dias
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1240px] px-5 py-12 md:px-6 md:py-16">
            <div class="mb-10">
                <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Funcionalidades principais</p>
                <h2 class="mt-3 text-3xl leading-[1.02] tracking-[-0.03em] text-slate-950 md:text-4xl">Quatro blocos que sustentam sua previsao</h2>
            </div>
            <div class="grid gap-4 md:grid-cols-2">
                <article
                    v-for="feature in keyFeatures"
                    :key="feature.title"
                    class="rounded-3xl border border-slate-200 bg-white/80 p-7"
                >
                    <h3 class="text-2xl tracking-tight text-slate-950">{{ feature.title }}</h3>
                    <p class="mt-3 text-base leading-relaxed text-slate-600">{{ feature.description }}</p>
                </article>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1240px] px-5 py-12 md:px-6 md:py-16">
            <div class="mb-10">
                <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Quem ja usa</p>
                <h2 class="mt-3 text-3xl leading-[1.02] tracking-[-0.03em] text-slate-950 md:text-4xl">Resultados reais em rotina real</h2>
            </div>
            <!-- TODO: substituir por depoimentos reais quando disponiveis -->
            <div class="grid gap-4 md:grid-cols-3">
                <article
                    v-for="person in testimonials"
                    :key="person.name"
                    class="rounded-3xl border border-slate-200 bg-white/80 p-6"
                >
                    <div class="flex items-center gap-3">
                        <div class="flex h-12 w-12 items-center justify-center rounded-full bg-slate-200 text-sm font-bold text-slate-700">
                            {{ person.initials }}
                        </div>
                        <div>
                            <p class="text-sm font-semibold text-slate-900">{{ person.name }}</p>
                            <p class="text-xs text-slate-500">{{ person.role }}</p>
                        </div>
                    </div>
                    <p class="mt-4 text-sm leading-relaxed text-slate-600">"{{ person.quote }}"</p>
                </article>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1240px] px-5 py-12 md:px-6 md:py-16">
            <div class="rounded-3xl border border-slate-200 bg-white p-6 md:p-8">
                <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Comparacao honesta</p>
                <h2 class="mt-3 text-3xl leading-[1.02] tracking-[-0.03em] text-slate-950 md:text-4xl">Kitamo vs. outros apps</h2>
                <div class="mt-6 overflow-x-auto">
                    <table class="min-w-full text-sm">
                        <thead>
                            <tr class="border-b border-slate-200 text-left text-xs uppercase tracking-[0.14em] text-slate-500">
                                <th class="pb-3 pr-4">Criterio</th>
                                <th class="pb-3 pr-4">Outros apps</th>
                                <th class="pb-3">Kitamo</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr
                                v-for="row in comparisonRows"
                                :key="row.feature"
                                class="border-b border-slate-100"
                            >
                                <td class="py-3 pr-4 font-semibold text-slate-900">{{ row.feature }}</td>
                                <td class="py-3 pr-4 text-slate-600">{{ row.others }}</td>
                                <td class="py-3 font-semibold text-emerald-700">{{ row.kitamo }}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <p class="mt-4 text-xs text-slate-500">Outros apps incluem Mobills, Organizze e similares.</p>
            </div>
        </section>

        <section class="bg-white py-16 md:py-20">
            <div class="mx-auto w-full max-w-[1240px] px-5 md:px-6">
                <div class="mb-10 text-center">
                    <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Precos</p>
                    <h2 class="mt-3 text-3xl leading-[1.02] tracking-[-0.03em] text-slate-950 md:text-4xl">Escolha o ritmo do seu controle</h2>
                </div>
                <PricingBlock :plans="pricingPlans" :can-register="canRegister" />
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1240px] px-5 pb-20 pt-16 text-center md:px-6 md:pb-24 md:pt-20">
            <div class="rounded-3xl bg-emerald-400 px-6 py-14 text-slate-950 md:px-10">
                <h2 class="text-4xl leading-[0.95] tracking-[-0.03em] md:text-5xl">Comece a projetar seu mes hoje</h2>
                <p class="mx-auto mt-4 max-w-2xl text-base font-medium text-slate-900/80 md:text-lg">
                    Gratis para sempre no plano Essencial. Upgrade quando fizer sentido para sua rotina.
                </p>
                <Link
                    :href="primaryHref"
                    class="mt-8 inline-flex h-12 items-center justify-center rounded-full bg-slate-950 px-7 text-[11px] font-bold uppercase tracking-[0.16em] text-white transition hover:bg-white hover:text-slate-950"
                >
                    Criar conta gratuita
                </Link>
            </div>
        </section>
    </SiteLayout>
</template>
