<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import CategoryIcon from '@/Components/CategoryIcon.vue';

type CategoryType = 'expense' | 'income';
type IconKey = 'cart' | 'food' | 'home' | 'car' | 'sparkles' | 'game' | 'pill' | 'briefcase' | 'heart' | 'shirt' | 'bolt' | 'money' | 'trend' | 'gym';

const props = defineProps<{
    open: boolean;
    initialType?: CategoryType;
}>();

const emit = defineEmits<{
    (event: 'close'): void;
    (event: 'save', payload: { name: string; type: CategoryType; icon: IconKey }): void;
}>();

const name = ref('');
const type = ref<CategoryType>('expense');
const icon = ref<IconKey>('cart');

const headerIcon = computed(() => icon.value);
const headerColor = computed(() => (type.value === 'expense' ? '#EF4444' : '#10B981'));
const canSave = computed(() => name.value.trim().length > 0);

const iconOptions: Array<{ key: IconKey; label: string }> = [
    { key: 'cart', label: 'Compras' },
    { key: 'food', label: 'Alimentação' },
    { key: 'home', label: 'Moradia' },
    { key: 'car', label: 'Transporte' },
    { key: 'sparkles', label: 'Lazer' },
    { key: 'game', label: 'Games' },
    { key: 'pill', label: 'Saúde' },
    { key: 'briefcase', label: 'Trabalho' },
    { key: 'heart', label: 'Bem-estar' },
    { key: 'shirt', label: 'Roupas' },
    { key: 'bolt', label: 'Energia' },
    { key: 'money', label: 'Dinheiro' },
    { key: 'trend', label: 'Investimentos' },
    { key: 'gym', label: 'Academia' },
];

const close = () => emit('close');
const save = () => emit('save', { name: name.value, type: type.value, icon: icon.value });

watch(
    () => props.open,
    (isOpen) => {
        if (!isOpen) return;
        name.value = '';
        type.value = props.initialType ?? 'expense';
        icon.value = 'cart';
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
                <div
                    class="flex h-16 w-16 items-center justify-center rounded-full text-white shadow-lg shadow-black/10"
                    :style="{ backgroundColor: headerColor }"
                >
                    <CategoryIcon :icon="headerIcon" class="h-7 w-7 text-white" />
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
                    <div class="-mx-1 flex gap-4 overflow-x-auto pb-2 px-1">
                        <button
                            v-for="opt in iconOptions"
                            :key="opt.key"
                            type="button"
                            class="flex h-12 w-[38px] shrink-0 items-center justify-center rounded-2xl bg-slate-50 ring-1 ring-slate-200"
                            :class="icon === opt.key ? 'ring-2 ring-teal-400' : ''"
                            @click="icon = opt.key"
                            :aria-label="opt.label"
                        >
                            <CategoryIcon :icon="opt.key" class="h-6 w-6 text-slate-600" />
                        </button>
                    </div>
                    <div class="mt-1 text-xs font-semibold text-slate-400">Arraste para o lado para ver mais ícones.</div>
                </div>
            </div>
        </main>

        <footer class="fixed inset-x-0 bottom-0 bg-white px-5 pb-[calc(1rem+env(safe-area-inset-bottom))] pt-3 shadow-[0_-18px_40px_-32px_rgba(15,23,42,0.45)]">
            <div class="mx-auto w-full max-w-md">
                <button
                    type="button"
                    class="w-full rounded-2xl py-4 text-base font-semibold text-white transition-all"
                    :class="canSave ? 'bg-teal-500 shadow-lg shadow-teal-500/25' : 'bg-slate-300 shadow-none cursor-not-allowed opacity-60'"
                    :disabled="!canSave"
                    @click="save"
                >
                    Salvar categoria
                </button>
            </div>
        </footer>
    </div>
</template>
