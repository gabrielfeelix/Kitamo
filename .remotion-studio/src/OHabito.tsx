import { AbsoluteFill, interpolate, spring, useCurrentFrame, useVideoConfig } from 'remotion';

export const OHabito: React.FC = () => {
    const frame = useCurrentFrame();
    const { fps } = useVideoConfig();

    // Animations
    // Cursor moves to the button and clicks
    const cursorX = interpolate(frame, [0, 20], [200, 360], { extrapolateRight: 'clamp' });
    const cursorY = interpolate(frame, [0, 20], [1000, 780], { extrapolateRight: 'clamp' });
    const clickScale = spring({ frame: frame - 20, fps, config: { damping: 10, mass: 0.5, stiffness: 200 } });

    // Button press effect
    const btnScale = interpolate(frame, [20, 25, 30], [1, 0.95, 1], { extrapolateRight: 'clamp' });
    const btnColor = interpolate(frame, [20, 25, 30], [1, 0.8, 1], { extrapolateRight: 'clamp' });

    // Transition to success screen
    const successTranslateY = interpolate(frame, [40, 55], [200, 0], { extrapolateRight: 'clamp' });
    const successOpacity = interpolate(frame, [40, 55], [0, 1], { extrapolateRight: 'clamp' });

    // Input typing effect
    const typedText = "- R$ 45,00".substring(0, Math.floor(interpolate(frame, [0, 15], [0, 10], { extrapolateRight: 'clamp' })));

    return (
        <AbsoluteFill className="bg-slate-950 flex items-center justify-center p-12">
            {/* Phone Mockup */}
            <div className="w-full h-full bg-slate-900 rounded-[3rem] border-8 border-slate-800 relative overflow-hidden shadow-2xl">

                {/* Top Notch */}
                <div className="absolute top-0 inset-x-0 h-8 flex justify-center z-50">
                    <div className="w-40 h-8 bg-slate-800 rounded-b-3xl"></div>
                </div>

                {/* Glow effect */}
                <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-96 h-96 bg-teal-500/20 rounded-full blur-[100px] pointer-events-none"></div>

                {/* Form Screen */}
                <div
                    className="absolute inset-0 p-8 flex flex-col pt-24"
                    style={{
                        opacity: interpolate(frame, [40, 55], [1, 0], { extrapolateRight: 'clamp' }),
                        transform: `translateY(${interpolate(frame, [40, 55], [0, -100], { extrapolateRight: 'clamp' })}px)`
                    }}
                >
                    <div className="text-center mb-10">
                        <h1 className="text-4xl font-extrabold text-white mb-2">IFood</h1>
                        <p className="text-slate-400 font-medium">Lanche da tarde</p>
                        <div className="w-16 h-16 rounded-full bg-slate-800 mx-auto mt-6 flex items-center justify-center text-3xl shadow-inner">🍔</div>
                    </div>

                    <div className="bg-slate-950/50 rounded-2xl border border-white/5 p-6 flex flex-col items-center justify-center relative overflow-hidden mb-8">
                        <div className="absolute inset-0 bg-gradient-to-b from-teal-500/5 to-transparent"></div>
                        {/* Blinking cursor effect fake */}
                        <span className="text-teal-400 font-bold text-5xl relative z-10 font-[tabular-nums] tracking-tight">
                            {typedText}
                            <span style={{ opacity: frame % 10 < 5 ? 1 : 0 }}>|</span>
                        </span>
                    </div>

                    <div className="grid grid-cols-2 gap-4 mb-auto">
                        <div className="bg-slate-800 rounded-xl p-4 text-center">
                            <span className="text-slate-400 text-sm font-bold block mb-1">Categoria</span>
                            <span className="text-white font-extrabold">Alimentação</span>
                        </div>
                        <div className="bg-slate-800 rounded-xl p-4 text-center">
                            <span className="text-slate-400 text-sm font-bold block mb-1">Conta</span>
                            <span className="text-white font-extrabold">Itaú</span>
                        </div>
                    </div>

                    <div
                        className="h-20 bg-teal-500 rounded-2xl flex items-center justify-center shadow-[0_5px_30px_theme(colors.teal.500/30)] relative overflow-hidden mt-8"
                        style={{
                            transform: `scale(${btnScale})`,
                            filter: `brightness(${btnColor})`
                        }}
                    >
                        <span className="text-slate-950 font-extrabold text-xl uppercase tracking-widest relative z-10 flex items-center gap-2">
                            Lançar agora
                            <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="3">
                                <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                            </svg>
                        </span>
                    </div>
                </div>

                {/* Success Screen */}
                <div
                    className="absolute inset-0 p-8 flex flex-col items-center justify-center text-center"
                    style={{
                        opacity: successOpacity,
                        transform: `translateY(${successTranslateY}px)`
                    }}
                >
                    <div className="w-32 h-32 bg-teal-500/20 rounded-full flex items-center justify-center mb-8 relative">
                        <div className="absolute inset-0 rounded-full border-4 border-teal-500/50 animate-[spin_3s_linear_infinite]"></div>
                        <svg className="w-16 h-16 text-teal-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="3">
                            <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                        </svg>
                    </div>
                    <h2 className="text-3xl font-extrabold text-white mb-4">Lançado com sucesso!</h2>
                    <p className="text-slate-400 text-lg font-medium">Seu saldo livre agora é<br /> <strong className="text-teal-400 text-2xl">R$ 1.850,00</strong></p>
                </div>

                {/* Fake Cursor */}
                <div
                    className="absolute z-50 w-12 h-12 flex items-center justify-center"
                    style={{
                        left: cursorX,
                        top: cursorY,
                        transform: `scale(${1 - (clickScale * 0.2)})`
                    }}
                >
                    <div className="w-8 h-8 rounded-full bg-white/30 backdrop-blur-sm border-2 border-white shadow-[0_0_15px_rgba(255,255,255,0.5)]"></div>
                </div>

            </div>
        </AbsoluteFill>
    );
};
