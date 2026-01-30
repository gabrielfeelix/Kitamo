<script setup lang="ts">
import { ref } from 'vue';

const props = defineProps<{
    text: string;
}>();

const open = ref(false);
const show = () => (open.value = true);
const hide = () => (open.value = false);
</script>

<template>
    <span class="relative inline-flex items-center">
        <span
            class="inline-flex h-5 w-5 items-center justify-center rounded-full text-xs font-bold text-slate-400 hover:text-slate-600"
            tabindex="0"
            @mouseenter="show"
            @mouseleave="hide"
            @focus="show"
            @blur="hide"
            aria-label="Ajuda"
        >
            ?
        </span>

        <span
            v-if="open"
            class="absolute left-1/2 top-[calc(100%+10px)] z-50 w-[220px] -translate-x-1/2 rounded-md bg-slate-900 px-3 py-2 text-[12px] text-white shadow-lg"
            role="tooltip"
        >
            <span
                class="absolute left-1/2 top-[-6px] h-3 w-3 -translate-x-1/2 rotate-45 bg-slate-900"
                aria-hidden="true"
            ></span>
            {{ props.text }}
        </span>
    </span>
</template>

