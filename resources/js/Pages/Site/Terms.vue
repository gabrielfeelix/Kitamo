<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';

const sections = [
    {
        id: 'acesso',
        label: 'Acesso e licenca',
        title: '1. Acesso e licenca',
        content: [
            'O Kitamo concede licenca pessoal, limitada, nao exclusiva e revogavel para uso da plataforma web.',
            'O uso pressupoe cumprimento destes termos e da legislacao aplicavel.',
        ],
    },
    {
        id: 'responsabilidade',
        label: 'Responsabilidade de uso',
        title: '2. Responsabilidade de uso',
        content: [
            'A plataforma e software de organizacao e projecao financeira, nao consultoria juridica, contabil ou de investimento.',
            'Decisoes financeiras permanecem sob responsabilidade do usuario.',
        ],
    },
    {
        id: 'assinaturas',
        label: 'Assinaturas e reembolso',
        title: '3. Assinaturas e reembolso',
        content: [
            'Planos pagos seguem ciclo de cobranca informado no ato da contratacao.',
            'Para contratacoes online, aplica-se o prazo legal de arrependimento de 7 dias, conforme CDC.',
        ],
    },
    {
        id: 'encerramento',
        label: 'Suspensao e encerramento',
        title: '4. Suspensao e encerramento',
        content: [
            'Contas podem ser suspensas em casos de fraude, uso abusivo ou violacao material destes termos.',
            'Medidas sao aplicadas conforme gravidade e risco para a plataforma e usuarios.',
        ],
    },
    {
        id: 'foro',
        label: 'Foro e legislacao',
        title: '5. Foro e legislacao',
        content: [
            'Estes termos sao regidos pelas leis brasileiras.',
            'Fica eleito o foro da Comarca de Sao Paulo/SP, salvo disposicao legal em contrario.',
        ],
    },
];

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();
</script>

<template>
    <Head title="Termos de Uso | Kitamo">
        <meta name="description" content="Termos de uso da plataforma Kitamo com regras claras de acesso, assinatura e base legal." />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <section class="mx-auto w-full max-w-[1320px] px-5 pb-12 pt-10 md:px-6 md:pb-16 md:pt-16">
            <div class="terms-hero relative overflow-hidden rounded-[2.1rem] border border-slate-200 p-6 md:p-8">
                <div class="grid items-center gap-8 md:grid-cols-12">
                    <div class="md:col-span-7 text-white">
                        <p class="text-[11px] font-bold uppercase tracking-[0.16em] text-emerald-300">Termos de uso</p>
                        <h1 class="mt-4 text-5xl leading-[0.9] tracking-[-0.03em] md:text-6xl">
                            Regras claras de uso
                        </h1>
                        <p class="mt-4 max-w-2xl text-base leading-relaxed text-slate-300 md:text-lg">
                            Documento contratual com regras de acesso, cobranca, cancelamento e responsabilidade de uso da plataforma.
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
                                Solicitar suporte legal
                            </Link>
                        </div>
                    </div>

                    <div class="md:col-span-5">
                        <img
                            src="https://images.pexels.com/photos/3184291/pexels-photo-3184291.jpeg?auto=compress&cs=tinysrgb&w=1200"
                            alt="Equipe analisando contrato"
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

                <div class="mt-4 border-t border-slate-200 pt-6">
                    <Link
                        :href="route('site.contact')"
                        class="inline-flex h-11 items-center justify-center rounded-full bg-slate-950 px-6 text-[11px] font-bold uppercase tracking-[0.14em] text-white transition hover:bg-emerald-500 hover:text-slate-950"
                    >
                        Solicitar versoes anteriores
                    </Link>
                </div>
            </div>
        </section>
    </SiteLayout>
</template>

<style scoped>
.terms-hero {
    background:
        radial-gradient(30rem 24rem at 8% 0%, rgba(16, 185, 129, 0.2), transparent 72%),
        linear-gradient(145deg, #020617 0%, #0f172a 60%, #111827 100%);
}
</style>
