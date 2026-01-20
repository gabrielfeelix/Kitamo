<script setup lang="ts">
const props = defineProps<{
    icon: string;
    class?: string;
}>();
</script>

<template>
    <!-- Food icon -->
    <svg v-if="icon === 'food'" :class="props.class || 'h-6 w-6'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M4 3v7" />
        <path d="M8 3v7" />
        <path d="M6 3v7" />
        <path d="M14 3v7c0 2 1 3 3 3v8" />
        <path d="M20 3v7" />
    </svg>

    <!-- Home icon -->
    <svg v-else-if="icon === 'home'" :class="props.class || 'h-6 w-6'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M3 10.5L12 3l9 7.5" />
        <path d="M5 10v10h14V10" />
    </svg>

    <!-- Car icon -->
    <svg v-else-if="icon === 'car'" :class="props.class || 'h-6 w-6'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M5 16l1-5 1-3h10l1 3 1 5" />
        <path d="M7 16h10" />
        <circle cx="8" cy="17" r="1.5" />
        <circle cx="16" cy="17" r="1.5" />
    </svg>

    <!-- Pill icon -->
    <svg v-else-if="icon === 'pill'" :class="props.class || 'h-6 w-6'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M10 14 8 16a4 4 0 0 1-6-6l2-2a4 4 0 0 1 6 6Z" />
        <path d="M14 10l2-2a4 4 0 0 1 6 6l-2 2a4 4 0 0 1-6-6Z" />
        <path d="M8 16l8-8" />
    </svg>

    <!-- Briefcase icon -->
    <svg v-else-if="icon === 'briefcase'" :class="props.class || 'h-6 w-6'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <rect x="3" y="7" width="18" height="13" rx="3" />
        <path d="M9 7V5a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2v2" />
        <path d="M3 12h18" />
    </svg>

    <!-- Heart icon -->
    <svg v-else-if="icon === 'heart'" :class="props.class || 'h-6 w-6'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M20 8c0 5-8 10-8 10S4 13 4 8a4 4 0 0 1 8 0 4 4 0 0 1 8 0Z" />
    </svg>

    <!-- Shirt icon -->
    <svg v-else-if="icon === 'shirt'" :class="props.class || 'h-6 w-6'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M15 3H9l-2 4h10l-2-4Z" />
        <path d="M7 7v14" />
        <path d="M17 7v14" />
    </svg>

    <!-- Bolt/Energy icon -->
    <svg v-else-if="icon === 'bolt'" :class="props.class || 'h-6 w-6'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M13 2 3 14h8l-1 8 10-12h-8l1-8Z" />
    </svg>

    <!-- Other/default icon -->
    <svg v-else :class="props.class || 'h-6 w-6'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <rect x="3" y="3" width="18" height="18" rx="4" />
        <path d="M8 12h8" />
    </svg>
</template>
