<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, Link, router, usePage } from '@inertiajs/vue3';
import { requestJson } from '@/lib/kitamoApi';
import type { BootstrapData, Goal } from '@/types/kitamo';
import MobileShell from '@/Layouts/MobileShell.vue';
import KitamoLayout from '@/Layouts/KitamoLayout.vue';
import { useMediaQuery } from '@/composables/useMediaQuery';
import { formatMoneyInput, moneyInputToNumber } from '@/lib/moneyInput';

const isMobile = useMediaQuery('(max-width: 767px)');

const page = usePage();
const bootstrap = computed(
    () => (page.props.bootstrap ?? { entries: [], goals: [], accounts: [], categories: [] }) as BootstrapData,
);

const props = defineProps<{
    goalId: string;
}>();

const initial = computed(() => {
    const g = bootstrap.value.goals.find((goal) => goal.id === props.goalId) as Goal | undefined;
    if (!g) return { name: 'Meta', icon: 'home' as const, target: '0,00', due: 'Dezembro 2026' };
    const icon: IconKey = g.icon === 'plane' ? 'plane' : g.icon === 'car' ? 'car' : 'home';
    const target = new Intl.NumberFormat('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(g.target);
    return { name: g.title, icon, target, due: g.due };
});

type IconKey = 'home' | 'car' | 'plane' | 'cap' | 'bag' | 'laptop';

const name = ref(initial.value.name);
const icon = ref<IconKey>(initial.value.icon);
const target = ref(initial.value.target);
const due = ref(initial.value.due);

const onTargetInput = (event: Event) => {
    const targetEl = event.target as HTMLInputElement;
    target.value = formatMoneyInput(targetEl.value);
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
    const newTarget = moneyInputToNumber(target.value);
    await requestJson(route('goals.update', props.goalId), {
        method: 'PATCH',
        body: JSON.stringify({
            title: name.value.trim() || 'Meta',
            target_amount: newTarget,
            due_date: parseDueDate(due.value),
            icon: icon.value === 'plane' ? 'plane' : icon.value === 'car' ? 'car' : 'home',
        }),
    });
    router.visit(route('goals.show', { goalId: props.goalId }));
};
</script>

<template>
    <Head title="Editar meta" />

    <MobileShell v-if="isMobile" :show-nav="false">
        <header class="relative flex items-center justify-center pt-2">
            <Link
                :href="route('goals.show', { goalId })"
                class="absolute left-0 flex h-10 w-10 items-center justify-center rounded-2xl bg-white text-slate-600 shadow-sm ring-1 ring-slate-200/60"
                aria-label="Voltar"
            >
                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M15 18l-6-6 6-6" />
                </svg>
            </Link>
            <div class="text-xl font-semibold tracking-tight text-slate-900">Editar meta</div>
        </header>

        <div class="mt-8 space-y-5 pb-[calc(6rem+env(safe-area-inset-bottom))]">
            <div>
                <div class="mb-2 text-sm font-semibold text-slate-700">Nome da meta</div>
                <input
                    v-model="name"
                    type="text"
                    placeholder="Ex: Casa própria..."
                    class="h-12 w-full rounded-2xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-700 placeholder:text-slate-300 focus:border-[#14B8A6] focus:outline-none focus:ring-0"
                />
            </div>

            <div>
                <div class="mb-2 text-sm font-semibold text-slate-700">Ícone</div>
                <div class="flex flex-wrap gap-3">
                    <button
                        v-for="k in (['home','car','plane','cap','bag','laptop'] as IconKey[])"
                        :key="k"
                        type="button"
                        class="flex h-12 w-12 items-center justify-center rounded-full bg-slate-50 ring-1 ring-slate-200"
                        :class="icon === k ? 'ring-2 ring-[#14B8A6] bg-emerald-50 text-[#14B8A6]' : 'text-slate-500'"
                        @click="icon = k"
                        :aria-label="k"
                    >
                        <svg v-if="k === 'home'" class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M3 10.5L12 3l9 7.5" />
                            <path d="M5 10v10h14V10" />
                        </svg>
                        <svg v-else-if="k === 'car'" class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M5 16l1-5 1-3h10l1 3 1 5" />
                            <path d="M7 16h10" />
                            <circle cx="8" cy="17" r="1.5" />
                            <circle cx="16" cy="17" r="1.5" />
                        </svg>
                        <svg v-else-if="k === 'plane'" class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M2 16l20-8-20-8 6 8-6 8Z" />
                            <path d="M6 16v6l4-4" />
                        </svg>
                        <svg v-else-if="k === 'cap'" class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M22 10 12 5 2 10l10 5 10-5Z" />
                            <path d="M6 12v5c0 1.7 2.7 3 6 3s6-1.3 6-3v-5" />
                        </svg>
                        <svg v-else-if="k === 'bag'" class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M6 8h12l-1 13H7L6 8Z" />
                            <path d="M9 8V6a3 3 0 0 1 6 0v2" />
                        </svg>
                        <svg v-else class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <rect x="3" y="4" width="18" height="12" rx="2" />
                            <path d="M8 20h8" />
                            <path d="M12 16v4" />
                        </svg>
                    </button>
                </div>
            </div>

            <div>
                <div class="mb-2 text-sm font-semibold text-slate-700">Valor objetivo</div>
                <input
                    type="text"
                    inputmode="decimal"
                    :value="target"
                    @input="onTargetInput"
                    placeholder="0,00"
                    @focus="() => { if (target === '0,00') target = '' }"
                    @blur="() => { if (!target.trim()) target = '0,00' }"
                    class="h-12 w-full rounded-2xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-700 focus:border-[#14B8A6] focus:outline-none focus:ring-0"
                />
            </div>

            <div>
                <div class="mb-2 text-sm font-semibold text-slate-700">Prazo</div>
                <input
                    v-model="due"
                    type="text"
                    class="h-12 w-full rounded-2xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-700 focus:border-[#14B8A6] focus:outline-none focus:ring-0"
                />
            </div>

            <div class="rounded-2xl border border-blue-100 bg-blue-50 px-4 py-4 text-sm font-semibold text-blue-700">
                <div class="flex items-start gap-3">
                    <span class="flex h-8 w-8 items-center justify-center rounded-full bg-blue-100 text-blue-600">
                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <circle cx="12" cy="12" r="9" />
                            <path d="M12 10v6" />
                            <path d="M12 8h.01" />
                        </svg>
                    </span>
                    <div>R$ 500/mês para atingir a meta no prazo.</div>
                </div>
            </div>
        </div>

        <div class="fixed inset-x-0 bottom-0 bg-white px-5 pb-[calc(1rem+env(safe-area-inset-bottom))] pt-3 shadow-[0_-18px_40px_-32px_rgba(15,23,42,0.45)]">
            <div class="mx-auto w-full max-w-md">
                <button
                    type="button"
                    class="h-[52px] w-full rounded-2xl bg-[#14B8A6] text-base font-bold text-white shadow-[0_2px_8px_rgba(20,184,166,0.25)]"
                    @click="submit"
                >
                    Salvar alterações
                </button>
            </div>
        </div>
    </MobileShell>

    <KitamoLayout v-else title="Editar meta" subtitle="Mobile-first por enquanto.">
        <div class="rounded-[28px] border border-white/70 bg-white p-8 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)]">
            <div class="text-sm font-semibold text-slate-900">Editar meta (desktop/tablet)</div>
            <div class="mt-2 text-sm text-slate-500">Vamos adaptar essa tela depois da versão mobile.</div>
        </div>
    </KitamoLayout>
</template>
