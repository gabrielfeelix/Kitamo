import { router } from 'expo-router';

import type { TabId } from '@/components/TabBar';

export function navigateToTab(id: TabId | 'add'): void {
    if (id === 'add') {
        router.push('/add');
        return;
    }
    router.replace({
        '/(app)/home': '/(app)/home',
        '/(app)/contas': '/(app)/contas',
        '/(app)/gastos': '/(app)/gastos',
        '/(app)/eu': '/(app)/eu',
    }[`/(app)/${id}`] as '/(app)/home' | '/(app)/contas' | '/(app)/gastos' | '/(app)/eu');
}
