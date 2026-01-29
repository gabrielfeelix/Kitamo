<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, router } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import { useIsMobile } from '@/composables/useIsMobile';
import AdminHeader from '@/Components/AdminHeader.vue';

const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() => (isMobile.value ? { showNav: false } : { title: 'Administração', showSearch: false, showNewAction: false }));

type RoleKey = 'admin' | 'user';
type PermissionKey = string;

type RoleRow = { key: RoleKey; label: string; description: string };
type PermissionRow = { key: PermissionKey; label: string; description: string };
type Matrix = Record<RoleKey, Record<PermissionKey, boolean>>;

const props = defineProps<{
    roles: RoleRow[];
    permissions: PermissionRow[];
    matrix: Matrix;
}>();

const selectedRole = ref<RoleKey>('user');
const working = ref(false);
const localMatrix = ref<Matrix>(JSON.parse(JSON.stringify(props.matrix)) as Matrix);

const isAllowed = (role: RoleKey, perm: PermissionKey) => Boolean(localMatrix.value?.[role]?.[perm]);
const toggle = (role: RoleKey, perm: PermissionKey) => {
    if (role === 'admin') return;
    localMatrix.value[role][perm] = !isAllowed(role, perm);
};

const save = async () => {
    working.value = true;
    router.patch(
        route('admin.roles.update', selectedRole.value),
        { permissions: localMatrix.value[selectedRole.value] },
        {
            preserveScroll: true,
            onFinish: () => {
                working.value = false;
            },
        },
    );
};
</script>

<template>
    <Head title="Administração · Papéis e Permissões" />

    <component :is="Shell" v-bind="shellProps">
        <div class="space-y-4">
            <AdminHeader description="Mapa atual de papéis e permissões do sistema." />

            <div class="rounded-3xl bg-white p-6 shadow-sm ring-1 ring-slate-200/60">
                <div class="text-sm font-semibold text-slate-900">Papéis</div>
                <div class="mt-4 grid gap-3 md:grid-cols-2">
                    <div v-for="role in roles" :key="role.key" class="rounded-2xl bg-slate-50 p-4 ring-1 ring-slate-200/60">
                        <div class="text-base font-semibold text-slate-900">{{ role.label }}</div>
                        <div class="mt-1 text-sm text-slate-600">{{ role.description }}</div>
                    </div>
                </div>
            </div>

            <div class="rounded-3xl bg-white p-6 shadow-sm ring-1 ring-slate-200/60">
                <div class="flex flex-wrap items-center justify-between gap-3">
                    <div class="text-sm font-semibold text-slate-900">Permissões</div>
                    <div class="flex items-center gap-2">
                        <select
                            v-model="selectedRole"
                            class="h-10 appearance-none rounded-xl border border-slate-200 bg-white px-3 pr-9 text-sm font-semibold text-slate-800"
                            aria-label="Selecionar papel"
                        >
                            <option v-for="role in props.roles" :key="role.key" :value="role.key">{{ role.label }}</option>
                        </select>
                        <button
                            type="button"
                            class="inline-flex items-center justify-center rounded-xl bg-[#14B8A6] px-4 py-2 text-sm font-semibold text-white shadow-lg shadow-emerald-500/20 disabled:cursor-not-allowed disabled:opacity-60"
                            :disabled="working || selectedRole === 'admin'"
                            @click="save"
                        >
                            {{ working ? 'Salvando…' : 'Salvar' }}
                        </button>
                    </div>
                </div>

                <div class="mt-4 overflow-x-auto">
                    <table class="min-w-full text-left text-sm">
                        <thead class="text-xs font-bold uppercase tracking-wide text-slate-400">
                            <tr>
                                <th class="py-3 pr-4">Permissão</th>
                                <th class="py-3 pr-4">Descrição</th>
                                <th class="py-3 pr-4 text-center">Permitido</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                            <tr v-for="perm in props.permissions" :key="perm.key">
                                <td class="py-3 pr-4">
                                    <div class="font-semibold text-slate-900">{{ perm.label }}</div>
                                    <div class="mt-1 text-xs font-semibold text-slate-400">{{ perm.key }}</div>
                                </td>
                                <td class="py-3 pr-4 text-slate-600">{{ perm.description }}</td>
                                <td class="py-3 pr-4 text-center">
                                    <div v-if="selectedRole === 'admin'" class="inline-flex h-6 w-6 items-center justify-center rounded-full bg-emerald-50 text-emerald-700">
                                        ✓
                                    </div>
                                    <button
                                        v-else
                                        type="button"
                                        class="inline-flex h-7 w-11 items-center rounded-full px-1 ring-1 transition"
                                        :class="isAllowed(selectedRole, perm.key) ? 'bg-[#14B8A6] ring-emerald-300/70' : 'bg-slate-100 ring-slate-200/70'"
                                        @click="toggle(selectedRole, perm.key)"
                                        :aria-label="isAllowed(selectedRole, perm.key) ? 'Desativar permissão' : 'Ativar permissão'"
                                    >
                                        <span
                                            class="h-5 w-5 rounded-full bg-white shadow-sm transition-transform"
                                            :class="isAllowed(selectedRole, perm.key) ? 'translate-x-4' : 'translate-x-0'"
                                        ></span>
                                    </button>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div class="mt-4 text-xs font-semibold text-slate-400">
                    Nota: o acesso real ao admin continua restrito ao e-mail `contato@kitamo.com.br` (isso não muda mesmo que você desmarque `admin.access`).
                </div>
            </div>
        </div>
    </component>
</template>
