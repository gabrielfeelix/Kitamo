<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import { requestJson } from '@/lib/kitamoApi';
import type { Goal } from '@/types/kitamo';

const props = defineProps<{
    open: boolean;
}>();

const emit = defineEmits<{
    (event: 'close'): void;
    (event: 'created', payload: { goal: Goal }): void;
}>();

type IconKey = 'home' | 'plane' | 'car';

const close = () => emit('close');

const name = ref('');
const icon = ref<IconKey>('home');
const target = ref('0,00');
const due = ref('Dez 2026');

const normalizeMoneyInput = (raw: string) => {
    const digits = raw.replace(/[^\d]/g, '');
    const padded = digits.padStart(3, '0');
    const cents = padded.slice(-2);
    const whole = padded.slice(0, -2).replace(/^0+/, '') || '0';
    return `${whole},${cents}`;
};

const onTargetInput = (event: Event) => {
    const targetEl = event.target as HTMLInputElement;
    target.value = normalizeMoneyInput(targetEl.value);
};

const targetNumber = computed(() => Number(target.value.replace(/\./g, '').replace(',', '.')) || 0);

const mapIcon = (key: IconKey) => {
    if (key === 'plane') return 'plane';
    if (key === 'car') return 'car';
    return 'home';
};

const parseDueDate = (label: string) => {
    const value = label.trim().toLowerCase();
    if (!value) return null;
    const monthMap: Record<string, number> = {
        jan: 1, janeiro: 1,
        fev: 2, fevereiro: 2,
        mar: 3, março: 3, marco: 3,
        abr: 4, abril: 4,
        mai: 5, maio: 5,
        jun: 6, junho: 6,
        jul: 7, julho: 7,
        ago: 8, agosto: 8,
        set: 9, setembro: 9,
        out: 10, outubro: 10,
        nov: 11, novembro: 11,
        dez: 12, dezembro: 12,
    };
    const parts = value.split(/\s+/);
    const year = parts.find((part) => part.match(/^\d{4}$/));
    const monthKey = parts.find((part) => monthMap[part]);
    if (!year || !monthKey) return null;
    const month = monthMap[monthKey];
    return `${year}-${String(month).padStart(2, '0')}-01`;
};

const submit = async () => {
    const dueDate = parseDueDate(due.value);
    const nowYear = new Date().getFullYear();
    const targetYear = dueDate ? Number(dueDate.slice(0, 4)) : nowYear;
    const term = targetYear - nowYear <= 1 ? 'short' : 'long';

    const response = await requestJson<{ goal: Goal }>(route('goals.store'), {
        method: 'POST',
        body: JSON.stringify({
            title: name.value.trim() || 'Nova meta',
            target_amount: targetNumber.value,
            due_date: dueDate,
            icon: mapIcon(icon.value),
            term,
        }),
    });

    emit('created', { goal: response.goal });
    close();
};

watch(
    () => props.open,
    (isOpen) => {
        if (!isOpen) return;
        name.value = '';
        icon.value = 'home';
        target.value = '0,00';
        due.value = 'Dez 2026';
    },
);
</script>

<template>
    <div v-if="open" class="fixed inset-0 z-[96]">
        <button class="absolute inset-0 bg-black/40 backdrop-blur-sm" type="button" @click="close" aria-label="Fechar"></button>

        <div class="absolute left-1/2 top-1/2 w-[520px] -translate-x-1/2 -translate-y-1/2 overflow-hidden rounded-2xl bg-white shadow-[0_30px_90px_-50px_rgba(15,23,42,0.7)] ring-1 ring-slate-200/60">
            <header class="flex items-center justify-between border-b border-slate-100 px-7 py-5">
                <div class="text-base font-semibold text-slate-900">Nova meta</div>
                <button type="button" class="flex h-10 w-10 items-center justify-center rounded-xl bg-slate-50 text-slate-400 hover:bg-slate-100" @click="close" aria-label="Fechar">
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M18 6L6 18" />
                        <path d="M6 6l12 12" />
                    </svg>
                </button>
            </header>

            <div class="space-y-6 px-7 py-6">
                <div>
                    <div class="text-xs font-bold uppercase tracking-wide text-slate-400">Nome</div>
                    <input
                        v-model="name"
                        type="text"
                        class="mt-3 h-12 w-full rounded-xl bg-slate-50 px-4 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60 focus:outline-none focus:ring-2 focus:ring-[#14B8A6]"
                        placeholder="Ex: Casa própria"
                    />
                </div>

                <div>
                    <div class="text-xs font-bold uppercase tracking-wide text-slate-400">Ícone</div>
                    <div class="mt-3 flex items-center gap-3">
                        <button
                            v-for="k in (['home', 'plane', 'car'] as IconKey[])"
                            :key="k"
                            type="button"
                            class="flex h-11 w-11 items-center justify-center rounded-xl ring-1 ring-slate-200/60"
                            :class="icon === k ? 'bg-emerald-50 text-[#14B8A6] ring-2 ring-[#14B8A6]' : 'bg-slate-50 text-slate-500 hover:bg-slate-100'"
                            @click="icon = k"
                            :aria-label="k"
                        >
                            <svg v-if="k === 'home'" class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M3 10.5L12 3l9 7.5" />
                                <path d="M5 10v10h14V10" />
                            </svg>
                            <svg v-else-if="k === 'plane'" class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M2 16l20-8-20-8 6 8-6 8Z" />
                                <path d="M6 16v6l4-4" />
                            </svg>
                            <svg v-else class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M5 16l1-5 1-3h10l1 3 1 5" />
                                <path d="M7 16h10" />
                                <circle cx="8" cy="17" r="1.5" />
                                <circle cx="16" cy="17" r="1.5" />
                            </svg>
                        </button>
                    </div>
                </div>

                <div class="grid grid-cols-2 gap-5">
                    <div>
                        <div class="text-xs font-bold uppercase tracking-wide text-slate-400">Valor objetivo</div>
                        <div class="mt-3 flex items-center gap-3 rounded-xl bg-slate-50 px-4 py-3 ring-1 ring-slate-200/60">
                            <div class="text-sm font-semibold text-slate-400">R$</div>
                            <input
                                class="w-full bg-transparent text-lg font-bold tracking-tight text-slate-900 focus:outline-none"
                                inputmode="numeric"
                                :value="target"
                                @input="onTargetInput"
                                aria-label="Valor objetivo"
                            />
                        </div>
                    </div>
                    <div>
                        <div class="text-xs font-bold uppercase tracking-wide text-slate-400">Prazo</div>
                        <input
                            v-model="due"
                            type="text"
                            class="mt-3 h-12 w-full rounded-xl bg-slate-50 px-4 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60 focus:outline-none focus:ring-2 focus:ring-[#14B8A6]"
                            placeholder="Ex: Dez 2026"
                        />
                    </div>
                </div>
            </div>

            <footer class="border-t border-slate-100 px-7 py-5">
                <button type="button" class="h-12 w-full rounded-xl bg-[#14B8A6] text-sm font-semibold text-white shadow-lg shadow-emerald-500/20" @click="submit">
                    Criar meta
                </button>
            </footer>
        </div>
    </div>
</template>

