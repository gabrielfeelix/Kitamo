import React from 'react';
import { AbsoluteFill, interpolate, spring, useCurrentFrame, useVideoConfig } from 'remotion';

export const Teste: React.FC = () => {
    const frame = useCurrentFrame();
    const { fps } = useVideoConfig();

    // Fundo com glow suave que acompanha a timeline
    const bgGlowOpacity = interpolate(frame, [150, 240], [0.1, 0.4], { extrapolateRight: 'clamp' });

    // Mockup Celular Float (Flutuando suavemente)
    const floatY = Math.sin(frame / 30) * 10;

    // -- Frame 1: Alerta da Fatura (0 - 60)
    const alertSpring = spring({ frame: frame - 30, fps, config: { damping: 12, stiffness: 150 } });
    const alertY = interpolate(alertSpring, [0, 1], [100, 0]);
    const alertOpacity = interpolate(alertSpring, [0, 1], [0, 1]);
    const alertExit = spring({ frame: frame - 80, fps, config: { damping: 15, stiffness: 200 } });
    const alertCurrentY = alertY + interpolate(alertExit, [0, 1], [0, 50]);
    const alertCurrentOpacity = alertOpacity - alertExit;

    // -- Frame 2: Modal Rápido KITAMO ORIGINAL (60 - 150)
    const cursorX = interpolate(frame, [50, 70], [200, 170], { extrapolateRight: 'clamp' });
    const cursorY = interpolate(frame, [50, 70], [600, 520], { extrapolateRight: 'clamp' });
    const clickFab = spring({ frame: frame - 70, fps, config: { damping: 10, stiffness: 300 } });

    // FAB scale press
    const fabScale = 1 - clickFab * 0.15 + spring({ frame: frame - 75, fps, config: { damping: 10, stiffness: 300 } }) * 0.15;

    // Modal aparece
    const modalSpring = spring({ frame: frame - 80, fps, config: { damping: 14, stiffness: 200 } });
    const modalScale = interpolate(modalSpring, [0, 1], [0.95, 1]);
    const modalOpacity = modalSpring;
    const modalExit = spring({ frame: frame - 145, fps, config: { damping: 15, stiffness: 250 } });
    const currentModalScale = modalScale - interpolate(modalExit, [0, 1], [0, 0.05]);
    const currentModalOpacity = modalOpacity - modalExit;

    // Digitação rápida
    const typingProgress = interpolate(frame, [90, 110], [0, 16], { extrapolateRight: 'clamp' });
    const titleText = "Pagamento Fatura".substring(0, Math.floor(typingProgress));
    const focusAmount = spring({ frame: frame - 110, fps, config: { damping: 15, stiffness: 200 } });
    const valAmount = Math.floor(interpolate(focusAmount, [0, 1], [0, 850]));

    // Confirm click
    const cursorX2 = interpolate(frame, [130, 140], [200, 180], { extrapolateRight: 'clamp' });
    const cursorY2 = interpolate(frame, [130, 140], [450, 620], { extrapolateRight: 'clamp' });
    const clickConfirm = spring({ frame: frame - 140, fps, config: { damping: 10, stiffness: 300 } });
    const btnConfirmScale = 1 - clickConfirm * 0.05 + spring({ frame: frame - 145, fps, config: { damping: 10, stiffness: 300 } }) * 0.05;

    // -- Frame 3: Transformação e Linha do Tempo (150 - 240)
    const timelineIntro = spring({ frame: frame - 150, fps, config: { damping: 12, stiffness: 150 } });
    const lineDraw = spring({ frame: frame - 170, fps, durationInFrames: 60, config: { damping: 15, stiffness: 120 } });
    const dayNumber = Math.floor(interpolate(lineDraw, [0, 1], [15, 30]));
    const balanceVal = Math.floor(interpolate(lineDraw, [0, 1], [1200, 150]));

    // Esconde saldo inicial
    const initBalanceExit = spring({ frame: frame - 150, fps, config: { damping: 14, stiffness: 180 } });

    // -- Frame 4: Paz final (240+)
    const finalPulse = Math.sin((frame - 240) / 5) * 0.05 * (frame > 240 ? 1 : 0);
    const successGlow = spring({ frame: frame - 230, fps, config: { damping: 20, stiffness: 100 } });

    return (
        <AbsoluteFill className="bg-slate-900 flex items-center justify-center font-sans overflow-hidden">
            {/* Background ambiente */}
            <div
                className="absolute w-[800px] h-[800px] rounded-full blur-[150px]"
                style={{
                    background: `rgba(20, 184, 166, ${bgGlowOpacity})`,
                    transform: `scale(${1 + finalPulse * 2})`
                }}
            ></div>

            {/* Mockup do Celular - Fundo Light real do sistema */}
            <div
                className="relative w-[360px] h-[720px] bg-slate-50 rounded-[40px] border-[10px] border-slate-900 shadow-[0_30px_60px_-15px_rgba(0,0,0,0.8)] overflow-hidden flex flex-col"
                style={{ transform: `translateY(${floatY}px)` }}
            >
                {/* Notch iPhone */}
                <div className="absolute top-0 left-1/2 -translate-x-1/2 w-32 h-7 bg-slate-900 rounded-b-[20px] z-50"></div>

                {/* --- CONTEÚDO DA TELA DA HOME --- */}
                <div className="p-6 pt-16 flex-1 relative z-10 flex flex-col">

                    {/* Header Saldo Original (Home) */}
                    <div style={{ opacity: 1 - initBalanceExit, transform: `translateY(${-initBalanceExit * 20}px)` }}>
                        <p className="text-slate-500 font-semibold text-xs mb-1 tracking-wider uppercase">Saldo Atual</p>
                        <h1 className="text-slate-900 text-[40px] font-extrabold tracking-tight">R$ 1.200,00</h1>
                    </div>

                    {/* Timeline View (Dashboard Widget) */}
                    {frame >= 150 && (
                        <div
                            className="absolute inset-x-6 top-16 flex flex-col pt-4"
                            style={{ opacity: timelineIntro, transform: `translateY(${(1 - timelineIntro) * 20}px)` }}
                        >
                            <div className="flex justify-between items-end mb-6">
                                <div>
                                    <p className="text-emerald-600 font-bold text-[10px] mb-1 uppercase tracking-wider">
                                        Sobra no dia {dayNumber}
                                    </p>
                                    <h1
                                        className="text-slate-900 text-4xl font-extrabold tracking-tight transition-all duration-300"
                                        style={{
                                            transform: frame > 230 ? `scale(${1 + finalPulse})` : 'scale(1)',
                                            color: frame > 230 ? '#14b8a6' : '#0f172a',
                                        }}
                                    >
                                        R$ {balanceVal},00
                                    </h1>
                                </div>
                            </div>

                            {/* Gráfico de Linha KITAMO (Projeção) */}
                            <div className="relative h-48 w-full mt-2 rounded-[24px] bg-white ring-1 ring-slate-200/60 p-4 shadow-sm">
                                <div className="absolute top-[80%] w-full left-0 border-t border-slate-200 border-dashed"></div>
                                <div className="absolute top-[75%] left-4 text-slate-400 font-semibold text-[10px]">R$ 0</div>

                                <svg className="w-full h-full absolute inset-0 overflow-visible px-4">
                                    <path
                                        d="M 10 20 Q 80 20 120 70 T 250 110"
                                        fill="none"
                                        stroke="#14b8a6"
                                        strokeWidth="4"
                                        strokeLinecap="round"
                                        strokeDasharray="300"
                                        strokeDashoffset={300 - (lineDraw * 300)}
                                    />
                                    {lineDraw > 0 && (
                                        <circle
                                            cx={10 + (lineDraw * 240)}
                                            cy={20 + (lineDraw * 90)}
                                            r="5"
                                            fill="#fff"
                                            stroke="#14b8a6"
                                            strokeWidth="3"
                                            className="origin-center shadow-lg"
                                        />
                                    )}
                                </svg>

                                {frame > 170 && frame < 230 && (
                                    <div
                                        className="absolute bg-white px-2 py-1 rounded-lg text-red-500 text-xs font-bold ring-1 ring-slate-200/60 shadow-md"
                                        style={{ left: 80, top: 40, opacity: Math.min((lineDraw - 0.3) * 5, 1) }}
                                    >
                                        - R$ 850
                                    </div>
                                )}
                            </div>
                        </div>
                    )}

                    <div className="flex-1"></div>

                    {/* Alerta de Fatura F1 */}
                    <div
                        className="bg-white border border-slate-200 rounded-2xl p-4 shadow-[0_10px_20px_-10px_rgba(0,0,0,0.1)] mb-6 flex items-center gap-4 relative z-20"
                        style={{
                            opacity: alertCurrentOpacity,
                            transform: `translateY(${alertCurrentY}px)`,
                            pointerEvents: alertCurrentOpacity > 0 ? 'auto' : 'none'
                        }}
                    >
                        <div className="w-10 h-10 rounded-xl bg-red-100 flex items-center justify-center text-red-600 font-bold border border-red-200">
                            <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}><path strokeLinecap="round" strokeLinejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" /></svg>
                        </div>
                        <div>
                            <p className="text-slate-500 text-xs font-semibold">Fatura do cartão fechou</p>
                            <p className="text-slate-900 font-extrabold text-sm">R$ 850,00</p>
                        </div>
                    </div>
                </div>

                {/* --- MODAL DE INPUT (Exato do Sistema) F2 --- */}
                <div
                    className="absolute inset-x-0 bottom-0 top-[15%] bg-white rounded-t-[28px] shadow-[0_-20px_50px_rgba(0,0,0,0.15)] ring-1 ring-slate-200/60 z-40 flex flex-col"
                    style={{
                        opacity: currentModalOpacity,
                        transform: `translateY(${(1 - currentModalScale) * 100}px)`,
                        pointerEvents: currentModalOpacity > 0 ? 'auto' : 'none'
                    }}
                >
                    {/* Header Modal */}
                    <header className="relative flex h-14 items-center px-4">
                        <div className="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-50 text-[#6B7280]">
                            <svg className="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M18 6L6 18" /><path d="M6 6l12 12" /></svg>
                        </div>
                        <div className="pointer-events-none absolute inset-0 flex items-center justify-center">
                            <div className="text-[16px] font-bold text-[#1F2937]">Nova movimentação</div>
                        </div>
                    </header>

                    <div className="px-5 pt-2">
                        <div class="rounded-2xl bg-slate-50 p-1 ring-1 ring-slate-200/70">
                            <div class="grid grid-cols-2 gap-1 relative">
                                <button class="flex h-10 items-center justify-center rounded-xl text-sm font-semibold bg-[#FEE2E2] text-[#EF4444] border border-transparent">
                                    Gasto
                                </button>
                                <button class="flex h-10 items-center justify-center rounded-xl text-sm font-semibold text-[#9CA3AF] border border-transparent">
                                    Receita
                                </button>
                            </div>
                        </div>

                        <div className="mt-6">
                            <div class="text-center text-[10px] font-bold uppercase tracking-wide text-slate-400">Valor da transação</div>
                            <div class="mt-2 flex items-center justify-center gap-2">
                                <div class="text-2xl font-bold text-[#EF4444]">R$</div>
                                <span class="text-[50px] font-bold text-[#EF4444] tracking-tight">{valAmount > 0 ? valAmount + ',00' : '0,00'}</span>
                                {(frame >= 110 && frame < 125) && <span className="w-[3px] h-12 bg-[#EF4444] animate-pulse"></span>}
                            </div>
                        </div>

                        {/* Form Fields baseados no UI */}
                        <div class="mt-4 space-y-3">
                            <div class="rounded-2xl bg-slate-50 px-4 py-3.5 ring-1 ring-slate-200/70">
                                <div class="flex items-center gap-3">
                                    <span class="flex h-9 w-9 items-center justify-center rounded-2xl bg-white text-slate-400 ring-1 ring-slate-200/60">
                                        <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M4 7h16" /><path d="M4 12h10" /><path d="M4 17h14" /></svg>
                                    </span>
                                    <span class="text-sm font-semibold text-slate-900">{titleText || <span className="text-slate-300">Descrição</span>}</span>
                                    {frame < 110 && <span className="w-0.5 h-4 bg-slate-400 animate-pulse"></span>}
                                </div>
                            </div>

                            <div class="grid grid-cols-2 gap-3">
                                <div class="rounded-2xl bg-slate-50 px-3 py-3 ring-1 ring-slate-200/70 flex items-center gap-2">
                                    <span class="flex h-8 w-8 items-center justify-center rounded-2xl bg-blue-100 text-blue-600">
                                        <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" /><polyline points="9 22 9 12 15 12 15 22" /></svg>
                                    </span>
                                    <div class="min-w-0">
                                        <div class="text-[9px] font-bold uppercase text-slate-400">Categoria</div>
                                        <div class="text-xs font-semibold text-slate-900">Moradia</div>
                                    </div>
                                </div>
                                <div class="rounded-2xl bg-slate-50 px-3 py-3 ring-1 ring-slate-200/70 flex items-center gap-2">
                                    <span class="flex h-8 w-8 items-center justify-center rounded-2xl bg-purple-100 text-purple-600">
                                        <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><rect x="1" y="4" width="22" height="16" rx="2" ry="2" /><line x1="1" y1="10" x2="23" y2="10" /></svg>
                                    </span>
                                    <div class="min-w-0">
                                        <div class="text-[9px] font-bold uppercase text-slate-400">Conta</div>
                                        <div class="text-xs font-semibold text-slate-900">Nubank</div>
                                    </div>
                                </div>
                            </div>

                            <button
                                class="w-full mt-4 flex h-12 items-center justify-center rounded-2xl bg-[#14B8A6] px-4 font-bold tracking-wide text-white shadow-md active:scale-95 transition-transform"
                                style={{ transform: `scale(${btnConfirmScale})` }}
                            >
                                SALVAR LANÇAMENTO
                            </button>
                        </div>
                    </div>
                </div>

                {/* FAB Button original do Kitamo (Mobile Shell Base) */}
                <div
                    className="absolute bottom-6 left-1/2 -translate-x-1/2 w-14 h-14 bg-[#14B8A6] rounded-full flex items-center justify-center shadow-[0_10px_25px_rgba(20,184,166,0.3)] z-30"
                    style={{
                        transform: `translateX(-50%) scale(${fabScale * (1 - initBalanceExit)})`,
                        opacity: 1 - initBalanceExit
                    }}
                >
                    <svg className="w-6 h-6 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="3">
                        <path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m8-8H4" />
                    </svg>
                </div>

                {/* Cursor Virtual */}
                {frame >= 50 && frame < 150 && (
                    <div className="absolute inset-0 z-50 pointer-events-none">
                        {frame < 80 && (
                            <div className="absolute w-12 h-12" style={{ left: cursorX, top: cursorY, transform: `scale(${1 - clickFab * 0.3})` }}>
                                <div className="w-8 h-8 rounded-full bg-slate-900/10 backdrop-blur-md border border-slate-900/20 shadow-lg"></div>
                            </div>
                        )}
                        {frame >= 130 && frame < 150 && (
                            <div className="absolute w-12 h-12" style={{ left: cursorX2, top: cursorY2, transform: `scale(${1 - clickConfirm * 0.3})` }}>
                                <div className="w-8 h-8 rounded-full bg-slate-900/10 backdrop-blur-md border border-slate-900/20 shadow-lg"></div>
                            </div>
                        )}
                    </div>
                )}

            </div>
        </AbsoluteFill>
    );
};
