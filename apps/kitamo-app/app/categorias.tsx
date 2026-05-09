import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { router } from 'expo-router';
import React, { useState } from 'react';
import { ActivityIndicator, Alert, Modal, Pressable, ScrollView, Text, TextInput, View } from 'react-native';
import { KeyboardAwareScrollView } from 'react-native-keyboard-controller';

import { extractApiError } from '@/api/client';
import { categoriesApi } from '@/api/endpoints';
import { Button } from '@/components/Button';
import { Icon, type IconName } from '@/components/Icon';
import { Screen } from '@/components/Screen';
import { formatBRLInput, parseBRLInput } from '@/lib/format';
import { KITAMO } from '@/theme/tokens';

const COLORS = ['#33D6C5', '#F59E0B', '#3B82F6', '#8B5CF6', '#EC4899', '#10B981', '#EF4444', '#94A3B8'];
const ICONS: IconName[] = ['food', 'car', 'house', 'health', 'game', 'bolt', 'tag', 'card'];

type Tab = 'expense' | 'income';

export default function Categorias(): React.JSX.Element {
    const [tab, setTab] = useState<Tab>('expense');
    const [createOpen, setCreateOpen] = useState(false);
    const qc = useQueryClient();

    const cats = useQuery({ queryKey: ['categories'], queryFn: () => categoriesApi.list() });

    const list = (cats.data ?? []).filter((c) => c.type === tab);

    return (
        <Screen bg={KITAMO.bg} edges={['top', 'bottom']}>
            <View style={{ paddingHorizontal: 16, paddingTop: 8, flexDirection: 'row', alignItems: 'center', gap: 10 }}>
                <Pressable
                    onPress={() => router.back()}
                    style={{ width: 36, height: 36, borderRadius: 18, backgroundColor: '#fff', alignItems: 'center', justifyContent: 'center' }}
                >
                    <Icon name="back" size={18} color={KITAMO.ink} />
                </Pressable>
                <Text style={{ flex: 1, fontSize: 18, fontWeight: '800', color: KITAMO.ink }}>Categorias</Text>
                <Pressable
                    onPress={() => setCreateOpen(true)}
                    style={{
                        paddingHorizontal: 12,
                        paddingVertical: 8,
                        borderRadius: 14,
                        backgroundColor: KITAMO.brand,
                        flexDirection: 'row',
                        alignItems: 'center',
                        gap: 4,
                    }}
                >
                    <Icon name="plus" size={14} color="#fff" />
                    <Text style={{ color: '#fff', fontSize: 12, fontWeight: '700' }}>Nova</Text>
                </Pressable>
            </View>

            <View style={{ paddingHorizontal: 16, paddingTop: 14 }}>
                <View style={{ flexDirection: 'row', gap: 6, padding: 4, backgroundColor: KITAMO.line2, borderRadius: 14 }}>
                    {[
                        { id: 'expense' as const, label: 'Saídas' },
                        { id: 'income' as const, label: 'Entradas' },
                    ].map((t) => {
                        const on = tab === t.id;
                        return (
                            <Pressable
                                key={t.id}
                                onPress={() => setTab(t.id)}
                                style={{
                                    flex: 1,
                                    paddingVertical: 8,
                                    borderRadius: 12,
                                    backgroundColor: on ? '#fff' : 'transparent',
                                    alignItems: 'center',
                                }}
                            >
                                <Text style={{ fontSize: 13, fontWeight: '700', color: on ? KITAMO.ink : KITAMO.muted }}>{t.label}</Text>
                            </Pressable>
                        );
                    })}
                </View>
            </View>

            <ScrollView contentContainerStyle={{ padding: 16, gap: 6 }} showsVerticalScrollIndicator={false}>
                {cats.isLoading ? (
                    <View style={{ paddingVertical: 40, alignItems: 'center' }}>
                        <ActivityIndicator color={KITAMO.brand} />
                    </View>
                ) : list.length === 0 ? (
                    <Text style={{ paddingVertical: 30, textAlign: 'center', color: KITAMO.muted }}>Nenhuma categoria nesta aba.</Text>
                ) : (
                    list.map((c) => <CategoryRow key={c.id} cat={c} />)
                )}
            </ScrollView>

            <Modal visible={createOpen} animationType="slide" presentationStyle="pageSheet" onRequestClose={() => setCreateOpen(false)}>
                <CreateCategoryForm
                    type={tab}
                    onClose={() => setCreateOpen(false)}
                    onCreated={() => {
                        setCreateOpen(false);
                        void qc.invalidateQueries({ queryKey: ['categories'] });
                    }}
                />
            </Modal>
        </Screen>
    );
}

function CategoryRow({ cat }: { cat: any }): React.JSX.Element {
    const qc = useQueryClient();
    const [budgetOpen, setBudgetOpen] = useState(false);
    const [budget, setBudget] = useState(cat.budget_limit ?? 0);

    const updateMut = useMutation({
        mutationFn: (newLimit: number | null) => categoriesApi.update(cat.id, { budget_limit: newLimit }),
        onSuccess: () => {
            void qc.invalidateQueries({ queryKey: ['categories'] });
            setBudgetOpen(false);
        },
        onError: (e) => Alert.alert('Erro', extractApiError(e)),
    });

    const removeMut = useMutation({
        mutationFn: () => categoriesApi.remove(cat.id),
        onSuccess: () => qc.invalidateQueries({ queryKey: ['categories'] }),
        onError: (e) => Alert.alert('Erro', extractApiError(e)),
    });

    function confirmRemove(): void {
        if (cat.is_default) {
            Alert.alert('Categoria padrão', 'Categorias padrão não podem ser apagadas.');
            return;
        }
        Alert.alert('Apagar categoria?', `"${cat.name}" será removida.`, [
            { text: 'Cancelar', style: 'cancel' },
            { text: 'Apagar', style: 'destructive', onPress: () => removeMut.mutate() },
        ]);
    }

    const spent = cat.spent_this_month ?? 0;
    const limit = cat.budget_limit;
    const over = limit ? spent > limit : false;
    const pct = limit ? Math.min((spent / limit) * 100, 100) : 0;
    const color = cat.color ?? KITAMO.brand;

    return (
        <View
            style={{
                paddingVertical: 12,
                paddingHorizontal: 14,
                backgroundColor: '#fff',
                borderRadius: 14,
                shadowColor: '#0F172A',
                shadowOffset: { width: 0, height: 1 },
                shadowOpacity: 0.04,
                shadowRadius: 3,
                elevation: 1,
            }}
        >
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12 }}>
                <View
                    style={{
                        width: 40,
                        height: 40,
                        borderRadius: 12,
                        backgroundColor: `${color}18`,
                        alignItems: 'center',
                        justifyContent: 'center',
                    }}
                >
                    <Icon name={(cat.icon as IconName) ?? 'tag'} size={18} color={color} />
                </View>
                <View style={{ flex: 1 }}>
                    <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
                        <Text style={{ fontSize: 14, fontWeight: '700', color: KITAMO.ink }}>{cat.name}</Text>
                        {limit ? (
                            <View
                                style={{
                                    paddingHorizontal: 5,
                                    paddingVertical: 1,
                                    borderRadius: 5,
                                    backgroundColor: over ? '#FEE2E2' : KITAMO.line2,
                                }}
                            >
                                <Text style={{ fontSize: 9, fontWeight: '700', color: over ? KITAMO.danger : KITAMO.muted }}>
                                    {over ? 'PASSOU' : 'COM LIMITE'}
                                </Text>
                            </View>
                        ) : null}
                    </View>
                    <Text style={{ fontSize: 11, color: KITAMO.muted, marginTop: 1 }}>
                        R$ {spent.toLocaleString('pt-BR', { minimumFractionDigits: 2 })} esse mês
                    </Text>
                </View>
                <Pressable onPress={() => setBudgetOpen(true)} hitSlop={8}>
                    <Text style={{ fontSize: 12, fontWeight: '700', color: KITAMO.brandDark }}>{limit ? 'Editar' : 'Definir'}</Text>
                </Pressable>
                {!cat.is_default && cat.user_id !== null ? (
                    <Pressable onPress={confirmRemove} hitSlop={8} style={{ marginLeft: 8 }}>
                        <Icon name="close" size={14} color={KITAMO.muted} />
                    </Pressable>
                ) : null}
            </View>
            {limit ? (
                <View style={{ marginTop: 8, marginLeft: 52 }}>
                    <View style={{ height: 4, backgroundColor: KITAMO.line2, borderRadius: 2, overflow: 'hidden' }}>
                        <View style={{ width: `${pct}%`, height: '100%', backgroundColor: over ? KITAMO.danger : color, borderRadius: 2 }} />
                    </View>
                    <Text style={{ fontSize: 10, color: KITAMO.muted, fontWeight: '600', marginTop: 3 }}>
                        Limite R$ {limit.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
                    </Text>
                </View>
            ) : null}

            <Modal visible={budgetOpen} transparent animationType="fade" onRequestClose={() => setBudgetOpen(false)}>
                <View style={{ flex: 1, backgroundColor: 'rgba(15,23,42,0.5)', justifyContent: 'center', padding: 24 }}>
                    <View style={{ backgroundColor: '#fff', padding: 22, borderRadius: 18 }}>
                        <Text style={{ fontSize: 16, fontWeight: '800', color: KITAMO.ink }}>Limite mensal de "{cat.name}"</Text>
                        <Text style={{ fontSize: 12, color: KITAMO.muted, marginTop: 4 }}>Você é avisada quando passar.</Text>
                        <View style={{ flexDirection: 'row', alignItems: 'baseline', marginTop: 18 }}>
                            <Text style={{ fontSize: 16, color: KITAMO.muted, marginRight: 4 }}>R$</Text>
                            <TextInput
                                value={formatBRLInput(budget)}
                                onChangeText={(t) => setBudget(parseBRLInput(t))}
                                keyboardType="numeric"
                                style={{ fontSize: 28, fontWeight: '800', color: KITAMO.ink, flex: 1, paddingVertical: 0 }}
                                selectTextOnFocus
                            />
                        </View>
                        <View style={{ flexDirection: 'row', gap: 8, marginTop: 18 }}>
                            <Pressable
                                onPress={() => updateMut.mutate(null)}
                                style={{ flex: 1, height: 44, borderRadius: 12, alignItems: 'center', justifyContent: 'center', backgroundColor: KITAMO.line2 }}
                                disabled={updateMut.isPending}
                            >
                                <Text style={{ color: KITAMO.ink2, fontSize: 13, fontWeight: '700' }}>Remover</Text>
                            </Pressable>
                            <Pressable
                                onPress={() => updateMut.mutate(budget > 0 ? budget : null)}
                                style={{ flex: 1, height: 44, borderRadius: 12, alignItems: 'center', justifyContent: 'center', backgroundColor: KITAMO.brand }}
                                disabled={updateMut.isPending}
                            >
                                <Text style={{ color: '#fff', fontSize: 13, fontWeight: '700' }}>{updateMut.isPending ? 'Salvando...' : 'Salvar'}</Text>
                            </Pressable>
                        </View>
                    </View>
                </View>
            </Modal>
        </View>
    );
}

function CreateCategoryForm({
    type,
    onClose,
    onCreated,
}: {
    type: 'expense' | 'income';
    onClose: () => void;
    onCreated: () => void;
}): React.JSX.Element {
    const [name, setName] = useState('');
    const [color, setColor] = useState(COLORS[0]);
    const [icon, setIcon] = useState<IconName>('tag');
    const [budget, setBudget] = useState(0);

    const mut = useMutation({
        mutationFn: () => categoriesApi.create({ name: name.trim(), type, color, icon, budget_limit: budget > 0 ? budget : null }),
        onSuccess: onCreated,
        onError: (e) => Alert.alert('Erro', extractApiError(e)),
    });

    return (
        <KeyboardAwareScrollView style={{ flex: 1, backgroundColor: '#fff' }} contentContainerStyle={{ padding: 24 }}>
            <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: 20 }}>
                <Text style={{ fontSize: 22, fontWeight: '800', color: KITAMO.ink }}>Nova categoria</Text>
                <Pressable onPress={onClose} hitSlop={10}>
                    <Icon name="close" size={22} color={KITAMO.ink} />
                </Pressable>
            </View>

            <Text style={{ fontSize: 12, color: KITAMO.muted, fontWeight: '700', marginBottom: 6 }}>NOME</Text>
            <TextInput
                value={name}
                onChangeText={setName}
                placeholder="Ex: Mercado, gasolina..."
                placeholderTextColor={KITAMO.muted}
                style={{
                    borderWidth: 1.5,
                    borderColor: KITAMO.line,
                    borderRadius: 12,
                    paddingHorizontal: 14,
                    paddingVertical: 12,
                    fontSize: 16,
                    color: KITAMO.ink,
                }}
            />

            <Text style={{ fontSize: 12, color: KITAMO.muted, fontWeight: '700', marginTop: 18, marginBottom: 8 }}>COR</Text>
            <View style={{ flexDirection: 'row', gap: 10, flexWrap: 'wrap' }}>
                {COLORS.map((c) => (
                    <Pressable
                        key={c}
                        onPress={() => setColor(c)}
                        style={{
                            width: 36,
                            height: 36,
                            borderRadius: 18,
                            backgroundColor: c,
                            borderWidth: color === c ? 3 : 0,
                            borderColor: '#fff',
                            shadowColor: c,
                            shadowOffset: { width: 0, height: 2 },
                            shadowOpacity: color === c ? 0.5 : 0,
                            shadowRadius: 6,
                            elevation: color === c ? 4 : 0,
                        }}
                    />
                ))}
            </View>

            <Text style={{ fontSize: 12, color: KITAMO.muted, fontWeight: '700', marginTop: 18, marginBottom: 8 }}>ÍCONE</Text>
            <View style={{ flexDirection: 'row', gap: 10, flexWrap: 'wrap' }}>
                {ICONS.map((ic) => {
                    const on = icon === ic;
                    return (
                        <Pressable
                            key={ic}
                            onPress={() => setIcon(ic)}
                            style={{
                                width: 48,
                                height: 48,
                                borderRadius: 12,
                                backgroundColor: on ? `${color}18` : KITAMO.line2,
                                borderWidth: on ? 1.5 : 0,
                                borderColor: color,
                                alignItems: 'center',
                                justifyContent: 'center',
                            }}
                        >
                            <Icon name={ic} size={20} color={on ? color : KITAMO.muted} />
                        </Pressable>
                    );
                })}
            </View>

            <Text style={{ fontSize: 12, color: KITAMO.muted, fontWeight: '700', marginTop: 18, marginBottom: 8 }}>LIMITE MENSAL (OPCIONAL)</Text>
            <View
                style={{
                    flexDirection: 'row',
                    alignItems: 'baseline',
                    borderWidth: 1.5,
                    borderColor: KITAMO.line,
                    borderRadius: 12,
                    paddingHorizontal: 14,
                    paddingVertical: 12,
                }}
            >
                <Text style={{ fontSize: 14, color: KITAMO.muted, marginRight: 4 }}>R$</Text>
                <TextInput
                    value={formatBRLInput(budget)}
                    onChangeText={(t) => setBudget(parseBRLInput(t))}
                    keyboardType="numeric"
                    style={{ fontSize: 16, color: KITAMO.ink, flex: 1, paddingVertical: 0 }}
                    selectTextOnFocus
                />
            </View>

            <View style={{ marginTop: 28 }}>
                <Button onPress={() => mut.mutate()} loading={mut.isPending}>
                    Criar categoria
                </Button>
            </View>
        </KeyboardAwareScrollView>
    );
}
