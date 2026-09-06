<script setup lang="ts">
import { computed, onMounted, ref } from 'vue';
import { Head, Link } from '@inertiajs/vue3';
import { useIsMobile } from '@/composables/useIsMobile';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import MobileToast from '@/Components/MobileToast.vue';
import { requestJson, requestFormData } from '@/lib/kitamoApi';

const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() =>
    isMobile.value ? { showNav: false } : { title: 'Importar extrato', showSearch: false, showNewAction: false },
);

type Row = {
    transaction_date: string;
    description: string;
    amount: number;
    kind: 'expense' | 'income';
    origem_id: string | null;
    incluir: boolean;
};

type Account = { id: number; name: string; type: string };

const contas = ref<Account[]>([]);
const contaId = ref<number | null>(null);
const linhas = ref<Row[]>([]);
const origem = ref<'ofx' | 'csv' | null>(null);
const instituicao = ref<string | null>(null);
const nomeArquivo = ref('');

const carregando = ref(false);
const enviando = ref(false);
const erro = ref('');
const toast = ref('');
const inputArquivo = ref<HTMLInputElement | null>(null);

const selecionadas = computed(() => linhas.value.filter((l) => l.incluir));
const totalEntradas = computed(() =>
    selecionadas.value.filter((l) => l.kind === 'income').reduce((s, l) => s + l.amount, 0),
);
const totalSaidas = computed(() =>
    selecionadas.value.filter((l) => l.kind === 'expense').reduce((s, l) => s + l.amount, 0),
);

const moeda = (v: number) =>
    v.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });

const dataCurta = (iso: string) => {
    const [y, m, d] = iso.split('-');
    return `${d}/${m}/${y.slice(2)}`;
};

const carregarContas = async () => {
    try {
        const res = await requestJson<{ accounts: Account[] }>('/api/accounts', { method: 'GET' });
        contas.value = res.accounts ?? [];
        if (contas.value.length > 0) contaId.value = contas.value[0].id;
    } catch (e) {
        console.error('Falha ao carregar contas', e);
        erro.value = 'Não foi possível carregar suas contas.';
    }
};

onMounted(carregarContas);

const escolherArquivo = () => inputArquivo.value?.click();

const aoSelecionarArquivo = async (event: Event) => {
    const alvo = event.target as HTMLInputElement;
    const arquivo = alvo.files?.[0];
    if (!arquivo) return;

    erro.value = '';
    linhas.value = [];
    carregando.value = true;
    nomeArquivo.value = arquivo.name;

    try {
        const form = new FormData();
        form.append('file', arquivo);

        // requestFormData deixa o browser definir o Content-Type com o
        // boundary do multipart; requestJson forçaria application/json.
        const res = await requestFormData<{
            institution: string | null;
            origem: 'ofx' | 'csv';
            rows: Omit<Row, 'incluir'>[];
        }>('/api/import/preview', { method: 'POST', body: form });

        origem.value = res.origem;
        instituicao.value = res.institution;
        linhas.value = (res.rows ?? []).map((r) => ({ ...r, incluir: true }));

        if (linhas.value.length === 0) {
            erro.value = 'Nenhum lançamento foi encontrado nesse arquivo.';
        }
    } catch (e) {
        console.error('Falha ao ler arquivo', e);
        erro.value = e instanceof Error && e.message ? e.message : 'Não foi possível ler esse arquivo.';
    } finally {
        carregando.value = false;
        // Permite reenviar o mesmo arquivo depois de um erro.
        alvo.value = '';
    }
};

const alternarTodas = (valor: boolean) => {
    linhas.value = linhas.value.map((l) => ({ ...l, incluir: valor }));
};

const confirmar = async () => {
    if (!contaId.value || selecionadas.value.length === 0) return;
    enviando.value = true;
    erro.value = '';

    try {
        const res = await requestJson<{ created: number; skipped: number }>('/api/import/commit', {
            method: 'POST',
            body: JSON.stringify({
                account_id: contaId.value,
                origem: origem.value,
                rows: selecionadas.value.map((l) => ({
                    transaction_date: l.transaction_date,
                    description: l.description,
                    amount: l.amount,
                    kind: l.kind,
                    origem_id: l.origem_id,
                })),
            }),
        });

        const partes = [`${res.created} lançamento${res.created === 1 ? '' : 's'} importado${res.created === 1 ? '' : 's'}`];
        if (res.skipped > 0) partes.push(`${res.skipped} já existia${res.skipped === 1 ? '' : 'm'}`);
        toast.value = partes.join(' · ');

        linhas.value = [];
        nomeArquivo.value = '';
    } catch (e) {
        console.error('Falha ao importar', e);
        erro.value = 'Não foi possível concluir a importação.';
    } finally {
        enviando.value = false;
    }
};
</script>

<template>
    <Head title="Importar extrato" />

    <component :is="Shell" v-bind="shellProps">
        <div class="mx-auto w-full max-w-3xl px-4 py-5 space-y-5">
            <div v-if="isMobile" class="flex items-center gap-3">
                <Link :href="route('settings')" class="text-[var(--text-secondary)]">←</Link>
                <h1 class="text-lg font-semibold text-[var(--text-primary)]">Importar extrato</h1>
            </div>

            <!-- Passo 1: arquivo -->
            <section class="rounded-2xl border border-[var(--border)] bg-[var(--bg-card)] p-4">
                <h2 class="text-sm font-semibold text-[var(--text-primary)]">1. Escolha o arquivo</h2>
                <p class="mt-1 text-sm text-[var(--text-tertiary)]">
                    Baixe o extrato em <strong>OFX</strong> no site ou app do seu banco. CSV também funciona.
                </p>

                <input
                    ref="inputArquivo"
                    type="file"
                    accept=".ofx,.qfx,.csv,.txt"
                    class="hidden"
                    @change="aoSelecionarArquivo"
                />

                <button
                    type="button"
                    class="mt-3 w-full rounded-xl bg-[var(--primary-500)] px-4 py-3 text-sm font-semibold text-white disabled:opacity-60"
                    :disabled="carregando"
                    @click="escolherArquivo"
                >
                    {{ carregando ? 'Lendo arquivo…' : 'Selecionar arquivo' }}
                </button>

                <p v-if="nomeArquivo" class="mt-2 text-xs text-[var(--text-tertiary)]">
                    {{ nomeArquivo }}
                    <span v-if="instituicao"> · {{ instituicao }}</span>
                </p>

                <details class="mt-3">
                    <summary class="cursor-pointer text-xs text-[var(--text-tertiary)]">
                        Onde encontro o OFX no meu banco?
                    </summary>
                    <ul class="mt-2 space-y-1 text-xs text-[var(--text-tertiary)]">
                        <li><strong>Nubank:</strong> app → Conta → Histórico → ícone de compartilhar → Exportar extrato</li>
                        <li><strong>Itaú:</strong> internet banking → Extrato → Salvar em outros formatos → OFX</li>
                        <li><strong>Bradesco / Santander / BB:</strong> Extrato → Exportar / Salvar → OFX</li>
                        <li><strong>Inter:</strong> app → Extrato → Exportar → OFX</li>
                        <li><strong>Mercado Pago:</strong> Atividade → Extrato → baixar (CSV)</li>
                    </ul>
                </details>

                <p v-if="erro" class="mt-3 rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700">{{ erro }}</p>
            </section>

            <!-- Passo 2: conferência -->
            <section
                v-if="linhas.length > 0"
                class="rounded-2xl border border-[var(--border)] bg-[var(--bg-card)] p-4"
            >
                <h2 class="text-sm font-semibold text-[var(--text-primary)]">
                    2. Confira os lançamentos
                </h2>

                <label class="mt-3 block text-xs font-medium text-[var(--text-secondary)]">
                    Conta de destino
                    <select
                        v-model="contaId"
                        class="mt-1 w-full rounded-xl border border-[var(--border)] bg-[var(--bg-input)] px-3 py-2 text-sm text-[var(--text-primary)]"
                    >
                        <option v-for="c in contas" :key="c.id" :value="c.id">{{ c.name }}</option>
                    </select>
                </label>

                <div class="mt-3 flex items-center justify-between text-xs">
                    <span class="text-[var(--text-tertiary)]">
                        {{ selecionadas.length }} de {{ linhas.length }} selecionados
                    </span>
                    <span class="space-x-3">
                        <button type="button" class="text-[var(--primary-500)]" @click="alternarTodas(true)">Todos</button>
                        <button type="button" class="text-[var(--text-tertiary)]" @click="alternarTodas(false)">Nenhum</button>
                    </span>
                </div>

                <ul class="mt-2 max-h-80 divide-y divide-[var(--border)] overflow-y-auto">
                    <li v-for="(l, i) in linhas" :key="`${l.origem_id ?? 'n'}-${i}`" class="flex items-center gap-3 py-2">
                        <input v-model="l.incluir" type="checkbox" class="h-4 w-4 shrink-0 accent-[var(--primary-500)]" />
                        <span class="w-14 shrink-0 text-xs text-[var(--text-tertiary)]">{{ dataCurta(l.transaction_date) }}</span>
                        <span class="min-w-0 flex-1 truncate text-sm text-[var(--text-primary)]">{{ l.description }}</span>
                        <span
                            class="shrink-0 text-sm font-medium"
                            :class="l.kind === 'income' ? 'text-[var(--success-500)]' : 'text-[var(--text-primary)]'"
                        >
                            {{ l.kind === 'income' ? '+' : '−' }}{{ moeda(l.amount) }}
                        </span>
                    </li>
                </ul>

                <div class="mt-3 flex justify-between border-t border-[var(--border)] pt-3 text-sm">
                    <span class="text-[var(--text-tertiary)]">Entradas <strong class="text-[var(--success-500)]">{{ moeda(totalEntradas) }}</strong></span>
                    <span class="text-[var(--text-tertiary)]">Saídas <strong class="text-[var(--text-primary)]">{{ moeda(totalSaidas) }}</strong></span>
                </div>

                <button
                    type="button"
                    class="mt-4 w-full rounded-xl bg-[var(--primary-500)] px-4 py-3 text-sm font-semibold text-white disabled:opacity-60"
                    :disabled="enviando || selecionadas.length === 0 || !contaId"
                    @click="confirmar"
                >
                    {{ enviando ? 'Importando…' : `Importar ${selecionadas.length} lançamento${selecionadas.length === 1 ? '' : 's'}` }}
                </button>

                <p class="mt-2 text-center text-xs text-[var(--text-tertiary)]">
                    Lançamentos que já existem são ignorados automaticamente.
                </p>
            </section>
        </div>

        <MobileToast :show="toast !== ''" :message="toast" @dismiss="toast = ''" />
    </component>
</template>
