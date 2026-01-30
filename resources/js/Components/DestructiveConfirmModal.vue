<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import Modal from '@/Components/Modal.vue';

const props = withDefaults(
    defineProps<{
        show: boolean;
        title: string;
        actionLabel?: string;
        itemTitle: string;
        itemSubtitle?: string | null;
        consequences?: string[];
        confirmWord?: string;
        confirmLabel?: string;
        busy?: boolean;
    }>(),
    {
        actionLabel: 'excluir',
        itemSubtitle: null,
        consequences: () => [],
        confirmWord: 'EXCLUIR',
        confirmLabel: 'Excluir Definitivo',
        busy: false,
    },
);

const emit = defineEmits<{
    (e: 'close'): void;
    (e: 'confirm'): void;
}>();

const input = ref('');
watch(
    () => props.show,
    (open) => {
        if (open) input.value = '';
    },
);

const canConfirm = computed(() => input.value.trim() === props.confirmWord);
</script>

<template>
    <Modal :show="show" maxWidth="lg" @close="emit('close')">
        <div class="p-6">
            <div class="flex items-start justify-between gap-4">
                <div>
                    <div class="text-[20px] font-bold text-slate-900">{{ title }}</div>
                </div>
                <button
                    type="button"
                    class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-50 text-slate-600 ring-1 ring-slate-200/60"
                    aria-label="Fechar"
                    @click="emit('close')"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M6 6l12 12" />
                        <path d="M18 6 6 18" />
                    </svg>
                </button>
            </div>

            <div class="mt-6 text-center">
                <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-amber-50 text-amber-600 ring-1 ring-amber-100">
                    <svg class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M12 9v4" />
                        <path d="M12 17h.01" />
                        <path d="M10.3 3.3h3.4L22 20.6H2L10.3 3.3z" />
                    </svg>
                </div>
            </div>

            <div class="mt-5 text-sm font-semibold text-slate-700">
                Você está prestes a {{ actionLabel }}:
            </div>
            <div class="mt-2 rounded-2xl bg-slate-50 p-4 ring-1 ring-slate-200/60">
                <div class="text-sm font-bold text-slate-900">{{ itemTitle }}</div>
                <div v-if="itemSubtitle" class="mt-1 text-xs font-semibold text-slate-500">{{ itemSubtitle }}</div>
            </div>

            <div v-if="consequences.length" class="mt-4">
                <div class="text-sm font-semibold text-slate-700">Esta ação não pode ser desfeita. Isso vai remover:</div>
                <ul class="mt-2 list-disc space-y-1 pl-5 text-sm font-semibold text-slate-600">
                    <li v-for="c in consequences" :key="c">{{ c }}</li>
                </ul>
            </div>

            <div class="mt-5">
                <label class="text-sm font-semibold text-slate-700">Digite "{{ confirmWord }}" para confirmar:</label>
                <input
                    v-model="input"
                    type="text"
                    class="mt-2 w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-800 placeholder:text-slate-400 outline-none focus:ring-2 focus:ring-[#14B8A6]"
                    :placeholder="`Digite ${confirmWord}`"
                    autocomplete="off"
                />
            </div>

            <div class="mt-6 flex items-center justify-end gap-2">
                <button type="button" class="rounded-xl border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-700 hover:bg-slate-50" @click="emit('close')">
                    Cancelar
                </button>
                <button
                    type="button"
                    class="rounded-xl bg-red-600 px-4 py-2 text-sm font-semibold text-white shadow-lg shadow-red-500/20 disabled:opacity-60"
                    :disabled="!canConfirm || busy"
                    @click="emit('confirm')"
                >
                    {{ busy ? 'Excluindo…' : confirmLabel }}
                </button>
            </div>
        </div>
    </Modal>
</template>
