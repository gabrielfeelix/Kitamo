<script setup lang="ts">
import { computed } from 'vue';
import { Link, router } from '@inertiajs/vue3';
import PickerSheet from '@/Components/PickerSheet.vue';

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
        tone: 'teal' as const,
    },
    {
        label: 'Tags',
        href: route('settings'),
        icon: 'tag2',
        tone: 'blue' as const,
    },
    {
        label: 'Metas',
        href: route('settings'),
        icon: 'target',
        tone: 'red' as const,
    },
    {
        label: 'Contas',
        href: route('settings'),
        icon: 'wallet',
        tone: 'emerald' as const,
    },
    {
        label: 'Cartão de Crédito',
        href: route('settings'),
        icon: 'card',
        tone: 'purple' as const,
    },
]);

const toneClass = (tone: 'teal' | 'blue' | 'red' | 'emerald' | 'purple') => {
    const toneMap = {
        teal: 'bg-teal-100 text-teal-600',
        blue: 'bg-blue-100 text-blue-600',
        red: 'bg-red-100 text-red-600',
        emerald: 'bg-emerald-100 text-emerald-600',
        purple: 'bg-purple-100 text-purple-600',
    };
    return toneMap[tone];
};

const handleSelect = (href: string) => {
    emit('close');
    router.visit(href);
};
</script>

<template>
    <PickerSheet :open="open" title="Menu Rápido" @close="emit('close')">
        <div class="grid grid-cols-2 gap-3 pb-4">
            <button
                v-for="item in menuItems"
                :key="item.label"
                type="button"
                class="flex flex-col items-center gap-3 rounded-2xl px-3 py-4 transition hover:bg-slate-50"
                @click="handleSelect(item.href)"
            >
                <span class="flex h-14 w-14 items-center justify-center rounded-full" :class="toneClass(item.tone)">
                    <svg v-if="item.icon === 'tag'" class="h-7 w-7" viewBox="0 0 24 24" fill="currentColor">
                        <path d="M7.5 3A4.5 4.5 0 0 0 3 7.5v9A4.5 4.5 0 0 0 7.5 21h9a4.5 4.5 0 0 0 4.5-4.5v-9A4.5 4.5 0 0 0 16.5 3h-9Z" />
                    </svg>
                    <svg v-else-if="item.icon === 'tag2'" class="h-7 w-7" viewBox="0 0 24 24" fill="currentColor">
                        <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2Z" />
                    </svg>
                    <svg v-else-if="item.icon === 'target'" class="h-7 w-7" viewBox="0 0 24 24" fill="currentColor">
                        <circle cx="12" cy="12" r="10" />
                        <circle cx="12" cy="12" r="6" fill="white" />
                        <circle cx="12" cy="12" r="2" />
                    </svg>
                    <svg v-else-if="item.icon === 'wallet'" class="h-7 w-7" viewBox="0 0 24 24" fill="currentColor">
                        <path d="M18 6H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8c0-1.1-.9-2-2-2Zm0 10h-4v-2h4v2Z" />
                    </svg>
                    <svg v-else-if="item.icon === 'card'" class="h-7 w-7" viewBox="0 0 24 24" fill="currentColor">
                        <rect x="2" y="4" width="20" height="16" rx="2" />
                        <path d="M2 9h20" fill="currentColor" />
                    </svg>
                </span>
                <span class="text-xs font-semibold text-slate-700 text-center">{{ item.label }}</span>
            </button>
        </div>

        <!-- Logout Button -->
        <div class="border-t border-slate-100 px-2 py-4 -mx-5">
            <Link
                :href="route('logout')"
                method="post"
                as="button"
                class="w-[calc(100%_-_2.5rem)] mx-auto block rounded-2xl bg-red-50 px-5 py-3 text-center text-sm font-semibold text-red-500 transition hover:bg-red-100"
            >
                Sair da conta
            </Link>
        </div>
    </PickerSheet>
</template>
