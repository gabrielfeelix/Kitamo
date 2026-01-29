<script setup lang="ts">
import { computed } from 'vue';
import { Head } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import { useIsMobile } from '@/composables/useIsMobile';
import AdminNav from '@/Components/AdminNav.vue';

const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() => (isMobile.value ? { showNav: false } : { title: 'Administração', showSearch: false, showNewAction: false }));
</script>

<template>
    <Head title="Administração · E-mails" />

    <component :is="Shell" v-bind="shellProps">
        <div class="space-y-4">
            <div class="rounded-3xl bg-white p-6 shadow-sm ring-1 ring-slate-200/60">
                <div class="text-xl font-semibold text-slate-900">Administração</div>
                <p class="mt-2 text-sm text-slate-500">E-mails e comunicados (em breve).</p>
                <div class="mt-5">
                    <AdminNav />
                </div>
            </div>
        </div>
    </component>
</template>

