import React from 'react';
import { AbsoluteFill, interpolate, spring, useCurrentFrame, useVideoConfig, Easing } from 'remotion';

export const HeroSectionDesktop: React.FC = () => {
    const frame = useCurrentFrame();
    const { fps } = useVideoConfig();

    // ==========================================
    // 1. STORYTELLING & CAMERA: PERFECT LOOP
    // ==========================================

    const zoomInSpring = spring({ frame: frame - 10, fps, config: { damping: 16, stiffness: 90 } });
    const zoomOutSpring = spring({ frame: frame - 70, fps, config: { damping: 16, stiffness: 90 } });
    const cameraScale = 1 + interpolate(zoomInSpring, [0, 1], [0, 0.25]) - interpolate(zoomOutSpring, [0, 1], [0, 0.25]);
    const cameraX = interpolate(zoomInSpring, [0, 1], [0, -280]) - interpolate(zoomOutSpring, [0, 1], [0, -280]);
    const cameraY = interpolate(zoomInSpring, [0, 1], [0, 120]) - interpolate(zoomOutSpring, [0, 1], [0, 120]);

    const cursorSpring = spring({ frame: frame - 10, fps, config: { damping: 14, stiffness: 100 } });
    const cursorX = interpolate(cursorSpring, [0, 1], [1800, 1600]);
    const cursorY = interpolate(cursorSpring, [0, 1], [900, 80]);

    const clickFab = spring({ frame: frame - 25, fps, config: { damping: 12, stiffness: 300 } });
    const currentFabScale = 1 - clickFab * 0.15 + spring({ frame: frame - 30, fps, config: { damping: 12, stiffness: 300 } }) * 0.15;

    const modalSpring = spring({ frame: frame - 28, fps, config: { damping: 14, stiffness: 180 } });
    const modalExitSpring = spring({ frame: frame - 72, fps, config: { damping: 14, stiffness: 160 } });
    const modalOpacity = interpolate(modalSpring, [0, 1], [0, 1]) - interpolate(modalExitSpring, [0, 1], [0, 1]);
    const finalModalScale = interpolate(modalSpring, [0, 1], [0.9, 1]) - interpolate(modalExitSpring, [0, 1], [0, 0.1]);

    const typeDesc = interpolate(frame, [40, 50], [0, 13], { extrapolateRight: 'clamp' });
    const descText = "Fatura Cartão".substring(0, Math.floor(typeDesc));
    const typeVal = interpolate(frame, [50, 60], [0, 8], { extrapolateRight: 'clamp' });
    const valText = "2.500,00".substring(0, Math.floor(typeVal));

    const cursorX2 = interpolate(frame, [60, 66], [1600, 1200], { extrapolateRight: 'clamp' });
    const cursorY2 = interpolate(frame, [60, 66], [80, 850], { extrapolateRight: 'clamp' });
    const clickConfirm = spring({ frame: frame - 68, fps, config: { damping: 12, stiffness: 300 } });
    const currentBtnScale = 1 - clickConfirm * 0.05 + spring({ frame: frame - 72, fps, config: { damping: 12, stiffness: 300 } }) * 0.05;

    const projSpring = spring({ frame: frame - 80, fps, config: { damping: 13, stiffness: 110 } });
    const resetSpring = spring({ frame: frame - 110, fps, config: { damping: 14, stiffness: 90 } });

    const balanceValue = Math.floor(
        3000 - interpolate(projSpring, [0, 1], [0, 2500]) + interpolate(resetSpring, [0, 1], [0, 2500])
    );
    const bar30Height = 250 - interpolate(projSpring, [0, 1], [0, 210]) + interpolate(resetSpring, [0, 1], [0, 210]);
    const bar30Top = 50 + interpolate(projSpring, [0, 1], [0, 210]) - interpolate(resetSpring, [0, 1], [0, 210]);

    const newItemSpring = spring({ frame: frame - 82, fps, config: { damping: 14, stiffness: 120 } });
    const newItemExitSpring = spring({ frame: frame - 115, fps, config: { damping: 14, stiffness: 100 } });
    const newItemOpacity = interpolate(newItemSpring, [0, 1], [0, 1]) - interpolate(newItemExitSpring, [0, 1], [0, 1]);
    const newItemX = interpolate(newItemSpring, [0, 1], [20, 0]) + interpolate(newItemExitSpring, [0, 1], [0, -20]);
    const newItemHeight = interpolate(newItemSpring, [0, 1], [0, 84]) - interpolate(newItemExitSpring, [0, 1], [0, 84]);

    const toastSpring = spring({ frame: frame - 82, fps, config: { damping: 12, stiffness: 150 } });
    const toastExitSpring = spring({ frame: frame - 115, fps, config: { damping: 14, stiffness: 120 } });
    const toastY = interpolate(toastSpring, [0, 1], [-200, 32]) - interpolate(toastExitSpring, [0, 1], [0, 200]);
    const toastOpacity = 1 - interpolate(toastExitSpring, [0, 1], [0, 1]);

    const cursorOpacity = 1 - interpolate(frame, [115, 125], [0, 1], { extrapolateRight: 'clamp' });

    return (
        <AbsoluteFill className="bg-slate-50 flex items-center justify-center font-sans overflow-hidden">
            <div
                className="w-full h-full flex relative bg-slate-50 origin-[70%_20%]"
                style={{
                    transform: `scale(${cameraScale}) translate(${cameraX}px, ${cameraY}px)`
                }}
            >
                <aside className="w-[300px] h-full bg-white border-r border-slate-200/60 flex flex-col p-6 z-10 relative shadow-[4px_0_24px_rgba(0,0,0,0.02)]">
                    <div className="flex items-center gap-3 mb-10 pl-2">
                        <div className="w-10 h-10 bg-[#14B8A6] rounded-xl flex items-center justify-center shadow-md">
                            <span className="text-white font-bold text-xl">K</span>
                        </div>
                        <span className="text-2xl font-bold text-slate-900 tracking-tight">Kitamo</span>
                    </div>

                    <nav className="flex-1 space-y-2">
                        <div className="flex items-center gap-4 px-4 py-3 bg-emerald-50 text-[#14B8A6] rounded-2xl font-semibold transition-all">
                            <svg className="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><rect x="3" y="3" width="7" height="7" rx="1" /><rect x="14" y="3" width="7" height="7" rx="1" /><rect x="14" y="14" width="7" height="7" rx="1" /><rect x="3" y="14" width="7" height="7" rx="1" /></svg>
                            Visão Geral
                        </div>
                        <div className="flex items-center gap-4 px-4 py-3 text-slate-500 hover:bg-slate-50 rounded-2xl font-semibold">
                            <svg className="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><line x1="12" y1="1" x2="12" y2="23" /><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6" /></svg>
                            Movimentações
                        </div>
                    </nav>

                    <div className="mt-auto px-4 py-3 flex items-center gap-3 cursor-pointer hover:bg-slate-50 rounded-2xl p-2 transition-all">
                        <div className="w-12 h-12 bg-slate-200 rounded-full flex items-center justify-center font-bold text-slate-700">GF</div>
                        <div className="flex-1 min-w-0">
                            <div className="text-sm font-semibold text-slate-900 truncate">Gabriel Felix</div>
                            <div className="text-xs text-slate-500 truncate">Meu Perfil</div>
                        </div>
                    </div>
                </aside>

                <main className="flex-1 h-full flex flex-col pt-10 px-16 relative z-0 overflow-hidden bg-[radial-gradient(ellipse_at_top_right,_var(--tw-gradient-stops))] from-slate-50 via-slate-50 to-slate-100">

                    <header className="flex items-center justify-between mb-10">
                        <div>
                            <div className="text-sm font-semibold text-slate-400">OLÁ, GABRIEL</div>
                            <div className="text-4xl font-bold tracking-tight text-slate-900">Visão Geral</div>
                        </div>

                        <div className="flex items-center gap-4 relative z-50">
                            <div className="relative flex h-14 w-14 items-center justify-center rounded-2xl bg-white text-slate-600 shadow-sm ring-1 ring-slate-200/60">
                                <span className="absolute -right-2 -top-2 inline-flex h-6 min-w-[24px] items-center justify-center rounded-full bg-red-500 px-1.5 text-xs font-bold text-white shadow-sm">1</span>
                                <svg className="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M6 8a6 6 0 0 1 12 0c0 7 3 7 3 7H3s3 0 3-7" /><path d="M10 21a2 2 0 0 0 4 0" /></svg>
                            </div>

                            <div
                                className="flex items-center gap-2 h-14 px-6 bg-[#14B8A6] rounded-2xl text-white font-bold cursor-pointer shadow-[0_4px_14px_rgba(20,184,166,0.3)] hover:shadow-[0_6px_20px_rgba(20,184,166,0.4)] transition-shadow"
                                style={{ transform: `scale(${currentFabScale})` }}
                            >
                                <svg className="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><line x1="12" y1="5" x2="12" y2="19" /><line x1="5" y1="12" x2="19" y2="12" /></svg>
                                <span>Nova Movimentação</span>
                            </div>
                        </div>
                    </header>

                    <div className="grid grid-cols-12 gap-8 relative z-10 w-full">
                        <div className="col-span-8 space-y-8">
                            <section className="rounded-[2rem] bg-gradient-to-br from-slate-950 via-slate-900 to-slate-800 p-8 shadow-xl ring-1 ring-slate-900/10 z-20">
                                <div className="flex items-start justify-between gap-4">
                                    <div>
                                        <div className="text-base font-semibold uppercase tracking-wide text-slate-300">Saldo Total</div>
                                        <div className="mt-2 text-6xl font-semibold tracking-tight text-emerald-400">
                                            R$ {balanceValue},00
                                        </div>
                                    </div>
                                    <div className="mt-1 inline-flex h-12 w-12 items-center justify-center rounded-full bg-white/10 text-white ring-1 ring-white/10">
                                        <svg className="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12Z" /><circle cx="12" cy="12" r="3" /></svg>
                                    </div>
                                </div>

                                <div className="mt-8 grid grid-cols-2 gap-4">
                                    <div className="rounded-[1.5rem] bg-white/5 p-5 ring-1 ring-white/10 backdrop-blur-sm">
                                        <div className="flex items-center justify-between text-xs font-semibold uppercase tracking-wide text-emerald-300">
                                            <span>Entrou</span>
                                            <svg className="h-5 w-5 text-white/70" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M9 18l6-6-6-6" /></svg>
                                        </div>
                                        <div className="mt-2 text-2xl font-semibold text-white">R$ 4.500,00</div>
                                    </div>
                                    <div className="rounded-[1.5rem] bg-white/5 p-5 ring-1 ring-white/10 backdrop-blur-sm">
                                        <div className="flex items-center justify-between text-xs font-semibold uppercase tracking-wide text-red-300">
                                            <span>Saiu</span>
                                            <svg className="h-5 w-5 text-white/70" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M9 18l6-6-6-6" /></svg>
                                        </div>
                                        <div className="mt-2 text-2xl font-semibold text-white">R$ 1.500,00</div>
                                    </div>
                                </div>
                            </section>

                            <section className="rounded-[2rem] bg-white p-6 shadow-sm ring-1 ring-slate-200/60 z-10 w-full">
                                <div className="flex items-center justify-between mb-8">
                                    <div className="flex items-center gap-4">
                                        <span className="flex h-14 w-14 items-center justify-center rounded-2xl bg-emerald-50 text-emerald-600 shadow-inner">
                                            <svg className="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M4 19V5" /><path d="M10 19V9" /><path d="M16 19v-4" /><path d="M22 19V7" /></svg>
                                        </span>
                                        <div className="text-2xl font-semibold text-slate-900">Projeção 30 dias</div>
                                    </div>
                                    {frame < 80 || frame > 110 ? (
                                        <div className="rounded-full bg-emerald-50 px-4 py-2 text-sm font-semibold text-emerald-600 border border-emerald-100">
                                            ✅ R$ 3000,00
                                        </div>
                                    ) : (
                                        <div className="rounded-full bg-red-50 px-4 py-2 text-sm font-semibold text-red-500 border border-red-100 shadow-sm">
                                            ⚠️ Atenção
                                        </div>
                                    )}
                                </div>

                                <div className="mt-6">
                                    <div className="relative mx-auto h-[260px] w-full max-w-2xl px-8">
                                        <div className="pointer-events-none absolute left-0 right-0 border-t-2 border-dashed border-[#EF4444]" style={{ top: '230px' }}></div>
                                        <div className="pointer-events-none absolute right-0 -translate-y-1/2 text-sm font-bold tracking-wide text-[#EF4444]/80" style={{ top: '230px' }}>Saldo zero</div>

                                        <div className="grid h-[260px] grid-cols-6 items-end gap-6 px-4">
                                            <div className="relative h-[260px] text-center"><div className="mx-auto w-14 rounded-full bg-gradient-to-t from-[#0f766e] to-[#14B8A6] absolute left-1/2 -translate-x-1/2 top-[50px] shadow-sm" style={{ height: '180px' }}></div></div>
                                            <div className="relative h-[260px] text-center"><div className="mx-auto w-14 rounded-full bg-gradient-to-t from-[#0f766e] to-[#14B8A6] absolute left-1/2 -translate-x-1/2 top-[70px] shadow-sm" style={{ height: '160px' }}></div></div>
                                            <div className="relative h-[260px] text-center"><div className="mx-auto w-14 rounded-full bg-gradient-to-t from-[#0f766e] to-[#14B8A6] absolute left-1/2 -translate-x-1/2 top-[100px] shadow-sm" style={{ height: '130px' }}></div></div>
                                            <div className="relative h-[260px] text-center"><div className="mx-auto w-14 rounded-full bg-gradient-to-t from-[#0f766e] to-[#14B8A6] absolute left-1/2 -translate-x-1/2 top-[60px] shadow-sm" style={{ height: '170px' }}></div></div>
                                            <div className="relative h-[260px] text-center"><div className="mx-auto w-14 rounded-full bg-gradient-to-t from-[#0f766e] to-[#14B8A6] absolute left-1/2 -translate-x-1/2 top-[90px] shadow-sm" style={{ height: '140px' }}></div></div>

                                            <div className="relative h-[260px] text-center z-10">
                                                <div
                                                    className="mx-auto w-14 rounded-full absolute left-1/2 -translate-x-1/2 transition-colors shadow-md"
                                                    style={{
                                                        height: `${bar30Height}px`,
                                                        top: `${bar30Top}px`,
                                                        background: (frame >= 80 && frame <= 110) ? 'linear-gradient(to top, #b91c1c, #EF4444)' : 'linear-gradient(to top, #0f766e, #14B8A6)'
                                                    }}
                                                ></div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </section>
                        </div>

                        <div className="col-span-4 space-y-8 relative z-30">
                            <section className="rounded-[2rem] bg-white p-6 shadow-sm ring-1 ring-slate-200/60 overflow-hidden relative min-h-[400px]">
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
                                        <div className="flex items-center justify-between p-3 rounded-2xl bg-[#FEF2F2] border border-[#FECACA] h-[72px]">
                                            <div className="flex items-center gap-4">
                                                <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-white text-red-500 shadow-sm"><svg className="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M12 5v14" /><path d="M19 12l-7 7-7-7" /></svg></div>
                                                <div>
                                                    <div className="text-sm font-bold text-slate-900">Fatura Cartão</div>
                                                    <div className="text-xs font-semibold text-red-500 mt-1">Moradia • Agora</div>
                                                </div>
                                            </div>
                                            <div className="text-sm font-black text-red-600">- 2.500,00</div>
                                        </div>
                                    </div>

                                    <div className="flex items-center justify-between p-3 rounded-2xl border border-transparent">
                                        <div className="flex items-center gap-4">
                                            <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-red-50 text-red-500"><svg className="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M12 5v14" /><path d="M19 12l-7 7-7-7" /></svg></div>
                                            <div>
                                                <div className="text-sm font-bold text-slate-900">Ifood S/A</div>
                                                <div className="text-xs text-slate-400 mt-1">Alimentação • Ontem</div>
                                            </div>
                                        </div>
                                        <div className="text-sm font-bold text-slate-900">- 89,90</div>
                                    </div>
                                    <div className="flex items-center justify-between p-3 rounded-2xl border border-transparent">
                                        <div className="flex items-center gap-4">
                                            <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-emerald-50 text-emerald-600"><svg className="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M12 19V5" /><path d="M5 12l7-7 7 7" /></svg></div>
                                            <div>
                                                <div className="text-sm font-bold text-slate-900">Salário</div>
                                                <div className="text-xs text-slate-400 mt-1">Renda • Ontem</div>
                                            </div>
                                        </div>
                                        <div className="text-sm font-bold text-emerald-600">+ 4.500,00</div>
                                    </div>
                                </div>
                            </section>
                        </div>
                    </div>
                </main>

                {frame > 25 && frame < 85 && (
                    <div
                        className="absolute inset-0 z-[60] flex items-center justify-center bg-slate-900/60 backdrop-blur-md"
                        style={{ opacity: modalOpacity, pointerEvents: 'none' }}
                    >
                        <div
                            className="bg-white rounded-[32px] shadow-[0_30px_80px_rgba(0,0,0,0.5)] ring-1 ring-slate-200/50 w-full max-w-[680px] flex flex-col relative"
                            style={{
                                transform: `scale(${finalModalScale})`,
                                pointerEvents: 'auto'
                            }}
                        >
                            <header className="relative flex h-20 items-center px-8 border-b border-slate-100">
                                <button className="flex h-12 w-12 items-center justify-center rounded-[16px] bg-slate-50 text-[#6B7280]">
                                    <svg className="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M18 6L6 18" /><path d="M6 6l12 12" /></svg>
                                </button>
                                <div className="pointer-events-none absolute inset-0 flex items-center justify-center">
                                    <div className="text-xl font-bold text-[#1F2937]">Nova movimentação</div>
                                </div>
                            </header>

                            <div className="px-10 pt-8 pb-10 space-y-6">
                                <div className="rounded-2xl bg-slate-50/80 p-2 ring-1 ring-slate-200/70">
                                    <div className="grid grid-cols-3 gap-2">
                                        <div className="flex h-12 items-center justify-center rounded-xl text-sm font-bold bg-[#FEE2E2] text-[#EF4444] shadow-sm">Gasto</div>
                                        <div className="flex h-12 items-center justify-center rounded-xl text-sm font-semibold text-[#9CA3AF]">Receita</div>
                                        <div className="flex h-12 items-center justify-center rounded-xl text-sm font-semibold text-[#9CA3AF]">Transf.</div>
                                    </div>
                                </div>

                                <div className="text-center py-6">
                                    <div className="text-xs font-bold uppercase tracking-widest text-slate-300">Valor da transação</div>
                                    <div className="mt-3 flex items-center justify-center gap-3">
                                        <div className="text-3xl font-bold text-[#EF4444]">R$</div>
                                        <span className={`text-[70px] leading-none font-bold text-[#EF4444] tracking-tight flex items-center ${!valText ? 'text-slate-200' : ''}`}>
                                            {valText || "0,00"}
                                            {frame > 60 && frame < 72 && <span className="w-[4px] h-[60px] bg-[#EF4444] animate-pulse ml-2 rounded-[2px] shadow-[0_0_10px_rgba(239,68,68,0.5)]"></span>}
                                        </span>
                                    </div>
                                </div>

                                <div className="space-y-4">
                                    <div className="rounded-2xl bg-slate-50 px-6 py-5 ring-1 ring-slate-200/70 flex items-center gap-4">
                                        <span className="flex h-12 w-12 items-center justify-center rounded-[1rem] bg-white text-slate-400 shadow-sm"><svg className="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M4 7h16" /><path d="M4 12h10" /><path d="M4 17h14" /></svg></span>
                                        <span className="text-lg font-semibold text-slate-700">
                                            {descText || <span className="text-slate-300">Descrição</span>}
                                        </span>
                                    </div>

                                    <div className="grid grid-cols-2 gap-4">
                                        <div className="rounded-2xl bg-slate-50 px-5 py-5 flex items-center gap-4 ring-1 ring-slate-200/70">
                                            <span className="flex h-12 w-12 items-center justify-center rounded-[1rem] bg-blue-100 text-blue-600 shadow-sm"><svg className="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" /><polyline points="9 22 9 12 15 12 15 22" /></svg></span>
                                            <div className="min-w-0 flex-1">
                                                <div className="text-[10px] font-bold uppercase tracking-widest text-slate-400">Categoria</div>
                                                <div className="truncate text-base font-bold text-slate-900 mt-0.5">Moradia</div>
                                            </div>
                                        </div>
                                        <div className="rounded-2xl bg-slate-50 px-5 py-5 flex items-center gap-4 ring-1 ring-slate-200/70">
                                            <div className="flex h-12 w-12 items-center justify-center overflow-hidden rounded-[1rem] bg-white shadow-sm"><svg className="h-8 w-8 text-purple-600" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8z" /></svg></div>
                                            <div className="min-w-0 flex-1">
                                                <div className="text-[10px] font-bold uppercase tracking-widest text-slate-400">Conta</div>
                                                <div className="truncate text-base font-bold text-slate-900 mt-0.5">Nubank</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <button
                                    className="h-[60px] mt-4 w-full rounded-2xl bg-gradient-to-tr from-[#14B8A6] to-emerald-400 text-xl font-bold text-white shadow-[0_10px_30px_rgba(20,184,166,0.3)] flex items-center justify-center transition-transform"
                                    style={{ transform: `scale(${currentBtnScale})` }}
                                >
                                    Salvar lançamento
                                </button>
                            </div>
                        </div>
                    </div>
                )}

                {frame > 75 && (
                    <div className="absolute z-[70] inset-x-0 top-12 flex justify-center pointer-events-none">
                        <div
                            className="bg-emerald-500/90 backdrop-blur-3xl border border-emerald-400 rounded-[2rem] p-6 shadow-[0_25px_60px_-15px_rgba(16,185,129,0.5)] flex items-start gap-4 pointer-events-auto w-full max-w-lg"
                            style={{
                                transform: `translateY(${toastY}px)`,
                                opacity: toastOpacity
                            }}
                        >
                            <div className="text-3xl text-white mt-1">✅</div>
                            <div className="flex-1">
                                <h3 className="text-xl font-extrabold text-white tracking-tight">Movimentação criada!</h3>
                                <p className="text-sm font-semibold text-emerald-50 mt-1">
                                    "Fatura Cartão" subtraída instantaneamente.
                                </p>
                            </div>
                        </div>
                    </div>
                )}

                {frame >= 10 && frame < 72 && (
                    <div
                        className="absolute w-24 h-24 z-[100] pointer-events-none"
                        style={{
                            left: frame < 60 ? cursorX : cursorX2,
                            top: frame < 60 ? cursorY : cursorY2,
                            opacity: cursorOpacity
                        }}
                    >
                        <div
                            className="w-16 h-16 rounded-full bg-slate-900/10 backdrop-blur-md border-[2px] border-slate-900/20 shadow-[0_0_30px_rgba(0,0,0,0.15)]"
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
