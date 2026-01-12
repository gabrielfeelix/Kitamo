<script setup lang="ts">
const props = defineProps<{
    modelValue: boolean;
    disabled?: boolean;
    onColorClass?: string;
}>();

const emit = defineEmits<{
    (event: 'update:modelValue', value: boolean): void;
}>();

const toggle = () => {
    if (props.disabled) return;
    emit('update:modelValue', !props.modelValue);
};
</script>

<template>
    <button
        type="button"
        class="relative inline-flex h-6 w-11 items-center rounded-full transition"
        :class="modelValue ? (onColorClass ?? 'bg-[#14B8A6]') : 'bg-slate-200'"
        :aria-pressed="modelValue"
        :aria-disabled="disabled ? 'true' : 'false'"
        @click="toggle"
    >
        <span
            class="inline-block h-5 w-5 transform rounded-full bg-white transition"
            :class="modelValue ? 'translate-x-5' : 'translate-x-0.5'"
        ></span>
    </button>
</template>

