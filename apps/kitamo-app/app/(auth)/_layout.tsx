import { Stack } from 'expo-router';
import React from 'react';

export default function AuthLayout(): React.JSX.Element {
    return (
        <Stack
            screenOptions={{
                headerShown: false,
                contentStyle: { backgroundColor: '#FFFFFF' },
                animation: 'slide_from_right',
            }}
        />
    );
}
