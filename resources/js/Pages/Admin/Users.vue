<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import { Head, router, useForm } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import { useIsMobile } from '@/composables/useIsMobile';
import AdminLayout from '@/Components/AdminLayout.vue';
import Modal from '@/Components/Modal.vue';
import StatusBadge from '@/Components/StatusBadge.vue';
import DestructiveConfirmModal from '@/Components/DestructiveConfirmModal.vue';

type UserRow = {
    id: number;
    name: string;
    email: string;
    phone: string | null;
    avatar_url: string | null;
    created_at: string | null;
    role: 'admin' | 'user';
    is_disabled: boolean;
    email_verified_at: string | null;
    plan: string;
};

type PaginationLink = { url: string | null; label: string; active: boolean };
type UsersPagination = {
    data: UserRow[];
    links: PaginationLink[];
    meta?: { total?: number };
};

const props = defineProps<{
    q: string;
    filters: {
        q?: string | null;
        plan?: string | null;
        status?: string | null;
        role?: string | null;
    };
    users: UsersPagination;
}>();

const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() =>
    isMobile.value ? { showNav: false } : { title: 'Administração', showSearch: false, showNewAction: false },
);

const totalUsersLabel = computed(() => {
    const total = props.users.meta?.total ?? props.users.data.length;
    return `${total} usuários`;
});

const formatDate = (iso: string | null) => {
    if (!iso) return '';
    const d = new Date(iso);
    return Number.isFinite(d.getTime())
        ? d.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric' })
        : String(iso);
};

const initials = (name: string) => {
    const parts = String(name).trim().split(/\s+/).filter(Boolean);
    const first = parts[0]?.[0] ?? 'U';
    const last = parts.length > 1 ? parts[parts.length - 1]?.[0] : '';
    return `${first}${last}`.toUpperCase();
};

const userStatusVariant = (user: UserRow): 'active' | 'inactive' | 'pending' => {
    if (user.is_disabled) return 'inactive';
    if (!user.email_verified_at) return 'pending';
    return 'active';
};

const userStatusLabel = (user: UserRow) => {
    const v = userStatusVariant(user);
    return v === 'inactive' ? 'Inativo' : v === 'pending' ? 'Pendente' : 'Ativo';
};

const query = ref(props.filters?.q ?? '');
const plan = ref(props.filters?.plan ?? '');
const status = ref(props.filters?.status ?? '');
const role = ref(props.filters?.role ?? '');

watch(
    () => props.filters,
    (f) => {
        query.value = f?.q ?? '';
        plan.value = f?.plan ?? '';
        status.value = f?.status ?? '';
        role.value = f?.role ?? '';
    },
);

const runFilters = () => {
    router.get(
        route('admin.users.index'),
        {
            q: query.value || undefined,
            plan: plan.value || undefined,
            status: status.value || undefined,
            role: role.value || undefined,
        },
        { preserveState: true, preserveScroll: true, replace: true },
    );
};

let debounceTimer: number | null = null;
const runSearch = () => {
    if (debounceTimer) window.clearTimeout(debounceTimer);
    debounceTimer = window.setTimeout(runFilters, 300);
};

const clearSearch = () => {
    query.value = '';
    runFilters();
};

const clearAll = () => {
    query.value = '';
    plan.value = '';
    status.value = '';
    role.value = '';
    runFilters();
};

const editingUserId = ref<number | null>(null);
const passwordUserId = ref<number | null>(null);
const deleteTarget = ref<UserRow | null>(null);

const editForm = useForm<{
    name: string;
    phone: string;
    role: 'admin' | 'user';
    status: 'active' | 'disabled';
}>({
    name: '',
    phone: '',
    role: 'user',
    status: 'active',
});

const passwordForm = useForm({
    password: '',
    password_confirmation: '',
});

const openEdit = (user: UserRow) => {
    deleteTarget.value = null;
    passwordUserId.value = null;
    editingUserId.value = editingUserId.value === user.id ? null : user.id;
    editForm.reset();
    editForm.clearErrors();
    editForm.name = user.name;
    editForm.phone = user.phone ?? '';
    editForm.role = user.role;
    editForm.status = user.is_disabled ? 'disabled' : 'active';
};

const saveEdit = (id: number) => {
    editForm.patch(route('admin.users.update', id), {
        preserveScroll: true,
        onSuccess: () => {
            editingUserId.value = null;
            router.reload({ only: ['users'] });
        },
    });
};

const toggleStatus = (user: UserRow) => {
    editForm.reset();
    editForm.clearErrors();
    editForm.name = user.name;
    editForm.phone = user.phone ?? '';
    editForm.role = user.role;
    editForm.status = user.is_disabled ? 'active' : 'disabled';
    editForm.patch(route('admin.users.update', user.id), {
        preserveScroll: true,
        onSuccess: () => router.reload({ only: ['users'] }),
    });
};

const openPassword = (user: UserRow) => {
    deleteTarget.value = null;
    editingUserId.value = null;
    passwordUserId.value = passwordUserId.value === user.id ? null : user.id;
    passwordForm.reset();
    passwordForm.clearErrors();
};

const savePassword = (id: number) => {
    passwordForm.patch(route('admin.users.password', id), {
        preserveScroll: true,
        onSuccess: () => {
            passwordForm.reset();
            passwordUserId.value = null;
        },
    });
};

const deleteForm = useForm({});
const confirmDelete = () => {
    if (!deleteTarget.value) return;
    deleteForm.delete(route('admin.users.destroy', deleteTarget.value.id), {
        preserveScroll: true,
        onSuccess: () => {
            deleteTarget.value = null;
            router.reload({ only: ['users'] });
        },
        onFinish: () => {
            // keep modal open if backend returns error
        },
    });
};

const createOpen = ref(false);
const createForm = useForm<{
    name: string;
    email: string;
    password: string;
    phone: string;
    role: 'admin' | 'user';
    status: 'active' | 'disabled';
}>({
    name: '',
    email: '',
    password: '',
    phone: '',
    role: 'user',
    status: 'active',
});

const openCreate = () => {
    createForm.reset();
    createForm.clearErrors();
    createOpen.value = true;
};

const saveCreate = () => {
    createForm.post(route('admin.users.store'), {
        preserveScroll: true,
        onSuccess: () => {
            createOpen.value = false;
            router.reload({ only: ['users'] });
        },
    });
};
</script>

<template>
    <Head title="Administração · Usuários" />

    <component :is="Shell" v-bind="shellProps">
        <AdminLayout title="Usuários" description="Gerencie usuários, papéis e status da conta.">
            <div class="rounded-2xl bg-slate-50 p-6 ring-1 ring-slate-200/60">
                <div class="flex items-center justify-between gap-4">
                    <div class="text-sm font-semibold text-slate-900">Usuários</div>
                    <div class="text-xs font-semibold text-slate-400">{{ totalUsersLabel }}</div>
                </div>

                <div class="mt-4">
                    <div class="flex flex-wrap items-center gap-3">
                        <div class="flex w-full items-center gap-2 rounded-2xl bg-white px-4 py-3 ring-1 ring-slate-200/60 md:w-[60%]">
                            <input
                                v-model="query"
                                type="text"
                                class="w-full appearance-none border-0 bg-transparent p-0 text-sm font-semibold text-slate-700 placeholder:text-slate-400 outline-none"
                                placeholder="🔍 Buscar por nome ou email..."
                                @input="runSearch"
                            />
                            <button
                                type="button"
                                class="flex h-9 w-9 items-center justify-center rounded-xl bg-slate-50 text-slate-500 ring-1 ring-slate-200/60 hover:bg-slate-100"
                                aria-label="Limpar busca"
                                @click="clearSearch"
                            >
                                ↻
                            </button>
                        </div>

                        <div class="flex flex-1 items-center justify-between gap-3">
                            <button
                                type="button"
                                class="rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-700 hover:bg-slate-50"
                                @click="clearAll"
                            >
                                Limpar filtros
                            </button>
                            <button
                                type="button"
                                class="rounded-xl bg-[#14B8A6] px-4 py-3 text-sm font-semibold text-white shadow-lg shadow-emerald-500/20"
                                @click="openCreate"
                            >
                                + Novo usuário
                            </button>
                        </div>
                    </div>

                    <div class="mt-4 text-xs font-semibold uppercase tracking-wide text-slate-400">Filtrar por:</div>
                    <div class="mt-2 grid grid-cols-1 gap-3 md:grid-cols-3">
                        <div>
                            <label class="text-xs font-semibold text-slate-500">Plano</label>
                            <select v-model="plan" class="mt-2 h-11 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800" @change="runFilters">
                                <option value="">Todos</option>
                                <option value="Free">Free</option>
                                <option value="Pro">Pro</option>
                                <option value="Premium">Premium</option>
                                <option value="Família">Família</option>
                            </select>
                        </div>
                        <div>
                            <label class="text-xs font-semibold text-slate-500">Status</label>
                            <select v-model="status" class="mt-2 h-11 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800" @change="runFilters">
                                <option value="">Todos</option>
                                <option value="active">Ativo</option>
                                <option value="inactive">Inativo</option>
                                <option value="pending">Pendente</option>
                            </select>
                        </div>
                        <div>
                            <label class="text-xs font-semibold text-slate-500">Papel</label>
                            <select v-model="role" class="mt-2 h-11 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800" @change="runFilters">
                                <option value="">Todos</option>
                                <option value="admin">Admin</option>
                                <option value="user">Usuário</option>
                            </select>
                        </div>
                    </div>
                </div>
            </div>

            <div class="mt-4 rounded-2xl bg-slate-50 p-6 ring-1 ring-slate-200/60">
                <div class="overflow-x-auto">
                    <table class="min-w-full text-left text-sm">
                        <thead class="text-xs font-bold uppercase tracking-wide text-slate-400">
                            <tr>
                                <th class="py-3 pr-4">Usuário</th>
                                <th class="py-3 pr-4">Telefone</th>
                                <th class="py-3 pr-4">Plano</th>
                                <th class="py-3 pr-4">Criado em</th>
                                <th class="py-3 pr-4">Papel</th>
                                <th class="py-3 pr-4">Status</th>
                                <th class="py-3 text-right">Ações</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                            <tr v-for="user in props.users.data" :key="user.id" class="align-top">
                                <td class="py-4 pr-4">
                                    <div class="flex items-center gap-3">
                                        <div class="flex h-10 w-10 items-center justify-center overflow-hidden rounded-full bg-slate-200 text-xs font-bold text-slate-700">
                                            <img v-if="user.avatar_url" :src="user.avatar_url" alt="" class="h-full w-full object-cover" />
                                            <span v-else>{{ initials(user.name) }}</span>
                                        </div>
                                        <div class="min-w-0">
                                            <div class="truncate font-semibold text-slate-900">{{ user.name }}</div>
                                            <div class="truncate text-xs font-semibold text-slate-400">{{ user.email }}</div>
                                        </div>
                                    </div>
                                </td>
                                <td class="py-4 pr-4 text-slate-600">{{ user.phone ?? '—' }}</td>
                                <td class="py-4 pr-4 text-slate-600">{{ user.plan }}</td>
                                <td class="py-4 pr-4 text-slate-600">{{ formatDate(user.created_at) }}</td>
                                <td class="py-4 pr-4">
                                    <span class="rounded-full px-3 py-1 text-xs font-semibold" :class="user.role === 'admin' ? 'bg-slate-900 text-white' : 'bg-white text-slate-700 ring-1 ring-slate-200/60'">
                                        {{ user.role === 'admin' ? 'Admin' : 'Usuário' }}
                                    </span>
                                </td>
                                <td class="py-4 pr-4">
                                    <StatusBadge :variant="userStatusVariant(user)" :label="userStatusLabel(user)" />
                                </td>
                                <td class="py-4 text-right">
                                    <div class="inline-flex items-center justify-end gap-2">
                                        <button type="button" class="rounded-xl border border-slate-200 bg-white px-3 py-2 text-xs font-semibold text-slate-700 hover:bg-slate-50" @click="openEdit(user)">
                                            Editar
                                        </button>
                                        <button type="button" class="rounded-xl border border-slate-200 bg-white px-3 py-2 text-xs font-semibold text-slate-700 hover:bg-slate-50" @click="openPassword(user)">
                                            Senha
                                        </button>
                                        <button type="button" class="rounded-xl border border-slate-200 bg-white px-3 py-2 text-xs font-semibold text-slate-700 hover:bg-slate-50" @click="toggleStatus(user)">
                                            {{ user.is_disabled ? 'Ativar' : 'Desativar' }}
                                        </button>
                                        <button type="button" class="rounded-xl border border-red-200 bg-red-50 px-3 py-2 text-xs font-semibold text-red-700 hover:bg-red-100" @click="deleteTarget = user">
                                            Excluir
                                        </button>
                                    </div>

                                    <div v-if="editingUserId === user.id" class="mt-4 rounded-2xl bg-slate-50 p-4 text-left ring-1 ring-slate-200/60">
                                        <div class="grid grid-cols-2 gap-3">
                                            <div class="col-span-2">
                                                <label class="text-xs font-semibold text-slate-500">Nome</label>
                                                <input v-model="editForm.name" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-800" />
                                                <div v-if="editForm.errors.name" class="mt-1 text-xs font-semibold text-red-600">{{ editForm.errors.name }}</div>
                                            </div>
                                            <div class="col-span-2">
                                                <label class="text-xs font-semibold text-slate-500">Telefone</label>
                                                <input v-model="editForm.phone" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-800" />
                                            </div>
                                            <div>
                                                <label class="text-xs font-semibold text-slate-500">Papel</label>
                                                <select v-model="editForm.role" class="mt-2 h-11 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800">
                                                    <option value="user">Usuário</option>
                                                    <option value="admin">Admin</option>
                                                </select>
                                            </div>
                                            <div>
                                                <label class="text-xs font-semibold text-slate-500">Status</label>
                                                <select v-model="editForm.status" class="mt-2 h-11 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800">
                                                    <option value="active">Ativo</option>
                                                    <option value="disabled">Inativo</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="mt-4 flex justify-end gap-2">
                                            <button type="button" class="rounded-xl border border-slate-200 bg-white px-4 py-2 text-xs font-semibold text-slate-700 hover:bg-slate-50" @click="editingUserId = null">
                                                Cancelar
                                            </button>
                                            <button type="button" class="rounded-xl bg-slate-900 px-4 py-2 text-xs font-semibold text-white disabled:opacity-50" :disabled="editForm.processing" @click="saveEdit(user.id)">
                                                Salvar
                                            </button>
                                        </div>
                                    </div>

                                    <div v-if="passwordUserId === user.id" class="mt-4 rounded-2xl bg-slate-50 p-4 text-left ring-1 ring-slate-200/60">
                                        <div class="grid grid-cols-2 gap-3">
                                            <div class="col-span-2">
                                                <label class="text-xs font-semibold text-slate-500">Nova senha</label>
                                                <input v-model="passwordForm.password" type="password" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-800" />
                                                <div v-if="passwordForm.errors.password" class="mt-1 text-xs font-semibold text-red-600">{{ passwordForm.errors.password }}</div>
                                            </div>
                                            <div class="col-span-2">
                                                <label class="text-xs font-semibold text-slate-500">Confirmar senha</label>
                                                <input v-model="passwordForm.password_confirmation" type="password" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-800" />
                                            </div>
                                        </div>
                                        <div class="mt-4 flex justify-end gap-2">
                                            <button type="button" class="rounded-xl border border-slate-200 bg-white px-4 py-2 text-xs font-semibold text-slate-700 hover:bg-slate-50" @click="passwordUserId = null">
                                                Cancelar
                                            </button>
                                            <button type="button" class="rounded-xl bg-slate-900 px-4 py-2 text-xs font-semibold text-white disabled:opacity-50" :disabled="passwordForm.processing" @click="savePassword(user.id)">
                                                Salvar senha
                                            </button>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <div v-if="props.users.links?.length" class="mt-6 flex flex-wrap items-center justify-center gap-2">
                    <button
                        v-for="link in props.users.links"
                        :key="link.label"
                        type="button"
                        class="rounded-full px-4 py-2 text-xs font-semibold ring-1"
                        :class="link.active ? 'bg-[#14B8A6] text-white ring-[#14B8A6]' : 'bg-white text-slate-600 ring-slate-200 hover:bg-slate-50'"
                        :disabled="!link.url"
                        v-html="link.label"
                        @click="link.url && router.visit(link.url)"
                    />
                </div>
            </div>

            <Modal :show="createOpen" maxWidth="lg" @close="createOpen = false">
                <div class="p-6">
                    <div class="flex items-start justify-between gap-4">
                        <div>
                            <div class="text-lg font-semibold text-slate-900">Novo usuário</div>
                            <div class="mt-1 text-sm text-slate-500">Cria um usuário com senha inicial.</div>
                        </div>
                        <button type="button" class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-50 text-slate-600 ring-1 ring-slate-200/60" aria-label="Fechar" @click="createOpen = false">
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M6 6l12 12" />
                                <path d="M18 6 6 18" />
                            </svg>
                        </button>
                    </div>

                    <div class="mt-5 grid grid-cols-2 gap-3">
                        <div class="col-span-2">
                            <label class="text-xs font-semibold text-slate-500">Nome</label>
                            <input v-model="createForm.name" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-800" />
                            <div v-if="createForm.errors.name" class="mt-1 text-xs font-semibold text-red-600">{{ createForm.errors.name }}</div>
                        </div>
                        <div class="col-span-2">
                            <label class="text-xs font-semibold text-slate-500">Email</label>
                            <input v-model="createForm.email" type="email" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-800" />
                            <div v-if="createForm.errors.email" class="mt-1 text-xs font-semibold text-red-600">{{ createForm.errors.email }}</div>
                        </div>
                        <div class="col-span-2">
                            <label class="text-xs font-semibold text-slate-500">Senha</label>
                            <input v-model="createForm.password" type="password" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-800" />
                            <div v-if="createForm.errors.password" class="mt-1 text-xs font-semibold text-red-600">{{ createForm.errors.password }}</div>
                        </div>
                        <div class="col-span-2">
                            <label class="text-xs font-semibold text-slate-500">Telefone</label>
                            <input v-model="createForm.phone" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-800" />
                        </div>
                        <div>
                            <label class="text-xs font-semibold text-slate-500">Papel</label>
                            <select v-model="createForm.role" class="mt-2 h-11 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800">
                                <option value="user">Usuário</option>
                                <option value="admin">Admin</option>
                            </select>
                        </div>
                        <div>
                            <label class="text-xs font-semibold text-slate-500">Status</label>
                            <select v-model="createForm.status" class="mt-2 h-11 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800">
                                <option value="active">Ativo</option>
                                <option value="disabled">Inativo</option>
                            </select>
                        </div>
                    </div>

                    <div class="mt-6 flex items-center justify-end gap-2">
                        <button type="button" class="rounded-xl border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-700 hover:bg-slate-50" @click="createOpen = false">
                            Cancelar
                        </button>
                        <button type="button" class="rounded-xl bg-[#14B8A6] px-4 py-2 text-sm font-semibold text-white disabled:opacity-60" :disabled="createForm.processing" @click="saveCreate">
                            {{ createForm.processing ? 'Criando…' : 'Criar usuário' }}
                        </button>
                    </div>
                </div>
            </Modal>

            <DestructiveConfirmModal
                :show="Boolean(deleteTarget)"
                title="Excluir usuário?"
                :item-title="deleteTarget?.name ?? ''"
                :item-subtitle="deleteTarget?.email ?? ''"
                :consequences="[
                    'Transações cadastradas',
                    'Contas e cartões',
                    'Metas e categorias customizadas',
                ]"
                confirm-word="EXCLUIR"
                :busy="deleteForm.processing"
                @close="deleteTarget = null"
                @confirm="confirmDelete"
            />
        </AdminLayout>
    </component>
</template>

