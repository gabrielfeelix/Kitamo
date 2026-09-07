<script setup lang="ts">
import { Head } from '@inertiajs/vue3';
import SiteLayout from '@/Layouts/SiteLayout.vue';
import MotionSection from '@/Components/site/MotionSection.vue';

const props = defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
    apk?: {
        url: string;
        tamanho: string;
        atualizado: number;
        versao?: string | null;
    } | null;
}>();

/** "7 de setembro de 2026" — a data que o arquivo tem no servidor. */
const atualizadoEm = (() => {
    if (!props.apk) return '';
    const d = new Date(props.apk.atualizado * 1000);
    const meses = [
        'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
        'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
    ];
    return `${d.getDate()} de ${meses[d.getMonth()]} de ${d.getFullYear()}`;
})();

// O passo 3 é o que trava todo mundo: o Android chama de "fonte
// desconhecida" e o aviso assusta. Explicar antes evita a mensagem de
// "não consegui instalar".
const passos = [
    {
        n: '1',
        titulo: 'Baixe o arquivo',
        texto: 'Toque no botão acima. O download leva alguns segundos.',
    },
    {
        n: '2',
        titulo: 'Abra o que baixou',
        texto: 'Toque na notificação do download, ou procure o arquivo na pasta Downloads do celular.',
    },
    {
        n: '3',
        titulo: 'Permita a instalação',
        texto: 'O Android vai avisar que o app não veio da Play Store. É esperado: toque em "configurações", ligue "permitir desta fonte" e volte. Você só faz isso uma vez.',
    },
    {
        n: '4',
        titulo: 'Instale e abra',
        texto: 'Toque em instalar. Pronto, o joão já está no seu celular.',
    },
];
</script>

<template>
    <Head title="Baixar o app | Kitamo">
        <meta name="description" content="Baixe o app da Kitamo para Android." />
        <!-- Página de teste fechado: não queremos ela em busca. -->
        <meta name="robots" content="noindex, nofollow" />
    </Head>

    <SiteLayout :can-login="canLogin" :can-register="canRegister">
        <MotionSection
            class="relative min-h-[60vh] w-full overflow-hidden bg-white text-slate-900 flex flex-col justify-center pt-32 pb-20 border-b border-slate-200"
        >
            <template #background>
                <div
                    class="pointer-events-none absolute -top-20 left-1/2 -translate-x-1/2 w-[600px] h-[600px] bg-teal-500/10 blur-[150px] rounded-full mix-blend-multiply opacity-60"
                ></div>
            </template>

            <div class="relative mx-auto w-full max-w-3xl px-6">
                <p class="text-[12px] font-extrabold uppercase tracking-[0.2em] text-teal-600">
                    Versão de teste
                </p>

                <h1 class="mt-4 text-4xl md:text-5xl font-black tracking-tight leading-[1.05]">
                    Baixe o app da Kitamo
                </h1>

                <p class="mt-5 text-lg leading-relaxed text-slate-600 max-w-xl">
                    O app está em teste com um grupo pequeno de pessoas. Ainda
                    não está na Play Store, então a instalação é pelo arquivo
                    aqui de baixo.
                </p>

                <!-- O botão. Sem APK no servidor a página não finge que tem. -->
                <div v-if="apk" class="mt-10">
                    <a
                        :href="apk.url"
                        :download="`kitamo-${(apk.versao || '').replace(/[^0-9.]/g, '') || 'app'}.apk`"
                        class="inline-flex h-14 items-center justify-center gap-3 rounded-xl bg-slate-950 px-8 text-[13px] font-extrabold uppercase tracking-[0.15em] text-white hover:bg-teal-500 hover:text-slate-950 transition-all active:scale-95"
                    >
                        <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v12m0 0l-4-4m4 4l4-4M4 20h16" />
                        </svg>
                        Baixar para Android
                    </a>

                    <p class="mt-4 text-sm text-slate-500">
                        <template v-if="apk.versao">versão {{ apk.versao }} · </template>{{ apk.tamanho }} · Android 8 ou mais novo · atualizado em {{ atualizadoEm }}
                    </p>

                    <!-- Sem isso não dá pra saber se a instalação pegou: o
                         Android ignora em silêncio um APK com a mesma
                         versão e mantém o app antigo. -->
                    <p v-if="apk.versao" class="mt-2 text-sm text-slate-500">
                        Já instalou e continua igual? Veja a versão em
                        Ajustes &rsaquo; Apps &rsaquo; Kitamo. Se não for
                        {{ apk.versao }}, desinstale antes e instale de novo.
                    </p>
                    <p class="mt-2 text-sm text-slate-500">
                        É um arquivo grande porque serve qualquer celular
                        Android. Prefira baixar no Wi-Fi.
                    </p>
                </div>

                <div
                    v-else
                    class="mt-10 rounded-2xl border border-amber-200 bg-amber-50 p-6 text-amber-900"
                >
                    <p class="font-bold">A versão nova está sendo preparada.</p>
                    <p class="mt-1 text-sm leading-relaxed">
                        O arquivo sai do ar enquanto a gente publica uma
                        atualização. Tente de novo daqui a pouco.
                    </p>
                </div>

                <p class="mt-6 text-sm text-slate-500">
                    Só Android por enquanto. iPhone ainda não tem.
                </p>
            </div>
        </MotionSection>

        <MotionSection class="w-full bg-slate-50 py-20 border-b border-slate-200">
            <div class="mx-auto w-full max-w-3xl px-6">
                <h2 class="text-2xl md:text-3xl font-black tracking-tight">
                    Como instalar
                </h2>

                <div class="mt-8 flex flex-col gap-4">
                    <article
                        v-for="passo in passos"
                        :key="passo.n"
                        class="flex items-start gap-5 rounded-2xl border border-slate-200 bg-white p-6"
                    >
                        <div
                            class="shrink-0 w-10 h-10 rounded-full bg-teal-50 text-teal-600 flex items-center justify-center font-black"
                        >
                            {{ passo.n }}
                        </div>
                        <div>
                            <h3 class="font-bold text-slate-900">{{ passo.titulo }}</h3>
                            <p class="mt-1 leading-relaxed text-slate-600">
                                {{ passo.texto }}
                            </p>
                        </div>
                    </article>
                </div>

                <div class="mt-10 rounded-2xl border border-slate-200 bg-white p-6">
                    <h3 class="font-bold text-slate-900">Seus dados ficam no seu celular</h3>
                    <p class="mt-2 leading-relaxed text-slate-600">
                        O app guarda tudo no próprio aparelho, num banco
                        criptografado. Não pedimos senha de banco, cartão nem
                        CPF, e nada é enviado pra gente.
                    </p>
                </div>

                <p class="mt-8 text-sm leading-relaxed text-slate-500">
                    Achou um problema ou tem uma ideia? Fala com a gente pela
                    página de contato. É pra isso que o teste existe.
                </p>
            </div>
        </MotionSection>
    </SiteLayout>
</template>

<style scoped>
h1, h2, h3 {
    font-feature-settings: "salt" on, "ss01" on;
}
</style>
