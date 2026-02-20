<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';

const sections = [
    {
        id: 'coleta',
        label: 'Coleta e uso de dados',
        title: '1. Coleta e uso de dados',
        content: [
            'Coletamos apenas os dados necessarios para funcionamento da plataforma, suporte e seguranca.',
            'O Kitamo nao vende dados pessoais e nao utiliza informacoes para publicidade comportamental.',
        ],
    },
    {
        id: 'protecao',
        label: 'Protecao de dados',
        title: '2. Protecao de dados',
        content: [
            'O Kitamo nao se conecta a contas bancarias. O cadastro e manual por escolha de produto.',
            'Dados sao protegidos em transito e em repouso com controles tecnicos compativeis com padroes de mercado.',
        ],
    },
    {
        id: 'compartilhamento',
        label: 'Compartilhamento',
        title: '3. Compartilhamento',
        content: [
            'Compartilhamento ocorre apenas com operadores essenciais de infraestrutura e seguranca.',
            'Esses operadores atuam sob obrigacao contratual de confidencialidade e protecao de dados.',
        ],
    },
    {
        id: 'direitos',
        label: 'Direitos LGPD',
        title: '4. Seus direitos (LGPD)',
        content: [
            'Voce pode solicitar confirmacao de tratamento, acesso, correcao, portabilidade e exclusao de dados.',
            'As solicitacoes sao tratadas conforme Art. 18 da LGPD e priorizadas pelo canal oficial.',
        ],
    },
    {
        id: 'contato',
        label: 'Contato DPO',
        title: '5. Contato com DPO',
        content: [
            'Para exercicio de direitos e duvidas regulatorias, utilize nosso canal oficial de contato.',
            'O atendimento para demandas de dados pessoais recebe priorizacao de SLA.',
        ],
    },
];

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();
</script>

<template>
    <Head title="Privacidade | Kitamo">
        <meta name="description" content="Politica de privacidade da Kitamo com compromisso de transparencia e conformidade com LGPD." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[1320px] px-5 pb-12 pt-10 md:px-6 md:pb-16 md:pt-16">
            <div class="privacy-hero relative overflow-hidden rounded-[2.1rem] border border-slate-200 p-6 md:p-8">
                <div class="grid items-center gap-8 md:grid-cols-12">
                    <div class="md:col-span-7 text-white">
                        <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-emerald-300">Privacidade</p>
                        <h1 class="mt-4 text-5xl leading-[0.9] tracking-[-0.03em] md:text-6xl">
                            Politica de privacidade
                        </h1>
                        <p class="mt-4 max-w-2xl text-base leading-relaxed text-slate-300 md:text-lg">
                            Este documento explica como tratamos dados de forma transparente, segura e em conformidade com a LGPD.
                        </p>
                        <div class="mt-6 flex flex-wrap items-center gap-3 text-xs font-semibold uppercase tracking-[0.12em] text-slate-300">
                            <span>Ultima atualizacao: 20 de fevereiro de 2026</span>
                            <span>Versao 1.1</span>
                        </div>
                        <div class="mt-6 flex flex-wrap gap-3">
                            <button
                                type="button"
                                class="inline-flex h-11 items-center justify-center rounded-full bg-white px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-slate-950 transition hover:bg-emerald-300"
                            >
                                Baixar PDF
                            </button>
                            <!-- TODO: vincular botao a versao PDF oficial -->
                            <Link
                                :href="route('site.contact')"
                                class="inline-flex h-11 items-center justify-center rounded-full border border-white/30 px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-white transition hover:border-white"
                            >
                                Falar com DPO
                            </Link>
                        </div>
                    </div>

                    <div class="md:col-span-5">
                        <img
                            src="https://images.pexels.com/photos/3184465/pexels-photo-3184465.jpeg?auto=compress&cs=tinysrgb&w=1200"
                            alt="Equipe revisando documento de politica"
                            class="h-[320px] w-full rounded-[1.6rem] object-cover md:h-[400px]"
                            loading="lazy"
                        />
                    </div>
                </div>
            </div>
        </section>

        <section class="mx-auto grid w-full max-w-[1320px] gap-8 px-5 pb-20 md:grid-cols-12 md:px-6 md:pb-24">
            <aside class="md:col-span-4 md:sticky md:top-28 md:h-fit">
                <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500">Indice do documento</p>
                <nav class="mt-4 border-y border-slate-200 py-4">
                    <a
                        v-for="item in sections"
                        :key="item.id"
                        :href="`#${item.id}`"
                        class="block border-b border-slate-100 py-3 text-sm font-semibold text-slate-700 last:border-b-0 hover:text-emerald-700"
                    >
                        {{ item.label }}
                    </a>
                </nav>
            </aside>

            <div class="md:col-span-8">
                <article
                    v-for="(item, index) in sections"
                    :id="item.id"
                    :key="item.id"
                    class="grid gap-5 border-t border-slate-200 py-8 first:border-t-0 first:pt-0 md:grid-cols-12"
                >
                    <p class="md:col-span-2 text-3xl font-semibold tracking-tight text-slate-300">0{{ index + 1 }}</p>
                    <div class="md:col-span-10">
                        <h2 class="text-4xl leading-tight tracking-tight text-slate-950 md:text-5xl">{{ item.title }}</h2>
                        <p
                            v-for="paragraph in item.content"
                            :key="paragraph"
                            class="mt-4 text-base leading-relaxed text-slate-600 md:text-lg"
                        >
                            {{ paragraph }}
                        </p>
                    </div>
                </article>
            </div>
        </section>
    </SiteLayout>
</template>

<style scoped>
.privacy-hero {
    background:
        radial-gradient(30rem 24rem at 8% 0%, rgba(16, 185, 129, 0.2), transparent 72%),
        linear-gradient(145deg, #020617 0%, #0f172a 60%, #111827 100%);
}
</style>
