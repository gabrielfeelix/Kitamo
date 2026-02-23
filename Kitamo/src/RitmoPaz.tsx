import React from 'react';
import { AbsoluteFill, interpolate, spring, useCurrentFrame, useVideoConfig } from 'remotion';

// ─── VIDEO 04: A PAZ ──────────────────────────────────────────────────
// Shows the month going from red to blue/green — cuts made, route adjusted.
// Theme: resolution, calma, control restored.

function ExpenseRow({ name, amount, cut, cutProgress, rowProgress }: {
    name: string; amount: string; cut: boolean; cutProgress: number; rowProgress: number;
}) {
    const strikeWidth = `${cutProgress * 100}%`;
    return (
        <div style={{
            display: 'flex', alignItems: 'center', gap: 14,
            padding: '12px 16px',
            background: cut && cutProgress > 0.1 ? `rgba(20,184,166,${cutProgress * 0.06})` : 'rgba(255,255,255,0.04)',
            borderRadius: 14, marginBottom: 8,
            border: cut && cutProgress > 0.1 ? `1px solid rgba(20,184,166,${cutProgress * 0.2})` : '1px solid rgba(255,255,255,0.06)',
            opacity: rowProgress,
            transform: `translateX(${interpolate(rowProgress, [0, 1], [-20, 0])}px)`,
        }}>
            {/* Cut checkbox */}
            <div style={{
                width: 22, height: 22, borderRadius: 7,
                background: cut && cutProgress > 0.8 ? '#14B8A6' : 'transparent',
                border: `2px solid ${cut && cutProgress > 0.1 ? `rgba(20,184,166,${Math.min(cutProgress, 1)})` : 'rgba(255,255,255,0.15)'}`,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                flexShrink: 0,
                transform: `scale(${cut && cutProgress > 0.8 ? 1 : 0.9})`,
            }}>
                {cut && cutProgress > 0.8 && (
                    <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="3.5">
                        <path d="M5 13l4 4L19 7" strokeLinecap="round" strokeLinejoin="round" />
                    </svg>
                )}
            </div>

            {/* Name with strikethrough */}
            <div style={{ flex: 1, position: 'relative' }}>
                <div style={{
                    fontSize: 14, fontWeight: 600,
                    color: cut && cutProgress > 0.5 ? `rgba(100,116,139,${1 - cutProgress * 0.4})` : 'white',
                }}>
                    {name}
                </div>
                {cut && (
                    <div style={{
                        position: 'absolute', top: '50%', left: 0,
                        height: 1.5, background: '#14B8A6', borderRadius: 1,
                        width: strikeWidth, transition: 'none',
                    }} />
                )}
            </div>

            {/* Amount */}
            <div style={{
                fontSize: 14, fontWeight: 700,
                color: cut && cutProgress > 0.5 ? `rgba(100,116,139,${1 - cutProgress * 0.4})` : '#EF4444',
                textDecoration: 'none',
            }}>
                {amount}
            </div>

            {/* Saved badge */}
            {cut && cutProgress > 0.85 && (
                <div style={{
                    background: 'rgba(20,184,166,0.15)', color: '#14B8A6',
                    fontSize: 10, fontWeight: 800, padding: '3px 8px', borderRadius: 6,
                    opacity: interpolate(cutProgress, [0.85, 1], [0, 1], { extrapolateRight: 'clamp' }),
                }}>
                    CORTADO
                </div>
            )}
        </div>
    );
}

export const RitmoPaz: React.FC = () => {
    const frame = useCurrentFrame();
    const { fps } = useVideoConfig();

    // ─── Phase 1: Scene loads + month in red (0-20) ───
    const sceneFade = interpolate(frame, [0, 16], [0, 1], { extrapolateRight: 'clamp' });

    // ─── Phase 2: Expense rows appear (12-45) ───
    const row0 = spring({ frame: frame - 12, fps, config: { damping: 20, stiffness: 160 } });
    const row1 = spring({ frame: frame - 20, fps, config: { damping: 20, stiffness: 160 } });
    const row2 = spring({ frame: frame - 28, fps, config: { damping: 20, stiffness: 160 } });
    const row3 = spring({ frame: frame - 36, fps, config: { damping: 20, stiffness: 160 } });

    // ─── Phase 3: Cuts happen sequentially (48-90) ───
    const cut0 = spring({ frame: frame - 48, fps, config: { damping: 16, stiffness: 120 } });
    const cut1 = spring({ frame: frame - 64, fps, config: { damping: 16, stiffness: 120 } });

    // ─── Phase 4: Balance sweeps up from red to green (85-110) ───
    const sweepSpring = spring({ frame: frame - 85, fps, config: { damping: 16, stiffness: 80 } });

    // Balance: starts at -800 (red), sweeps to +2400 (green)
    const balanceRaw = interpolate(sweepSpring, [0, 1], [-800, 2400]);

    // Color: red → teal
    const colorR = Math.round(interpolate(sweepSpring, [0, 1], [239, 20]));
    const colorG = Math.round(interpolate(sweepSpring, [0, 1], [68, 184]));
    const colorB = Math.round(interpolate(sweepSpring, [0, 1], [68, 166]));
    const balColor = `rgb(${colorR},${colorG},${colorB})`;
    const bgColor = `rgba(${colorR},${colorG},${colorB},0.08)`;
    const borderColor = `rgba(${colorR},${colorG},${colorB},0.2)`;

    // ─── Phase 5: Peace badge lands (108-120) ───
    const peaceSpring = spring({ frame: frame - 108, fps, config: { damping: 14, stiffness: 200 } });
    const peaceScale = interpolate(peaceSpring, [0, 1], [0.5, 1]);
    const peaceOp = interpolate(peaceSpring, [0, 0.15], [0, 1], { extrapolateRight: 'clamp' });

    // ─── Background glow transitions ───
    const glowR = Math.round(interpolate(sweepSpring, [0, 1], [239, 20]));
    const glowG = Math.round(interpolate(sweepSpring, [0, 1], [68, 184]));
    const glowB = Math.round(interpolate(sweepSpring, [0, 1], [68, 166]));

    const expenses = [
        { name: 'Netflix + Max + Disney+', amount: '-R$ 97,90', cut: true },
        { name: 'Academia (pausar 1 mês)', amount: '-R$ 89,00', cut: true },
        { name: 'Aluguel', amount: '-R$ 1.800,00', cut: false },
        { name: 'Supermercado', amount: '-R$ 600,00', cut: false },
    ];
    const rowProgress = [row0, row1, row2, row3];
    const cuts = [cut0, cut1, 0, 0];

    return (
        <AbsoluteFill style={{
            background: '#0F172A',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontFamily: 'Inter, system-ui, sans-serif',
        }}>
            {/* Animated bg glow */}
            <div style={{
                position: 'absolute', top: '20%', left: '50%', transform: 'translateX(-50%)',
                width: 600, height: 600, borderRadius: '50%',
                background: `radial-gradient(circle, rgba(${glowR},${glowG},${glowB},0.08) 0%, transparent 70%)`,
                pointerEvents: 'none',
            }} />

            <div style={{
                width: 680,
                background: '#1E293B',
                borderRadius: 32,
                padding: 40,
                boxShadow: '0 40px 120px rgba(0,0,0,0.5)',
                border: '1px solid rgba(255,255,255,0.06)',
                opacity: sceneFade,
            }}>
                {/* Header */}
                <div style={{ marginBottom: 28 }}>
                    <div style={{
                        fontSize: 11, color: '#475569', fontWeight: 700,
                        letterSpacing: '0.12em', textTransform: 'uppercase', marginBottom: 6,
                    }}>
                        04 — A PAZ
                    </div>
                    <div style={{ display: 'flex', alignItems: 'baseline', gap: 8 }}>
                        <div style={{ fontSize: 13, color: '#475569' }}>Saldo no fim do mês:</div>
                        <div style={{
                            fontSize: 32, fontWeight: 800, letterSpacing: '-0.04em',
                            color: balColor,
                        }}>
                            {balanceRaw >= 0 ? '+' : ''}R$ {Math.abs(Math.round(balanceRaw)).toLocaleString('pt-BR')}
                        </div>
                    </div>

                    {/* Balance bar */}
                    <div style={{
                        marginTop: 14,
                        height: 8, background: 'rgba(255,255,255,0.06)', borderRadius: 8, overflow: 'hidden',
                    }}>
                        <div style={{
                            height: '100%',
                            width: `${Math.max(0, interpolate(sweepSpring, [0, 1], [0, 100]))}%`,
                            background: `linear-gradient(90deg, rgba(${colorR},${colorG},${colorB},0.5), rgb(${colorR},${colorG},${colorB}))`,
                            borderRadius: 8,
                        }} />
                    </div>
                </div>

                {/* Section label */}
                <div style={{
                    fontSize: 11, color: '#475569', fontWeight: 700,
                    letterSpacing: '0.1em', textTransform: 'uppercase',
                    marginBottom: 16,
                }}>
                    ✂ Ajuste de Rota
                </div>

                {/* Expense rows */}
                <div style={{ marginBottom: 24 }}>
                    {expenses.map((exp, i) => (
                        <ExpenseRow
                            key={i}
                            name={exp.name}
                            amount={exp.amount}
                            cut={exp.cut}
                            cutProgress={cuts[i] as number}
                            rowProgress={rowProgress[i]}
                        />
                    ))}
                </div>

                {/* Savings summary */}
                <div style={{
                    display: 'flex', gap: 12, marginBottom: 24,
                    opacity: interpolate(cut1, [0.5, 1], [0, 1], { extrapolateRight: 'clamp' }),
                }}>
                    <div style={{
                        flex: 1, padding: '14px 16px',
                        background: 'rgba(20,184,166,0.06)',
                        borderRadius: 16, border: '1px solid rgba(20,184,166,0.15)',
                    }}>
                        <div style={{ fontSize: 11, color: '#14B8A6', fontWeight: 700, marginBottom: 4 }}>ECONOMIZADO</div>
                        <div style={{ fontSize: 20, fontWeight: 800, color: '#14B8A6', letterSpacing: '-0.03em' }}>
                            +R$ 186,90
                        </div>
                    </div>
                    <div style={{
                        flex: 1, padding: '14px 16px',
                        background: 'rgba(255,255,255,0.04)',
                        borderRadius: 16, border: '1px solid rgba(255,255,255,0.08)',
                    }}>
                        <div style={{ fontSize: 11, color: '#64748B', fontWeight: 700, marginBottom: 4 }}>PENDENTE</div>
                        <div style={{ fontSize: 20, fontWeight: 800, color: '#94A3B8', letterSpacing: '-0.03em' }}>
                            R$ 2.400,00
                        </div>
                    </div>
                </div>

                {/* Peace badge */}
                {peaceOp > 0.01 && (
                    <div style={{
                        padding: '18px 24px',
                        background: bgColor,
                        borderRadius: 20, border: `1px solid ${borderColor}`,
                        display: 'flex', alignItems: 'center', gap: 16,
                        transform: `scale(${peaceScale})`, opacity: peaceOp,
                    }}>
                        <div style={{
                            width: 48, height: 48, borderRadius: 16,
                            background: balColor,
                            display: 'flex', alignItems: 'center', justifyContent: 'center',
                            boxShadow: `0 8px 24px rgba(${colorR},${colorG},${colorB},0.4)`,
                            flexShrink: 0,
                        }}>
                            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2.5">
                                <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" strokeLinecap="round" strokeLinejoin="round" />
                            </svg>
                        </div>
                        <div>
                            <div style={{ fontSize: 16, fontWeight: 800, color: 'white', marginBottom: 2 }}>
                                Mês de volta ao azul 💙
                            </div>
                            <div style={{ fontSize: 13, color: '#64748B' }}>
                                Dois cortes simples. Resultado: <span style={{ color: balColor, fontWeight: 700 }}>+R$ 2.400 de sobra</span>.
                            </div>
                        </div>
                    </div>
                )}
            </div>
        </AbsoluteFill>
    );
};
