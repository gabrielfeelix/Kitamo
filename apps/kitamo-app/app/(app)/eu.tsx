import { router } from 'expo-router';
import React from 'react';
import { Alert, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';

import { Icon, type IconName } from '@/components/Icon';
import { Screen, useBottomTabPadding } from '@/components/Screen';
import { TabBar } from '@/components/TabBar';
import { navigateToTab } from '@/lib/navigation';
import { useAuth } from '@/stores/authStore';
import { KITAMO } from '@/theme/tokens';

export default function Eu(): React.JSX.Element {
    const user = useAuth((s) => s.user);
    const logout = useAuth((s) => s.logout);
    const bottomPad = useBottomTabPadding();

    const initial = (user?.name ?? '?').charAt(0).toUpperCase();
    const planLabel = user?.plan === 'plus' ? 'Kitamo+' : 'Plano Grátis';

    function handleLogout(): void {
        Alert.alert('Sair', 'Quer mesmo sair? Você precisará entrar de novo na próxima vez.', [
            { text: 'Cancelar', style: 'cancel' },
            {
                text: 'Sair',
                style: 'destructive',
                onPress: async () => {
                    await logout();
                    router.replace('/(auth)/login');
                },
            },
        ]);
    }

    return (
        <Screen bg={KITAMO.bg} barStyle="light" edges={['top']}>
            <ScrollView contentContainerStyle={{ paddingBottom: bottomPad + 60 }} showsVerticalScrollIndicator={false}>
                <View style={styles.tealHeader} pointerEvents="none" />

                <View style={{ paddingHorizontal: 22, paddingTop: 12 }}>
                    <Text style={{ fontSize: 13, color: '#fff', opacity: 0.9, fontWeight: '600' }}>Perfil</Text>
                    <View style={styles.userRow}>
                        <View style={styles.avatar}>
                            <Text style={{ color: KITAMO.brandDark, fontSize: 28, fontWeight: '800' }}>{initial}</Text>
                        </View>
                        <View style={{ flex: 1, marginLeft: 14 }}>
                            <Text style={{ fontSize: 20, fontWeight: '800', color: '#fff' }}>{user?.name ?? '—'}</Text>
                            <Text style={{ fontSize: 13, color: '#fff', opacity: 0.9, marginTop: 2 }}>{user?.email ?? ''}</Text>
                            <View style={styles.planBadge}>
                                <Text style={{ color: '#fff', fontSize: 11, fontWeight: '700' }}>★ {planLabel}</Text>
                            </View>
                        </View>
                    </View>
                </View>

                <View style={{ paddingHorizontal: 16, paddingTop: 24 }}>
                    <Pressable onPress={() => router.push('/planos')} style={styles.upsellCard}>
                        <View style={styles.upsellTopRow}>
                            <View style={styles.upsellIcon}>
                                <Icon name="bot" size={24} color="#fff" />
                            </View>
                            <View style={{ flex: 1, marginLeft: 14 }}>
                                <Text style={{ fontSize: 16, fontWeight: '800', color: KITAMO.ink }}>
                                    Quer um ajudante de finanças?
                                </Text>
                                <Text style={{ fontSize: 13, color: KITAMO.ink2, marginTop: 4, lineHeight: 20 }}>
                                    A <Text style={{ color: KITAMO.brandDark, fontWeight: '700' }}>Kitamo IA</Text> olha seus gastos e te dá dicas práticas todo dia.
                                </Text>
                            </View>
                        </View>
                        <View style={styles.upsellCta}>
                            <Text style={{ color: '#fff', fontWeight: '700', fontSize: 14 }}>Conhecer Kitamo+</Text>
                        </View>
                    </Pressable>

                    <View style={styles.menuGroup}>
                        <MenuRow icon="bot" color={KITAMO.brand} label="Kitamo IA" onPress={() => router.push('/ia')} />
                        <MenuRow icon="imp" color="#3B82F6" label="Importar fatura/extrato" sub="CSV, OFX ou foto da fatura" onPress={() => router.push('/import')} />
                        <MenuRow icon="bolt" color="#8B5CF6" label="Open Finance" sub="Em breve · sincronizar bancos automaticamente" onPress={() => Alert.alert('Em breve', 'Open Finance via BACEN chega na próxima versão. Por enquanto dá pra importar CSV/OFX direto.')} />
                        <MenuRow icon="tag" color="#F59E0B" label="Categorias" sub="Gerenciar suas categorias" onPress={() => router.push('/categorias')} />
                        <MenuRow icon="target" color={KITAMO.warn} label="Metas" sub="Suas metas ativas" onPress={() => router.push('/metas')} />
                        <MenuRow icon="bell" color={KITAMO.info} label="Notificações" onPress={() => router.push('/notif')} />
                        <MenuRow icon="lock" color={KITAMO.ink} label="Segurança" sub="Senha e sessões" onPress={() => router.push('/seguranca')} />
                        <MenuRow icon="card" color={KITAMO.success} label="Meu Plano" onPress={() => router.push('/planos')} last />
                    </View>

                    <Pressable onPress={handleLogout} style={{ marginTop: 18, padding: 16, alignItems: 'center' }}>
                        <Text style={{ color: KITAMO.danger, fontSize: 15, fontWeight: '700' }}>Sair</Text>
                    </Pressable>

                    <Text style={{ textAlign: 'center', fontSize: 11, color: KITAMO.muted }}>Kitamo · v1.0.0</Text>
                </View>
            </ScrollView>

            <TabBar active="eu" onTab={navigateToTab} />
        </Screen>
    );
}

function MenuRow({
    icon,
    color,
    label,
    sub,
    onPress,
    last,
}: {
    icon: IconName;
    color: string;
    label: string;
    sub?: string;
    onPress: () => void;
    last?: boolean;
}): React.JSX.Element {
    return (
        <Pressable
            onPress={onPress}
            style={({ pressed }) => [
                styles.menuRow,
                !last && styles.menuRowBorder,
                pressed && { backgroundColor: KITAMO.line2 },
            ]}
        >
            <View style={[styles.menuIcon, { backgroundColor: `${color}18` }]}>
                <Icon name={icon} size={20} color={color} />
            </View>
            <View style={styles.menuTextCol}>
                <Text style={{ fontSize: 15, fontWeight: '700', color: KITAMO.ink }}>{label}</Text>
                {sub ? <Text style={{ fontSize: 12, color: KITAMO.muted, marginTop: 1 }} numberOfLines={1}>{sub}</Text> : null}
            </View>
            <Icon name="arrow" size={16} color={KITAMO.line} />
        </Pressable>
    );
}

const styles = StyleSheet.create({
    tealHeader: {
        position: 'absolute',
        top: 0,
        left: 0,
        right: 0,
        height: 200,
        backgroundColor: KITAMO.brand,
        borderBottomLeftRadius: 28,
        borderBottomRightRadius: 28,
    },
    userRow: { flexDirection: 'row', alignItems: 'center', marginTop: 14 },
    avatar: {
        width: 64,
        height: 64,
        borderRadius: 32,
        backgroundColor: '#fff',
        alignItems: 'center',
        justifyContent: 'center',
    },
    planBadge: {
        alignSelf: 'flex-start',
        marginTop: 6,
        paddingHorizontal: 8,
        paddingVertical: 3,
        borderRadius: 10,
        backgroundColor: 'rgba(255,255,255,0.22)',
    },
    upsellCard: {
        padding: 18,
        borderRadius: 18,
        backgroundColor: '#fff',
        shadowColor: '#0F172A',
        shadowOffset: { width: 0, height: 8 },
        shadowOpacity: 0.08,
        shadowRadius: 24,
        elevation: 4,
    },
    upsellTopRow: { flexDirection: 'row', alignItems: 'flex-start' },
    upsellIcon: {
        width: 48,
        height: 48,
        borderRadius: 24,
        backgroundColor: KITAMO.brand,
        alignItems: 'center',
        justifyContent: 'center',
    },
    upsellCta: {
        marginTop: 14,
        height: 46,
        borderRadius: 12,
        backgroundColor: KITAMO.brand,
        alignItems: 'center',
        justifyContent: 'center',
    },
    menuGroup: {
        marginTop: 20,
        backgroundColor: '#fff',
        borderRadius: 18,
        overflow: 'hidden',
        shadowColor: '#0F172A',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.04,
        shadowRadius: 8,
        elevation: 1,
    },
    menuRow: {
        flexDirection: 'row',
        alignItems: 'center',
        paddingVertical: 14,
        paddingHorizontal: 16,
        backgroundColor: 'transparent',
    },
    menuRowBorder: {
        borderBottomWidth: 1,
        borderBottomColor: KITAMO.line2,
    },
    menuIcon: {
        width: 36,
        height: 36,
        borderRadius: 10,
        alignItems: 'center',
        justifyContent: 'center',
        marginRight: 14,
    },
    menuTextCol: {
        flex: 1,
        marginRight: 12,
    },
});
