import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { Icon, type IconName } from '@/components/Icon';
import { KITAMO } from '@/theme/tokens';

export type TabId = 'home' | 'contas' | 'gastos' | 'eu';

type Props = {
    active: TabId;
    onTab: (id: TabId | 'add') => void;
};

const TABS: { id: TabId; label: string; icon: IconName }[] = [
    { id: 'home', label: 'Início', icon: 'home' },
    { id: 'contas', label: 'Contas', icon: 'bank' },
    { id: 'gastos', label: 'Gastos', icon: 'chart' },
    { id: 'eu', label: 'Eu', icon: 'user' },
];

export function TabBar({ active, onTab }: Props): React.JSX.Element {
    const insets = useSafeAreaInsets();
    const bottomPad = Math.max(insets.bottom, 8);
    return (
        <View pointerEvents="box-none" style={[styles.wrap, { paddingBottom: bottomPad }]}>
            <View style={styles.row}>
                <TabButton tab={TABS[0]} active={active === TABS[0].id} onPress={() => onTab(TABS[0].id)} />
                <TabButton tab={TABS[1]} active={active === TABS[1].id} onPress={() => onTab(TABS[1].id)} />
                <View style={styles.fabSpacer} />
                <TabButton tab={TABS[2]} active={active === TABS[2].id} onPress={() => onTab(TABS[2].id)} />
                <TabButton tab={TABS[3]} active={active === TABS[3].id} onPress={() => onTab(TABS[3].id)} />
            </View>
            <Pressable
                onPress={() => onTab('add')}
                accessibilityLabel="Adicionar"
                style={({ pressed }) => [styles.fab, { bottom: bottomPad + 28, transform: [{ scale: pressed ? 0.94 : 1 }] }]}
            >
                <Icon name="plus" size={30} color="#fff" />
            </Pressable>
        </View>
    );
}

type TabButtonProps = {
    tab: (typeof TABS)[number];
    active: boolean;
    onPress: () => void;
};

function TabButton({ tab, active, onPress }: TabButtonProps): React.JSX.Element {
    const color = active ? KITAMO.brandDark : KITAMO.muted;
    return (
        <Pressable onPress={onPress} style={styles.tabBtn}>
            <Icon name={tab.icon} size={22} color={color} />
            <Text style={{ fontSize: 11, color, fontWeight: active ? '700' : '500', marginTop: 4 }}>{tab.label}</Text>
        </Pressable>
    );
}

const styles = StyleSheet.create({
    wrap: {
        position: 'absolute',
        left: 0,
        right: 0,
        bottom: 0,
        paddingTop: 8,
        backgroundColor: '#fff',
        borderTopWidth: 1,
        borderTopColor: KITAMO.line2,
        shadowColor: '#0F172A',
        shadowOffset: { width: 0, height: -2 },
        shadowOpacity: 0.06,
        shadowRadius: 12,
        elevation: 8,
    },
    row: {
        flexDirection: 'row',
        alignItems: 'center',
        height: 56,
    },
    tabBtn: {
        flex: 1,
        height: '100%',
        alignItems: 'center',
        justifyContent: 'center',
    },
    fabSpacer: {
        width: 76,
    },
    fab: {
        position: 'absolute',
        alignSelf: 'center',
        width: 64,
        height: 64,
        borderRadius: 32,
        backgroundColor: KITAMO.brand,
        borderWidth: 4,
        borderColor: '#fff',
        alignItems: 'center',
        justifyContent: 'center',
        shadowColor: KITAMO.brand,
        shadowOffset: { width: 0, height: 8 },
        shadowOpacity: 0.45,
        shadowRadius: 16,
        elevation: 12,
    },
});
