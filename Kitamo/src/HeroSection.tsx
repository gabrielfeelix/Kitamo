import React from 'react';
import { AbsoluteFill, interpolate, spring, useCurrentFrame, useVideoConfig, Easing } from 'remotion';

export const HeroSection: React.FC = () => {
    const frame = useCurrentFrame();
    const { fps } = useVideoConfig();

    // ==========================================
    // STORYTELLING: PERFECT LOOP (MOBILE)
    // ==========================================

    const zoomInSpring = spring({ frame: frame - 10, fps, config: { damping: 16, stiffness: 90 } });
    const zoomOutSpring = spring({ frame: frame - 70, fps, config: { damping: 16, stiffness: 90 } });
    const cameraScale = 1 + interpolate(zoomInSpring, [0, 1], [0, 0.05]) - interpolate(zoomOutSpring, [0, 1], [0, 0.05]);

    const cursorSpring = spring({ frame: frame - 10, fps, config: { damping: 14, stiffness: 100 } });
    const cursorX = interpolate(cursorSpring, [0, 1], [800, 540]);
    const cursorY = interpolate(cursorSpring, [0, 1], [1800, 1600]);

    const clickFab = spring({ frame: frame - 28, fps, config: { damping: 12, stiffness: 300 } });
    const currentFabScale = 1 - clickFab * 0.15 + spring({ frame: frame - 32, fps, config: { damping: 12, stiffness: 300 } }) * 0.15;

    const rippleSpring = spring({ frame: frame - 28, fps, config: { damping: 20, stiffness: 100 } });
    const rippleScale = interpolate(rippleSpring, [0, 1], [0.8, 2]);
    const rippleOpacity = interpolate(rippleSpring, [0, 1], [0.5, 0]);

    // Slide up modal Sheet iOS Style
    const modalSpring = spring({ frame: frame - 30, fps, config: { damping: 14, stiffness: 200 } });
    const modalExitSpring = spring({ frame: frame - 72, fps, config: { damping: 15, stiffness: 180 } });
    const modalY = interpolate(modalSpring, [0, 1], [1920, 0]) + interpolate(modalExitSpring, [0, 1], [0, 1920]);

    const typeDesc = interpolate(frame, [40, 50], [0, 13], { extrapolateRight: 'clamp' });
    const descText = "Fatura Cartão".substring(0, Math.floor(typeDesc));
    const typeVal = interpolate(frame, [50, 60], [0, 8], { extrapolateRight: 'clamp' });
    const valText = "2.500,00".substring(0, Math.floor(typeVal));

    const cursorX2 = interpolate(frame, [60, 65], [540, 540], { extrapolateRight: 'clamp' });
    const cursorY2 = interpolate(frame, [60, 65], [1600, 1780], { extrapolateRight: 'clamp' });
    const clickConfirm = spring({ frame: frame - 68, fps, config: { damping: 12, stiffness: 300 } });
    const currentBtnScale = 1 - clickConfirm * 0.05 + spring({ frame: frame - 72, fps, config: { damping: 12, stiffness: 300 } }) * 0.05;

    const projSpring = spring({ frame: frame - 80, fps, config: { damping: 13, stiffness: 120 } });
    const resetProgress = interpolate(frame, [115, 134], [0, 1], { easing: Easing.bezier(0.25, 1, 0.5, 1), extrapolateRight: 'clamp' });

    const balanceValue = Math.floor(
        3000 - interpolate(projSpring, [0, 1], [0, 2500]) + interpolate(resetProgress, [0, 1], [0, 2500])
    );
    const bar30Height = 250 - interpolate(projSpring, [0, 1], [0, 210]) + interpolate(resetProgress, [0, 1], [0, 210]);
    const bar30Top = 50 + interpolate(projSpring, [0, 1], [0, 210]) - interpolate(resetProgress, [0, 1], [0, 210]);

    // Glassmorphic toast
    const toastSpring = spring({ frame: frame - 82, fps, config: { damping: 14, stiffness: 180 } });
    const toastY = interpolate(toastSpring, [0, 1], [-400, 50]) - interpolate(resetProgress, [0, 1], [0, 300]);
    const toastOpacity = 1 - resetProgress;

    const newItemSpring = spring({ frame: frame - 80, fps, config: { damping: 14, stiffness: 120 } });
    const newItemOpacity = interpolate(newItemSpring, [0, 1], [0, 1]) - resetProgress;
    const newItemX = interpolate(newItemSpring, [0, 1], [50, 0]) + interpolate(resetProgress, [0, 1], [0, -50]);
    const newItemHeight = interpolate(newItemSpring, [0, 1], [0, 140]) - interpolate(resetProgress, [0, 1], [0, 140]);

    const cursorOpacity = 1 - interpolate(frame, [115, 125], [0, 1], { extrapolateRight: 'clamp' });

    return (
        <AbsoluteFill className="bg-slate-50 flex items-center justify-center font-sans overflow-hidden">
            <div
                className="w-full h-full flex flex-col relative bg-[radial-gradient(ellipse_at_top_right,_var(--tw-gradient-stops))] from-slate-50 via-slate-50 to-slate-100"
                style={{ transform: `scale(${cameraScale})` }}
            >
                {/* --- REAL KITAMO DASHBOARD --- */}
                <div className="flex-1 w-full px-12 pt-16 flex flex-col relative z-10 w-full" >
                    <header className="flex items-center justify-between pt-2">
                        <div className="flex items-center gap-4">
                            <span className="flex h-16 w-16 items-center justify-center overflow-hidden rounded-full bg-slate-200 text-xl font-bold text-slate-700">GF</span>
                            <div className="leading-tight">
                                <div className="text-sm font-semibold text-slate-400">OLÁ, GABRIEL</div>
                                <div className="text-3xl font-bold tracking-tight text-slate-900">Visão Geral</div>
                            </div>
                        </div>

                        <div className="flex items-center gap-3">
                            <div className="flex h-14 w-14 items-center justify-center rounded-full bg-white text-slate-600 shadow-sm ring-1 ring-slate-200/60"><svg className="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="11" cy="11" r="7" /><path d="M21 21l-4.3-4.3" /></svg></div>
                            <div className="relative flex h-14 w-14 items-center justify-center rounded-full bg-white text-slate-600 shadow-sm ring-1 ring-slate-200/60">
                                <span className="absolute -right-1 -top-1 inline-flex h-6 min-w-[24px] items-center justify-center rounded-full bg-red-500 px-1.5 text-xs font-bold text-white shadow-sm">1</span>
                                <svg className="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M6 8a6 6 0 0 1 12 0c0 7 3 7 3 7H3s3 0 3-7" /><path d="M10 21a2 2 0 0 0 4 0" /></svg>
                            </div>
                        </div>
                    </header>

                    {/* Card de Saldo Total */}
                    <section className="mt-10 rounded-[2rem] bg-gradient-to-br from-slate-950 via-slate-900 to-slate-800 p-8 shadow-[0_20px_50px_rgba(0,0,0,0.15)] ring-1 ring-slate-900/10 z-20 w-full">
                        <div className="flex items-start justify-between gap-4">
                            <div>
                                <div className="text-base font-semibold uppercase tracking-wide text-slate-300">Saldo Total</div>
                                <div className="mt-2 text-6xl font-semibold tracking-tight text-emerald-400">R$ {balanceValue},00</div>
                            </div>
                            <div className="flex items-center gap-2">
                                <div className="mt-1 inline-flex h-12 w-12 items-center justify-center rounded-full bg-white/10 text-white ring-1 ring-white/10"><svg className="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12Z" /><circle cx="12" cy="12" r="3" /></svg></div>
                            </div>
                        </div>

                        <div className="mt-8 grid grid-cols-2 gap-4">
                            <div className="rounded-[1.5rem] bg-white/5 p-5 ring-1 ring-white/10">
                                <div className="flex items-center justify-between text-xs font-semibold uppercase tracking-wide text-emerald-300"><span>Entrou</span><svg className="h-5 w-5 text-white/70" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M9 18l6-6-6-6" /></svg></div>
                                <div className="mt-2 text-2xl font-semibold text-white">R$ 4.500,00</div>
                            </div>
                            <div className="rounded-[1.5rem] bg-white/5 p-5 ring-1 ring-white/10">
                                <div className="flex items-center justify-between text-xs font-semibold uppercase tracking-wide text-red-300"><span>Saiu</span><svg className="h-5 w-5 text-white/70" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M9 18l6-6-6-6" /></svg></div>
                                <div className="mt-2 text-2xl font-semibold text-white">R$ 1.500,00</div>
                            </div>
                        </div>
                    </section>

                    {/* Projeção 30 dias */}
                    <section className="mt-8 rounded-[2rem] bg-white p-6 shadow-sm ring-1 ring-slate-200/60 z-10 block w-full">
                        <div className="flex items-center justify-between mb-8">
                            <div className="flex items-center gap-4">
                                <span className="flex h-14 w-14 items-center justify-center rounded-2xl bg-emerald-50 text-emerald-600 shadow-inner"><svg className="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M4 19V5" /><path d="M10 19V9" /><path d="M16 19v-4" /><path d="M22 19V7" /></svg></span>
                                <div className="text-2xl font-semibold text-slate-900">Projeção 30 dias</div>
                            </div>
                            {frame < 80 || frame > 110 ? (
                                <div className="rounded-full bg-emerald-50 px-4 py-2 text-sm font-semibold text-emerald-600 border border-emerald-100">✅ R$ 3000,00</div>
                            ) : (
                                <div className="rounded-full bg-red-50 px-4 py-2 text-sm font-semibold text-red-500 border border-red-100 shadow-sm">⚠️ Atenção</div>
                            )}
                        </div>

                        <div className="mt-6">
                            <div className="relative mx-auto h-[300px]">
                                <div className="pointer-events-none absolute left-0 right-0 border-t-2 border-dashed border-[#EF4444]" style={{ top: '230px' }}></div>
                                <div className="pointer-events-none absolute right-0 -translate-y-1/2 text-sm font-semibold text-[#EF4444]" style={{ top: '230px' }}>Saldo zero</div>

                                <div className="grid h-[300px] grid-cols-6 items-end gap-4 px-2">
                                    <div className="relative h-[300px] text-center"><div className="mx-auto w-12 rounded-full bg-gradient-to-t from-[#0f766e] to-[#14B8A6] absolute left-1/2 -translate-x-1/2 top-[50px] shadow-sm" style={{ height: '180px' }}></div></div>
                                    <div className="relative h-[300px] text-center"><div className="mx-auto w-12 rounded-full bg-gradient-to-t from-[#0f766e] to-[#14B8A6] absolute left-1/2 -translate-x-1/2 top-[70px] shadow-sm" style={{ height: '160px' }}></div></div>
                                    <div className="relative h-[300px] text-center"><div className="mx-auto w-12 rounded-full bg-gradient-to-t from-[#0f766e] to-[#14B8A6] absolute left-1/2 -translate-x-1/2 top-[100px] shadow-sm" style={{ height: '130px' }}></div></div>
                                    <div className="relative h-[300px] text-center"><div className="mx-auto w-12 rounded-full bg-gradient-to-t from-[#0f766e] to-[#14B8A6] absolute left-1/2 -translate-x-1/2 top-[60px] shadow-sm" style={{ height: '170px' }}></div></div>
                                    <div className="relative h-[300px] text-center"><div className="mx-auto w-12 rounded-full bg-gradient-to-t from-[#0f766e] to-[#14B8A6] absolute left-1/2 -translate-x-1/2 top-[90px] shadow-sm" style={{ height: '140px' }}></div></div>

                                    <div className="relative h-[300px] text-center">
                                        <div
                                            className="mx-auto w-12 rounded-full absolute left-1/2 -translate-x-1/2 transition-colors shadow-md"
                                            style={{
                                                height: `${bar30Height}px`, top: `${bar30Top}px`,
                                                background: (frame >= 80 && frame <= 110) ? 'linear-gradient(to top, #b91c1c, #EF4444)' : 'linear-gradient(to top, #0f766e, #14b8a6)'
                                            }}
                                        ></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </section>

                    <section className="mt-8 rounded-[2rem] bg-white p-6 shadow-sm ring-1 ring-slate-200/60 overflow-hidden relative w-full pb-[150px]">
                        <div className="flex items-center justify-between mb-6">
                            <div className="text-xl font-semibold text-slate-900">Últimas movimentações</div>
                        </div>

                        <div className="space-y-4">
                            <div
                                style={{
                                    height: `${newItemHeight}px`,
                                    opacity: newItemOpacity,
                                    transform: `translateX(${newItemX}px)`
                                }}
                                className="overflow-hidden"
                            >
                                <div className="flex items-center justify-between p-4 rounded-[1.5rem] bg-[#FEF2F2] border border-[#FECACA] h-[120px]">
                                    <div className="flex items-center gap-4">
                                        <div className="flex h-20 w-20 items-center justify-center rounded-[1rem] bg-white text-red-500 shadow-sm"><svg className="h-8 w-8" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M12 5v14" /><path d="M19 12l-7 7-7-7" /></svg></div>
                                        <div>
                                            <div className="text-[26px] font-bold text-slate-900">Fatura Cartão</div>
                                            <div className="text-[18px] font-semibold text-red-500 mt-1">Moradia • Agora</div>
                                        </div>
                                    </div>
                                    <div className="text-[26px] font-black text-red-600">- 2.500,00</div>
                                </div>
                            </div>

                            <div className="flex items-center justify-between p-3 rounded-2xl border border-transparent">
                                <div className="flex items-center gap-4">
                                    <div className="flex h-20 w-20 items-center justify-center rounded-[1rem] bg-red-50 text-red-500"><svg className="h-8 w-8" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M12 5v14" /><path d="M19 12l-7 7-7-7" /></svg></div>
                                    <div>
                                        <div className="text-[26px] font-bold text-slate-900">Ifood S/A</div>
                                        <div className="text-[18px] text-slate-400 mt-1">Alimentação • Ontem</div>
                                    </div>
                                </div>
                                <div className="text-[26px] font-bold text-slate-900">- 89,90</div>
                            </div>
                            <div className="flex items-center justify-between p-3 rounded-2xl border border-transparent">
                                <div className="flex items-center gap-4">
                                    <div className="flex h-20 w-20 items-center justify-center rounded-[1rem] bg-emerald-50 text-emerald-600"><svg className="h-8 w-8" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M12 19V5" /><path d="M5 12l7-7 7 7" /></svg></div>
                                    <div>
                                        <div className="text-[26px] font-bold text-slate-900">Salário</div>
                                        <div className="text-[18px] text-slate-400 mt-1">Renda • Ontem</div>
                                    </div>
                                </div>
                                <div className="text-[26px] font-bold text-emerald-600">+ 4.500,00</div>
                            </div>
                        </div>
                    </section>
                </div>

                {/* --- MÁSCARA MODAL IN TELA (iOS SHEET STYLE) --- */}
                {frame <= 80 && (
                    <>
                        <div
                            className="absolute inset-0 bg-slate-900/40 backdrop-blur-md z-[50]"
                            style={{ opacity: 1 - interpolate(modalY, [0, 1920], [0, 1]) }}
                        ></div>
                        <div
                            className="absolute inset-x-0 bottom-0 top-[8%] bg-white z-[60] flex flex-col pt-4 rounded-t-[48px] shadow-[0_-30px_80px_rgba(0,0,0,0.2)] ring-1 ring-slate-200/50"
                            style={{ transform: `translateY(${modalY}px)` }}
                        >
                            <div className="w-20 h-2 bg-slate-200 rounded-full mx-auto mb-2"></div>
                            <header className="relative flex h-24 items-center px-10">
                                <div className="flex h-16 w-16 items-center justify-center rounded-[1.5rem] bg-slate-50 text-[#6B7280]">
                                    <svg className="h-10 w-10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M18 6L6 18" /><path d="M6 6l12 12" /></svg>
                                </div>
                                <div className="pointer-events-none absolute inset-0 flex items-center justify-center"><div className="text-2xl font-bold text-[#1F2937]">Nova movimentação</div></div>
                            </header>

                            <div className="flex-1 overflow-y-auto w-full">
                                <div className="px-10 pt-8">
                                    <div className="rounded-[1.5rem] bg-slate-50 p-2 ring-1 ring-slate-200/70">
                                        <div className="grid grid-cols-3 gap-2">
                                            <div className="flex h-[3.5rem] items-center justify-center rounded-xl text-[20px] font-semibold bg-[#FEE2E2] text-[#EF4444] shadow-sm">Gasto</div>
                                            <div className="flex h-[3.5rem] items-center justify-center rounded-xl text-[20px] font-semibold text-[#9CA3AF]">Receita</div>
                                            <div className="flex h-[3.5rem] items-center justify-center rounded-xl text-[20px] font-semibold text-[#9CA3AF]">Transf.</div>
                                        </div>
                                    </div>
                                </div>

                                <div className="mt-12 px-10">
                                    <div className="text-center text-lg font-bold uppercase tracking-wide text-slate-300">Valor da transação</div>
                                    <div className="mt-4 flex items-center justify-center gap-3">
                                        <div className="text-5xl font-bold text-[#EF4444]">R$</div>
                                        <span className={`text-[90px] font-bold text-[#EF4444] tracking-tight flex items-center ${!valText ? 'text-slate-200' : ''}`}>
                                            {valText || "0,00"}
                                            {frame > 50 && frame < 65 && <span className="w-[6px] h-[90px] bg-[#EF4444] animate-pulse ml-2 rounded-[2px] shadow-[0_0_10px_rgba(239,68,68,0.5)]"></span>}
                                        </span>
                                    </div>
                                </div>

                                <div className="mt-12 space-y-6 px-10 border-t border-slate-100/50 pt-8">
                                    <div className="rounded-[2rem] bg-slate-50 px-6 py-6 ring-1 ring-slate-200/70 flex items-center gap-5 shadow-sm">
                                        <span className="flex h-16 w-16 items-center justify-center rounded-[1.5rem] bg-white text-slate-400 ring-1 ring-slate-200/60"><svg className="h-8 w-8" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M4 7h16" /><path d="M4 12h10" /><path d="M4 17h14" /></svg></span>
                                        <span className="text-2xl font-semibold text-slate-700">
                                            {descText || <span className="text-slate-300">Descrição</span>}
                                        </span>
                                    </div>

                                    <div className="grid grid-cols-2 gap-6">
                                        <div className="rounded-[2rem] bg-slate-50 px-6 py-6 ring-1 ring-slate-200/70 flex items-center gap-5 shadow-sm">
                                            <span className="flex h-16 w-16 items-center justify-center rounded-[1.5rem] bg-blue-100 text-blue-600"><svg className="h-8 w-8" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" /><polyline points="9 22 9 12 15 12 15 22" /></svg></span>
                                            <div className="min-w-0 flex-1"><div className="text-sm font-bold uppercase tracking-wide text-slate-400">Categoria</div><div className="truncate text-xl font-semibold text-slate-900 mt-1">Moradia</div></div>
                                        </div>

                                        <div className="rounded-[2rem] bg-slate-50 px-6 py-6 ring-1 ring-slate-200/70 flex items-center gap-5 shadow-sm">
                                            <div className="flex h-16 w-16 items-center justify-center overflow-hidden rounded-[1.5rem] bg-white ring-1 ring-slate-200/70"><svg className="h-10 w-10 text-purple-600" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8z" /></svg></div>
                                            <div className="min-w-0 flex-1"><div className="text-sm font-bold uppercase tracking-wide text-slate-400">Conta</div><div className="truncate text-xl font-semibold text-slate-900 mt-1">Nubank</div></div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <footer className="px-10 pt-6 pb-20">
                                <div
                                    className="h-24 w-full rounded-[1.5rem] bg-gradient-to-tr from-[#14B8A6] to-emerald-400 flex items-center justify-center text-3xl font-bold text-white shadow-[0_10px_30px_rgba(20,184,166,0.3)] transition-transform"
                                    style={{ transform: `scale(${currentBtnScale})` }}
                                >
                                    Salvar
                                </div>
                            </footer>
                        </div>
                    </>
                )}

                {/* --- TOAST NOTIFICATION PREMIUM GLASSMORPHISM --- */}
                {frame > 75 && (
                    <div className="absolute z-[70] left-0 right-0 flex justify-center pointer-events-none">
                        <div
                            className="w-[90%] bg-emerald-500/95 backdrop-blur-3xl border border-emerald-400 rounded-[2rem] p-8 shadow-[0_25px_60px_-15px_rgba(16,185,129,0.5)] flex items-start gap-6 pointer-events-auto"
                            style={{
                                transform: `translateY(${toastY}px)`,
                                opacity: toastOpacity
                            }}
                        >
                            <div className="text-4xl">✅</div>
                            <div className="flex-1">
                                <h3 className="mb-2 text-3xl font-bold text-white tracking-tight">Movimentação criada!</h3>
                                <p className="text-xl text-emerald-50 font-semibold whitespace-pre-line leading-relaxed">
                                    "Fatura Cartão" subtraída.
                                </p>
                            </div>
                        </div>
                    </div>
                )}

                {/* --- FAB BOTTOM LAYER --- */}
                <div className="absolute bottom-16 left-0 right-0 flex justify-center z-40 pointer-events-none">
                    <div className="relative pointer-events-auto">
                        {frame >= 28 && (
                            <div
                                className="absolute inset-0 rounded-[2rem] bg-emerald-400 shadow-[0_0_40px_rgba(52,211,153,0.8)]"
                                style={{ transform: `scale(${rippleScale})`, opacity: rippleOpacity }}
                            ></div>
                        )}
                        <div
                            className="relative w-24 h-24 bg-gradient-to-tr from-[#14B8A6] to-emerald-400 rounded-[2rem] flex items-center justify-center shadow-[0_20px_40px_-5px_rgba(20,184,166,0.5)]"
                            style={{ transform: `scale(${currentFabScale * (frame < 15 ? (1 + Math.sin(frame / 4) * 0.03) : 1)})` }}
                        >
                            <svg className="w-10 h-10 text-white shadow-sm" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="3"><path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m8-8H4" /></svg>
                        </div>
                    </div>
                </div>

                {/* --- CURSOR MOCK --- */}
                {frame >= 10 && frame < 72 && (
                    <div
                        className="absolute w-32 h-32 z-[100] pointer-events-none"
                        style={{
                            left: frame < 65 ? cursorX : cursorX2,
                            top: frame < 65 ? cursorY : cursorY2,
                            opacity: cursorOpacity
                        }}
                    >
                        <div
                            className="w-20 h-20 rounded-full bg-slate-900/10 backdrop-blur-md border-[2px] border-slate-900/20 shadow-[0_10px_40px_rgba(0,0,0,0.2)]"
                            style={{
                                transform: `scale(${frame < 60 ? (1 - clickFab * 0.4) : (1 - clickConfirm * 0.4)})`
                            }}
                        ></div>
                    </div>
                )}
            </div>
        </AbsoluteFill>
    );
};
