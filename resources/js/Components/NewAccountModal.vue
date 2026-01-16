<script setup lang="ts">
	import { computed, ref, watch } from 'vue';
import { formatMoneyInputCentsShift } from '@/lib/moneyInput';

	type AccountType = 'wallet' | 'bank' | 'card';

	const props = defineProps<{
	    open: boolean;
	    initial?: { id: string; name: string; type: AccountType; icon: string } | null;
	}>();

	const emit = defineEmits<{
	    (event: 'close'): void;
	    (event: 'save', payload: { id?: string; name: string; type: AccountType; initialBalance: string; icon: string }): void;
	}>();

const name = ref('');
const type = ref<AccountType>('wallet');
const initialBalance = ref('');
	const icon = ref<'wallet' | 'bank' | 'card' | 'phone'>('wallet');

	const isEdit = computed(() => Boolean(props.initial?.id));

const onInitialBalanceInput = (event: Event) => {
    const target = event.target as HTMLInputElement;
    initialBalance.value = formatMoneyInputCentsShift(target.value);
};

const headerIcon = computed(() => {
    switch (icon.value) {
        case 'bank':
            return 'bank';
        case 'card':
            return 'card';
        case 'phone':
            return 'phone';
        default:
            return 'wallet';
    }
});

const close = () => emit('close');
	const save = () =>
	    emit('save', { id: props.initial?.id, name: name.value, type: type.value, initialBalance: initialBalance.value, icon: icon.value });

	watch(
	    () => props.open,
	    (isOpen) => {
	        if (!isOpen) return;
	        name.value = props.initial?.name ?? '';
	        type.value = props.initial?.type ?? 'wallet';
	        initialBalance.value = '';
	        icon.value = (props.initial?.icon as any) ?? 'wallet';
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
	            <div class="text-xl font-semibold tracking-tight text-slate-900">{{ isEdit ? 'Editar conta' : 'Nova conta' }}</div>
	        </header>

        <main class="mx-auto w-full max-w-md px-5 pb-[calc(6rem+env(safe-area-inset-bottom))]">
            <div class="flex justify-center pt-2">
                <div class="flex h-16 w-16 items-center justify-center rounded-full bg-amber-400 text-white shadow-lg shadow-black/10">
                    <svg v-if="headerIcon === 'wallet'" class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M4 7h16v12H4z" />
                        <path d="M4 7V5h12v2" />
                        <path d="M16 12h4" />
                    </svg>
                    <svg v-else-if="headerIcon === 'bank'" class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M3 10h18" />
                        <path d="M5 10V8l7-5 7 5v2" />
                        <path d="M6 10v9" />
                        <path d="M18 10v9" />
                    </svg>
                    <svg v-else-if="headerIcon === 'card'" class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <rect x="3" y="5" width="18" height="14" rx="3" />
                        <path d="M3 10h18" />
                    </svg>
                    <svg v-else class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <rect x="7" y="2" width="10" height="20" rx="2" />
                        <path d="M11 19h2" />
                    </svg>
                </div>
            </div>

            <div class="mt-6 space-y-5">
                <div>
                    <div class="mb-2 text-sm font-semibold text-slate-700">Nome da conta</div>
                    <input
                        v-model="name"
                        type="text"
                        placeholder="Ex: Banco Inter, Carteira..."
                        class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-4 text-sm font-semibold text-slate-700 placeholder:text-slate-400 focus:border-teal-400 focus:outline-none"
                    />
                </div>

                <div>
                    <div class="mb-2 text-sm font-semibold text-slate-700">Tipo de conta</div>
                    <div class="grid grid-cols-3 gap-3">
                        <button
                            type="button"
                            class="rounded-2xl px-4 py-3 text-sm font-semibold"
                            :class="type === 'wallet' ? 'bg-teal-500 text-white' : 'bg-white text-slate-500 ring-1 ring-slate-200'"
                            @click="type = 'wallet'"
                        >
                            Carteira
                        </button>
                        <button
                            type="button"
                            class="rounded-2xl px-4 py-3 text-sm font-semibold"
                            :class="type === 'bank' ? 'bg-teal-500 text-white' : 'bg-white text-slate-500 ring-1 ring-slate-200'"
                            @click="type = 'bank'"
                        >
                            Banco
                        </button>
                        <button
                            type="button"
                            class="rounded-2xl px-4 py-3 text-sm font-semibold"
                            :class="type === 'card' ? 'bg-teal-500 text-white' : 'bg-white text-slate-500 ring-1 ring-slate-200'"
                            @click="type = 'card'"
                        >
                            Cartão
                        </button>
                    </div>
                </div>

	                <div v-if="!isEdit">
	                    <div class="mb-2 text-sm font-semibold text-slate-700">Saldo inicial</div>
	                    <input
	                        :value="initialBalance"
	                        @input="onInitialBalanceInput"
	                        inputmode="decimal"
	                        type="text"
	                        placeholder="0,00"
	                        class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-4 text-sm font-semibold text-slate-700 focus:border-teal-400 focus:outline-none"
	                        aria-label="Saldo inicial"
	                    />
	                </div>

                <div>
                    <div class="mb-2 text-sm font-semibold text-slate-700">Ícone</div>
                    <div class="grid grid-cols-4 gap-4">
                        <button
                            type="button"
                            class="flex h-14 w-full items-center justify-center rounded-2xl bg-slate-50 ring-1 ring-slate-200"
                            :class="icon === 'wallet' ? 'ring-2 ring-teal-400' : ''"
                            @click="icon = 'wallet'"
                            aria-label="Carteira"
                        >
                            <svg class="h-6 w-6 text-slate-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M4 7h16v12H4z" />
                                <path d="M4 7V5h12v2" />
                                <path d="M16 12h4" />
                            </svg>
                        </button>
                        <button
                            type="button"
                            class="flex h-14 w-full items-center justify-center rounded-2xl bg-slate-50 ring-1 ring-slate-200"
                            :class="icon === 'bank' ? 'ring-2 ring-teal-400' : ''"
                            @click="icon = 'bank'"
                            aria-label="Banco"
                        >
                            <svg class="h-6 w-6 text-slate-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M3 10h18" />
                                <path d="M5 10V8l7-5 7 5v2" />
                                <path d="M6 10v9" />
                                <path d="M18 10v9" />
                            </svg>
                        </button>
                        <button
                            type="button"
                            class="flex h-14 w-full items-center justify-center rounded-2xl bg-slate-50 ring-1 ring-slate-200"
                            :class="icon === 'card' ? 'ring-2 ring-teal-400' : ''"
                            @click="icon = 'card'"
                            aria-label="Cartão"
                        >
                            <svg class="h-6 w-6 text-slate-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="5" width="18" height="14" rx="3" />
                                <path d="M3 10h18" />
                            </svg>
                        </button>
                        <button
                            type="button"
                            class="flex h-14 w-full items-center justify-center rounded-2xl bg-slate-50 ring-1 ring-slate-200"
                            :class="icon === 'phone' ? 'ring-2 ring-teal-400' : ''"
                            @click="icon = 'phone'"
                            aria-label="Celular"
                        >
                            <svg class="h-6 w-6 text-slate-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="7" y="2" width="10" height="20" rx="2" />
                                <path d="M11 19h2" />
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
                    class="w-full rounded-2xl bg-teal-500 py-4 text-base font-semibold text-white shadow-lg shadow-teal-500/25"
                    @click="save"
                >
                    Salvar conta
                </button>
            </div>
        </footer>
    </div>
</template>
