import { useQuery } from '@tanstack/react-query';
import { router } from 'expo-router';
import React from 'react';
import { ActivityIndicator, Pressable, ScrollView, Text, View } from 'react-native';

import { apiClient } from '@/api/client';
import { Icon } from '@/components/Icon';
import { Screen } from '@/components/Screen';
import { KITAMO } from '@/theme/tokens';

type Plan = {
    id: number;
    name: string;
    slug: string;
    description: string | null;
    price_cents: number;
    currency: string;
    interval: string;
    is_popular: boolean;
    trial_days: number;
};

type PlansResponse = { plans: Plan[]; current: string };

const FALLBACK: Plan[] = [
    {
        id: 1,
        name: 'Kitamo Grátis',
        slug: 'free',
        description: 'O básico pra organizar a grana',
        price_cents: 0,
        currency: 'BRL',
        interval: 'monthly',
        is_popular: false,
        trial_days: 0,
    },
    {
        id: 2,
        name: 'Kitamo+',
        slug: 'plus',
        description: 'Tudo do grátis + Kitamo IA todo dia',
        price_cents: 990,
        currency: 'BRL',
        interval: 'monthly',
        is_popular: true,
        trial_days: 7,
    },
];

export default function Planos(): React.JSX.Element {
    const plans = useQuery({
        queryKey: ['plans'],
        queryFn: async (): Promise<PlansResponse> => {
            const { data } = await apiClient.get<PlansResponse>('/plans');
            return data;
        },
    });

    const list = plans.data?.plans?.length ? plans.data.plans : FALLBACK;
    const current = plans.data?.current ?? 'free';

    return (
        <Screen bg={KITAMO.bg} edges={['top', 'bottom']}>
            <View style={{ paddingHorizontal: 16, paddingTop: 8 }}>
                <Pressable
                    onPress={() => router.back()}
                    style={{ width: 36, height: 36, borderRadius: 18, backgroundColor: '#fff', alignItems: 'center', justifyContent: 'center' }}
                >
                    <Icon name="back" size={18} color={KITAMO.ink} />
                </Pressable>
            </View>

            <ScrollView contentContainerStyle={{ paddingBottom: 60 }} showsVerticalScrollIndicator={false}>
                <View style={{ paddingHorizontal: 22, paddingTop: 18 }}>
                    <Text style={{ fontSize: 30, fontWeight: '800', letterSpacing: -0.6, color: KITAMO.ink, lineHeight: 34 }}>
                        Escolhe o teu{'\n'}plano
                    </Text>
                    <Text style={{ fontSize: 14, color: KITAMO.ink2, marginTop: 8 }}>Sem pegadinha, cancela quando quiser.</Text>
                </View>

                {plans.isLoading ? (
                    <View style={{ paddingVertical: 60, alignItems: 'center' }}>
                        <ActivityIndicator color={KITAMO.brand} />
                    </View>
                ) : (
                    <View style={{ paddingHorizontal: 16, paddingTop: 22 }}>
                        {list.map((p) => (
                            <PlanCard key={p.id} plan={p} isCurrent={p.slug === current} />
                        ))}
                    </View>
                )}
            </ScrollView>
        </Screen>
    );
}

function PlanCard({ plan, isCurrent }: { plan: Plan; isCurrent: boolean }): React.JSX.Element {
    const isPaid = plan.price_cents > 0;
    return (
        <View
            style={{
                padding: 20,
                backgroundColor: '#fff',
                borderRadius: 20,
                marginBottom: 14,
                position: 'relative',
                borderWidth: plan.is_popular ? 2 : 0,
                borderColor: plan.is_popular ? KITAMO.brand : 'transparent',
                shadowColor: plan.is_popular ? KITAMO.brand : '#0F172A',
                shadowOffset: { width: 0, height: plan.is_popular ? 12 : 2 },
                shadowOpacity: plan.is_popular ? 0.18 : 0.04,
                shadowRadius: plan.is_popular ? 32 : 8,
                elevation: plan.is_popular ? 6 : 1,
            }}
        >
            {plan.is_popular ? (
                <View
                    style={{
                        position: 'absolute',
                        top: -12,
                        left: 20,
                        paddingHorizontal: 12,
                        paddingVertical: 5,
                        borderRadius: 10,
                        backgroundColor: KITAMO.brand,
                    }}
                >
                    <Text style={{ color: '#fff', fontSize: 11, fontWeight: '800', letterSpacing: 0.5 }}>MAIS ESCOLHIDO</Text>
                </View>
            ) : null}

            <View style={{ flexDirection: 'row', alignItems: 'baseline', justifyContent: 'space-between' }}>
                <Text style={{ fontSize: 20, fontWeight: '800', color: KITAMO.ink }}>{plan.name}</Text>
                <View style={{ flexDirection: 'row', alignItems: 'baseline' }}>
                    <Text style={{ fontSize: 24, fontWeight: '800', color: KITAMO.ink }}>R$ {(plan.price_cents / 100).toFixed(2).replace('.', ',')}</Text>
                    {isPaid ? <Text style={{ fontSize: 13, color: KITAMO.muted }}>/mês</Text> : null}
                </View>
            </View>
            {plan.description ? <Text style={{ fontSize: 13, color: KITAMO.muted, marginTop: 4 }}>{plan.description}</Text> : null}

            <Pressable
                disabled={isCurrent}
                onPress={() => {
                    if (!isCurrent) {
                        // Em uma versão futura, abrir o checkout. Por enquanto só notifica visualmente.
                    }
                }}
                style={{
                    width: '100%',
                    height: isPaid ? 52 : 48,
                    marginTop: 18,
                    borderRadius: 12,
                    backgroundColor: isCurrent ? KITAMO.line2 : isPaid ? KITAMO.brand : '#fff',
                    borderWidth: isPaid ? 0 : 1.5,
                    borderColor: KITAMO.line,
                    alignItems: 'center',
                    justifyContent: 'center',
                }}
            >
                <Text
                    style={{
                        color: isCurrent ? KITAMO.muted : isPaid ? '#fff' : KITAMO.ink,
                        fontWeight: '700',
                        fontSize: 14,
                    }}
                >
                    {isCurrent ? 'Plano atual' : isPaid && plan.trial_days > 0 ? `Começar grátis ${plan.trial_days} dias` : 'Continuar grátis'}
                </Text>
            </Pressable>
            {isPaid ? (
                <Text style={{ textAlign: 'center', fontSize: 11, color: KITAMO.muted, marginTop: 8 }}>Cancela quando quiser, sem pegadinha</Text>
            ) : null}
        </View>
    );
}
