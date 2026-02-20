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
        subtitle: 'Renda irregular',
        description: 'Antecipe semanas de maior pressao antes do fechamento de caixa.',
        image: 'https://images.pexels.com/photos/3760263/pexels-photo-3760263.jpeg?auto=compress&cs=tinysrgb&w=900',
    },
    {
        title: 'Casais',
        subtitle: 'Planejamento conjunto',
        description: 'Consolidem gastos fixos e variaveis com um plano unico de decisao.',
        image: 'https://images.pexels.com/photos/572056/pexels-photo-572056.jpeg?auto=compress&cs=tinysrgb&w=900',
    },
    {
        title: 'Profissionais CLT',
        subtitle: 'Ciclo mensal',
        description: 'Conecte salario, fatura e recorrencias com previsibilidade diaria.',
        image: 'https://images.pexels.com/photos/1184572/pexels-photo-1184572.jpeg?auto=compress&cs=tinysrgb&w=900',
    },
];

const flowTimeline = [
    {
        number: '01',
        title: 'Configurar base financeira',
        text: 'Cadastre contas, cartoes, recorrencias e categorias em uma estrutura unica.',
    },
    {
        number: '02',
        title: 'Ativar rotina de lancamentos',
        text: 'Mantenha entradas e saidas atualizadas com pouco atrito no dia a dia.',
    },
    {
        number: '03',
        title: 'Ler risco por data',
        text: 'A projecao mostra em que dia o saldo pode entrar em zona critica.',
    },
    {
        number: '04',
        title: 'Executar ajuste semanal',
        text: 'Priorize cortes e redistribuicoes antes da fatura travar seu mes.',
    },
];

const splitShowcase = [
    {
        tag: '/Sobre',
        title: 'Aproximamos voce da sua previsao real',
        description: 'Painel orientado a decisao com leitura de saldo projetado e alertas por data.',
        image: 'https://images.pexels.com/photos/3184338/pexels-photo-3184338.jpeg?auto=compress&cs=tinysrgb&w=1200',
    },
    {
        tag: '/Cases',
        title: 'Resultados praticos de uso continuo',
        description: 'Rotina semanal curta para manter clareza financeira sem voltar para planilhas.',
        image: 'https://images.pexels.com/photos/3184418/pexels-photo-3184418.jpeg?auto=compress&cs=tinysrgb&w=1200',
    },
];

const serviceBlocks = [
    {
        title: 'Leitura de saldo em tempo real',
        description: 'Visao objetiva dos proximos dias para agir antes do vencimento.',
        background: 'bg-emerald-100/70',
    },
    {
        title: 'Analise de risco por data',
        description: 'Pontos de pressao financeira destacados com prioridade de acao.',
        background: 'bg-slate-100',
    },
    {
        title: 'Rotina guiada de ajuste',
        description: 'Passos semanais para manter o caixa previsivel sem sobrecarga.',
        background: 'bg-emerald-100/70',
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
        <section class="relative mx-auto w-full max-w-[1360px] px-5 pb-14 pt-10 md:px-6 md:pb-20 md:pt-16">
            <div class="pointer-events-none absolute bottom-12 left-0 top-12 hidden w-10 rounded-r-2xl bg-emerald-100/85 xl:block"></div>
            <div class="pointer-events-none absolute bottom-12 right-0 top-12 hidden w-10 rounded-l-2xl bg-emerald-100/60 xl:block"></div>

            <div class="hero-shell relative overflow-hidden rounded-[2.2rem] border border-slate-200 p-6 md:p-8">
                <div class="grid items-center gap-8 md:grid-cols-12">
                    <div class="md:col-span-6 text-white">
                        <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-emerald-300">Projecao financeira pessoal</p>
                        <h1 class="mt-4 text-5xl leading-[0.9] tracking-[-0.03em] md:text-6xl">
                            O mes nao precisa
                            <span class="block font-serif italic text-emerald-300">te surpreender.</span>
                        </h1>
                        <p class="mt-5 max-w-xl text-base leading-relaxed text-slate-300 md:text-lg">
                            O Kitamo transforma controle manual em visao de futuro para voce decidir antes do caixa apertar.
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

                        <div class="mt-8 grid max-w-md grid-cols-3 gap-4">
                            <div>
                                <p class="text-3xl font-semibold tracking-tight">30d</p>
                                <p class="text-xs uppercase tracking-[0.12em] text-slate-400">Essencial</p>
                            </div>
                            <div>
                                <p class="text-3xl font-semibold tracking-tight">90d</p>
                                <p class="text-xs uppercase tracking-[0.12em] text-slate-400">Pro</p>
                            </div>
                            <div>
                                <p class="text-3xl font-semibold tracking-tight">5a</p>
                                <p class="text-xs uppercase tracking-[0.12em] text-slate-400">Visionario</p>
                            </div>
                        </div>
                    </div>

                    <div class="md:col-span-6">
                        <div class="relative overflow-hidden rounded-[1.8rem] border border-white/10 bg-slate-900">
                            <div class="hero-diagonal absolute -right-16 -top-16 h-[150%] w-[75%]"></div>
                            <img
                                src="https://images.pexels.com/photos/3184433/pexels-photo-3184433.jpeg?auto=compress&cs=tinysrgb&w=1400"
                                alt="Pessoa em reuniao analisando indicadores"
                                class="relative z-10 h-[360px] w-full object-cover object-center md:h-[430px]"
                                loading="lazy"
                            />
                            <div class="absolute bottom-4 left-4 right-4 z-20 rounded-2xl border border-white/15 bg-slate-950/70 p-4 backdrop-blur">
                                <p class="text-[11px] font-bold uppercase tracking-[0.14em] text-emerald-300">Alerta inteligente</p>
                                <p class="mt-1 text-sm text-slate-200">Risco de saldo negativo em 27/03. Ajuste recomendado: reduzir variavel em R$ 320.</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 pb-14 md:px-6 md:pb-20">
            <div class="grid gap-6 md:grid-cols-12 md:items-end">
                <div class="md:col-span-5">
                    <h2 class="text-4xl leading-[0.95] tracking-tight text-slate-950 md:text-5xl">Diferentes perfis, a mesma clareza de caixa.</h2>
                </div>
                <p class="md:col-span-4 text-base leading-relaxed text-slate-600">
                    O produto acompanha diferentes perfis sem mudar a pergunta central: o plano financeiro do mes esta sustentavel?
                </p>
                <p class="md:col-span-3 text-sm font-bold uppercase tracking-[0.14em] text-slate-700 md:text-right">Aplicacoes reais</p>
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
                        <span class="absolute left-3 top-3 rounded-full bg-white/90 px-3 py-1 text-[11px] font-bold uppercase tracking-[0.12em] text-slate-800">Perfil</span>
                    </div>
                    <div class="p-5">
                        <p class="text-xs font-bold uppercase tracking-[0.12em] text-emerald-700">{{ item.subtitle }}</p>
                        <h3 class="mt-2 text-3xl leading-tight tracking-tight text-slate-950">{{ item.title }}</h3>
                        <p class="mt-3 text-sm leading-relaxed text-slate-600">{{ item.description }}</p>
                    </div>
                </article>
            </div>
        </section>

        <section class="relative overflow-hidden bg-[#06180f] py-16 text-white md:py-20">
            <div class="pointer-events-none absolute inset-0 hidden xl:block">
                <img src="https://images.pexels.com/photos/3184291/pexels-photo-3184291.jpeg?auto=compress&cs=tinysrgb&w=700" alt="" class="float-shot float-a" aria-hidden="true" />
                <img src="https://images.pexels.com/photos/3184360/pexels-photo-3184360.jpeg?auto=compress&cs=tinysrgb&w=700" alt="" class="float-shot float-b" aria-hidden="true" />
                <img src="https://images.pexels.com/photos/3760067/pexels-photo-3760067.jpeg?auto=compress&cs=tinysrgb&w=700" alt="" class="float-shot float-c" aria-hidden="true" />
                <img src="https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=700" alt="" class="float-shot float-d" aria-hidden="true" />
            </div>

            <div class="mx-auto grid w-full max-w-[1320px] items-center gap-8 px-5 md:grid-cols-12 md:px-6">
                <div class="md:col-span-6">
                    <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-emerald-300">Tour operacional</p>
                    <h2 class="mt-3 text-4xl leading-[0.95] tracking-tight md:text-5xl">Da base de dados ao ajuste semanal</h2>

                    <ol class="flow-timeline mt-7 space-y-6 pl-10">
                        <li v-for="step in flowTimeline" :key="step.number" class="relative">
                            <span class="absolute -left-10 top-0 inline-flex h-8 w-8 items-center justify-center rounded-full bg-emerald-500 text-xs font-bold text-white shadow-[0_0_0_6px_rgba(16,185,129,0.14)]">
                                {{ step.number }}
                            </span>
                            <h3 class="text-2xl leading-tight tracking-tight">{{ step.title }}</h3>
                            <p class="mt-2 text-sm leading-relaxed text-slate-300 md:text-base">{{ step.text }}</p>
                        </li>
                    </ol>
                </div>

                <div class="md:col-span-6">
                    <div class="rounded-[1.8rem] bg-[#d9ecff] p-5 md:p-6">
                        <img
                            src="https://images.pexels.com/photos/1181519/pexels-photo-1181519.jpeg?auto=compress&cs=tinysrgb&w=1200"
                            alt="Pessoa acompanhando dados no smartphone"
                            class="h-[420px] w-full rounded-[1.3rem] object-cover"
                            loading="lazy"
                        />
                    </div>
                </div>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 py-14 md:px-6 md:py-20">
            <div class="grid gap-4 md:grid-cols-2">
                <article
                    v-for="item in splitShowcase"
                    :key="item.tag"
                    class="overflow-hidden rounded-[1.8rem] border border-slate-200 bg-white"
                >
                    <div class="p-6 md:p-7">
                        <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">{{ item.tag }}</p>
                        <h3 class="mt-3 text-4xl leading-[0.95] tracking-tight text-slate-950 md:text-5xl">{{ item.title }}</h3>
                        <p class="mt-4 text-sm leading-relaxed text-slate-600 md:text-base">{{ item.description }}</p>
                    </div>
                    <img
                        :src="item.image"
                        :alt="item.title"
                        class="h-56 w-full object-cover"
                        loading="lazy"
                    />
                </article>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 pb-14 md:px-6 md:pb-20">
            <div class="rounded-[1.8rem] border border-slate-200 bg-white p-6 md:p-8">
                <h2 class="text-4xl leading-[0.95] tracking-tight text-slate-950 md:text-5xl">Confira os nossos blocos de decisao</h2>
                <div class="mt-7 grid gap-4 md:grid-cols-3">
                    <article
                        v-for="item in serviceBlocks"
                        :key="item.title"
                        class="rounded-[1.3rem] p-5"
                        :class="item.background"
                    >
                        <h3 class="text-2xl leading-tight tracking-tight text-slate-900">{{ item.title }}</h3>
                        <p class="mt-3 text-sm leading-relaxed text-slate-600">{{ item.description }}</p>
                        <div class="mt-4 h-24 rounded-xl bg-white/80 p-3">
                            <svg viewBox="0 0 180 70" class="h-full w-full" aria-hidden="true">
                                <path d="M0 58 C15 42, 30 49, 48 30 C66 11, 80 24, 100 40 C120 56, 145 33, 180 20" fill="none" stroke="#16a34a" stroke-width="4" stroke-linecap="round" />
                            </svg>
                        </div>
                    </article>
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
.hero-shell {
    background:
        radial-gradient(34rem 24rem at 12% 0%, rgba(16, 185, 129, 0.2), transparent 72%),
        linear-gradient(140deg, #030712 0%, #0f172a 58%, #111827 100%);
}

.hero-diagonal {
    background: linear-gradient(145deg, rgba(16, 185, 129, 0.65), rgba(99, 102, 241, 0.6));
    transform: rotate(-18deg);
    border-radius: 2rem;
}

.flow-timeline {
    position: relative;
}

.flow-timeline::before {
    content: '';
    position: absolute;
    left: 15px;
    top: 0;
    bottom: 0;
    width: 2px;
    background: linear-gradient(180deg, rgba(16, 185, 129, 0.08), rgba(16, 185, 129, 0.5), rgba(16, 185, 129, 0.08));
}

.float-shot {
    position: absolute;
    width: 170px;
    border-radius: 1rem;
    border: 1px solid rgba(255, 255, 255, 0.24);
    box-shadow: 0 18px 45px rgba(2, 6, 23, 0.45);
    animation: drift 8s ease-in-out infinite;
}

.float-a {
    left: 4%;
    top: 16%;
    transform: rotate(-12deg);
}

.float-b {
    left: 10%;
    bottom: 18%;
    transform: rotate(10deg);
    animation-delay: 1.2s;
}

.float-c {
    right: 4%;
    top: 18%;
    transform: rotate(14deg);
    animation-delay: 2.2s;
}

.float-d {
    right: 10%;
    bottom: 15%;
    transform: rotate(-10deg);
    animation-delay: 0.8s;
}

.dark-stat {
    background:
        radial-gradient(26rem 20rem at 10% 100%, rgba(16, 185, 129, 0.18), transparent 76%),
        linear-gradient(140deg, #030712 0%, #020617 100%);
}

@keyframes drift {
    0%,
    100% {
        transform: translateY(0) rotate(var(--rotate, 0deg));
    }
    50% {
        transform: translateY(-10px) rotate(var(--rotate, 0deg));
    }
}

.float-a {
    --rotate: -12deg;
}

.float-b {
    --rotate: 10deg;
}

.float-c {
    --rotate: 14deg;
}

.float-d {
    --rotate: -10deg;
}
</style>
