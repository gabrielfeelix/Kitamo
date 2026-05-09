import React from 'react';
import { ActivityIndicator, Pressable, Text, type PressableProps, View } from 'react-native';

import { KITAMO, RADIUS, SHADOW } from '@/theme/tokens';

type Variant = 'primary' | 'outline' | 'ghost' | 'danger';

type Props = Omit<PressableProps, 'children' | 'style'> & {
    children: React.ReactNode;
    variant?: Variant;
    loading?: boolean;
    disabled?: boolean;
    leading?: React.ReactNode;
    trailing?: React.ReactNode;
    fullWidth?: boolean;
    height?: number;
};

export function Button({
    children,
    variant = 'primary',
    loading = false,
    disabled = false,
    leading,
    trailing,
    fullWidth = true,
    height = 56,
    onPress,
    ...rest
}: Props): React.JSX.Element {
    const palette = (() => {
        switch (variant) {
            case 'primary':
                return {
                    bg: KITAMO.brand,
                    fg: '#fff',
                    border: 'transparent',
                    shadow: SHADOW.cta,
                };
            case 'danger':
                return { bg: KITAMO.danger, fg: '#fff', border: 'transparent', shadow: SHADOW.soft };
            case 'outline':
                return {
                    bg: '#fff',
                    fg: KITAMO.ink,
                    border: KITAMO.line,
                    shadow: SHADOW.soft,
                };
            case 'ghost':
            default:
                return { bg: 'transparent', fg: KITAMO.brandDark, border: 'transparent', shadow: undefined };
        }
    })();

    return (
        <Pressable
            onPress={loading || disabled ? undefined : onPress}
            style={({ pressed }) => [
                {
                    height,
                    width: fullWidth ? '100%' : undefined,
                    paddingHorizontal: 22,
                    backgroundColor: palette.bg,
                    borderColor: palette.border,
                    borderWidth: variant === 'outline' ? 1.5 : 0,
                    borderRadius: RADIUS.lg,
                    alignItems: 'center',
                    justifyContent: 'center',
                    flexDirection: 'row',
                    opacity: disabled ? 0.5 : pressed ? 0.85 : 1,
                    transform: [{ scale: pressed ? 0.98 : 1 }],
                },
                palette.shadow,
            ]}
            {...rest}
        >
            {loading ? (
                <ActivityIndicator color={palette.fg} />
            ) : (
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
                    {leading}
                    <Text style={{ color: palette.fg, fontWeight: '700', fontSize: 16 }}>{children}</Text>
                    {trailing}
                </View>
            )}
        </Pressable>
    );
}
