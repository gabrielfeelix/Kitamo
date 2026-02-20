<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

const controls = [
    {
        title: 'Criptografia de ponta a ponta',
        description: 'Todos os dados trafegam em conexao segura (TLS 1.3) e sao protegidos em repouso com criptografia AES-256.',
    },
    {
        title: 'Dados isolados por usuario',
        description: 'Cada conta possui segregacao logica no banco de dados para evitar qualquer mistura de informacao entre usuarios.',
    },
    {
        title: 'Sem acesso bancario direto',
        description: 'O Kitamo nao conecta em bancos e nao usa Open Finance. O cadastro e manual e voce mantem controle total.',
    },
    {
        title: 'Hospedagem confiavel e backup',
        description: 'Infraestrutura em nuvem com monitoramento, redundancia e rotinas de backup para continuidade operacional.',
    },
];

const lgpd = [
    'Voce pode solicitar exclusao total dos seus dados a qualquer momento.',
    'Nao vendemos nem compartilhamos seus dados com terceiros para publicidade.',
    'Voce pode solicitar acesso, correcao ou exportacao dos seus dados quando quiser.',
];
</script>

<template>
    <Head title="Seguranca | Kitamo">
        <meta
            name="description"
            content="Conheca os controles de seguranca e privacidade da Kitamo para proteger seus dados financeiros."
        />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[1240px] px-5 pb-12 pt-10 md:px-6 md:pb-16 md:pt-16">
            <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Seguranca</p>
            <h1 class="mt-5 max-w-4xl text-5xl leading-[0.92] tracking-[-0.03em] text-slate-950 md:text-6xl">
                Seguranca que voce pode confiar
            </h1>
            <p class="mt-6 max-w-3xl text-lg leading-relaxed text-slate-600 md:text-xl">
                Seus dados financeiros protegidos com controles tecnicos e processos alinhados a padroes de mercado.
            </p>
        </section>

        <section class="mx-auto w-full max-w-[1240px] px-5 py-6 md:px-6 md:py-8">
            <div class="grid gap-4 md:grid-cols-2">
                <article
                    v-for="item in controls"
                    :key="item.title"
                    class="rounded-3xl border border-slate-200 bg-white/80 p-7"
                >
                    <h2 class="text-2xl tracking-tight text-slate-950">{{ item.title }}</h2>
                    <p class="mt-3 text-sm leading-relaxed text-slate-600 md:text-base">{{ item.description }}</p>
                </article>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1240px] px-5 py-12 md:px-6 md:py-16">
            <div class="rounded-3xl border border-emerald-200 bg-emerald-50/70 p-7 md:p-9">
                <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-emerald-700">LGPD</p>
                <h2 class="mt-3 text-3xl leading-tight tracking-tight text-slate-950 md:text-4xl">Em conformidade com a LGPD</h2>
                <ul class="mt-5 space-y-3">
                    <li
                        v-for="item in lgpd"
                        :key="item"
                        class="flex items-start gap-2 text-sm font-medium leading-relaxed text-slate-700 md:text-base"
                    >
                        <span class="mt-1 h-2 w-2 rounded-full bg-emerald-600"></span>
                        <span>{{ item }}</span>
                    </li>
                </ul>
                <div class="mt-7 flex flex-wrap gap-3">
                    <Link
                        :href="route('site.privacy')"
                        class="inline-flex h-11 items-center justify-center rounded-full bg-slate-950 px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-white transition hover:bg-emerald-500 hover:text-slate-950"
                    >
                        Politica de privacidade
                    </Link>
                    <Link
                        :href="route('site.contact')"
                        class="inline-flex h-11 items-center justify-center rounded-full border border-slate-300 bg-white px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-slate-700 transition hover:border-slate-950"
                    >
                        Falar com o time
                    </Link>
                </div>
            </div>
        </section>

        <section class="mx-auto w-full max-w-[1240px] px-5 pb-20 pt-2 md:px-6 md:pb-24 md:pt-6">
            <div class="grid gap-4 md:grid-cols-2">
                <Link
                    :href="route('site.privacy')"
                    class="rounded-3xl border border-slate-200 bg-white/80 p-6 transition hover:border-emerald-300"
                >
                    <p class="text-[11px] font-bold uppercase tracking-[0.14em] text-slate-500">Documento</p>
                    <p class="mt-2 text-2xl tracking-tight text-slate-950">Privacidade</p>
                    <p class="mt-2 text-sm text-slate-600">Como coletamos, processamos e excluimos dados.</p>
                </Link>
                <Link
                    :href="route('site.terms')"
                    class="rounded-3xl border border-slate-200 bg-white/80 p-6 transition hover:border-amber-300"
                >
                    <p class="text-[11px] font-bold uppercase tracking-[0.14em] text-slate-500">Documento</p>
                    <p class="mt-2 text-2xl tracking-tight text-slate-950">Termos de uso</p>
                    <p class="mt-2 text-sm text-slate-600">Regras de uso, assinatura e relacao contratual.</p>
                </Link>
            </div>
        </section>
    </SiteLayout>
</template>
