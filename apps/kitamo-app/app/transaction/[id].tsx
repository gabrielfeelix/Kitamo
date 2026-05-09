import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { router, useLocalSearchParams } from 'expo-router';
import React from 'react';
import { ActivityIndicator, Alert, Pressable, ScrollView, Text, View } from 'react-native';

import { extractApiError } from '@/api/client';
import { accountsApi, categoriesApi, transactionsApi } from '@/api/endpoints';
import { CatIcon } from '@/components/Avatar';
import { Icon } from '@/components/Icon';
import { Screen } from '@/components/Screen';
import { KITAMO } from '@/theme/tokens';

export default function TransactionDetail(): React.JSX.Element {
    const { id } = useLocalSearchParams<{ id: string }>();
    const txId = Number(id);
    const qc = useQueryClient();

    const tx = useQuery({
        queryKey: ['transaction', txId],
        queryFn: () => transactionsApi.show(txId),
        enabled: !Number.isNaN(txId),
    });
    const accounts = useQuery({ queryKey: ['accounts'], queryFn: () => accountsApi.list() });
    const cats = useQuery({ queryKey: ['categories'], queryFn: () => categoriesApi.list() });

    const removeMut = useMutation({
        mutationFn: () => transactionsApi.remove(txId),
        onSuccess: () => {
            void qc.invalidateQueries({ queryKey: ['transactions'] });
            void qc.invalidateQueries({ queryKey: ['accounts'] });
            void qc.invalidateQueries({ queryKey: ['dashboard-summary'] });
            router.back();
        },
        onError: (e) => Alert.alert('Erro', extractApiError(e)),
    });

    const cat = (cats.data ?? []).find((c) => c.id === tx.data?.category_id);
    const account = (accounts.data ?? []).find((a) => a.id === tx.data?.account_id);

    function confirmDelete(): void {
        Alert.alert('Apagar?', 'Essa transação será removida e o saldo da conta ajustado.', [
            { text: 'Cancelar', style: 'cancel' },
            { text: 'Apagar', style: 'destructive', onPress: () => removeMut.mutate() },
        ]);
    }

    return (
        <Screen bg="rgba(15,23,42,0.4)" edges={[]}>
            <View style={{ flex: 1, justifyContent: 'flex-end' }}>
                <Pressable onPress={() => router.back()} style={{ flex: 1 }} />
                <View
                    style={{
                        backgroundColor: '#fff',
                        borderTopLeftRadius: 24,
                        borderTopRightRadius: 24,
                        paddingHorizontal: 20,
                        paddingTop: 14,
                        paddingBottom: 28,
                    }}
                >
                    <View style={{ width: 40, height: 4, backgroundColor: KITAMO.line, borderRadius: 2, alignSelf: 'center', marginBottom: 18 }} />

                    {tx.isLoading || !tx.data ? (
                        <View style={{ paddingVertical: 40, alignItems: 'center' }}>
                            <ActivityIndicator color={KITAMO.brand} />
                        </View>
                    ) : (
                        <ScrollView showsVerticalScrollIndicator={false}>
                            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 14 }}>
                                <CatIcon
                                    name={cat?.icon as any ?? 'tag'}
                                    color={cat?.color ?? (tx.data.kind === 'income' ? KITAMO.success : KITAMO.danger)}
                                    size={56}
                                />
                                <View style={{ flex: 1 }}>
                                    <Text style={{ fontSize: 18, fontWeight: '800', color: KITAMO.ink }}>{tx.data.description}</Text>
                                    <Text style={{ fontSize: 13, color: KITAMO.muted, marginTop: 1 }}>
                                        {cat?.name ?? 'Sem categoria'} · {tx.data.transaction_date}
                                    </Text>
                                </View>
                                <View
                                    style={{
                                        paddingHorizontal: 10,
                                        paddingVertical: 4,
                                        borderRadius: 8,
                                        backgroundColor: tx.data.status === 'paid' ? '#D1FAE5' : tx.data.status === 'pending' ? '#FEF3C7' : KITAMO.brandSoft,
                                    }}
                                >
                                    <Text
                                        style={{
                                            fontSize: 11,
                                            fontWeight: '700',
                                            color: tx.data.status === 'paid' ? KITAMO.success : tx.data.status === 'pending' ? KITAMO.warn : KITAMO.brandDark,
                                        }}
                                    >
                                        ● {labelForStatus(tx.data.status)}
                                    </Text>
                                </View>
                            </View>

                            <Text
                                style={{
                                    fontSize: 42,
                                    fontWeight: '800',
                                    marginTop: 18,
                                    letterSpacing: -1.5,
                                    color: tx.data.kind === 'income' ? KITAMO.success : KITAMO.danger,
                                }}
                            >
                                {tx.data.kind === 'income' ? '+ ' : '- '}R$ {tx.data.amount.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
                            </Text>

                            <View style={{ marginTop: 18, paddingHorizontal: 14, backgroundColor: KITAMO.bg, borderRadius: 14 }}>
                                <Meta label="Categoria" value={cat?.name ?? 'Sem categoria'} />
                                <Meta label="Conta" value={account?.name ?? '—'} />
                                <Meta label="Tipo" value={tx.data.kind === 'income' ? 'Entrada' : 'Saída'} />
                                <Meta label="Status" value={labelForStatus(tx.data.status)} />
                                {tx.data.notes ? <Meta label="Observação" value={tx.data.notes} /> : null}
                                <Meta label="Data" value={tx.data.transaction_date} last />
                            </View>

                            <View style={{ flexDirection: 'row', gap: 8, marginTop: 18 }}>
                                <DrawerBtn iconName="tag" label="Editar" onPress={() => Alert.alert('Em breve', 'Edição na próxima versão.')} />
                                <DrawerBtn
                                    iconName="swap"
                                    label="Duplicar"
                                    onPress={() => Alert.alert('Em breve', 'Duplicar na próxima versão.')}
                                />
                                <DrawerBtn iconName="close" label="Apagar" danger onPress={confirmDelete} loading={removeMut.isPending} />
                            </View>
                        </ScrollView>
                    )}
                </View>
            </View>
        </Screen>
    );
}

function labelForStatus(s: string): string {
    if (s === 'paid') return 'Pago';
    if (s === 'received') return 'Recebido';
    return 'Pendente';
}

function Meta({ label, value, last }: { label: string; value: string; last?: boolean }): React.JSX.Element {
    return (
        <View
            style={{
                flexDirection: 'row',
                alignItems: 'center',
                justifyContent: 'space-between',
                paddingVertical: 12,
                borderBottomWidth: last ? 0 : 1,
                borderBottomColor: KITAMO.line2,
            }}
        >
            <Text style={{ fontSize: 13, color: KITAMO.muted, fontWeight: '600' }}>{label}</Text>
            <Text style={{ fontSize: 14, fontWeight: '700', color: KITAMO.ink, maxWidth: '60%' }} numberOfLines={2}>
                {value}
            </Text>
        </View>
    );
}

function DrawerBtn({
    iconName,
    label,
    danger,
    loading,
    onPress,
}: {
    iconName: 'tag' | 'swap' | 'close';
    label: string;
    danger?: boolean;
    loading?: boolean;
    onPress: () => void;
}): React.JSX.Element {
    return (
        <Pressable
            onPress={loading ? undefined : onPress}
            style={({ pressed }) => ({
                flex: 1,
                paddingVertical: 12,
                borderRadius: 12,
                backgroundColor: danger ? '#FEE2E2' : KITAMO.brandSoft,
                alignItems: 'center',
                gap: 4,
                opacity: pressed ? 0.7 : 1,
            })}
        >
            {loading ? (
                <ActivityIndicator color={danger ? KITAMO.danger : KITAMO.brandDark} />
            ) : (
                <>
                    <Icon name={iconName} size={20} color={danger ? KITAMO.danger : KITAMO.brandDark} />
                    <Text style={{ fontSize: 13, fontWeight: '700', color: danger ? KITAMO.danger : KITAMO.brandDark }}>{label}</Text>
                </>
            )}
        </Pressable>
    );
}
