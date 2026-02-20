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
        step: '01',
        title: 'Cadastre contas e cartoes',
        description: 'Monte a base financeira com as contas que voce realmente usa no mes.',
    },
    {
        step: '02',
        title: 'Lance receitas e despesas',
        description: 'Registre movimentacoes, recorrencias e parcelas sem depender de sincronizacao externa.',
    },
    {
        step: '03',
        title: 'Leia sua projecao diaria',
        description: 'Veja quando o saldo aperta e ajuste rota antes da data critica.',
    },
];

const keyFeatures = [
    'Projecao de caixa com risco por data',
    'Gestao de cartoes com ciclo de fatura',
    'Metas financeiras com status de progresso',
    'Despesas recorrentes em frequencias flexiveis',
];

const testimonials = [
    {
        name: 'Mariana S., 32 anos, Sao Paulo',
        role: 'Designer Freelancer',
        quote: 'Parei de descobrir problema financeiro no ultimo dia do mes. Agora eu antecipo.',
    },
    {
        name: 'Rafael L., 29 anos, Belo Horizonte',
        role: 'Analista de Operacoes',
        quote: 'A projecao deixou meu controle objetivo: olho, priorizo e executo.',
    },
    {
        name: 'Camila T., 35 anos, Recife',
        role: 'Empreendedora',
        quote: 'Com poucos minutos por semana, sei exatamente o que pode comprometer meu caixa.',
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
            content="Kitamo e o app de financas pessoais focado em projecao de caixa para voce decidir antes da falta de saldo."
        />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[1320px] px-5 pb-20 pt-10 md:px-6 md:pb-24 md:pt-16">
            <div class="grid items-center gap-12 lg:grid-cols-12 lg:gap-16">
                <div class="lg:col-span-7">
                    <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Planejamento financeiro pessoal</p>
                    <h1 class="mt-5 max-w-4xl text-6xl leading-[0.88] tracking-[-0.04em] text-slate-950 md:text-[6.5rem]">
                        Pare de reagir.
                        <span class="block font-serif italic text-emerald-600">Projete o proximo passo.</span>
                    </h1>
                    <p class="mt-6 max-w-3xl text-lg leading-relaxed text-slate-600 md:text-xl">
                        O Kitamo mostra o que pode acontecer com seu saldo nos proximos dias para voce decidir com antecedencia.
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
                            class="inline-flex h-12 items-center justify-center rounded-full border border-slate-300 px-6 text-[11px] font-bold uppercase tracking-[0.16em] text-slate-700 transition hover:border-slate-950"
                        >
                            Ver demonstracao
                        </Link>
                        <span class="text-xs font-semibold uppercase tracking-[0.12em] text-slate-500">Sem cartao de credito</span>
                    </div>
                </div>

                <div class="lg:col-span-5">
                    <div class="hero-stage relative overflow-hidden rounded-[2rem] border border-slate-200 p-5 md:p-6">
                        <div class="rounded-[1.4rem] border border-slate-800 bg-slate-950 p-5 text-white">
                            <p class="text-[11px] font-bold uppercase tracking-[0.14em] text-emerald-300">Painel de previsao</p>
                            <p class="mt-3 text-5xl tracking-tight">R$ 1.240</p>
                            <div class="mt-5 grid grid-cols-7 items-end gap-2">
                                <span class="h-16 rounded bg-emerald-500/35"></span>
                                <span class="h-20 rounded bg-emerald-500/35"></span>
                                <span class="h-14 rounded bg-emerald-500/35"></span>
                                <span class="h-10 rounded bg-amber-400/55"></span>
                                <span class="h-8 rounded bg-amber-400/65"></span>
                                <span class="h-6 rounded bg-red-500/60"></span>
                                <span class="h-5 rounded bg-red-500/80"></span>
                            </div>
                        </div>
                        <div class="mt-4 border-l-2 border-red-500 pl-4">
                            <p class="text-[11px] font-bold uppercase tracking-[0.14em] text-red-700">Alerta</p>
                            <p class="mt-1 text-sm text-slate-700">Risco de saldo negativo em 27/03 sem ajuste de despesa variavel.</p>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 pb-12 md:px-6 md:pb-16">
            <div class="grid gap-8 border-y border-slate-200 py-12 md:grid-cols-12">
                <div class="md:col-span-4">
                    <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">O problema</p>
                    <h2 class="mt-3 text-4xl leading-[0.95] tracking-tight text-slate-950">Apps olham para o passado</h2>
                </div>
                <div class="md:col-span-8">
                    <p class="max-w-3xl text-xl leading-relaxed text-slate-600">
                        Saber quanto voce ja gastou nao responde o que importa para o fechamento do mes. Sem projecao, toda decisao vira aposta.
                    </p>
                </div>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 py-8 md:px-6 md:py-12">
            <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Como funciona</p>
            <ol class="mt-6 grid gap-6 md:grid-cols-3">
                <li v-for="item in howItWorks" :key="item.step" class="relative pl-7">
                    <span class="absolute left-0 top-1 h-3 w-3 rounded-full bg-emerald-500"></span>
                    <p class="text-[11px] font-bold uppercase tracking-[0.14em] text-slate-500">Passo {{ item.step }}</p>
                    <h3 class="mt-2 text-3xl leading-tight tracking-tight text-slate-950">{{ item.title }}</h3>
                    <p class="mt-3 text-sm leading-relaxed text-slate-600 md:text-base">{{ item.description }}</p>
                </li>
            </ol>
        </section>

        <section class="relative overflow-hidden bg-slate-950 py-16 text-white md:py-20">
            <div class="absolute -left-16 top-0 h-72 w-72 rounded-full bg-emerald-500/20 blur-3xl"></div>
            <div class="mx-auto grid w-full max-w-[1320px] gap-10 px-5 md:grid-cols-12 md:px-6">
                <div class="md:col-span-5">
                    <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-emerald-300">Projecao visual</p>
                    <h2 class="mt-4 text-4xl leading-[0.95] tracking-[-0.03em] md:text-5xl">
                        Veja quando seu saldo pode ficar negativo
                    </h2>
                    <p class="mt-4 text-base leading-relaxed text-slate-300 md:text-lg">
                        Um unico painel mostra data de risco e ajuda a priorizar qual ajuste tem maior impacto imediato.
                    </p>
                </div>
                <div class="md:col-span-7">
                    <div class="rounded-[1.8rem] border border-white/15 bg-white/5 p-6">
                        <div class="flex min-h-[210px] items-center justify-center rounded-2xl border border-dashed border-white/30 text-center text-sm text-slate-300">
                            Screenshot do dashboard de projecao
                            <br />
                            <!-- TODO: substituir por captura real -->
                        </div>
                        <p class="mt-5 inline-flex border-b border-red-400 pb-1 text-xs font-bold uppercase tracking-[0.14em] text-red-300">
                            Alerta de risco em 4 dias
                        </p>
                    </div>
                </div>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 py-14 md:px-6 md:py-20">
            <div class="grid gap-10 lg:grid-cols-12">
                <div class="lg:col-span-4">
                    <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Funcionalidades centrais</p>
                    <h2 class="mt-3 text-4xl leading-[0.95] tracking-tight text-slate-950 md:text-5xl">Base para decidir sem ruído</h2>
                </div>
                <div class="lg:col-span-8">
                    <ul class="divide-y divide-slate-200 border-y border-slate-200">
                        <li
                            v-for="(item, index) in keyFeatures"
                            :key="item"
                            class="py-5 text-lg leading-relaxed text-slate-700 md:flex md:items-start md:gap-4 md:text-2xl"
                        >
                            <span class="inline-block w-14 text-sm font-bold uppercase tracking-[0.14em] text-slate-400 md:pt-2">0{{ index + 1 }}</span>
                            <span>{{ item }}</span>
                        </li>
                    </ul>
                </div>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 pb-14 md:px-6 md:pb-20">
            <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Quem ja usa</p>
            <div class="mt-6 grid gap-4 md:grid-cols-3">
                <article
                    v-for="person in testimonials"
                    :key="person.name"
                    class="border-t-2 border-slate-900 pt-5"
                >
                    <p class="text-xl leading-relaxed text-slate-700">"{{ person.quote }}"</p>
                    <p class="mt-4 text-sm font-semibold text-slate-900">{{ person.name }}</p>
                    <p class="text-xs uppercase tracking-[0.12em] text-slate-500">{{ person.role }}</p>
                </article>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 pb-14 md:px-6 md:pb-20">
            <div class="overflow-x-auto border-y border-slate-200 py-8">
                <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Comparacao honesta</p>
                <table class="mt-4 min-w-full text-sm">
                    <thead>
                        <tr class="border-b border-slate-200 text-left text-xs uppercase tracking-[0.14em] text-slate-500">
                            <th class="pb-3 pr-4">Criterio</th>
                            <th class="pb-3 pr-4">Outros apps</th>
                            <th class="pb-3">Kitamo</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="row in comparisonRows" :key="row.feature" class="border-b border-slate-100">
                            <td class="py-3 pr-4 font-semibold text-slate-900">{{ row.feature }}</td>
                            <td class="py-3 pr-4 text-slate-600">{{ row.others }}</td>
                            <td class="py-3 font-semibold text-emerald-700">{{ row.kitamo }}</td>
                        </tr>
                    </tbody>
                </table>
                <p class="mt-4 text-xs text-slate-500">Outros apps incluem Mobills, Organizze e similares.</p>
            </div>
        </section>

        <section class="bg-white py-14 md:py-16">
            <div class="mx-auto w-full max-w-[1320px] px-5 md:px-6">
                <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500 text-center">Precos</p>
                <h2 class="mt-3 text-center text-4xl leading-[0.95] tracking-tight text-slate-950 md:text-5xl">Escolha seu ritmo de controle</h2>
                <div class="mt-8">
                    <PricingBlock :plans="pricingPlans" :can-register="canRegister" />
                </div>
            </div>
        </section>

        <section class="bg-emerald-400 py-16 md:py-20">
            <div class="mx-auto w-full max-w-[1320px] px-5 text-center md:px-6">
                <h2 class="text-5xl leading-[0.88] tracking-[-0.03em] text-slate-950 md:text-6xl">Comece a projetar seu mes hoje</h2>
                <p class="mx-auto mt-4 max-w-3xl text-base leading-relaxed text-slate-900/80 md:text-lg">
                    Plano Essencial gratis para sempre. Upgrade apenas quando precisar de mais profundidade.
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

<style scoped>
.hero-stage {
    background:
        radial-gradient(22rem 22rem at 10% 0%, rgba(16, 185, 129, 0.18), transparent 72%),
        linear-gradient(180deg, rgba(255, 255, 255, 0.94), rgba(241, 245, 249, 0.88));
}
</style>
