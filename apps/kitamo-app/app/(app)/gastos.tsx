import { useQuery } from '@tanstack/react-query';
import { router } from 'expo-router';
import React, { useMemo, useState } from 'react';
import { ActivityIndicator, Pressable, ScrollView, Text, View } from 'react-native';
import Svg, { Circle, G, Path } from 'react-native-svg';

import { categoriesApi, dashboardApi, transactionsApi } from '@/api/endpoints';
import { CatIcon } from '@/components/Avatar';
import { Icon } from '@/components/Icon';
import { Screen, useBottomTabPadding } from '@/components/Screen';
import { TabBar } from '@/components/TabBar';
import { monthRange } from '@/lib/format';
import { navigateToTab } from '@/lib/navigation';
import { KITAMO } from '@/theme/tokens';

type Filter = 'all' | 'expense' | 'income';

export default function Gastos(): React.JSX.Element {
    const [monthOffset, setMonthOffset] = useState(0);
    const [filter, setFilter] = useState<Filter>('all');
    const bottomPad = useBottomTabPadding();

    const range = useMemo(() => {
        const ref = new Date();
        ref.setMonth(ref.getMonth() + monthOffset);
        return monthRange(ref);
    }, [monthOffset]);

    const txs = useQuery({
        queryKey: ['transactions', range.from, range.to, filter],
        queryFn: () =>
            transactionsApi.list({
                from: range.from,
                to: range.to,
                kind: filter === 'all' ? undefined : (filter as 'expense' | 'income'),
                limit: 200,
            }),
    });

    const summary = useQuery({
        queryKey: ['dashboard-summary'],
        queryFn: () => dashboardApi.summary(),
    });

    const cats = useQuery({ queryKey: ['categories'], queryFn: () => categoriesApi.list() });

    const dayGroups = useMemo(() => {
        const groups = new Map<string, { total: number; items: NonNullable<typeof txs.data>[number][] }>();
        (txs.data ?? []).forEach((t) => {
            const key = t.transaction_date;
            const g = groups.get(key) ?? { total: 0, items: [] };
            g.total += t.kind === 'income' ? t.amount : -t.amount;
            g.items.push(t);
            groups.set(key, g);
        });
        return Array.from(groups.entries());
    }, [txs.data]);

    const totalExpenses = (txs.data ?? []).filter((t) => t.kind === 'expense').reduce((s, t) => s + t.amount, 0);
    const totalIncome = (txs.data ?? []).filter((t) => t.kind === 'income').reduce((s, t) => s + t.amount, 0);

    const isEmpty = !txs.isLoading && (txs.data ?? []).length === 0;

    return (
        <Screen bg={KITAMO.bg} edges={['top']}>
            <ScrollView contentContainerStyle={{ paddingBottom: bottomPad + 80 }} showsVerticalScrollIndicator={false}>
                <View style={{ paddingHorizontal: 22, paddingTop: 8 }}>
                    <Text style={{ fontSize: 26, fontWeight: '800', color: KITAMO.ink, letterSpacing: -0.6 }}>Gastos</Text>
                </View>

                <View
                    style={{
                        marginHorizontal: 22,
                        marginTop: 14,
                        paddingVertical: 12,
                        paddingHorizontal: 14,
                        backgroundColor: '#fff',
                        borderRadius: 14,
                        flexDirection: 'row',
                        alignItems: 'center',
                        justifyContent: 'space-between',
                        shadowColor: '#0F172A',
                        shadowOffset: { width: 0, height: 1 },
                        shadowOpacity: 0.04,
                        shadowRadius: 3,
                        elevation: 1,
                    }}
                >
                    <Pressable onPress={() => setMonthOffset((m) => m - 1)} hitSlop={10}>
                        <Icon name="back" size={18} color={KITAMO.muted} />
                    </Pressable>
                    <Text style={{ fontSize: 15, fontWeight: '700' }}>{range.label}</Text>
                    <Pressable onPress={() => setMonthOffset((m) => Math.min(m + 1, 0))} hitSlop={10} disabled={monthOffset >= 0}>
                        <View style={{ transform: [{ rotate: '180deg' }] }}>
                            <Icon name="back" size={18} color={monthOffset >= 0 ? KITAMO.line : KITAMO.muted} />
                        </View>
                    </Pressable>
                </View>

                <View style={{ flexDirection: 'row', gap: 8, paddingHorizontal: 16, marginTop: 14 }}>
                    <SumCard label="Entrou" value={totalIncome} color={KITAMO.success} />
                    <SumCard label="Saiu" value={totalExpenses} color={KITAMO.danger} />
                    <SumCard label="Sobrou" value={totalIncome - totalExpenses} color={KITAMO.brandDark} highlight />
                </View>

                {summary.data?.spending_by_category && summary.data.spending_by_category.length > 0 ? (
                    <PieCard slices={summary.data.spending_by_category.slice(0, 6)} />
                ) : null}

                <View style={{ flexDirection: 'row', gap: 8, paddingHorizontal: 16, marginTop: 18 }}>
                    {[
                        { id: 'all', label: 'Tudo' },
                        { id: 'expense', label: 'Gastos' },
                        { id: 'income', label: 'Entradas' },
                    ].map((f) => {
                        const on = filter === f.id;
                        return (
                            <Pressable
                                key={f.id}
                                onPress={() => setFilter(f.id as Filter)}
                                style={{
                                    paddingVertical: 7,
                                    paddingHorizontal: 14,
                                    borderRadius: 18,
                                    backgroundColor: on ? KITAMO.ink : '#fff',
                                    shadowColor: '#0F172A',
                                    shadowOffset: { width: 0, height: 1 },
                                    shadowOpacity: 0.05,
                                    shadowRadius: 3,
                                    elevation: 1,
                                }}
                            >
                                <Text style={{ color: on ? '#fff' : KITAMO.ink2, fontWeight: '700', fontSize: 13 }}>{f.label}</Text>
                            </Pressable>
                        );
                    })}
                </View>

                <View style={{ paddingHorizontal: 16, marginTop: 4 }}>
                    {txs.isLoading ? (
                        <View style={{ paddingVertical: 40, alignItems: 'center' }}>
                            <ActivityIndicator color={KITAMO.brand} />
                        </View>
                    ) : isEmpty ? (
                        <EmptyTxs />
                    ) : (
                        dayGroups.map(([day, group]) => (
                            <View key={day}>
                                <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', paddingTop: 18, paddingBottom: 8 }}>
                                    <Text style={{ fontSize: 11, color: KITAMO.muted, fontWeight: '700', letterSpacing: 0.4 }}>
                                        {formatDayLabel(day)}
                                    </Text>
                                    <Text style={{ fontSize: 12, color: KITAMO.muted, fontWeight: '600' }}>
                                        R$ {group.total.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
                                    </Text>
                                </View>
                                {group.items.map((t) => {
                                    const cat = (cats.data ?? []).find((c) => c.id === t.category_id);
                                    return (
                                        <Pressable
                                            key={t.id}
                                            onPress={() => router.push({ pathname: '/transaction/[id]', params: { id: String(t.id) } })}
                                            style={({ pressed }) => ({
                                                flexDirection: 'row',
                                                alignItems: 'center',
                                                gap: 12,
                                                padding: 12,
                                                backgroundColor: '#fff',
                                                borderRadius: 14,
                                                marginBottom: 8,
                                                shadowColor: '#0F172A',
                                                shadowOffset: { width: 0, height: 1 },
                                                shadowOpacity: 0.03,
                                                shadowRadius: 3,
                                                elevation: 1,
                                                opacity: pressed ? 0.85 : 1,
                                            })}
                                        >
                                            <CatIcon
                                                name={cat?.icon as any ?? (t.kind === 'income' ? 'recv' : 'tag')}
                                                color={cat?.color ?? (t.kind === 'income' ? KITAMO.success : KITAMO.muted)}
                                                size={40}
                                            />
                                            <View style={{ flex: 1 }}>
                                                <Text style={{ fontSize: 15, fontWeight: '700', color: KITAMO.ink }} numberOfLines={1}>
                                                    {t.description}
                                                </Text>
                                                <Text style={{ fontSize: 12, color: KITAMO.muted, marginTop: 1 }}>
                                                    {cat?.name ?? 'Sem categoria'}
                                                </Text>
                                            </View>
                                            <Text style={{ fontSize: 16, fontWeight: '800', color: t.kind === 'income' ? KITAMO.success : KITAMO.ink }}>
                                                {t.kind === 'income' ? '+ ' : '- '}R$ {t.amount.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
                                            </Text>
                                        </Pressable>
                                    );
                                })}
                            </View>
                        ))
                    )}
                </View>
            </ScrollView>

            <TabBar active="gastos" onTab={navigateToTab} />
        </Screen>
    );
}

function SumCard({ label, value, color, highlight }: { label: string; value: number; color: string; highlight?: boolean }): React.JSX.Element {
    return (
        <View
            style={{
                flex: 1,
                paddingVertical: 12,
                paddingHorizontal: 12,
                borderRadius: 14,
                backgroundColor: highlight ? color : '#fff',
                shadowColor: '#0F172A',
                shadowOffset: { width: 0, height: 2 },
                shadowOpacity: 0.04,
                shadowRadius: 8,
                elevation: 1,
            }}
        >
            <Text style={{ fontSize: 11, color: highlight ? 'rgba(255,255,255,0.85)' : KITAMO.muted, fontWeight: '600' }}>{label}</Text>
            <Text style={{ fontSize: 18, fontWeight: '800', marginTop: 3, letterSpacing: -0.4, color: highlight ? '#fff' : KITAMO.ink }}>
                R$ {Math.abs(value).toLocaleString('pt-BR', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}
            </Text>
        </View>
    );
}

type Slice = {
    category_id: number | null;
    category_name: string;
    category_color: string | null;
    total: number;
    percentage: number;
};

function PieCard({ slices }: { slices: Slice[] }): React.JSX.Element {
    const total = slices.reduce((s, x) => s + x.total, 0);
    const SIZE = 168;
    const RADIUS = 78;
    const STROKE = 24;
    const C = 2 * Math.PI * RADIUS;

    let cumulative = 0;
    const palette = ['#33D6C5', '#F59E0B', '#3B82F6', '#8B5CF6', '#EC4899', '#94A3B8'];

    return (
        <View
            style={{
                marginHorizontal: 16,
                marginTop: 14,
                paddingVertical: 18,
                paddingHorizontal: 18,
                backgroundColor: '#fff',
                borderRadius: 18,
                shadowColor: '#0F172A',
                shadowOffset: { width: 0, height: 2 },
                shadowOpacity: 0.04,
                shadowRadius: 8,
                elevation: 1,
            }}
        >
            <Text style={{ fontSize: 13, fontWeight: '700', color: KITAMO.ink, marginBottom: 14 }}>Onde foi sua grana?</Text>
            <View style={{ flexDirection: 'row', alignItems: 'center' }}>
                <View style={{ width: SIZE, height: SIZE, alignItems: 'center', justifyContent: 'center' }}>
                    <Svg width={SIZE} height={SIZE} viewBox={`0 0 ${SIZE} ${SIZE}`}>
                        <G rotation={-90} originX={SIZE / 2} originY={SIZE / 2}>
                            <Circle cx={SIZE / 2} cy={SIZE / 2} r={RADIUS} stroke={KITAMO.line2} strokeWidth={STROKE} fill="none" />
                            {slices.map((slice, i) => {
                                const color = slice.category_color ?? palette[i % palette.length];
                                const length = total > 0 ? (slice.total / total) * C : 0;
                                const offset = total > 0 ? (cumulative / total) * C : 0;
                                cumulative += slice.total;
                                return (
                                    <Circle
                                        key={`${slice.category_id ?? 'none'}-${i}`}
                                        cx={SIZE / 2}
                                        cy={SIZE / 2}
                                        r={RADIUS}
                                        stroke={color}
                                        strokeWidth={STROKE}
                                        strokeDasharray={`${length} ${C - length}`}
                                        strokeDashoffset={-offset}
                                        fill="none"
                                        strokeLinecap="butt"
                                    />
                                );
                            })}
                        </G>
                    </Svg>
                    <View style={{ position: 'absolute', alignItems: 'center' }}>
                        <Text style={{ fontSize: 11, color: KITAMO.muted, fontWeight: '700' }}>TOTAL GASTO</Text>
                        <Text style={{ fontSize: 16, fontWeight: '800', color: KITAMO.ink, marginTop: 2 }}>
                            R$ {total.toLocaleString('pt-BR', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}
                        </Text>
                    </View>
                </View>
                <View style={{ flex: 1, marginLeft: 14 }}>
                    {slices.slice(0, 5).map((s, i) => (
                        <View key={`legend-${i}`} style={{ flexDirection: 'row', alignItems: 'center', marginBottom: 8 }}>
                            <View style={{ width: 10, height: 10, borderRadius: 5, backgroundColor: s.category_color ?? palette[i % palette.length], marginRight: 8 }} />
                            <Text style={{ fontSize: 12, fontWeight: '600', color: KITAMO.ink, flex: 1 }} numberOfLines={1}>
                                {s.category_name}
                            </Text>
                            <Text style={{ fontSize: 11, color: KITAMO.muted, fontWeight: '700', marginLeft: 4 }}>
                                {Math.round(s.percentage)}%
                            </Text>
                        </View>
                    ))}
                </View>
            </View>
        </View>
    );
}

function EmptyTxs(): React.JSX.Element {
    return (
        <View style={{ paddingVertical: 60, alignItems: 'center' }}>
            <Icon name="tag" size={40} color={KITAMO.line} />
            <Text style={{ fontSize: 22, fontWeight: '800', marginTop: 18, color: KITAMO.ink }}>Cadê a grana?</Text>
            <Text style={{ fontSize: 14, color: KITAMO.ink2, marginTop: 10, textAlign: 'center', lineHeight: 22, paddingHorizontal: 28 }}>
                Bora começar lançando seu primeiro gasto. Em 10 segundos você já entende pra onde vai a grana.
            </Text>
            <Pressable
                onPress={() => router.push({ pathname: '/add', params: { kind: 'out' } })}
                style={({ pressed }) => ({
                    marginTop: 24,
                    paddingHorizontal: 28,
                    height: 52,
                    borderRadius: 14,
                    backgroundColor: KITAMO.brand,
                    alignItems: 'center',
                    justifyContent: 'center',
                    opacity: pressed ? 0.85 : 1,
                })}
            >
                <Text style={{ color: '#fff', fontSize: 15, fontWeight: '700' }}>Lançar agora</Text>
            </Pressable>
        </View>
    );
}

function formatDayLabel(date: string): string {
    const d = new Date(date + 'T00:00:00');
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const yesterday = new Date(today);
    yesterday.setDate(today.getDate() - 1);

    if (d.getTime() === today.getTime()) {
        return `HOJE · ${d.toLocaleDateString('pt-BR', { day: 'numeric', month: 'short' }).toUpperCase()}`;
    }
    if (d.getTime() === yesterday.getTime()) {
        return `ONTEM · ${d.toLocaleDateString('pt-BR', { day: 'numeric', month: 'short' }).toUpperCase()}`;
    }
    return d.toLocaleDateString('pt-BR', { day: 'numeric', month: 'short' }).toUpperCase();
}
