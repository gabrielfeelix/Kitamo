import { onMounted, onUnmounted, ref } from 'vue';

export function useInertiaGetLoading() {
    const loading = ref(false);
    let pending = 0;

    const onStart = (event: Event) => {
        const detail: any = (event as any).detail;
        const method = String(detail?.visit?.method ?? '').toLowerCase();
        if (method !== 'get') return;
        pending += 1;
        loading.value = true;
    };

    const onFinish = (event: Event) => {
        const detail: any = (event as any).detail;
        const method = String(detail?.visit?.method ?? '').toLowerCase();
        if (method !== 'get') return;
        pending = Math.max(0, pending - 1);
        loading.value = pending > 0;
    };

    onMounted(() => {
        document.addEventListener('inertia:start', onStart as any);
        document.addEventListener('inertia:finish', onFinish as any);
    });

    onUnmounted(() => {
        document.removeEventListener('inertia:start', onStart as any);
        document.removeEventListener('inertia:finish', onFinish as any);
    });

    return { loading };
}

