import { onBeforeUnmount, onMounted, ref } from 'vue';

export function useMediaQuery(query: string) {
    const matches = ref(false);
    let mql: MediaQueryList | null = null;

    const update = () => {
        if (typeof window === 'undefined') return;
        matches.value = window.matchMedia(query).matches;
    };
    const handler = () => update();

    onMounted(() => {
        update();
        mql = window.matchMedia(query);

        if (typeof mql.addEventListener === 'function') {
            mql.addEventListener('change', handler);
        } else {
            // Safari < 14
            mql.addListener(handler);
        }
    });

    onBeforeUnmount(() => {
        if (!mql) return;

        if (typeof mql.removeEventListener === 'function') {
            mql.removeEventListener('change', handler);
        } else {
            mql.removeListener(handler);
        }
        mql = null;
    });

    if (typeof window !== 'undefined') {
        matches.value = window.matchMedia(query).matches;
    }

    return matches;
}
