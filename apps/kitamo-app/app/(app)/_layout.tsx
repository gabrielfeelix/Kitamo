import { Redirect, Stack } from 'expo-router';
import React from 'react';

import { useAuth } from '@/stores/authStore';

export default function AppLayout(): React.JSX.Element {
    const token = useAuth((s) => s.token);
    const bootstrapped = useAuth((s) => s.bootstrapped);

    if (bootstrapped && !token) {
        return <Redirect href="/(auth)/onboarding" />;
    }

    return (
        <Stack
            screenOptions={{
                headerShown: false,
                contentStyle: { backgroundColor: '#F8FAFC' },
            }}
        />
    );
}
