<script setup lang="ts">
import { computed } from 'vue';
import { Link } from '@inertiajs/vue3';

type Item = {
    label: string;
    href: string;
    active: boolean;
};

const items = computed<Item[]>(() => [
    { label: 'Usuários', href: route('admin.users.index'), active: route().current('admin.users.*') },
    { label: 'Papéis e Permissões', href: route('admin.roles.index'), active: route().current('admin.roles.*') },
    { label: 'Logs de Ações', href: route('admin.logs.index'), active: route().current('admin.logs.*') },
    { label: 'Notificações', href: route('admin.notifications.index'), active: route().current('admin.notifications.*') },
    { label: 'E-mails e Comunicados', href: route('admin.emails.index'), active: route().current('admin.emails.*') },
    { label: 'Leads', href: route('admin.leads.index'), active: route().current('admin.leads.*') },
    { label: 'Contatos Institucionais', href: route('admin.inquiries.index'), active: route().current('admin.inquiries.*') },
    { label: 'Novidades', href: route('admin.news.index'), active: route().current('admin.news.*') },
]);
</script>

<template>
    <div class="flex gap-2 overflow-x-auto pb-1 scrollbar-hide">
        <Link
            v-for="item in items"
            :key="item.href"
            :href="item.href"
            class="shrink-0 rounded-full px-4 py-2 text-xs font-semibold transition ring-1"
            :class="item.active ? 'bg-[#14B8A6] text-white ring-[#14B8A6]' : 'bg-white text-slate-600 ring-slate-200 hover:bg-slate-50'"
        >
            {{ item.label }}
        </Link>
    </div>
</template>
