import { router } from 'expo-router';
import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import Svg, { Circle, Path } from 'react-native-svg';

import { Icon } from '@/components/Icon';
import { Screen } from '@/components/Screen';
import { KITAMO } from '@/theme/tokens';

export default function Onboarding(): React.JSX.Element {
    return (
        <Screen bg="#fff" edges={['top', 'bottom']}>
            <View style={{ paddingHorizontal: 24, paddingTop: 8, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
                <Pressable onPress={() => router.push('/(auth)/login')}>
                    <Text style={{ fontSize: 14, color: KITAMO.muted }}>Pular</Text>
                </Pressable>
                <View style={{ flexDirection: 'row', gap: 6 }}>
                    {[1, 1, 0].map((on, i) => (
                        <View
                            key={i}
                            style={{
                                width: on ? 22 : 8,
                                height: 8,
                                borderRadius: 4,
                                backgroundColor: on ? KITAMO.brand : KITAMO.line,
                            }}
                        />
                    ))}
                </View>
                <Text style={{ opacity: 0 }}>...</Text>
            </View>

            <View
                style={{
                    marginHorizontal: 24,
                    marginTop: 28,
                    height: 240,
                    borderRadius: 24,
                    backgroundColor: KITAMO.brandSoft,
                    overflow: 'hidden',
                }}
            >
                <Svg viewBox="0 0 300 240" width="100%" height="100%">
                    <Circle cx="150" cy="135" r="80" fill="none" stroke={KITAMO.brand} strokeWidth="3" opacity="0.5" />
                    <Circle cx="150" cy="135" r="55" fill="none" stroke={KITAMO.brand} strokeWidth="3" />
                    <Path
                        d="M120 135 L145 160 L185 115"
                        stroke={KITAMO.brandDark}
                        strokeWidth="6"
                        fill="none"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                    />
                    <Circle cx="220" cy="60" r="6" fill={KITAMO.warn} />
                    <Circle cx="60" cy="180" r="5" fill={KITAMO.brand} />
                    <Circle cx="245" cy="180" r="4" fill={KITAMO.success} />
                </Svg>
            </View>

            <View style={{ paddingHorizontal: 28, paddingTop: 30 }}>
                <Text style={{ fontSize: 30, fontWeight: '800', lineHeight: 34, color: KITAMO.ink }}>
                    Fala! {'\n'}Bora começar?
                </Text>
                <Text style={{ fontSize: 16, color: KITAMO.ink2, marginTop: 14, lineHeight: 24 }}>
                    Em 1 minuto a gente já te mostra quanto você tem e pra onde tá indo seu dinheiro.
                </Text>
            </View>

            <View style={{ position: 'absolute', left: 24, right: 24, bottom: 36 }}>
                <Pressable
                    onPress={() => router.push('/(auth)/login')}
                    style={({ pressed }) => [styles.cta, { opacity: pressed ? 0.9 : 1 }]}
                >
                    <Text style={styles.ctaText}>Bora!</Text>
                    <Icon name="arrow" size={20} color="#fff" />
                </Pressable>
            </View>
        </Screen>
    );
}

const styles = StyleSheet.create({
    cta: {
        height: 56,
        borderRadius: 16,
        backgroundColor: KITAMO.brand,
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 8,
        shadowColor: KITAMO.brand,
        shadowOffset: { width: 0, height: 6 },
        shadowOpacity: 0.4,
        shadowRadius: 16,
        elevation: 6,
    },
    ctaText: { color: '#fff', fontSize: 16, fontWeight: '700' },
});
