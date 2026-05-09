import { Redirect } from 'expo-router';
import React from 'react';
import { View } from 'react-native';

import { KitamoLogo } from '@/components/Logo';
import { useAuth } from '@/stores/authStore';
import { KITAMO } from '@/theme/tokens';

export default function Index(): React.JSX.Element {
    const bootstrapped = useAuth((s) => s.bootstrapped);
    const token = useAuth((s) => s.token);
    const user = useAuth((s) => s.user);

    if (!bootstrapped) {
        return (
            <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center', backgroundColor: KITAMO.brand }}>
                <KitamoLogo size={84} color="#fff" />
            </View>
        );
    }

    if (!token) {
        return <Redirect href="/(auth)/onboarding" />;
    }

    if (!user?.onboarding_completed_at) {
        return <Redirect href="/(auth)/onboarding-connect" />;
    }

    return <Redirect href="/(app)/home" />;
}
