import { useMutation } from '@tanstack/react-query';
import { router, useLocalSearchParams } from 'expo-router';
import React, { useEffect, useRef, useState } from 'react';
import { ActivityIndicator, Pressable, ScrollView, Text, TextInput, View } from 'react-native';
import { KeyboardAwareScrollView } from 'react-native-keyboard-controller';

import { extractApiError } from '@/api/client';
import { aiApi } from '@/api/endpoints';
import { Icon } from '@/components/Icon';
import { Screen } from '@/components/Screen';
import { KITAMO } from '@/theme/tokens';

type Message = { role: 'user' | 'kit'; text: string };

export default function IAChat(): React.JSX.Element {
    const params = useLocalSearchParams<{ q?: string }>();
    const [messages, setMessages] = useState<Message[]>([
        { role: 'kit', text: 'Oi! Eu sou a Kit. Posso te ajudar a entender seus gastos. O que quer saber?' },
    ]);
    const [input, setInput] = useState('');
    const scrollRef = useRef<ScrollView>(null);

    const chat = useMutation({
        mutationFn: (msg: string) => aiApi.chat(msg),
        onSuccess: (data) => {
            setMessages((prev) => [...prev, { role: 'kit', text: data.reply }]);
            setTimeout(() => scrollRef.current?.scrollToEnd({ animated: true }), 100);
        },
        onError: (e) => {
            setMessages((prev) => [...prev, { role: 'kit', text: 'Não consegui responder agora. ' + extractApiError(e) }]);
        },
    });

    useEffect(() => {
        if (params.q && messages.length === 1) {
            send(String(params.q));
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [params.q]);

    function send(text?: string): void {
        const msg = (text ?? input).trim();
        if (!msg || chat.isPending) return;
        setMessages((prev) => [...prev, { role: 'user', text: msg }]);
        setInput('');
        chat.mutate(msg);
        setTimeout(() => scrollRef.current?.scrollToEnd({ animated: true }), 50);
    }

    return (
        <Screen bg={KITAMO.bg} barStyle="light" edges={['top', 'bottom']}>
            <View style={{ backgroundColor: KITAMO.brand, paddingHorizontal: 16, paddingVertical: 14, borderBottomLeftRadius: 20, borderBottomRightRadius: 20 }}>
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10 }}>
                    <Pressable
                        onPress={() => router.back()}
                        style={{ width: 34, height: 34, borderRadius: 17, backgroundColor: 'rgba(255,255,255,0.2)', alignItems: 'center', justifyContent: 'center' }}
                    >
                        <Icon name="back" size={16} color="#fff" />
                    </Pressable>
                    <View style={{ width: 38, height: 38, borderRadius: 19, backgroundColor: '#fff', alignItems: 'center', justifyContent: 'center' }}>
                        <Icon name="bot" size={20} color={KITAMO.brandDark} />
                    </View>
                    <View style={{ flex: 1 }}>
                        <Text style={{ fontSize: 15, fontWeight: '800', color: '#fff' }}>Kit</Text>
                        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 4 }}>
                            <View style={{ width: 6, height: 6, borderRadius: 3, backgroundColor: '#5EEAD4' }} />
                            <Text style={{ fontSize: 11, color: '#fff', opacity: 0.85 }}>Online · responde em segundos</Text>
                        </View>
                    </View>
                </View>
            </View>

            <ScrollView
                ref={scrollRef}
                style={{ flex: 1 }}
                contentContainerStyle={{ padding: 14, gap: 10 }}
                showsVerticalScrollIndicator={false}
            >
                {messages.map((m, i) => (m.role === 'user' ? <UserMsg key={i}>{m.text}</UserMsg> : <KitMsg key={i}>{m.text}</KitMsg>))}
                {chat.isPending ? (
                    <View
                        style={{
                            alignSelf: 'flex-start',
                            padding: 12,
                            backgroundColor: '#fff',
                            borderRadius: 16,
                            borderTopLeftRadius: 4,
                            flexDirection: 'row',
                            gap: 6,
                        }}
                    >
                        <ActivityIndicator color={KITAMO.muted} />
                    </View>
                ) : null}
            </ScrollView>

            <View
                style={{
                    paddingHorizontal: 14,
                    paddingTop: 8,
                    paddingBottom: 14,
                    flexDirection: 'row',
                    alignItems: 'center',
                    gap: 8,
                    backgroundColor: KITAMO.bg,
                    borderTopWidth: 1,
                    borderTopColor: KITAMO.line2,
                }}
            >
                <View style={{ flex: 1, paddingHorizontal: 16, paddingVertical: 10, backgroundColor: '#fff', borderRadius: 24, borderWidth: 1, borderColor: KITAMO.line }}>
                    <TextInput
                        value={input}
                        onChangeText={setInput}
                        placeholder="Pergunta pra Kit..."
                        placeholderTextColor={KITAMO.muted}
                        style={{ fontSize: 14, color: KITAMO.ink, paddingVertical: 0, minHeight: 22 }}
                        onSubmitEditing={() => send()}
                        returnKeyType="send"
                    />
                </View>
                <Pressable
                    onPress={() => send()}
                    style={{ width: 44, height: 44, borderRadius: 22, backgroundColor: KITAMO.brand, alignItems: 'center', justifyContent: 'center' }}
                >
                    <Icon name="send" size={18} color="#fff" />
                </Pressable>
            </View>
        </Screen>
    );
}

function KitMsg({ children }: { children: string }): React.JSX.Element {
    return (
        <View
            style={{
                alignSelf: 'flex-start',
                maxWidth: '82%',
                padding: 12,
                backgroundColor: '#fff',
                borderRadius: 16,
                borderTopLeftRadius: 4,
                shadowColor: '#0F172A',
                shadowOffset: { width: 0, height: 1 },
                shadowOpacity: 0.05,
                shadowRadius: 3,
                elevation: 1,
            }}
        >
            <Text style={{ fontSize: 14, color: KITAMO.ink, lineHeight: 20 }}>{children}</Text>
        </View>
    );
}

function UserMsg({ children }: { children: string }): React.JSX.Element {
    return (
        <View
            style={{
                alignSelf: 'flex-end',
                maxWidth: '80%',
                padding: 12,
                backgroundColor: KITAMO.brand,
                borderRadius: 16,
                borderTopRightRadius: 4,
            }}
        >
            <Text style={{ fontSize: 14, color: '#fff', lineHeight: 20 }}>{children}</Text>
        </View>
    );
}
