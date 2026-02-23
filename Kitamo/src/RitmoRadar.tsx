import React from 'react';
import { AbsoluteFill, interpolate, spring, useCurrentFrame, useVideoConfig } from 'remotion';

// ─── VIDEO 03: O RADAR ────────────────────────────────────────────────
// Shows the balance forecast turning RED when a bill can't be covered.
// Theme: early warning, prevention, financial awareness.

function BalanceBar({
    label, dateLabel, amount, barH, isAlert, alertProgress, index
}: {
    label: string; dateLabel: string; amount: number; barH: number;
    isAlert: boolean; alertProgress: number; index: number;
}) {
    const barColor = isAlert
        ? `rgb(${Math.round(interpolate(alertProgress, [0, 1], [20, 239]))}, ${Math.round(interpolate(alertProgress, [0, 1], [184, 68]))}, ${Math.round(interpolate(alertProgress, [0, 1], [166, 68]))})`
        : '#14B8A6';


    return (
        <div style={{
            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6,
            flex: 1,
        }}>
            {/* Amount label */}
            <div style={{
                fontSize: 12, fontWeight: 800,
                color: isAlert ? `rgba(239,68,68,${alertProgress})` : '#14B8A6',
                letterSpacing: '-0.02em',
                opacity: barH > 10 ? 1 : 0,
            }}>
                R$ {amount >= 0 ? amount.toLocaleString('pt-BR') : `(${Math.abs(amount).toLocaleString('pt-BR')})`}
            </div>
            {/* Bar */}
            <div style={{
                width: '100%',
                height: 180,
                display: 'flex', alignItems: 'flex-end',
                borderRadius: 6,
                position: 'relative',
            }}>
                <div style={{
                    width: '100%', height: Math.max(barH, 0),
                    background: barColor,
                    borderRadius: '8px 8px 4px 4px',
                    boxShadow: isAlert && alertProgress > 0.5 ? `0 0 20px rgba(239,68,68,${alertProgress * 0.5})` : 'none',
                    transition: 'none',
                }} />
                {/* Zero line pulse for negative bars */}
                {barH <= 0 && isAlert && alertProgress > 0.3 && (
                    <div style={{
                        position: 'absolute', bottom: 0, left: -4, right: -4,
                        height: 2,
                        background: 'rgba(239,68,68,0.8)',
                        borderRadius: 2,
                    }} />
                )}
            </div>
            {/* Label */}
            <div style={{ fontSize: 11, color: '#64748B', fontWeight: 600, textAlign: 'center' }}>
                {label}
            </div>
            <div style={{ fontSize: 10, color: '#475569', textAlign: 'center' }}>
                {dateLabel}
            </div>
        </div>
    );
}

export const RitmoRadar: React.FC = () => {
    const frame = useCurrentFrame();
    const { fps } = useVideoConfig();

    // ─── Phase 1: Dashboard fades in (0-18) ───
    const dashFade = interpolate(frame, [0, 18], [0, 1], { extrapolateRight: 'clamp' });

    // ─── Phase 2: Bars grow up (10-50) ───
    const bar1Spring = spring({ frame: frame - 10, fps, config: { damping: 20, stiffness: 120 } });
    const bar2Spring = spring({ frame: frame - 20, fps, config: { damping: 20, stiffness: 120 } });
    const bar3Spring = spring({ frame: frame - 30, fps, config: { damping: 20, stiffness: 120 } });
    const bar4Spring = spring({ frame: frame - 40, fps, config: { damping: 20, stiffness: 120 } });

    // Bar 4 is alert bar (drops to negative)
    // ─── Phase 3: Alert animation (55-80) ───
    const alertSpring = spring({ frame: frame - 55, fps, config: { damping: 14, stiffness: 100 } });
    const alertShake = frame >= 58 && frame <= 70
        ? Math.sin((frame - 58) * 1.8) * interpolate(frame, [58, 70], [6, 0], { extrapolateRight: 'clamp' })
        : 0;

    // Alert badge slides in
    const alertBadgeSpring = spring({ frame: frame - 60, fps, config: { damping: 16, stiffness: 180 } });
    const alertBadgeY = interpolate(alertBadgeSpring, [0, 1], [-40, 0]);
    const alertBadgeOp = interpolate(alertBadgeSpring, [0, 0.1], [0, 1], { extrapolateRight: 'clamp' });

    // ─── Phase 4: Bill card drops in (75-90) ───
    const billSpring = spring({ frame: frame - 75, fps, config: { damping: 16, stiffness: 160 } });
    const billY = interpolate(billSpring, [0, 1], [30, 0]);
    const billOp = interpolate(billSpring, [0, 0.1], [0, 1], { extrapolateRight: 'clamp' });

    // ─── Phase 5: "Antecipe!" CTA pulses (95-120) ───
    const ctaSpring = spring({ frame: frame - 95, fps, config: { damping: 16, stiffness: 180 } });
    const ctaOp = interpolate(ctaSpring, [0, 0.1], [0, 1], { extrapolateRight: 'clamp' });
    const ctaScale = interpolate(ctaSpring, [0, 1], [0.8, 1]);

    // Bar values (with alarm driving bar 4 down)
    const b1H = interpolate(bar1Spring, [0, 1], [0, 130]);
    const b2H = interpolate(bar2Spring, [0, 1], [0, 180]);
    const b3H = interpolate(bar3Spring, [0, 1], [0, 100]);
    const b4RawH = interpolate(bar4Spring, [0, 1], [0, 20]); // starts small
    const b4AlertDrop = interpolate(alertSpring, [0, 1], [0, 20]);
    const b4H = b4RawH - b4AlertDrop; // goes negative = zero height + alert glow

    const b1Amt = Math.round(interpolate(bar1Spring, [0, 1], [0, 4200]));
    const b2Amt = Math.round(interpolate(bar2Spring, [0, 1], [0, 5800]));
    const b3Amt = Math.round(interpolate(bar3Spring, [0, 1], [0, 3100]));
    const b4Amt = Math.round(interpolate(bar4Spring, [0, 1], [0, 600]) - interpolate(alertSpring, [0, 1], [0, 2400]));

    return (
        <AbsoluteFill style={{
            background: '#0F172A',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontFamily: 'Inter, system-ui, sans-serif',
        }}>
            <div style={{
                width: 720,
                background: '#1E293B',
                borderRadius: 32,
                padding: 40,
                boxShadow: '0 40px 120px rgba(0,0,0,0.5)',
                border: '1px solid rgba(255,255,255,0.06)',
                opacity: dashFade,
                transform: `translateX(${alertShake}px)`,
            }}>
                {/* Header */}
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 32 }}>
                    <div>
                        <div style={{ fontSize: 11, color: '#475569', fontWeight: 700, letterSpacing: '0.12em', textTransform: 'uppercase', marginBottom: 4 }}>
                            03 — O RADAR
                        </div>
                        <div style={{ fontSize: 24, fontWeight: 800, color: 'white', letterSpacing: '-0.04em' }}>
                            Projeção de Saldo
                        </div>
                        <div style={{ fontSize: 13, color: '#475569', marginTop: 2 }}>próximos 30 dias</div>
                    </div>

                    {/* Alert badge */}
                    {alertBadgeOp > 0.01 && (
                        <div style={{
                            background: 'rgba(239,68,68,0.1)', border: '1px solid rgba(239,68,68,0.3)',
                            borderRadius: 14, padding: '8px 16px',
                            transform: `translateY(${alertBadgeY}px)`, opacity: alertBadgeOp,
                        }}>
                            <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                                <div style={{
                                    width: 8, height: 8, borderRadius: '50%', background: '#EF4444',
                                    boxShadow: '0 0 8px rgba(239,68,68,0.8)',
                                }} />
                                <span style={{ fontSize: 12, fontWeight: 800, color: '#EF4444' }}>
                                    ALERTA VERMELHO
                                </span>
                            </div>
                        </div>
                    )}
                </div>

                {/* Chart area */}
                <div style={{
                    display: 'flex', gap: 12, alignItems: 'flex-end',
                    height: 240, marginBottom: 24,
                    padding: '0 8px',
                    position: 'relative',
                }}>
                    {/* Zero line */}
                    <div style={{
                        position: 'absolute', bottom: 56, left: 0, right: 0,
                        height: 1, background: 'rgba(255,255,255,0.05)',
                    }} />

                    <BarWithAlert label="Hoje" dateLabel="22/02" amount={b1Amt} barH={b1H} isAlert={false} alertProgress={0} index={0} />
                    <BarWithAlert label="Semana 2" dateLabel="01/03" amount={b2Amt} barH={b2H} isAlert={false} alertProgress={0} index={1} />
                    <BarWithAlert label="Semana 3" dateLabel="08/03" amount={b3Amt} barH={b3H} isAlert={false} alertProgress={0} index={2} />
                    <BarWithAlert label="Semana 4" dateLabel="15/03 ⚠" amount={b4Amt} barH={Math.max(b4H, 0)} isAlert={true} alertProgress={alertSpring} index={3} />
                </div>

                {/* Overdue bill card */}
                {billOp > 0.01 && (
                    <div style={{
                        background: 'rgba(239,68,68,0.06)',
                        border: '1px solid rgba(239,68,68,0.25)',
                        borderRadius: 18, padding: '16px 20px',
                        display: 'flex', alignItems: 'center', gap: 16,
                        transform: `translateY(${billY}px)`, opacity: billOp,
                        marginBottom: 20,
                    }}>
                        <div style={{
                            width: 44, height: 44, borderRadius: 14,
                            background: 'rgba(239,68,68,0.12)',
                            display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
                        }}>
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#EF4444" strokeWidth="2">
                                <path d="M12 9v4m0 4h.01M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z" strokeLinecap="round" strokeLinejoin="round" />
                            </svg>
                        </div>
                        <div style={{ flex: 1 }}>
                            <div style={{ fontSize: 13, fontWeight: 700, color: '#FCA5A5', marginBottom: 2 }}>
                                Fatura do Cartão vence em 5 dias
                            </div>
                            <div style={{ fontSize: 12, color: '#64748B' }}>
                                Saldo insuficiente na semana 4 · faltam <span style={{ color: '#EF4444', fontWeight: 700 }}>R$ 1.800,00</span>
                            </div>
                        </div>
                        <div style={{
                            fontSize: 18, fontWeight: 800, color: '#EF4444',
                            letterSpacing: '-0.03em', flexShrink: 0,
                        }}>-R$ 1.800</div>
                    </div>
                )}

                {/* CTA */}
                {ctaOp > 0.01 && (
                    <div style={{
                        display: 'flex', gap: 12,
                        opacity: ctaOp, transform: `scale(${ctaScale})`,
                    }}>
                        <div style={{
                            flex: 1, height: 48, borderRadius: 16,
                            background: 'linear-gradient(135deg, #EF4444, #DC2626)',
                            display: 'flex', alignItems: 'center', justifyContent: 'center',
                            fontWeight: 800, fontSize: 13, color: 'white', letterSpacing: '0.04em',
                            boxShadow: '0 8px 24px rgba(239,68,68,0.35)',
                        }}>
                            ANTECIPAR GRANA
                        </div>
                        <div style={{
                            flex: 1, height: 48, borderRadius: 16,
                            background: 'rgba(255,255,255,0.06)',
                            border: '1px solid rgba(255,255,255,0.1)',
                            display: 'flex', alignItems: 'center', justifyContent: 'center',
                            fontWeight: 700, fontSize: 13, color: '#94A3B8',
                        }}>
                            Ver detalhes
                        </div>
                    </div>
                )}
            </div>
        </AbsoluteFill>
    );
};

// Alias needed for JSX
function BarWithAlert(props: Parameters<typeof BalanceBar>[0]) {
    return <BalanceBar {...props} />;
}
