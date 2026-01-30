<script setup lang="ts">
import { onMounted, onUnmounted, ref } from 'vue';

const visible = ref(false);
let ticking = false;

const update = () => {
    visible.value = (window.scrollY || 0) > 400;
};

const onScroll = () => {
    if (ticking) return;
    ticking = true;
    requestAnimationFrame(() => {
        update();
        ticking = false;
    });
};

const scrollToTop = () => {
    try {
        window.scrollTo({ top: 0, behavior: 'smooth' });
    } catch {
        window.scrollTo(0, 0);
    }
};

onMounted(() => {
    update();
    window.addEventListener('scroll', onScroll, { passive: true });
});

onUnmounted(() => {
    window.removeEventListener('scroll', onScroll);
});
</script>

<template>
    <button
        type="button"
        class="fixed bottom-6 right-6 z-[90] flex h-12 w-12 items-center justify-center rounded-full bg-[#14B8A6] text-white shadow-[0_4px_12px_rgba(0,0,0,0.15)] transition duration-200 hover:scale-110 hover:shadow-[0_6px_16px_rgba(0,0,0,0.18)]"
        :class="visible ? 'opacity-100' : 'pointer-events-none opacity-0'"
        aria-label="Voltar ao topo"
        @click="scrollToTop"
    >
        ↑
    </button>
</template>

