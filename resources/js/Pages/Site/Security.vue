<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const controls = [
    {
        title: 'Criptografia em transito e em repouso',
        description: 'Todo trafego utiliza TLS 1.3 e os dados persistidos seguem criptografia AES-256.',
    },
    {
        title: 'Isolamento por conta de usuario',
        description: 'Cada conta possui segregacao logica para evitar cruzamento de informacao entre clientes.',
    },
    {
        title: 'Sem conexao bancaria automatica',
        description: 'O Kitamo nao usa Open Finance. O controle e manual para manter previsibilidade e dominio.',
    },
    {
        title: 'Infraestrutura com redundancia',
        description: 'Monitoramento, backup e mecanismos de continuidade para reduzir risco operacional.',
    },
];

const securityFlow = [
    {
        step: '01',
        title: 'Prevenir',
        text: 'Padroes de desenvolvimento e controle de acesso para reduzir superficie de risco.',
    },
    {
        step: '02',
        title: 'Detectar',
        text: 'Monitoramento de eventos para identificar comportamento anomalo rapidamente.',
    },
    {
        step: '03',
        title: 'Responder',
        text: 'Fluxo de resposta para incidentes com prioridade por impacto.',
    },
    {
        step: '04',
        title: 'Evoluir',
        text: 'Revisao continua de controles e processo para fortalecer a plataforma.',
    },
];

const lgpd = [
    'Solicitacao de exclusao total a qualquer momento.',
    'Acesso, correcao e exportacao de dados conforme LGPD.',
    'Sem venda de dados para publicidade ou perfilamento.',
];
</script>

<template>
    <Head title="Seguranca | Kitamo">
        <meta
            name="description"
            content="Controles de seguranca e privacidade da Kitamo com isolamento de dados, criptografia e conformidade com LGPD."
        />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[1320px] px-5 pb-14 pt-10 md:px-6 md:pb-20 md:pt-16">
            <div class="security-hero relative overflow-hidden rounded-[2.2rem] border border-slate-200 p-6 md:p-8">
                <div class="grid items-center gap-8 md:grid-cols-12">
                    <div class="md:col-span-6 text-white">
                        <p class="inline-flex items-center gap-2 rounded-full border border-emerald-300/40 bg-emerald-500/10 px-4 py-2 text-[11px] font-bold uppercase tracking-[0.14em] text-emerald-300">
                            <span class="h-2 w-2 rounded-full bg-emerald-300"></span>
                            Security Review
                        </p>
                        <h1 class="mt-5 text-5xl leading-[0.9] tracking-[-0.03em] md:text-6xl">
                            Seguranca com
                            <span class="font-serif italic text-emerald-300">metodo</span>.
                        </h1>
                        <p class="mt-5 max-w-xl text-base leading-relaxed text-slate-300 md:text-lg">
                            A arquitetura de seguranca foi desenhada para proteger dados financeiros com consistencia tecnica e operacao continua.
                        </p>
                        <div class="mt-7 flex flex-wrap gap-3">
                            <Link
                                :href="route('site.contact')"
                                class="inline-flex h-11 items-center justify-center rounded-full bg-emerald-400 px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-slate-950 transition hover:bg-emerald-300"
                            >
                                Falar com o time tecnico
                            </Link>
                            <Link
                                :href="route('site.privacy')"
                                class="inline-flex h-11 items-center justify-center rounded-full border border-white/30 px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-white transition hover:border-white"
                            >
                                Ler privacidade
                            </Link>
                        </div>
                    </div>

                    <div class="md:col-span-6">
                        <img
                            src="https://images.pexels.com/photos/3184465/pexels-photo-3184465.jpeg?auto=compress&cs=tinysrgb&w=1200"
                            alt="Equipe revisando operacao e seguranca"
                            class="h-[340px] w-full rounded-[1.6rem] object-cover md:h-[420px]"
                            loading="lazy"
                        />
                    </div>
                </div>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 pb-14 md:px-6 md:pb-20">
            <div class="grid gap-10 lg:grid-cols-12 lg:gap-14">
                <aside class="lg:col-span-4 lg:sticky lg:top-28 lg:h-fit">
                    <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Controles criticos</p>
                    <h2 class="mt-3 text-4xl leading-[0.95] tracking-tight text-slate-950 md:text-5xl">
                        Base tecnica da protecao de dados
                    </h2>
                </aside>

                <div class="lg:col-span-8">
                    <article
                        v-for="(item, index) in controls"
                        :key="item.title"
                        class="grid gap-6 border-t border-slate-200 py-8 first:border-t-0 first:pt-0 md:grid-cols-12"
                    >
                        <p class="md:col-span-2 text-3xl font-semibold tracking-tight text-slate-300">0{{ index + 1 }}</p>
                        <div class="md:col-span-10">
                            <h3 class="text-4xl leading-tight tracking-tight text-slate-950 md:text-5xl">{{ item.title }}</h3>
                            <p class="mt-4 max-w-3xl text-base leading-relaxed text-slate-600 md:text-lg">{{ item.description }}</p>
                        </div>
                    </article>
                </div>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1320px] px-5 pb-14 md:px-6 md:pb-20">
            <div class="grid gap-8 rounded-[2rem] border border-slate-200 bg-white p-6 md:grid-cols-12 md:p-8">
                <div class="md:col-span-6">
                    <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Fluxo de seguranca</p>
                    <h2 class="mt-3 text-4xl leading-[0.95] tracking-tight text-slate-950 md:text-5xl">Ciclo continuo de prevencao e resposta</h2>

                    <ol class="flow mt-7 space-y-6 pl-10">
                        <li v-for="step in securityFlow" :key="step.step" class="relative">
                            <span class="absolute -left-10 top-0 inline-flex h-8 w-8 items-center justify-center rounded-full bg-emerald-500 text-xs font-bold text-white shadow-[0_0_0_6px_rgba(16,185,129,0.14)]">
                                {{ step.step }}
                            </span>
                            <h3 class="text-2xl tracking-tight text-slate-950">{{ step.title }}</h3>
                            <p class="mt-2 text-sm leading-relaxed text-slate-600 md:text-base">{{ step.text }}</p>
                        </li>
                    </ol>
                </div>

                <div class="md:col-span-6">
                    <div class="grid h-full gap-3 md:grid-cols-2">
                        <img
                            src="https://images.pexels.com/photos/3184418/pexels-photo-3184418.jpeg?auto=compress&cs=tinysrgb&w=900"
                            alt="Pessoa em call de revisao"
                            class="h-52 w-full rounded-[1.2rem] object-cover md:h-full"
                            loading="lazy"
                        />
                        <img
                            src="https://images.pexels.com/photos/3184338/pexels-photo-3184338.jpeg?auto=compress&cs=tinysrgb&w=900"
                            alt="Equipe discutindo operacao"
                            class="h-52 w-full rounded-[1.2rem] object-cover md:h-full"
                            loading="lazy"
                        />
                    </div>
                </div>
            </div>
        </section>

        <section class="relative overflow-hidden bg-slate-950 py-16 text-white md:py-20">
            <div class="absolute -right-20 top-0 h-80 w-80 rounded-full bg-emerald-500/20 blur-3xl"></div>
            <div class="mx-auto grid w-full max-w-[1320px] gap-10 px-5 md:grid-cols-12 md:px-6">
                <div class="md:col-span-5">
                    <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-emerald-300">LGPD</p>
                    <h2 class="mt-4 text-4xl leading-[0.95] tracking-[-0.03em] md:text-5xl">Conformidade como baseline</h2>
                    <p class="mt-4 text-base leading-relaxed text-slate-300 md:text-lg">
                        Privacidade nao e um bloco extra. E parte da arquitetura, das politicas e da operacao diaria.
                    </p>
                </div>
                <div class="md:col-span-7">
                    <ul class="divide-y divide-white/10 border-y border-white/10">
                        <li v-for="item in lgpd" :key="item" class="py-5 text-base leading-relaxed text-slate-200 md:text-lg">
                            {{ item }}
                        </li>
                    </ul>
                    <div class="mt-7 flex flex-wrap gap-3">
                        <Link
                            :href="route('site.privacy')"
                            class="inline-flex h-11 items-center justify-center rounded-full bg-white px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-slate-950 transition hover:bg-emerald-300"
                        >
                            Politica de privacidade
                        </Link>
                        <Link
                            :href="route('site.terms')"
                            class="inline-flex h-11 items-center justify-center rounded-full border border-white/30 px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-white transition hover:border-white"
                        >
                            Termos de uso
                        </Link>
                    </div>
                </div>
            </div>
        </section>
    </SiteLayout>
</template>

<style scoped>
.security-hero {
    background:
        radial-gradient(30rem 24rem at 8% 0%, rgba(16, 185, 129, 0.2), transparent 72%),
        linear-gradient(145deg, #020617 0%, #0f172a 60%, #111827 100%);
}

.flow {
    position: relative;
}

.flow::before {
    content: '';
    position: absolute;
    left: 15px;
    top: 0;
    bottom: 0;
    width: 2px;
    background: linear-gradient(180deg, rgba(16, 185, 129, 0.08), rgba(16, 185, 129, 0.5), rgba(16, 185, 129, 0.08));
}
</style>
