import React from 'react';
import { Text, TextInput, View, type TextInputProps } from 'react-native';

import { KITAMO, RADIUS } from '@/theme/tokens';

type Props = TextInputProps & {
    label: string;
    error?: string | null;
    trailing?: React.ReactNode;
};

export function Field({ label, error, trailing, value, ...rest }: Props): React.JSX.Element {
    return (
        <View>
            <View
                style={{
                    borderColor: error ? KITAMO.danger : KITAMO.line,
                    borderWidth: 1.5,
                    borderRadius: RADIUS.lg,
                    paddingHorizontal: 14,
                    paddingVertical: 8,
                    backgroundColor: '#fff',
                    flexDirection: 'row',
                    alignItems: 'center',
                    gap: 10,
                }}
            >
                <View style={{ flex: 1 }}>
                    <Text style={{ fontSize: 11, color: KITAMO.muted, fontWeight: '700', letterSpacing: 0.4 }}>
                        {label.toUpperCase()}
                    </Text>
                    <TextInput
                        value={value}
                        placeholderTextColor={KITAMO.muted}
                        style={{
                            fontSize: 16,
                            color: KITAMO.ink,
                            fontWeight: '500',
                            marginTop: 2,
                            paddingVertical: 0,
                            minHeight: 22,
                        }}
                        {...rest}
                    />
                </View>
                {trailing}
            </View>
            {error ? (
                <Text style={{ marginTop: 6, color: KITAMO.danger, fontSize: 12, fontWeight: '600' }}>{error}</Text>
            ) : null}
        </View>
    );
}
