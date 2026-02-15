<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { Dialog, DialogPanel, TransitionChild, TransitionRoot } from '@headlessui/vue';

const props = defineProps<{
    open: boolean;
}>();

const emit = defineEmits<{
    (e: 'close'): void;
}>();

type Plan = {
    id: number;
    name: string;
    description: string | null;
    price_cents: number;
    interval: string;
    accounts_limit: number | null;
    cards_limit: number | null;
    projection_days: number;
    backup_enabled: boolean;
    recurring_enabled: boolean;
    priority_support: boolean;
    is_popular: boolean;
    is_active: boolean;
};

const allPlans = ref<Plan[]>([]);
const loading = ref(true);
const billing = ref<'monthly' | 'annual'>('monthly');

const fetchPlans = async () => {
    loading.value = true;
    try {
        const response = await window.axios.get('/api/plans-list');
        allPlans.value = response.data;
    } catch (error) {
        console.error('Failed to load plans', error);
    } finally {
        loading.value = false;
    }
};

onMounted(() => {
    fetchPlans();
});

const filteredPlans = computed(() => {
    // Filter plans based on selected interval
    let plans = allPlans.value.filter(p => p.interval === billing.value);
    
    // If no annual plans exist, maybe show monthly ones or empty state? 
    // For now, let's just show what matches.
    return plans;
});

const formatMoney = (cents: number) => {
    return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(cents / 100);
};

// Helper to generate features list from plan properties
const getFeatures = (plan: Plan) => {
    const features = [];
    
    if (plan.accounts_limit === null) features.push('Contas bancárias ilimitadas');
    else features.push(`Até ${plan.accounts_limit} conta(s) bancária(s)`);

    if (plan.cards_limit === null) features.push('Cartões de crédito ilimitados');
    else features.push(`Até ${plan.cards_limit} cartão(ões) de crédito`);

    features.push(`Projeção de saldo de ${plan.projection_days} dias`);

    if (plan.recurring_enabled) features.push('Lançamentos recorrentes');
    if (plan.backup_enabled) features.push('Backup automático diário');
    if (plan.priority_support) features.push('Suporte prioritário');

    return features;
};
</script>

<template>
    <TransitionRoot as="template" :show="open">
        <Dialog as="div" class="relative z-50" @close="emit('close')">
            <TransitionChild
                as="template"
                enter="ease-out duration-300"
                enter-from="opacity-0"
                enter-to="opacity-100"
                leave="ease-in duration-200"
                leave-from="opacity-100"
                leave-to="opacity-0"
            >
                <div class="fixed inset-0 bg-slate-900/80 backdrop-blur transition-opacity" />
            </TransitionChild>

            <div class="fixed inset-0 z-10 overflow-y-auto">
                <div class="flex min-h-full items-center justify-center p-4 text-center sm:p-0">
                    <TransitionChild
                        as="template"
                        enter="ease-out duration-300"
                        enter-from="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
                        enter-to="opacity-100 translate-y-0 sm:scale-100"
                        leave="ease-in duration-200"
                        leave-from="opacity-100 translate-y-0 sm:scale-100"
                        leave-to="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
                    >
                        <DialogPanel class="relative w-full max-w-6xl transform overflow-hidden rounded-[2.5rem] bg-white text-left shadow-2xl transition-all">
                            
                            <!-- Close Button -->
                            <div class="absolute right-6 top-6 z-20">
                                <button 
                                    @click="emit('close')" 
                                    type="button" 
                                    class="rounded-full bg-slate-100 p-2 text-slate-400 hover:bg-slate-200 hover:text-slate-600 transition"
                                >
                                    <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M6 18L18 6M6 6l12 12" />
                                    </svg>
                                </button>
                            </div>

                            <div class="px-8 py-12 sm:px-16 sm:py-16">
                                <!-- Header -->
                                <div class="mx-auto max-w-2xl text-center mb-12">
                                    <h2 class="text-3xl font-bold tracking-tight text-slate-900 sm:text-4xl">
                                        Escolha o melhor plano para você
                                    </h2>
                                    <p class="mt-4 text-sm font-medium text-slate-500 leading-relaxed">
                                        Assine hoje e garanta acesso completo às ferramentas de gestão financeira mais avançadas do mercado no Kitamo.
                                    </p>

                                    <!-- Toggle -->
                                    <div class="mt-8 flex items-center justify-center gap-4">
                                        <span class="text-sm font-bold" :class="billing === 'monthly' ? 'text-slate-900' : 'text-slate-500'">Mensal</span>
                                        <button 
                                            @click="billing = billing === 'monthly' ? 'annual' : 'monthly'"
                                            class="relative inline-flex h-8 w-14 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none"
                                            :class="billing === 'annual' ? 'bg-teal-500' : 'bg-slate-200'"
                                        >
                                            <span 
                                                aria-hidden="true" 
                                                class="pointer-events-none inline-block h-7 w-7 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out"
                                                :class="billing === 'annual' ? 'translate-x-6' : 'translate-x-0'"
                                            />
                                        </button>
                                        <span class="flex items-center gap-2">
                                            <span class="text-sm font-bold" :class="billing === 'annual' ? 'text-slate-900' : 'text-slate-500'">Anual</span>
                                            <span class="rounded-full bg-emerald-100 px-2 py-0.5 text-[10px] font-bold uppercase tracking-wide text-emerald-700">Economia</span>
                                        </span>
                                    </div>
                                </div>

                                <!-- Loading State -->
                                <div v-if="loading" class="flex justify-center py-20">
                                    <div class="h-10 w-10 animate-spin rounded-full border-4 border-slate-200 border-t-teal-500"></div>
                                </div>

                                <!-- Plans Grid -->
                                <div v-else class="isolate mx-auto grid max-w-md grid-cols-1 gap-8 lg:mx-0 lg:max-w-none lg:grid-cols-3">
                                    <div 
                                        v-for="plan in filteredPlans" 
                                        :key="plan.id"
                                        class="relative flex flex-col justify-between rounded-[2rem] p-8 ring-1 transition-all duration-300 hover:-translate-y-2 hover:shadow-xl xl:p-10"
                                        :class="plan.is_popular ? 'bg-white shadow-xl ring-teal-500 z-10 scale-105' : 'bg-white ring-slate-200 hover:ring-slate-300'"
                                    >
                                        <!-- Recommended Badge -->
                                        <div v-if="plan.is_popular" class="absolute -top-4 left-0 right-0 mx-auto w-fit rounded-full bg-gradient-to-r from-emerald-500 to-teal-600 px-4 py-1.5 text-xs font-bold uppercase tracking-wide text-white shadow-lg shadow-teal-500/30">
                                            Recomendado
                                        </div>

                                        <div>
                                            <div class="flex items-center justify-between gap-x-4">
                                                <h3 class="text-lg font-bold leading-8 text-slate-900">{{ plan.name }}</h3>
                                            </div>
                                            <p class="mt-1 text-xs leading-6 text-slate-500 min-h-[1.5rem]">{{ plan.description }}</p>
                                            
                                            <div class="mt-6 flex items-baseline gap-x-1">
                                                <span class="text-4xl font-bold tracking-tight text-slate-900">{{ formatMoney(plan.price_cents) }}</span>
                                                <span class="text-sm font-semibold leading-6 text-slate-500">/{{ plan.interval === 'monthly' ? 'mês' : (plan.interval === 'annual' ? 'ano' : 'un') }}</span>
                                            </div>

                                            <ul role="list" class="mt-8 space-y-3 text-sm leading-6 text-slate-600">
                                                <li v-for="feature in getFeatures(plan)" :key="feature" class="flex gap-x-3">
                                                    <svg class="h-6 w-5 flex-none text-teal-500" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                                                        <path fill-rule="evenodd" d="M16.704 4.153a.75.75 0 01.143 1.052l-8 10.5a.75.75 0 01-1.127.075l-4.5-4.5a.75.75 0 011.06-1.06l3.894 3.893 7.48-9.817a.75.75 0 011.05-.143z" clip-rule="evenodd" />
                                                    </svg>
                                                    {{ feature }}
                                                </li>
                                            </ul>
                                        </div>
                                        
                                        <div class="mt-8">
                                            <button 
                                                v-if="plan.is_popular"
                                                type="button"
                                                class="w-full rounded-2xl bg-gradient-to-r from-emerald-500 to-teal-600 px-3 py-3.5 text-center text-sm font-bold text-white shadow-lg shadow-teal-500/25 transition-all hover:to-teal-500 hover:shadow-teal-500/40"
                                            >
                                                Assinar {{ plan.name }}
                                            </button>
                                            <button
                                                v-else
                                                type="button"
                                                class="w-full rounded-2xl bg-white px-3 py-3.5 text-center text-sm font-bold text-teal-600 ring-1 ring-inset ring-teal-500 transition-all hover:bg-teal-50"
                                            >
                                                Assinar {{ plan.name }}
                                            </button>
                                        </div>
                                    </div>
                                    
                                    <!-- Empty State if no plans found -->
                                    <div v-if="!loading && filteredPlans.length === 0" class="col-span-full py-12 text-center text-slate-500">
                                        Nenhum plano disponível para o ciclo selecionado.
                                    </div>
                                </div>
                                
                                <div class="mt-12 text-center">
                                    <button class="inline-flex items-center gap-2 text-sm font-semibold text-teal-600 hover:text-teal-700">
                                        <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 9l-7 7-7-7" /></svg>
                                        Ver tabela comparativa completa
                                    </button>
                                </div>
                            </div>
                        </DialogPanel>
                    </TransitionChild>
                </div>
            </div>
        </Dialog>
    </TransitionRoot>
</template>
