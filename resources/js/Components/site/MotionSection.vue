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
        { threshold: 0.15 }
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
        :class="[props.class, 'site-motion-wrap']"
    >
        <!-- Inner wrapper that actually animates — background stays visible -->
        <div :class="['site-motion-inner', { 'is-visible': visible }]">
            <slot />
        </div>
    </component>
</template>

<style scoped>
/* The outer wrapper (section) keeps its background always visible — NO opacity/transform */
.site-motion-wrap {
    /* Intentionally no opacity or transform — background always renders */
}

/* Only the inner content fades in + slides up */
.site-motion-inner {
    opacity: 0;
    transform: translateY(28px);
    transition:
        opacity var(--motion-slow, 480ms) var(--motion-ease, cubic-bezier(0.2, 0.8, 0.2, 1)),
        transform var(--motion-slow, 480ms) var(--motion-ease, cubic-bezier(0.2, 0.8, 0.2, 1));
}

.site-motion-inner.is-visible {
    opacity: 1;
    transform: none;
}

@media (prefers-reduced-motion: reduce), print {
    .site-motion-inner {
        opacity: 1 !important;
        transform: none !important;
        transition: none !important;
    }
}
</style>
