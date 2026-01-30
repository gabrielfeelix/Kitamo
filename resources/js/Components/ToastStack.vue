<script setup lang="ts">
import { computed, watch } from 'vue';
import { usePage } from '@inertiajs/vue3';
import { toasts, type Toast } from '@/lib/toasts';

const page = usePage();

const items = computed(() => toasts.state.items);

const tone = (t: Toast) => {
    if (t.type === 'success') return 'bg-emerald-500 text-white';
    if (t.type === 'info') return 'bg-blue-500 text-white';
    return 'bg-red-500 text-white';
};

let lastErrorKey = '';
let lastFlashKey = '';

watch(
    () => (page.props as any)?.flash,
    (flash) => {
        const msg = flash?.success ?? flash?.error ?? flash?.info ?? null;
        const type = flash?.success ? 'success' : flash?.error ? 'error' : flash?.info ? 'info' : null;
        if (!msg || !type) return;
        const key = `${type}:${String(msg)}`;
        if (key === lastFlashKey) return;
        lastFlashKey = key;
        if (type === 'success') toasts.success(String(msg));
        else if (type === 'info') toasts.info(String(msg));
        else toasts.error(String(msg));
    },
    { immediate: true },
);

watch(
    () => (page.props as any)?.errors,
    (errors) => {
        const msg = errors?.default;
        if (!msg) return;
        const key = String(msg);
        if (key === lastErrorKey) return;
        lastErrorKey = key;
        toasts.error(String(msg));
    },
    { immediate: true },
);
</script>

<template>
    <div class="pointer-events-none fixed inset-x-0 bottom-6 z-[100] flex justify-center">
        <div class="pointer-events-auto flex w-full max-w-md flex-col items-center gap-2 px-4">
            <div
                v-for="t in items"
                :key="t.id"
                class="flex w-full items-center justify-between gap-3 rounded-2xl px-4 py-3 text-sm font-semibold shadow-lg"
                :class="tone(t)"
            >
                <div class="min-w-0 truncate">
                    <span v-if="t.type === 'success'">✅</span>
                    <span v-else-if="t.type === 'info'">ℹ️</span>
                    <span v-else>❌</span>
                    <span class="ml-2">{{ t.message }}</span>
                </div>
                <button
                    v-if="t.dismissible"
                    type="button"
                    class="ml-2 rounded-xl bg-white/15 px-2 py-1 text-xs font-bold text-white hover:bg-white/20"
                    aria-label="Fechar"
                    @click="toasts.remove(t.id)"
                >
                    ✕
                </button>
            </div>
        </div>
    </div>
</template>
