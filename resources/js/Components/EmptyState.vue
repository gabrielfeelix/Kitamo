<script setup lang="ts">
import { Link } from '@inertiajs/vue3';

const props = withDefaults(
    defineProps<{
        icon: string;
        title: string;
        description: string;
        ctaLabel?: string;
        ctaDisabled?: boolean;
        ctaHref?: string;
    }>(),
    {
        ctaLabel: undefined,
        ctaDisabled: false,
        ctaHref: undefined,
    },
);

const emit = defineEmits<{
    (e: 'cta'): void;
}>();
</script>

<template>
    <div class="rounded-3xl border border-dashed border-slate-200 bg-slate-50 px-6 py-16 text-center">
        <div class="mx-auto text-[96px] leading-none">{{ icon }}</div>
        <div class="mt-4 text-[18px] font-semibold text-slate-700">{{ title }}</div>
        <div class="mx-auto mt-2 max-w-[520px] text-[14px] text-slate-500">
            {{ description }}
        </div>

        <div v-if="ctaLabel" class="mt-6 flex justify-center">
            <Link
                v-if="ctaHref"
                :href="ctaHref"
                class="rounded-2xl bg-[#14B8A6] px-5 py-3 text-sm font-semibold text-white shadow-lg shadow-emerald-500/20 disabled:opacity-60"
                :class="ctaDisabled ? 'pointer-events-none opacity-60' : ''"
            >
                {{ ctaLabel }}
            </Link>
            <button
                v-else
                type="button"
                class="rounded-2xl bg-[#14B8A6] px-5 py-3 text-sm font-semibold text-white shadow-lg shadow-emerald-500/20 disabled:opacity-60"
                :disabled="ctaDisabled"
                @click="emit('cta')"
            >
                {{ ctaLabel }}
            </button>
        </div>
    </div>
</template>

