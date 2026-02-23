import React from 'react';
import { AbsoluteFill, interpolate, spring, useCurrentFrame, useVideoConfig } from 'remotion';

const ACCOUNTS = [
    { name: 'Nubank', type: 'Conta Digital', icon: '💜', color: '#7C3AED', balance: 'R$ 3.200,00' },
    { name: 'Itaú', type: 'Conta Corrente', icon: '🟠', color: '#EA580C', balance: 'R$ 8.500,00' },
    { name: 'Cartão Visa', type: 'Crédito', icon: '💳', color: '#0EA5E9', balance: '-R$ 1.200,00' },
];

const DEBTS = [
    { name: 'Aluguel', value: '-R$ 1.800,00', due: 'Todo dia 10', color: '#EF4444' },
    { name: 'Internet', value: '-R$ 120,00', due: 'Todo dia 15', color: '#F97316' },
];

function AccountRow({ name, type, color, balance, progress }: {
    name: string; type: string; color: string; balance: string; progress: number;
}) {
    const isNeg = balance.startsWith('-');
    return (
        <div style={{
            display: 'flex',
            alignItems: 'center',
            gap: 16,
            padding: '14px 20px',
            background: 'white',
            borderRadius: 16,
            marginBottom: 10,
            boxShadow: '0 2px 12px rgba(0,0,0,0.05)',
            opacity: progress,
            transform: `translateX(${interpolate(progress, [0, 1], [-24, 0])}px)`,
            border: `1px solid ${color}22`,
        }}>
            <div style={{
                width: 40, height: 40, borderRadius: 12,
                background: `${color}18`,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
                <div style={{ width: 14, height: 14, borderRadius: 4, background: color }} />
            </div>
            <div style={{ flex: 1 }}>
                <div style={{ fontSize: 15, fontWeight: 700, color: '#0F172A', fontFamily: 'Inter, sans-serif' }}>{name}</div>
                <div style={{ fontSize: 12, color: '#94A3B8', fontFamily: 'Inter, sans-serif' }}>{type}</div>
            </div>
            <div style={{
                fontSize: 15, fontWeight: 700, fontFamily: 'Inter, sans-serif',
                color: isNeg ? '#EF4444' : '#14B8A6',
            }}>{balance}</div>
        </div>
    );
}

function DebtRow({ name, value, due, color, progress }: {
    name: string; value: string; due: string; color: string; progress: number;
}) {
    return (
        <div style={{
            display: 'flex',
            alignItems: 'center',
            gap: 16,
            padding: '14px 20px',
            background: 'white',
            borderRadius: 16,
            marginBottom: 10,
            boxShadow: '0 2px 12px rgba(0,0,0,0.05)',
            opacity: progress,
            transform: `translateX(${interpolate(progress, [0, 1], [24, 0])}px)`,
            border: `1px solid ${color}22`,
        }}>
            <div style={{
                width: 40, height: 40, borderRadius: 12,
                background: `${color}15`,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
                <div style={{ width: 14, height: 4, borderRadius: 2, background: color }} />
            </div>
            <div style={{ flex: 1 }}>
                <div style={{ fontSize: 15, fontWeight: 700, color: '#0F172A', fontFamily: 'Inter, sans-serif' }}>{name}</div>
                <div style={{ fontSize: 12, color: '#94A3B8', fontFamily: 'Inter, sans-serif' }}>{due}</div>
            </div>
            <div style={{
                fontSize: 15, fontWeight: 700, fontFamily: 'Inter, sans-serif',
                color: '#EF4444',
            }}>{value}</div>
        </div>
    );
}

export const RitmoFundacao: React.FC = () => {
    const frame = useCurrentFrame();
    const { fps } = useVideoConfig();

    // Title fade in
    const titleOpacity = interpolate(frame, [0, 12], [0, 1], { extrapolateRight: 'clamp' });
    const titleY = interpolate(frame, [0, 12], [20, 0], { extrapolateRight: 'clamp' });

    // "Contas" section header
    const s1HeaderOp = interpolate(frame, [8, 20], [0, 1], { extrapolateRight: 'clamp' });

    // Accounts stagger in
    const acct0 = spring({ frame: frame - 20, fps, config: { damping: 20, stiffness: 160 } });
    const acct1 = spring({ frame: frame - 32, fps, config: { damping: 20, stiffness: 160 } });
    const acct2 = spring({ frame: frame - 44, fps, config: { damping: 20, stiffness: 160 } });

    // Divider & debts header
    const s2HeaderOp = interpolate(frame, [60, 70], [0, 1], { extrapolateRight: 'clamp' });

    // Debt rows stagger
    const debt0 = spring({ frame: frame - 68, fps, config: { damping: 20, stiffness: 160 } });
    const debt1 = spring({ frame: frame - 80, fps, config: { damping: 20, stiffness: 160 } });

    // Check / success badge
    const checkSpring = spring({ frame: frame - 100, fps, config: { damping: 14, stiffness: 200 } });
    const checkScale = interpolate(checkSpring, [0, 1], [0.4, 1]);
    const checkOpacity = interpolate(checkSpring, [0, 0.1], [0, 1], { extrapolateRight: 'clamp' });

    // Total balance reveal
    const totalOpacity = interpolate(frame, [108, 118], [0, 1], { extrapolateRight: 'clamp' });

    // Background fade
    const bgLightness = interpolate(frame, [0, 20], [0.97, 1], { extrapolateRight: 'clamp' });

    return (
        <AbsoluteFill style={{
            background: '#F8FAFC',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontFamily: 'Inter, system-ui, sans-serif',
        }}>
            {/* Card shell */}
            <div style={{
                width: 640,
                background: 'white',
                borderRadius: 32,
                padding: 40,
                boxShadow: '0 24px 80px rgba(0,0,0,0.10)',
                border: '1px solid #E2E8F0',
            }}>
                {/* Top bar */}
                <div style={{
                    display: 'flex', alignItems: 'center', gap: 12, marginBottom: 32,
                    opacity: titleOpacity, transform: `translateY(${titleY}px)`
                }}>
                    <div style={{
                        width: 44, height: 44, borderRadius: 14,
                        background: 'linear-gradient(135deg, #14B8A6, #06B6D4)',
                        display: 'flex', alignItems: 'center', justifyContent: 'center',
                    }}>
                        <span style={{ color: 'white', fontWeight: 800, fontSize: 20 }}>K</span>
                    </div>
                    <div>
                        <div style={{ fontSize: 18, fontWeight: 800, color: '#0F172A', letterSpacing: '-0.03em' }}>
                            01 — A Fundação
                        </div>
                        <div style={{ fontSize: 12, color: '#94A3B8', fontWeight: 500 }}>Configure em 1 minuto</div>
                    </div>
                </div>

                {/* Accounts section */}
                <div style={{ opacity: s1HeaderOp, marginBottom: 12 }}>
                    <div style={{
                        fontSize: 11, fontWeight: 800, color: '#14B8A6',
                        textTransform: 'uppercase', letterSpacing: '0.12em', marginBottom: 12,
                    }}>💰 Suas Contas</div>
                    <AccountRow {...ACCOUNTS[0]} progress={acct0} />
                    <AccountRow {...ACCOUNTS[1]} progress={acct1} />
                    <AccountRow {...ACCOUNTS[2]} progress={acct2} />
                </div>

                {/* Divider */}
                <div style={{
                    height: 1, background: '#F1F5F9', margin: '8px 0 20px', opacity: s2HeaderOp,
                }} />

                {/* Debts section */}
                <div style={{ opacity: s2HeaderOp, marginBottom: 16 }}>
                    <div style={{
                        fontSize: 11, fontWeight: 800, color: '#EF4444',
                        textTransform: 'uppercase', letterSpacing: '0.12em', marginBottom: 12,
                    }}>📅 Dívidas Fixas</div>
                    <DebtRow {...DEBTS[0]} progress={debt0} />
                    <DebtRow {...DEBTS[1]} progress={debt1} />
                </div>

                {/* Success footer */}
                <div style={{
                    display: 'flex', alignItems: 'center', justifyContent: 'space-between',
                    padding: '16px 20px',
                    background: 'linear-gradient(135deg, #F0FDF4, #ECFDF5)',
                    borderRadius: 16, border: '1px solid #BBF7D0',
                    opacity: totalOpacity,
                }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                        <div style={{
                            width: 36, height: 36, borderRadius: '50%',
                            background: '#14B8A6',
                            display: 'flex', alignItems: 'center', justifyContent: 'center',
                            transform: `scale(${checkScale})`,
                            opacity: checkOpacity,
                        }}>
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="3">
                                <path d="M5 13l4 4L19 7" strokeLinecap="round" strokeLinejoin="round" />
                            </svg>
                        </div>
                        <span style={{ fontSize: 14, fontWeight: 700, color: '#14532D' }}>Base configurada!</span>
                    </div>
                    <div style={{ textAlign: 'right' }}>
                        <div style={{ fontSize: 11, color: '#86EFAC', fontWeight: 600 }}>SALDO LÍQUIDO</div>
                        <div style={{ fontSize: 20, fontWeight: 800, color: '#14B8A6', letterSpacing: '-0.03em' }}>
                            R$ 8.680,00
                        </div>
                    </div>
                </div>
            </div>
        </AbsoluteFill>
    );
};
