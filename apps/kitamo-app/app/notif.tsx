import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { router } from 'expo-router';
import React from 'react';
import { ActivityIndicator, Pressable, ScrollView, Text, View } from 'react-native';

import { extractApiError } from '@/api/client';
import { notificationsApi } from '@/api/endpoints';
import { Icon, type IconName } from '@/components/Icon';
import { Screen } from '@/components/Screen';
import { KITAMO } from '@/theme/tokens';

export default function Notif(): React.JSX.Element {
    const qc = useQueryClient();
    const list = useQuery({ queryKey: ['notifications'], queryFn: () => notificationsApi.list() });

    const markAll = useMutation({
        mutationFn: () => notificationsApi.markAllRead(),
        onSuccess: () => qc.invalidateQueries({ queryKey: ['notifications'] }),
    });
    const markOne = useMutation({
        mutationFn: (id: string) => notificationsApi.markRead(id),
        onSuccess: () => qc.invalidateQueries({ queryKey: ['notifications'] }),
    });

    return (
        <Screen bg={KITAMO.bg} edges={['top', 'bottom']}>
            <View style={{ paddingHorizontal: 16, paddingTop: 8, flexDirection: 'row', alignItems: 'center', gap: 10 }}>
                <Pressable
                    onPress={() => router.back()}
                    style={{ width: 36, height: 36, borderRadius: 18, backgroundColor: '#fff', alignItems: 'center', justifyContent: 'center' }}
                >
                    <Icon name="back" size={18} color={KITAMO.ink} />
                </Pressable>
                <Text style={{ flex: 1, fontSize: 18, fontWeight: '800', color: KITAMO.ink }}>Avisos</Text>
                <Pressable onPress={() => markAll.mutate()} disabled={markAll.isPending} hitSlop={8}>
                    <Text style={{ fontSize: 12, color: KITAMO.brandDark, fontWeight: '700' }}>Marcar tudo</Text>
                </Pressable>
            </View>

            <ScrollView contentContainerStyle={{ padding: 16, gap: 6 }} showsVerticalScrollIndicator={false}>
                {list.isLoading ? (
                    <View style={{ paddingVertical: 60, alignItems: 'center' }}>
                        <ActivityIndicator color={KITAMO.brand} />
                    </View>
                ) : (list.data ?? []).length === 0 ? (
                    <View style={{ paddingVertical: 60, alignItems: 'center' }}>
                        <Icon name="bell" size={48} color={KITAMO.line} />
                        <Text style={{ marginTop: 16, fontSize: 16, fontWeight: '700', color: KITAMO.ink }}>Tudo em dia</Text>
                        <Text style={{ marginTop: 6, fontSize: 13, color: KITAMO.muted, textAlign: 'center' }}>
                            Quando rolar algo importante a Kit te avisa por aqui.
                        </Text>
                    </View>
                ) : (
                    (list.data ?? []).map((n) => (
                        <Pressable
                            key={n.id}
                            onPress={() => !n.lida && markOne.mutate(n.id)}
                            style={{
                                flexDirection: 'row',
                                gap: 12,
                                paddingVertical: 12,
                                paddingHorizontal: 14,
                                backgroundColor: '#fff',
                                borderRadius: 14,
                                shadowColor: '#0F172A',
                                shadowOffset: { width: 0, height: 1 },
                                shadowOpacity: 0.04,
                                shadowRadius: 3,
                                elevation: 1,
                                position: 'relative',
                            }}
                        >
                            {!n.lida ? (
                                <View
                                    style={{
                                        position: 'absolute',
                                        left: 6,
                                        top: '50%',
                                        marginTop: -3,
                                        width: 6,
                                        height: 6,
                                        borderRadius: 3,
                                        backgroundColor: KITAMO.brand,
                                    }}
                                />
                            ) : null}
                            <View
                                style={{
                                    width: 36,
                                    height: 36,
                                    borderRadius: 10,
                                    backgroundColor: colorFor(n.tipo) + '18',
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                }}
                            >
                                <Icon name={iconFor(n.tipo)} size={16} color={colorFor(n.tipo)} />
                            </View>
                            <View style={{ flex: 1 }}>
                                <Text style={{ fontSize: 13, fontWeight: n.lida ? '700' : '800', color: KITAMO.ink }}>{n.titulo}</Text>
                                <Text style={{ fontSize: 12, color: KITAMO.ink2, marginTop: 2 }}>{n.mensagem}</Text>
                                <Text style={{ fontSize: 10, color: KITAMO.muted, marginTop: 4, fontWeight: '600' }}>{relativeTime(n.created_at)}</Text>
                            </View>
                        </Pressable>
                    ))
                )}
                {markAll.error ? (
                    <Text style={{ marginTop: 12, color: KITAMO.danger, fontSize: 12 }}>{extractApiError(markAll.error)}</Text>
                ) : null}
            </ScrollView>
        </Screen>
    );
}

function iconFor(tipo: string): IconName {
    if (tipo.includes('aviso')) return 'bell';
    if (tipo.includes('dica')) return 'bulb';
    if (tipo.includes('meta')) return 'target';
    if (tipo.includes('cartao') || tipo.includes('card')) return 'card';
    return 'bell';
}

function colorFor(tipo: string): string {
    if (tipo.includes('aviso')) return KITAMO.warn;
    if (tipo.includes('dica')) return KITAMO.brandDark;
    if (tipo.includes('meta')) return KITAMO.brand;
    if (tipo.includes('cartao') || tipo.includes('card')) return KITAMO.info;
    return KITAMO.muted;
}

function relativeTime(iso: string | null | undefined): string {
    if (!iso) return '';
    const t = new Date(iso).getTime();
    const diff = Date.now() - t;
    const min = Math.floor(diff / 60000);
    if (min < 1) return 'agora';
    if (min < 60) return `${min} min`;
    const h = Math.floor(min / 60);
    if (h < 24) return `${h}h`;
    const d = Math.floor(h / 24);
    if (d < 7) return `${d}d`;
    return new Date(t).toLocaleDateString('pt-BR', { day: '2-digit', month: 'short' });
}
