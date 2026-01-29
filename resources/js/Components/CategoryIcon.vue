<script setup lang="ts">
import { computed } from 'vue';

const props = defineProps<{
    icon: string | null | undefined;
    class?: string;
}>();

const normalizedIcon = computed(() => {
    return (props.icon ?? '').toString().toLowerCase().trim();
});
</script>

<template>
    <!-- Food icon -->
    <svg v-if="normalizedIcon === 'food'" :class="props.class || 'h-6 w-6'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M4 3v7" />
        <path d="M8 3v7" />
        <path d="M6 3v7" />
        <path d="M14 3v7c0 2 1 3 3 3v8" />
        <path d="M20 3v7" />
    </svg>

    <!-- Home icon -->
    <svg v-else-if="normalizedIcon === 'home'" :class="props.class || 'h-6 w-6'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M3 10.5L12 3l9 7.5" />
        <path d="M5 10v10h14V10" />
    </svg>

    <!-- Car icon -->
    <svg v-else-if="normalizedIcon === 'car'" :class="props.class || 'h-6 w-6'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M5 16l1-5 1-3h10l1 3 1 5" />
        <path d="M7 16h10" />
        <circle cx="8" cy="17" r="1.5" />
        <circle cx="16" cy="17" r="1.5" />
    </svg>

    <!-- Cart/Shopping icon -->
    <svg v-else-if="normalizedIcon === 'cart'" :class="props.class || 'h-6 w-6'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M6 6h15l-2 7H7L6 6Z" />
        <path d="M6 6l-2-2H2" />
        <circle cx="9" cy="18" r="1.5" />
        <circle cx="17" cy="18" r="1.5" />
    </svg>

    <!-- Gym/Fitness icon -->
    <svg v-else-if="normalizedIcon === 'gym'" :class="props.class || 'h-6 w-6'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M6 8v8" />
        <path d="M18 8v8" />
        <path d="M8 10h8" />
        <path d="M8 14h8" />
        <path d="M4 10v4" />
        <path d="M20 10v4" />
    </svg>

    <!-- Game icon -->
    <svg v-else-if="normalizedIcon === 'game'" :class="props.class || 'h-6 w-6'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M6 7h12a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V9a2 2 0 0 1 2-2Z" />
        <path d="M8 13h2" />
        <path d="M9 12v2" />
        <path d="M15 13h2" />
    </svg>

    <!-- Pill icon -->
    <svg v-else-if="normalizedIcon === 'pill'" :class="props.class || 'h-6 w-6'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M10 14 8 16a4 4 0 0 1-6-6l2-2a4 4 0 0 1 6 6Z" />
        <path d="M14 10l2-2a4 4 0 0 1 6 6l-2 2a4 4 0 0 1-6-6Z" />
        <path d="M8 16l8-8" />
    </svg>

    <!-- Briefcase icon -->
    <svg v-else-if="normalizedIcon === 'briefcase'" :class="props.class || 'h-6 w-6'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <rect x="3" y="7" width="18" height="13" rx="3" />
        <path d="M9 7V5a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2v2" />
        <path d="M3 12h18" />
    </svg>

    <!-- Heart icon -->
    <svg v-else-if="normalizedIcon === 'heart'" :class="props.class || 'h-6 w-6'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M20 8c0 5-8 10-8 10S4 13 4 8a4 4 0 0 1 8 0 4 4 0 0 1 8 0Z" />
    </svg>

    <!-- Shirt icon -->
    <svg v-else-if="normalizedIcon === 'shirt'" :class="props.class || 'h-6 w-6'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M15 3H9l-2 4h10l-2-4Z" />
        <path d="M7 7v14" />
        <path d="M17 7v14" />
    </svg>

    <!-- Bolt/Energy icon -->
    <svg v-else-if="normalizedIcon === 'bolt'" :class="props.class || 'h-6 w-6'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M13 2 3 14h8l-1 8 10-12h-8l1-8Z" />
    </svg>

    <!-- Money icon -->
    <svg v-else-if="normalizedIcon === 'money'" :class="props.class || 'h-6 w-6'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <rect x="3" y="6" width="18" height="12" rx="2" />
        <path d="M7 10h0" />
        <path d="M17 14h0" />
        <path d="M12 10a2 2 0 1 0 0 4a2 2 0 1 0 0-4" />
    </svg>

    <!-- Trend icon -->
    <svg v-else-if="normalizedIcon === 'trend'" :class="props.class || 'h-6 w-6'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M3 17l6-6 4 4 8-8" />
        <path d="M17 7h4v4" />
    </svg>

    <!-- Sparkles icon -->
    <svg v-else-if="normalizedIcon === 'sparkles'" :class="props.class || 'h-6 w-6'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M12 2l1.6 5.2L19 9l-5.4 1.8L12 16l-1.6-5.2L5 9l5.4-1.8L12 2Z" />
    </svg>

    <!-- Other/default icon -->
    <svg v-else :class="props.class || 'h-6 w-6'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <rect x="3" y="3" width="18" height="18" rx="4" />
        <path d="M8 12h8" />
    </svg>
</template>
