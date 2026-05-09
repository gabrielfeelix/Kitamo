import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { router, useLocalSearchParams } from 'expo-router';
import React, { useEffect, useMemo, useState } from 'react';
import { Alert, Pressable, ScrollView, Text, TextInput, View } from 'react-native';
import { KeyboardAwareScrollView } from 'react-native-keyboard-controller';

import { extractApiError } from '@/api/client';
import { accountsApi, categoriesApi, transactionsApi, transfersApi } from '@/api/endpoints';
import { BankAvatar } from '@/components/Avatar';
import { Button } from '@/components/Button';
import { Icon, type IconName } from '@/components/Icon';
import { Screen } from '@/components/Screen';
import { formatBRLInput, parseBRLInput, todayISO } from '@/lib/format';
import { KITAMO } from '@/theme/tokens';

type Kind = 'out' | 'in' | 'mov';

const KIND_DEFS: { id: Kind; label: string; emoji: string; color: string }[] = [
    { id: 'out', label: 'Saiu', emoji: '💸', color: KITAMO.danger },
    { id: 'in', label: 'Entrou', emoji: '💰', color: KITAMO.success },
    { id: 'mov', label: 'Transferi', emoji: '🔄', color: KITAMO.info },
];

const CAT_ICONS: { name: string; icon: IconName }[] = [
    { name: 'comida', icon: 'food' },
    { name: 'alimentação', icon: 'food' },
    { name: 'transporte', icon: 'car' },
    { name: 'casa', icon: 'house' },
    { name: 'moradia', icon: 'house' },
    { name: 'saúde', icon: 'health' },
    { name: 'lazer', icon: 'game' },
];

export default function Add(): React.JSX.Element {
    const params = useLocalSearchParams<{ kind?: string }>();
    const initialKind = (params.kind === 'in' || params.kind === 'mov' ? params.kind : 'out') as Kind;
    const [kind, setKind] = useState<Kind>(initialKind);
    const [amount, setAmount] = useState(0);
    const [description, setDescription] = useState('');
    const [accountId, setAccountId] = useState<number | null>(null);
    const [toAccountId, setToAccountId] = useState<number | null>(null);
    const [categoryId, setCategoryId] = useState<number | null>(null);
    const [date] = useState(() => todayISO());
    const [notes, setNotes] = useState('');
    const qc = useQueryClient();

    const accounts = useQuery({ queryKey: ['accounts'], queryFn: () => accountsApi.list() });
    const cats = useQuery({ queryKey: ['categories'], queryFn: () => categoriesApi.list() });

    const accentColor = KIND_DEFS.find((k) => k.id === kind)!.color;

    useEffect(() => {
        if (!accountId && accounts.data?.length) {
            setAccountId(accounts.data[0].id);
        }
        if (!toAccountId && accounts.data && accounts.data.length > 1) {
            setToAccountId(accounts.data[1].id);
        }
    }, [accounts.data, accountId, toAccountId]);

    const filteredCats = useMemo(() => {
        if (!cats.data) return [];
        return cats.data.filter((c) => c.type === (kind === 'in' ? 'income' : 'expense')).slice(0, 12);
    }, [cats.data, kind]);

    const mutation = useMutation({
        mutationFn: async () => {
            if (amount <= 0) throw new Error('Valor precisa ser maior que zero.');
            if (!accountId) throw new Error('Selecione uma conta.');
            if (kind === 'mov') {
                if (!toAccountId) throw new Error('Selecione a conta de destino.');
                if (toAccountId === accountId) throw new Error('Conta destino precisa ser diferente.');
                return transfersApi.create({
                    from_account_id: accountId,
                    to_account_id: toAccountId,
                    amount,
                    transaction_date: date,
                    notes: notes || undefined,
                });
            }
            return transactionsApi.create({
                account_id: accountId,
                category_id: categoryId,
                kind: kind === 'in' ? 'income' : 'expense',
                amount,
                description: description.trim() || (kind === 'in' ? 'Entrada' : 'Saída'),
                transaction_date: date,
                notes: notes || undefined,
            });
        },
        onSuccess: () => {
            void qc.invalidateQueries({ queryKey: ['transactions'] });
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
                <Text style={{ fontSize: 15, fontWeight: '700' }}>{kind === 'mov' ? 'Transferir' : 'Nova transação'}</Text>
                <View style={{ width: 36 }} />
            </View>

            <KeyboardAwareScrollView style={{ flex: 1 }} contentContainerStyle={{ paddingBottom: 100 }}>
                <View style={{ paddingHorizontal: 16, paddingTop: 18, flexDirection: 'row', gap: 8 }}>
                    {KIND_DEFS.map((k) => {
                        const on = kind === k.id;
                        return (
                            <Pressable
                                key={k.id}
                                onPress={() => setKind(k.id)}
                                style={{
                                    flex: 1,
                                    paddingVertical: 12,
                                    paddingHorizontal: 8,
                                    borderRadius: 14,
                                    alignItems: 'center',
                                    backgroundColor: on ? `${k.color}15` : KITAMO.line2,
                                    borderWidth: 1.5,
                                    borderColor: on ? k.color : 'transparent',
                                }}
                            >
                                <Text style={{ fontSize: 18 }}>{k.emoji}</Text>
                                <Text style={{ fontSize: 12, fontWeight: '700', color: on ? k.color : KITAMO.ink2, marginTop: 2 }}>{k.label}</Text>
                            </Pressable>
                        );
                    })}
                </View>

                <View style={{ paddingHorizontal: 16, paddingTop: 28, paddingBottom: 16, alignItems: 'center' }}>
                    <Text style={{ fontSize: 13, color: KITAMO.muted, fontWeight: '600' }}>Valor</Text>
                    <View style={{ flexDirection: 'row', alignItems: 'baseline', marginTop: 4 }}>
                        <Text style={{ fontSize: 22, fontWeight: '600', opacity: 0.7, marginRight: 4, color: accentColor }}>R$</Text>
                        <TextInput
                            value={formatBRLInput(amount)}
                            onChangeText={(t) => setAmount(parseBRLInput(t))}
                            keyboardType="numeric"
                            style={{
                                fontSize: 46,
                                fontWeight: '800',
                                letterSpacing: -1.5,
                                color: accentColor,
                                minWidth: 120,
                                textAlign: 'center',
                                paddingVertical: 0,
                            }}
                            selectTextOnFocus
                        />
                    </View>
                </View>

                {kind !== 'mov' ? (
                    <View style={{ paddingHorizontal: 16 }}>
                        <FieldRow label={kind === 'in' ? 'O que entrou?' : 'O que foi?'}>
                            <TextInput
                                value={description}
                                onChangeText={setDescription}
                                placeholder={kind === 'in' ? 'Salário, freela, pix...' : 'Mercado, uber, padaria...'}
                                placeholderTextColor={KITAMO.muted}
                                style={{ fontSize: 17, fontWeight: '600', color: KITAMO.ink, paddingVertical: 0 }}
                            />
                        </FieldRow>
                        <FieldRow label="De qual conta?">
                            <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={{ gap: 8, paddingTop: 4 }}>
                                {(accounts.data ?? []).map((a) => {
                                    const on = accountId === a.id;
                                    return (
                                        <Pressable
                                            key={a.id}
                                            onPress={() => setAccountId(a.id)}
                                            style={{
                                                flexDirection: 'row',
                                                alignItems: 'center',
                                                gap: 8,
                                                paddingHorizontal: 12,
                                                paddingVertical: 8,
                                                borderRadius: 12,
                                                backgroundColor: on ? KITAMO.brandSoft : '#fff',
                                                borderWidth: 1,
                                                borderColor: on ? KITAMO.brand : KITAMO.line,
                                            }}
                                        >
                                            <BankAvatar name={a.name} color={a.color ?? KITAMO.brand} size={20} />
                                            <Text style={{ fontSize: 13, fontWeight: '600', color: on ? KITAMO.brandDark : KITAMO.ink }}>{a.name}</Text>
                                        </Pressable>
                                    );
                                })}
                            </ScrollView>
                        </FieldRow>
                        <View style={{ paddingVertical: 14, borderBottomWidth: 1, borderBottomColor: KITAMO.line2 }}>
                            <Text style={{ fontSize: 12, color: KITAMO.muted, fontWeight: '700', marginBottom: 10 }}>Categoria</Text>
                            <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={{ gap: 10 }}>
                                {filteredCats.length === 0 ? (
                                    <Text style={{ color: KITAMO.muted, fontSize: 12 }}>Carregando categorias...</Text>
                                ) : (
                                    filteredCats.map((c) => {
                                        const on = categoryId === c.id;
                                        const iconName = guessIcon(c.name, c.icon);
                                        return (
                                            <Pressable
                                                key={c.id}
                                                onPress={() => setCategoryId(c.id)}
                                                style={{
                                                    alignItems: 'center',
                                                    gap: 4,
                                                    minWidth: 64,
                                                    paddingVertical: 8,
                                                    paddingHorizontal: 6,
                                                    borderRadius: 14,
                                                    backgroundColor: on ? `${c.color ?? KITAMO.brand}15` : 'transparent',
                                                    borderWidth: 1.5,
                                                    borderColor: on ? c.color ?? KITAMO.brand : KITAMO.line2,
                                                }}
                                            >
                                                <View
                                                    style={{
                                                        width: 36,
                                                        height: 36,
                                                        borderRadius: 18,
                                                        backgroundColor: `${c.color ?? KITAMO.brand}22`,
                                                        alignItems: 'center',
                                                        justifyContent: 'center',
                                                    }}
                                                >
                                                    <Icon name={iconName} size={18} color={c.color ?? KITAMO.brand} />
                                                </View>
                                                <Text style={{ fontSize: 11, fontWeight: '600', color: KITAMO.ink }}>{c.name}</Text>
                                            </Pressable>
                                        );
                                    })
                                )}
                            </ScrollView>
                        </View>
                        <FieldRow label="Observação (opcional)">
                            <TextInput
                                value={notes}
                                onChangeText={setNotes}
                                placeholder="Adicione uma observação..."
                                placeholderTextColor={KITAMO.muted}
                                style={{ fontSize: 15, color: KITAMO.ink, paddingVertical: 0 }}
                            />
                        </FieldRow>
                    </View>
                ) : (
                    <View style={{ paddingHorizontal: 16 }}>
                        <Text style={{ fontSize: 12, color: KITAMO.muted, fontWeight: '700', marginBottom: 8 }}>De qual conta sai?</Text>
                        <AccountList accounts={accounts.data ?? []} selectedId={accountId} onSelect={setAccountId} />
                        <Text style={{ fontSize: 12, color: KITAMO.muted, fontWeight: '700', marginTop: 18, marginBottom: 8 }}>Pra qual conta vai?</Text>
                        <AccountList
                            accounts={(accounts.data ?? []).filter((a) => a.id !== accountId)}
                            selectedId={toAccountId}
                            onSelect={setToAccountId}
                        />
                        <View style={{ marginTop: 14, padding: 12, borderRadius: 12, backgroundColor: KITAMO.brandSoft, flexDirection: 'row', gap: 8, alignItems: 'center' }}>
                            <Icon name="info" size={14} color={KITAMO.brandDark} />
                            <Text style={{ fontSize: 12, color: KITAMO.ink2, fontWeight: '600' }}>Não conta como gasto — só muda de conta.</Text>
                        </View>
                    </View>
                )}
            </KeyboardAwareScrollView>

            <View style={{ position: 'absolute', left: 16, right: 16, bottom: 24 }}>
                <Button onPress={() => mutation.mutate()} loading={mutation.isPending}>
                    {kind === 'mov' ? 'Transferir' : 'Salvar'}
                </Button>
            </View>
        </Screen>
    );
}

function FieldRow({ label, children }: { label: string; children: React.ReactNode }): React.JSX.Element {
    return (
        <View style={{ paddingVertical: 14, borderBottomWidth: 1, borderBottomColor: KITAMO.line2 }}>
            <Text style={{ fontSize: 12, color: KITAMO.muted, fontWeight: '700' }}>{label}</Text>
            <View style={{ marginTop: 6 }}>{children}</View>
        </View>
    );
}

function AccountList({
    accounts,
    selectedId,
    onSelect,
}: {
    accounts: any[];
    selectedId: number | null;
    onSelect: (id: number) => void;
}): React.JSX.Element {
    return (
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={{ gap: 8 }}>
            {accounts.map((a) => {
                const on = selectedId === a.id;
                return (
                    <Pressable
                        key={a.id}
                        onPress={() => onSelect(a.id)}
                        style={{
                            flexDirection: 'row',
                            alignItems: 'center',
                            gap: 10,
                            paddingHorizontal: 14,
                            paddingVertical: 10,
                            borderRadius: 12,
                            backgroundColor: on ? KITAMO.brandSoft : '#fff',
                            borderWidth: 1,
                            borderColor: on ? KITAMO.brand : KITAMO.line,
                        }}
                    >
                        <BankAvatar name={a.name} color={a.color ?? KITAMO.brand} size={28} />
                        <View>
                            <Text style={{ fontSize: 13, fontWeight: '700', color: KITAMO.ink }}>{a.name}</Text>
                            <Text style={{ fontSize: 11, color: KITAMO.muted }}>R$ {a.current_balance.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}</Text>
                        </View>
                    </Pressable>
                );
            })}
        </ScrollView>
    );
}

function guessIcon(catName: string, dbIcon: string | null): IconName {
    if (dbIcon === 'food' || dbIcon === 'car' || dbIcon === 'house' || dbIcon === 'health' || dbIcon === 'game' || dbIcon === 'tag') {
        return dbIcon;
    }
    const n = catName.toLowerCase();
    const match = CAT_ICONS.find((c) => n.includes(c.name));
    return match?.icon ?? 'tag';
}
