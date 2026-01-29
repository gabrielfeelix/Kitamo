<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue';
import { router, usePage } from '@inertiajs/vue3';
import { formatMoneyInputCentsShift, moneyInputToNumber } from '@/lib/moneyInput';
import { preventNonDigitKeydown } from '@/lib/inputGuards';
import { requestJson } from '@/lib/kitamoApi';
import ApplicationLogo from '@/Components/ApplicationLogo.vue';
import InstitutionAvatar from '@/Components/InstitutionAvatar.vue';
import { bankInstitutions } from '@/lib/bankLogos';

type AccountSeed = {
    key: string;
    label: string;
    type: 'wallet' | 'bank';
    icon: 'wallet' | 'bank';
    color: string;
    institution?: string | null;
    svgFile?: string | null;
    isFuture?: boolean;
};

const props = defineProps<{
    open: boolean;
}>();

const emit = defineEmits<{
    (event: 'close'): void;
    (event: 'done'): void;
}>();

const page = usePage();
const firstName = computed(() => String((page.props as any)?.auth?.user?.name ?? '').trim().split(' ')[0] || 'Bem-vindo');

const step = ref<1 | 2 | 3 | 4>(1);
const busy = ref(false);
const error = ref('');

const walletSeed: AccountSeed = { key: 'wallet', label: 'Carteira', type: 'wallet', icon: 'wallet', color: '#14B8A6' };
const bankSeeds: AccountSeed[] = bankInstitutions.map((b) => ({
    key: `bank:${b.nome}`,
    label: b.nome,
    type: 'bank',
    icon: 'bank',
    color: b.color,
    institution: b.nome,
    svgFile: b.svgFile,
    isFuture: b.nome === 'Outro',
}));
const seeds: AccountSeed[] = [walletSeed, ...bankSeeds];

const selectedKeys = ref<Set<string>>(new Set(['wallet']));

const selectedAccounts = computed(() => {
    const options = seeds;
    const active = options.filter((o) => selectedKeys.value.has(o.key) && !o.isFuture);
    return active;
});

const balances = ref<Record<string, string>>({});

const formatBRL2 = (value: number) =>
    new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL', minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(value);

const setBalance = (key: string, raw: string) => {
    balances.value = { ...balances.value, [key]: formatMoneyInputCentsShift(raw) };
};

const toggle = (key: string) => {
    const next = new Set(selectedKeys.value);
    if (next.has(key)) next.delete(key);
    else next.add(key);
    selectedKeys.value = next;
};

const canContinueFromSelect = computed(() => selectedAccounts.value.length > 0);

const markOnboardingDone = async () => {
    try {
        await requestJson('/api/user/onboarding', { method: 'PATCH' });
    } catch {
        // ignore
    }
};

const close = () => emit('close');
const skip = () => {
    void markOnboardingDone();
    emit('done');
};

const goBack = () => {
    error.value = '';
    if (step.value === 3) step.value = 2;
    else if (step.value === 2) step.value = 1;
};

const goStart = () => {
    error.value = '';
    step.value = 2;
};

const goBalances = () => {
    error.value = '';
    for (const acc of selectedAccounts.value) {
        if (balances.value[acc.key] == null) setBalance(acc.key, '');
    }
    step.value = 3;
};

const createAccounts = async () => {
    error.value = '';
    busy.value = true;
    try {
        for (const acc of selectedAccounts.value) {
            const amount = moneyInputToNumber(balances.value[acc.key] ?? '');
            await requestJson('/api/contas', {
                method: 'POST',
                body: JSON.stringify({
                    name: acc.label,
                    type: acc.type,
                    icon: acc.icon,
                    institution: acc.type === 'bank' ? (acc.institution ?? acc.label) : null,
                    initial_balance: Math.max(0, amount),
                    color: acc.color,
                    incluir_soma: true,
                }),
            });
        }

        await markOnboardingDone();
        step.value = 4;
    } catch {
        error.value = 'Não foi possível salvar suas contas. Tente novamente.';
    } finally {
        busy.value = false;
    }
};

const finish = () => {
    void markOnboardingDone();
    emit('done');
    router.reload({ only: ['bootstrap'] });
};

watch(
    () => props.open,
    (isOpen) => {
        if (!isOpen) return;
        step.value = 1;
        busy.value = false;
        error.value = '';
        selectedKeys.value = new Set(['wallet']);
        balances.value = {};
    },
);

onMounted(() => {
    // pre-warm
});
</script>

<template>
    <div v-if="open" class="fixed inset-0 z-[95] bg-white">
        <header class="flex items-center justify-between px-5 pt-[calc(1rem+env(safe-area-inset-top))]">
            <button v-if="step > 1 && step < 4" type="button" class="text-sm font-semibold text-slate-600" @click="goBack">Voltar</button>
            <button v-else-if="step < 4" type="button" class="text-sm font-semibold text-slate-400" @click="skip">Pular</button>
            <div v-else class="h-10"></div>

            <div class="flex items-center gap-3">
                <button v-if="step > 1 && step < 4" type="button" class="text-sm font-semibold text-slate-400" @click="skip">Pular</button>
                <button type="button" class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-100 text-slate-600" @click="close" aria-label="Fechar">
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M18 6L6 18" />
                        <path d="M6 6l12 12" />
                    </svg>
                </button>
            </div>
        </header>

        <main class="mx-auto flex h-[calc(100vh-5rem)] w-full max-w-md flex-col px-6 pb-[calc(2rem+env(safe-area-inset-bottom))]">
            <!-- Step 1 -->
            <div v-if="step === 1" class="flex flex-1 flex-col justify-center">
                <div class="flex justify-center">
                    <div class="flex h-16 w-16 items-center justify-center rounded-3xl bg-slate-50 ring-1 ring-slate-200/60">
                        <ApplicationLogo class="h-10 w-10 text-slate-900" />
                    </div>
                </div>
                <div class="mt-6 text-center text-2xl font-semibold tracking-tight text-slate-900">Bem-vindo, {{ firstName }}!</div>
                <div class="mt-2 text-center text-sm font-semibold text-slate-500">Vamos configurar suas finanças em menos de 2 minutos.</div>
                <button type="button" class="mt-8 w-full rounded-2xl bg-teal-500 py-4 text-base font-semibold text-white shadow-lg shadow-teal-500/25" @click="goStart">
                    Começar
                </button>
            </div>

            <!-- Step 2 -->
            <div v-else-if="step === 2" class="flex flex-1 flex-col">
                <div class="mt-6 text-xl font-semibold tracking-tight text-slate-900">Por onde seu dinheiro passa?</div>
                <div class="mt-1 text-sm font-semibold text-slate-500">Selecione as contas que você usa.</div>

                <div class="mt-6 grid grid-cols-2 gap-3">
                    <button
                        v-for="opt in seeds"
                        :key="opt.key"
                        type="button"
                        class="rounded-3xl border bg-white px-4 py-5 text-left transition"
                        :class="[
                            opt.isFuture ? 'cursor-not-allowed opacity-60' : '',
                            selectedKeys.has(opt.key) ? 'border-teal-400 ring-2 ring-teal-200' : 'border-slate-200 hover:border-slate-300',
                        ]"
                        :disabled="opt.isFuture"
                        @click="opt.isFuture ? null : toggle(opt.key)"
                    >
                        <InstitutionAvatar
                            :institution="opt.institution ?? null"
                            :svg-path="opt.svgFile ?? null"
                            :fallback-icon="opt.type === 'wallet' ? 'wallet' : 'account'"
                            :is-wallet="opt.type === 'wallet'"
                            :container-class="'flex h-10 w-10 items-center justify-center overflow-hidden rounded-2xl bg-slate-50 ring-1 ring-slate-200/60'"
                            :img-class="'h-8 w-8 object-contain'"
                            :fallback-icon-class="'h-5 w-5 text-slate-600'"
                        />
                        <div class="mt-2 text-sm font-semibold text-slate-900">{{ opt.label }}</div>
                        <div class="mt-1 text-xs font-semibold" :class="selectedKeys.has(opt.key) ? 'text-teal-600' : 'text-slate-400'">
                            <template v-if="opt.isFuture">Função futura</template>
                            <template v-else>{{ selectedKeys.has(opt.key) ? 'Selecionado' : 'Toque para selecionar' }}</template>
                        </div>
                    </button>
                </div>

                <button type="button" class="mt-4 text-left text-sm font-semibold text-slate-400 cursor-not-allowed" disabled>+ Outro banco (função futura)</button>

                <div class="mt-auto">
                    <button
                        type="button"
                        class="mt-6 w-full rounded-2xl bg-teal-500 py-4 text-base font-semibold text-white shadow-lg shadow-teal-500/25 disabled:cursor-not-allowed disabled:opacity-50"
                        :disabled="!canContinueFromSelect"
                        @click="goBalances"
                    >
                        Continuar
                    </button>
                </div>
            </div>

            <!-- Step 3 -->
            <div v-else-if="step === 3" class="flex flex-1 flex-col">
                <div class="mt-6 text-xl font-semibold tracking-tight text-slate-900">Quanto você tem hoje?</div>
                <div class="mt-1 text-sm font-semibold text-slate-500">Não precisa ser exato, você pode ajustar depois.</div>

                <div class="mt-6 space-y-4">
                    <div v-for="acc in selectedAccounts" :key="acc.key">
                        <div class="mb-2 flex items-center justify-between">
                            <div class="flex items-center gap-2">
                                <InstitutionAvatar
                                    :institution="acc.institution ?? null"
                                    :svg-path="acc.svgFile ?? null"
                                    :fallback-icon="acc.type === 'wallet' ? 'wallet' : 'account'"
                                    :is-wallet="acc.type === 'wallet'"
                                    :container-class="'flex h-8 w-8 items-center justify-center overflow-hidden rounded-2xl bg-slate-50 ring-1 ring-slate-200/60'"
                                    :img-class="'h-6 w-6 object-contain'"
                                    :fallback-icon-class="'h-4 w-4 text-slate-600'"
                                />
                                <div class="text-sm font-semibold text-slate-900">{{ acc.label }}</div>
                            </div>
                            <div class="text-xs font-semibold text-slate-400">Saldo inicial</div>
                        </div>
                        <div class="flex h-12 items-center gap-2 rounded-2xl bg-slate-50 px-4 ring-1 ring-slate-200/60">
                            <span class="text-sm font-semibold text-slate-500">R$</span>
                            <input
                                :value="balances[acc.key] ?? ''"
                                type="text"
                                inputmode="numeric"
                                pattern="[0-9]*"
                                placeholder="0,00"
                                class="w-full bg-transparent text-right text-base font-semibold text-slate-900 outline-none"
                                @keydown="preventNonDigitKeydown"
                                @input="(e) => setBalance(acc.key, (e.target as HTMLInputElement).value)"
                            />
                        </div>
                    </div>
                </div>

                <div v-if="error" class="mt-4 rounded-2xl bg-red-50 px-4 py-3 text-sm font-semibold text-red-600">
                    {{ error }}
                </div>

                <div class="mt-auto">
                    <div class="mb-3 text-xs font-semibold text-slate-400">
                        Total selecionado: {{ formatBRL2(selectedAccounts.reduce((sum, a) => sum + moneyInputToNumber(balances[a.key] ?? ''), 0)) }}
                    </div>
                    <button
                        type="button"
                        class="w-full rounded-2xl bg-teal-500 py-4 text-base font-semibold text-white shadow-lg shadow-teal-500/25 disabled:cursor-not-allowed disabled:opacity-50"
                        :disabled="busy"
                        @click="createAccounts"
                    >
                        {{ busy ? 'Salvando…' : 'Continuar' }}
                    </button>
                </div>
            </div>

            <!-- Step 4 -->
            <div v-else class="flex flex-1 flex-col justify-center text-center">
                <div class="text-4xl">🎉</div>
                <div class="mt-4 text-2xl font-semibold tracking-tight text-slate-900">Tudo pronto!</div>
                <div class="mt-2 text-sm font-semibold text-slate-500">
                    Agora é só registrar seus gastos e o KITAMO te avisa se vai dar pra chegar no fim do mês.
                </div>
                <button type="button" class="mt-8 w-full rounded-2xl bg-teal-500 py-4 text-base font-semibold text-white shadow-lg shadow-teal-500/25" @click="finish">
                    Começar a usar
                </button>
            </div>
        </main>
    </div>
</template>
