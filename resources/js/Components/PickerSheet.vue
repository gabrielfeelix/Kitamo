<script setup lang="ts">
import { computed } from 'vue';

const props = defineProps<{
    open: boolean;
    title: string;
}>();

const emit = defineEmits<{
    (e: 'close'): void;
}>();

const titleId = computed(() => `sheet-title-${props.title.replace(/\s+/g, '-').toLowerCase()}`);
</script>

<template>
    <Teleport to="body">
        <Transition
            enter-active-class="transition duration-200"
            enter-from-class="opacity-0"
            enter-to-class="opacity-100"
            leave-active-class="transition duration-150"
            leave-from-class="opacity-100"
            leave-to-class="opacity-0"
        >
            <div v-if="open" class="fixed inset-0 z-[85]">
                <button class="absolute inset-0 bg-black/40 backdrop-blur-sm" type="button" @click="emit('close')" aria-label="Fechar"></button>

                <Transition
                    enter-active-class="transition duration-250 ease-out"
                    enter-from-class="translate-y-8 opacity-0"
                    enter-to-class="translate-y-0 opacity-100"
                    leave-active-class="transition duration-150 ease-in"
                    leave-from-class="translate-y-0 opacity-100"
                    leave-to-class="translate-y-8 opacity-0"
                >
                    <section
                        v-if="open"
                        class="absolute inset-x-0 bottom-0 mx-auto w-full max-w-md rounded-t-[28px] bg-white px-5 pb-[calc(18px+env(safe-area-inset-bottom))] pt-3 shadow-[0_-18px_60px_-40px_rgba(15,23,42,0.55)]"
                        role="dialog"
                        aria-modal="true"
                        :aria-labelledby="titleId"
                    >
                        <div class="mx-auto h-1.5 w-12 rounded-full bg-slate-200"></div>

                        <div class="relative mt-4 flex items-center justify-center">
                            <h2 :id="titleId" class="text-lg font-semibold text-slate-900">{{ title }}</h2>
                            <button
                                type="button"
                                class="absolute right-0 flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-50 text-slate-500"
                                aria-label="Fechar"
                                @click="emit('close')"
                            >
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M18 6L6 18" />
                                    <path d="M6 6l12 12" />
                                </svg>
                            </button>
                        </div>

                        <div class="mt-6">
                            <slot />
                        </div>
                    </section>
                </Transition>
            </div>
        </Transition>
    </Teleport>
</template>

