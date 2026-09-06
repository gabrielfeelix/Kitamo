<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, router, usePage } from '@inertiajs/vue3';
import { requestJson } from '@/lib/kitamoApi';
import type { BootstrapData, Investment, AssetClass } from '@/types/kitamo';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import MobileToast from '@/Components/MobileToast.vue';
import InvestmentModal, { type InvestmentModalPayload } from '@/Components/InvestmentModal.vue';
import AporteModal, { type AportePayload } from '@/Components/AporteModal.vue';
import { useIsMobile } from '@/composables/useIsMobile';

const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() =>
    isMobile.value ? { showNav: true } : { title: 'Patrimônio', showSearch: false, showNewAction: false },
);

const page = usePage();
const bootstrap = computed(
    () =>
        (page.props.bootstrap ?? {
            entries: [],
            goals: [],
            accounts: [],
            investments: [],
            categories: [],
            tags: [],
        }) as BootstrapData,
);

const investments = ref<Investment[]>(bootstrap.value.investments ?? []);

const formatBRL = (value: number) =>
    new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value);

/**
 * Cada classe tem cor e rótulo próprios: a composição precisa ser legível sem
 * legenda, e o nome interno ('caixinha') não é o que a pessoa reconhece.
 */
const CLASSES: Record<AssetClass, { label: string; color: string }> = {
    caixinha: { label: 'Caixinha', color: '#14B8A6' },
    cdb: { label: 'CDB', color: '#3B82F6' },
    tesouro: { label: 'Tesouro Direto', color: '#8B5CF6' },
    acao: { label: 'Ações', color: '#F59E0B' },
    fii: { label: 'Fundos imobiliários', color: '#EC4899' },
    cripto: { label: 'Cripto', color: '#F97316' },
    outro: { label: 'Outro', color: '#64748B' },
};

const classeDe = (c: AssetClass) => CLASSES[c] ?? CLASSES.outro;

// Saldo em conta: cartão de crédito não entra, é passivo, não reserva.
const saldoEmContas = computed(() =>
    (bootstrap.value.accounts ?? [])
        .filter((a) => a.type !== 'credit_card')
        .reduce((acc, a) => acc + Number(a.current_balance ?? 0), 0),
);

const totalInvestido = computed(() => investments.value.reduce((acc, i) => acc + i.currentValue, 0));
const patrimonioTotal = computed(() => saldoEmContas.value + totalInvestido.value);

const totalAportado = computed(() => investments.value.reduce((acc, i) => acc + i.totalAportado, 0));
const rendimentoTotal = computed(() => investments.value.reduce((acc, i) => acc + i.rendimento, 0));
const rentabilidadeTotal = computed(() => {
    if (totalAportado.value <= 0) return 0;
    return (rendimentoTotal.value / totalAportado.value) * 100;
});

const TETO_FGC = 250000;

/**
 * Comparação da carteira com o CDI. Usa a maior janela entre as posições,
 * ponderando pelo valor — e some inteira quando não há cotação, em vez de
 * mostrar um benchmark chutado.
 */
const resumoCdi = computed(() => {
    const comCdi = investments.value.filter((i) => i.cdiNoPeriodo !== null && i.totalAportado > 0);
    if (comCdi.length === 0) return null;

    const aportado = comCdi.reduce((acc, i) => acc + i.totalAportado, 0);
    if (aportado <= 0) return null;

    const cdiPonderado = comCdi.reduce((acc, i) => acc + (i.cdiNoPeriodo ?? 0) * i.totalAportado, 0) / aportado;
    const rendPonderado = comCdi.reduce((acc, i) => acc + i.rentabilidade * i.totalAportado, 0) / aportado;

    if (cdiPonderado <= 0) return null;

    const percentual = (rendPonderado / cdiPonderado) * 100;
    const cdiTexto = `CDI no período: ${cdiPonderado.toFixed(2)}%`;

    if (percentual >= 100) {
        return `${cdiTexto} · você rendeu ${percentual.toFixed(0)}% do CDI`;
    }
    return `${cdiTexto} · você rendeu ${percentual.toFixed(0)}% do CDI, abaixo do índice`;
});

/** Instituições onde o saldo garantido passa do teto do FGC. */
const expostoAcimaDoFgc = computed(() => {
    const porInstituicao = new Map<string, number>();

    for (const i of investments.value) {
        if (!i.cobertoPeloFgc) continue;
        const nome = i.institution?.trim() || 'sua instituição';
        porInstituicao.set(nome, (porInstituicao.get(nome) ?? 0) + i.currentValue);
    }

    return Array.from(porInstituicao.entries())
        .filter(([, total]) => total > TETO_FGC)
        .map(([institution, total]) => ({ institution, total }));
});

/** Fatia de cada classe no total investido, para a barra de composição. */
const composicao = computed(() => {
    const porClasse = new Map<AssetClass, number>();
    for (const i of investments.value) {
        porClasse.set(i.assetClass, (porClasse.get(i.assetClass) ?? 0) + i.currentValue);
    }

    const total = totalInvestido.value;
    if (total <= 0) return [];

    const aportadoPorClasse = new Map<AssetClass, number>();
    const rendimentoPorClasse = new Map<AssetClass, number>();
    for (const i of investments.value) {
        aportadoPorClasse.set(i.assetClass, (aportadoPorClasse.get(i.assetClass) ?? 0) + i.totalAportado);
        rendimentoPorClasse.set(i.assetClass, (rendimentoPorClasse.get(i.assetClass) ?? 0) + i.rendimento);
    }

    return Array.from(porClasse.entries())
        .map(([classe, valor]) => {
            const aportado = aportadoPorClasse.get(classe) ?? 0;
            const rendimento = rendimentoPorClasse.get(classe) ?? 0;

            return {
                classe,
                valor,
                percent: (valor / total) * 100,
                rendimento,
                // Rentabilidade da classe: null quando não há capital aportado,
                // porque dividir por zero não produz percentual nenhum.
                rentabilidade: aportado > 0 ? (rendimento / aportado) * 100 : null,
                ...classeDe(classe),
            };
        })
        .sort((a, b) => b.valor - a.valor);
});

/**
 * Idade do dado. Nunca omitir: sync silenciosamente velho é a maior fonte de
 * desconfiança em apps de investimento.
 */
const idadeDoPreco = (investment: Investment) => {
    if (investment.priceSource === 'manual') return 'Você define o valor';
    if (!investment.priceUpdatedAt) return 'Nunca atualizado';

    const then = new Date(investment.priceUpdatedAt).getTime();
    if (Number.isNaN(then)) return 'Nunca atualizado';

    const horas = Math.floor((Date.now() - then) / 3_600_000);
    if (horas < 1) return 'Atualizado agora';
    if (horas < 24) return `Atualizado há ${horas}h`;

    const dias = Math.floor(horas / 24);
    return dias === 1 ? 'Atualizado ontem' : `Atualizado há ${dias} dias`;
};

const precoDesatualizado = (investment: Investment) => {
    if (investment.priceSource === 'manual' || !investment.priceUpdatedAt) return false;
    const then = new Date(investment.priceUpdatedAt).getTime();
    return !Number.isNaN(then) && Date.now() - then > 3 * 24 * 3_600_000;
};

const toastOpen = ref(false);
const toastMessage = ref('');
const showToast = (message: string) => {
    toastMessage.value = message;
    toastOpen.value = true;
};

const investmentModalOpen = ref(false);
const editing = ref<Investment | null>(null);

const openNew = () => {
    editing.value = null;
    investmentModalOpen.value = true;
};

const openEdit = (investment: Investment) => {
    editing.value = investment;
    investmentModalOpen.value = true;
};

const replaceInvestment = (investment: Investment | null | undefined) => {
    if (!investment?.id) return;
    const idx = investments.value.findIndex((i) => i.id === investment.id);
    if (idx >= 0) investments.value[idx] = investment;
    else investments.value.unshift(investment);
};

const saveInvestment = async (payload: InvestmentModalPayload) => {
    try {
        const editingId = editing.value?.id;
        const response = await requestJson<{ investment?: Investment }>(
            editingId ? route('api.investments.update', editingId) : route('api.investments.store'),
            {
                method: editingId ? 'PATCH' : 'POST',
                body: JSON.stringify(payload),
            },
        );

        replaceInvestment(response?.investment);
        investmentModalOpen.value = false;
        showToast(editingId ? 'Investimento atualizado' : 'Investimento cadastrado');
        router.reload({ only: ['bootstrap'] });
    } catch {
        showToast('Não foi possível salvar. Tente novamente.');
    }
};

const aporteModalOpen = ref(false);
const aporteTarget = ref<Investment | null>(null);

const openAporte = (investment: Investment) => {
    aporteTarget.value = investment;
    aporteModalOpen.value = true;
};

const saveAporte = async (payload: AportePayload) => {
    const target = aporteTarget.value;
    if (!target) return;

    try {
        const response = await requestJson<{ investment?: Investment }>(
            route('api.investments.aporte', target.id),
            { method: 'POST', body: JSON.stringify(payload) },
        );

        replaceInvestment(response?.investment);
        aporteModalOpen.value = false;
        showToast(payload.kind === 'aporte' ? 'Aporte registrado' : 'Resgate registrado');
        router.reload({ only: ['bootstrap'] });
    } catch {
        showToast('Não foi possível registrar. Tente novamente.');
    }
};

const removeInvestment = async (investment: Investment) => {
    if (!confirm(`Excluir "${investment.name}"? O histórico de aportes vai junto. Os lançamentos já feitos no seu extrato permanecem.`)) {
        return;
    }

    try {
        await requestJson(route('api.investments.destroy', investment.id), { method: 'DELETE' });
        investments.value = investments.value.filter((i) => i.id !== investment.id);
        showToast('Investimento excluído');
        router.reload({ only: ['bootstrap'] });
    } catch {
        showToast('Não foi possível excluir. Tente novamente.');
    }
};

const contasParaAporte = computed(() =>
    (bootstrap.value.accounts ?? [])
        .filter((a) => a.type !== 'credit_card')
        .map((a) => ({ id: String(a.id), name: a.name, balance: Number(a.current_balance ?? 0) })),
);
</script>

<template>
    <Head title="Patrimônio" />

    <component :is="Shell" v-bind="shellProps" @add="openNew">
        <header v-if="isMobile" class="flex items-center justify-between pt-2">
            <div class="text-2xl font-semibold tracking-tight text-slate-900">Patrimônio</div>
        </header>

        <!-- Herói: o que você guardou vs o que o mercado deu. É a pergunta que
             motiva a tela; o total sozinho não conta essa história. -->
        <section class="mt-6 overflow-hidden rounded-3xl bg-slate-900 p-6 text-white shadow-sm sm:p-8">
            <div class="text-xs font-medium uppercase tracking-wider text-slate-400">Patrimônio total</div>
            <div class="mt-2 text-4xl font-bold tracking-tight tabular-nums sm:text-5xl">
                {{ formatBRL(patrimonioTotal) }}
            </div>
            <div class="mt-1 text-sm text-slate-400">
                {{ formatBRL(saldoEmContas) }} em conta · {{ formatBRL(totalInvestido) }} investido
            </div>

            <div v-if="investments.length > 0" class="mt-6 grid grid-cols-2 gap-4 border-t border-white/10 pt-5">
                <div>
                    <div class="text-xs font-medium text-slate-400">Você aportou</div>
                    <div class="mt-1 text-xl font-semibold tabular-nums sm:text-2xl">{{ formatBRL(totalAportado) }}</div>
                </div>
                <div>
                    <div class="text-xs font-medium text-slate-400">Rendimento</div>
                    <div
                        class="mt-1 text-xl font-semibold tabular-nums sm:text-2xl"
                        :class="rendimentoTotal < 0 ? 'text-red-400' : 'text-emerald-400'"
                    >
                        {{ rendimentoTotal >= 0 ? '+' : '−' }}{{ formatBRL(Math.abs(rendimentoTotal)) }}
                        <span class="text-sm font-medium opacity-80">
                            ({{ rentabilidadeTotal >= 0 ? '+' : '−' }}{{ Math.abs(rentabilidadeTotal).toFixed(1) }}%)
                        </span>
                    </div>
                </div>
            </div>

            <!-- A comparação com o CDI é o que transforma "rendeu 2%" em
                 "rendeu bem" ou "rendeu mal". Some quando não há cotação. -->
            <p v-if="resumoCdi" class="mt-4 text-sm text-slate-300">{{ resumoCdi }}</p>
        </section>

        <section
            v-if="expostoAcimaDoFgc.length > 0"
            class="mt-4 rounded-2xl border border-amber-200 bg-amber-50 p-4"
        >
            <h2 class="text-sm font-semibold text-amber-900">Acima da cobertura do FGC</h2>
            <p class="mt-1 text-xs text-amber-800">
                O FGC garante até {{ formatBRL(TETO_FGC) }} por instituição. Em
                {{ expostoAcimaDoFgc.map((e) => e.institution).join(', ') }} você tem mais que isso — o excedente não
                está garantido.
            </p>
        </section>

        <!-- Composição: uma barra só, proporcional. Rótulo junto da cor, sem
             legenda separada obrigando o olho a ir e voltar. -->
        <section v-if="composicao.length > 0" class="mt-6 rounded-3xl bg-white p-5 shadow-sm ring-1 ring-slate-200/60 sm:p-6">
            <h2 class="text-base font-semibold text-slate-900">Onde está seu dinheiro</h2>

            <div class="mt-4 flex h-3 w-full overflow-hidden rounded-full bg-slate-100">
                <div
                    v-for="fatia in composicao"
                    :key="fatia.classe"
                    class="h-full transition-all duration-700 ease-out first:rounded-l-full last:rounded-r-full"
                    :style="{ width: `${fatia.percent}%`, backgroundColor: fatia.color }"
                    :title="`${fatia.label}: ${formatBRL(fatia.valor)}`"
                ></div>
            </div>

            <ul class="mt-4 space-y-2">
                <li v-for="fatia in composicao" :key="fatia.classe" class="flex items-center justify-between gap-3 text-sm">
                    <span class="flex min-w-0 items-center gap-2">
                        <span class="h-2.5 w-2.5 shrink-0 rounded-full" :style="{ backgroundColor: fatia.color }"></span>
                        <span class="truncate font-medium text-slate-700">{{ fatia.label }}</span>
                    </span>
                    <span class="shrink-0 text-right tabular-nums">
                        <span class="text-slate-500">{{ formatBRL(fatia.valor) }} · {{ fatia.percent.toFixed(0) }}%</span>
                        <span
                            v-if="fatia.rentabilidade !== null"
                            class="ml-2 text-xs font-semibold"
                            :class="fatia.rentabilidade < 0 ? 'text-red-500' : 'text-emerald-600'"
                        >
                            {{ fatia.rentabilidade >= 0 ? '+' : '−' }}{{ Math.abs(fatia.rentabilidade).toFixed(1) }}%
                        </span>
                    </span>
                </li>
            </ul>
        </section>

        <!-- Estado vazio: um convite com o próximo passo explícito. -->
        <section
            v-if="investments.length === 0"
            class="mt-6 rounded-3xl border border-dashed border-slate-300 bg-white px-6 py-10 text-center shadow-sm"
        >
            <h2 class="text-base font-semibold text-slate-900">Nada guardado por aqui ainda</h2>
            <p class="mx-auto mt-2 max-w-sm text-sm text-slate-500">
                Cadastre uma caixinha, um CDB ou qualquer reserva para ver quanto você tem — e quanto rendeu.
            </p>
            <button
                type="button"
                class="mt-5 inline-flex items-center gap-2 rounded-2xl bg-slate-900 px-5 py-3 text-sm font-semibold text-white transition-colors hover:bg-slate-800"
                @click="openNew"
            >
                Cadastrar investimento
            </button>
        </section>

        <section v-else class="mt-6 space-y-3 pb-6">
            <div class="flex items-center justify-between">
                <h2 class="text-base font-semibold text-slate-900">Seus investimentos</h2>
                <button
                    type="button"
                    class="rounded-xl px-3 py-1.5 text-sm font-semibold text-emerald-700 transition-colors hover:bg-emerald-50"
                    @click="openNew"
                >
                    Adicionar
                </button>
            </div>

            <article
                v-for="investment in investments"
                :key="investment.id"
                class="rounded-3xl bg-white p-5 shadow-sm ring-1 ring-slate-200/60"
            >
                <div class="flex items-start justify-between gap-3">
                    <div class="flex min-w-0 items-center gap-3">
                        <span
                            class="flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl text-sm font-bold text-white"
                            :style="{ backgroundColor: investment.color ?? classeDe(investment.assetClass).color }"
                        >
                            {{ investment.name.slice(0, 2).toUpperCase() }}
                        </span>
                        <div class="min-w-0">
                            <h3 class="truncate font-semibold text-slate-900">{{ investment.name }}</h3>
                            <p class="truncate text-xs text-slate-500">
                                {{ classeDe(investment.assetClass).label }}
                                <template v-if="investment.institution"> · {{ investment.institution }}</template>
                            </p>
                            <div class="mt-1.5 flex flex-wrap items-center gap-1.5">
                                <span
                                    v-if="investment.cobertoPeloFgc"
                                    class="rounded-full bg-emerald-50 px-2 py-0.5 text-[10px] font-semibold text-emerald-700"
                                    title="Garantido pelo FGC até R$ 250 mil por instituição"
                                >
                                    FGC
                                </span>
                                <span
                                    v-if="investment.percentualDoCdi !== null"
                                    class="rounded-full px-2 py-0.5 text-[10px] font-semibold"
                                    :class="investment.percentualDoCdi >= 100 ? 'bg-emerald-50 text-emerald-700' : 'bg-amber-50 text-amber-700'"
                                >
                                    {{ investment.percentualDoCdi.toFixed(0) }}% do CDI
                                </span>
                                <span
                                    v-if="investment.precoMedio !== null"
                                    class="rounded-full bg-slate-100 px-2 py-0.5 text-[10px] font-semibold text-slate-600"
                                >
                                    PM {{ formatBRL(investment.precoMedio) }}
                                </span>
                            </div>
                        </div>
                    </div>
                    <div class="shrink-0 text-right">
                        <div class="font-bold tabular-nums text-slate-900">{{ formatBRL(investment.currentValue) }}</div>
                        <div
                            class="text-xs font-semibold tabular-nums"
                            :class="investment.rendimento < 0 ? 'text-red-500' : 'text-emerald-600'"
                        >
                            {{ investment.rendimento >= 0 ? '+' : '−' }}{{ formatBRL(Math.abs(investment.rendimento)) }}
                        </div>
                    </div>
                </div>

                <div class="mt-4 flex flex-wrap items-center justify-between gap-3 border-t border-slate-100 pt-3">
                    <span
                        class="text-xs"
                        :class="precoDesatualizado(investment) ? 'font-semibold text-amber-600' : 'text-slate-400'"
                    >
                        {{ idadeDoPreco(investment) }}
                    </span>

                    <div class="flex items-center gap-1">
                        <button
                            type="button"
                            class="rounded-xl px-3 py-1.5 text-xs font-semibold text-slate-700 transition-colors hover:bg-slate-100"
                            @click="openAporte(investment)"
                        >
                            Aportar ou resgatar
                        </button>
                        <button
                            type="button"
                            class="rounded-xl px-3 py-1.5 text-xs font-semibold text-slate-500 transition-colors hover:bg-slate-100"
                            @click="openEdit(investment)"
                        >
                            Editar
                        </button>
                        <button
                            type="button"
                            class="rounded-xl px-3 py-1.5 text-xs font-semibold text-red-500 transition-colors hover:bg-red-50"
                            @click="removeInvestment(investment)"
                        >
                            Excluir
                        </button>
                    </div>
                </div>
            </article>
        </section>

        <InvestmentModal
            :open="investmentModalOpen"
            :investment="editing"
            @close="investmentModalOpen = false"
            @save="saveInvestment"
        />

        <AporteModal
            :open="aporteModalOpen"
            :investment="aporteTarget"
            :accounts="contasParaAporte"
            @close="aporteModalOpen = false"
            @save="saveAporte"
        />

        <MobileToast :show="toastOpen" :message="toastMessage" @dismiss="toastOpen = false" />
    </component>
</template>
