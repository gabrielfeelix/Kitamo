import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useEffect } from 'react';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { KeyboardProvider } from 'react-native-keyboard-controller';
import { SafeAreaProvider } from 'react-native-safe-area-context';

import '../global.css';

import { setUnauthorizedHandler } from '@/api/client';
import { useAuth } from '@/stores/authStore';

const queryClient = new QueryClient({
    defaultOptions: {
        queries: {
            staleTime: 30_000,
            retry: 1,
            refetchOnWindowFocus: false,
        },
    },
});

export default function RootLayout(): React.JSX.Element {
    const bootstrap = useAuth((s) => s.bootstrap);
    const logout = useAuth((s) => s.logout);

    useEffect(() => {
        void bootstrap();
        setUnauthorizedHandler(() => {
            void logout();
        });
    }, [bootstrap, logout]);

    return (
        <GestureHandlerRootView style={{ flex: 1 }}>
            <SafeAreaProvider>
                <KeyboardProvider>
                    <QueryClientProvider client={queryClient}>
                        <StatusBar style="dark" />
                        <Stack screenOptions={{ headerShown: false, contentStyle: { backgroundColor: '#F8FAFC' } }} />
                    </QueryClientProvider>
                </KeyboardProvider>
            </SafeAreaProvider>
        </GestureHandlerRootView>
    );
}
