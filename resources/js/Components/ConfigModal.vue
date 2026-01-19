<script setup lang="ts">
import { computed } from 'vue';
import { Link } from '@inertiajs/vue3';

defineProps<{
    open: boolean;
}>();

const emit = defineEmits<{
    (e: 'close'): void;
}>();

const menuItems = computed(() => [
    {
        label: 'Categorias',
        href: route('settings'),
        icon: 'tag',
    },
    {
        label: 'Tags',
        href: route('settings'),
        icon: 'tag2',
    },
    {
        label: 'Metas',
        href: route('settings'),
        icon: 'target',
    },
    {
        label: 'Contas',
        href: route('settings'),
        icon: 'wallet',
    },
    {
        label: 'Cartão de Crédito',
        href: route('settings'),
        icon: 'card',
    },
]);
</script>

<template>
    <div
        v-if="open"
        class="fixed inset-0 z-50 overflow-y-auto bg-white"
    >
        <!-- Header -->
        <div class="sticky top-0 z-10 border-b border-slate-200/70 bg-white px-5 py-4">
            <div class="flex items-center justify-between">
                <h2 class="text-2xl font-semibold tracking-tight text-slate-900">Configurações</h2>
                <button
                    type="button"
                    class="flex h-11 w-11 items-center justify-center rounded-full text-slate-400 hover:bg-slate-100"
                    @click="emit('close')"
                >
                    <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M18 6l-12 12" />
                        <path d="M6 6l12 12" />
                    </svg>
                </button>
            </div>
        </div>

        <!-- Menu Items -->
        <div class="px-5 py-6">
            <div class="space-y-3">
                <Link
                    v-for="item in menuItems"
                    :key="item.label"
                    :href="item.href"
                    class="flex items-center gap-4 rounded-2xl bg-white px-5 py-4 shadow-sm ring-1 ring-slate-200/60 transition hover:bg-slate-50"
                    @click="emit('close')"
                >
                    <span class="flex h-12 w-12 items-center justify-center rounded-2xl bg-slate-100 text-slate-600">
                        <svg v-if="item.icon === 'tag'" class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M12.586 2.586a2 2 0 0 1 2.828 0l6 6a2 2 0 0 1 0 2.828l-9 9a2 2 0 0 1-2.828 0l-6-6a2 2 0 0 1 0-2.828l9-9Z" />
                            <path d="M15 9h.01" />
                        </svg>
                        <svg v-else-if="item.icon === 'tag2'" class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M12.586 2.586a2 2 0 0 1 2.828 0l6 6a2 2 0 0 1 0 2.828l-9 9a2 2 0 0 1-2.828 0l-6-6a2 2 0 0 1 0-2.828l9-9Z" />
                            <path d="M15 9h.01" />
                        </svg>
                        <svg v-else-if="item.icon === 'target'" class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <circle cx="12" cy="12" r="1" />
                            <circle cx="12" cy="12" r="5" />
                            <circle cx="12" cy="12" r="9" />
                        </svg>
                        <svg v-else-if="item.icon === 'wallet'" class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M4 7h16v12H4z" />
                            <path d="M4 7V5h12v2" />
                            <path d="M16 12h4" />
                        </svg>
                        <svg v-else-if="item.icon === 'card'" class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <rect x="3" y="5" width="18" height="14" rx="3" />
                            <path d="M3 10h18" />
                        </svg>
                    </span>
                    <div class="text-sm font-semibold text-slate-900">{{ item.label }}</div>
                </Link>
            </div>
        </div>

        <!-- Logout Button -->
        <div class="border-t border-slate-200/70 px-5 py-6">
            <Link
                :href="route('logout')"
                method="post"
                as="button"
                class="w-full rounded-2xl bg-red-50 px-5 py-4 text-center text-sm font-semibold text-red-500 transition hover:bg-red-100"
            >
                Sair da conta
            </Link>
        </div>
    </div>
</template>
