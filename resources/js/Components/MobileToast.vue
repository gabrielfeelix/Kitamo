<script setup lang="ts">
import { watch } from 'vue';

const props = defineProps<{
    show: boolean;
    message: string;
}>();

const emit = defineEmits<{
    (event: 'dismiss'): void;
}>();

watch(
    () => props.show,
    (isOpen) => {
        if (!isOpen) return;
        const timer = window.setTimeout(() => emit('dismiss'), 2200);
        return () => window.clearTimeout(timer);
    },
);
</script>

<template>
    <transition
        enter-active-class="transition duration-200 ease-out"
        enter-from-class="translate-y-2 opacity-0"
        enter-to-class="translate-y-0 opacity-100"
        leave-active-class="transition duration-150 ease-in"
        leave-from-class="translate-y-0 opacity-100"
        leave-to-class="translate-y-2 opacity-0"
    >
        <div
            v-if="show"
            class="fixed inset-x-5 bottom-[calc(5.5rem+env(safe-area-inset-bottom)+1rem)] z-[80] rounded-2xl bg-slate-900 px-4 py-3 shadow-2xl"
            role="status"
            aria-live="polite"
        >
            <div class="flex items-center gap-3">
                <span class="flex h-8 w-8 items-center justify-center rounded-full bg-emerald-500 text-white">
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M20 6 9 17l-5-5" />
                    </svg>
                </span>
                <div class="text-sm font-semibold text-white">{{ message }}</div>
            </div>
        </div>
    </transition>
</template>

