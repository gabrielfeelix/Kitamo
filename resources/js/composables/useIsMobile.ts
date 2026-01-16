import { useMediaQuery } from '@/composables/useMediaQuery';

// Mobile sempre. Tablet: retrato => mobile, paisagem => desktop.
export const useIsMobile = () =>
    useMediaQuery('(max-width: 767px), (min-width: 768px) and (max-width: 1024px) and (orientation: portrait)');

