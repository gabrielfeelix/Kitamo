<script setup lang="ts">
import { Head } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopSettingsShell from '@/Layouts/DesktopSettingsShell.vue';
import ToggleSwitch from '@/Components/ToggleSwitch.vue';
import { useMediaQuery } from '@/composables/useMediaQuery';
import { computed, ref, watch } from 'vue';
import { usePage } from '@inertiajs/vue3';
import axios from 'axios';

const isMobile = useMediaQuery('(max-width: 767px)');
const page = usePage<any>();
const darkMode = ref(false);
const brl = ref(true);

const userTheme = computed(() => page.props.auth?.user?.theme ?? 'light');

watch(
    userTheme,
    (theme) => {
        darkMode.value = theme === 'dark';
        const resolved = darkMode.value ? 'dark' : 'light';
        document.documentElement.setAttribute('data-theme', resolved);
        localStorage.setItem('theme', resolved);
    },
    { immediate: true },
);

watch(darkMode, async (enabled, old) => {
    if (enabled === old) return;
    const next = enabled ? 'dark' : 'light';
    document.documentElement.setAttribute('data-theme', next);
    localStorage.setItem('theme', next);

    try {
        await axios.patch('/api/user/theme', { theme: next });
    } catch {
        const fallback = old ? 'dark' : 'light';
        darkMode.value = old;
        document.documentElement.setAttribute('data-theme', fallback);
        localStorage.setItem('theme', fallback);
    }
});
</script>

<template>
    <Head title="Aparência & Moeda" />

    <MobileShell v-if="isMobile" :show-nav="false">
        <div class="rounded-3xl bg-white p-6 shadow-sm ring-1 ring-slate-200/60">
            <div class="text-sm font-semibold text-slate-900">Aparência & Moeda</div>
            <div class="mt-2 text-sm text-slate-500">Ainda vamos definir essa tela no mobile.</div>
        </div>
    </MobileShell>

    <DesktopSettingsShell v-else>
        <div class="rounded-3xl bg-white px-10 py-9 shadow-sm ring-1 ring-slate-200/60">
            <div class="text-[11px] font-bold uppercase tracking-wide text-slate-300">Aparência</div>
            <div class="mt-5 space-y-4">
                <div class="flex items-center justify-between gap-6 rounded-2xl bg-slate-50 px-6 py-5 ring-1 ring-slate-200/60">
                    <div>
                        <div class="text-sm font-semibold text-slate-900">Tema escuro</div>
                        <div class="mt-1 text-xs font-semibold text-slate-400">Ativar modo escuro no painel</div>
                    </div>
                    <ToggleSwitch v-model="darkMode" />
                </div>
            </div>

            <div class="mt-10 text-[11px] font-bold uppercase tracking-wide text-slate-300">Moeda</div>
            <div class="mt-5 space-y-4">
                <div class="flex items-center justify-between gap-6 rounded-2xl bg-slate-50 px-6 py-5 ring-1 ring-slate-200/60">
                    <div>
                        <div class="text-sm font-semibold text-slate-900">BRL (R$)</div>
                        <div class="mt-1 text-xs font-semibold text-slate-400">Formato pt-BR</div>
                    </div>
                    <ToggleSwitch v-model="brl" />
                </div>
            </div>
        </div>
    </DesktopSettingsShell>
</template>
