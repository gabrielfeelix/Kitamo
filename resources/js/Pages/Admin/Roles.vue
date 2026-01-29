<script setup lang="ts">
import { computed } from 'vue';
import { Head } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import { useIsMobile } from '@/composables/useIsMobile';
import AdminHeader from '@/Components/AdminHeader.vue';

const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() => (isMobile.value ? { showNav: false } : { title: 'Administração', showSearch: false, showNewAction: false }));

type RoleKey = 'admin' | 'user';
type PermissionKey =
    | 'transactions.read'
    | 'transactions.create'
    | 'transactions.update'
    | 'transactions.delete'
    | 'accounts.manage'
    | 'categories.manage'
    | 'credit_cards.manage'
    | 'reports.export'
    | 'goals.manage'
    | 'settings.manage'
    | 'admin.access'
    | 'admin.users.manage'
    | 'admin.roles.manage'
    | 'admin.logs.read';

const roles: Array<{ key: RoleKey; label: string; description: string }> = [
    { key: 'admin', label: 'Admin', description: 'Acesso total (painel de administração + gestão).' },
    { key: 'user', label: 'Usuário', description: 'Acesso padrão ao app (sem painel admin).' },
];

const permissions: Array<{ key: PermissionKey; label: string; description: string }> = [
    { key: 'transactions.read', label: 'Ver transações', description: 'Listar e visualizar movimentações.' },
    { key: 'transactions.create', label: 'Criar transações', description: 'Adicionar receitas/despesas/transferências.' },
    { key: 'transactions.update', label: 'Editar transações', description: 'Alterar categoria, conta, valor, etc.' },
    { key: 'transactions.delete', label: 'Excluir transações', description: 'Remover movimentações.' },
    { key: 'accounts.manage', label: 'Gerenciar contas', description: 'Criar/editar/excluir contas e carteiras.' },
    { key: 'categories.manage', label: 'Gerenciar categorias', description: 'Criar/editar/excluir categorias e ícones.' },
    { key: 'credit_cards.manage', label: 'Gerenciar cartões', description: 'Criar/editar/excluir cartões de crédito.' },
    { key: 'reports.export', label: 'Exportar relatórios', description: 'Gerar PDF/CSV/XLSX (quando habilitado).' },
    { key: 'goals.manage', label: 'Gerenciar metas', description: 'Criar/editar/excluir metas e depósitos.' },
    { key: 'settings.manage', label: 'Ajustes gerais', description: 'Preferências e telas de configurações.' },
    { key: 'admin.access', label: 'Acessar painel admin', description: 'Entrar na área de administração.' },
    { key: 'admin.users.manage', label: 'Gerenciar usuários', description: 'Editar/desativar/excluir usuários.' },
    { key: 'admin.roles.manage', label: 'Gerenciar papéis', description: 'Gerenciar papéis e permissões.' },
    { key: 'admin.logs.read', label: 'Ver logs', description: 'Visualizar logs de ações.' },
];

const matrix: Record<RoleKey, Set<PermissionKey>> = {
    admin: new Set(permissions.map((p) => p.key)),
    user: new Set([
        'transactions.read',
        'transactions.create',
        'transactions.update',
        'transactions.delete',
        'accounts.manage',
        'categories.manage',
        'credit_cards.manage',
        'reports.export',
        'goals.manage',
        'settings.manage',
    ]),
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
                <div class="text-sm font-semibold text-slate-900">Permissões</div>
                <div class="mt-4 overflow-x-auto">
                    <table class="min-w-full text-left text-sm">
                        <thead class="text-xs font-bold uppercase tracking-wide text-slate-400">
                            <tr>
                                <th class="py-3 pr-4">Permissão</th>
                                <th class="py-3 pr-4">Descrição</th>
                                <th class="py-3 pr-4 text-center">Admin</th>
                                <th class="py-3 pr-4 text-center">Usuário</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                            <tr v-for="perm in permissions" :key="perm.key">
                                <td class="py-3 pr-4">
                                    <div class="font-semibold text-slate-900">{{ perm.label }}</div>
                                    <div class="mt-1 text-xs font-semibold text-slate-400">{{ perm.key }}</div>
                                </td>
                                <td class="py-3 pr-4 text-slate-600">{{ perm.description }}</td>
                                <td class="py-3 pr-4 text-center">
                                    <span class="inline-flex h-6 w-6 items-center justify-center rounded-full bg-emerald-50 text-emerald-700">✓</span>
                                </td>
                                <td class="py-3 pr-4 text-center">
                                    <span
                                        class="inline-flex h-6 w-6 items-center justify-center rounded-full"
                                        :class="matrix.user.has(perm.key) ? 'bg-emerald-50 text-emerald-700' : 'bg-slate-100 text-slate-400'"
                                    >
                                        {{ matrix.user.has(perm.key) ? '✓' : '—' }}
                                    </span>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div class="mt-4 text-xs font-semibold text-slate-400">
                    Nota: por enquanto as permissões são um “mapa” de referência; o acesso real ao admin continua restrito ao e-mail `contato@kitamo.com.br`.
                </div>
            </div>
        </div>
    </component>
</template>
