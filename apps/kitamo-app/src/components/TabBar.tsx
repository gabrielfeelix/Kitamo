import React from 'react';
import { Pressable, Text, View } from 'react-native';
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
    return (
        <View
            style={{
                position: 'absolute',
                left: 0,
                right: 0,
                bottom: 0,
                paddingBottom: Math.max(insets.bottom, 8),
                paddingTop: 8,
                backgroundColor: '#fff',
                borderTopWidth: 1,
                borderTopColor: KITAMO.line2,
                flexDirection: 'row',
                alignItems: 'flex-start',
                shadowColor: '#0F172A',
                shadowOffset: { width: 0, height: -2 },
                shadowOpacity: 0.04,
                shadowRadius: 12,
                elevation: 6,
            }}
        >
            <TabButton tab={TABS[0]} active={active === TABS[0].id} onPress={() => onTab(TABS[0].id)} />
            <TabButton tab={TABS[1]} active={active === TABS[1].id} onPress={() => onTab(TABS[1].id)} />
            <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
                <Pressable
                    onPress={() => onTab('add')}
                    style={({ pressed }) => ({
                        width: 60,
                        height: 60,
                        borderRadius: 30,
                        marginTop: -22,
                        backgroundColor: KITAMO.brand,
                        borderWidth: 4,
                        borderColor: '#fff',
                        alignItems: 'center',
                        justifyContent: 'center',
                        transform: [{ scale: pressed ? 0.95 : 1 }],
                        shadowColor: KITAMO.brand,
                        shadowOffset: { width: 0, height: 8 },
                        shadowOpacity: 0.4,
                        shadowRadius: 20,
                        elevation: 8,
                    })}
                    accessibilityLabel="Adicionar"
                >
                    <Icon name="plus" size={28} color="#fff" />
                </Pressable>
            </View>
            <TabButton tab={TABS[2]} active={active === TABS[2].id} onPress={() => onTab(TABS[2].id)} />
            <TabButton tab={TABS[3]} active={active === TABS[3].id} onPress={() => onTab(TABS[3].id)} />
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
        <Pressable
            onPress={onPress}
            style={{
                flex: 1,
                paddingVertical: 8,
                alignItems: 'center',
                justifyContent: 'center',
                gap: 4,
            }}
        >
            <Icon name={tab.icon} size={22} color={color} />
            <Text style={{ fontSize: 11, color, fontWeight: active ? '700' : '500' }}>{tab.label}</Text>
        </Pressable>
    );
}
