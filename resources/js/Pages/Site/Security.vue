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
        description:
            'Todo trafego da plataforma utiliza TLS 1.3 e os dados persistidos seguem criptografia AES-256.',
        detail: 'Protecao aplicada da camada de rede ate a persistencia de dados.',
    },
    {
        title: 'Isolamento por conta de usuario',
        description:
            'Cada conta possui segregacao logica no banco para evitar cruzamento de informacao entre clientes.',
        detail: 'Arquitetura orientada a isolamento, com politicas de acesso por contexto.',
    },
    {
        title: 'Sem conexao bancaria automatica',
        description:
            'O Kitamo nao utiliza Open Finance nem conecta diretamente em bancos. O controle e manual por design.',
        detail: 'Mais previsibilidade operacional e dominio total do que entra no sistema.',
    },
    {
        title: 'Infraestrutura com redundancia',
        description:
            'Ambiente em nuvem com monitoramento, backup e rotina de continuidade para reduzir risco operacional.',
        detail: 'Operacao acompanhada por eventos, alertas e mecanismos de recuperacao.',
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
            content="Controles de seguranca e privacidade da Kitamo com foco em isolamento de dados, criptografia e conformidade com LGPD."
        />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[1320px] px-5 pb-16 pt-10 md:px-6 md:pb-20 md:pt-16">
            <div class="grid gap-10 lg:grid-cols-12 lg:gap-16">
                <aside class="lg:col-span-4 lg:sticky lg:top-32 lg:h-fit">
                    <p class="inline-flex items-center gap-2 rounded-full border border-emerald-300 bg-emerald-100/70 px-4 py-2 text-[11px] font-bold uppercase tracking-[0.14em] text-emerald-800">
                        <span class="h-2 w-2 rounded-full bg-emerald-500"></span>
                        Security Review
                    </p>
                    <h1 class="mt-6 text-6xl leading-[0.9] tracking-[-0.04em] text-slate-950 md:text-7xl">
                        Segurança sem
                        <span class="font-serif italic text-emerald-600">espetáculo</span>.
                    </h1>
                    <p class="mt-6 max-w-lg text-lg leading-relaxed text-slate-600 md:text-xl">
                        A engenharia de seguranca foi pensada para proteger dados financeiros com consistencia tecnica e clareza operacional.
                    </p>
                    <Link
                        :href="route('site.contact')"
                        class="mt-8 inline-flex h-11 items-center justify-center rounded-full border border-slate-300 px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-slate-800 transition hover:border-slate-950"
                    >
                        Falar com o time tecnico
                    </Link>
                </aside>

                <div class="lg:col-span-8">
                    <ol class="security-rail">
                        <li
                            v-for="(item, index) in controls"
                            :key="item.title"
                            class="group relative border-b border-slate-200 py-10 pl-12 first:pt-2"
                        >
                            <span class="absolute left-0 top-10 text-4xl font-semibold tracking-tight text-slate-300 transition group-hover:text-emerald-600 md:text-5xl">
                                0{{ index + 1 }}
                            </span>
                            <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Controle critico</p>
                            <h2 class="mt-2 text-3xl leading-tight tracking-tight text-slate-950 md:text-5xl">{{ item.title }}</h2>
                            <p class="mt-4 max-w-3xl text-base leading-relaxed text-slate-600 md:text-lg">{{ item.description }}</p>
                            <p class="mt-4 text-sm font-semibold uppercase tracking-[0.12em] text-slate-500">{{ item.detail }}</p>
                        </li>
                    </ol>
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
                        Privacidade nao e um bloco extra. E parte da arquitetura, das politicas e da operacao diaria do produto.
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

        <section class="mx-auto w-full max-w-[1320px] px-5 pb-20 pt-10 md:px-6 md:pb-24 md:pt-14">
            <div class="grid overflow-hidden rounded-[2rem] border border-slate-200 md:grid-cols-2">
                <Link
                    :href="route('site.privacy')"
                    class="group relative bg-white px-8 py-12 transition hover:bg-slate-50"
                >
                    <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Documento legal</p>
                    <h3 class="mt-3 text-4xl tracking-tight text-slate-950">Privacidade</h3>
                    <p class="mt-3 max-w-md text-base text-slate-600">Como dados sao coletados, protegidos, processados e removidos.</p>
                    <span class="mt-6 inline-flex border-b border-emerald-500 text-xs font-bold uppercase tracking-[0.14em] text-slate-900">Abrir documento</span>
                </Link>
                <Link
                    :href="route('site.terms')"
                    class="group relative border-t border-slate-200 bg-slate-50 px-8 py-12 transition hover:bg-white md:border-l md:border-t-0"
                >
                    <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Documento legal</p>
                    <h3 class="mt-3 text-4xl tracking-tight text-slate-950">Termos</h3>
                    <p class="mt-3 max-w-md text-base text-slate-600">Regras de acesso, assinatura, cancelamento e responsabilidades.</p>
                    <span class="mt-6 inline-flex border-b border-emerald-500 text-xs font-bold uppercase tracking-[0.14em] text-slate-900">Abrir documento</span>
                </Link>
            </div>
        </section>
    </SiteLayout>
</template>

<style scoped>
.security-rail {
    position: relative;
}

.security-rail::before {
    content: '';
    position: absolute;
    left: 18px;
    top: 0;
    bottom: 0;
    width: 1px;
    background: linear-gradient(180deg, rgba(148, 163, 184, 0), rgba(148, 163, 184, 0.8), rgba(148, 163, 184, 0));
}

@media (max-width: 767px) {
    .security-rail::before {
        display: none;
    }
}
</style>
