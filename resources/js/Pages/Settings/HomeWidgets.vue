<script setup lang="ts">
import { computed } from 'vue';
import { Head, Link } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import { useIsMobile } from '@/composables/useIsMobile';
import HomeWidgetsManager from '@/Components/HomeWidgetsManager.vue';

const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() =>
    isMobile.value ? { showNav: false } : { title: 'Configurações', subtitle: 'Tela inicial', showSearch: false, showNewAction: false },
);
</script>

<template>
    <Head title="Tela inicial" />

    <component :is="Shell" v-bind="shellProps">
        <header v-if="isMobile" class="relative flex items-center justify-center pt-2">
            <Link
                :href="route('settings')"
                class="absolute left-0 flex h-10 w-10 items-center justify-center rounded-2xl bg-white text-slate-600 shadow-sm ring-1 ring-slate-200/60"
                aria-label="Voltar"
            >
                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M15 18l-6-6 6-6" />
                </svg>
            </Link>
            <div class="text-xl font-semibold tracking-tight text-slate-900">Tela inicial</div>
        </header>

        <div class="mt-6">
            <HomeWidgetsManager />
        </div>
    </component>
</template>
