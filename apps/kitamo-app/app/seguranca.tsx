import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { router } from 'expo-router';
import React, { useState } from 'react';
import { ActivityIndicator, Alert, Modal, Pressable, ScrollView, Text, TextInput, View } from 'react-native';
import { KeyboardAwareScrollView } from 'react-native-keyboard-controller';

import { extractApiError } from '@/api/client';
import { authApi } from '@/api/endpoints';
import { Button } from '@/components/Button';
import { Icon } from '@/components/Icon';
import { Screen } from '@/components/Screen';
import { useAuth } from '@/stores/authStore';
import { KITAMO } from '@/theme/tokens';

export default function Seguranca(): React.JSX.Element {
    const user = useAuth((s) => s.user);
    const [pwOpen, setPwOpen] = useState(false);
    const qc = useQueryClient();

    const sessions = useQuery({ queryKey: ['sessions'], queryFn: () => authApi.sessions() });
    const revokeAll = useMutation({
        mutationFn: () => authApi.revokeAllSessions(),
        onSuccess: () => qc.invalidateQueries({ queryKey: ['sessions'] }),
        onError: (e) => Alert.alert('Erro', extractApiError(e)),
    });

    const otherSessions = (sessions.data ?? []).filter((s) => !s.is_current).length;

    function confirmRevokeAll(): void {
        Alert.alert(
            'Sair de outros dispositivos',
            `${otherSessions} sessão(ões) ativa(s). Após confirmar, você precisará entrar de novo nelas.`,
            [
                { text: 'Cancelar', style: 'cancel' },
                { text: 'Sair de todos', style: 'destructive', onPress: () => revokeAll.mutate() },
            ],
        );
    }

    return (
        <Screen bg={KITAMO.bg} edges={['top', 'bottom']}>
            <View style={{ paddingHorizontal: 16, paddingTop: 8, flexDirection: 'row', alignItems: 'center', gap: 10 }}>
                <Pressable
                    onPress={() => router.back()}
                    style={{ width: 36, height: 36, borderRadius: 18, backgroundColor: '#fff', alignItems: 'center', justifyContent: 'center' }}
                >
                    <Icon name="back" size={18} color={KITAMO.ink} />
                </Pressable>
                <Text style={{ flex: 1, fontSize: 18, fontWeight: '800', color: KITAMO.ink }}>Segurança</Text>
            </View>

            <ScrollView contentContainerStyle={{ paddingBottom: 60 }} showsVerticalScrollIndicator={false}>
                <View
                    style={{
                        marginHorizontal: 16,
                        marginTop: 14,
                        padding: 18,
                        backgroundColor: '#fff',
                        borderRadius: 18,
                        flexDirection: 'row',
                        alignItems: 'center',
                        gap: 14,
                        shadowColor: '#0F172A',
                        shadowOffset: { width: 0, height: 2 },
                        shadowOpacity: 0.05,
                        shadowRadius: 8,
                        elevation: 1,
                    }}
                >
                    <View
                        style={{
                            width: 54,
                            height: 54,
                            borderRadius: 14,
                            backgroundColor: KITAMO.success,
                            alignItems: 'center',
                            justifyContent: 'center',
                        }}
                    >
                        <Icon name="shield" size={26} color="#fff" />
                    </View>
                    <View style={{ flex: 1 }}>
                        <Text style={{ fontSize: 11, color: KITAMO.muted, fontWeight: '700', letterSpacing: 0.3 }}>SUA CONTA TÁ</Text>
                        <Text style={{ fontSize: 18, fontWeight: '800', color: KITAMO.success }}>Bem protegida ✓</Text>
                        <Text style={{ fontSize: 11, color: KITAMO.muted, marginTop: 1 }}>Token Sanctum ativo</Text>
                    </View>
                </View>

                <Section title="SEUS DADOS">
                    <Row
                        icon="lock"
                        color={KITAMO.brandDark}
                        name="Trocar senha"
                        sub={user?.auth_provider === 'google' ? 'Conta criada com Google' : 'Mudar a senha de acesso'}
                        cta={user?.auth_provider === 'google' ? undefined : 'Trocar'}
                        onPress={() => user?.auth_provider !== 'google' && setPwOpen(true)}
                    />
                    <Row
                        icon="bot"
                        color={KITAMO.brandDark}
                        name="Verificação em 2 etapas"
                        sub={user?.has_2fa ? 'Ativada' : 'Recomendado'}
                        toggle
                        on={user?.has_2fa}
                        onPress={() => Alert.alert('Em breve', 'Verificação em 2 etapas chega na próxima versão.')}
                    />
                    <Row
                        icon="swap"
                        color={KITAMO.brandDark}
                        name="Sessões ativas"
                        sub={sessions.isLoading ? 'Carregando...' : `${(sessions.data ?? []).length} dispositivo(s)`}
                        cta={sessions.data && otherSessions > 0 ? `Ver` : undefined}
                        onPress={() => Alert.alert('Sessões', (sessions.data ?? []).map((s) => `• ${s.name}${s.is_current ? ' (este)' : ''}`).join('\n') || 'Nenhuma')}
                    />
                </Section>

                <Section title="ENTRAR NO APP">
                    <Row icon="face" color={KITAMO.success} name="Face ID / biometria" sub="Pra abrir o app rapidinho" toggle onPress={() => Alert.alert('Em breve', 'Configuração de biometria na próxima versão.')} />
                    <Row icon="eye" color={KITAMO.warn} name="Esconder saldo" sub="Aparece como ••• ao abrir" toggle onPress={() => Alert.alert('Em breve', 'Em breve.')} />
                </Section>

                <View style={{ paddingHorizontal: 16, paddingTop: 18 }}>
                    <Pressable
                        onPress={confirmRevokeAll}
                        disabled={revokeAll.isPending || otherSessions === 0}
                        style={{ paddingVertical: 16, alignItems: 'center', opacity: otherSessions === 0 ? 0.4 : 1 }}
                    >
                        {revokeAll.isPending ? (
                            <ActivityIndicator color={KITAMO.danger} />
                        ) : (
                            <Text style={{ color: KITAMO.danger, fontSize: 14, fontWeight: '700' }}>
                                Sair de todos os outros dispositivos {otherSessions > 0 ? `(${otherSessions})` : ''}
                            </Text>
                        )}
                    </Pressable>
                </View>
            </ScrollView>

            <Modal visible={pwOpen} animationType="slide" presentationStyle="pageSheet" onRequestClose={() => setPwOpen(false)}>
                <ChangePasswordForm onClose={() => setPwOpen(false)} />
            </Modal>
        </Screen>
    );
}

function Section({ title, children }: { title: string; children: React.ReactNode }): React.JSX.Element {
    return (
        <View>
            <Text style={{ paddingHorizontal: 22, paddingTop: 18, paddingBottom: 8, fontSize: 10, color: KITAMO.muted, fontWeight: '700', letterSpacing: 0.5 }}>
                {title}
            </Text>
            <View style={{ paddingHorizontal: 16, gap: 6 }}>{children}</View>
        </View>
    );
}

function Row({
    icon,
    color,
    name,
    sub,
    toggle,
    on,
    cta,
    onPress,
}: {
    icon: any;
    color: string;
    name: string;
    sub?: string;
    toggle?: boolean;
    on?: boolean;
    cta?: string;
    onPress: () => void;
}): React.JSX.Element {
    return (
        <Pressable
            onPress={onPress}
            style={({ pressed }) => ({
                paddingVertical: 14,
                paddingHorizontal: 14,
                backgroundColor: '#fff',
                borderRadius: 14,
                shadowColor: '#0F172A',
                shadowOffset: { width: 0, height: 1 },
                shadowOpacity: 0.04,
                shadowRadius: 3,
                elevation: 1,
                flexDirection: 'row',
                alignItems: 'center',
                gap: 12,
                opacity: pressed ? 0.7 : 1,
            })}
        >
            <View
                style={{
                    width: 36,
                    height: 36,
                    borderRadius: 10,
                    backgroundColor: `${color}18`,
                    alignItems: 'center',
                    justifyContent: 'center',
                }}
            >
                <Icon name={icon} size={16} color={color} />
            </View>
            <View style={{ flex: 1 }}>
                <Text style={{ fontSize: 13, fontWeight: '700', color: KITAMO.ink }}>{name}</Text>
                {sub ? <Text style={{ fontSize: 11, color: KITAMO.muted, marginTop: 1 }}>{sub}</Text> : null}
            </View>
            {toggle ? (
                <View
                    style={{
                        width: 42,
                        height: 24,
                        borderRadius: 12,
                        padding: 2,
                        backgroundColor: on ? KITAMO.brand : KITAMO.line2,
                        flexDirection: 'row',
                        alignItems: 'center',
                        justifyContent: on ? 'flex-end' : 'flex-start',
                    }}
                >
                    <View style={{ width: 20, height: 20, borderRadius: 10, backgroundColor: '#fff' }} />
                </View>
            ) : cta ? (
                <Text style={{ fontSize: 12, color: KITAMO.brandDark, fontWeight: '700' }}>{cta}</Text>
            ) : (
                <Icon name="arrow" size={16} color={KITAMO.line} />
            )}
        </Pressable>
    );
}

function ChangePasswordForm({ onClose }: { onClose: () => void }): React.JSX.Element {
    const [current, setCurrent] = useState('');
    const [next, setNext] = useState('');
    const [confirm, setConfirm] = useState('');

    const mut = useMutation({
        mutationFn: async () => {
            if (next.length < 6) throw new Error('Senha precisa de no mínimo 6 caracteres.');
            if (next !== confirm) throw new Error('A nova senha e a confirmação não batem.');
            await authApi.changePassword({ current_password: current, new_password: next });
        },
        onSuccess: () => {
            Alert.alert('Pronto!', 'Senha trocada com sucesso.');
            onClose();
        },
        onError: (e) => Alert.alert('Erro', extractApiError(e)),
    });

    return (
        <KeyboardAwareScrollView style={{ flex: 1, backgroundColor: '#fff' }} contentContainerStyle={{ padding: 24 }}>
            <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: 20 }}>
                <Text style={{ fontSize: 22, fontWeight: '800', color: KITAMO.ink }}>Trocar senha</Text>
                <Pressable onPress={onClose} hitSlop={10}>
                    <Icon name="close" size={22} color={KITAMO.ink} />
                </Pressable>
            </View>
            <PwField label="SENHA ATUAL" value={current} onChange={setCurrent} />
            <PwField label="NOVA SENHA" value={next} onChange={setNext} />
            <PwField label="CONFIRMAR NOVA SENHA" value={confirm} onChange={setConfirm} />
            <View style={{ marginTop: 24 }}>
                <Button onPress={() => mut.mutate()} loading={mut.isPending}>
                    Trocar senha
                </Button>
            </View>
        </KeyboardAwareScrollView>
    );
}

function PwField({ label, value, onChange }: { label: string; value: string; onChange: (t: string) => void }): React.JSX.Element {
    return (
        <View style={{ marginBottom: 14 }}>
            <Text style={{ fontSize: 12, color: KITAMO.muted, fontWeight: '700', marginBottom: 6 }}>{label}</Text>
            <TextInput
                value={value}
                onChangeText={onChange}
                secureTextEntry
                autoCapitalize="none"
                style={{ borderWidth: 1.5, borderColor: KITAMO.line, borderRadius: 12, padding: 12, fontSize: 16, color: KITAMO.ink }}
            />
        </View>
    );
}
