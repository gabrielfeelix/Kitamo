<script setup lang="ts">
import { computed, ref, watch } from 'vue';

type CategoryType = 'expense' | 'income';
type IconKey = 'food' | 'home' | 'car' | 'pill' | 'briefcase' | 'heart' | 'shirt' | 'bolt';

const props = defineProps<{
    open: boolean;
}>();

const emit = defineEmits<{
    (event: 'close'): void;
    (event: 'save', payload: { name: string; type: CategoryType; icon: IconKey }): void;
}>();

const name = ref('');
const type = ref<CategoryType>('expense');
const icon = ref<IconKey>('food');

const headerIcon = computed(() => icon.value);

const close = () => emit('close');
const save = () => emit('save', { name: name.value, type: type.value, icon: icon.value });

watch(
    () => props.open,
    (isOpen) => {
        if (!isOpen) return;
        name.value = '';
        type.value = 'expense';
        icon.value = 'food';
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
            <div class="text-xl font-semibold tracking-tight text-slate-900">Nova categoria</div>
        </header>

        <main class="mx-auto w-full max-w-md px-5 pb-[calc(6rem+env(safe-area-inset-bottom))]">
            <div class="flex justify-center pt-2">
                <div class="flex h-16 w-16 items-center justify-center rounded-full bg-orange-400 text-white shadow-lg shadow-black/10">
                    <svg v-if="headerIcon === 'food'" class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M4 3v7" />
                        <path d="M8 3v7" />
                        <path d="M6 3v7" />
                        <path d="M14 3v7c0 2 1 3 3 3v8" />
                        <path d="M20 3v7" />
                    </svg>
                    <svg v-else-if="headerIcon === 'home'" class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M3 10.5L12 3l9 7.5" />
                        <path d="M5 10v10h14V10" />
                    </svg>
                    <svg v-else-if="headerIcon === 'car'" class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M5 16l1-5 1-3h10l1 3 1 5" />
                        <path d="M7 16h10" />
                        <circle cx="8" cy="17" r="1.5" />
                        <circle cx="16" cy="17" r="1.5" />
                    </svg>
                    <svg v-else-if="headerIcon === 'pill'" class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M10 14 8 16a4 4 0 0 1-6-6l2-2a4 4 0 0 1 6 6Z" />
                        <path d="M14 10l2-2a4 4 0 0 1 6 6l-2 2a4 4 0 0 1-6-6Z" />
                        <path d="M8 16l8-8" />
                    </svg>
                    <svg v-else-if="headerIcon === 'briefcase'" class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <rect x="3" y="7" width="18" height="13" rx="3" />
                        <path d="M9 7V5a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2v2" />
                        <path d="M3 12h18" />
                    </svg>
                    <svg v-else-if="headerIcon === 'heart'" class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M20 8c0 5-8 10-8 10S4 13 4 8a4 4 0 0 1 8 0 4 4 0 0 1 8 0Z" />
                    </svg>
                    <svg v-else-if="headerIcon === 'shirt'" class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M15 3H9l-2 4h10l-2-4Z" />
                        <path d="M7 7v14" />
                        <path d="M17 7v14" />
                    </svg>
                    <svg v-else class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M13 2 3 14h8l-1 8 10-12h-8l1-8Z" />
                    </svg>
                </div>
            </div>

            <div class="mt-6 space-y-5">
                <div>
                    <div class="mb-2 text-sm font-semibold text-slate-700">Nome da categoria</div>
                    <input
                        v-model="name"
                        type="text"
                        placeholder="Ex: Alimentação..."
                        class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-4 text-sm font-semibold text-slate-700 placeholder:text-slate-400 focus:border-teal-400 focus:outline-none"
                    />
                </div>

                <div>
                    <div class="mb-2 text-sm font-semibold text-slate-700">Tipo</div>
                    <div class="grid grid-cols-2 gap-3">
                        <button
                            type="button"
                            class="rounded-2xl px-4 py-3 text-sm font-semibold"
                            :class="type === 'expense' ? 'bg-red-50 text-red-500 ring-1 ring-red-100' : 'bg-white text-slate-500 ring-1 ring-slate-200'"
                            @click="type = 'expense'"
                        >
                            Despesa
                        </button>
                        <button
                            type="button"
                            class="rounded-2xl px-4 py-3 text-sm font-semibold"
                            :class="type === 'income' ? 'bg-emerald-50 text-emerald-600 ring-1 ring-emerald-100' : 'bg-white text-slate-500 ring-1 ring-slate-200'"
                            @click="type = 'income'"
                        >
                            Receita
                        </button>
                    </div>
                </div>

                <div>
                    <div class="mb-2 text-sm font-semibold text-slate-700">Ícone</div>
                    <div class="grid grid-cols-4 gap-4">
                        <button type="button" class="flex h-14 w-full items-center justify-center rounded-2xl bg-slate-50 ring-1 ring-slate-200" :class="icon === 'food' ? 'ring-2 ring-teal-400' : ''" @click="icon = 'food'" aria-label="Alimentação">
                            <svg class="h-6 w-6 text-slate-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M4 3v7" />
                                <path d="M8 3v7" />
                                <path d="M6 3v7" />
                                <path d="M14 3v7c0 2 1 3 3 3v8" />
                                <path d="M20 3v7" />
                            </svg>
                        </button>
                        <button type="button" class="flex h-14 w-full items-center justify-center rounded-2xl bg-slate-50 ring-1 ring-slate-200" :class="icon === 'home' ? 'ring-2 ring-teal-400' : ''" @click="icon = 'home'" aria-label="Moradia">
                            <svg class="h-6 w-6 text-slate-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M3 10.5L12 3l9 7.5" />
                                <path d="M5 10v10h14V10" />
                            </svg>
                        </button>
                        <button type="button" class="flex h-14 w-full items-center justify-center rounded-2xl bg-slate-50 ring-1 ring-slate-200" :class="icon === 'car' ? 'ring-2 ring-teal-400' : ''" @click="icon = 'car'" aria-label="Transporte">
                            <svg class="h-6 w-6 text-slate-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M5 16l1-5 1-3h10l1 3 1 5" />
                                <path d="M7 16h10" />
                                <circle cx="8" cy="17" r="1.5" />
                                <circle cx="16" cy="17" r="1.5" />
                            </svg>
                        </button>
                        <button type="button" class="flex h-14 w-full items-center justify-center rounded-2xl bg-slate-50 ring-1 ring-slate-200" :class="icon === 'pill' ? 'ring-2 ring-teal-400' : ''" @click="icon = 'pill'" aria-label="Remédio">
                            <svg class="h-6 w-6 text-slate-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M10 14 8 16a4 4 0 0 1-6-6l2-2a4 4 0 0 1 6 6Z" />
                                <path d="M14 10l2-2a4 4 0 0 1 6 6l-2 2a4 4 0 0 1-6-6Z" />
                                <path d="M8 16l8-8" />
                            </svg>
                        </button>
                        <button type="button" class="flex h-14 w-full items-center justify-center rounded-2xl bg-slate-50 ring-1 ring-slate-200" :class="icon === 'briefcase' ? 'ring-2 ring-teal-400' : ''" @click="icon = 'briefcase'" aria-label="Trabalho">
                            <svg class="h-6 w-6 text-slate-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="7" width="18" height="13" rx="3" />
                                <path d="M9 7V5a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2v2" />
                                <path d="M3 12h18" />
                            </svg>
                        </button>
                        <button type="button" class="flex h-14 w-full items-center justify-center rounded-2xl bg-slate-50 ring-1 ring-slate-200" :class="icon === 'heart' ? 'ring-2 ring-teal-400' : ''" @click="icon = 'heart'" aria-label="Saúde">
                            <svg class="h-6 w-6 text-slate-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M20 8c0 5-8 10-8 10S4 13 4 8a4 4 0 0 1 8 0 4 4 0 0 1 8 0Z" />
                            </svg>
                        </button>
                        <button type="button" class="flex h-14 w-full items-center justify-center rounded-2xl bg-slate-50 ring-1 ring-slate-200" :class="icon === 'shirt' ? 'ring-2 ring-teal-400' : ''" @click="icon = 'shirt'" aria-label="Roupas">
                            <svg class="h-6 w-6 text-slate-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M15 3H9l-2 4h10l-2-4Z" />
                                <path d="M7 7v14" />
                                <path d="M17 7v14" />
                            </svg>
                        </button>
                        <button type="button" class="flex h-14 w-full items-center justify-center rounded-2xl bg-slate-50 ring-1 ring-slate-200" :class="icon === 'bolt' ? 'ring-2 ring-teal-400' : ''" @click="icon = 'bolt'" aria-label="Energia">
                            <svg class="h-6 w-6 text-slate-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M13 2 3 14h8l-1 8 10-12h-8l1-8Z" />
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
                    Salvar categoria
                </button>
            </div>
        </footer>
    </div>
</template>

