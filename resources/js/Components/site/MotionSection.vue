<script setup lang="ts">
import { onMounted, onUnmounted, ref } from 'vue';

const props = withDefaults(
    defineProps<{
        as?: string;
        class?: string;
        immediate?: boolean;
    }>(),
    {
        as: 'section',
        class: '',
        immediate: false,
    }
);

const visible = ref(false);
const sectionRef = ref<HTMLElement | null>(null);
let observer: IntersectionObserver | null = null;

onMounted(() => {
    const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    const isBotOrTest = typeof window !== 'undefined' && 
        (window.navigator.webdriver || /bot|googlebot|crawler|spider|robot|crawling|percy|cypress/i.test(navigator.userAgent) || '__cypress' in window || '__playwright' in window);

    if (props.immediate || reducedMotion || isBotOrTest) {
        visible.value = true;
        return;
    }

    if (!('IntersectionObserver' in window) || !sectionRef.value) {
        visible.value = true;
        return;
    }

    observer = new IntersectionObserver(
        (entries) => {
            if (entries.some((entry) => entry.isIntersecting)) {
                visible.value = true;
                observer?.disconnect();
            }
        },
        { threshold: 0.2 }
    );

    observer.observe(sectionRef.value);
});

onUnmounted(() => {
    observer?.disconnect();
});
</script>

<template>
    <component
        :is="props.as"
        ref="sectionRef"
        :class="[props.class, 'site-motion', { 'is-visible': visible }]"
    >
        <slot />
    </component>
</template>

<style scoped>
.site-motion {
    opacity: 0;
    transform: translateY(28px);
    transition:
        opacity var(--motion-slow, 480ms) var(--motion-ease, cubic-bezier(0.2, 0.8, 0.2, 1)),
        transform var(--motion-slow, 480ms) var(--motion-ease, cubic-bezier(0.2, 0.8, 0.2, 1));
}

.site-motion.is-visible {
    opacity: 1;
    transform: none;
}

@media (prefers-reduced-motion: reduce), print {
    .site-motion {
        opacity: 1 !important;
        transform: none !important;
        transition: none !important;
    }
}
</style>
