import { router } from 'expo-router';
import React, { useState } from 'react';
import { Alert, Pressable, ScrollView, Text, View } from 'react-native';

import { extractApiError } from '@/api/client';
import { authApi } from '@/api/endpoints';
import { Icon } from '@/components/Icon';
import { Screen } from '@/components/Screen';
import { useAuth } from '@/stores/authStore';
import { KITAMO } from '@/theme/tokens';

type Mode = 'connect' | 'manual' | 'skip';

export default function OnboardingConnect(): React.JSX.Element {
    const setSession = useAuth((s) => s.setSession);
    const token = useAuth((s) => s.token);
    const [busy, setBusy] = useState<Mode | null>(null);

    async function pick(mode: Mode): Promise<void> {
        if (busy) return;
        setBusy(mode);
        try {
            const user = await authApi.completeOnboarding({ entry_mode: mode });
            if (token) await setSession(token, user);
            router.replace('/(app)/home');
        } catch (e) {
            Alert.alert('Ops', extractApiError(e));
        } finally {
            setBusy(null);
        }
    }

    return (
        <Screen bg="#fff" edges={['top', 'bottom']}>
            <ScrollView contentContainerStyle={{ paddingBottom: 60 }}>
                <View style={{ paddingHorizontal: 24, paddingTop: 8, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
                    <Pressable onPress={() => router.back()} hitSlop={10}>
                        <Icon name="back" size={24} color={KITAMO.ink} />
                    </Pressable>
                    <View style={{ flexDirection: 'row', gap: 6 }}>
                        <View style={{ width: 8, height: 8, borderRadius: 4, backgroundColor: KITAMO.brand }} />
                        <View style={{ width: 22, height: 8, borderRadius: 4, backgroundColor: KITAMO.brand }} />
                        <View style={{ width: 8, height: 8, borderRadius: 4, backgroundColor: KITAMO.line }} />
                    </View>
                    <Text style={{ opacity: 0 }}>...</Text>
                </View>

                <View style={{ paddingHorizontal: 24, marginTop: 24 }}>
                    <Text style={{ fontSize: 28, fontWeight: '800', lineHeight: 32, color: KITAMO.ink }}>
                        Como você quer{'\n'}começar?
                    </Text>
                    <Text style={{ fontSize: 15, color: KITAMO.ink2, marginTop: 10 }}>Escolhe um jeito. Dá pra mudar depois.</Text>

                    <Pressable
                        onPress={() => pick('connect')}
                        style={({ pressed }) => ({
                            marginTop: 22,
                            padding: 20,
                            borderRadius: 18,
                            backgroundColor: KITAMO.brand,
                            opacity: busy && busy !== 'connect' ? 0.5 : pressed ? 0.9 : 1,
                            transform: [{ scale: pressed ? 0.99 : 1 }],
                            overflow: 'hidden',
                        })}
                    >
                        <View
                            style={{
                                position: 'absolute',
                                top: 14,
                                right: 14,
                                paddingHorizontal: 10,
                                paddingVertical: 4,
                                backgroundColor: 'rgba(255,255,255,0.22)',
                                borderRadius: 20,
                            }}
                        >
                            <Text style={{ color: '#fff', fontSize: 11, fontWeight: '700' }}>Mais rápido</Text>
                        </View>
                        <View
                            style={{
                                width: 46,
                                height: 46,
                                borderRadius: 14,
                                backgroundColor: 'rgba(255,255,255,0.18)',
                                alignItems: 'center',
                                justifyContent: 'center',
                            }}
                        >
                            <Icon name="bolt" size={24} color="#fff" />
                        </View>
                        <Text style={{ fontSize: 20, fontWeight: '800', color: '#fff', marginTop: 14 }}>Conectar meu banco</Text>
                        <Text style={{ fontSize: 14, color: '#fff', opacity: 0.92, marginTop: 6, lineHeight: 20 }}>
                            A gente puxa tudo automaticamente. Seguro, autorizado pelo Banco Central.
                        </Text>
                        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8, marginTop: 14 }}>
                            <Icon name="lock" size={14} color="#fff" />
                            <Text style={{ fontSize: 12, color: '#fff', opacity: 0.85 }}>Open Finance · BACEN</Text>
                        </View>
                    </Pressable>

                    <Pressable
                        onPress={() => pick('manual')}
                        style={({ pressed }) => ({
                            marginTop: 14,
                            padding: 20,
                            borderRadius: 18,
                            borderWidth: 1.5,
                            borderColor: KITAMO.line,
                            backgroundColor: '#fff',
                            opacity: busy && busy !== 'manual' ? 0.5 : pressed ? 0.95 : 1,
                            transform: [{ scale: pressed ? 0.99 : 1 }],
                        })}
                    >
                        <View
                            style={{
                                width: 46,
                                height: 46,
                                borderRadius: 14,
                                backgroundColor: KITAMO.brandSoft,
                                alignItems: 'center',
                                justifyContent: 'center',
                            }}
                        >
                            <Icon name="imp" size={24} color={KITAMO.brandDark} />
                        </View>
                        <Text style={{ fontSize: 20, fontWeight: '800', color: KITAMO.ink, marginTop: 14 }}>Lançar manual</Text>
                        <Text style={{ fontSize: 14, color: KITAMO.ink2, marginTop: 6, lineHeight: 20 }}>
                            Você adiciona suas contas e gastos do seu jeito.
                        </Text>
                    </Pressable>

                    <View style={{ alignItems: 'center', marginTop: 18 }}>
                        <Pressable onPress={() => pick('skip')} disabled={!!busy}>
                            <Text style={{ fontSize: 14, color: KITAMO.muted }}>Ainda não sei, depois eu vejo</Text>
                        </Pressable>
                    </View>
                </View>
            </ScrollView>
        </Screen>
    );
}
