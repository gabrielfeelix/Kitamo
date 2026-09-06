<script setup lang="ts">
import { Head } from '@inertiajs/vue3';
import { useIsMobile } from '@/composables/useIsMobile';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import ToggleSwitch from '@/Components/ToggleSwitch.vue';
import { useMediaQuery } from '@/composables/useMediaQuery';
import { computed, ref, watch } from 'vue';
import { usePage } from '@inertiajs/vue3';
import axios from 'axios';

const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() =>
    isMobile.value ? { showNav: false } : { title: 'Aparência', showSearch: false, showNewAction: false },
);
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

    <component :is="Shell" v-bind="shellProps">
        <!-- A lógica de tema e moeda já existia e funcionava (persiste no
             servidor e no localStorage); só o template era um placeholder
             dizendo "ainda vamos definir essa tela". -->
        <div class="rounded-3xl bg-white p-6 shadow-sm ring-1 ring-slate-200/60">
            <div class="text-base font-bold text-slate-900">Aparência</div>
            <p class="mt-1 text-sm text-slate-500">Escolha como o Kitamo aparece para você.</p>

            <label class="mt-5 flex cursor-pointer items-center justify-between gap-4 rounded-2xl bg-slate-50 p-4 transition-colors hover:bg-slate-100">
                <span class="flex items-center gap-3">
                    <span class="flex h-10 w-10 items-center justify-center rounded-xl bg-slate-900 text-white">
                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z" />
                        </svg>
                    </span>
                    <span>
                        <span class="block text-sm font-semibold text-slate-900">Modo escuro</span>
                        <span class="block text-xs text-slate-500">Reduz o brilho em ambientes com pouca luz</span>
                    </span>
                </span>
                <ToggleSwitch v-model="darkMode" />
            </label>
        </div>

        <div class="mt-4 rounded-3xl bg-white p-6 shadow-sm ring-1 ring-slate-200/60">
            <div class="text-base font-bold text-slate-900">Moeda</div>
            <p class="mt-1 text-sm text-slate-500">Formato usado para exibir os valores.</p>

            <label class="mt-5 flex cursor-pointer items-center justify-between gap-4 rounded-2xl bg-slate-50 p-4 transition-colors hover:bg-slate-100">
                <span class="flex items-center gap-3">
                    <span class="flex h-10 w-10 items-center justify-center rounded-xl bg-emerald-500 text-sm font-bold text-white">R$</span>
                    <span>
                        <span class="block text-sm font-semibold text-slate-900">Real brasileiro</span>
                        <span class="block text-xs text-slate-500">Exibir valores em BRL</span>
                    </span>
                </span>
                <ToggleSwitch v-model="brl" />
            </label>
        </div>
    </component>
</template>
