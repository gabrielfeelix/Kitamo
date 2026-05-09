import { useQuery } from '@tanstack/react-query';
import { router } from 'expo-router';
import React from 'react';
import { ActivityIndicator, Pressable, ScrollView, Text, View } from 'react-native';

import { aiApi } from '@/api/endpoints';
import { Icon, type IconName } from '@/components/Icon';
import { Screen } from '@/components/Screen';
import { KITAMO } from '@/theme/tokens';

export default function IA(): React.JSX.Element {
    const tips = useQuery({
        queryKey: ['ai-tips'],
        queryFn: () => aiApi.tips(),
        staleTime: 5 * 60_000,
    });

    return (
        <Screen bg={KITAMO.bg} barStyle="light" edges={['top']}>
            <View style={{ position: 'absolute', top: 0, left: 0, right: 0, height: 230, backgroundColor: KITAMO.brand, borderBottomLeftRadius: 28, borderBottomRightRadius: 28 }} />

            <ScrollView contentContainerStyle={{ paddingBottom: 60 }} showsVerticalScrollIndicator={false}>
                <View style={{ paddingHorizontal: 16, paddingTop: 8, flexDirection: 'row', alignItems: 'center', gap: 8 }}>
                    <Pressable
                        onPress={() => router.back()}
                        style={{ width: 36, height: 36, borderRadius: 18, backgroundColor: 'rgba(255,255,255,0.2)', alignItems: 'center', justifyContent: 'center' }}
                    >
                        <Icon name="back" size={18} color="#fff" />
                    </Pressable>
                    <Text style={{ flex: 1, fontSize: 15, fontWeight: '700', color: '#fff', textAlign: 'center', marginRight: 36 }}>Kitamo IA</Text>
                </View>

                <View style={{ paddingHorizontal: 24, paddingTop: 24, flexDirection: 'row', alignItems: 'center', gap: 14 }}>
                    <View style={{ width: 60, height: 60, borderRadius: 30, backgroundColor: '#fff', alignItems: 'center', justifyContent: 'center' }}>
                        <Icon name="bot" size={32} color={KITAMO.brandDark} />
                    </View>
                    <View>
                        <Text style={{ fontSize: 20, fontWeight: '800', color: '#fff' }}>Oi! Eu sou a Kit 🤟</Text>
                        <Text style={{ fontSize: 13, color: '#fff', opacity: 0.9, marginTop: 2 }}>Sua ajudante de finanças</Text>
                    </View>
                </View>

                <View style={{ paddingHorizontal: 16, paddingTop: 18, flexDirection: 'row', gap: 6 }}>
                    <View
                        style={{
                            paddingHorizontal: 14,
                            paddingVertical: 8,
                            borderRadius: 14,
                            backgroundColor: '#fff',
                        }}
                    >
                        <Text style={{ fontSize: 13, fontWeight: '700', color: KITAMO.brandDark }}>Minhas dicas</Text>
                    </View>
                    <Pressable
                        onPress={() => router.push('/ia-chat')}
                        style={{
                            paddingHorizontal: 14,
                            paddingVertical: 8,
                            borderRadius: 14,
                            backgroundColor: 'rgba(255,255,255,0.25)',
                        }}
                    >
                        <Text style={{ fontSize: 13, fontWeight: '700', color: '#fff' }}>Conversar</Text>
                    </Pressable>
                </View>

                <View style={{ paddingHorizontal: 16, paddingTop: 16 }}>
                    <Text style={{ fontSize: 11, color: KITAMO.muted, fontWeight: '700', letterSpacing: 0.5, paddingVertical: 8 }}>DICAS DE HOJE</Text>

                    {tips.isLoading ? (
                        <View style={{ paddingVertical: 30, alignItems: 'center' }}>
                            <ActivityIndicator color={KITAMO.brand} />
                        </View>
                    ) : (tips.data?.tips ?? []).length === 0 ? (
                        <View style={{ paddingVertical: 30, alignItems: 'center' }}>
                            <Text style={{ color: KITAMO.muted, fontSize: 13, textAlign: 'center' }}>
                                Sem dicas no momento. Adicione mais lançamentos pra gente analisar.
                            </Text>
                        </View>
                    ) : (
                        (tips.data?.tips ?? []).map((tip, i) => (
                            <Insight key={i} tip={tip} />
                        ))
                    )}

                    <Text style={{ fontSize: 11, color: KITAMO.muted, fontWeight: '700', letterSpacing: 0.5, paddingTop: 18, paddingBottom: 10 }}>
                        PERGUNTAR PRA KIT
                    </Text>
                    <View style={{ flexDirection: 'row', gap: 8, flexWrap: 'wrap' }}>
                        {['Quanto posso gastar hoje?', 'Tô no vermelho?', 'Como economizar mais?'].map((q) => (
                            <Pressable
                                key={q}
                                onPress={() => router.push({ pathname: '/ia-chat', params: { q } })}
                                style={{
                                    paddingHorizontal: 12,
                                    paddingVertical: 8,
                                    borderRadius: 14,
                                    backgroundColor: '#fff',
                                    borderWidth: 1,
                                    borderColor: KITAMO.line,
                                }}
                            >
                                <Text style={{ fontSize: 12, fontWeight: '600', color: KITAMO.ink2 }}>{q}</Text>
                            </Pressable>
                        ))}
                    </View>
                </View>
            </ScrollView>

            <Pressable
                onPress={() => router.push('/ia-chat')}
                style={{
                    position: 'absolute',
                    left: 16,
                    right: 16,
                    bottom: 36,
                    paddingHorizontal: 14,
                    paddingVertical: 10,
                    backgroundColor: '#fff',
                    borderRadius: 24,
                    flexDirection: 'row',
                    alignItems: 'center',
                    gap: 10,
                    shadowColor: '#0F172A',
                    shadowOffset: { width: 0, height: 8 },
                    shadowOpacity: 0.1,
                    shadowRadius: 24,
                    elevation: 4,
                    borderWidth: 1,
                    borderColor: KITAMO.line,
                }}
            >
                <Text style={{ flex: 1, color: KITAMO.muted, fontSize: 14 }}>Pergunta pra Kit...</Text>
                <View style={{ width: 36, height: 36, borderRadius: 18, backgroundColor: KITAMO.brand, alignItems: 'center', justifyContent: 'center' }}>
                    <Icon name="send" size={16} color="#fff" />
                </View>
            </Pressable>
        </Screen>
    );
}

function Insight({ tip }: { tip: { title: string; body: string; severity: 'info' | 'warn' | 'good'; action?: string } }): React.JSX.Element {
    const map: Record<string, { color: string; icon: IconName }> = {
        warn: { color: KITAMO.warn, icon: 'bulb' },
        good: { color: KITAMO.success, icon: 'spark' },
        info: { color: KITAMO.info, icon: 'info' },
    };
    const m = map[tip.severity] ?? map.info;
    return (
        <View
            style={{
                padding: 16,
                backgroundColor: '#fff',
                borderRadius: 18,
                marginBottom: 10,
                shadowColor: '#0F172A',
                shadowOffset: { width: 0, height: 2 },
                shadowOpacity: 0.05,
                shadowRadius: 8,
                elevation: 1,
                borderLeftWidth: 3,
                borderLeftColor: m.color,
            }}
        >
            <View style={{ flexDirection: 'row', gap: 12 }}>
                <View
                    style={{
                        width: 36,
                        height: 36,
                        borderRadius: 10,
                        backgroundColor: `${m.color}15`,
                        alignItems: 'center',
                        justifyContent: 'center',
                    }}
                >
                    <Icon name={m.icon} size={18} color={m.color} />
                </View>
                <View style={{ flex: 1 }}>
                    <Text style={{ fontSize: 14, fontWeight: '800', color: KITAMO.ink }}>{tip.title}</Text>
                    <Text style={{ fontSize: 13, color: KITAMO.ink2, marginTop: 4, lineHeight: 20 }}>{tip.body}</Text>
                    {tip.action ? (
                        <Text style={{ marginTop: 10, fontSize: 13, fontWeight: '700', color: KITAMO.brandDark }}>{tip.action} →</Text>
                    ) : null}
                </View>
            </View>
        </View>
    );
}
