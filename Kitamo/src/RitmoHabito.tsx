import React from 'react';
import { AbsoluteFill, interpolate, spring, useCurrentFrame, useVideoConfig } from 'remotion';

// ─── VIDEO 02: O HÁBITO ──────────────────────────────────────────────
// Shows a quick transaction being typed and saved in seconds.
// Theme: speed, simplicity, 5-second habit.




function PhoneShell({ children }: { children: React.ReactNode }) {
    return (
        <div style={{
            width: 340,
            minHeight: 580,
            background: '#0F172A',
            borderRadius: 44,
            overflow: 'hidden',
            boxShadow: '0 40px 100px rgba(0,0,0,0.5), inset 0 0 0 1px rgba(255,255,255,0.08)',
            position: 'relative',
            display: 'flex',
            flexDirection: 'column',
        }}>
            {/* Notch */}
            <div style={{
                position: 'absolute', top: 12, left: '50%', transform: 'translateX(-50%)',
                width: 100, height: 26, background: '#0F172A', borderRadius: 20, zIndex: 10,
                boxShadow: 'inset 0 0 0 1px rgba(255,255,255,0.06)',
            }} />

            {/* Status bar */}
            <div style={{
                padding: '16px 24px 0 24px',
                display: 'flex', justifyContent: 'space-between', alignItems: 'center',
                color: 'rgba(255,255,255,0.5)', fontSize: 11, marginTop: 8,
            }}>
                <span style={{ fontWeight: 600 }}>9:41</span>
                <div style={{ display: 'flex', gap: 4, alignItems: 'center' }}>
                    <div style={{ width: 14, height: 8, border: '1.5px solid rgba(255,255,255,0.4)', borderRadius: 2, position: 'relative' }}>
                        <div style={{ position: 'absolute', top: 1, left: 1, width: 7, height: 4, background: '#14B8A6', borderRadius: 1 }} />
                    </div>
                </div>
            </div>

            {/* App content */}
            <div style={{ flex: 1, overflowY: 'hidden', position: 'relative' }}>
                {children}
            </div>
        </div>
    );
}

export const RitmoHabito: React.FC = () => {
    const frame = useCurrentFrame();
    const { fps } = useVideoConfig();

    // ─── PHASE 1: App loads (0-15) ───
    const appFade = interpolate(frame, [0, 12], [0, 1], { extrapolateRight: 'clamp' });

    // ─── PHASE 2: FAB button pulse then tap (15-30) ───
    const fabPulse = interpolate(frame, [15, 22], [1, 0.92], { extrapolateRight: 'clamp' });
    const fabTapSpring = spring({ frame: frame - 26, fps, config: { damping: 12, stiffness: 300 } });
    const fabScale = fabPulse * (1 - fabTapSpring * 0.1);

    // ─── PHASE 3: Quick-add modal slides up (28-38) ───
    const modalSpring = spring({ frame: frame - 28, fps, config: { damping: 18, stiffness: 180 } });
    const modalY = interpolate(modalSpring, [0, 1], [300, 0]);
    const backdropOp = interpolate(modalSpring, [0, 1], [0, 0.7]);

    // ─── PHASE 4: Typing animation (38-75) ───
    const descLength = interpolate(frame, [38, 60], [0, 19], { extrapolateRight: 'clamp' });
    const fullDesc = "Pizza com a galera";
    const descText = fullDesc.substring(0, Math.round(descLength));

    const valLength = interpolate(frame, [62, 74], [0, 9], { extrapolateRight: 'clamp' });
    const fullVal = "-R$ 89,00";
    const valText = fullVal.substring(0, Math.round(valLength));

    // ─── PHASE 5: Save button tap (78-82) ───
    const saveTap = spring({ frame: frame - 78, fps, config: { damping: 14, stiffness: 300 } });
    const btnScale = 1 - saveTap * 0.08 + spring({ frame: frame - 82, fps, config: { damping: 14, stiffness: 300 } }) * 0.08;

    // ─── PHASE 6: Modal exits (82-92), toast enters ───
    const modalExit = spring({ frame: frame - 82, fps, config: { damping: 18, stiffness: 180 } });
    const modalYFinal = interpolate(modalSpring, [0, 1], [300, 0]) + interpolate(modalExit, [0, 1], [0, 300]);
    const backdropFinal = (interpolate(modalSpring, [0, 1], [0, 0.7])) - interpolate(modalExit, [0, 1], [0, 0.7]);

    // ─── PHASE 7: Transaction row appears in list (88-100) ───
    const newTxSpring = spring({ frame: frame - 88, fps, config: { damping: 18, stiffness: 140 } });
    const txOpacity = interpolate(newTxSpring, [0, 1], [0, 1]);
    const txHeight = interpolate(newTxSpring, [0, 1], [0, 60]);
    const txY = interpolate(newTxSpring, [0, 1], [-16, 0]);

    // ─── PHASE 8: Toast notification (90-115) ───
    const toastSpring = spring({ frame: frame - 90, fps, config: { damping: 14, stiffness: 180 } });
    const toastExit = spring({ frame: frame - 118, fps, config: { damping: 14, stiffness: 180 } });
    const toastY = interpolate(toastSpring, [0, 1], [-80, 0]) + interpolate(toastExit, [0, 1], [0, -80]);
    const toastOpacity = interpolate(toastSpring, [0, 0.1], [0, 1]) - interpolate(toastExit, [0, 1], [0, 1]);

    // ─── Timer countdown (5 seconds visual) ───
    const timerProg = interpolate(frame, [38, 83], [0, 1], { extrapolateRight: 'clamp' });
    const timerOpacity = interpolate(frame, [35, 42], [0, 1], { extrapolateRight: 'clamp' }) *
        (1 - interpolate(frame, [86, 94], [0, 1], { extrapolateRight: 'clamp' }));

    const useModalY = frame < 82 ? modalY : modalYFinal;
    const useBackdrop = frame < 82 ? backdropOp : backdropFinal;

    // Existing transactions (before new one)
    const existingTxs = [
        { name: 'Pix Recebido', cat: 'Receita', val: '+R$ 2.100,00', color: '#14B8A6', date: 'Hoje' },
        { name: 'Supermercado', cat: 'Alimentação', val: '-R$ 243,80', color: '#EF4444', date: 'Ontem' },
        { name: 'Uber', cat: 'Transporte', val: '-R$ 18,90', color: '#F97316', date: 'Ontem' },
    ];

    return (
        <AbsoluteFill style={{
            background: 'linear-gradient(145deg, #0F172A 0%, #1E293B 100%)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontFamily: 'Inter, system-ui, sans-serif',
        }}>
            <div style={{ position: 'relative' }}>
                <PhoneShell>
                    {/* App header */}
                    <div style={{
                        padding: '12px 20px',
                        opacity: appFade,
                    }}>
                        <div style={{ fontSize: 11, color: '#64748B', fontWeight: 600, marginBottom: 4 }}>
                            FEVEREIRO 2025
                        </div>
                        <div style={{
                            fontSize: 28, fontWeight: 800, color: 'white', letterSpacing: '-0.04em',
                        }}>
                            R$ 3.842
                            <span style={{ fontSize: 16, color: '#64748B' }}>,00</span>
                        </div>
                        <div style={{ fontSize: 12, color: '#94A3B8', marginTop: 2 }}>saldo atual</div>
                    </div>

                    {/* Transaction list */}
                    <div style={{ padding: '8px 20px', opacity: appFade }}>
                        <div style={{ fontSize: 11, color: '#475569', fontWeight: 700, marginBottom: 10, textTransform: 'uppercase', letterSpacing: '0.1em' }}>
                            LANÇAMENTOS
                        </div>

                        {/* NEW transaction appears here */}
                        {txOpacity > 0 && (
                            <div style={{
                                display: 'flex', alignItems: 'center', gap: 12,
                                padding: '0 0 0 0',
                                overflow: 'hidden',
                                height: txHeight,
                                opacity: txOpacity,
                                transform: `translateY(${txY}px)`,
                                marginBottom: txHeight > 0 ? 8 : 0,
                            }}>
                                <div style={{
                                    display: 'flex', alignItems: 'center', gap: 12,
                                    padding: '10px 14px',
                                    background: 'rgba(239,68,68,0.08)',
                                    borderRadius: 14,
                                    flex: 1,
                                    border: '1px solid rgba(239,68,68,0.2)',
                                }}>
                                    <div style={{
                                        width: 32, height: 32, borderRadius: 10,
                                        background: 'rgba(239,68,68,0.15)',
                                        display: 'flex', alignItems: 'center', justifyContent: 'center',
                                    }}>
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#EF4444" strokeWidth="2.5">
                                            <path d="M3 11l19-9-9 19-2-8-8-2z" strokeLinecap="round" strokeLinejoin="round" />
                                        </svg>
                                    </div>
                                    <div style={{ flex: 1 }}>
                                        <div style={{ fontSize: 13, fontWeight: 700, color: 'white' }}>Pizza com a galera</div>
                                        <div style={{ fontSize: 11, color: '#64748B' }}>Lazer · Agora</div>
                                    </div>
                                    <div style={{ fontSize: 14, fontWeight: 800, color: '#EF4444' }}>-R$ 89,00</div>
                                </div>
                            </div>
                        )}

                        {existingTxs.map((tx, i) => (
                            <div key={i} style={{
                                display: 'flex', alignItems: 'center', gap: 12,
                                padding: '10px 14px',
                                background: 'rgba(255,255,255,0.04)',
                                borderRadius: 14, marginBottom: 8,
                                border: '1px solid rgba(255,255,255,0.06)',
                            }}>
                                <div style={{
                                    width: 32, height: 32, borderRadius: 10,
                                    background: `${tx.color}18`,
                                    flexShrink: 0,
                                }} />
                                <div style={{ flex: 1 }}>
                                    <div style={{ fontSize: 13, fontWeight: 600, color: '#E2E8F0' }}>{tx.name}</div>
                                    <div style={{ fontSize: 11, color: '#475569' }}>{tx.cat} · {tx.date}</div>
                                </div>
                                <div style={{
                                    fontSize: 13, fontWeight: 700,
                                    color: tx.val.startsWith('+') ? '#14B8A6' : '#EF4444',
                                }}>{tx.val}</div>
                            </div>
                        ))}
                    </div>

                    {/* FAB Button */}
                    <div style={{
                        position: 'absolute', bottom: 28, right: 24,
                        width: 56, height: 56, borderRadius: '50%',
                        background: 'linear-gradient(135deg, #14B8A6, #06B6D4)',
                        display: 'flex', alignItems: 'center', justifyContent: 'center',
                        boxShadow: '0 8px 24px rgba(20,184,166,0.4)',
                        transform: `scale(${fabScale})`,
                        opacity: appFade,
                    }}>
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2.5">
                            <path d="M12 5v14M5 12h14" strokeLinecap="round" />
                        </svg>
                    </div>

                    {/* Backdrop */}
                    {useBackdrop > 0.01 && (
                        <div style={{
                            position: 'absolute', inset: 0,
                            background: `rgba(0,0,0,${useBackdrop})`,
                            backdropFilter: 'blur(4px)',
                        }} />
                    )}

                    {/* Quick-add modal */}
                    {useModalY < 290 && (
                        <div style={{
                            position: 'absolute', bottom: 0, left: 0, right: 0,
                            background: '#1E293B',
                            borderRadius: '28px 28px 0 0',
                            padding: '28px 24px 40px',
                            transform: `translateY(${useModalY}px)`,
                            boxShadow: '0 -20px 60px rgba(0,0,0,0.4)',
                            border: '1px solid rgba(255,255,255,0.08)',
                            borderBottom: 'none',
                        }}>
                            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 24 }}>
                                <span style={{ fontSize: 16, fontWeight: 800, color: 'white' }}>Lançar rápido</span>
                                <div style={{
                                    fontSize: 11, fontWeight: 700, color: '#14B8A6',
                                    background: 'rgba(20,184,166,0.1)', padding: '4px 10px', borderRadius: 8,
                                }}>5 seg ⚡</div>
                            </div>

                            {/* Description field */}
                            <div style={{
                                background: 'rgba(255,255,255,0.06)',
                                border: descText.length > 0 ? '1.5px solid #14B8A6' : '1.5px solid rgba(255,255,255,0.1)',
                                borderRadius: 14, padding: '12px 16px', marginBottom: 12,
                                transition: 'border-color 0.2s',
                            }}>
                                <div style={{ fontSize: 11, color: '#64748B', marginBottom: 4 }}>Descrição</div>
                                <div style={{ fontSize: 15, fontWeight: 600, color: 'white', minHeight: 22 }}>
                                    {descText}
                                    {frame >= 38 && frame <= 62 && (
                                        <span style={{
                                            display: 'inline-block', width: 2, height: 16,
                                            background: '#14B8A6', marginLeft: 2,
                                            opacity: Math.sin(frame * 0.4) > 0 ? 1 : 0,
                                            verticalAlign: 'middle',
                                        }} />
                                    )}
                                </div>
                            </div>

                            {/* Value field */}
                            <div style={{
                                background: 'rgba(255,255,255,0.06)',
                                border: valText.length > 0 ? '1.5px solid #EF4444' : '1.5px solid rgba(255,255,255,0.1)',
                                borderRadius: 14, padding: '12px 16px', marginBottom: 20,
                            }}>
                                <div style={{ fontSize: 11, color: '#64748B', marginBottom: 4 }}>Valor</div>
                                <div style={{
                                    fontSize: 22, fontWeight: 800,
                                    color: valText.startsWith('-') ? '#EF4444' : 'white',
                                    letterSpacing: '-0.03em', minHeight: 28,
                                }}>
                                    {valText}
                                    {frame >= 62 && frame <= 78 && (
                                        <span style={{
                                            display: 'inline-block', width: 2, height: 20,
                                            background: '#EF4444', marginLeft: 2,
                                            opacity: Math.sin(frame * 0.4) > 0 ? 1 : 0,
                                            verticalAlign: 'middle',
                                        }} />
                                    )}
                                </div>
                            </div>

                            {/* Save button */}
                            <div style={{
                                width: '100%',
                                height: 52, borderRadius: 18,
                                background: 'linear-gradient(135deg, #14B8A6, #06B6D4)',
                                display: 'flex', alignItems: 'center', justifyContent: 'center',
                                boxShadow: '0 8px 24px rgba(20, 184, 166, 0.35)',
                                transform: `scale(${btnScale})`,
                                fontWeight: 800, fontSize: 14, color: '#0F172A',
                                letterSpacing: '0.04em',
                            }}>
                                LANÇAR AGORA
                            </div>
                        </div>
                    )}
                </PhoneShell>

                {/* Timer pill — outside phone */}
                {timerOpacity > 0.01 && (
                    <div style={{
                        position: 'absolute', top: -20, left: '50%', transform: 'translateX(-50%)',
                        background: 'rgba(20,184,166,0.1)', border: '1px solid rgba(20,184,166,0.3)',
                        borderRadius: 99, padding: '6px 16px',
                        display: 'flex', alignItems: 'center', gap: 10,
                        opacity: timerOpacity,
                    }}>
                        <div style={{ width: 6, height: 6, borderRadius: '50%', background: '#14B8A6' }} />
                        <div style={{ fontSize: 11, fontWeight: 700, color: '#14B8A6', letterSpacing: '0.1em', whiteSpace: 'nowrap' }}>
                            {Math.ceil(5 - timerProg * 5)}s para lançar
                        </div>
                        {/* Progress track */}
                        <div style={{ width: 60, height: 3, background: 'rgba(20,184,166,0.2)', borderRadius: 2, overflow: 'hidden' }}>
                            <div style={{
                                height: '100%', background: '#14B8A6', borderRadius: 2,
                                width: `${timerProg * 100}%`,
                            }} />
                        </div>
                    </div>
                )}

                {/* Toast notification */}
                {toastOpacity > 0.01 && (
                    <div style={{
                        position: 'absolute', bottom: -24, left: '50%', transform: `translateX(-50%) translateY(${toastY}px)`,
                        background: '#1E293B', border: '1px solid rgba(20,184,166,0.3)',
                        borderRadius: 18, padding: '12px 20px',
                        display: 'flex', alignItems: 'center', gap: 12,
                        opacity: toastOpacity,
                        whiteSpace: 'nowrap',
                        boxShadow: '0 8px 32px rgba(0,0,0,0.4)',
                    }}>
                        <div style={{
                            width: 28, height: 28, borderRadius: '50%', background: '#14B8A6',
                            display: 'flex', alignItems: 'center', justifyContent: 'center',
                        }}>
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="3">
                                <path d="M5 13l4 4L19 7" strokeLinecap="round" strokeLinejoin="round" />
                            </svg>
                        </div>
                        <div>
                            <div style={{ fontSize: 12, fontWeight: 700, color: 'white' }}>Lançado em 5 segundos!</div>
                            <div style={{ fontSize: 10, color: '#64748B' }}>Pizza com a galera · -R$ 89,00</div>
                        </div>
                    </div>
                )}
            </div>
        </AbsoluteFill>
    );
};
