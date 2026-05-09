import React from 'react';
import { StatusBar as RNStatusBar, View, type ViewStyle } from 'react-native';
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';

import { KITAMO } from '@/theme/tokens';

type Props = {
    children: React.ReactNode;
    bg?: string;
    barStyle?: 'dark' | 'light';
    edges?: ('top' | 'bottom' | 'left' | 'right')[];
    style?: ViewStyle;
};

export function Screen({
    children,
    bg = KITAMO.bg,
    barStyle = 'dark',
    edges = ['top', 'bottom'],
    style,
}: Props): React.JSX.Element {
    return (
        <View style={{ flex: 1, backgroundColor: bg }}>
            <RNStatusBar barStyle={barStyle === 'light' ? 'light-content' : 'dark-content'} />
            <SafeAreaView style={[{ flex: 1, backgroundColor: bg }, style]} edges={edges}>
                {children}
            </SafeAreaView>
        </View>
    );
}

export function useBottomTabPadding(): number {
    const insets = useSafeAreaInsets();
    return Math.max(insets.bottom, 12) + 76;
}
