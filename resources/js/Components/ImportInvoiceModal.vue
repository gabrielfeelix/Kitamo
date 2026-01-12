<script setup lang="ts">
import { computed, onBeforeUnmount, ref, watch } from 'vue';

type Step = 'pick' | 'analyzing' | 'review';

const props = defineProps<{
    open: boolean;
}>();

const emit = defineEmits<{
    (event: 'close'): void;
    (event: 'imported', payload: { importedCount: number; items: Array<{ title: string; amount: number }> }): void;
}>();

const close = () => emit('close');

const step = ref<Step>('pick');
const file = ref<File | null>(null);
const progress = ref(0);

type ReviewItem = { id: string; title: string; amount: number; selected: boolean };
const items = ref<ReviewItem[]>([]);

const fileInput = ref<HTMLInputElement | null>(null);
const cameraInput = ref<HTMLInputElement | null>(null);

let progressTimer: number | null = null;

const reset = () => {
    step.value = 'pick';
    file.value = null;
    progress.value = 0;
    items.value = [];
    if (progressTimer) {
        window.clearInterval(progressTimer);
        progressTimer = null;
    }
};

watch(
    () => props.open,
    (isOpen) => {
        if (!isOpen) return;
        reset();
    },
);

onBeforeUnmount(() => reset());

const openPicker = () => fileInput.value?.click();
const openCamera = () => cameraInput.value?.click();

const formatMoney = (value: number) =>
    new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL',
    }).format(value);

const startAnalyzing = (selectedFile: File) => {
    file.value = selectedFile;
    step.value = 'analyzing';
    progress.value = 0;

    if (progressTimer) window.clearInterval(progressTimer);
    progressTimer = window.setInterval(() => {
        progress.value = Math.min(100, progress.value + 4);
        if (progress.value >= 100 && progressTimer) {
            window.clearInterval(progressTimer);
            progressTimer = null;
        }
    }, 60);

    window.setTimeout(() => {
        step.value = 'review';
        items.value = [
            { id: 'netflix', title: 'Netflix', amount: 44.9, selected: true },
            { id: 'uber', title: 'Uber', amount: 25, selected: true },
        ];
        progress.value = 100;
    }, 1500);
};

const onFileChange = (event: Event) => {
    const target = event.target as HTMLInputElement;
    const selected = target.files?.[0];
    if (!selected) return;
    startAnalyzing(selected);
    target.value = '';
};

const importedCount = computed(() => items.value.filter((i) => i.selected).length);
const canImport = computed(() => importedCount.value > 0);

const importNow = () => {
    emit('imported', {
        importedCount: importedCount.value,
        items: items.value.filter((i) => i.selected).map((i) => ({ title: i.title, amount: i.amount })),
    });
    close();
};
</script>

<template>
    <div v-if="open" class="fixed inset-0 z-[85] bg-white">
        <header class="flex items-center gap-3 px-5 pb-4 pt-[calc(1rem+env(safe-area-inset-top))]">
            <button
                v-if="step !== 'review'"
                type="button"
                class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-100 text-slate-600"
                aria-label="Voltar"
                @click="close"
            >
                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M15 18l-6-6 6-6" />
                </svg>
            </button>

            <div class="flex-1 text-xl font-semibold tracking-tight text-slate-900">
                {{ step === 'review' ? 'Revisar' : 'Importar fatura' }}
            </div>

            <button
                v-if="step === 'review'"
                type="button"
                class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-100 text-slate-600"
                aria-label="Fechar"
                @click="close"
            >
                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M18 6L6 18" />
                    <path d="M6 6l12 12" />
                </svg>
            </button>
        </header>

        <main class="mx-auto w-full max-w-md px-5 pb-[calc(6rem+env(safe-area-inset-bottom))]">
            <input ref="fileInput" class="hidden" type="file" accept="application/pdf,image/*" @change="onFileChange" />
            <input ref="cameraInput" class="hidden" type="file" accept="image/*" capture="environment" @change="onFileChange" />

            <div v-if="step === 'pick'" class="flex min-h-[70vh] items-center justify-center">
                <div class="w-full rounded-[28px] border-2 border-dashed border-slate-200 bg-white p-8 text-center">
                    <div class="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-slate-100 text-slate-400">
                        <svg class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
                            <path d="M14 2v6h6" />
                            <path d="M8 13h8" />
                            <path d="M8 17h6" />
                        </svg>
                    </div>

                    <div class="mt-6 text-lg font-semibold text-slate-900">Adicione a fatura</div>
                    <div class="mt-1 text-sm font-semibold text-slate-400">PDF ou foto</div>

                    <div class="mt-8 space-y-3">
                        <button
                            type="button"
                            class="flex h-12 w-full items-center justify-center gap-2 rounded-2xl bg-[#14B8A6] text-sm font-semibold text-white shadow-lg shadow-emerald-500/20"
                            @click="openCamera"
                        >
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M4 7h4l2-2h4l2 2h4v12H4V7Z" />
                                <circle cx="12" cy="13" r="3" />
                            </svg>
                            Tirar foto
                        </button>
                        <button
                            type="button"
                            class="flex h-12 w-full items-center justify-center gap-2 rounded-2xl border border-[#14B8A6] bg-white text-sm font-semibold text-[#14B8A6]"
                            @click="openPicker"
                        >
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M4 7h6l2 2h8v10H4V7Z" />
                            </svg>
                            Escolher arquivo
                        </button>
                    </div>
                </div>
            </div>

            <div v-else-if="step === 'analyzing'" class="flex min-h-[70vh] flex-col items-center justify-center">
                <div class="relative h-20 w-20">
                    <div class="absolute inset-0 rounded-full border-4 border-slate-100"></div>
                    <div class="absolute inset-0 rounded-full border-4 border-[#14B8A6] border-t-transparent animate-spin"></div>
                </div>
                <div class="mt-8 text-lg font-semibold text-slate-900">Analisando...</div>
                <div class="mt-10 h-2 w-full overflow-hidden rounded-full bg-slate-100">
                    <div class="h-full bg-[#14B8A6] transition-all" :style="{ width: `${progress}%` }"></div>
                </div>
                <div class="mt-3 text-xs font-semibold text-slate-400">{{ file?.name }}</div>
            </div>

            <div v-else class="mt-4 space-y-3">
                <div
                    v-for="it in items"
                    :key="it.id"
                    class="flex items-center justify-between gap-3 rounded-2xl bg-white px-4 py-4 shadow-sm ring-1 ring-slate-200/60"
                >
                    <label class="flex flex-1 items-center gap-3">
                        <input v-model="it.selected" type="checkbox" class="h-5 w-5 rounded-md border-slate-300 text-blue-600" />
                        <div class="text-sm font-semibold text-slate-900">{{ it.title }}</div>
                    </label>
                    <div class="text-sm font-semibold text-[#EF4444]">-{{ formatMoney(it.amount).replace('R$', 'R$') }}</div>
                </div>
            </div>
        </main>

        <footer v-if="step === 'review'" class="fixed inset-x-0 bottom-0 bg-white px-5 pb-[calc(1rem+env(safe-area-inset-bottom))] pt-3 shadow-[0_-18px_40px_-32px_rgba(15,23,42,0.45)]">
            <div class="mx-auto w-full max-w-md">
                <button
                    type="button"
                    class="h-[52px] w-full rounded-2xl bg-[#14B8A6] text-base font-bold text-white shadow-[0_2px_8px_rgba(20,184,166,0.25)] disabled:opacity-60"
                    :disabled="!canImport"
                    @click="importNow"
                >
                    Importar
                </button>
            </div>
        </footer>
    </div>
</template>
