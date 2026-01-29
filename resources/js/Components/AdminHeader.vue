<script setup lang="ts">
import { computed } from 'vue';
import { Link } from '@inertiajs/vue3';
import AdminNav from '@/Components/AdminNav.vue';
import { useIsMobile } from '@/composables/useIsMobile';

const props = withDefaults(
    defineProps<{
        title?: string;
        description?: string;
    }>(),
    {
        title: 'Administração',
        description: '',
    },
);

const isMobile = useIsMobile();
const currentTitle = computed(() => props.title || 'Administração');
</script>

<template>
    <div class="rounded-3xl bg-white p-6 shadow-sm ring-1 ring-slate-200/60">
        <div v-if="isMobile" class="mb-4 flex items-center justify-between">
            <Link
                :href="route('dashboard')"
                class="inline-flex items-center gap-2 rounded-2xl bg-slate-50 px-3 py-2 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60"
                aria-label="Voltar para início"
            >
                <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M15 18l-6-6 6-6" />
                </svg>
                Início
            </Link>
            <div class="text-sm font-semibold text-slate-900">{{ currentTitle }}</div>
            <Link
                :href="route('dashboard')"
                class="inline-flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-50 text-slate-600 ring-1 ring-slate-200/60"
                aria-label="Ir para início"
            >
                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M3 10.5L12 3l9 7.5" />
                    <path d="M5 10v10h14V10" />
                </svg>
            </Link>
        </div>
        <div class="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
            <div>
                <div class="text-xl font-semibold text-slate-900">{{ props.title }}</div>
                <p v-if="props.description" class="mt-2 text-sm text-slate-500">{{ props.description }}</p>
            </div>
            <div class="md:max-w-[720px] md:justify-end">
                <AdminNav />
            </div>
        </div>
    </div>
</template>
