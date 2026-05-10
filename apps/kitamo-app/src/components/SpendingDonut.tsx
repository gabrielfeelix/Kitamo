import React, { useMemo, useState } from 'react';
import { Modal, Pressable, ScrollView, Text, View } from 'react-native';
import Svg, { Circle, G, Path } from 'react-native-svg';

import { Icon } from '@/components/Icon';
import { KITAMO } from '@/theme/tokens';

export type DonutSlice = {
    category_id: number | null;
    category_name: string;
    category_color: string | null;
    total: number;
    percentage: number;
};

type Props = {
    slices: DonutSlice[];
    title?: string;
    style?: object;
    onSlicePress?: (slice: DonutSlice) => void;
    size?: number;
};

const PALETTE = ['#33D6C5', '#F59E0B', '#3B82F6', '#8B5CF6', '#EC4899', '#94A3B8', '#10B981', '#EF4444'];

const GAP_DEG = 1.2;

function polar(cx: number, cy: number, r: number, angleDeg: number): { x: number; y: number } {
    const rad = ((angleDeg - 90) * Math.PI) / 180;
    return { x: cx + r * Math.cos(rad), y: cy + r * Math.sin(rad) };
}

function donutPath(cx: number, cy: number, rOuter: number, rInner: number, startAngle: number, endAngle: number): string {
    const largeArc = endAngle - startAngle > 180 ? 1 : 0;
    const sOuter = polar(cx, cy, rOuter, startAngle);
    const eOuter = polar(cx, cy, rOuter, endAngle);
    const sInner = polar(cx, cy, rInner, endAngle);
    const eInner = polar(cx, cy, rInner, startAngle);
    return [
        `M ${sOuter.x} ${sOuter.y}`,
        `A ${rOuter} ${rOuter} 0 ${largeArc} 1 ${eOuter.x} ${eOuter.y}`,
        `L ${sInner.x} ${sInner.y}`,
        `A ${rInner} ${rInner} 0 ${largeArc} 0 ${eInner.x} ${eInner.y}`,
        'Z',
    ].join(' ');
}

export function SpendingDonut({ slices, title = 'Onde foi sua grana?', style, onSlicePress, size = 168 }: Props): React.JSX.Element | null {
    const [internalSelected, setInternalSelected] = useState<DonutSlice | null>(null);
    const total = slices.reduce((s, x) => s + x.total, 0);

    const computed = useMemo(() => {
        if (total <= 0 || slices.length === 0) return [] as Array<DonutSlice & { color: string; startAngle: number; endAngle: number }>;
        let cursor = 0;
        return slices.map((slice, i) => {
            const sweep = (slice.total / total) * 360;
            const startAngle = cursor + GAP_DEG / 2;
            const endAngle = cursor + sweep - GAP_DEG / 2;
            cursor += sweep;
            return {
                ...slice,
                color: slice.category_color ?? PALETTE[i % PALETTE.length],
                startAngle,
                endAngle,
            };
        });
    }, [slices, total]);

    if (total <= 0 || computed.length === 0) return null;

    const cx = size / 2;
    const cy = size / 2;
    const rOuter = size / 2 - 4;
    const rInner = size / 2 - 28;

    const handlePress = (slice: DonutSlice): void => {
        if (onSlicePress) onSlicePress(slice);
        else setInternalSelected(slice);
    };

    return (
        <View
            style={[
                {
                    paddingVertical: 18,
                    paddingHorizontal: 18,
                    backgroundColor: '#fff',
                    borderRadius: 18,
                    shadowColor: '#0F172A',
                    shadowOffset: { width: 0, height: 2 },
                    shadowOpacity: 0.04,
                    shadowRadius: 8,
                    elevation: 1,
                },
                style as any,
            ]}
        >
            <Text style={{ fontSize: 13, fontWeight: '700', color: KITAMO.ink, marginBottom: 14 }}>{title}</Text>
            <View style={{ flexDirection: 'row', alignItems: 'center' }}>
                <View style={{ width: size, height: size, alignItems: 'center', justifyContent: 'center' }}>
                    <Svg width={size} height={size} viewBox={`0 0 ${size} ${size}`}>
                        <G>
                            <Circle cx={cx} cy={cy} r={(rOuter + rInner) / 2} stroke={KITAMO.line2} strokeWidth={rOuter - rInner} fill="none" />
                            {computed.map((slice, i) => (
                                <Path
                                    key={`slice-${slice.category_id ?? 'none'}-${i}`}
                                    d={donutPath(cx, cy, rOuter, rInner, slice.startAngle, slice.endAngle)}
                                    fill={slice.color}
                                    onPress={() => handlePress(slice)}
                                />
                            ))}
                        </G>
                    </Svg>
                    <View pointerEvents="none" style={{ position: 'absolute', alignItems: 'center' }}>
                        <Text style={{ fontSize: 10, color: KITAMO.muted, fontWeight: '700', letterSpacing: 0.4 }}>TOTAL GASTO</Text>
                        <Text style={{ fontSize: 16, fontWeight: '800', color: KITAMO.ink, marginTop: 2 }}>
                            R$ {total.toLocaleString('pt-BR', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}
                        </Text>
                    </View>
                </View>
                <View style={{ flex: 1, marginLeft: 14 }}>
                    {computed.slice(0, 5).map((s, i) => (
                        <Pressable
                            key={`legend-${s.category_id ?? 'none'}-${i}`}
                            onPress={() => handlePress(s)}
                            hitSlop={6}
                            style={({ pressed }) => ({ flexDirection: 'row', alignItems: 'center', marginBottom: 8, opacity: pressed ? 0.6 : 1 })}
                        >
                            <View style={{ width: 10, height: 10, borderRadius: 5, backgroundColor: s.color, marginRight: 8 }} />
                            <Text style={{ fontSize: 12, fontWeight: '600', color: KITAMO.ink, flex: 1 }} numberOfLines={1}>
                                {s.category_name}
                            </Text>
                            <Text style={{ fontSize: 11, color: KITAMO.muted, fontWeight: '700', marginLeft: 4 }}>
                                {Math.round(s.percentage)}%
                            </Text>
                        </Pressable>
                    ))}
                </View>
            </View>

            <SliceDetailModal
                slice={internalSelected}
                total={total}
                color={internalSelected ? (computed.find((c) => c.category_id === internalSelected.category_id)?.color ?? KITAMO.brand) : KITAMO.brand}
                onClose={() => setInternalSelected(null)}
            />
        </View>
    );
}

function SliceDetailModal({
    slice,
    total,
    color,
    onClose,
}: {
    slice: DonutSlice | null;
    total: number;
    color: string;
    onClose: () => void;
}): React.JSX.Element {
    const open = slice !== null;
    return (
        <Modal visible={open} transparent animationType="fade" onRequestClose={onClose}>
            <Pressable onPress={onClose} style={{ flex: 1, backgroundColor: 'rgba(15,23,42,0.5)', justifyContent: 'flex-end' }}>
                <Pressable onPress={() => undefined} style={{ backgroundColor: '#fff', borderTopLeftRadius: 24, borderTopRightRadius: 24, padding: 22, paddingBottom: 36 }}>
                    <View style={{ width: 40, height: 4, borderRadius: 2, backgroundColor: KITAMO.line, alignSelf: 'center', marginBottom: 16 }} />
                    {slice ? (
                        <ScrollView showsVerticalScrollIndicator={false}>
                            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12 }}>
                                <View style={{ width: 44, height: 44, borderRadius: 14, backgroundColor: color + '22', alignItems: 'center', justifyContent: 'center' }}>
                                    <View style={{ width: 16, height: 16, borderRadius: 8, backgroundColor: color }} />
                                </View>
                                <View style={{ flex: 1 }}>
                                    <Text style={{ fontSize: 12, color: KITAMO.muted, fontWeight: '700', letterSpacing: 0.4 }}>CATEGORIA</Text>
                                    <Text style={{ fontSize: 18, fontWeight: '800', color: KITAMO.ink, marginTop: 2 }}>{slice.category_name}</Text>
                                </View>
                                <Pressable onPress={onClose} hitSlop={10} style={{ width: 32, height: 32, borderRadius: 16, backgroundColor: KITAMO.line2, alignItems: 'center', justifyContent: 'center' }}>
                                    <Icon name="close" size={16} color={KITAMO.ink} />
                                </Pressable>
                            </View>

                            <View style={{ marginTop: 22, padding: 18, borderRadius: 16, backgroundColor: KITAMO.bg }}>
                                <Text style={{ fontSize: 12, color: KITAMO.muted, fontWeight: '700', letterSpacing: 0.4 }}>QUANTO FOI</Text>
                                <Text style={{ fontSize: 28, fontWeight: '800', color: KITAMO.ink, marginTop: 4 }}>
                                    R$ {slice.total.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                                </Text>
                                <Text style={{ fontSize: 13, color: KITAMO.ink2, marginTop: 6 }}>
                                    Isso é{' '}
                                    <Text style={{ fontWeight: '800', color }}>
                                        {Math.round(slice.percentage)}%
                                    </Text>{' '}
                                    de tudo que saiu — R$ {total.toLocaleString('pt-BR', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}.
                                </Text>
                            </View>

                            <View style={{ marginTop: 16, padding: 16, borderRadius: 16, borderWidth: 1, borderColor: KITAMO.line2 }}>
                                <Text style={{ fontSize: 13, color: KITAMO.ink2, lineHeight: 20 }}>
                                    Pra ver os lançamentos dessa categoria, abre a aba <Text style={{ fontWeight: '700' }}>Gastos</Text> — todos os lançamentos do mês ficam ali separados por dia.
                                </Text>
                            </View>
                        </ScrollView>
                    ) : null}
                </Pressable>
            </Pressable>
        </Modal>
    );
}
