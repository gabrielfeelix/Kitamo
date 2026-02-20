<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, router, useForm } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import { useIsMobile } from '@/composables/useIsMobile';
import AdminLayout from '@/Components/AdminLayout.vue';
import EmptyState from '@/Components/EmptyState.vue';
import DestructiveConfirmModal from '@/Components/DestructiveConfirmModal.vue';

type InquiryRow = {
    id: number;
    name: string;
    email: string;
    objective: string;
    message: string;
    source: string | null;
    handled_at: string | null;
    created_at: string | null;
};

const props = defineProps<{
    inquiries: InquiryRow[];
}>();

const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() => (isMobile.value ? { showNav: false } : { title: 'Administração', showSearch: false, showNewAction: false }));
const inquiriesMeta = computed(() => `${props.inquiries.length} contatos`);

const formatDate = (iso: string | null) => {
    if (!iso) return '';
    const d = new Date(iso);
    return Number.isFinite(d.getTime())
        ? d.toLocaleString('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' })
        : String(iso);
};

const selectedInquiry = ref<InquiryRow | null>(null);

const toggleForm = useForm<{ handled: boolean }>({
    handled: true,
});

const toggleHandled = (inquiry: InquiryRow, handled: boolean) => {
    toggleForm.handled = handled;
    toggleForm.patch(route('admin.inquiries.update', inquiry.id), {
        preserveScroll: true,
        onSuccess: () => {
            router.reload({ only: ['inquiries'] });
        },
    });
};

const deleteTarget = ref<InquiryRow | null>(null);
const deleteForm = useForm({});

const confirmDelete = () => {
    if (!deleteTarget.value) return;
    deleteForm.delete(route('admin.inquiries.destroy', deleteTarget.value.id), {
        preserveScroll: true,
        onSuccess: () => {
            deleteTarget.value = null;
            router.reload({ only: ['inquiries'] });
        },
    });
};
</script>

<template>
    <Head title="Administração · Contatos Institucionais" />

    <component :is="Shell" v-bind="shellProps">
        <AdminLayout
            title="Contatos Institucionais"
            description="Mensagens recebidas pelo formulário público do website institucional."
            :meta="inquiriesMeta"
        >
            <div class="rounded-2xl bg-slate-50 p-6 ring-1 ring-slate-200/60">
                <EmptyState
                    v-if="props.inquiries.length === 0"
                    icon="📨"
                    title="Nenhum contato ainda"
                    description="As mensagens enviadas em /contato aparecerão aqui para tratamento da equipe."
                    cta-label="Aguardando contatos"
                    :cta-disabled="true"
                />

                <div v-else class="overflow-hidden rounded-2xl ring-1 ring-slate-200/60">
                    <table class="min-w-full text-left text-sm">
                        <thead class="bg-slate-50 text-xs font-bold uppercase tracking-wide text-slate-400">
                            <tr>
                                <th class="px-4 py-3">Nome</th>
                                <th class="px-4 py-3">E-mail</th>
                                <th class="px-4 py-3">Objetivo</th>
                                <th class="hidden px-4 py-3 lg:table-cell">Origem</th>
                                <th class="hidden px-4 py-3 lg:table-cell">Status</th>
                                <th class="px-4 py-3 text-right">Ações</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                            <tr v-for="inquiry in props.inquiries" :key="inquiry.id" class="bg-white">
                                <td class="px-4 py-3 font-semibold text-slate-900">{{ inquiry.name }}</td>
                                <td class="px-4 py-3 text-slate-700">{{ inquiry.email }}</td>
                                <td class="px-4 py-3 text-slate-700">{{ inquiry.objective }}</td>
                                <td class="hidden px-4 py-3 text-slate-500 lg:table-cell">{{ inquiry.source || '—' }}</td>
                                <td class="hidden px-4 py-3 lg:table-cell">
                                    <span
                                        class="inline-flex items-center rounded-full px-3 py-1 text-xs font-semibold"
                                        :class="inquiry.handled_at ? 'bg-emerald-50 text-emerald-700' : 'bg-amber-50 text-amber-700'"
                                    >
                                        {{ inquiry.handled_at ? 'Tratado' : 'Pendente' }}
                                    </span>
                                </td>
                                <td class="px-4 py-3">
                                    <div class="flex justify-end gap-2">
                                        <button
                                            type="button"
                                            class="rounded-xl bg-slate-50 px-3 py-2 text-xs font-semibold text-slate-700 ring-1 ring-slate-200/60 hover:bg-slate-100"
                                            @click="selectedInquiry = inquiry"
                                        >
                                            Ver
                                        </button>
                                        <button
                                            type="button"
                                            class="rounded-xl px-3 py-2 text-xs font-semibold ring-1"
                                            :class="inquiry.handled_at ? 'bg-amber-50 text-amber-700 ring-amber-100 hover:bg-amber-100' : 'bg-emerald-50 text-emerald-700 ring-emerald-100 hover:bg-emerald-100'"
                                            @click="toggleHandled(inquiry, !inquiry.handled_at)"
                                        >
                                            {{ inquiry.handled_at ? 'Reabrir' : 'Marcar tratado' }}
                                        </button>
                                        <button
                                            type="button"
                                            class="rounded-xl bg-red-50 px-3 py-2 text-xs font-semibold text-red-700 ring-1 ring-red-100 hover:bg-red-100"
                                            @click="deleteTarget = inquiry"
                                        >
                                            Excluir
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <div v-if="selectedInquiry" class="mt-5 rounded-2xl border border-slate-200 bg-white p-6">
                <div class="flex items-start justify-between gap-4">
                    <div>
                        <h2 class="text-lg font-semibold text-slate-900">{{ selectedInquiry.name }}</h2>
                        <p class="text-sm text-slate-500">{{ selectedInquiry.email }} · {{ selectedInquiry.objective }}</p>
                    </div>
                    <button
                        type="button"
                        class="rounded-xl bg-slate-50 px-3 py-2 text-xs font-semibold text-slate-600 ring-1 ring-slate-200/60 hover:bg-slate-100"
                        @click="selectedInquiry = null"
                    >
                        Fechar
                    </button>
                </div>
                <div class="mt-4 rounded-xl bg-slate-50 p-4 text-sm leading-relaxed text-slate-700">
                    {{ selectedInquiry.message }}
                </div>
                <div class="mt-3 text-xs text-slate-500">
                    Recebido em {{ formatDate(selectedInquiry.created_at) }}
                    <span v-if="selectedInquiry.handled_at">· Tratado em {{ formatDate(selectedInquiry.handled_at) }}</span>
                </div>
            </div>

            <DestructiveConfirmModal
                :show="Boolean(deleteTarget)"
                title="Excluir contato?"
                :item-title="deleteTarget?.name || 'Contato'"
                :item-subtitle="deleteTarget?.email ?? ''"
                confirm-word="EXCLUIR"
                :busy="deleteForm.processing"
                @close="deleteTarget = null"
                @confirm="confirmDelete"
            />
        </AdminLayout>
    </component>
</template>
