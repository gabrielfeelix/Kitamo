<script setup lang="ts">
import { ref, onMounted } from 'vue';

const isVisible = ref(false);

onMounted(() => {
    // Staggered reveal for internal elements
    setTimeout(() => {
        isVisible.value = true;
    }, 100);
});
</script>

<template>
    <!-- O mockups inteiros foram substituídos pelas renders do Kitamo Studio Premium em Remotion -->
    <div 
        class="relative w-full rounded-[2.5rem] bg-slate-950/80 shadow-[0_20px_50px_rgba(0,0,0,0.5)] overflow-hidden flex transform transition-all duration-1000 ease-[cubic-bezier(0.25,1,0.5,1)] md:aspect-video aspect-[9/16] ring-1 ring-white/10" 
        :class="{ 'opacity-100 scale-100 translate-y-0': isVisible, 'opacity-0 scale-95 translate-y-12': !isVisible }"
    >
        
        <!-- Desktop Video Premium Hero Loop -->
        <video 
            src="/videos/hero-desktop.mp4" 
            autoplay 
            loop 
            muted 
            playsinline 
            class="hidden md:block w-full h-full object-cover pointer-events-none filter brightness-105 contrast-[1.05]"
        ></video>

        <!-- Mobile Video Premium Hero Loop -->
        <video 
            src="/videos/hero-mobile.mp4" 
            autoplay 
            loop 
            muted 
            playsinline 
            class="block md:hidden w-full h-full object-cover pointer-events-none filter brightness-105 contrast-[1.05]"
        ></video>

        <!-- Glass overlay lines para vender o Motion premium -->
        <div class="absolute inset-0 pointer-events-none border border-white/10 rounded-[2.5rem] shadow-[inset_0_0_20px_rgba(255,255,255,0.05)]"></div>
        <div class="absolute -top-px -left-px -right-px h-px bg-gradient-to-r from-transparent via-teal-400/50 to-transparent"></div>
    </div>
</template>
