import { useQuery } from '@tanstack/react-query';
import { router } from 'expo-router';
import React, { useMemo, useState } from 'react';
import { ActivityIndicator, Pressable, ScrollView, Text, View } from 'react-native';

import { accountsApi } from '@/api/endpoints';
import { BankAvatar } from '@/components/Avatar';
import { Icon } from '@/components/Icon';
import { Screen, useBottomTabPadding } from '@/components/Screen';
import { TabBar } from '@/components/TabBar';
import { navigateToTab } from '@/lib/navigation';
import { KITAMO } from '@/theme/tokens';

type Tab = 'bancos' | 'cartoes' | 'invest';

const TAB_DEFS: { id: Tab; label: string }[] = [
    { id: 'bancos', label: 'Bancos' },
    { id: 'cartoes', label: 'Cartões' },
    { id: 'invest', label: 'Investimentos' },
];

export default function Contas(): React.JSX.Element {
    const [tab, setTab] = useState<Tab>('bancos');
    const bottomPad = useBottomTabPadding();

    const accounts = useQuery({
        queryKey: ['accounts'],
        queryFn: () => accountsApi.list(),
    });

    const grouped = useMemo(() => {
        const all = accounts.data ?? [];
        return {
            bancos: all.filter((a) => ['checking', 'savings', 'wallet'].includes(a.type)),
            cartoes: all.filter((a) => a.type === 'credit_card'),
            invest: all.filter((a) => a.type === 'investment'),
        };
    }, [accounts.data]);

    const totalBalance = grouped.bancos.reduce((sum, a) => sum + (a.incluir_soma ? a.current_balance : 0), 0);

    return (
        <Screen bg={KITAMO.bg} edges={['top']}>
            <ScrollView contentContainerStyle={{ paddingBottom: bottomPad + 80 }} showsVerticalScrollIndicator={false}>
                <View style={{ paddingHorizontal: 22, paddingTop: 8, flexDirection: 'row', alignItems: 'center' }}>
                    <Text style={{ flex: 1, fontSize: 24, fontWeight: '800', letterSpacing: -0.4, color: KITAMO.ink }}>
                        Minhas contas
                    </Text>
                    <Pressable
                        onPress={() => router.push({ pathname: '/add-invest', params: { intent: tab } })}
                        style={({ pressed }) => ({
                            paddingHorizontal: 14,
                            paddingVertical: 9,
                            borderRadius: 18,
                            backgroundColor: KITAMO.brand,
                            flexDirection: 'row',
                            alignItems: 'center',
                            opacity: pressed ? 0.85 : 1,
                        })}
                    >
                        <Icon name="plus" size={16} color="#fff" />
                        <Text style={{ color: '#fff', fontWeight: '700', fontSize: 13, marginLeft: 4 }}>Nova</Text>
                    </Pressable>
                </View>
                <View style={{ paddingHorizontal: 22, marginTop: 6, flexDirection: 'row', gap: 8, flexWrap: 'wrap' }}>
                    <Pressable
                        onPress={() => router.push('/import')}
                        style={({ pressed }) => ({
                            paddingHorizontal: 12,
                            paddingVertical: 7,
                            borderRadius: 14,
                            backgroundColor: '#fff',
                            borderWidth: 1,
                            borderColor: KITAMO.line,
                            flexDirection: 'row',
                            alignItems: 'center',
                            opacity: pressed ? 0.85 : 1,
                        })}
                    >
                        <Icon name="imp" size={13} color={KITAMO.brandDark} />
                        <Text style={{ color: KITAMO.brandDark, fontWeight: '700', fontSize: 12, marginLeft: 5 }}>Importar fatura</Text>
                    </Pressable>
                </View>

                <View style={{ flexDirection: 'row', gap: 8, paddingHorizontal: 22, marginTop: 18 }}>
                    {TAB_DEFS.map((t) => {
                        const on = t.id === tab;
                        return (
                            <Pressable
                                key={t.id}
                                onPress={() => setTab(t.id)}
                                style={{
                                    paddingVertical: 9,
                                    paddingHorizontal: 16,
                                    borderRadius: 20,
                                    backgroundColor: on ? KITAMO.ink : '#fff',
                                    shadowColor: '#0F172A',
                                    shadowOffset: { width: 0, height: 1 },
                                    shadowOpacity: 0.05,
                                    shadowRadius: 3,
                                    elevation: 1,
                                }}
                            >
                                <Text style={{ color: on ? '#fff' : KITAMO.ink2, fontWeight: on ? '700' : '600', fontSize: 13 }}>{t.label}</Text>
                            </Pressable>
                        );
                    })}
                </View>

                <View style={{ paddingHorizontal: 16, paddingTop: 18 }}>
                    {accounts.isLoading ? (
                        <View style={{ paddingVertical: 40, alignItems: 'center' }}>
                            <ActivityIndicator color={KITAMO.brand} />
                        </View>
                    ) : tab === 'bancos' ? (
                        <BancosTab list={grouped.bancos} total={totalBalance} />
                    ) : tab === 'cartoes' ? (
                        <CartoesTab list={grouped.cartoes} />
                    ) : (
                        <InvestTab list={grouped.invest} />
                    )}
                </View>
            </ScrollView>

            <TabBar active="contas" onTab={navigateToTab} />
        </Screen>
    );
}

function BancosTab({ list, total }: { list: ReturnType<typeof Array.prototype.slice>; total: number }): React.JSX.Element {
    return (
        <View>
            <View
                style={{
                    paddingHorizontal: 16,
                    paddingVertical: 14,
                    backgroundColor: '#fff',
                    borderRadius: 16,
                    shadowColor: '#0F172A',
                    shadowOffset: { width: 0, height: 1 },
                    shadowOpacity: 0.04,
                    shadowRadius: 3,
                    elevation: 1,
                    marginBottom: 12,
                    flexDirection: 'row',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                }}
            >
                <View>
                    <Text style={{ fontSize: 11, color: KITAMO.muted, fontWeight: '600', letterSpacing: 0.4 }}>SALDO TOTAL</Text>
                    <Text style={{ fontSize: 22, fontWeight: '800', letterSpacing: -0.5, marginTop: 2, color: KITAMO.ink }}>
                        R$ {total.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
                    </Text>
                </View>
                <View style={{ paddingHorizontal: 8, paddingVertical: 4, backgroundColor: '#D1FAE5', borderRadius: 8 }}>
                    <Text style={{ fontSize: 11, fontWeight: '700', color: KITAMO.success }}>● {list.length} contas</Text>
                </View>
            </View>

            {list.length === 0 ? (
                <Text style={{ paddingVertical: 24, textAlign: 'center', color: KITAMO.muted }}>
                    Nenhum banco ainda. Toque em "Adicionar".
                </Text>
            ) : (
                list.map((a: any) => (
                    <View
                        key={a.id}
                        style={{
                            paddingHorizontal: 14,
                            paddingVertical: 12,
                            backgroundColor: '#fff',
                            borderRadius: 14,
                            marginBottom: 6,
                            shadowColor: '#0F172A',
                            shadowOffset: { width: 0, height: 1 },
                            shadowOpacity: 0.04,
                            shadowRadius: 3,
                            elevation: 1,
                            flexDirection: 'row',
                            alignItems: 'center',
                            gap: 11,
                        }}
                    >
                        <BankAvatar name={a.name} color={a.color ?? KITAMO.brand} size={34} />
                        <View style={{ flex: 1 }}>
                            <Text style={{ fontSize: 13, fontWeight: '700', color: KITAMO.ink }}>{a.name}</Text>
                            <Text style={{ fontSize: 11, color: KITAMO.muted, marginTop: 1 }}>
                                {a.bank_account_type === 'corrente'
                                    ? 'Conta corrente'
                                    : a.bank_account_type === 'poupanca'
                                      ? 'Poupança'
                                      : a.type === 'wallet'
                                        ? 'Carteira'
                                        : a.institution ?? a.type}
                            </Text>
                        </View>
                        <Text style={{ fontSize: 14, fontWeight: '700', color: KITAMO.ink }}>
                            R$ {a.current_balance.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
                        </Text>
                    </View>
                ))
            )}
        </View>
    );
}

function CartoesTab({ list }: { list: any[] }): React.JSX.Element {
    if (list.length === 0) {
        return (
            <View style={{ paddingVertical: 60, alignItems: 'center' }}>
                <Text style={{ fontSize: 14, color: KITAMO.muted, textAlign: 'center', paddingHorizontal: 30, lineHeight: 20 }}>
                    Nenhum cartão ainda. {'\n'}Toque em "Adicionar" pra começar.
                </Text>
            </View>
        );
    }
    return (
        <View>
            {list.map((c) => {
                const limit = c.credit_limit ?? 0;
                const used = c.current_balance < 0 ? Math.abs(c.current_balance) : 0;
                const available = Math.max(limit - used, 0);
                const usedPct = limit > 0 ? Math.min((used / limit) * 100, 100) : 0;
                const baseColor = c.color ?? '#5B0286';
                return (
                    <View key={c.id} style={{ marginBottom: 16 }}>
                        <View
                            style={{
                                padding: 18,
                                height: 180,
                                borderRadius: 20,
                                backgroundColor: baseColor,
                                overflow: 'hidden',
                                justifyContent: 'space-between',
                                shadowColor: baseColor,
                                shadowOffset: { width: 0, height: 8 },
                                shadowOpacity: 0.25,
                                shadowRadius: 16,
                                elevation: 6,
                            }}
                        >
                            <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
                                <View style={{ flex: 1, marginRight: 12 }}>
                                    <Text style={{ fontSize: 11, color: '#fff', opacity: 0.7, fontWeight: '700', letterSpacing: 0.4 }}>
                                        CARTÃO DE CRÉDITO
                                    </Text>
                                    <Text style={{ fontSize: 16, fontWeight: '800', color: '#fff', marginTop: 2 }} numberOfLines={1}>
                                        {c.name}
                                    </Text>
                                </View>
                                <Icon name="card" size={26} color="#fff" />
                            </View>
                            <View>
                                <Text style={{ fontSize: 11, color: '#fff', opacity: 0.8 }}>Disponível</Text>
                                <Text style={{ fontSize: 26, fontWeight: '800', color: '#fff', letterSpacing: -0.5, marginTop: 2 }}>
                                    R$ {available.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
                                </Text>
                                <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginTop: 6 }}>
                                    <Text style={{ fontSize: 11, color: '#fff', opacity: 0.85 }}>
                                        Limite R$ {limit.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
                                    </Text>
                                    {c.due_day ? (
                                        <Text style={{ fontSize: 11, color: '#fff', opacity: 0.85 }}>Vence dia {c.due_day}</Text>
                                    ) : null}
                                </View>
                            </View>
                        </View>
                        {limit > 0 ? (
                            <View style={{ paddingHorizontal: 4, marginTop: 8 }}>
                                <View style={{ height: 6, backgroundColor: KITAMO.line2, borderRadius: 3, overflow: 'hidden' }}>
                                    <View style={{ width: `${usedPct}%`, height: '100%', backgroundColor: usedPct > 80 ? KITAMO.danger : KITAMO.brand, borderRadius: 3 }} />
                                </View>
                                <View style={{ flexDirection: 'row', justifyContent: 'space-between', marginTop: 4 }}>
                                    <Text style={{ fontSize: 11, color: KITAMO.muted, fontWeight: '600' }}>
                                        Usado R$ {used.toLocaleString('pt-BR', { minimumFractionDigits: 2 })} ({Math.round(usedPct)}%)
                                    </Text>
                                    {c.closing_day ? (
                                        <Text style={{ fontSize: 11, color: KITAMO.muted }}>Fecha dia {c.closing_day}</Text>
                                    ) : null}
                                </View>
                            </View>
                        ) : null}
                    </View>
                );
            })}
        </View>
    );
}

function InvestTab({ list }: { list: any[] }): React.JSX.Element {
    const total = list.reduce((sum: number, a: any) => sum + a.current_balance, 0);
    return (
        <View>
            <View
                style={{
                    padding: 18,
                    backgroundColor: '#0F172A',
                    borderRadius: 18,
                    marginBottom: 12,
                }}
            >
                <Text style={{ fontSize: 11, color: '#fff', opacity: 0.6, fontWeight: '600', letterSpacing: 0.3 }}>TOTAL INVESTIDO</Text>
                <Text style={{ fontSize: 28, fontWeight: '800', letterSpacing: -1, color: '#fff', marginTop: 2 }}>
                    R$ {total.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
                </Text>
            </View>

            {list.length === 0 ? (
                <Text style={{ paddingVertical: 30, textAlign: 'center', color: KITAMO.muted }}>
                    Nenhum investimento cadastrado.
                </Text>
            ) : (
                list.map((i) => (
                    <View
                        key={i.id}
                        style={{
                            flexDirection: 'row',
                            alignItems: 'center',
                            gap: 12,
                            padding: 14,
                            backgroundColor: '#fff',
                            borderRadius: 14,
                            marginBottom: 8,
                            shadowColor: '#0F172A',
                            shadowOffset: { width: 0, height: 1 },
                            shadowOpacity: 0.04,
                            shadowRadius: 3,
                            elevation: 1,
                        }}
                    >
                        <View
                            style={{
                                width: 36,
                                height: 36,
                                borderRadius: 10,
                                backgroundColor: (i.color ?? '#3B82F6') + '22',
                                alignItems: 'center',
                                justifyContent: 'center',
                            }}
                        >
                            <Icon name="chart" size={18} color={i.color ?? '#3B82F6'} />
                        </View>
                        <View style={{ flex: 1 }}>
                            <Text style={{ fontSize: 14, fontWeight: '700', color: KITAMO.ink }}>{i.name}</Text>
                            <Text style={{ fontSize: 11, color: KITAMO.muted, marginTop: 1 }}>{i.institution ?? 'Investimento'}</Text>
                        </View>
                        <Text style={{ fontSize: 14, fontWeight: '800', color: KITAMO.ink }}>
                            R$ {i.current_balance.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
                        </Text>
                    </View>
                ))
            )}

            <Pressable
                onPress={() => router.push('/add-invest')}
                style={{
                    paddingVertical: 14,
                    marginTop: 8,
                    borderRadius: 14,
                    borderWidth: 1.5,
                    borderColor: KITAMO.line,
                    borderStyle: 'dashed',
                    flexDirection: 'row',
                    alignItems: 'center',
                    justifyContent: 'center',
                    gap: 8,
                }}
            >
                <Icon name="plus" size={16} color={KITAMO.brandDark} />
                <Text style={{ color: KITAMO.brandDark, fontSize: 14, fontWeight: '700' }}>Adicionar investimento</Text>
            </Pressable>
        </View>
    );
}
