import { useMutation, useQueryClient } from '@tanstack/react-query';
import { router } from 'expo-router';
import React, { useState } from 'react';
import { Alert, Pressable, ScrollView, Text, TextInput, View } from 'react-native';
import { KeyboardAwareScrollView } from 'react-native-keyboard-controller';

import { extractApiError } from '@/api/client';
import { accountsApi } from '@/api/endpoints';
import { Button } from '@/components/Button';
import { Icon } from '@/components/Icon';
import { Screen } from '@/components/Screen';
import { formatBRLInput, parseBRLInput } from '@/lib/format';
import { KITAMO } from '@/theme/tokens';

const TYPES = [
    { id: 'fixa', name: 'Renda fixa', sub: 'Tesouro, CDB, LCI', color: '#3B82F6' },
    { id: 'fundos', name: 'Fundos', sub: 'Multi, DI, ações', color: '#8B5CF6' },
    { id: 'poupanca', name: 'Poupança', sub: 'Conta poupança', color: '#10B981' },
    { id: 'outro', name: 'Outro', sub: 'Cripto, ações…', color: '#F59E0B' },
];

export default function AddInvest(): React.JSX.Element {
    const [type, setType] = useState(TYPES[0]);
    const [amount, setAmount] = useState(0);
    const [name, setName] = useState('');
    const [institution, setInstitution] = useState('');
    const qc = useQueryClient();

    const mutation = useMutation({
        mutationFn: () => {
            if (amount <= 0) throw new Error('Valor precisa ser maior que zero.');
            if (!name.trim()) throw new Error('Dá um nome pra esse investimento.');
            return accountsApi.create({
                name: name.trim(),
                type: 'investment',
                institution: institution || null,
                initial_balance: amount,
                current_balance: amount,
                color: type.color,
                icon: 'chart',
            });
        },
        onSuccess: () => {
            void qc.invalidateQueries({ queryKey: ['accounts'] });
            void qc.invalidateQueries({ queryKey: ['dashboard-summary'] });
            router.back();
        },
        onError: (e) => Alert.alert('Erro', extractApiError(e)),
    });

    return (
        <Screen bg="#fff" edges={['top', 'bottom']}>
            <View style={{ paddingHorizontal: 16, paddingTop: 8, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
                <Pressable
                    onPress={() => router.back()}
                    style={{ width: 36, height: 36, borderRadius: 18, backgroundColor: KITAMO.line2, alignItems: 'center', justifyContent: 'center' }}
                >
                    <Icon name="close" size={18} color={KITAMO.ink} />
                </Pressable>
                <Text style={{ fontSize: 15, fontWeight: '700' }}>Novo investimento</Text>
                <View style={{ width: 36 }} />
            </View>

            <KeyboardAwareScrollView style={{ flex: 1 }} contentContainerStyle={{ paddingBottom: 100 }}>
                <View style={{ paddingHorizontal: 16, paddingTop: 18 }}>
                    <Text style={{ fontSize: 12, color: KITAMO.muted, fontWeight: '700', marginBottom: 10 }}>QUE TIPO?</Text>
                    <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
                        {TYPES.map((t) => {
                            const on = type.id === t.id;
                            return (
                                <Pressable
                                    key={t.id}
                                    onPress={() => setType(t)}
                                    style={{
                                        width: '48%',
                                        padding: 14,
                                        borderRadius: 14,
                                        backgroundColor: on ? `${t.color}12` : '#fff',
                                        borderWidth: 1.5,
                                        borderColor: on ? t.color : KITAMO.line,
                                    }}
                                >
                                    <View
                                        style={{
                                            width: 34,
                                            height: 34,
                                            borderRadius: 10,
                                            backgroundColor: `${t.color}20`,
                                            alignItems: 'center',
                                            justifyContent: 'center',
                                        }}
                                    >
                                        <Icon name="chart" size={16} color={t.color} />
                                    </View>
                                    <Text style={{ fontSize: 13, fontWeight: '700', color: KITAMO.ink, marginTop: 8 }}>{t.name}</Text>
                                    <Text style={{ fontSize: 10, color: KITAMO.muted, marginTop: 1 }}>{t.sub}</Text>
                                </Pressable>
                            );
                        })}
                    </View>
                </View>

                <View style={{ paddingHorizontal: 16, paddingTop: 24, alignItems: 'center' }}>
                    <Text style={{ fontSize: 12, color: KITAMO.muted, fontWeight: '600' }}>QUANTO?</Text>
                    <View style={{ flexDirection: 'row', alignItems: 'baseline', marginTop: 4 }}>
                        <Text style={{ fontSize: 20, fontWeight: '600', opacity: 0.7, marginRight: 4, color: KITAMO.brandDark }}>R$</Text>
                        <TextInput
                            value={formatBRLInput(amount)}
                            onChangeText={(t) => setAmount(parseBRLInput(t))}
                            keyboardType="numeric"
                            selectTextOnFocus
                            style={{
                                fontSize: 42,
                                fontWeight: '800',
                                letterSpacing: -1.5,
                                color: KITAMO.brandDark,
                                minWidth: 120,
                                textAlign: 'center',
                                paddingVertical: 0,
                            }}
                        />
                    </View>
                </View>

                <View style={{ paddingHorizontal: 16, paddingTop: 14 }}>
                    <Field label="Nome" value={name} onChangeText={setName} placeholder="Tesouro Selic 2029" />
                    <Field label="Onde tá?" value={institution} onChangeText={setInstitution} placeholder="Nubank, XP..." />
                </View>
            </KeyboardAwareScrollView>

            <View style={{ position: 'absolute', left: 16, right: 16, bottom: 24 }}>
                <Button onPress={() => mutation.mutate()} loading={mutation.isPending}>
                    Adicionar
                </Button>
            </View>
        </Screen>
    );
}

function Field({
    label,
    value,
    onChangeText,
    placeholder,
}: {
    label: string;
    value: string;
    onChangeText: (t: string) => void;
    placeholder?: string;
}): React.JSX.Element {
    return (
        <View style={{ paddingVertical: 14, borderBottomWidth: 1, borderBottomColor: KITAMO.line2 }}>
            <Text style={{ fontSize: 12, color: KITAMO.muted, fontWeight: '700' }}>{label}</Text>
            <TextInput
                value={value}
                onChangeText={onChangeText}
                placeholder={placeholder}
                placeholderTextColor={KITAMO.muted}
                style={{ fontSize: 17, fontWeight: '600', color: KITAMO.ink, marginTop: 6, paddingVertical: 0 }}
            />
        </View>
    );
}
