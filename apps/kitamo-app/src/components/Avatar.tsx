import React from 'react';
import { Text, View } from 'react-native';

import { Icon, type IconName } from '@/components/Icon';
import { KITAMO } from '@/theme/tokens';

type BankAvatarProps = {
    name: string;
    color?: string;
    size?: number;
};

export function BankAvatar({ name, color = KITAMO.brand, size = 40 }: BankAvatarProps): React.JSX.Element {
    const initial = (name?.[0] ?? '?').toUpperCase();
    return (
        <View
            style={{
                width: size,
                height: size,
                borderRadius: size / 2,
                backgroundColor: color,
                alignItems: 'center',
                justifyContent: 'center',
            }}
        >
            <Text style={{ color: '#fff', fontSize: size * 0.42, fontWeight: '700' }}>{initial}</Text>
        </View>
    );
}

type CatIconProps = {
    name: IconName;
    color?: string;
    size?: number;
};

export function CatIcon({ name, color = KITAMO.muted, size = 40 }: CatIconProps): React.JSX.Element {
    const iconSize = Math.round(size * 0.5);
    return (
        <View
            style={{
                width: size,
                height: size,
                borderRadius: size / 2.6,
                backgroundColor: hexAlpha(color, 0.13),
                alignItems: 'center',
                justifyContent: 'center',
            }}
        >
            <Icon name={name} size={iconSize} color={color} />
        </View>
    );
}

export function hexAlpha(hex: string, alpha: number): string {
    const h = hex.replace('#', '');
    const a = Math.round(Math.min(Math.max(alpha, 0), 1) * 255)
        .toString(16)
        .padStart(2, '0');
    return `#${h}${a}`;
}
