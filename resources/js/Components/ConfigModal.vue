<script setup lang="ts">
import { computed } from 'vue';
import { router, usePage } from '@inertiajs/vue3';
import PickerSheet from '@/Components/PickerSheet.vue';

defineProps<{
    open: boolean;
}>();

const emit = defineEmits<{
    (e: 'close'): void;
}>();

const page = usePage();
const userEmail = computed(() => String((page.props as any)?.auth?.user?.email ?? '').toLowerCase());
const isAdminEmail = computed(() => userEmail.value === 'contato@kitamo.com.br');

const menuItems = computed(() => {
    const items = [
    {
        label: 'Categorias',
        href: route('settings.categories'),
        icon: 'tag',
        tone: 'teal' as const,
    },
    {
        label: 'Tags',
        href: route('settings.tags'),
        icon: 'tag2',
        tone: 'blue' as const,
    },
    {
        label: 'Metas',
        href: route('goals.index'),
        icon: 'target',
        tone: 'red' as const,
    },
    {
        label: 'Contas Bancárias',
        href: route('accounts.overview'),
        icon: 'wallet',
        tone: 'emerald' as const,
    },
    {
        label: 'Cartões de Crédito',
        href: route('credit-cards.my-cards'),
        icon: 'card',
        tone: 'purple' as const,
    },
    ] as const;

    return [
        ...(isAdminEmail.value
            ? [
                  {
                      label: 'Administração',
                      href: route('admin.index'),
                      icon: 'gear',
                      tone: 'teal' as const,
                  },
              ]
            : []),
        ...items,
    ];
});

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
        <div class="space-y-1 pb-2">
            <button
                v-for="item in menuItems"
                :key="item.label"
                type="button"
                class="flex w-full items-center gap-4 rounded-2xl px-4 py-4 transition hover:bg-slate-50"
                @click="handleSelect(item.href)"
            >
                <span class="flex h-11 w-11 flex-shrink-0 items-center justify-center rounded-xl" :class="toneClass(item.tone)">
                    <!-- Categorias Icon -->
                    <svg v-if="item.icon === 'tag'" class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M12 2H2v10l9.29 9.29c.94.94 2.48.94 3.42 0l6.58-6.58c.94-.94.94-2.48 0-3.42L12 2Z" />
                        <path d="M7 7h.01" />
                    </svg>
                    <!-- Tags Icon -->
                    <svg v-else-if="item.icon === 'tag2'" class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M9 5H2v7l6.29 6.29c.94.94 2.48.94 3.42 0l3.58-3.58c.94-.94.94-2.48 0-3.42L9 5Z" />
                        <path d="M6 9.01V9" />
                        <path d="m15 5 6.3 6.3a2.4 2.4 0 0 1 0 3.4L17 19" />
                    </svg>
                    <!-- Metas Icon (Target) -->
                    <svg v-else-if="item.icon === 'target'" class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="12" cy="12" r="10" />
                        <circle cx="12" cy="12" r="6" />
                        <circle cx="12" cy="12" r="2" />
                    </svg>
                    <!-- Contas Icon (Wallet) -->
                    <svg v-else-if="item.icon === 'wallet'" class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M21 12V7H5a2 2 0 0 1 0-4h14v4" />
                        <path d="M3 5v14a2 2 0 0 0 2 2h16v-5" />
                        <path d="M18 12a2 2 0 0 0 0 4h4v-4Z" />
                    </svg>
                    <!-- Cartão de Crédito Icon -->
                    <svg v-else-if="item.icon === 'card'" class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="2" y="5" width="20" height="14" rx="2" />
                        <line x1="2" y1="10" x2="22" y2="10" />
                    </svg>
                    <!-- Admin Icon (Gear) -->
                    <svg v-else-if="item.icon === 'gear'" class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M12 15.5A3.5 3.5 0 1 0 12 8.5a3.5 3.5 0 0 0 0 7Z" />
                        <path
                            d="M19.4 15a7.9 7.9 0 0 0 .1-1 7.9 7.9 0 0 0-.1-1l2-1.6-2-3.4-2.4 1a7.4 7.4 0 0 0-1.7-1l-.4-2.6H9.1L8.7 8a7.4 7.4 0 0 0-1.7 1l-2.4-1-2 3.4 2 1.6a7.9 7.9 0 0 0-.1 1 7.9 7.9 0 0 0 .1 1l-2 1.6 2 3.4 2.4-1a7.4 7.4 0 0 0 1.7 1l.4 2.6h5.8l.4-2.6a7.4 7.4 0 0 0 1.7-1l2.4 1 2-3.4-2-1.6Z"
                        />
                    </svg>
                </span>
                <span class="flex-1 text-left text-sm font-semibold text-slate-900">{{ item.label }}</span>
                <svg class="h-5 w-5 flex-shrink-0 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M9 18l6-6-6-6" />
                </svg>
            </button>
        </div>
    </PickerSheet>
</template>
