import { useQuery } from '@tanstack/react-query';
import { router } from 'expo-router';
import React from 'react';
import { ActivityIndicator, Pressable, ScrollView, Text, View } from 'react-native';

import { accountsApi, dashboardApi } from '@/api/endpoints';
import { BankAvatar, CatIcon } from '@/components/Avatar';
import { Icon, type IconName } from '@/components/Icon';
import { Screen, useBottomTabPadding } from '@/components/Screen';
import { SpendingDonut } from '@/components/SpendingDonut';
import { TabBar } from '@/components/TabBar';
import { formatBRLNumber } from '@/lib/format';
import { greetingByHour } from '@/lib/format';
import { navigateToTab } from '@/lib/navigation';
import { useAuth } from '@/stores/authStore';
import { KITAMO } from '@/theme/tokens';

export default function Home(): React.JSX.Element {
    const user = useAuth((s) => s.user);
    const bottomPad = useBottomTabPadding();

    const summary = useQuery({
        queryKey: ['dashboard-summary'],
        queryFn: () => dashboardApi.summary(),
    });
    const accounts = useQuery({
        queryKey: ['accounts'],
        queryFn: () => accountsApi.list(),
    });

    const totalBalance = summary.data?.total_balance ?? 0;
    const balance = formatBRLNumber(totalBalance);
    const greeting = greetingByHour();
    const initial = (user?.name ?? '?').charAt(0).toUpperCase();
    const monthlyBalance = summary.data?.monthly_balance ?? 0;
    const willClose = monthlyBalance >= 0;

    return (
        <Screen bg={KITAMO.bg} barStyle="light" edges={['top']}>
            <ScrollView contentContainerStyle={{ paddingBottom: bottomPad + 100 }} showsVerticalScrollIndicator={false}>
                <View style={{ position: 'absolute', top: 0, left: 0, right: 0, height: 290, backgroundColor: KITAMO.brand, borderBottomLeftRadius: 28, borderBottomRightRadius: 28 }} />

                <View style={{ paddingHorizontal: 22, paddingTop: 4 }}>
                    <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginTop: 6 }}>
                        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12 }}>
                            <View
                                style={{
                                    width: 42,
                                    height: 42,
                                    borderRadius: 21,
                                    backgroundColor: 'rgba(255,255,255,0.25)',
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                }}
                            >
                                <Text style={{ color: '#fff', fontWeight: '800', fontSize: 16 }}>{initial}</Text>
                            </View>
                            <View>
                                <Text style={{ color: '#fff', opacity: 0.85, fontSize: 13 }}>{greeting}</Text>
                                <Text style={{ color: '#fff', fontSize: 18, fontWeight: '700' }}>Oi, {user?.name?.split(' ')[0] ?? '!'}</Text>
                            </View>
                        </View>
                        <Pressable
                            onPress={() => router.push('/notif')}
                            style={{
                                width: 42,
                                height: 42,
                                borderRadius: 21,
                                backgroundColor: 'rgba(255,255,255,0.2)',
                                alignItems: 'center',
                                justifyContent: 'center',
                            }}
                        >
                            <Icon name="bell" size={20} color="#fff" />
                        </Pressable>
                    </View>

                    <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8, marginTop: 22 }}>
                        <Text style={{ color: '#fff', opacity: 0.9, fontSize: 13 }}>Seu dinheiro hoje</Text>
                        <Icon name="eye" size={16} color="#fff" />
                    </View>
                    <View style={{ flexDirection: 'row', alignItems: 'baseline', marginTop: 4 }}>
                        <Text style={{ color: '#fff', fontSize: 24, fontWeight: '600', opacity: 0.85, marginRight: 4 }}>R$</Text>
                        <Text style={{ color: '#fff', fontSize: 42, fontWeight: '800', letterSpacing: -1.2 }}>{balance.whole}</Text>
                        <Text style={{ color: '#fff', fontSize: 28, fontWeight: '800', opacity: 0.7 }}>,{balance.cents}</Text>
                    </View>
                    <Text style={{ color: '#fff', opacity: 0.85, fontSize: 13, marginTop: 2 }}>Somando todas as suas contas</Text>
                </View>

                <View
                    style={{
                        marginHorizontal: 16,
                        marginTop: 24,
                        padding: 18,
                        backgroundColor: '#fff',
                        borderRadius: 20,
                        shadowColor: '#0F172A',
                        shadowOffset: { width: 0, height: 8 },
                        shadowOpacity: 0.08,
                        shadowRadius: 28,
                        elevation: 4,
                    }}
                >
                    <Text style={{ fontSize: 13, color: KITAMO.muted, fontWeight: '600' }}>O dinheiro fecha o mês?</Text>
                    <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8, marginTop: 6 }}>
                        <Text style={{ fontSize: 22, fontWeight: '800', color: willClose ? KITAMO.success : KITAMO.danger }}>
                            {willClose ? 'Fecha, com folga' : 'Tá apertado'}
                        </Text>
                        <Text style={{ fontSize: 22 }}>{willClose ? '👍' : '⚠️'}</Text>
                    </View>
                    <Text style={{ fontSize: 13, color: KITAMO.ink2, marginTop: 4 }}>
                        Sobra estimada:{' '}
                        <Text style={{ fontWeight: '700', color: KITAMO.ink }}>
                            R$ {monthlyBalance.toLocaleString('pt-BR', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}
                        </Text>
                    </Text>
                </View>

                {summary.data?.spending_by_category && summary.data.spending_by_category.length > 0 ? (
                    <SpendingDonut
                        slices={summary.data.spending_by_category.slice(0, 6)}
                        style={{ marginHorizontal: 16, marginTop: 16 }}
                    />
                ) : null}

                <View style={{ paddingHorizontal: 16, marginTop: 22 }}>
                    <View style={{ flexDirection: 'row', gap: 10 }}>
                        <Shortcut color={KITAMO.danger} bg="#FEE2E2" iconName="send" label="Lançar gasto" onPress={() => router.push({ pathname: '/add', params: { kind: 'out' } })} />
                        <Shortcut color={KITAMO.success} bg="#D1FAE5" iconName="recv" label="Lançar entrada" onPress={() => router.push({ pathname: '/add', params: { kind: 'in' } })} />
                        <Shortcut color={KITAMO.info} bg="#DBEAFE" iconName="bolt" label="Pagar conta" onPress={() => router.push({ pathname: '/add', params: { kind: 'out' } })} />
                        <Shortcut color={KITAMO.muted} bg="#F1F5F9" iconName="tag" label="Ver tudo" onPress={() => router.replace('/(app)/gastos')} />
                    </View>

                    <SectionHeader title="Minhas contas" link="Ver todas →" onLinkPress={() => router.replace('/(app)/contas')} />
                    <View style={{ backgroundColor: '#fff', borderRadius: 18, paddingHorizontal: 16, paddingVertical: 4, shadowColor: '#0F172A', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.04, shadowRadius: 8, elevation: 1 }}>
                        {accounts.isLoading ? (
                            <View style={{ paddingVertical: 24, alignItems: 'center' }}>
                                <ActivityIndicator color={KITAMO.brand} />
                            </View>
                        ) : (accounts.data ?? []).length === 0 ? (
                            <Text style={{ paddingVertical: 24, textAlign: 'center', color: KITAMO.muted }}>Nenhuma conta ainda.</Text>
                        ) : (
                            (accounts.data ?? []).slice(0, 3).map((a, i, arr) => (
                                <View
                                    key={a.id}
                                    style={{
                                        flexDirection: 'row',
                                        alignItems: 'center',
                                        gap: 12,
                                        paddingVertical: 14,
                                        borderBottomWidth: i === arr.length - 1 ? 0 : 1,
                                        borderBottomColor: KITAMO.line2,
                                    }}
                                >
                                    <BankAvatar name={a.name} color={a.color ?? KITAMO.brand} />
                                    <View style={{ flex: 1 }}>
                                        <Text style={{ fontSize: 15, fontWeight: '700', color: KITAMO.ink }}>{a.name}</Text>
                                        <Text style={{ fontSize: 12, color: KITAMO.muted, marginTop: 1 }}>
                                            {a.institution ?? a.type}
                                        </Text>
                                    </View>
                                    <Text style={{ fontSize: 16, fontWeight: '700', color: KITAMO.ink }}>
                                        R$ {a.current_balance.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
                                    </Text>
                                </View>
                            ))
                        )}
                    </View>

                    <SectionHeader title="Últimas transações" link="Ver tudo →" onLinkPress={() => router.replace('/(app)/gastos')} />
                    <View style={{ backgroundColor: '#fff', borderRadius: 18, paddingHorizontal: 16, paddingVertical: 4, shadowColor: '#0F172A', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.04, shadowRadius: 8, elevation: 1 }}>
                        {summary.isLoading ? (
                            <View style={{ paddingVertical: 24, alignItems: 'center' }}>
                                <ActivityIndicator color={KITAMO.brand} />
                            </View>
                        ) : (summary.data?.top_recent ?? []).length === 0 ? (
                            <Text style={{ paddingVertical: 24, textAlign: 'center', color: KITAMO.muted }}>Sem lançamentos ainda.</Text>
                        ) : (
                            (summary.data?.top_recent ?? []).slice(0, 4).map((t, i, arr) => (
                                <Pressable
                                    key={t.id}
                                    onPress={() => router.push({ pathname: '/transaction/[id]', params: { id: String(t.id) } })}
                                    style={{
                                        flexDirection: 'row',
                                        alignItems: 'center',
                                        gap: 12,
                                        paddingVertical: 12,
                                        borderBottomWidth: i === arr.length - 1 ? 0 : 1,
                                        borderBottomColor: KITAMO.line2,
                                    }}
                                >
                                    <CatIcon name="tag" color={t.kind === 'income' ? KITAMO.success : KITAMO.danger} size={36} />
                                    <View style={{ flex: 1 }}>
                                        <Text style={{ fontSize: 14, fontWeight: '700', color: KITAMO.ink }} numberOfLines={1}>
                                            {t.description}
                                        </Text>
                                        <Text style={{ fontSize: 11, color: KITAMO.muted, marginTop: 1 }}>{t.transaction_date}</Text>
                                    </View>
                                    <Text style={{ fontSize: 14, fontWeight: '800', color: t.kind === 'income' ? KITAMO.success : KITAMO.ink }}>
                                        {t.kind === 'income' ? '+ ' : '- '}R$ {t.amount.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
                                    </Text>
                                </Pressable>
                            ))
                        )}
                    </View>

                    <Pressable
                        onPress={() => router.push('/ia-chat')}
                        style={{
                            marginTop: 18,
                            padding: 16,
                            borderRadius: 18,
                            backgroundColor: KITAMO.brandSoft,
                            flexDirection: 'row',
                            gap: 14,
                            alignItems: 'flex-start',
                        }}
                    >
                        <View
                            style={{
                                width: 42,
                                height: 42,
                                borderRadius: 21,
                                backgroundColor: '#fff',
                                alignItems: 'center',
                                justifyContent: 'center',
                            }}
                        >
                            <Icon name="bulb" size={22} color={KITAMO.brandDark} />
                        </View>
                        <View style={{ flex: 1 }}>
                            <Text style={{ fontSize: 14, fontWeight: '700', color: KITAMO.ink }}>Pergunta pra Kit</Text>
                            <Text style={{ fontSize: 14, color: KITAMO.ink2, marginTop: 3, lineHeight: 20 }}>
                                Sua ajudante de finanças pode te dar dicas personalizadas a qualquer hora.
                            </Text>
                        </View>
                    </Pressable>
                </View>
            </ScrollView>

            <Pressable
                onPress={() => router.push('/ia-chat')}
                style={({ pressed }) => ({
                    position: 'absolute',
                    right: 18,
                    bottom: bottomPad + 18,
                    width: 60,
                    height: 60,
                    borderRadius: 30,
                    backgroundColor: KITAMO.brand,
                    alignItems: 'center',
                    justifyContent: 'center',
                    shadowColor: KITAMO.brand,
                    shadowOffset: { width: 0, height: 8 },
                    shadowOpacity: 0.45,
                    shadowRadius: 18,
                    elevation: 10,
                    transform: [{ scale: pressed ? 0.94 : 1 }],
                })}
                hitSlop={8}
                accessibilityLabel="Abrir Kit, sua ajudante de finanças"
            >
                <View style={{ position: 'absolute', top: -6, right: -6, paddingHorizontal: 7, height: 18, borderRadius: 10, backgroundColor: KITAMO.warn, alignItems: 'center', justifyContent: 'center' }}>
                    <Text style={{ color: '#fff', fontSize: 9, fontWeight: '800', letterSpacing: 0.4 }}>IA</Text>
                </View>
                <View style={{ alignItems: 'center', justifyContent: 'center' }}>
                    <Icon name="bulb" size={26} color="#fff" />
                    <Text style={{ color: '#fff', fontSize: 10, fontWeight: '800', marginTop: 1, letterSpacing: 0.4 }}>KIT</Text>
                </View>
            </Pressable>

            <TabBar active="home" onTab={navigateToTab} />
        </Screen>
    );
}

function Shortcut({
    color,
    bg,
    iconName,
    label,
    onPress,
}: {
    color: string;
    bg: string;
    iconName: IconName;
    label: string;
    onPress: () => void;
}): React.JSX.Element {
    return (
        <Pressable
            onPress={onPress}
            style={({ pressed }) => ({
                flex: 1,
                backgroundColor: '#fff',
                borderRadius: 16,
                paddingVertical: 14,
                alignItems: 'center',
                gap: 8,
                shadowColor: '#0F172A',
                shadowOffset: { width: 0, height: 2 },
                shadowOpacity: 0.04,
                shadowRadius: 8,
                elevation: 1,
                transform: [{ scale: pressed ? 0.97 : 1 }],
            })}
        >
            <View style={{ width: 42, height: 42, borderRadius: 14, backgroundColor: bg, alignItems: 'center', justifyContent: 'center' }}>
                <Icon name={iconName} size={22} color={color} />
            </View>
            <Text style={{ fontSize: 11, fontWeight: '600', color: KITAMO.ink, textAlign: 'center' }}>{label}</Text>
        </Pressable>
    );
}

function SectionHeader({ title, link, onLinkPress }: { title: string; link?: string; onLinkPress?: () => void }): React.JSX.Element {
    return (
        <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginTop: 24, marginBottom: 12 }}>
            <Text style={{ fontSize: 17, fontWeight: '800', color: KITAMO.ink }}>{title}</Text>
            {link ? (
                <Pressable onPress={onLinkPress}>
                    <Text style={{ fontSize: 13, color: KITAMO.brandDark, fontWeight: '700' }}>{link}</Text>
                </Pressable>
            ) : null}
        </View>
    );
}
