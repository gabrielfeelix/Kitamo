<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, router, useForm } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import { useIsMobile } from '@/composables/useIsMobile';
import AdminLayout from '@/Components/AdminLayout.vue';
import Modal from '@/Components/Modal.vue';
import StatusBadge from '@/Components/StatusBadge.vue';
import DestructiveConfirmModal from '@/Components/DestructiveConfirmModal.vue';
import Tooltip from '@/Components/Tooltip.vue';
import { formatMoneyInputCentsShift, moneyInputToNumber, numberToMoneyInput } from '@/lib/moneyInput';
import { preventNonDigitKeydown } from '@/lib/inputGuards';

type PlanRow = {
    id: number;
    name: string;
    slug: string;
    description: string | null;
    price_cents: number;
    currency: string;
    interval: 'monthly' | 'annual' | 'lifetime' | string;
    accounts_limit: number | null;
    cards_limit: number | null;
    projection_days: number;
    backup_enabled: boolean;
    recurring_enabled: boolean;
    priority_support: boolean;
    trial_days: number;
    requires_card: boolean;
    is_popular: boolean;
    is_active: boolean;
};

const props = defineProps<{
    plans: PlanRow[];
}>();

const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() => (isMobile.value ? { showNav: false } : { title: 'Administração', showSearch: false, showNewAction: false }));

const priceLabel = (cents: number) => `R$ ${numberToMoneyInput((Number(cents ?? 0) || 0) / 100)}`;
const intervalLabel = (interval: string) => {
    if (interval === 'annual') return '/ano';
    if (interval === 'lifetime') return 'vitalício';
    return '/mês';
};

const activeCount = computed(() => props.plans.filter((p) => p.is_active).length);
const plansMeta = computed(() => `${activeCount.value} planos ativos`);

const modalOpen = ref(false);
const editingId = ref<number | null>(null);

const form = useForm<{
    name: string;
    description: string;
    price_display: string;
    interval: 'monthly' | 'annual' | 'lifetime';
    accounts_unlimited: boolean;
    accounts_limit: string;
    cards_unlimited: boolean;
    cards_limit: string;
    projection_days: string;
    backup_enabled: boolean;
    recurring_enabled: boolean;
    priority_support: boolean;
    trial_days: string;
    requires_card: boolean;
    is_popular: boolean;
    is_active: boolean;
    sort_order: string;
}>({
    name: '',
    description: '',
    price_display: '',
    interval: 'monthly',
    accounts_unlimited: false,
    accounts_limit: '1',
    cards_unlimited: false,
    cards_limit: '1',
    projection_days: '30',
    backup_enabled: false,
    recurring_enabled: false,
    priority_support: false,
    trial_days: '0',
    requires_card: false,
    is_popular: false,
    is_active: true,
    sort_order: '0',
});

const setPriceDisplay = (raw: string) => {
    if (!String(raw ?? '').trim()) {
        form.price_display = '';
        return;
    }
    form.price_display = formatMoneyInputCentsShift(raw);
};

const openCreate = () => {
    editingId.value = null;
    form.reset();
    form.clearErrors();
    form.is_active = true;
    modalOpen.value = true;
};

const openEdit = (p: PlanRow) => {
    editingId.value = p.id;
    form.reset();
    form.clearErrors();

    form.name = p.name;
    form.description = p.description ?? '';
    form.price_display = numberToMoneyInput((p.price_cents ?? 0) / 100);
    form.interval = (p.interval === 'annual' ? 'annual' : p.interval === 'lifetime' ? 'lifetime' : 'monthly') as any;

    form.accounts_unlimited = p.accounts_limit == null;
    form.accounts_limit = String(p.accounts_limit ?? 3);
    form.cards_unlimited = p.cards_limit == null;
    form.cards_limit = String(p.cards_limit ?? 5);

    form.projection_days = String(p.projection_days ?? 30);
    form.backup_enabled = Boolean(p.backup_enabled);
    form.recurring_enabled = Boolean(p.recurring_enabled);
    form.priority_support = Boolean(p.priority_support);
    form.trial_days = String(p.trial_days ?? 0);
    form.requires_card = Boolean(p.requires_card);
    form.is_popular = Boolean(p.is_popular);
    form.is_active = Boolean(p.is_active);
    form.sort_order = '0';

    modalOpen.value = true;
};

const save = () => {
    const priceNumber = Math.max(0, moneyInputToNumber(form.price_display || '0,00'));
    const priceCents = Math.round(priceNumber * 100);

    form.transform((data) => ({
        name: data.name,
        description: data.description || null,
        price_cents: priceCents,
        currency: 'BRL',
        interval: data.interval,
        accounts_limit: data.accounts_unlimited ? null : Number(data.accounts_limit || 0) || null,
        cards_limit: data.cards_unlimited ? null : Number(data.cards_limit || 0) || null,
        projection_days: Number(data.projection_days || 0) || 0,
        backup_enabled: Boolean(data.backup_enabled),
        recurring_enabled: Boolean(data.recurring_enabled),
        priority_support: Boolean(data.priority_support),
        trial_days: Number(data.trial_days || 0) || 0,
        requires_card: Boolean(data.requires_card),
        is_popular: Boolean(data.is_popular),
        is_active: Boolean(data.is_active),
        sort_order: Number(data.sort_order || 0) || 0,
    }));

    if (editingId.value) {
        form.patch(route('admin.plans.update', editingId.value), {
            preserveScroll: true,
            onSuccess: () => {
                modalOpen.value = false;
                router.reload({ only: ['plans'] });
            },
        });
        return;
    }

    form.post(route('admin.plans.store'), {
        preserveScroll: true,
        onSuccess: () => {
            modalOpen.value = false;
            router.reload({ only: ['plans'] });
        },
    });
};

const toggleActive = (p: PlanRow) => {
    router.patch(
        route('admin.plans.update', p.id),
        {
            name: p.name,
            description: p.description,
            price_cents: p.price_cents,
            currency: p.currency,
            interval: p.interval,
            accounts_limit: p.accounts_limit,
            cards_limit: p.cards_limit,
            projection_days: p.projection_days,
            backup_enabled: p.backup_enabled,
            recurring_enabled: p.recurring_enabled,
            priority_support: p.priority_support,
            trial_days: p.trial_days,
            requires_card: p.requires_card,
            is_popular: p.is_popular,
            is_active: !p.is_active,
            sort_order: 0,
        },
        { preserveScroll: true, onSuccess: () => router.reload({ only: ['plans'] }) },
    );
};

const deactivateTarget = ref<PlanRow | null>(null);
const deactivateBusy = ref(false);

const requestToggleActive = (p: PlanRow) => {
    if (p.is_active) {
        deactivateTarget.value = p;
        return;
    }
    toggleActive(p);
};

const confirmDeactivate = () => {
    if (!deactivateTarget.value) return;
    const p = deactivateTarget.value;
    deactivateBusy.value = true;
    router.patch(
        route('admin.plans.update', p.id),
        {
            name: p.name,
            description: p.description,
            price_cents: p.price_cents,
            currency: p.currency,
            interval: p.interval,
            accounts_limit: p.accounts_limit,
            cards_limit: p.cards_limit,
            projection_days: p.projection_days,
            backup_enabled: p.backup_enabled,
            recurring_enabled: p.recurring_enabled,
            priority_support: p.priority_support,
            trial_days: p.trial_days,
            requires_card: p.requires_card,
            is_popular: p.is_popular,
            is_active: false,
            sort_order: 0,
        },
        {
            preserveScroll: true,
            onSuccess: () => {
                deactivateTarget.value = null;
                router.reload({ only: ['plans'] });
            },
            onFinish: () => {
                deactivateBusy.value = false;
            },
        },
    );
};
</script>

<template>
    <Head title="Administração · Planos" />

    <component :is="Shell" v-bind="shellProps">
        <AdminLayout title="Planos e Monetização" description="Configure recursos, preços e limites de cada plano." :meta="plansMeta">
            <div class="flex flex-wrap items-center justify-between gap-3">
                <button
                    type="button"
                    class="inline-flex items-center justify-center rounded-2xl bg-[#14B8A6] px-4 py-3 text-sm font-semibold text-white shadow-lg shadow-emerald-500/20"
                    @click="openCreate"
                >
                    + Criar novo plano
                </button>
                <div class="text-xs font-semibold text-slate-400">Dica: só 1 plano pode ficar marcado como “Popular”.</div>
            </div>

            <div class="mt-6 grid gap-4 md:grid-cols-2 xl:grid-cols-3">
                <div
                    v-for="p in props.plans"
                    :key="p.id"
                    class="relative rounded-2xl border border-slate-200 bg-white p-6 shadow-sm transition hover:shadow-md"
                >
                    <div v-if="p.is_popular" class="absolute right-4 top-4 rounded-full bg-gradient-to-r from-emerald-500 to-teal-600 px-3 py-1 text-xs font-bold text-white">
                        🏷️ Popular
                    </div>

                    <div class="text-lg font-bold text-slate-900">{{ p.name }}</div>
                    <div v-if="p.description" class="mt-1 text-sm font-medium text-slate-500">{{ p.description }}</div>

                    <div class="mt-5 flex items-end gap-2">
                        <div class="text-3xl font-bold text-[#14B8A6]">{{ priceLabel(p.price_cents) }}</div>
                        <div class="pb-1 text-sm font-semibold text-slate-400">{{ intervalLabel(p.interval) }}</div>
                    </div>

                    <div class="mt-5 space-y-2 text-sm font-semibold text-slate-600">
                        <div>✅ Contas: {{ p.accounts_limit == null ? 'Ilimitado' : p.accounts_limit }}</div>
                        <div>✅ Cartões: {{ p.cards_limit == null ? 'Ilimitado' : p.cards_limit }}</div>
                        <div>✅ Projeção: {{ p.projection_days }} dias</div>
                        <div class="flex items-center justify-between gap-3">
                            <span>{{ p.backup_enabled ? '✅' : '❌' }} Backup automático</span>
                            <Tooltip text="Salva cópia dos dados diariamente para recuperação em caso de perda." />
                        </div>
                        <div class="flex items-center justify-between gap-3">
                            <span>{{ p.recurring_enabled ? '✅' : '❌' }} Despesas recorrentes</span>
                            <Tooltip text="Permite criar lançamentos recorrentes automaticamente (mensais, etc.)." />
                        </div>
                        <div class="flex items-center justify-between gap-3">
                            <span>{{ p.priority_support ? '✅' : '⚠️' }} Suporte prioritário</span>
                            <Tooltip text="Atendimento com prioridade para solicitações e incidentes." />
                        </div>
                    </div>

                    <div class="mt-6 flex flex-wrap items-center gap-2">
                        <button
                            type="button"
                            class="rounded-xl border border-emerald-200 bg-white px-3 py-2 text-xs font-semibold text-emerald-700 hover:bg-emerald-50"
                            @click="openEdit(p)"
                        >
                            Editar
                        </button>
                        <button
                            type="button"
                            class="rounded-xl border border-red-200 bg-white px-3 py-2 text-xs font-semibold text-red-700 hover:bg-red-50"
                            @click="requestToggleActive(p)"
                        >
                            {{ p.is_active ? 'Desativar' : 'Ativar' }}
                        </button>
                        <StatusBadge :variant="p.is_active ? 'active' : 'inactive'" :label="p.is_active ? 'Ativo' : 'Inativo'" />
                    </div>
                </div>
            </div>

            <DestructiveConfirmModal
                :show="Boolean(deactivateTarget)"
                title="Desativar plano?"
                action-label="desativar"
                :item-title="deactivateTarget?.name ?? ''"
                :item-subtitle="deactivateTarget?.slug ?? ''"
                :consequences="[]"
                confirm-word="EXCLUIR"
                confirm-label="Desativar"
                :busy="deactivateBusy"
                @close="deactivateTarget = null"
                @confirm="confirmDeactivate"
            />

            <Modal :show="modalOpen" maxWidth="2xl" @close="modalOpen = false">
                <div class="p-6">
                    <div class="flex items-start justify-between gap-4">
                        <div>
                            <div class="text-lg font-semibold text-slate-900">{{ editingId ? 'Editar plano' : 'Novo plano' }}</div>
                            <div class="mt-1 text-sm text-slate-500">Defina limites, recursos e preço.</div>
                        </div>
                        <button
                            type="button"
                            class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-50 text-slate-600 ring-1 ring-slate-200/60"
                            aria-label="Fechar"
                            @click="modalOpen = false"
                        >
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M6 6l12 12" />
                                <path d="M18 6 6 18" />
                            </svg>
                        </button>
                    </div>

                    <div class="mt-6 grid gap-4 md:grid-cols-2">
                        <label class="block md:col-span-2">
                            <div class="text-xs font-semibold text-slate-500">Nome do plano *</div>
                            <input v-model="form.name" type="text" class="mt-2 h-11 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800" placeholder="Ex.: Premium" />
                        </label>

                        <label class="block">
                            <div class="text-xs font-semibold text-slate-500">Preço (R$) *</div>
                            <input
                                :value="form.price_display"
                                type="text"
                                inputmode="numeric"
                                placeholder="0,00"
                                class="mt-2 h-11 w-full rounded-xl border border-slate-200 bg-white px-4 text-right text-sm font-semibold text-slate-800"
                                @keydown="preventNonDigitKeydown"
                                @input="(e) => setPriceDisplay((e.target as HTMLInputElement).value)"
                            />
                        </label>

                        <label class="block">
                            <div class="text-xs font-semibold text-slate-500">Periodicidade *</div>
                            <select v-model="form.interval" class="mt-2 h-11 w-full appearance-none rounded-xl border border-slate-200 bg-white px-4 pr-10 text-sm font-semibold text-slate-800">
                                <option value="monthly">Mensal</option>
                                <option value="annual">Anual</option>
                                <option value="lifetime">Vitalício</option>
                            </select>
                        </label>

                        <label class="block md:col-span-2">
                            <div class="text-xs font-semibold text-slate-500">Descrição (opcional)</div>
                            <input v-model="form.description" type="text" class="mt-2 h-11 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800" maxlength="200" />
                        </label>

                        <div class="md:col-span-2">
                            <div class="mb-2 text-xs font-semibold uppercase tracking-wide text-slate-400">Recursos e limites</div>
                            <div class="grid gap-3 md:grid-cols-2">
                                <div class="rounded-2xl bg-slate-50 p-4 ring-1 ring-slate-200/60">
                                    <div class="flex items-center justify-between">
                                        <div class="text-sm font-semibold text-slate-900">Número de contas</div>
                                        <label class="inline-flex items-center gap-2 text-xs font-semibold text-slate-600">
                                            <input v-model="form.accounts_unlimited" type="checkbox" class="h-4 w-4 text-[#14B8A6]" />
                                            Ilimitado
                                        </label>
                                    </div>
                                    <input
                                        v-model="form.accounts_limit"
                                        type="number"
                                        min="1"
                                        class="mt-3 h-10 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800 disabled:bg-slate-100"
                                        :disabled="form.accounts_unlimited"
                                    />
                                </div>
                                <div class="rounded-2xl bg-slate-50 p-4 ring-1 ring-slate-200/60">
                                    <div class="flex items-center justify-between">
                                        <div class="text-sm font-semibold text-slate-900">Número de cartões</div>
                                        <label class="inline-flex items-center gap-2 text-xs font-semibold text-slate-600">
                                            <input v-model="form.cards_unlimited" type="checkbox" class="h-4 w-4 text-[#14B8A6]" />
                                            Ilimitado
                                        </label>
                                    </div>
                                    <input
                                        v-model="form.cards_limit"
                                        type="number"
                                        min="1"
                                        class="mt-3 h-10 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800 disabled:bg-slate-100"
                                        :disabled="form.cards_unlimited"
                                    />
                                </div>
                                <div class="rounded-2xl bg-slate-50 p-4 ring-1 ring-slate-200/60">
                                    <div class="text-sm font-semibold text-slate-900">Projeção futura (dias)</div>
                                    <input v-model="form.projection_days" type="number" min="0" class="mt-3 h-10 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800" />
                                </div>
                                <div class="rounded-2xl bg-slate-50 p-4 ring-1 ring-slate-200/60">
                                    <div class="text-sm font-semibold text-slate-900">Atalhos</div>
                                    <div class="mt-3 space-y-2 text-sm font-semibold text-slate-700">
                                        <label class="flex items-center justify-between">
                                            Backup automático
                                            <input v-model="form.backup_enabled" type="checkbox" class="h-4 w-4 text-[#14B8A6]" />
                                        </label>
                                        <label class="flex items-center justify-between">
                                            Despesas recorrentes
                                            <input v-model="form.recurring_enabled" type="checkbox" class="h-4 w-4 text-[#14B8A6]" />
                                        </label>
                                        <label class="flex items-center justify-between">
                                            Suporte prioritário
                                            <input v-model="form.priority_support" type="checkbox" class="h-4 w-4 text-[#14B8A6]" />
                                        </label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="md:col-span-2">
                            <div class="mb-2 text-xs font-semibold uppercase tracking-wide text-slate-400">Trial</div>
                            <div class="grid gap-3 md:grid-cols-2">
                                <label class="block rounded-2xl bg-slate-50 p-4 ring-1 ring-slate-200/60">
                                    <div class="text-sm font-semibold text-slate-900">Dias de trial</div>
                                    <input v-model="form.trial_days" type="number" min="0" class="mt-3 h-10 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800" />
                                </label>
                                <label class="block rounded-2xl bg-slate-50 p-4 ring-1 ring-slate-200/60">
                                    <div class="flex items-center justify-between">
                                        <div class="text-sm font-semibold text-slate-900">Requer cartão?</div>
                                        <input v-model="form.requires_card" type="checkbox" class="h-4 w-4 text-[#14B8A6]" />
                                    </div>
                                    <div class="mt-3 text-xs font-semibold text-slate-500">Opcional (para futuras integrações).</div>
                                </label>
                            </div>
                        </div>

                        <div class="md:col-span-2">
                            <div class="mb-2 text-xs font-semibold uppercase tracking-wide text-slate-400">Destaque</div>
                            <div class="flex flex-wrap items-center gap-4 rounded-2xl bg-slate-50 p-4 ring-1 ring-slate-200/60">
                                <label class="flex items-center gap-2 text-sm font-semibold text-slate-700">
                                    <input v-model="form.is_popular" type="checkbox" class="h-4 w-4 text-[#14B8A6]" />
                                    Marcar como “Popular”
                                </label>
                                <label class="flex items-center gap-2 text-sm font-semibold text-slate-700">
                                    <input v-model="form.is_active" type="checkbox" class="h-4 w-4 text-[#14B8A6]" />
                                    Plano ativo
                                </label>
                            </div>
                        </div>
                    </div>

                    <div v-if="form.hasErrors" class="mt-4 rounded-2xl bg-red-50 p-4 text-sm font-semibold text-red-700">
                        Não foi possível salvar. Verifique os campos.
                    </div>

                    <div class="mt-6 flex items-center justify-end gap-2">
                        <button type="button" class="rounded-xl px-4 py-2 text-sm font-semibold text-slate-600" @click="modalOpen = false">Cancelar</button>
                        <button
                            type="button"
                            class="rounded-xl bg-[#14B8A6] px-4 py-2 text-sm font-semibold text-white shadow-lg shadow-emerald-500/20 disabled:opacity-60"
                            :disabled="form.processing"
                            @click="save"
                        >
                            {{ form.processing ? 'Salvando…' : 'Salvar plano' }}
                        </button>
                    </div>
                </div>
            </Modal>
        </AdminLayout>
    </component>
</template>
