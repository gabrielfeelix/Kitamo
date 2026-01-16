<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import KitamoLayout from '@/Layouts/KitamoLayout.vue';
import { useIsMobile } from '@/composables/useIsMobile';
import HomeWidgetsManager from '@/Components/HomeWidgetsManager.vue';

const isMobile = useIsMobile();
</script>

<template>
    <Head title="Tela inicial" />

    <MobileShell v-if="isMobile" :show-nav="false">
        <header class="relative flex items-center justify-center pt-2">
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
    </MobileShell>

    <KitamoLayout v-else title="Tela inicial" subtitle="Gerenciar seções">
        <div class="rounded-2xl bg-white p-6 shadow-sm ring-1 ring-slate-200/60">
            <div class="text-sm font-semibold text-slate-900">Abra no mobile para configurar.</div>
        </div>
    </KitamoLayout>
</template>
