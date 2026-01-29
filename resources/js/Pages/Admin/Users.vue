<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, router, useForm } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import { useIsMobile } from '@/composables/useIsMobile';
import AdminLayout from '@/Components/AdminLayout.vue';

type UserRow = {
    id: number;
    name: string;
    email: string;
    phone: string | null;
    avatar_url: string | null;
    created_at: string | null;
    role: 'admin' | 'user';
    status: 'active' | 'disabled';
    plan: string;
};

const props = defineProps<{
    users: UserRow[];
}>();

const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() =>
    isMobile.value ? { showNav: false } : { title: 'Administração', showSearch: false, showNewAction: false },
);

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

const editingUserId = ref<number | null>(null);
const deletingUserId = ref<number | null>(null);

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

const passwordUserId = ref<number | null>(null);
const passwordForm = useForm({
    password: '',
    password_confirmation: '',
});

const openEdit = (user: UserRow) => {
    deletingUserId.value = null;
    passwordUserId.value = null;
    editingUserId.value = editingUserId.value === user.id ? null : user.id;
    editForm.reset();
    editForm.clearErrors();
    editForm.name = user.name;
    editForm.phone = user.phone ?? '';
    editForm.role = user.role;
    editForm.status = user.status;
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
    editForm.status = user.status === 'disabled' ? 'active' : 'disabled';
    editForm.patch(route('admin.users.update', user.id), {
        preserveScroll: true,
        onSuccess: () => router.reload({ only: ['users'] }),
    });
};

const openPassword = (user: UserRow) => {
    deletingUserId.value = null;
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

const openDelete = (id: number) => {
    editingUserId.value = null;
    passwordUserId.value = null;
    deletingUserId.value = deletingUserId.value === id ? null : id;
};

const deleteForm = useForm({});
const confirmDelete = (id: number) => {
    deleteForm.delete(route('admin.users.destroy', id), {
        preserveScroll: true,
        onSuccess: () => {
            deletingUserId.value = null;
            router.reload({ only: ['users'] });
        },
    });
};
</script>

<template>
    <Head title="Administração · Usuários" />

    <component :is="Shell" v-bind="shellProps">
        <AdminLayout title="Usuários" description="Gerencie usuários, papéis e status da conta.">

            <!-- Desktop table -->
            <div v-if="!isMobile" class="rounded-2xl bg-slate-50 p-6 ring-1 ring-slate-200/60">
                <div class="flex items-center justify-between">
                    <div class="text-sm font-semibold text-slate-900">Usuários</div>
                    <div class="text-xs font-semibold text-slate-400">{{ props.users.length }} usuários</div>
                </div>

                <div class="mt-5 overflow-x-auto">
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
                            <tr v-for="user in props.users" :key="user.id" class="align-top">
                                <td class="py-4 pr-4">
                                    <div class="flex items-center gap-3">
                                        <div
                                            class="flex h-10 w-10 items-center justify-center overflow-hidden rounded-full bg-slate-200 text-xs font-bold text-slate-700"
                                        >
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
                                    <span
                                        class="rounded-full px-3 py-1 text-xs font-semibold"
                                        :class="user.role === 'admin' ? 'bg-emerald-50 text-emerald-700' : 'bg-slate-100 text-slate-600'"
                                    >
                                        {{ user.role === 'admin' ? 'Admin' : 'Usuário' }}
                                    </span>
                                </td>
                                <td class="py-4 pr-4">
                                    <span
                                        class="rounded-full px-3 py-1 text-xs font-semibold"
                                        :class="user.status === 'disabled' ? 'bg-red-50 text-red-600' : 'bg-emerald-50 text-emerald-700'"
                                    >
                                        {{ user.status === 'disabled' ? 'Desativado' : 'Ativo' }}
                                    </span>
                                </td>
                                <td class="py-4 text-right">
                                    <div class="inline-flex items-center justify-end gap-2">
                                        <button
                                            type="button"
                                            class="rounded-xl border border-slate-200 bg-white px-3 py-2 text-xs font-semibold text-slate-700 hover:bg-slate-50"
                                            @click="openEdit(user)"
                                        >
                                            Editar
                                        </button>
                                        <button
                                            type="button"
                                            class="rounded-xl border border-slate-200 bg-white px-3 py-2 text-xs font-semibold text-slate-700 hover:bg-slate-50"
                                            @click="openPassword(user)"
                                        >
                                            Senha
                                        </button>
                                        <button
                                            type="button"
                                            class="rounded-xl border border-slate-200 bg-white px-3 py-2 text-xs font-semibold text-slate-700 hover:bg-slate-50"
                                            @click="toggleStatus(user)"
                                        >
                                            {{ user.status === 'disabled' ? 'Ativar' : 'Desativar' }}
                                        </button>
                                        <button
                                            type="button"
                                            class="rounded-xl border border-red-200 bg-red-50 px-3 py-2 text-xs font-semibold text-red-700 hover:bg-red-100"
                                            @click="openDelete(user.id)"
                                        >
                                            Excluir
                                        </button>
                                    </div>

                                    <div v-if="editingUserId === user.id" class="mt-4 rounded-2xl bg-slate-50 p-4 text-left ring-1 ring-slate-200/60">
                                        <div class="grid grid-cols-2 gap-3">
                                            <div class="col-span-2">
                                                <label class="text-xs font-semibold text-slate-500">Nome</label>
                                                <input
                                                    v-model="editForm.name"
                                                    type="text"
                                                    class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-800"
                                                />
                                                <div v-if="editForm.errors.name" class="mt-1 text-xs font-semibold text-red-600">{{ editForm.errors.name }}</div>
                                            </div>
                                            <div class="col-span-2">
                                                <label class="text-xs font-semibold text-slate-500">Telefone</label>
                                                <input
                                                    v-model="editForm.phone"
                                                    type="text"
                                                    class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-800"
                                                />
                                            </div>
                                            <div>
                                                <label class="text-xs font-semibold text-slate-500">Papel</label>
                                                <select
                                                    v-model="editForm.role"
                                                    class="mt-2 h-11 w-full appearance-none rounded-xl border border-slate-200 bg-white bg-none px-4 pr-10 text-sm font-semibold text-slate-800"
                                                >
                                                    <option value="user">Usuário</option>
                                                    <option value="admin">Admin</option>
                                                </select>
                                            </div>
                                            <div>
                                                <label class="text-xs font-semibold text-slate-500">Status</label>
                                                <select
                                                    v-model="editForm.status"
                                                    class="mt-2 h-11 w-full appearance-none rounded-xl border border-slate-200 bg-white bg-none px-4 pr-10 text-sm font-semibold text-slate-800"
                                                >
                                                    <option value="active">Ativo</option>
                                                    <option value="disabled">Desativado</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="mt-4 flex justify-end gap-2">
                                            <button
                                                type="button"
                                                class="rounded-xl border border-slate-200 bg-white px-4 py-2 text-xs font-semibold text-slate-700 hover:bg-slate-50"
                                                @click="editingUserId = null"
                                            >
                                                Cancelar
                                            </button>
                                            <button
                                                type="button"
                                                class="rounded-xl bg-slate-900 px-4 py-2 text-xs font-semibold text-white disabled:opacity-50"
                                                :disabled="editForm.processing"
                                                @click="saveEdit(user.id)"
                                            >
                                                Salvar
                                            </button>
                                        </div>
                                    </div>

                                    <div v-if="passwordUserId === user.id" class="mt-4 rounded-2xl bg-slate-50 p-4 text-left ring-1 ring-slate-200/60">
                                        <div class="grid grid-cols-2 gap-3">
                                            <div class="col-span-2">
                                                <label class="text-xs font-semibold text-slate-500">Nova senha</label>
                                                <input
                                                    v-model="passwordForm.password"
                                                    type="password"
                                                    class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-800"
                                                />
                                                <div v-if="passwordForm.errors.password" class="mt-1 text-xs font-semibold text-red-600">{{ passwordForm.errors.password }}</div>
                                            </div>
                                            <div class="col-span-2">
                                                <label class="text-xs font-semibold text-slate-500">Confirmar senha</label>
                                                <input
                                                    v-model="passwordForm.password_confirmation"
                                                    type="password"
                                                    class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-800"
                                                />
                                            </div>
                                        </div>
                                        <div class="mt-4 flex justify-end gap-2">
                                            <button
                                                type="button"
                                                class="rounded-xl border border-slate-200 bg-white px-4 py-2 text-xs font-semibold text-slate-700 hover:bg-slate-50"
                                                @click="passwordUserId = null"
                                            >
                                                Cancelar
                                            </button>
                                            <button
                                                type="button"
                                                class="rounded-xl bg-slate-900 px-4 py-2 text-xs font-semibold text-white disabled:opacity-50"
                                                :disabled="passwordForm.processing"
                                                @click="savePassword(user.id)"
                                            >
                                                Salvar senha
                                            </button>
                                        </div>
                                    </div>

                                    <div v-if="deletingUserId === user.id" class="mt-4 rounded-2xl border border-red-200 bg-red-50 p-4 text-left">
                                        <div class="text-sm font-semibold text-red-700">Confirmar exclusão</div>
                                        <div class="mt-1 text-xs font-semibold text-red-600">Essa ação é permanente.</div>
                                        <div class="mt-4 flex justify-end gap-2">
                                            <button
                                                type="button"
                                                class="rounded-xl border border-red-200 bg-white px-4 py-2 text-xs font-semibold text-red-700 hover:bg-red-100"
                                                @click="deletingUserId = null"
                                            >
                                                Cancelar
                                            </button>
                                            <button
                                                type="button"
                                                class="rounded-xl bg-red-600 px-4 py-2 text-xs font-semibold text-white disabled:opacity-50"
                                                :disabled="deleteForm.processing"
                                                @click="confirmDelete(user.id)"
                                            >
                                                Excluir
                                            </button>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Mobile cards -->
            <div v-else class="space-y-4">
                <div
                    v-for="user in props.users"
                    :key="user.id"
                    class="rounded-3xl bg-white p-5 shadow-sm ring-1 ring-slate-200/60"
                >
                    <div class="flex items-start justify-between gap-4">
                        <div class="flex min-w-0 items-center gap-3">
                            <div
                                class="flex h-11 w-11 items-center justify-center overflow-hidden rounded-full bg-slate-200 text-xs font-bold text-slate-700"
                            >
                                <img v-if="user.avatar_url" :src="user.avatar_url" alt="" class="h-full w-full object-cover" />
                                <span v-else>{{ initials(user.name) }}</span>
                            </div>
                            <div class="min-w-0">
                                <div class="truncate text-base font-semibold text-slate-900">{{ user.name }}</div>
                                <div class="truncate text-xs font-semibold text-slate-400">{{ user.email }}</div>
                            </div>
                        </div>

                        <div class="flex flex-col items-end gap-2">
                            <span
                                class="rounded-full px-3 py-1 text-xs font-semibold"
                                :class="user.role === 'admin' ? 'bg-emerald-50 text-emerald-700' : 'bg-slate-100 text-slate-600'"
                            >
                                {{ user.role === 'admin' ? 'Admin' : 'Usuário' }}
                            </span>
                            <span
                                class="rounded-full px-3 py-1 text-xs font-semibold"
                                :class="user.status === 'disabled' ? 'bg-red-50 text-red-600' : 'bg-emerald-50 text-emerald-700'"
                            >
                                {{ user.status === 'disabled' ? 'Desativado' : 'Ativo' }}
                            </span>
                        </div>
                    </div>

                    <div class="mt-4 grid grid-cols-2 gap-3 text-xs font-semibold text-slate-500">
                        <div>
                            <div class="text-slate-400">Telefone</div>
                            <div class="mt-1 text-slate-700">{{ user.phone ?? '—' }}</div>
                        </div>
                        <div>
                            <div class="text-slate-400">Plano</div>
                            <div class="mt-1 text-slate-700">{{ user.plan }}</div>
                        </div>
                        <div class="col-span-2">
                            <div class="text-slate-400">Criado em</div>
                            <div class="mt-1 text-slate-700">{{ formatDate(user.created_at) }}</div>
                        </div>
                    </div>

                    <div class="mt-4 flex flex-wrap gap-2">
                        <button
                            type="button"
                            class="rounded-xl border border-slate-200 bg-white px-3 py-2 text-xs font-semibold text-slate-700"
                            @click="openEdit(user)"
                        >
                            Editar
                        </button>
                        <button
                            type="button"
                            class="rounded-xl border border-slate-200 bg-white px-3 py-2 text-xs font-semibold text-slate-700"
                            @click="openPassword(user)"
                        >
                            Senha
                        </button>
                        <button
                            type="button"
                            class="rounded-xl border border-slate-200 bg-white px-3 py-2 text-xs font-semibold text-slate-700"
                            @click="toggleStatus(user)"
                        >
                            {{ user.status === 'disabled' ? 'Ativar' : 'Desativar' }}
                        </button>
                        <button
                            type="button"
                            class="rounded-xl border border-red-200 bg-red-50 px-3 py-2 text-xs font-semibold text-red-700"
                            @click="openDelete(user.id)"
                        >
                            Excluir
                        </button>
                    </div>

                    <div v-if="editingUserId === user.id" class="mt-4 rounded-2xl bg-slate-50 p-4 ring-1 ring-slate-200/60">
                        <div class="space-y-3">
                            <div>
                                <label class="text-xs font-semibold text-slate-500">Nome</label>
                                <input v-model="editForm.name" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-800" />
                                <div v-if="editForm.errors.name" class="mt-1 text-xs font-semibold text-red-600">{{ editForm.errors.name }}</div>
                            </div>
                            <div>
                                <label class="text-xs font-semibold text-slate-500">Telefone</label>
                                <input v-model="editForm.phone" type="text" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-800" />
                            </div>
                            <div class="grid grid-cols-2 gap-3">
                                <div>
                                    <label class="text-xs font-semibold text-slate-500">Papel</label>
                                    <select v-model="editForm.role" class="mt-2 h-11 w-full appearance-none rounded-xl border border-slate-200 bg-white bg-none px-4 pr-10 text-sm font-semibold text-slate-800">
                                        <option value="user">Usuário</option>
                                        <option value="admin">Admin</option>
                                    </select>
                                </div>
                                <div>
                                    <label class="text-xs font-semibold text-slate-500">Status</label>
                                    <select v-model="editForm.status" class="mt-2 h-11 w-full appearance-none rounded-xl border border-slate-200 bg-white bg-none px-4 pr-10 text-sm font-semibold text-slate-800">
                                        <option value="active">Ativo</option>
                                        <option value="disabled">Desativado</option>
                                    </select>
                                </div>
                            </div>
                            <div class="flex justify-end gap-2">
                                <button type="button" class="rounded-xl border border-slate-200 bg-white px-4 py-2 text-xs font-semibold text-slate-700" @click="editingUserId = null">Cancelar</button>
                                <button type="button" class="rounded-xl bg-slate-900 px-4 py-2 text-xs font-semibold text-white disabled:opacity-50" :disabled="editForm.processing" @click="saveEdit(user.id)">Salvar</button>
                            </div>
                        </div>
                    </div>

                    <div v-if="passwordUserId === user.id" class="mt-4 rounded-2xl bg-slate-50 p-4 ring-1 ring-slate-200/60">
                        <div class="space-y-3">
                            <div>
                                <label class="text-xs font-semibold text-slate-500">Nova senha</label>
                                <input v-model="passwordForm.password" type="password" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-800" />
                                <div v-if="passwordForm.errors.password" class="mt-1 text-xs font-semibold text-red-600">{{ passwordForm.errors.password }}</div>
                            </div>
                            <div>
                                <label class="text-xs font-semibold text-slate-500">Confirmar senha</label>
                                <input v-model="passwordForm.password_confirmation" type="password" class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-800" />
                            </div>
                            <div class="flex justify-end gap-2">
                                <button type="button" class="rounded-xl border border-slate-200 bg-white px-4 py-2 text-xs font-semibold text-slate-700" @click="passwordUserId = null">Cancelar</button>
                                <button type="button" class="rounded-xl bg-slate-900 px-4 py-2 text-xs font-semibold text-white disabled:opacity-50" :disabled="passwordForm.processing" @click="savePassword(user.id)">Salvar senha</button>
                            </div>
                        </div>
                    </div>

                    <div v-if="deletingUserId === user.id" class="mt-4 rounded-2xl border border-red-200 bg-red-50 p-4">
                        <div class="text-sm font-semibold text-red-700">Confirmar exclusão</div>
                        <div class="mt-1 text-xs font-semibold text-red-600">Essa ação é permanente.</div>
                        <div class="mt-4 flex justify-end gap-2">
                            <button type="button" class="rounded-xl border border-red-200 bg-white px-4 py-2 text-xs font-semibold text-red-700" @click="deletingUserId = null">Cancelar</button>
                            <button type="button" class="rounded-xl bg-red-600 px-4 py-2 text-xs font-semibold text-white disabled:opacity-50" :disabled="deleteForm.processing" @click="confirmDelete(user.id)">Excluir</button>
                        </div>
                    </div>
                </div>
            </div>
        </AdminLayout>
    </component>
</template>
