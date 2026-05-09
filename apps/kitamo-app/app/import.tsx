import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import * as DocumentPicker from 'expo-document-picker';
import { router } from 'expo-router';
import React, { useState } from 'react';
import { ActivityIndicator, Alert, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';

import { extractApiError } from '@/api/client';
import { accountsApi, importApi, type ImportPreview } from '@/api/endpoints';
import { BankAvatar } from '@/components/Avatar';
import { Button } from '@/components/Button';
import { Icon } from '@/components/Icon';
import { Screen } from '@/components/Screen';
import { KITAMO } from '@/theme/tokens';

type Step = 'pick' | 'review' | 'done';

export default function Import(): React.JSX.Element {
    const [step, setStep] = useState<Step>('pick');
    const [preview, setPreview] = useState<ImportPreview | null>(null);
    const [accountId, setAccountId] = useState<number | null>(null);
    const [committedSummary, setCommittedSummary] = useState<{ created: number; skipped: number } | null>(null);
    const qc = useQueryClient();

    const accounts = useQuery({ queryKey: ['accounts'], queryFn: () => accountsApi.list() });

    const previewMut = useMutation({
        mutationFn: async (file: { uri: string; name: string; mime: string }) => {
            return importApi.preview(file.uri, file.name, file.mime);
        },
        onSuccess: (data) => {
            setPreview(data);
            setStep('review');
            if (!accountId && accounts.data && accounts.data.length > 0) {
                setAccountId(accounts.data[0].id);
            }
        },
        onError: (e) => Alert.alert('Erro', extractApiError(e)),
    });

    const commitMut = useMutation({
        mutationFn: async () => {
            if (!preview || !accountId) throw new Error('Selecione uma conta.');
            return importApi.commit(accountId, preview.rows);
        },
        onSuccess: (data) => {
            setCommittedSummary(data);
            setStep('done');
            void qc.invalidateQueries({ queryKey: ['transactions'] });
            void qc.invalidateQueries({ queryKey: ['accounts'] });
            void qc.invalidateQueries({ queryKey: ['dashboard-summary'] });
        },
        onError: (e) => Alert.alert('Erro', extractApiError(e)),
    });

    async function pickFile(): Promise<void> {
        try {
            const res = await DocumentPicker.getDocumentAsync({
                type: ['text/csv', 'application/ofx', 'application/x-ofx', 'text/plain', 'application/octet-stream', '*/*'],
                copyToCacheDirectory: true,
                multiple: false,
            });
            if (res.canceled || res.assets.length === 0) return;
            const a = res.assets[0];
            previewMut.mutate({ uri: a.uri, name: a.name, mime: a.mimeType ?? 'application/octet-stream' });
        } catch (e: any) {
            Alert.alert('Erro', e?.message ?? 'Não foi possível abrir o arquivo.');
        }
    }

    return (
        <Screen bg={KITAMO.bg} edges={['top', 'bottom']}>
            <View style={styles.header}>
                <Pressable onPress={() => router.back()} style={styles.backBtn}>
                    <Icon name="back" size={18} color={KITAMO.ink} />
                </Pressable>
                <Text style={styles.title}>Importar fatura/extrato</Text>
                <View style={{ width: 36 }} />
            </View>

            {step === 'pick' ? (
                <PickStep onPick={pickFile} loading={previewMut.isPending} />
            ) : step === 'review' && preview ? (
                <ReviewStep
                    preview={preview}
                    accounts={accounts.data ?? []}
                    accountId={accountId}
                    onSelectAccount={setAccountId}
                    onCommit={() => commitMut.mutate()}
                    onCancel={() => {
                        setPreview(null);
                        setStep('pick');
                    }}
                    committing={commitMut.isPending}
                />
            ) : step === 'done' && committedSummary ? (
                <DoneStep summary={committedSummary} onClose={() => router.back()} />
            ) : null}
        </Screen>
    );
}

function PickStep({ onPick, loading }: { onPick: () => void; loading: boolean }): React.JSX.Element {
    return (
        <ScrollView contentContainerStyle={{ padding: 22, paddingBottom: 60 }}>
            <Text style={{ fontSize: 22, fontWeight: '800', color: KITAMO.ink, lineHeight: 28 }}>
                Cola tudo de uma vez{'\n'}sem precisar digitar
            </Text>
            <Text style={{ fontSize: 14, color: KITAMO.ink2, marginTop: 8, lineHeight: 22 }}>
                Suba a fatura do cartão ou o extrato bancário e a Kit identifica cada lançamento, categoriza e importa.
            </Text>

            <Pressable
                onPress={loading ? undefined : onPick}
                style={({ pressed }) => [styles.uploadCard, { opacity: loading ? 0.7 : pressed ? 0.95 : 1 }]}
            >
                {loading ? (
                    <>
                        <ActivityIndicator color={KITAMO.brandDark} size="large" />
                        <Text style={{ marginTop: 14, fontSize: 14, fontWeight: '700', color: KITAMO.ink }}>Lendo arquivo...</Text>
                    </>
                ) : (
                    <>
                        <View style={styles.uploadIcon}>
                            <Icon name="imp" size={28} color={KITAMO.brandDark} />
                        </View>
                        <Text style={{ marginTop: 14, fontSize: 16, fontWeight: '800', color: KITAMO.ink }}>
                            Selecionar arquivo
                        </Text>
                        <Text style={{ marginTop: 4, fontSize: 12, color: KITAMO.muted }}>CSV · OFX · QFX</Text>
                    </>
                )}
            </Pressable>

            <View style={{ marginTop: 24 }}>
                <Text style={styles.sectionLabel}>OUTRAS FORMAS DE IMPORTAR</Text>
                <View style={styles.optionCard}>
                    <View style={[styles.optionIcon, { backgroundColor: '#FEF3C7' }]}>
                        <Icon name="bolt" size={18} color={KITAMO.warn} />
                    </View>
                    <View style={{ flex: 1, marginLeft: 12 }}>
                        <Text style={{ fontSize: 14, fontWeight: '800', color: KITAMO.ink }}>Open Finance</Text>
                        <Text style={{ fontSize: 12, color: KITAMO.muted, marginTop: 2 }}>
                            Sincronizar bancos automaticamente · em breve
                        </Text>
                    </View>
                    <View style={styles.soonBadge}>
                        <Text style={{ fontSize: 10, color: KITAMO.muted, fontWeight: '700' }}>EM BREVE</Text>
                    </View>
                </View>

                <View style={styles.optionCard}>
                    <View style={[styles.optionIcon, { backgroundColor: KITAMO.brandSoft }]}>
                        <Icon name="tag" size={18} color={KITAMO.brandDark} />
                    </View>
                    <View style={{ flex: 1, marginLeft: 12 }}>
                        <Text style={{ fontSize: 14, fontWeight: '800', color: KITAMO.ink }}>Lançar manualmente</Text>
                        <Text style={{ fontSize: 12, color: KITAMO.muted, marginTop: 2 }}>
                            Adicionar uma transação por vez
                        </Text>
                    </View>
                    <Pressable onPress={() => router.replace({ pathname: '/add', params: { kind: 'out' } })} hitSlop={8}>
                        <Icon name="arrow" size={16} color={KITAMO.brandDark} />
                    </Pressable>
                </View>
            </View>

            <View style={[styles.tipCard]}>
                <Icon name="info" size={14} color={KITAMO.brandDark} />
                <Text style={{ flex: 1, marginLeft: 10, fontSize: 12, color: KITAMO.ink2, lineHeight: 18 }}>
                    A maioria dos bancos brasileiros (Nubank, Itaú, Bradesco, Inter, BB...) deixa exportar OFX ou CSV pelo
                    app oficial — geralmente em "Extrato → Compartilhar".
                </Text>
            </View>
        </ScrollView>
    );
}

function ReviewStep({
    preview,
    accounts,
    accountId,
    onSelectAccount,
    onCommit,
    onCancel,
    committing,
}: {
    preview: ImportPreview;
    accounts: any[];
    accountId: number | null;
    onSelectAccount: (id: number) => void;
    onCommit: () => void;
    onCancel: () => void;
    committing: boolean;
}): React.JSX.Element {
    const totalIn = preview.rows.filter((r) => r.kind === 'income').reduce((s, r) => s + r.amount, 0);
    const totalOut = preview.rows.filter((r) => r.kind === 'expense').reduce((s, r) => s + r.amount, 0);

    return (
        <View style={{ flex: 1 }}>
            <ScrollView contentContainerStyle={{ paddingHorizontal: 16, paddingBottom: 120 }}>
                <View style={styles.summaryCard}>
                    <Text style={{ fontSize: 12, color: KITAMO.muted, fontWeight: '700', letterSpacing: 0.4 }}>
                        ARQUIVO IDENTIFICADO
                    </Text>
                    <Text style={{ fontSize: 20, fontWeight: '800', color: KITAMO.ink, marginTop: 4 }}>
                        {preview.institution ?? 'Importação manual'}
                    </Text>
                    <View style={{ flexDirection: 'row', marginTop: 14 }}>
                        <View style={{ flex: 1 }}>
                            <Text style={{ fontSize: 11, color: KITAMO.muted }}>Lançamentos</Text>
                            <Text style={{ fontSize: 18, fontWeight: '800', color: KITAMO.ink, marginTop: 2 }}>
                                {preview.rows.length}
                            </Text>
                        </View>
                        <View style={{ flex: 1 }}>
                            <Text style={{ fontSize: 11, color: KITAMO.muted }}>Entradas</Text>
                            <Text style={{ fontSize: 14, fontWeight: '700', color: KITAMO.success, marginTop: 2 }}>
                                R$ {totalIn.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
                            </Text>
                        </View>
                        <View style={{ flex: 1 }}>
                            <Text style={{ fontSize: 11, color: KITAMO.muted }}>Saídas</Text>
                            <Text style={{ fontSize: 14, fontWeight: '700', color: KITAMO.danger, marginTop: 2 }}>
                                R$ {totalOut.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
                            </Text>
                        </View>
                    </View>
                </View>

                <Text style={[styles.sectionLabel, { marginTop: 18 }]}>EM QUAL CONTA?</Text>
                <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={{ paddingVertical: 4 }}>
                    {accounts.map((a) => {
                        const on = accountId === a.id;
                        return (
                            <Pressable
                                key={a.id}
                                onPress={() => onSelectAccount(a.id)}
                                style={[
                                    styles.accountChip,
                                    { backgroundColor: on ? KITAMO.brandSoft : '#fff', borderColor: on ? KITAMO.brand : KITAMO.line },
                                ]}
                            >
                                <BankAvatar name={a.name} color={a.color ?? KITAMO.brand} size={22} />
                                <Text style={{ marginLeft: 8, fontSize: 13, fontWeight: '700', color: on ? KITAMO.brandDark : KITAMO.ink }}>
                                    {a.name}
                                </Text>
                            </Pressable>
                        );
                    })}
                </ScrollView>

                <Text style={[styles.sectionLabel, { marginTop: 18 }]}>PRÉVIA DOS LANÇAMENTOS</Text>
                {preview.rows.slice(0, 30).map((r, i) => (
                    <View key={`${r.transaction_date}-${i}`} style={styles.previewRow}>
                        <View style={{ flex: 1 }}>
                            <Text style={{ fontSize: 14, fontWeight: '700', color: KITAMO.ink }} numberOfLines={1}>
                                {r.description}
                            </Text>
                            <Text style={{ fontSize: 11, color: KITAMO.muted, marginTop: 1 }}>{r.transaction_date}</Text>
                        </View>
                        <Text style={{ fontSize: 14, fontWeight: '800', color: r.kind === 'income' ? KITAMO.success : KITAMO.ink }}>
                            {r.kind === 'income' ? '+ ' : '- '}R$ {r.amount.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
                        </Text>
                    </View>
                ))}
                {preview.rows.length > 30 ? (
                    <Text style={{ marginTop: 8, textAlign: 'center', fontSize: 12, color: KITAMO.muted }}>
                        + {preview.rows.length - 30} lançamentos
                    </Text>
                ) : null}
            </ScrollView>

            <View style={styles.bottomBar}>
                <Pressable onPress={committing ? undefined : onCancel} style={styles.cancelBtn}>
                    <Text style={{ color: KITAMO.ink2, fontSize: 14, fontWeight: '700' }}>Cancelar</Text>
                </Pressable>
                <View style={{ width: 10 }} />
                <View style={{ flex: 1 }}>
                    <Button onPress={onCommit} loading={committing} disabled={!accountId}>
                        Importar {preview.rows.length}
                    </Button>
                </View>
            </View>
        </View>
    );
}

function DoneStep({ summary, onClose }: { summary: { created: number; skipped: number }; onClose: () => void }): React.JSX.Element {
    return (
        <View style={{ flex: 1, padding: 24, alignItems: 'center', justifyContent: 'center' }}>
            <View style={styles.successCircle}>
                <Icon name="check" size={36} color="#fff" />
            </View>
            <Text style={{ fontSize: 24, fontWeight: '800', color: KITAMO.ink, marginTop: 24 }}>Importou!</Text>
            <Text style={{ fontSize: 14, color: KITAMO.ink2, marginTop: 10, textAlign: 'center', lineHeight: 22 }}>
                <Text style={{ fontWeight: '800' }}>{summary.created}</Text> lançamento{summary.created !== 1 ? 's' : ''} novo{summary.created !== 1 ? 's' : ''}.
                {summary.skipped > 0 ? `\n${summary.skipped} já existiam e foram puladas.` : ''}
            </Text>
            <View style={{ width: '100%', marginTop: 32 }}>
                <Button onPress={onClose}>Beleza</Button>
            </View>
        </View>
    );
}

const styles = StyleSheet.create({
    header: {
        paddingHorizontal: 16,
        paddingTop: 8,
        paddingBottom: 8,
        flexDirection: 'row',
        alignItems: 'center',
    },
    backBtn: {
        width: 36,
        height: 36,
        borderRadius: 18,
        backgroundColor: '#fff',
        alignItems: 'center',
        justifyContent: 'center',
    },
    title: { flex: 1, textAlign: 'center', fontSize: 16, fontWeight: '800', color: KITAMO.ink },
    uploadCard: {
        marginTop: 22,
        borderRadius: 22,
        backgroundColor: '#fff',
        paddingVertical: 38,
        alignItems: 'center',
        borderWidth: 2,
        borderColor: KITAMO.brand,
        borderStyle: 'dashed',
    },
    uploadIcon: {
        width: 64,
        height: 64,
        borderRadius: 18,
        backgroundColor: KITAMO.brandSoft,
        alignItems: 'center',
        justifyContent: 'center',
    },
    sectionLabel: {
        fontSize: 11,
        color: KITAMO.muted,
        fontWeight: '700',
        letterSpacing: 0.5,
        marginBottom: 10,
    },
    optionCard: {
        flexDirection: 'row',
        alignItems: 'center',
        padding: 14,
        backgroundColor: '#fff',
        borderRadius: 14,
        marginBottom: 8,
        shadowColor: '#0F172A',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.04,
        shadowRadius: 4,
        elevation: 1,
    },
    optionIcon: {
        width: 36,
        height: 36,
        borderRadius: 10,
        alignItems: 'center',
        justifyContent: 'center',
    },
    soonBadge: {
        paddingHorizontal: 8,
        paddingVertical: 4,
        borderRadius: 8,
        backgroundColor: KITAMO.line2,
    },
    tipCard: {
        marginTop: 18,
        padding: 12,
        borderRadius: 12,
        backgroundColor: KITAMO.brandSoft,
        flexDirection: 'row',
    },
    summaryCard: {
        marginTop: 14,
        padding: 18,
        backgroundColor: '#fff',
        borderRadius: 18,
        shadowColor: '#0F172A',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.05,
        shadowRadius: 8,
        elevation: 2,
    },
    accountChip: {
        flexDirection: 'row',
        alignItems: 'center',
        paddingHorizontal: 12,
        paddingVertical: 8,
        borderRadius: 12,
        borderWidth: 1,
        marginRight: 8,
    },
    previewRow: {
        flexDirection: 'row',
        alignItems: 'center',
        paddingVertical: 12,
        paddingHorizontal: 14,
        backgroundColor: '#fff',
        borderRadius: 12,
        marginBottom: 6,
    },
    bottomBar: {
        position: 'absolute',
        left: 16,
        right: 16,
        bottom: 24,
        flexDirection: 'row',
        alignItems: 'center',
    },
    cancelBtn: {
        height: 56,
        paddingHorizontal: 22,
        backgroundColor: '#fff',
        borderRadius: 14,
        borderWidth: 1.5,
        borderColor: KITAMO.line,
        alignItems: 'center',
        justifyContent: 'center',
    },
    successCircle: {
        width: 88,
        height: 88,
        borderRadius: 44,
        backgroundColor: KITAMO.success,
        alignItems: 'center',
        justifyContent: 'center',
    },
});
