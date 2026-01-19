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
        color: 'teal',
    },
    {
        label: 'Tags',
        href: route('settings'),
        icon: 'tag2',
        color: 'blue',
    },
    {
        label: 'Metas',
        href: route('settings'),
        icon: 'target',
        color: 'red',
    },
    {
        label: 'Contas',
        href: route('settings'),
        icon: 'wallet',
        color: 'emerald',
    },
    {
        label: 'Cartão de Crédito',
        href: route('settings'),
        icon: 'card',
        color: 'purple',
    },
]);

const getColorClasses = (color: string) => {
    const colorMap: Record<string, { bg: string; text: string }> = {
        teal: { bg: 'bg-teal-50', text: 'text-teal-500' },
        blue: { bg: 'bg-blue-50', text: 'text-blue-500' },
        red: { bg: 'bg-red-50', text: 'text-red-500' },
        emerald: { bg: 'bg-emerald-50', text: 'text-emerald-500' },
        purple: { bg: 'bg-purple-50', text: 'text-purple-500' },
    };
    return colorMap[color] || colorMap.teal;
};
</script>

<template>
    <div
        v-if="open"
        class="fixed inset-0 z-50 overflow-y-auto bg-slate-950/40"
    >
        <!-- Modal Content -->
        <div class="flex items-end justify-center min-h-screen px-5 pb-8">
            <div class="w-full max-w-md rounded-3xl bg-white shadow-lg">
                <!-- Header -->
                <div class="border-b border-slate-100 px-5 py-4">
                    <div class="flex items-center justify-between">
                        <h2 class="text-xl font-semibold tracking-tight text-slate-900">Menu Rápido</h2>
                        <button
                            type="button"
                            class="flex h-10 w-10 items-center justify-center text-slate-400 hover:text-slate-600"
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
                <div class="px-5 py-5 space-y-3">
                    <Link
                        v-for="item in menuItems"
                        :key="item.label"
                        :href="item.href"
                        class="flex items-center gap-4 rounded-2xl px-4 py-4 transition hover:bg-slate-50"
                        @click="emit('close')"
                    >
                        <span :class="[getColorClasses(item.color).bg, getColorClasses(item.color).text, 'flex h-11 w-11 items-center justify-center rounded-xl flex-shrink-0']">
                            <svg v-if="item.icon === 'tag'" class="h-5 w-5" viewBox="0 0 24 24" fill="currentColor">
                                <path d="M7.5 3A4.5 4.5 0 0 0 3 7.5v9A4.5 4.5 0 0 0 7.5 21h9a4.5 4.5 0 0 0 4.5-4.5v-9A4.5 4.5 0 0 0 16.5 3h-9Z" />
                            </svg>
                            <svg v-else-if="item.icon === 'tag2'" class="h-5 w-5" viewBox="0 0 24 24" fill="currentColor">
                                <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2Z" />
                            </svg>
                            <svg v-else-if="item.icon === 'target'" class="h-5 w-5" viewBox="0 0 24 24" fill="currentColor">
                                <circle cx="12" cy="12" r="10" />
                                <circle cx="12" cy="12" r="6" fill="white" />
                                <circle cx="12" cy="12" r="2" />
                            </svg>
                            <svg v-else-if="item.icon === 'wallet'" class="h-5 w-5" viewBox="0 0 24 24" fill="currentColor">
                                <path d="M18 6H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8c0-1.1-.9-2-2-2Zm0 10h-4v-2h4v2Z" />
                            </svg>
                            <svg v-else-if="item.icon === 'card'" class="h-5 w-5" viewBox="0 0 24 24" fill="currentColor">
                                <rect x="2" y="4" width="20" height="16" rx="2" />
                                <path d="M2 9h20" fill="currentColor" />
                            </svg>
                        </span>
                        <div class="flex-1 text-sm font-semibold text-slate-900">{{ item.label }}</div>
                        <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 18l6-6-6-6" />
                        </svg>
                    </Link>
                </div>

                <!-- Logout Button -->
                <div class="border-t border-slate-100 px-5 py-5">
                    <Link
                        :href="route('logout')"
                        method="post"
                        as="button"
                        class="w-full rounded-2xl bg-red-50 px-5 py-3 text-center text-sm font-semibold text-red-500 transition hover:bg-red-100"
                    >
                        Sair da conta
                    </Link>
                </div>
            </div>
        </div>
    </div>
</template>
