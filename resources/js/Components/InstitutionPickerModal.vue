<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import InstitutionAvatar from '@/Components/InstitutionAvatar.vue';
import { bankInstitutions } from '@/lib/bankLogos';

export type InstitutionPick = {
    nome: string;
    svgFile: string | null;
    color: string;
};

const props = withDefaults(
    defineProps<{
        open: boolean;
        title?: string;
        selected?: string | null;
    }>(),
    {
        title: 'Escolher instituição',
        selected: null,
    },
);

const emit = defineEmits<{
    (event: 'close'): void;
    (event: 'select', value: InstitutionPick): void;
}>();

const search = ref('');

watch(
    () => props.open,
    (isOpen) => {
        if (isOpen) search.value = '';
    },
);

const filtered = computed(() => {
    const term = search.value.trim().toLowerCase();
    if (!term) return bankInstitutions;
    return bankInstitutions.filter((b) => b.nome.toLowerCase().includes(term));
});

const handleSelect = (banco: (typeof bankInstitutions)[number]) => {
    emit('select', { nome: banco.nome, svgFile: banco.svgFile, color: banco.color });
};
</script>

<template>
    <div v-if="open" class="fixed inset-0 z-[120]">
        <button
            class="absolute inset-0 bg-black/50 backdrop-blur-sm"
            type="button"
            @click="emit('close')"
            aria-label="Fechar"
        ></button>

        <div class="absolute inset-0 w-full bg-white" role="dialog" aria-modal="true">
            <div class="flex h-full flex-col">
                <header class="flex items-center justify-between px-4 pt-[calc(0.5rem+env(safe-area-inset-top))] pb-4">
                    <button class="h-6 w-6 text-[#6B7280]" type="button" @click="emit('close')" aria-label="Voltar">
                        <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M15 18l-6-6 6-6" />
                        </svg>
                    </button>
                    <div class="text-[14px] font-bold text-[#1F2937]">{{ title }}</div>
                    <div class="w-6"></div>
                </header>

                <div class="flex-1 overflow-y-auto px-4 pb-[calc(1.5rem+env(safe-area-inset-bottom))]">
                    <div class="mb-4">
                        <input
                            v-model="search"
                            type="text"
                            placeholder="Buscar banco..."
                            class="w-full appearance-none rounded-xl border border-[#E5E7EB] bg-[#F9FAFB] px-4 py-3 text-sm text-[#374151] placeholder:text-[#9CA3AF] focus:border-[#14B8A6] focus:outline-none focus:ring-0 focus-visible:outline-none"
                        />
                    </div>

                    <div class="grid grid-cols-2 gap-3">
                        <button
                            v-for="banco in filtered"
                            :key="banco.nome"
                            type="button"
                            class="h-28 w-full overflow-hidden rounded-2xl border border-slate-200 bg-white p-3 text-left shadow-sm ring-1 ring-slate-200/60 transition hover:bg-slate-50"
                            @click="handleSelect(banco)"
                        >
                            <div class="flex h-full flex-col">
                                <div class="flex items-start justify-between">
                                    <InstitutionAvatar
                                        :institution="banco.nome"
                                        :svg-path="banco.svgFile"
                                        :fallback-icon="'account'"
                                        :container-class="'flex h-10 w-10 items-center justify-center overflow-hidden rounded-2xl bg-white'"
                                        :img-class="'h-8 w-8 object-contain'"
                                        :fallback-bg-class="'rounded-2xl'"
                                        :fallback-icon-class="'h-5 w-5 text-slate-500'"
                                    />
                                    <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                                        <path d="M9 5l7 7-7 7" />
                                    </svg>
                                </div>

                                <div class="mt-3 flex-1">
                                    <div class="line-clamp-2 text-sm font-semibold leading-snug text-slate-900">
                                        {{ banco.nome }}
                                    </div>
                                </div>

                                <div class="mt-2 h-1 w-full rounded-full bg-slate-100">
                                    <div class="h-1 rounded-full" :style="{ width: '40%', backgroundColor: banco.color }"></div>
                                </div>
                            </div>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>
