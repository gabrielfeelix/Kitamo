<script setup lang="ts">
const props = defineProps<{
    type?: 'bank' | 'wallet' | 'credit_card';
    icon?: string;
    class?: string;
}>();
</script>

<template>
    <!-- Wallet icon -->
    <svg v-if="type === 'wallet' || icon === 'wallet'" :class="props.class || 'h-6 w-6'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M4 7h16v12H4z" />
        <path d="M4 7V5h12v2" />
        <path d="M16 12h4" />
    </svg>

    <!-- Credit card icon -->
    <svg v-else-if="type === 'credit_card' || icon === 'credit-card' || icon === 'credit_card'" :class="props.class || 'h-6 w-6'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <rect x="3" y="5" width="18" height="14" rx="3" />
        <path d="M3 10h18" />
    </svg>

    <!-- Bank icon (default) -->
    <svg v-else :class="props.class || 'h-6 w-6'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M3 10h18" />
        <path d="M5 10V8l7-5 7 5v2" />
        <path d="M6 10v9" />
        <path d="M18 10v9" />
    </svg>
</template>
