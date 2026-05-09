import { router } from 'expo-router';
import React, { useState } from 'react';
import { Alert, Modal, Pressable, ScrollView, StyleSheet, Text, TextInput, View } from 'react-native';
import { KeyboardAwareScrollView } from 'react-native-keyboard-controller';

import { extractApiError } from '@/api/client';
import { authApi } from '@/api/endpoints';
import { Field } from '@/components/Field';
import { Icon } from '@/components/Icon';
import { KitamoLogo } from '@/components/Logo';
import { Screen } from '@/components/Screen';
import { useAuth } from '@/stores/authStore';
import { KITAMO } from '@/theme/tokens';

export default function Login(): React.JSX.Element {
    const setSession = useAuth((s) => s.setSession);
    const [mode, setMode] = useState<'login' | 'register'>('login');
    const [name, setName] = useState('');
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [forgotOpen, setForgotOpen] = useState(false);

    async function submit(): Promise<void> {
        if (!email || !password || (mode === 'register' && !name)) {
            setError('Preenche todos os campos.');
            return;
        }
        setError(null);
        setLoading(true);
        try {
            const res =
                mode === 'login'
                    ? await authApi.login(email.trim(), password)
                    : await authApi.register(name.trim(), email.trim(), password);
            await setSession(res.token, res.user);
            if (!res.user.onboarding_completed_at) {
                router.replace('/(auth)/onboarding-connect');
            } else {
                router.replace('/(app)/home');
            }
        } catch (e) {
            setError(extractApiError(e));
        } finally {
            setLoading(false);
        }
    }

    function googleNotice(): void {
        Alert.alert(
            'Em breve',
            'Login com Google chega na próxima versão. Por enquanto cria sua conta com email + senha — ela funciona igual no app e no site.',
        );
    }

    return (
        <Screen bg="#fff" barStyle="light" edges={['top']}>
            <View style={styles.tealHeader} pointerEvents="none" />

            <KeyboardAwareScrollView
                style={{ flex: 1 }}
                contentContainerStyle={{ paddingBottom: 60 }}
                keyboardShouldPersistTaps="handled"
            >
                <View style={styles.brandRow}>
                    <KitamoLogo size={32} color="#fff" />
                    <Text style={styles.brandText}>kitamo</Text>
                </View>
                <View style={{ paddingHorizontal: 24, marginTop: 12 }}>
                    <Text style={styles.h1}>
                        {mode === 'login' ? 'Bora organizar\nessa grana?' : 'Vamos criar\nsua conta'}
                    </Text>
                    <Text style={styles.sub}>
                        {mode === 'login' ? 'Entra com seu e-mail pra continuar.' : 'Em 30 segundos sua conta tá pronta.'}
                    </Text>
                </View>

                <View style={styles.card}>
                    {mode === 'register' ? (
                        <View style={{ marginBottom: 14 }}>
                            <Field label="Nome" value={name} onChangeText={setName} autoCapitalize="words" />
                        </View>
                    ) : null}
                    <Field
                        label="E-mail"
                        value={email}
                        onChangeText={setEmail}
                        keyboardType="email-address"
                        autoCapitalize="none"
                        autoComplete="email"
                    />
                    <View style={{ height: 14 }} />
                    <Field
                        label="Senha"
                        value={password}
                        onChangeText={setPassword}
                        secureTextEntry
                        autoCapitalize="none"
                    />

                    {mode === 'login' ? (
                        <Pressable onPress={() => setForgotOpen(true)} hitSlop={8} style={{ alignSelf: 'flex-end', marginTop: 10 }}>
                            <Text style={{ fontSize: 13, color: KITAMO.brandDark, fontWeight: '700' }}>Esqueci minha senha</Text>
                        </Pressable>
                    ) : null}

                    {error ? (
                        <Text style={styles.error}>{error}</Text>
                    ) : null}

                    <Pressable
                        onPress={loading ? undefined : submit}
                        style={({ pressed }) => [
                            styles.primaryBtn,
                            { opacity: loading ? 0.7 : pressed ? 0.9 : 1 },
                        ]}
                    >
                        <Text style={styles.primaryBtnText}>
                            {loading ? 'Aguarda...' : mode === 'login' ? 'Entrar' : 'Criar conta'}
                        </Text>
                    </Pressable>

                    <View style={styles.dividerRow}>
                        <View style={styles.dividerLine} />
                        <Text style={styles.dividerText}>ou</Text>
                        <View style={styles.dividerLine} />
                    </View>

                    <Pressable
                        onPress={googleNotice}
                        style={({ pressed }) => [styles.googleBtn, { opacity: pressed ? 0.85 : 1 }]}
                    >
                        <Icon name="google" size={20} />
                        <Text style={styles.googleBtnText}>Entrar com Google</Text>
                    </Pressable>
                </View>

                <View style={{ alignItems: 'center', marginTop: 24, flexDirection: 'row', justifyContent: 'center' }}>
                    <Text style={{ fontSize: 14, color: KITAMO.muted }}>
                        {mode === 'login' ? 'Novo aqui? ' : 'Já tem conta? '}
                    </Text>
                    <Pressable
                        onPress={() => {
                            setMode(mode === 'login' ? 'register' : 'login');
                            setError(null);
                        }}
                        hitSlop={8}
                    >
                        <Text style={{ fontSize: 14, color: KITAMO.brandDark, fontWeight: '700' }}>
                            {mode === 'login' ? 'Criar conta' : 'Fazer login'}
                        </Text>
                    </Pressable>
                </View>
            </KeyboardAwareScrollView>

            <ForgotPasswordModal visible={forgotOpen} initialEmail={email} onClose={() => setForgotOpen(false)} />
        </Screen>
    );
}

function ForgotPasswordModal({
    visible,
    initialEmail,
    onClose,
}: {
    visible: boolean;
    initialEmail: string;
    onClose: () => void;
}): React.JSX.Element {
    const [email, setEmail] = useState(initialEmail);
    const [loading, setLoading] = useState(false);
    const [done, setDone] = useState(false);
    const [errMsg, setErrMsg] = useState<string | null>(null);

    React.useEffect(() => {
        if (visible) {
            setEmail(initialEmail);
            setDone(false);
            setErrMsg(null);
        }
    }, [visible, initialEmail]);

    async function send(): Promise<void> {
        if (!email.trim()) {
            setErrMsg('Coloca seu e-mail aí.');
            return;
        }
        setLoading(true);
        setErrMsg(null);
        try {
            await authApi.forgotPassword(email.trim());
            setDone(true);
        } catch (e) {
            setErrMsg(extractApiError(e));
        } finally {
            setLoading(false);
        }
    }

    return (
        <Modal visible={visible} transparent animationType="fade" onRequestClose={onClose}>
            <View style={styles.modalBackdrop}>
                <View style={styles.modalCard}>
                    <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' }}>
                        <Text style={{ fontSize: 18, fontWeight: '800', color: KITAMO.ink }}>Esqueci a senha</Text>
                        <Pressable onPress={onClose} hitSlop={10}>
                            <Icon name="close" size={20} color={KITAMO.ink} />
                        </Pressable>
                    </View>
                    {done ? (
                        <View style={{ marginTop: 16 }}>
                            <Text style={{ fontSize: 14, color: KITAMO.ink2, lineHeight: 20 }}>
                                Pronto! Se a conta existir, mandamos um link de redefinição pro <Text style={{ fontWeight: '700' }}>{email}</Text>.
                                Confere a caixa de entrada e o spam.
                            </Text>
                            <Pressable onPress={onClose} style={[styles.primaryBtn, { marginTop: 20 }]}>
                                <Text style={styles.primaryBtnText}>Beleza</Text>
                            </Pressable>
                        </View>
                    ) : (
                        <View style={{ marginTop: 14 }}>
                            <Text style={{ fontSize: 14, color: KITAMO.ink2, lineHeight: 20, marginBottom: 14 }}>
                                A gente manda um link pro seu e-mail pra você criar uma senha nova.
                            </Text>
                            <View style={{ borderColor: KITAMO.line, borderWidth: 1.5, borderRadius: 12, paddingHorizontal: 14, paddingVertical: 10 }}>
                                <Text style={{ fontSize: 11, color: KITAMO.muted, fontWeight: '700' }}>E-MAIL</Text>
                                <TextInput
                                    value={email}
                                    onChangeText={setEmail}
                                    keyboardType="email-address"
                                    autoCapitalize="none"
                                    placeholder="seu@email.com"
                                    placeholderTextColor={KITAMO.muted}
                                    style={{ fontSize: 16, color: KITAMO.ink, paddingVertical: 0, marginTop: 2 }}
                                />
                            </View>
                            {errMsg ? <Text style={[styles.error, { marginTop: 10 }]}>{errMsg}</Text> : null}
                            <Pressable
                                onPress={loading ? undefined : send}
                                style={[styles.primaryBtn, { marginTop: 16, opacity: loading ? 0.7 : 1 }]}
                            >
                                <Text style={styles.primaryBtnText}>{loading ? 'Enviando...' : 'Enviar link'}</Text>
                            </Pressable>
                        </View>
                    )}
                </View>
            </View>
        </Modal>
    );
}

const styles = StyleSheet.create({
    tealHeader: {
        position: 'absolute',
        top: 0,
        left: 0,
        right: 0,
        height: 320,
        backgroundColor: KITAMO.brand,
        borderBottomLeftRadius: 60,
        borderBottomRightRadius: 60,
    },
    brandRow: {
        position: 'relative',
        paddingHorizontal: 24,
        paddingTop: 18,
        flexDirection: 'row',
        alignItems: 'center',
        gap: 10,
    },
    brandText: { color: '#fff', fontWeight: '800', fontSize: 22 },
    h1: { fontSize: 28, fontWeight: '800', lineHeight: 32, color: '#fff' },
    sub: { fontSize: 15, color: '#fff', opacity: 0.92, marginTop: 8 },
    card: {
        marginHorizontal: 20,
        marginTop: 28,
        padding: 22,
        backgroundColor: '#fff',
        borderRadius: 22,
        shadowColor: '#0F172A',
        shadowOffset: { width: 0, height: 12 },
        shadowOpacity: 0.1,
        shadowRadius: 36,
        elevation: 10,
    },
    error: { marginTop: 12, color: KITAMO.danger, fontSize: 13, fontWeight: '600' },
    primaryBtn: {
        height: 54,
        borderRadius: 14,
        backgroundColor: KITAMO.brand,
        alignItems: 'center',
        justifyContent: 'center',
        marginTop: 18,
        shadowColor: KITAMO.brand,
        shadowOffset: { width: 0, height: 6 },
        shadowOpacity: 0.4,
        shadowRadius: 14,
        elevation: 6,
    },
    primaryBtnText: { color: '#fff', fontSize: 16, fontWeight: '700' },
    dividerRow: { flexDirection: 'row', alignItems: 'center', marginVertical: 16 },
    dividerLine: { flex: 1, height: 1, backgroundColor: KITAMO.line },
    dividerText: { fontSize: 12, color: KITAMO.muted, marginHorizontal: 10 },
    googleBtn: {
        height: 50,
        borderRadius: 14,
        backgroundColor: '#fff',
        borderWidth: 1.5,
        borderColor: KITAMO.line,
        alignItems: 'center',
        justifyContent: 'center',
        flexDirection: 'row',
        gap: 10,
    },
    googleBtnText: { fontSize: 15, fontWeight: '600', color: KITAMO.ink },
    modalBackdrop: { flex: 1, backgroundColor: 'rgba(15,23,42,0.5)', justifyContent: 'center', padding: 24 },
    modalCard: { backgroundColor: '#fff', padding: 22, borderRadius: 18 },
});
