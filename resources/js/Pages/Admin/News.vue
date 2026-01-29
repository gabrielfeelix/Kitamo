<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, router, useForm } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import { useIsMobile } from '@/composables/useIsMobile';
import Modal from '@/Components/Modal.vue';
import AdminLayout from '@/Components/AdminLayout.vue';

type NewsStatus = 'draft' | 'scheduled' | 'published';
type NewsType = 'new' | 'improvement' | 'fix' | 'announcement';
type Visibility = 'public' | 'admin';

type NewsRow = {
    id: number;
    title: string;
    category: string | null;
    type: NewsType | string;
    visibility: Visibility | string;
    status: NewsStatus | string;
    scheduled_at: string | null;
    published_at: string | null;
    content: string | null;
    image_url: string | null;
    cta_text: string | null;
    cta_url: string | null;
    created_at: string | null;
};

const props = defineProps<{
    items: NewsRow[];
}>();

const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() => (isMobile.value ? { showNav: false } : { title: 'Administração', showSearch: false, showNewAction: false }));

const filterCategory = ref<string>('Todas');
const filterStatus = ref<string>('Todos');
const filterType = ref<string>('Todos');
const search = ref('');

const categories = computed(() => {
    const set = new Set<string>();
    for (const item of props.items) {
        if (item.category) set.add(item.category);
    }
    return ['Todas', ...Array.from(set.values()).sort((a, b) => a.localeCompare(b))];
});

const filtered = computed(() => {
    const q = search.value.trim().toLowerCase();
    return props.items.filter((item) => {
        if (filterCategory.value !== 'Todas' && (item.category || '') !== filterCategory.value) return false;
        if (filterStatus.value !== 'Todos' && item.status !== filterStatus.value) return false;
        if (filterType.value !== 'Todos' && item.type !== filterType.value) return false;
        if (!q) return true;
        return `${item.title} ${item.content || ''} ${item.category || ''}`.toLowerCase().includes(q);
    });
});

const formatDate = (iso: string | null) => {
    if (!iso) return '';
    const d = new Date(iso);
    if (!Number.isFinite(d.getTime())) return String(iso);
    return d.toLocaleString('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' });
};

const statusBadge = (status: string) => {
    if (status === 'published') return { label: 'Publicado', cls: 'bg-emerald-50 text-emerald-700' };
    if (status === 'scheduled') return { label: 'Agendado', cls: 'bg-amber-50 text-amber-700' };
    return { label: 'Rascunho', cls: 'bg-slate-100 text-slate-700' };
};

const typeBadge = (type: string) => {
    if (type === 'fix') return { label: 'Correção', cls: 'bg-red-50 text-red-700' };
    if (type === 'improvement') return { label: 'Melhoria', cls: 'bg-blue-50 text-blue-700' };
    if (type === 'announcement') return { label: 'Aviso', cls: 'bg-amber-50 text-amber-700' };
    return { label: 'Novo', cls: 'bg-emerald-50 text-emerald-700' };
};

const modalOpen = ref(false);
const editingId = ref<number | null>(null);

const form = useForm<{
    title: string;
    category: string;
    type: NewsType;
    visibility: Visibility;
    status: NewsStatus;
    scheduled_at: string;
    content: string;
    image_url: string;
    cta_text: string;
    cta_url: string;
}>({
    title: '',
    category: '',
    type: 'new',
    visibility: 'public',
    status: 'draft',
    scheduled_at: '',
    content: '',
    image_url: '',
    cta_text: '',
    cta_url: '',
});

const openCreate = () => {
    editingId.value = null;
    form.reset();
    form.clearErrors();
    modalOpen.value = true;
};

const openEdit = (item: NewsRow) => {
    editingId.value = item.id;
    form.reset();
    form.clearErrors();
    form.title = item.title;
    form.category = item.category ?? '';
    form.type = (item.type as any) || 'new';
    form.visibility = (item.visibility as any) || 'public';
    form.status = (item.status as any) || 'draft';
    form.scheduled_at = item.scheduled_at ? item.scheduled_at.slice(0, 16) : '';
    form.content = item.content ?? '';
    form.image_url = item.image_url ?? '';
    form.cta_text = item.cta_text ?? '';
    form.cta_url = item.cta_url ?? '';
    modalOpen.value = true;
};

const save = () => {
    form.transform((data) => ({
        title: data.title,
        category: data.category || null,
        type: data.type,
        visibility: data.visibility,
        status: data.status,
        scheduled_at: data.scheduled_at || null,
        content: data.content || null,
        image_url: data.image_url || null,
        cta_text: data.cta_text || null,
        cta_url: data.cta_url || null,
    }));

    if (editingId.value) {
        form.patch(route('admin.news.update', editingId.value), {
            preserveScroll: true,
            onSuccess: () => {
                modalOpen.value = false;
                router.reload({ only: ['items'] });
            },
        });
        return;
    }

    form.post(route('admin.news.store'), {
        preserveScroll: true,
        onSuccess: () => {
            modalOpen.value = false;
            router.reload({ only: ['items'] });
        },
    });
};

const deleteId = ref<number | null>(null);
const deleteForm = useForm({});
const confirmDelete = (id: number) => {
    deleteForm.delete(route('admin.news.destroy', id), {
        preserveScroll: true,
        onSuccess: () => {
            deleteId.value = null;
            router.reload({ only: ['items'] });
        },
    });
};
</script>

<template>
    <Head title="Administração · Novidades" />

    <component :is="Shell" v-bind="shellProps">
        <AdminLayout title="Changelog" description="Crie e publique novidades do sistema (modal de novidades para usuários).">
            <div class="rounded-2xl bg-slate-50 p-6 ring-1 ring-slate-200/60">
                <div class="flex flex-wrap items-center justify-between gap-3">
                    <div>
                        <div class="text-sm font-semibold text-slate-900">Changelog</div>
                        <div class="mt-1 text-xs font-semibold text-slate-400">{{ filtered.length }} item(ns)</div>
                    </div>
                    <div class="flex flex-wrap items-center gap-2">
                        <button
                            type="button"
                            class="inline-flex items-center justify-center rounded-2xl bg-[#14B8A6] px-4 py-3 text-sm font-semibold text-white shadow-lg shadow-emerald-500/20"
                            @click="openCreate"
                        >
                            + Adicionar novidade
                        </button>
                    </div>
                </div>

                <div class="mt-5 grid gap-3 md:grid-cols-[1fr_1fr_1fr_1.2fr]">
                    <label class="block">
                        <div class="text-xs font-semibold text-slate-500">Categoria</div>
                        <select v-model="filterCategory" class="mt-2 h-11 w-full appearance-none rounded-xl border border-slate-200 bg-white px-4 pr-10 text-sm font-semibold text-slate-800">
                            <option v-for="c in categories" :key="c" :value="c">{{ c }}</option>
                        </select>
                    </label>
                    <label class="block">
                        <div class="text-xs font-semibold text-slate-500">Status</div>
                        <select v-model="filterStatus" class="mt-2 h-11 w-full appearance-none rounded-xl border border-slate-200 bg-white px-4 pr-10 text-sm font-semibold text-slate-800">
                            <option value="Todos">Todos</option>
                            <option value="draft">Rascunho</option>
                            <option value="scheduled">Agendado</option>
                            <option value="published">Publicado</option>
                        </select>
                    </label>
                    <label class="block">
                        <div class="text-xs font-semibold text-slate-500">Tipo</div>
                        <select v-model="filterType" class="mt-2 h-11 w-full appearance-none rounded-xl border border-slate-200 bg-white px-4 pr-10 text-sm font-semibold text-slate-800">
                            <option value="Todos">Todos</option>
                            <option value="new">Novo</option>
                            <option value="improvement">Melhoria</option>
                            <option value="fix">Correção</option>
                            <option value="announcement">Aviso</option>
                        </select>
                    </label>
                    <label class="block">
                        <div class="text-xs font-semibold text-slate-500">Buscar</div>
                        <div class="mt-2 flex h-11 items-center gap-2 rounded-xl border border-slate-200 bg-white px-4">
                            <svg class="h-5 w-5 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <circle cx="11" cy="11" r="7" />
                                <path d="M21 21l-4.3-4.3" />
                            </svg>
                            <input
                                v-model="search"
                                type="text"
                                class="w-full appearance-none border-0 bg-transparent p-0 text-sm font-semibold text-slate-800 placeholder:text-slate-400 outline-none focus:outline-none focus:ring-0"
                                placeholder="Buscar por título/conteúdo"
                            />
                        </div>
                    </label>
                </div>

                <div v-if="filtered.length === 0" class="mt-6 rounded-2xl border border-dashed border-slate-200 bg-slate-50 px-4 py-10 text-center">
                    <div class="text-sm font-semibold text-slate-900">Nenhuma novidade encontrada</div>
                    <div class="mt-2 text-xs font-semibold text-slate-500">Ajuste os filtros ou crie uma novidade.</div>
                </div>

                <div v-else class="mt-6 space-y-3">
                    <div v-for="item in filtered" :key="item.id" class="rounded-2xl bg-slate-50 p-4 ring-1 ring-slate-200/60">
                        <div class="flex flex-wrap items-start justify-between gap-3">
                            <div class="min-w-0">
                                <div class="flex flex-wrap items-center gap-2">
                                    <div class="truncate text-base font-semibold text-slate-900">{{ item.title }}</div>
                                    <span class="inline-flex items-center rounded-full px-3 py-1 text-xs font-semibold" :class="typeBadge(item.type).cls">
                                        {{ typeBadge(item.type).label }}
                                    </span>
                                    <span class="inline-flex items-center rounded-full px-3 py-1 text-xs font-semibold" :class="statusBadge(item.status).cls">
                                        {{ statusBadge(item.status).label }}
                                    </span>
                                </div>
                                <div class="mt-1 text-xs font-semibold text-slate-500">
                                    <span v-if="item.category">{{ item.category }} • </span>
                                    <span v-if="item.published_at">Publicado em {{ formatDate(item.published_at) }}</span>
                                    <span v-else-if="item.scheduled_at">Agendado para {{ formatDate(item.scheduled_at) }}</span>
                                    <span v-else>Criado em {{ formatDate(item.created_at) }}</span>
                                </div>
                            </div>
                            <div class="flex flex-wrap items-center gap-2">
                                <button
                                    type="button"
                                    class="rounded-xl bg-white px-3 py-2 text-xs font-semibold text-slate-700 ring-1 ring-slate-200/60 hover:bg-slate-50"
                                    @click="openEdit(item)"
                                >
                                    Editar
                                </button>
                                <button
                                    type="button"
                                    class="rounded-xl bg-red-50 px-3 py-2 text-xs font-semibold text-red-700 ring-1 ring-red-100 hover:bg-red-100"
                                    @click="deleteId = deleteId === item.id ? null : item.id"
                                >
                                    Excluir
                                </button>
                            </div>
                        </div>

                        <div v-if="deleteId === item.id" class="mt-3 rounded-xl bg-red-50 p-3 ring-1 ring-red-100">
                            <div class="text-xs font-semibold text-red-700">Tem certeza que deseja excluir?</div>
                            <div class="mt-2 flex justify-end gap-2">
                                <button type="button" class="px-3 py-2 text-xs font-semibold text-slate-600" @click="deleteId = null">Cancelar</button>
                                <button
                                    type="button"
                                    class="rounded-xl bg-red-600 px-3 py-2 text-xs font-semibold text-white disabled:opacity-60"
                                    :disabled="deleteForm.processing"
                                    @click="confirmDelete(item.id)"
                                >
                                    Excluir agora
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </AdminLayout>
    </component>

    <Modal :show="modalOpen" maxWidth="2xl" @close="modalOpen = false">
        <div class="p-6">
            <div class="flex items-start justify-between gap-4">
                <div>
                    <div class="text-lg font-semibold text-slate-900">{{ editingId ? 'Editar novidade' : 'Nova novidade' }}</div>
                    <div class="mt-1 text-sm text-slate-500">Isso aparece no modal de novidades para os usuários.</div>
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
                <label class="block md:col-span-2">
                    <div class="text-xs font-semibold text-slate-500">Título *</div>
                    <input v-model="form.title" type="text" class="mt-2 h-11 w-full appearance-none rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800" placeholder="Ex.: Melhorias na Estante" />
                </label>
                <label class="block md:col-span-2">
                    <div class="text-xs font-semibold text-slate-500">Categoria (opcional)</div>
                    <input v-model="form.category" type="text" class="mt-2 h-11 w-full appearance-none rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800" placeholder="Ex.: Biblioteca, Perfil, Admin..." />
                </label>

                <label class="block">
                    <div class="text-xs font-semibold text-slate-500">Tipo</div>
                    <select v-model="form.type" class="mt-2 h-11 w-full appearance-none rounded-xl border border-slate-200 bg-white px-4 pr-10 text-sm font-semibold text-slate-800">
                        <option value="new">Novo</option>
                        <option value="improvement">Melhoria</option>
                        <option value="fix">Correção</option>
                        <option value="announcement">Aviso</option>
                    </select>
                </label>
                <label class="block">
                    <div class="text-xs font-semibold text-slate-500">Visibilidade</div>
                    <select v-model="form.visibility" class="mt-2 h-11 w-full appearance-none rounded-xl border border-slate-200 bg-white px-4 pr-10 text-sm font-semibold text-slate-800">
                        <option value="public">Público</option>
                        <option value="admin">Apenas admin</option>
                    </select>
                </label>

                <label class="block">
                    <div class="text-xs font-semibold text-slate-500">Status</div>
                    <select v-model="form.status" class="mt-2 h-11 w-full appearance-none rounded-xl border border-slate-200 bg-white px-4 pr-10 text-sm font-semibold text-slate-800">
                        <option value="draft">Rascunho</option>
                        <option value="scheduled">Agendado</option>
                        <option value="published">Publicado</option>
                    </select>
                </label>
                <label class="block">
                    <div class="text-xs font-semibold text-slate-500">Agendar para (opcional)</div>
                    <input v-model="form.scheduled_at" type="datetime-local" class="mt-2 h-11 w-full appearance-none rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800" />
                </label>

                <label class="block md:col-span-2">
                    <div class="text-xs font-semibold text-slate-500">Conteúdo</div>
                    <textarea v-model="form.content" rows="7" class="mt-2 w-full resize-none appearance-none rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-800" placeholder="Descreva a novidade..."></textarea>
                </label>

                <label class="block md:col-span-2">
                    <div class="text-xs font-semibold text-slate-500">Imagem (URL opcional)</div>
                    <input v-model="form.image_url" type="url" class="mt-2 h-11 w-full appearance-none rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800" placeholder="https://..." />
                </label>

                <label class="block">
                    <div class="text-xs font-semibold text-slate-500">CTA (texto opcional)</div>
                    <input v-model="form.cta_text" type="text" class="mt-2 h-11 w-full appearance-none rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800" placeholder="Saiba mais" />
                </label>
                <label class="block">
                    <div class="text-xs font-semibold text-slate-500">CTA (URL opcional)</div>
                    <input v-model="form.cta_url" type="url" class="mt-2 h-11 w-full appearance-none rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800" placeholder="https://..." />
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
