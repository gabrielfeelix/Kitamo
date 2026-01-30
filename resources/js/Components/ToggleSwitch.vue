<script setup lang="ts">
import { computed } from 'vue';

const props = defineProps<{
    modelValue: boolean;
    disabled?: boolean;
    label?: string;
}>();

const emit = defineEmits<{
    (event: 'update:modelValue', value: boolean): void;
}>();

const ariaLabel = computed(() => {
    if (!props.label) return undefined;
    return props.modelValue ? `Desativar ${props.label}` : `Ativar ${props.label}`;
});

const toggle = () => {
    if (props.disabled) return;
    emit('update:modelValue', !props.modelValue);
};
</script>

<template>
    <button
        type="button"
        class="relative inline-flex h-6 w-11 items-center rounded-full transition duration-200 focus:outline-none focus:ring-2 focus:ring-[#14B8A6] focus:ring-offset-2"
        :class="modelValue ? 'bg-emerald-500' : 'bg-slate-200'"
        :aria-pressed="modelValue"
        :aria-disabled="disabled ? 'true' : 'false'"
        :aria-label="ariaLabel"
        :disabled="disabled"
        @click="toggle"
    >
        <span
            class="relative inline-flex h-5 w-5 transform items-center justify-center rounded-full transition duration-200"
            :class="[
                modelValue ? 'translate-x-5 bg-white' : 'translate-x-0.5 bg-slate-500',
            ]"
        >
            <span v-if="modelValue" class="text-[11px] font-bold leading-none text-emerald-600" aria-hidden="true">✓</span>
        </span>
    </button>
</template>
