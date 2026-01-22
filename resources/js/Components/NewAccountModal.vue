<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import PickerSheet from '@/Components/PickerSheet.vue';
import { formatMoneyInputCentsShift, moneyInputToNumber, numberToMoneyInput } from '@/lib/moneyInput';
import { preventNonDigitKeydown } from '@/lib/inputGuards';

type BankAccountType = 'corrente' | 'poupanca' | 'salario';

const props = defineProps<{
    open: boolean;
    initial?: {
        id: string;
        name: string;
        icon?: string | null;
        current_balance: number;
        color?: string | null;
        incluir_soma?: boolean;
        institution?: string | null;
        bank_account_type?: BankAccountType | string | null;
    } | null;
}>();

const emit = defineEmits<{
    (event: 'close'): void;
    (event: 'save', payload: {
        id: string;
        name: string;
        icon: string;
        current_balance: number;
        color: string;
        incluir_soma: boolean;
        institution: string | null;
        bank_account_type: BankAccountType;
    }): void;
}>();

const institutions = [
    { nome: 'Nubank', logo: '🟣', cor: '#8B10AE' },
    { nome: 'Banco Inter', logo: '🟢', cor: '#FF7A00' },
    { nome: 'Itaú', logo: '🟠', cor: '#EC7000' },
    { nome: 'Bradesco', logo: '🔴', cor: '#CC092F' },
    { nome: 'Banco do Brasil', logo: '🟡', cor: '#FFDD00' },
    { nome: 'Caixa', logo: '🔵', cor: '#0066B3' },
    { nome: 'Santander', logo: '🔴', cor: '#EC0000' },
    { nome: 'C6 Bank', logo: '⚫', cor: '#000000' },
    { nome: 'PicPay', logo: '🟢', cor: '#21C25E' },
    { nome: 'Neon', logo: '🔵', cor: '#00D9E1' },
    { nome: 'Outro', logo: '⚪', cor: '#64748B' },
] as const;

const colors = ['#14B8A6', '#10B981', '#3B82F6', '#8B5CF6', '#F59E0B', '#EF4444'];
const icons = ['bank', 'phone', 'home'] as const;

const institutionSheetOpen = ref(false);
const institutionSearch = ref('');

const selectedInstitution = ref<string | null>(null);
const nickname = ref('');
const currentBalanceInput = ref('');
const bankAccountType = ref<BankAccountType>('corrente');
const color = ref('#14B8A6');
const incluirSoma = ref(true);
const icon = ref<(typeof icons)[number]>('bank');

const filteredInstitutions = computed(() => {
    const term = institutionSearch.value.trim().toLowerCase();
    if (!term) return institutions;
    return institutions.filter((b) => b.nome.toLowerCase().includes(term));
});

const displayInstitution = computed(() => selectedInstitution.value || 'Selecione');

const canSave = computed(() => nickname.value.trim().length > 0);

const parseName = (value: string) => {
    const raw = value ?? '';
    const parts = raw.split(' - ').map((p) => p.trim()).filter(Boolean);
    if (parts.length >= 2) {
        return { institution: parts[0] ?? null, nickname: parts.slice(1).join(' - ') };
    }
    return { institution: null, nickname: raw.trim() };
};

const onBalanceInput = (event: Event) => {
    const target = event.target as HTMLInputElement;
    currentBalanceInput.value = formatMoneyInputCentsShift(target.value);
};

const currentBalanceNumber = computed(() => moneyInputToNumber(currentBalanceInput.value));

const close = () => emit('close');

const save = () => {
    if (!props.initial?.id) return;
    const inst = selectedInstitution.value && selectedInstitution.value !== 'Outro' ? selectedInstitution.value : null;
    const nick = nickname.value.trim();
    const composedName = inst ? `${inst}${nick ? ` - ${nick}` : ''}`.trim() : nick;
    if (!composedName) return;

    emit('save', {
        id: props.initial.id,
        name: composedName,
        icon: icon.value,
        current_balance: currentBalanceNumber.value,
        color: color.value,
        incluir_soma: incluirSoma.value,
        institution: inst,
        bank_account_type: bankAccountType.value,
    });
};

watch(
    () => props.open,
    (isOpen) => {
        if (!isOpen) return;
        const initial = props.initial ?? null;
        institutionSearch.value = '';
        if (!initial) return;

        const parsed = parseName(initial.name);
        selectedInstitution.value = initial.institution ?? parsed.institution ?? 'Outro';
        nickname.value = parsed.nickname;

        currentBalanceInput.value = numberToMoneyInput(Number(initial.current_balance ?? 0));
        color.value = initial.color ?? '#14B8A6';
        incluirSoma.value = initial.incluir_soma ?? true;

        const bt = String(initial.bank_account_type ?? 'corrente');
        bankAccountType.value = bt === 'poupanca' ? 'poupanca' : bt === 'salario' ? 'salario' : 'corrente';

        const iconValue = String(initial.icon ?? 'bank');
        icon.value = (icons as readonly string[]).includes(iconValue) ? (iconValue as any) : 'bank';
    },
);
</script>

<template>
    <div v-if="open" class="fixed inset-0 z-[90] bg-white">
        <header class="flex items-center gap-3 px-5 pb-4 pt-[calc(1rem+env(safe-area-inset-top))]">
            <button
                type="button"
                class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-100 text-slate-600"
                aria-label="Voltar"
                @click="close"
            >
                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M15 18l-6-6 6-6" />
                </svg>
            </button>
            <div class="text-xl font-semibold tracking-tight text-slate-900">Editar conta</div>
        </header>

        <main class="mx-auto w-full max-w-md px-5 pb-[calc(6rem+env(safe-area-inset-bottom))]">
            <div class="flex justify-center pt-2">
                <div class="flex h-16 w-16 items-center justify-center rounded-3xl text-white shadow-lg shadow-black/10" :style="{ backgroundColor: color }">
                    <svg v-if="icon === 'bank'" class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M3 10h18" />
                        <path d="M5 10V8l7-5 7 5v2" />
                        <path d="M6 10v9" />
                        <path d="M18 10v9" />
                    </svg>
                    <svg v-else-if="icon === 'phone'" class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <rect x="7" y="2" width="10" height="20" rx="2" />
                        <path d="M11 19h2" />
                    </svg>
                    <svg v-else class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M3 10h18" />
                        <path d="M5 10V8l7-5 7 5v2" />
                        <path d="M6 10v9" />
                        <path d="M18 10v9" />
                    </svg>
                </div>
            </div>

            <div class="mt-6 space-y-5">
                <div>
                    <div class="mb-2 text-sm font-semibold text-slate-700">Instituição financeira</div>
                    <button
                        type="button"
                        class="flex w-full items-center justify-between rounded-2xl border border-slate-200 bg-slate-50 px-4 py-4 text-left text-sm font-semibold text-slate-700"
                        @click="institutionSheetOpen = true"
                    >
                        <span class="truncate">{{ displayInstitution }}</span>
                        <svg class="h-5 w-5 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 5l7 7-7 7" />
                        </svg>
                    </button>
                </div>

                <div>
                    <div class="mb-2 text-sm font-semibold text-slate-700">Nome da conta</div>
                    <input
                        v-model="nickname"
                        type="text"
                        placeholder="Ex: Conta pessoal"
                        class="w-full appearance-none rounded-2xl border border-slate-200 bg-slate-50 px-4 py-4 text-sm font-semibold text-slate-700 placeholder:text-slate-400 focus:border-teal-400 focus:outline-none focus:ring-0 focus-visible:outline-none"
                    />
                </div>

                <div>
                    <div class="mb-2 text-sm font-semibold text-slate-700">Saldo atual</div>
                    <input
                        :value="currentBalanceInput"
                        type="text"
                        inputmode="numeric"
                        pattern="[0-9]*"
                        placeholder="0,00"
                        class="w-full appearance-none rounded-2xl border border-slate-200 bg-slate-50 px-4 py-4 text-sm font-semibold text-slate-700 focus:border-teal-400 focus:outline-none focus:ring-0 focus-visible:outline-none"
                        @input="onBalanceInput"
                        @keydown="preventNonDigitKeydown"
                        aria-label="Saldo atual"
                    />
                </div>

                <div>
                    <div class="mb-2 text-sm font-semibold text-slate-700">Tipo de conta</div>
                    <div class="grid grid-cols-3 gap-3">
                        <button
                            type="button"
                            class="rounded-2xl px-4 py-3 text-sm font-semibold"
                            :class="bankAccountType === 'corrente' ? 'bg-teal-500 text-white' : 'bg-white text-slate-500 ring-1 ring-slate-200'"
                            @click="bankAccountType = 'corrente'"
                        >
                            Corrente
                        </button>
                        <button
                            type="button"
                            class="rounded-2xl px-4 py-3 text-sm font-semibold"
                            :class="bankAccountType === 'poupanca' ? 'bg-teal-500 text-white' : 'bg-white text-slate-500 ring-1 ring-slate-200'"
                            @click="bankAccountType = 'poupanca'"
                        >
                            Poupança
                        </button>
                        <button
                            type="button"
                            class="rounded-2xl px-4 py-3 text-sm font-semibold"
                            :class="bankAccountType === 'salario' ? 'bg-teal-500 text-white' : 'bg-white text-slate-500 ring-1 ring-slate-200'"
                            @click="bankAccountType = 'salario'"
                        >
                            Salário
                        </button>
                    </div>
                </div>

                <div>
                    <div class="mb-2 text-sm font-semibold text-slate-700">Cor da conta</div>
                    <div class="flex gap-3">
                        <button
                            v-for="c in colors"
                            :key="c"
                            type="button"
                            class="h-12 w-12 rounded-2xl border-2 transition"
                            :style="{ backgroundColor: c }"
                            :class="color === c ? 'border-slate-900 ring-2 ring-white ring-offset-2 ring-offset-slate-900' : 'border-transparent hover:border-slate-200'"
                            @click="color = c"
                            :aria-label="`Cor ${c}`"
                        />
                    </div>
                </div>

                <div class="rounded-2xl border border-slate-200 bg-slate-50 px-4 py-4">
                    <div class="flex items-center justify-between">
                        <div class="text-sm font-semibold text-slate-700">Incluir na soma da tela inicial</div>
                        <button
                            type="button"
                            class="relative inline-flex h-6 w-11 items-center rounded-full transition"
                            :class="incluirSoma ? 'bg-teal-500' : 'bg-slate-300'"
                            @click="incluirSoma = !incluirSoma"
                            aria-label="Incluir na soma"
                        >
                            <span class="inline-block h-5 w-5 transform rounded-full bg-white transition" :class="incluirSoma ? 'translate-x-5' : 'translate-x-0.5'"></span>
                        </button>
                    </div>
                </div>

                <div>
                    <div class="mb-2 text-sm font-semibold text-slate-700">Ícone</div>
                    <div class="grid grid-cols-3 gap-4">
                        <button
                            v-for="i in icons"
                            :key="i"
                            type="button"
                            class="flex h-14 w-full items-center justify-center rounded-2xl bg-slate-50 ring-1 ring-slate-200"
                            :class="icon === i ? 'ring-2 ring-teal-400' : ''"
                            @click="icon = i"
                            :aria-label="`Ícone ${i}`"
                        >
                            <svg v-if="i === 'bank'" class="h-6 w-6 text-slate-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M3 10h18" />
                                <path d="M5 10V8l7-5 7 5v2" />
                                <path d="M6 10v9" />
                                <path d="M18 10v9" />
                            </svg>
                            <svg v-else-if="i === 'phone'" class="h-6 w-6 text-slate-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="7" y="2" width="10" height="20" rx="2" />
                                <path d="M11 19h2" />
                            </svg>
                            <svg v-else class="h-6 w-6 text-slate-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M4 19V5" />
                                <path d="M10 19V9" />
                                <path d="M16 19v-4" />
                                <path d="M22 19V7" />
                            </svg>
                        </button>
                    </div>
                </div>
            </div>
        </main>

        <footer class="fixed inset-x-0 bottom-0 bg-white px-5 pb-[calc(1rem+env(safe-area-inset-bottom))] pt-3 shadow-[0_-18px_40px_-32px_rgba(15,23,42,0.45)]">
            <div class="mx-auto w-full max-w-md">
                <button
                    type="button"
                    class="w-full rounded-2xl py-4 text-base font-semibold text-white transition-all"
                    :class="canSave
                        ? 'bg-teal-500 shadow-lg shadow-teal-500/25'
                        : 'bg-slate-300 shadow-none cursor-not-allowed opacity-60'"
                    :disabled="!canSave"
                    @click="save"
                >
                    Salvar alterações
                </button>
            </div>
        </footer>
    </div>

    <PickerSheet :open="institutionSheetOpen" title="Instituição financeira" @close="institutionSheetOpen = false">
        <div class="space-y-4">
            <input
                v-model="institutionSearch"
                type="text"
                placeholder="Buscar por nome"
                class="w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm font-semibold text-slate-700 placeholder:text-slate-400 focus:border-teal-400 focus:outline-none focus:ring-0"
            />
            <div class="grid grid-cols-2 gap-3">
                <button
                    v-for="banco in filteredInstitutions"
                    :key="banco.nome"
                    type="button"
                    class="flex items-center gap-3 rounded-2xl bg-slate-50 px-4 py-4 text-left ring-1 ring-slate-200/70"
                    @click="() => { selectedInstitution = banco.nome; institutionSheetOpen = false; }"
                >
                    <span class="flex h-10 w-10 items-center justify-center rounded-2xl text-lg" :style="{ backgroundColor: `${banco.cor}22`, color: banco.cor }">{{ banco.logo }}</span>
                    <div class="min-w-0 flex-1">
                        <div class="truncate text-sm font-semibold text-slate-900">{{ banco.nome }}</div>
                    </div>
                </button>
            </div>
        </div>
    </PickerSheet>
</template>

