<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, router, useForm } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import { useIsMobile } from '@/composables/useIsMobile';
import AdminLayout from '@/Components/AdminLayout.vue';
import Modal from '@/Components/Modal.vue';

type Scope = 'user' | 'admin';
type Channel = 'in_app' | 'email' | 'sms' | 'whatsapp';

type RuleRow = {
    id: number;
    scope: Scope | string;
    title: string;
    description: string | null;
    icon: string | null;
    enabled: boolean;
    trigger_key: string;
    trigger_config: Record<string, any>;
    channels: Channel[];
    message_title: string;
    message_body: string;
};

const props = defineProps<{
    rules: RuleRow[];
}>();

const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() => (isMobile.value ? { showNav: false } : { title: 'Administração', showSearch: false, showNewAction: false }));

const modalOpen = ref(false);
const editingId = ref<number | null>(null);

const triggers = [
    { key: 'billing_due', label: 'Vencimento de fatura' },
    { key: 'weekly_report', label: 'Relatório semanal' },
    { key: 'monthly_report', label: 'Relatório mensal' },
    { key: 'low_balance', label: 'Saldo baixo' },
    { key: 'big_transaction', label: 'Transação grande' },
    { key: 'system_news', label: 'Novidade no sistema' },
    { key: 'custom', label: 'Custom' },
];

const form = useForm<{
    scope: Scope;
    title: string;
    description: string;
    icon: string;
    enabled: boolean;
    trigger_key: string;
    trigger_config: Record<string, any>;
    channels: Channel[];
    message_title: string;
    message_body: string;
}>({
    scope: 'user',
    title: '',
    description: '',
    icon: '🔔',
    enabled: true,
    trigger_key: 'billing_due',
    trigger_config: { days_before: 3, time: '09:00' },
    channels: ['in_app', 'email'],
    message_title: '',
    message_body: '',
});

const openCreate = (scope: Scope) => {
    editingId.value = null;
    form.reset();
    form.clearErrors();
    form.scope = scope;
    form.icon = scope === 'admin' ? '🚨' : '🔔';
    form.enabled = true;
    form.trigger_key = 'billing_due';
    form.trigger_config = { days_before: 3, time: '09:00' };
    form.channels = ['in_app', 'email'];
    form.message_title = '';
    form.message_body = '';
    modalOpen.value = true;
};

const openEdit = (r: RuleRow) => {
    editingId.value = r.id;
    form.reset();
    form.clearErrors();
    form.scope = (r.scope === 'admin' ? 'admin' : 'user') as Scope;
    form.title = r.title;
    form.description = r.description ?? '';
    form.icon = r.icon ?? '🔔';
    form.enabled = Boolean(r.enabled);
    form.trigger_key = r.trigger_key || 'custom';
    form.trigger_config = r.trigger_config ?? {};
    form.channels = (r.channels ?? []) as Channel[];
    form.message_title = r.message_title ?? '';
    form.message_body = r.message_body ?? '';
    modalOpen.value = true;
};

const save = () => {
    form.transform((data) => ({
        scope: data.scope,
        title: data.title,
        description: data.description || null,
        icon: data.icon || null,
        enabled: Boolean(data.enabled),
        trigger_key: data.trigger_key,
        trigger_config: data.trigger_config ?? {},
        channels: data.channels ?? [],
        message_title: data.message_title,
        message_body: data.message_body || null,
    }));

    if (editingId.value) {
        form.patch(route('admin.notifications.update', editingId.value), {
            preserveScroll: true,
            onSuccess: () => {
                modalOpen.value = false;
                router.reload({ only: ['rules'] });
            },
        });
        return;
    }

    form.post(route('admin.notifications.store'), {
        preserveScroll: true,
        onSuccess: () => {
            modalOpen.value = false;
            router.reload({ only: ['rules'] });
        },
    });
};

const destroyRule = (id: number) => {
    router.delete(route('admin.notifications.destroy', id), {
        preserveScroll: true,
        onSuccess: () => router.reload({ only: ['rules'] }),
    });
};

const sendTest = (id: number) => {
    router.post(route('admin.notifications.test', id), {}, { preserveScroll: true });
};

const updateTriggerDefaults = () => {
    if (form.trigger_key === 'billing_due') form.trigger_config = { days_before: 3, time: '09:00' };
    else if (form.trigger_key === 'weekly_report') form.trigger_config = { day_of_week: 'mon', time: '09:00' };
    else if (form.trigger_key === 'monthly_report') form.trigger_config = { day_of_month: 1, time: '09:00' };
    else if (form.trigger_key === 'low_balance') form.trigger_config = { threshold: 100, time: '09:00' };
    else if (form.trigger_key === 'big_transaction') form.trigger_config = { threshold: 300, time: '09:00' };
    else form.trigger_config = {};
};

const userRules = computed(() => props.rules.filter((r) => (r.scope === 'admin' ? 'admin' : 'user') === 'user'));
const adminRules = computed(() => props.rules.filter((r) => (r.scope === 'admin' ? 'admin' : 'user') === 'admin'));

const channelsLabel = (channels: any[]) => {
    const set = new Set((channels ?? []) as string[]);
    const out = [];
    if (set.has('in_app')) out.push('📱 In-app');
    if (set.has('email')) out.push('📧 E-mail');
    if (set.has('sms')) out.push('📩 SMS');
    if (set.has('whatsapp')) out.push('💬 WhatsApp');
    return out.length ? out.join(' + ') : '—';
};

const previewText = computed(() => {
    const sample = {
        nome: 'Gabriel',
        valor: 'R$ 450,00',
        data_vencimento: '15/02',
        saldo: 'R$ 1.234,56',
    };
    const body = (form.message_body || '')
        .replaceAll('{nome}', sample.nome)
        .replaceAll('{valor}', sample.valor)
        .replaceAll('{data_vencimento}', sample.data_vencimento)
        .replaceAll('{saldo}', sample.saldo);
    return body;
});
</script>

<template>
    <Head title="Administração · Notificações" />

    <component :is="Shell" v-bind="shellProps">
        <AdminLayout title="Notificações" description="Configure lembretes automáticos e alertas do sistema.">
            <div class="flex flex-wrap items-center justify-between gap-3">
                <button
                    type="button"
                    class="inline-flex items-center justify-center rounded-2xl bg-[#14B8A6] px-4 py-3 text-sm font-semibold text-white shadow-lg shadow-emerald-500/20"
                    @click="openCreate('user')"
                >
                    + Criar nova notificação
                </button>
                <div class="text-xs font-semibold text-slate-400">As notificações de teste chegam como aviso in-app no admin.</div>
            </div>

            <div class="mt-6 space-y-6">
                <section class="rounded-2xl bg-slate-50 p-6 ring-1 ring-slate-200/60">
                    <div class="flex items-center justify-between">
                        <div class="text-sm font-semibold text-slate-900">Notificações para usuários</div>
                        <div class="text-xs font-semibold text-slate-400">{{ userRules.length }}</div>
                    </div>
                    <div v-if="userRules.length === 0" class="mt-4 rounded-2xl border border-dashed border-slate-200 bg-white px-4 py-8 text-center">
                        <div class="text-sm font-semibold text-slate-900">Nenhuma notificação ainda</div>
                        <div class="mt-2 text-xs font-semibold text-slate-500">Crie uma regra para começar.</div>
                    </div>
                    <div v-else class="mt-4 space-y-3">
                        <div v-for="r in userRules" :key="r.id" class="rounded-2xl bg-white p-4 ring-1 ring-slate-200/60">
                            <div class="flex flex-wrap items-start justify-between gap-4">
                                <div class="min-w-0">
                                    <div class="flex items-center gap-2">
                                        <span class="text-lg">{{ r.icon || '🔔' }}</span>
                                        <div class="truncate text-base font-semibold text-slate-900">{{ r.title }}</div>
                                        <span
                                            class="rounded-full px-3 py-1 text-xs font-semibold"
                                            :class="r.enabled ? 'bg-emerald-50 text-emerald-700' : 'bg-slate-100 text-slate-600'"
                                        >
                                            {{ r.enabled ? 'Ativa' : 'Pausada' }}
                                        </span>
                                    </div>
                                    <div v-if="r.description" class="mt-1 text-sm text-slate-600">{{ r.description }}</div>
                                    <div class="mt-2 text-xs font-semibold text-slate-500">Canal: {{ channelsLabel(r.channels) }}</div>
                                </div>

                                <div class="flex flex-wrap items-center gap-2">
                                    <button type="button" class="rounded-xl bg-slate-50 px-3 py-2 text-xs font-semibold text-slate-700 ring-1 ring-slate-200/60 hover:bg-slate-100" @click="openEdit(r)">
                                        Editar
                                    </button>
                                    <button type="button" class="rounded-xl bg-white px-3 py-2 text-xs font-semibold text-slate-700 ring-1 ring-slate-200/60 hover:bg-slate-50" @click="sendTest(r.id)">
                                        Testar
                                    </button>
                                    <button type="button" class="rounded-xl bg-red-50 px-3 py-2 text-xs font-semibold text-red-700 ring-1 ring-red-100 hover:bg-red-100" @click="destroyRule(r.id)">
                                        Excluir
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>

                <section class="rounded-2xl bg-slate-50 p-6 ring-1 ring-slate-200/60">
                    <div class="flex items-center justify-between">
                        <div class="text-sm font-semibold text-slate-900">Notificações para admin</div>
                        <div class="text-xs font-semibold text-slate-400">{{ adminRules.length }}</div>
                    </div>
                    <div v-if="adminRules.length === 0" class="mt-4 rounded-2xl border border-dashed border-slate-200 bg-white px-4 py-8 text-center">
                        <div class="text-sm font-semibold text-slate-900">Nenhuma notificação ainda</div>
                        <div class="mt-2 text-xs font-semibold text-slate-500">Crie regras internas (ex.: erro crítico, novo usuário, etc).</div>
                    </div>
                    <div v-else class="mt-4 space-y-3">
                        <div v-for="r in adminRules" :key="r.id" class="rounded-2xl bg-white p-4 ring-1 ring-slate-200/60">
                            <div class="flex flex-wrap items-start justify-between gap-4">
                                <div class="min-w-0">
                                    <div class="flex items-center gap-2">
                                        <span class="text-lg">{{ r.icon || '🚨' }}</span>
                                        <div class="truncate text-base font-semibold text-slate-900">{{ r.title }}</div>
                                        <span
                                            class="rounded-full px-3 py-1 text-xs font-semibold"
                                            :class="r.enabled ? 'bg-emerald-50 text-emerald-700' : 'bg-slate-100 text-slate-600'"
                                        >
                                            {{ r.enabled ? 'Ativa' : 'Pausada' }}
                                        </span>
                                    </div>
                                    <div v-if="r.description" class="mt-1 text-sm text-slate-600">{{ r.description }}</div>
                                    <div class="mt-2 text-xs font-semibold text-slate-500">Canal: {{ channelsLabel(r.channels) }}</div>
                                </div>

                                <div class="flex flex-wrap items-center gap-2">
                                    <button type="button" class="rounded-xl bg-slate-50 px-3 py-2 text-xs font-semibold text-slate-700 ring-1 ring-slate-200/60 hover:bg-slate-100" @click="openEdit(r)">
                                        Editar
                                    </button>
                                    <button type="button" class="rounded-xl bg-white px-3 py-2 text-xs font-semibold text-slate-700 ring-1 ring-slate-200/60 hover:bg-slate-50" @click="sendTest(r.id)">
                                        Testar
                                    </button>
                                    <button type="button" class="rounded-xl bg-red-50 px-3 py-2 text-xs font-semibold text-red-700 ring-1 ring-red-100 hover:bg-red-100" @click="destroyRule(r.id)">
                                        Excluir
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
            </div>

            <Modal :show="modalOpen" maxWidth="2xl" @close="modalOpen = false">
                <div class="p-6">
                    <div class="flex items-start justify-between gap-4">
                        <div>
                            <div class="text-lg font-semibold text-slate-900">{{ editingId ? 'Editar notificação' : 'Nova notificação' }}</div>
                            <div class="mt-1 text-sm text-slate-500">Defina trigger, canais e mensagem.</div>
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
                        <label class="block">
                            <div class="text-xs font-semibold text-slate-500">Tipo</div>
                            <select v-model="form.scope" class="mt-2 h-11 w-full appearance-none rounded-xl border border-slate-200 bg-white px-4 pr-10 text-sm font-semibold text-slate-800">
                                <option value="user">Para usuários</option>
                                <option value="admin">Para admin</option>
                            </select>
                        </label>
                        <label class="block">
                            <div class="text-xs font-semibold text-slate-500">Ícone (emoji)</div>
                            <input v-model="form.icon" type="text" maxlength="4" class="mt-2 h-11 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800" />
                        </label>

                        <label class="block md:col-span-2">
                            <div class="text-xs font-semibold text-slate-500">Nome/Título *</div>
                            <input v-model="form.title" type="text" class="mt-2 h-11 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800" placeholder="Ex.: Lembrete de Vencimento" />
                        </label>

                        <label class="block md:col-span-2">
                            <div class="text-xs font-semibold text-slate-500">Descrição (opcional)</div>
                            <input v-model="form.description" type="text" class="mt-2 h-11 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800" />
                        </label>

                        <label class="block md:col-span-2">
                            <div class="text-xs font-semibold text-slate-500">Trigger</div>
                            <select
                                v-model="form.trigger_key"
                                class="mt-2 h-11 w-full appearance-none rounded-xl border border-slate-200 bg-white px-4 pr-10 text-sm font-semibold text-slate-800"
                                @change="updateTriggerDefaults"
                            >
                                <option v-for="t in triggers" :key="t.key" :value="t.key">{{ t.label }}</option>
                            </select>
                        </label>

                        <div class="md:col-span-2 rounded-2xl bg-slate-50 p-4 ring-1 ring-slate-200/60">
                            <div class="text-xs font-bold uppercase tracking-wide text-slate-400">Quando enviar</div>
                            <div class="mt-3 grid gap-3 md:grid-cols-2">
                                <label v-if="form.trigger_key === 'billing_due'" class="block">
                                    <div class="text-xs font-semibold text-slate-500">Antecedência (dias)</div>
                                    <input v-model="form.trigger_config.days_before" type="number" min="0" class="mt-2 h-10 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800" />
                                </label>
                                <label v-if="form.trigger_key === 'low_balance' || form.trigger_key === 'big_transaction'" class="block">
                                    <div class="text-xs font-semibold text-slate-500">Limite (R$)</div>
                                    <input v-model="form.trigger_config.threshold" type="number" min="0" class="mt-2 h-10 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800" />
                                </label>
                                <label v-if="form.trigger_key === 'weekly_report'" class="block">
                                    <div class="text-xs font-semibold text-slate-500">Dia da semana</div>
                                    <select v-model="form.trigger_config.day_of_week" class="mt-2 h-10 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800">
                                        <option value="mon">Segunda</option>
                                        <option value="tue">Terça</option>
                                        <option value="wed">Quarta</option>
                                        <option value="thu">Quinta</option>
                                        <option value="fri">Sexta</option>
                                        <option value="sat">Sábado</option>
                                        <option value="sun">Domingo</option>
                                    </select>
                                </label>
                                <label v-if="form.trigger_key === 'monthly_report'" class="block">
                                    <div class="text-xs font-semibold text-slate-500">Dia do mês</div>
                                    <input v-model="form.trigger_config.day_of_month" type="number" min="1" max="31" class="mt-2 h-10 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800" />
                                </label>
                                <label class="block">
                                    <div class="text-xs font-semibold text-slate-500">Horário</div>
                                    <input v-model="form.trigger_config.time" type="time" class="mt-2 h-10 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800" />
                                </label>
                            </div>
                        </div>

                        <div class="md:col-span-2 rounded-2xl bg-slate-50 p-4 ring-1 ring-slate-200/60">
                            <div class="text-xs font-bold uppercase tracking-wide text-slate-400">Canais</div>
                            <div class="mt-3 grid gap-2 md:grid-cols-2">
                                <label class="flex items-center justify-between rounded-xl bg-white px-4 py-3 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60">
                                    Push (in-app)
                                    <input v-model="form.channels" type="checkbox" value="in_app" class="h-4 w-4 text-[#14B8A6]" />
                                </label>
                                <label class="flex items-center justify-between rounded-xl bg-white px-4 py-3 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60">
                                    E-mail
                                    <input v-model="form.channels" type="checkbox" value="email" class="h-4 w-4 text-[#14B8A6]" />
                                </label>
                                <label class="flex items-center justify-between rounded-xl bg-white px-4 py-3 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60">
                                    SMS
                                    <input v-model="form.channels" type="checkbox" value="sms" class="h-4 w-4 text-[#14B8A6]" />
                                </label>
                                <label class="flex items-center justify-between rounded-xl bg-white px-4 py-3 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60">
                                    WhatsApp
                                    <input v-model="form.channels" type="checkbox" value="whatsapp" class="h-4 w-4 text-[#14B8A6]" />
                                </label>
                            </div>
                        </div>

                        <label class="block md:col-span-2">
                            <div class="text-xs font-semibold text-slate-500">Título da notificação *</div>
                            <input v-model="form.message_title" type="text" class="mt-2 h-11 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800" placeholder="Ex.: Sua fatura vence em 3 dias!" />
                        </label>
                        <label class="block md:col-span-2">
                            <div class="text-xs font-semibold text-slate-500">Corpo da mensagem</div>
                            <textarea v-model="form.message_body" rows="4" class="mt-2 w-full resize-none rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-800 placeholder:text-slate-400" placeholder="Ex.: Oi {nome}, sua fatura de {valor} vence em {data_vencimento}." />
                            <div class="mt-2 text-xs font-semibold text-slate-400">Variáveis: {nome}, {valor}, {data_vencimento}, {saldo}</div>
                        </label>

                        <div class="md:col-span-2 rounded-2xl bg-slate-50 p-4 ring-1 ring-slate-200/60">
                            <div class="text-xs font-bold uppercase tracking-wide text-slate-400">Preview</div>
                            <div class="mt-3 rounded-2xl bg-white p-4 ring-1 ring-slate-200/60">
                                <div class="text-sm font-semibold text-slate-900">{{ form.icon || '🔔' }} {{ form.message_title || form.title || '—' }}</div>
                                <div class="mt-2 text-sm text-slate-700 whitespace-pre-line">{{ previewText || '—' }}</div>
                            </div>
                        </div>

                        <label class="flex items-center justify-between rounded-2xl bg-slate-50 p-4 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60 md:col-span-2">
                            Ativa
                            <input v-model="form.enabled" type="checkbox" class="h-4 w-4 text-[#14B8A6]" />
                        </label>
                    </div>

                    <div v-if="form.hasErrors" class="mt-4 rounded-2xl bg-red-50 p-4 text-sm font-semibold text-red-700">
                        Não foi possível salvar. Verifique os campos.
                    </div>

                    <div class="mt-6 flex flex-wrap items-center justify-between gap-2">
                        <button
                            v-if="editingId"
                            type="button"
                            class="rounded-xl bg-white px-4 py-2 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60"
                            @click="sendTest(editingId)"
                        >
                            Enviar teste
                        </button>
                        <div class="flex items-center justify-end gap-2 ml-auto">
                            <button type="button" class="rounded-xl px-4 py-2 text-sm font-semibold text-slate-600" @click="modalOpen = false">Cancelar</button>
                            <button
                                type="button"
                                class="rounded-xl bg-[#14B8A6] px-4 py-2 text-sm font-semibold text-white shadow-lg shadow-emerald-500/20 disabled:opacity-60"
                                :disabled="form.processing"
                                @click="save"
                            >
                                {{ form.processing ? 'Salvando…' : 'Salvar notificação' }}
                            </button>
                        </div>
                    </div>
                </div>
            </Modal>
        </AdminLayout>
    </component>
</template>
