import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { router } from 'expo-router';
import React, { useState } from 'react';
import { ActivityIndicator, Alert, Modal, Pressable, ScrollView, Text, TextInput, View } from 'react-native';
import { KeyboardAwareScrollView } from 'react-native-keyboard-controller';

import { extractApiError } from '@/api/client';
import { goalsApi } from '@/api/endpoints';
import { Button } from '@/components/Button';
import { Icon } from '@/components/Icon';
import { Screen } from '@/components/Screen';
import { formatBRLInput, parseBRLInput, todayISO } from '@/lib/format';
import { KITAMO } from '@/theme/tokens';

const ICON_CHOICES = ['✈️', '📱', '🎓', '🚗', '🏠', '💍', '🎮', '⛱️'];

export default function Metas(): React.JSX.Element {
    const [createOpen, setCreateOpen] = useState(false);
    const [depositGoalId, setDepositGoalId] = useState<number | null>(null);
    const qc = useQueryClient();

    const goals = useQuery({ queryKey: ['goals'], queryFn: () => goalsApi.list() });

    const total = (goals.data ?? []).reduce(
        (acc, g) => ({ saved: acc.saved + g.current_amount, target: acc.target + g.target_amount }),
        { saved: 0, target: 0 },
    );
    const totalPct = total.target ? Math.min((total.saved / total.target) * 100, 100) : 0;

    return (
        <Screen bg={KITAMO.bg} edges={['top', 'bottom']}>
            <View style={{ paddingHorizontal: 16, paddingTop: 8, flexDirection: 'row', alignItems: 'center', gap: 10 }}>
                <Pressable
                    onPress={() => router.back()}
                    style={{ width: 36, height: 36, borderRadius: 18, backgroundColor: '#fff', alignItems: 'center', justifyContent: 'center' }}
                >
                    <Icon name="back" size={18} color={KITAMO.ink} />
                </Pressable>
                <Text style={{ flex: 1, fontSize: 18, fontWeight: '800', color: KITAMO.ink }}>Metas</Text>
            </View>

            <ScrollView contentContainerStyle={{ padding: 16, paddingBottom: 60 }} showsVerticalScrollIndicator={false}>
                <View
                    style={{
                        padding: 18,
                        borderRadius: 18,
                        backgroundColor: KITAMO.brand,
                        marginBottom: 14,
                    }}
                >
                    <Text style={{ fontSize: 11, color: '#fff', opacity: 0.85, fontWeight: '700', letterSpacing: 0.3 }}>
                        JUNTANDO PRO QUE IMPORTA
                    </Text>
                    <View style={{ flexDirection: 'row', alignItems: 'baseline', marginTop: 4 }}>
                        <Text style={{ fontSize: 16, color: '#fff', opacity: 0.7, marginRight: 3 }}>R$</Text>
                        <Text style={{ fontSize: 28, fontWeight: '800', letterSpacing: -0.8, color: '#fff' }}>
                            {total.saved.toLocaleString('pt-BR', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}
                        </Text>
                        <Text style={{ fontSize: 14, opacity: 0.7, color: '#fff' }}>
                            {' '}
                            / {total.target.toLocaleString('pt-BR', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}
                        </Text>
                    </View>
                    <Text style={{ fontSize: 12, opacity: 0.9, color: '#fff', marginTop: 4 }}>
                        {(goals.data ?? []).length} metas ativas · {Math.round(totalPct)}% do total
                    </Text>
                    <View style={{ height: 6, backgroundColor: 'rgba(255,255,255,0.2)', borderRadius: 3, marginTop: 12, overflow: 'hidden' }}>
                        <View style={{ width: `${totalPct}%`, height: '100%', backgroundColor: '#fff', borderRadius: 3 }} />
                    </View>
                </View>

                {goals.isLoading ? (
                    <View style={{ paddingVertical: 40, alignItems: 'center' }}>
                        <ActivityIndicator color={KITAMO.brand} />
                    </View>
                ) : (goals.data ?? []).length === 0 ? (
                    <Text style={{ paddingVertical: 30, textAlign: 'center', color: KITAMO.muted }}>
                        Sem metas ainda. Toque em "Criar nova meta" pra começar.
                    </Text>
                ) : (
                    (goals.data ?? []).map((g) => (
                        <GoalCard key={g.id} goal={g} onDeposit={() => setDepositGoalId(g.id)} />
                    ))
                )}

                <Pressable
                    onPress={() => setCreateOpen(true)}
                    style={{
                        paddingVertical: 16,
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
                    <Text style={{ color: KITAMO.brandDark, fontSize: 14, fontWeight: '700' }}>Criar nova meta</Text>
                </Pressable>
            </ScrollView>

            <Modal visible={createOpen} animationType="slide" presentationStyle="pageSheet" onRequestClose={() => setCreateOpen(false)}>
                <CreateGoalForm onClose={() => setCreateOpen(false)} onCreated={() => {
                    setCreateOpen(false);
                    void qc.invalidateQueries({ queryKey: ['goals'] });
                }} />
            </Modal>

            <Modal visible={depositGoalId !== null} animationType="slide" presentationStyle="pageSheet" onRequestClose={() => setDepositGoalId(null)}>
                {depositGoalId !== null ? (
                    <DepositForm
                        goalId={depositGoalId}
                        onClose={() => setDepositGoalId(null)}
                        onDone={() => {
                            setDepositGoalId(null);
                            void qc.invalidateQueries({ queryKey: ['goals'] });
                        }}
                    />
                ) : null}
            </Modal>
        </Screen>
    );
}

function GoalCard({ goal, onDeposit }: { goal: any; onDeposit: () => void }): React.JSX.Element {
    const qc = useQueryClient();
    const removeMut = useMutation({
        mutationFn: () => goalsApi.remove(goal.id),
        onSuccess: () => qc.invalidateQueries({ queryKey: ['goals'] }),
        onError: (e) => Alert.alert('Erro', extractApiError(e)),
    });

    function confirmRemove(): void {
        Alert.alert('Apagar meta?', `"${goal.title}" e seus depósitos serão removidos.`, [
            { text: 'Cancelar', style: 'cancel' },
            { text: 'Apagar', style: 'destructive', onPress: () => removeMut.mutate() },
        ]);
    }

    const pct = goal.target_amount ? Math.min((goal.current_amount / goal.target_amount) * 100, 100) : 0;
    const emoji = goal.icon ?? '🎯';

    return (
        <View
            style={{
                padding: 14,
                backgroundColor: '#fff',
                borderRadius: 16,
                marginBottom: 8,
                shadowColor: '#0F172A',
                shadowOffset: { width: 0, height: 1 },
                shadowOpacity: 0.04,
                shadowRadius: 3,
                elevation: 1,
            }}
        >
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12 }}>
                <View style={{ width: 42, height: 42, borderRadius: 12, backgroundColor: KITAMO.line2, alignItems: 'center', justifyContent: 'center' }}>
                    <Text style={{ fontSize: 22 }}>{emoji}</Text>
                </View>
                <View style={{ flex: 1 }}>
                    <Text style={{ fontSize: 14, fontWeight: '700', color: KITAMO.ink }}>{goal.title}</Text>
                    <Text style={{ fontSize: 11, color: KITAMO.muted, marginTop: 1 }}>
                        {goal.due_date ? `até ${goal.due_date}` : 'sem prazo'}
                    </Text>
                </View>
                <View style={{ alignItems: 'flex-end' }}>
                    <Text style={{ fontSize: 14, fontWeight: '800', color: KITAMO.ink }}>
                        R$ {goal.current_amount.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
                    </Text>
                    <Text style={{ fontSize: 10, color: KITAMO.muted }}>
                        de R$ {goal.target_amount.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
                    </Text>
                </View>
            </View>
            <View style={{ marginTop: 10, height: 8, backgroundColor: KITAMO.line2, borderRadius: 4, overflow: 'hidden' }}>
                <View style={{ width: `${pct}%`, height: '100%', backgroundColor: KITAMO.brand, borderRadius: 4 }} />
            </View>
            <View style={{ flexDirection: 'row', gap: 8, marginTop: 12 }}>
                <Pressable
                    onPress={onDeposit}
                    style={{ flex: 1, paddingVertical: 10, borderRadius: 10, backgroundColor: KITAMO.brandSoft, alignItems: 'center' }}
                >
                    <Text style={{ color: KITAMO.brandDark, fontSize: 12, fontWeight: '700' }}>Depositar</Text>
                </Pressable>
                <Pressable
                    onPress={confirmRemove}
                    style={{ paddingHorizontal: 14, paddingVertical: 10, borderRadius: 10, backgroundColor: '#FEE2E2', alignItems: 'center' }}
                >
                    <Text style={{ color: KITAMO.danger, fontSize: 12, fontWeight: '700' }}>Apagar</Text>
                </Pressable>
            </View>
        </View>
    );
}

function CreateGoalForm({ onClose, onCreated }: { onClose: () => void; onCreated: () => void }): React.JSX.Element {
    const [title, setTitle] = useState('');
    const [target, setTarget] = useState(0);
    const [icon, setIcon] = useState(ICON_CHOICES[0]);
    const [dueDate, setDueDate] = useState('');

    const mut = useMutation({
        mutationFn: () =>
            goalsApi.create({
                title: title.trim(),
                target_amount: target,
                due_date: dueDate || undefined,
                icon,
                color: KITAMO.brand,
            }),
        onSuccess: onCreated,
        onError: (e) => Alert.alert('Erro', extractApiError(e)),
    });

    return (
        <KeyboardAwareScrollView style={{ flex: 1, backgroundColor: '#fff' }} contentContainerStyle={{ padding: 24 }}>
            <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: 20 }}>
                <Text style={{ fontSize: 22, fontWeight: '800', color: KITAMO.ink }}>Nova meta</Text>
                <Pressable onPress={onClose} hitSlop={10}>
                    <Icon name="close" size={22} color={KITAMO.ink} />
                </Pressable>
            </View>

            <Text style={{ fontSize: 12, color: KITAMO.muted, fontWeight: '700', marginBottom: 6 }}>NOME</Text>
            <TextInput
                value={title}
                onChangeText={setTitle}
                placeholder="Viagem pra Bahia"
                placeholderTextColor={KITAMO.muted}
                style={{ borderWidth: 1.5, borderColor: KITAMO.line, borderRadius: 12, padding: 12, fontSize: 16, color: KITAMO.ink }}
            />

            <Text style={{ fontSize: 12, color: KITAMO.muted, fontWeight: '700', marginTop: 18, marginBottom: 8 }}>ÍCONE</Text>
            <View style={{ flexDirection: 'row', gap: 8, flexWrap: 'wrap' }}>
                {ICON_CHOICES.map((ic) => {
                    const on = icon === ic;
                    return (
                        <Pressable
                            key={ic}
                            onPress={() => setIcon(ic)}
                            style={{
                                width: 48,
                                height: 48,
                                borderRadius: 12,
                                backgroundColor: on ? KITAMO.brandSoft : KITAMO.line2,
                                borderWidth: on ? 2 : 0,
                                borderColor: KITAMO.brand,
                                alignItems: 'center',
                                justifyContent: 'center',
                            }}
                        >
                            <Text style={{ fontSize: 22 }}>{ic}</Text>
                        </Pressable>
                    );
                })}
            </View>

            <Text style={{ fontSize: 12, color: KITAMO.muted, fontWeight: '700', marginTop: 18, marginBottom: 6 }}>QUANTO?</Text>
            <View style={{ flexDirection: 'row', alignItems: 'baseline', borderWidth: 1.5, borderColor: KITAMO.line, borderRadius: 12, padding: 12 }}>
                <Text style={{ fontSize: 14, color: KITAMO.muted, marginRight: 4 }}>R$</Text>
                <TextInput
                    value={formatBRLInput(target)}
                    onChangeText={(t) => setTarget(parseBRLInput(t))}
                    keyboardType="numeric"
                    style={{ fontSize: 18, fontWeight: '700', color: KITAMO.ink, flex: 1, paddingVertical: 0 }}
                />
            </View>

            <Text style={{ fontSize: 12, color: KITAMO.muted, fontWeight: '700', marginTop: 18, marginBottom: 6 }}>PRAZO (OPCIONAL · YYYY-MM-DD)</Text>
            <TextInput
                value={dueDate}
                onChangeText={setDueDate}
                placeholder="2026-12-31"
                placeholderTextColor={KITAMO.muted}
                style={{ borderWidth: 1.5, borderColor: KITAMO.line, borderRadius: 12, padding: 12, fontSize: 16, color: KITAMO.ink }}
            />

            <View style={{ marginTop: 28 }}>
                <Button onPress={() => mut.mutate()} loading={mut.isPending}>
                    Criar meta
                </Button>
            </View>
        </KeyboardAwareScrollView>
    );
}

function DepositForm({ goalId, onClose, onDone }: { goalId: number; onClose: () => void; onDone: () => void }): React.JSX.Element {
    const [amount, setAmount] = useState(0);
    const [notes, setNotes] = useState('');

    const mut = useMutation({
        mutationFn: () =>
            goalsApi.deposit(goalId, {
                amount,
                notes: notes || undefined,
                deposit_date: todayISO(),
            }),
        onSuccess: onDone,
        onError: (e) => Alert.alert('Erro', extractApiError(e)),
    });

    return (
        <KeyboardAwareScrollView style={{ flex: 1, backgroundColor: '#fff' }} contentContainerStyle={{ padding: 24 }}>
            <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: 20 }}>
                <Text style={{ fontSize: 22, fontWeight: '800', color: KITAMO.ink }}>Depositar</Text>
                <Pressable onPress={onClose} hitSlop={10}>
                    <Icon name="close" size={22} color={KITAMO.ink} />
                </Pressable>
            </View>

            <Text style={{ fontSize: 12, color: KITAMO.muted, fontWeight: '700', marginBottom: 6 }}>VALOR</Text>
            <View style={{ flexDirection: 'row', alignItems: 'baseline', borderWidth: 1.5, borderColor: KITAMO.line, borderRadius: 12, padding: 12 }}>
                <Text style={{ fontSize: 14, color: KITAMO.muted, marginRight: 4 }}>R$</Text>
                <TextInput
                    value={formatBRLInput(amount)}
                    onChangeText={(t) => setAmount(parseBRLInput(t))}
                    keyboardType="numeric"
                    style={{ fontSize: 18, fontWeight: '700', color: KITAMO.ink, flex: 1, paddingVertical: 0 }}
                />
            </View>

            <Text style={{ fontSize: 12, color: KITAMO.muted, fontWeight: '700', marginTop: 18, marginBottom: 6 }}>OBSERVAÇÃO</Text>
            <TextInput
                value={notes}
                onChangeText={setNotes}
                placeholder="Opcional"
                placeholderTextColor={KITAMO.muted}
                style={{ borderWidth: 1.5, borderColor: KITAMO.line, borderRadius: 12, padding: 12, fontSize: 16, color: KITAMO.ink }}
            />

            <View style={{ marginTop: 28 }}>
                <Button onPress={() => mut.mutate()} loading={mut.isPending}>
                    Depositar
                </Button>
            </View>
        </KeyboardAwareScrollView>
    );
}
