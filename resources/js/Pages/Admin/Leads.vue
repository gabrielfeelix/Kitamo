<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, router, useForm } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import { useIsMobile } from '@/composables/useIsMobile';
import Modal from '@/Components/Modal.vue';
import AdminLayout from '@/Components/AdminLayout.vue';

type LeadRow = {
    id: number;
    name: string | null;
    email: string;
    status: 'subscribed' | 'unsubscribed';
    subscribed_at: string | null;
    created_at: string | null;
    source: string | null;
};

const props = defineProps<{
    leads: LeadRow[];
}>();

const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() => (isMobile.value ? { showNav: false } : { title: 'Administração', showSearch: false, showNewAction: false }));

const formatDate = (iso: string | null) => {
    if (!iso) return '';
    const d = new Date(iso);
    return Number.isFinite(d.getTime())
        ? d.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric' })
        : String(iso);
};

const modalOpen = ref(false);
const editingId = ref<number | null>(null);

const form = useForm<{ name: string; email: string; status: 'subscribed' | 'unsubscribed' }>({
    name: '',
    email: '',
    status: 'subscribed',
});

const openCreate = () => {
    editingId.value = null;
    form.reset();
    form.clearErrors();
    modalOpen.value = true;
};

const openEdit = (lead: LeadRow) => {
    editingId.value = lead.id;
    form.reset();
    form.clearErrors();
    form.name = lead.name ?? '';
    form.email = lead.email;
    form.status = lead.status;
    modalOpen.value = true;
};

const save = () => {
    if (editingId.value) {
        form.patch(route('admin.leads.update', editingId.value), {
            preserveScroll: true,
            onSuccess: () => {
                modalOpen.value = false;
                router.reload({ only: ['leads'] });
            },
        });
        return;
    }
    form.post(route('admin.leads.store'), {
        preserveScroll: true,
        onSuccess: () => {
            modalOpen.value = false;
            router.reload({ only: ['leads'] });
        },
    });
};

const deletingId = ref<number | null>(null);
const deleteForm = useForm({});
const confirmDelete = (id: number) => {
    deleteForm.delete(route('admin.leads.destroy', id), {
        preserveScroll: true,
        onSuccess: () => {
            deletingId.value = null;
            router.reload({ only: ['leads'] });
        },
    });
};
</script>

<template>
    <Head title="Administração · Leads" />

    <component :is="Shell" v-bind="shellProps">
        <AdminLayout title="Leads" description="Leads capturados pela newsletter (landing page).">
            <div class="rounded-2xl bg-slate-50 p-6 ring-1 ring-slate-200/60">
                <div class="flex flex-wrap items-center justify-between gap-3">
                    <div>
                        <div class="text-sm font-semibold text-slate-900">Leads</div>
                        <div class="mt-1 text-xs font-semibold text-slate-400">{{ props.leads.length }} no total</div>
                    </div>
                    <button
                        type="button"
                        class="inline-flex items-center justify-center rounded-2xl bg-[#14B8A6] px-4 py-3 text-sm font-semibold text-white shadow-lg shadow-emerald-500/20"
                        @click="openCreate"
                    >
                        + Adicionar lead
                    </button>
                </div>

                <div v-if="props.leads.length === 0" class="mt-6 rounded-2xl border border-dashed border-slate-200 bg-slate-50 px-4 py-10 text-center">
                    <div class="text-sm font-semibold text-slate-900">Nenhum lead ainda</div>
                    <div class="mt-2 text-xs font-semibold text-slate-500">Quando alguém se inscrever na newsletter, aparece aqui.</div>
                </div>

                <div v-else class="mt-6 overflow-hidden rounded-2xl ring-1 ring-slate-200/60">
                    <table class="min-w-full text-left text-sm">
                        <thead class="bg-slate-50 text-xs font-bold uppercase tracking-wide text-slate-400">
                            <tr>
                                <th class="px-4 py-3">Nome</th>
                                <th class="px-4 py-3">E-mail</th>
                                <th class="px-4 py-3">Status</th>
                                <th class="hidden px-4 py-3 md:table-cell">Origem</th>
                                <th class="hidden px-4 py-3 md:table-cell">Data</th>
                                <th class="px-4 py-3 text-right">Ações</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                            <tr v-for="lead in props.leads" :key="lead.id" class="bg-white">
                                <td class="px-4 py-3 font-semibold text-slate-900">{{ lead.name || '—' }}</td>
                                <td class="px-4 py-3 text-slate-700">{{ lead.email }}</td>
                                <td class="px-4 py-3">
                                    <span
                                        class="inline-flex items-center rounded-full px-3 py-1 text-xs font-semibold"
                                        :class="lead.status === 'subscribed' ? 'bg-emerald-50 text-emerald-700' : 'bg-slate-100 text-slate-600'"
                                    >
                                        {{ lead.status === 'subscribed' ? 'Inscrito' : 'Descadastrado' }}
                                    </span>
                                </td>
                                <td class="hidden px-4 py-3 text-slate-500 md:table-cell">{{ lead.source || '—' }}</td>
                                <td class="hidden px-4 py-3 text-slate-500 md:table-cell">{{ formatDate(lead.subscribed_at || lead.created_at) }}</td>
                                <td class="px-4 py-3 text-right">
                                    <div class="flex justify-end gap-2">
                                        <button
                                            type="button"
                                            class="rounded-xl bg-slate-50 px-3 py-2 text-xs font-semibold text-slate-700 ring-1 ring-slate-200/60 hover:bg-slate-100"
                                            @click="openEdit(lead)"
                                        >
                                            Editar
                                        </button>
                                        <button
                                            type="button"
                                            class="rounded-xl bg-red-50 px-3 py-2 text-xs font-semibold text-red-700 ring-1 ring-red-100 hover:bg-red-100"
                                            @click="deletingId = deletingId === lead.id ? null : lead.id"
                                        >
                                            Excluir
                                        </button>
                                    </div>
                                    <div v-if="deletingId === lead.id" class="mt-2 rounded-xl bg-red-50 p-3 text-left ring-1 ring-red-100">
                                        <div class="text-xs font-semibold text-red-700">Tem certeza?</div>
                                        <div class="mt-2 flex justify-end gap-2">
                                            <button type="button" class="px-3 py-2 text-xs font-semibold text-slate-600" @click="deletingId = null">Cancelar</button>
                                            <button
                                                type="button"
                                                class="rounded-xl bg-red-600 px-3 py-2 text-xs font-semibold text-white disabled:opacity-60"
                                                :disabled="deleteForm.processing"
                                                @click="confirmDelete(lead.id)"
                                            >
                                                Excluir agora
                                            </button>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </AdminLayout>
    </component>

    <Modal :show="modalOpen" maxWidth="lg" @close="modalOpen = false">
        <div class="p-6">
            <div class="flex items-start justify-between gap-4">
                <div>
                    <div class="text-lg font-semibold text-slate-900">{{ editingId ? 'Editar lead' : 'Novo lead' }}</div>
                    <div class="mt-1 text-sm text-slate-500">Cadastro usado para newsletters (inscritos da landing page).</div>
                </div>
                <button
                    type="button"
                    class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-50 text-slate-600 ring-1 ring-slate-200/60"
                    aria-label="Fechar"
                    @click="modalOpen = false"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M6 6l12 12" />
                        <path d="M18 6l-12 12" />
                    </svg>
                </button>
            </div>

            <div class="mt-5 grid gap-4 md:grid-cols-2">
                <label class="block">
                    <div class="text-xs font-semibold text-slate-500">Nome (opcional)</div>
                    <input
                        v-model="form.name"
                        type="text"
                        class="mt-2 h-11 w-full appearance-none rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800 placeholder:text-slate-400"
                        placeholder="Ex.: Maria"
                    />
                </label>
                <label class="block">
                    <div class="text-xs font-semibold text-slate-500">E-mail</div>
                    <input
                        v-model="form.email"
                        type="email"
                        class="mt-2 h-11 w-full appearance-none rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800 placeholder:text-slate-400"
                        placeholder="nome@exemplo.com"
                    />
                </label>
                <label class="block md:col-span-2">
                    <div class="text-xs font-semibold text-slate-500">Status</div>
                    <select v-model="form.status" class="mt-2 h-11 w-full appearance-none rounded-xl border border-slate-200 bg-white px-4 pr-10 text-sm font-semibold text-slate-800">
                        <option value="subscribed">Inscrito</option>
                        <option value="unsubscribed">Descadastrado</option>
                    </select>
                </label>
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
                    {{ form.processing ? 'Salvando…' : 'Salvar' }}
                </button>
            </div>
        </div>
    </Modal>
</template>
