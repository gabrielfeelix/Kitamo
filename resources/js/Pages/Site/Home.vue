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

const destinationCards = [
    {
        title: 'Autonomos',
        subtitle: 'Receita irregular',
        description: 'Organize entradas variaveis e veja os dias de maior pressao antes do fechamento.',
        image: 'https://images.pexels.com/photos/3760263/pexels-photo-3760263.jpeg?auto=compress&cs=tinysrgb&w=900',
    },
    {
        title: 'Casais',
        subtitle: 'Planejamento conjunto',
        description: 'Consolidem contas e compromissos para reduzir surpresas no fim do mes.',
        image: 'https://images.pexels.com/photos/572056/pexels-photo-572056.jpeg?auto=compress&cs=tinysrgb&w=900',
    },
    {
        title: 'Profissionais CLT',
        subtitle: 'Controle por ciclo',
        description: 'Conecte salario, fatura e recorrencias em uma rotina previsivel de decisao.',
        image: 'https://images.pexels.com/photos/1184572/pexels-photo-1184572.jpeg?auto=compress&cs=tinysrgb&w=900',
    },
];

const timeline = [
    {
        number: '01',
        title: 'Cadastre contas e cartoes',
        description: 'Corrente, poupanca, carteira e cartoes para montar a base do fluxo.',
    },
    {
        number: '02',
        title: 'Lance receitas e despesas',
        description: 'Registre movimentacoes, recorrencias e parcelamentos em poucos passos.',
    },
    {
        number: '03',
        title: 'Leia o risco por data',
        description: 'A projecao mostra em que dia o saldo pode entrar em zona critica.',
    },
    {
        number: '04',
        title: 'Ajuste rota com antecedencia',
        description: 'Corte, adie ou redistribua gastos antes da fatura fechar no vermelho.',
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
            content="Kitamo e o app de financas pessoais focado em projecao de caixa para decidir antes da falta de saldo."
        />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[1320px] px-5 pb-14 pt-10 md:px-6 md:pb-20 md:pt-16">
            <div class="hero-panel relative overflow-hidden rounded-[2.2rem] border border-slate-200 p-6 md:p-8">
                <div class="grid items-center gap-8 lg:grid-cols-12">
                    <div class="lg:col-span-6">
                        <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-emerald-300">Projecao financeira pessoal</p>
                        <h1 class="mt-4 text-5xl leading-[0.9] tracking-[-0.03em] text-white md:text-6xl">
                            Antecipe o mes.
                            <span class="block font-serif italic text-emerald-300">Nao espere o susto.</span>
                        </h1>
                        <p class="mt-5 max-w-xl text-base leading-relaxed text-slate-300 md:text-lg">
                            O Kitamo transforma seu controle manual em visao de futuro: voce enxerga risco por data e decide antes do caixa apertar.
                        </p>
                        <div class="mt-7 flex flex-wrap gap-3">
                            <Link
                                :href="primaryHref"
                                class="inline-flex h-11 items-center justify-center rounded-full bg-emerald-400 px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-slate-950 transition hover:bg-emerald-300"
                            >
                                Comecar gratis
                            </Link>
                            <Link
                                :href="route('site.product') + '#demo'"
                                class="inline-flex h-11 items-center justify-center rounded-full border border-white/30 px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-white transition hover:border-white"
                            >
                                Ver demonstracao
                            </Link>
                        </div>

                        <div class="mt-8 grid max-w-md grid-cols-3 gap-3 text-white">
                            <div>
                                <p class="text-3xl font-semibold tracking-tight">30d</p>
                                <p class="text-xs uppercase tracking-[0.12em] text-slate-400">Projecao base</p>
                            </div>
                            <div>
                                <p class="text-3xl font-semibold tracking-tight">90d</p>
                                <p class="text-xs uppercase tracking-[0.12em] text-slate-400">No plano Pro</p>
                            </div>
                            <div>
                                <p class="text-3xl font-semibold tracking-tight">5a</p>
                                <p class="text-xs uppercase tracking-[0.12em] text-slate-400">Visionario</p>
                            </div>
                        </div>
                    </div>

                    <div class="lg:col-span-6">
                        <div class="relative overflow-hidden rounded-[1.8rem] border border-white/10 bg-slate-900/80">
                            <img
                                src="https://images.pexels.com/photos/1184572/pexels-photo-1184572.jpeg?auto=compress&cs=tinysrgb&w=1400"
                                alt="Pessoa usando notebook para planejamento financeiro"
                                class="h-[360px] w-full object-cover object-center md:h-[460px]"
                                loading="lazy"
                            />
                            <div class="absolute inset-0 bg-gradient-to-t from-slate-950/80 via-slate-950/10 to-transparent"></div>
                            <div class="absolute bottom-4 left-4 right-4 rounded-2xl border border-white/15 bg-slate-950/70 p-4 backdrop-blur">
                                <p class="text-[11px] font-bold uppercase tracking-[0.14em] text-emerald-300">Alerta inteligente</p>
                                <p class="mt-1 text-sm text-slate-200">Risco de saldo negativo em 27/03. Ajuste recomendado: reduzir despesa variavel em R$ 320.</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 pb-14 md:px-6 md:pb-20">
            <div class="grid gap-6 md:grid-cols-12 md:items-end">
                <div class="md:col-span-5">
                    <h2 class="text-4xl leading-[0.95] tracking-tight text-slate-950 md:text-5xl">Diferentes rotinas. Mesma necessidade de clareza.</h2>
                </div>
                <p class="md:col-span-4 text-base leading-relaxed text-slate-600">
                    O produto foi desenhado para cenarios reais de renda, fatura e recorrencias. Sem jargao, sem setup complexo.
                </p>
                <p class="md:col-span-3 text-sm font-bold uppercase tracking-[0.14em] text-slate-700 md:text-right">
                    Aplicacoes praticas
                </p>
            </div>

            <div class="mt-7 grid gap-4 md:grid-cols-3">
                <article
                    v-for="item in destinationCards"
                    :key="item.title"
                    class="group overflow-hidden rounded-[1.6rem] border border-slate-200 bg-white"
                >
                    <div class="relative h-60 overflow-hidden">
                        <img
                            :src="item.image"
                            :alt="item.title"
                            class="h-full w-full object-cover transition duration-700 group-hover:scale-105"
                            loading="lazy"
                        />
                        <span class="absolute left-3 top-3 rounded-full bg-white/90 px-3 py-1 text-[11px] font-bold uppercase tracking-[0.12em] text-slate-800">Uso real</span>
                    </div>
                    <div class="p-5">
                        <p class="text-xs font-bold uppercase tracking-[0.12em] text-emerald-700">{{ item.subtitle }}</p>
                        <h3 class="mt-2 text-3xl leading-tight tracking-tight text-slate-950">{{ item.title }}</h3>
                        <p class="mt-3 text-sm leading-relaxed text-slate-600">{{ item.description }}</p>
                    </div>
                </article>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 pb-14 md:px-6 md:pb-20">
            <div class="grid gap-10 rounded-[2rem] border border-slate-200 bg-white p-6 md:grid-cols-12 md:p-8">
                <div class="md:col-span-6">
                    <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Como comecar</p>
                    <h2 class="mt-3 text-4xl leading-[0.95] tracking-tight text-slate-950 md:text-5xl">Da configuracao a decisao em poucos passos</h2>

                    <ol class="timeline mt-7 space-y-7 pl-10">
                        <li
                            v-for="(step, idx) in timeline"
                            :key="step.number"
                            class="relative"
                        >
                            <span class="absolute -left-10 top-0 inline-flex h-8 w-8 items-center justify-center rounded-full bg-emerald-500 text-xs font-bold text-white shadow-[0_0_0_6px_rgba(16,185,129,0.14)]">
                                {{ step.number }}
                            </span>
                            <h3 class="text-2xl leading-tight tracking-tight text-slate-950">{{ step.title }}</h3>
                            <p class="mt-2 text-sm leading-relaxed text-slate-600 md:text-base">{{ step.description }}</p>
                            <div
                                v-if="idx === timeline.length - 1"
                                class="mt-4 rounded-2xl bg-emerald-500 px-4 py-3 text-sm font-medium text-white"
                            >
                                Resultado: voce fecha o mes com visibilidade de risco e acao priorizada.
                            </div>
                        </li>
                    </ol>
                </div>

                <div class="md:col-span-6">
                    <div class="rounded-[1.6rem] bg-[#d9ecff] p-4 md:p-6">
                        <img
                            src="https://images.pexels.com/photos/834863/pexels-photo-834863.jpeg?auto=compress&cs=tinysrgb&w=1200"
                            alt="Pessoa usando smartphone para acompanhar informacoes"
                            class="h-[420px] w-full rounded-[1.3rem] object-cover object-center"
                            loading="lazy"
                        />
                    </div>
                </div>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 pb-14 md:px-6 md:pb-20">
            <div class="dark-stat relative overflow-hidden rounded-[2rem] border border-slate-900 p-6 md:p-8">
                <div class="grid items-center gap-8 md:grid-cols-12">
                    <div class="md:col-span-5">
                        <div class="rounded-[1.2rem] bg-white/95 p-5 text-slate-900">
                            <p class="text-3xl font-semibold tracking-tight">+150 mil</p>
                            <p class="mt-1 text-sm text-slate-600">decisoes financeiras apoiadas</p>
                            <div class="mt-4 h-28 rounded-xl bg-gradient-to-br from-emerald-100 to-emerald-50 p-4">
                                <svg viewBox="0 0 200 80" class="h-full w-full" aria-hidden="true">
                                    <path d="M0 62 C20 55, 32 28, 52 36 C72 44, 95 74, 118 48 C140 22, 165 26, 200 14" fill="none" stroke="#10b981" stroke-width="4" stroke-linecap="round" />
                                </svg>
                            </div>
                        </div>
                    </div>
                    <div class="md:col-span-7 text-white">
                        <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-emerald-300">Estatisticas</p>
                        <h2 class="mt-3 max-w-2xl text-4xl leading-[0.95] tracking-tight md:text-5xl">
                            Maximize o potencial do seu mes com projecao de caixa.
                        </h2>
                        <p class="mt-4 max-w-2xl text-base leading-relaxed text-slate-300 md:text-lg">
                            O Kitamo nao e mais um painel de historico. E uma ferramenta de antecipacao para decidir antes do impacto.
                        </p>
                        <div class="mt-7 flex flex-wrap gap-3">
                            <Link
                                :href="primaryHref"
                                class="inline-flex h-11 items-center justify-center rounded-full bg-emerald-400 px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-slate-950 transition hover:bg-emerald-300"
                            >
                                Criar conta
                            </Link>
                            <Link
                                :href="route('site.contact')"
                                class="inline-flex h-11 items-center justify-center rounded-full border border-white/30 px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-white transition hover:border-white"
                            >
                                Falar com especialista
                            </Link>
                        </div>
                    </div>
                </div>
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
                <p class="text-[11px] text-center font-bold uppercase tracking-[0.16em] text-slate-500">Precos</p>
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
.hero-panel {
    background:
        radial-gradient(34rem 24rem at 12% 0%, rgba(16, 185, 129, 0.2), transparent 72%),
        linear-gradient(140deg, #030712 0%, #0f172a 58%, #111827 100%);
}

.dark-stat {
    background:
        radial-gradient(26rem 20rem at 10% 100%, rgba(16, 185, 129, 0.18), transparent 76%),
        linear-gradient(140deg, #030712 0%, #020617 100%);
}

.timeline {
    position: relative;
}

.timeline::before {
    content: '';
    position: absolute;
    left: 15px;
    top: 0;
    bottom: 0;
    width: 2px;
    background: linear-gradient(180deg, rgba(16, 185, 129, 0.08), rgba(16, 185, 129, 0.5), rgba(16, 185, 129, 0.08));
}
</style>
