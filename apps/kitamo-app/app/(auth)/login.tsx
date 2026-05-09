import { router } from 'expo-router';
import React, { useState } from 'react';
import { Alert, Pressable, ScrollView, Text, View } from 'react-native';
import { KeyboardAwareScrollView } from 'react-native-keyboard-controller';

import { extractApiError } from '@/api/client';
import { authApi } from '@/api/endpoints';
import { Button } from '@/components/Button';
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

    async function submit(): Promise<void> {
        if (!email || !password || (mode === 'register' && !name)) {
            setError('Preenche todos os campos.');
            return;
        }
        setError(null);
        setLoading(true);
        try {
            const res = mode === 'login' ? await authApi.login(email.trim(), password) : await authApi.register(name.trim(), email.trim(), password);
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

    return (
        <Screen bg="#fff" barStyle="light" edges={['top']}>
            <View style={{ position: 'absolute', top: 0, left: 0, right: 0, height: 320, backgroundColor: KITAMO.brand, borderBottomLeftRadius: 60, borderBottomRightRadius: 60 }} />

            <KeyboardAwareScrollView
                style={{ flex: 1 }}
                contentContainerStyle={{ paddingBottom: 60 }}
                keyboardShouldPersistTaps="handled"
            >
                <View style={{ position: 'relative', padding: 24, flexDirection: 'row', alignItems: 'center', gap: 10 }}>
                    <KitamoLogo size={32} color="#fff" />
                    <Text style={{ color: '#fff', fontWeight: '800', fontSize: 22 }}>kitamo</Text>
                </View>
                <View style={{ paddingHorizontal: 24, marginTop: 16 }}>
                    <Text style={{ fontSize: 28, fontWeight: '800', lineHeight: 32, color: '#fff' }}>
                        {mode === 'login' ? 'Bora organizar\nessa grana?' : 'Vamos criar sua conta'}
                    </Text>
                    <Text style={{ fontSize: 15, color: '#fff', opacity: 0.9, marginTop: 8 }}>
                        {mode === 'login' ? 'Entra com seu e-mail pra continuar.' : 'Em 30 segundos sua conta tá pronta.'}
                    </Text>
                </View>

                <View
                    style={{
                        marginHorizontal: 20,
                        marginTop: 30,
                        padding: 24,
                        backgroundColor: '#fff',
                        borderRadius: 20,
                        shadowColor: '#0F172A',
                        shadowOffset: { width: 0, height: 12 },
                        shadowOpacity: 0.1,
                        shadowRadius: 40,
                        elevation: 8,
                    }}
                >
                    {mode === 'register' ? (
                        <>
                            <Field label="Nome" value={name} onChangeText={setName} autoCapitalize="words" />
                            <View style={{ height: 14 }} />
                        </>
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
                    <Field label="Senha" value={password} onChangeText={setPassword} secureTextEntry autoCapitalize="none" />

                    {mode === 'login' ? (
                        <View style={{ alignItems: 'flex-end', marginTop: 10 }}>
                            <Text style={{ fontSize: 13, color: KITAMO.muted }}>Esqueci minha senha</Text>
                        </View>
                    ) : null}

                    {error ? (
                        <Text style={{ marginTop: 12, color: KITAMO.danger, fontSize: 13, fontWeight: '600' }}>{error}</Text>
                    ) : null}

                    <View style={{ height: 18 }} />
                    <Button onPress={submit} loading={loading}>
                        {mode === 'login' ? 'Entrar' : 'Criar conta'}
                    </Button>

                    <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10, marginVertical: 18 }}>
                        <View style={{ flex: 1, height: 1, backgroundColor: KITAMO.line }} />
                        <Text style={{ fontSize: 12, color: KITAMO.muted }}>ou</Text>
                        <View style={{ flex: 1, height: 1, backgroundColor: KITAMO.line }} />
                    </View>

                    <Button
                        variant="outline"
                        onPress={() => Alert.alert('Em breve', 'Login com Google será habilitado em uma próxima versão.')}
                        leading={<Icon name="google" size={20} />}
                        height={52}
                    >
                        Entrar com Google
                    </Button>
                </View>

                <View style={{ alignItems: 'center', marginTop: 28 }}>
                    <Text style={{ fontSize: 14, color: KITAMO.muted }}>
                        {mode === 'login' ? 'Novo aqui? ' : 'Já tem conta? '}
                        <Pressable onPress={() => setMode(mode === 'login' ? 'register' : 'login')} hitSlop={6}>
                            <Text style={{ fontSize: 14, color: KITAMO.brandDark, fontWeight: '700' }}>
                                {mode === 'login' ? 'Criar conta' : 'Fazer login'}
                            </Text>
                        </Pressable>
                    </Text>
                </View>
            </KeyboardAwareScrollView>
        </Screen>
    );
}
