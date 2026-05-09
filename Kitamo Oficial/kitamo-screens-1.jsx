// Kitamo Screens 1-4: Splash, Login, Onboarding, Home

// ─── 1. SPLASH ─────────────────────────────────────────────
const ScreenSplash = () => (
  <Screen bg={KITAMO.brand} light label="01 Splash">
    <div style={{
      position:'absolute', inset:0, display:'flex', flexDirection:'column',
      alignItems:'center', justifyContent:'center', gap: 18,
    }}>
      <KitamoLogo size={84} color="#fff" />
      <div style={{fontSize: 48, fontWeight: 800, color:'#fff', letterSpacing:-1.5, lineHeight:1}}>kitamo</div>
      <div style={{fontSize:18, color:'rgba(255,255,255,0.85)', fontWeight: 500}}>Saiba se vai dar</div>
      <div style={{position:'absolute', bottom: 60, display:'flex', gap:6}}>
        {[0,1,2].map(i => <div key={i} style={{
          width:8, height:8, borderRadius:4, background:'#fff',
          opacity: 0.3 + (i===1 ? 0.7 : 0),
        }}/>)}
      </div>
    </div>
  </Screen>
);

const KitamoLogo = ({ size = 36, color = KITAMO.brand }) => (
  <svg width={size} height={size} viewBox="0 0 64 64" fill="none">
    <circle cx="32" cy="32" r="30" stroke={color} strokeWidth="4"/>
    <path d="M22 18v28M22 32l16-14M22 32l16 14" stroke={color} strokeWidth="5" strokeLinecap="round" strokeLinejoin="round"/>
    <circle cx="46" cy="22" r="4" fill={color}/>
  </svg>
);

// ─── 2. LOGIN ──────────────────────────────────────────────
const ScreenLogin = () => (
  <Screen bg="#fff" light label="02 Login">
    {/* curved teal top */}
    <div style={{
      position:'absolute', top:0, left:0, right:0, height: 320,
      background: KITAMO.brand,
      borderBottomLeftRadius:'50% 60px', borderBottomRightRadius:'50% 60px',
    }}/>
    <div style={{position:'relative', padding:'10px 24px 0', display:'flex', alignItems:'center', gap:10}}>
      <KitamoLogo size={32} color="#fff"/>
      <span style={{color:'#fff', fontWeight:800, fontSize:22, letterSpacing:-0.5}}>kitamo</span>
    </div>
    <div style={{position:'relative', padding:'40px 24px 0', color:'#fff'}}>
      <div style={{fontSize:28, fontWeight:800, lineHeight:1.15, letterSpacing:-0.5}}>Bora organizar<br/>essa grana?</div>
      <div style={{fontSize:15, opacity:0.9, marginTop:8}}>Entra com seu e-mail pra continuar.</div>
    </div>
    {/* card */}
    <div style={{
      position:'absolute', top: 290, left:20, right:20, padding:24,
      background:'#fff', borderRadius:20,
      boxShadow:'0 12px 40px rgba(15,23,42,0.10), 0 2px 6px rgba(15,23,42,0.04)',
    }}>
      <Input label="E-mail" value="maria.silva@gmail.com" />
      <div style={{height:14}}/>
      <Input label="Senha" value="••••••••••" type="password" />
      <div style={{textAlign:'right', marginTop:10}}>
        <a style={{fontSize:13, color: KITAMO.muted}}>Esqueci minha senha</a>
      </div>
      <button style={{
        width:'100%', height:56, marginTop:18, border:0, borderRadius:14,
        background: KITAMO.brand, color:'#fff', fontSize:17, fontWeight:700,
        boxShadow:'0 6px 16px rgba(51,214,197,0.35)', cursor:'pointer',
      }}>Entrar</button>
      <div style={{display:'flex', alignItems:'center', gap:10, margin:'18px 0'}}>
        <div style={{flex:1, height:1, background: KITAMO.line}}/>
        <span style={{fontSize:12, color: KITAMO.muted}}>ou</span>
        <div style={{flex:1, height:1, background: KITAMO.line}}/>
      </div>
      <button style={{
        width:'100%', height:52, border:`1px solid ${KITAMO.line}`, borderRadius:14,
        background:'#fff', cursor:'pointer', display:'flex',
        alignItems:'center', justifyContent:'center', gap:10,
        fontSize:15, fontWeight:600, color: KITAMO.ink,
      }}>
        <span style={{color:'#4285F4'}}>{I.google({size:20})}</span>
        Entrar com Google
      </button>
    </div>
    <div style={{position:'absolute', bottom: 28, left:0, right:0, textAlign:'center'}}>
      <span style={{fontSize:14, color: KITAMO.muted}}>Novo aqui? </span>
      <a style={{fontSize:14, color: KITAMO.brandDark, fontWeight:700}}>Criar conta</a>
    </div>
  </Screen>
);

const Input = ({ label, value, type = 'text' }) => (
  <div style={{
    border:`1.5px solid ${KITAMO.line}`, borderRadius:14, padding:'8px 14px',
    background:'#fff',
  }}>
    <div style={{fontSize:11, color: KITAMO.muted, fontWeight:600, letterSpacing:0.2}}>{label.toUpperCase()}</div>
    <div style={{fontSize:16, color: KITAMO.ink, fontWeight:500, marginTop:2}}>{value}</div>
  </div>
);

// ─── 3. ONBOARDING ─────────────────────────────────────────
const ScreenOnboarding = () => (
  <Screen bg="#fff" label="03 Onboarding">
    <div style={{padding:'8px 24px 0', display:'flex', alignItems:'center', justifyContent:'space-between'}}>
      <a style={{fontSize:14, color: KITAMO.muted}}>Pular</a>
      <div style={{display:'flex', gap:6}}>
        {[1,1,0].map((on,i) => <div key={i} style={{
          width: on?22:8, height:8, borderRadius:4,
          background: on ? KITAMO.brand : KITAMO.line,
        }}/>)}
      </div>
      <span style={{fontSize:14, opacity:0}}>...</span>
    </div>
    {/* illustration */}
    <div style={{margin:'28px 24px 0', height:240, borderRadius:24,
      background: `linear-gradient(140deg, ${KITAMO.brandSoft} 0%, #fff 100%)`,
      position:'relative', overflow:'hidden',
    }}>
      <svg viewBox="0 0 300 240" style={{position:'absolute', inset:0, width:'100%', height:'100%'}}>
        <circle cx="150" cy="135" r="80" fill="none" stroke={KITAMO.brand} strokeWidth="3" opacity="0.5"/>
        <circle cx="150" cy="135" r="55" fill="none" stroke={KITAMO.brand} strokeWidth="3"/>
        <path d="M120 135 L145 160 L185 115" stroke={KITAMO.brandDark} strokeWidth="6" fill="none" strokeLinecap="round" strokeLinejoin="round"/>
        <circle cx="220" cy="60" r="6" fill={KITAMO.warn}/>
        <circle cx="60" cy="180" r="5" fill={KITAMO.brand}/>
        <circle cx="245" cy="180" r="4" fill={KITAMO.success}/>
        <path d="M40 50 L60 50 M50 40 L50 60" stroke={KITAMO.muted} strokeWidth="2" strokeLinecap="round"/>
      </svg>
    </div>
    <div style={{padding:'30px 28px 0'}}>
      <div style={{fontSize:30, fontWeight:800, lineHeight:1.15, letterSpacing:-0.6}}>Fala! <br/>Bora começar?</div>
      <div style={{fontSize:16, color: KITAMO.ink2, marginTop:14, lineHeight:1.5}}>
        Em 1 minuto a gente já te mostra quanto você tem e pra onde tá indo seu dinheiro.
      </div>
    </div>
    <div style={{position:'absolute', left:24, right:24, bottom:36}}>
      <button style={{
        width:'100%', height:56, border:0, borderRadius:14,
        background: KITAMO.brand, color:'#fff', fontSize:17, fontWeight:700,
        cursor:'pointer', boxShadow:'0 6px 16px rgba(51,214,197,0.35)',
        display:'flex', alignItems:'center', justifyContent:'center', gap:8,
      }}>
        Bora! {I.arrow({ size:20 })}
      </button>
    </div>
  </Screen>
);

// Onboarding step 2: connect or manual
const ScreenOnboardingConnect = () => (
  <Screen bg="#fff" label="04 Conectar">
    <div style={{padding:'8px 24px 0', display:'flex', alignItems:'center', justifyContent:'space-between'}}>
      <button style={{background:'none', border:0, padding:0, color: KITAMO.ink, cursor:'pointer'}}>{I.back({size:24})}</button>
      <div style={{display:'flex', gap:6}}>
        {[1,1,0].map((on,i) => <div key={i} style={{
          width: on && i===1 ?22:8, height:8, borderRadius:4,
          background: i<=1 ? KITAMO.brand : KITAMO.line,
        }}/>)}
      </div>
      <span style={{opacity:0}}>...</span>
    </div>
    <div style={{padding:'24px 24px 0'}}>
      <div style={{fontSize:28, fontWeight:800, letterSpacing:-0.5, lineHeight:1.15}}>Como você quer<br/>começar?</div>
      <div style={{fontSize:15, color: KITAMO.ink2, marginTop:10}}>Escolhe um jeito. Dá pra mudar depois.</div>

      <div style={{marginTop:22, padding:20, borderRadius:18, background: KITAMO.brand,
        color:'#fff', position:'relative', overflow:'hidden',
      }}>
        <div style={{position:'absolute', top:14, right:14, padding:'4px 10px',
          background:'rgba(255,255,255,0.22)', borderRadius:20, fontSize:11, fontWeight:700}}>
          Mais rápido
        </div>
        <div style={{width:46, height:46, borderRadius:14, background:'rgba(255,255,255,0.18)',
          display:'flex', alignItems:'center', justifyContent:'center'}}>
          {I.bolt({size:24, stroke:'#fff'})}
        </div>
        <div style={{fontSize:20, fontWeight:800, marginTop:14}}>Conectar meu banco</div>
        <div style={{fontSize:14, opacity:0.92, marginTop:6, lineHeight:1.4}}>
          A gente puxa tudo automaticamente. Seguro, autorizado pelo Banco Central.
        </div>
        <div style={{display:'flex', alignItems:'center', gap:8, marginTop:14, fontSize:12, opacity:0.85}}>
          {I.lock({size:14})} <span>Open Finance · BACEN</span>
        </div>
      </div>

      <div style={{marginTop:14, padding:20, borderRadius:18, border:`1.5px solid ${KITAMO.line}`,
        background:'#fff'}}>
        <div style={{width:46, height:46, borderRadius:14, background: KITAMO.brandSoft,
          display:'flex', alignItems:'center', justifyContent:'center', color: KITAMO.brandDark}}>
          {I.imp({size:24})}
        </div>
        <div style={{fontSize:20, fontWeight:800, marginTop:14, color: KITAMO.ink}}>Lançar manual</div>
        <div style={{fontSize:14, color: KITAMO.ink2, marginTop:6, lineHeight:1.4}}>
          Você adiciona suas contas e gastos do seu jeito.
        </div>
      </div>

      <div style={{textAlign:'center', marginTop:18}}>
        <a style={{fontSize:14, color: KITAMO.muted}}>Ainda não sei, depois eu vejo</a>
      </div>
    </div>
  </Screen>
);

// ─── 4. HOME ───────────────────────────────────────────────
const ScreenHome = ({ active = 'home', onTab }) => (
  <Screen bg={KITAMO.bg} light label="05 Início">
    {/* teal top */}
    <div style={{
      position:'absolute', top:0, left:0, right:0, height: 290,
      background:`linear-gradient(180deg, ${KITAMO.brand} 0%, #2BC0B1 100%)`,
      borderBottomLeftRadius:28, borderBottomRightRadius:28,
    }}/>
    <div style={{position:'relative', padding:'4px 22px 0', color:'#fff'}}>
      <div style={{display:'flex', alignItems:'center', justifyContent:'space-between', marginTop:6}}>
        <div style={{display:'flex', alignItems:'center', gap:12}}>
          <div style={{width:42, height:42, borderRadius:21,
            background:'rgba(255,255,255,0.25)', display:'flex',
            alignItems:'center', justifyContent:'center', fontWeight:800, fontSize:16}}>
            M
          </div>
          <div>
            <div style={{fontSize:13, opacity:0.85}}>Boa noite</div>
            <div style={{fontSize:18, fontWeight:700}}>Oi, Maria!</div>
          </div>
        </div>
        <button style={{width:42, height:42, borderRadius:21, border:0,
          background:'rgba(255,255,255,0.2)', color:'#fff', cursor:'pointer',
          display:'flex', alignItems:'center', justifyContent:'center', position:'relative'}} data-nav="notif">
          {I.bell({size:20})}
          <div style={{position:'absolute', top:10, right:10, width:8, height:8,
            background: KITAMO.warn, borderRadius:4, border:'2px solid #2BC0B1'}}/>
        </button>
      </div>

      <div style={{marginTop:22, display:'flex', alignItems:'center', gap:8, fontSize:13, opacity:0.9}}>
        Seu dinheiro hoje
        <span style={{cursor:'pointer'}}>{I.eye({size:16})}</span>
      </div>
      <div style={{fontSize:42, fontWeight:800, letterSpacing:-1.2, marginTop:4, fontVariantNumeric:'tabular-nums'}}>
        <span style={{fontSize:24, fontWeight:600, opacity:0.85, marginRight:4}}>R$</span>1.847<span style={{opacity:0.7}}>,30</span>
      </div>
      <div style={{fontSize:13, opacity:0.85, marginTop:2}}>Somando todas as suas contas</div>
    </div>

    {/* projection card */}
    <div style={{
      position:'relative', margin:'24px 16px 0', padding:18,
      background:'#fff', borderRadius:20,
      boxShadow:'0 8px 28px rgba(15,23,42,0.08), 0 1px 3px rgba(15,23,42,0.04)',
    }}>
      <div style={{display:'flex', alignItems:'flex-start', justifyContent:'space-between'}}>
        <div>
          <div style={{fontSize:13, color: KITAMO.muted, fontWeight:600}}>O dinheiro fecha o mês?</div>
          <div style={{display:'flex', alignItems:'center', gap:8, marginTop:6}}>
            <div style={{fontSize:22, fontWeight:800, color: KITAMO.success}}>Fecha, com folga</div>
            <span style={{fontSize:22}}>👍</span>
          </div>
          <div style={{fontSize:13, color: KITAMO.ink2, marginTop:4}}>Sobra estimada: <b style={{color: KITAMO.ink}}>R$ 312</b></div>
        </div>
      </div>
      <ProjectionChart />
      <div style={{display:'flex', alignItems:'center', justifyContent:'space-between', marginTop:6}}>
        <div style={{fontSize:11, color: KITAMO.muted}}>Hoje · 8 mai</div>
        <div style={{fontSize:11, color: KITAMO.muted}}>Fim do mês · 31 mai</div>
      </div>
      <a style={{display:'flex', alignItems:'center', gap:6, fontSize:14, color: KITAMO.brandDark,
        fontWeight:700, marginTop:12}}>Ver detalhes da projeção {I.arrow({size:14})}</a>
    </div>

    <div style={{padding:'22px 16px 120px'}}>
      {/* shortcuts */}
      <div style={{display:'grid', gridTemplateColumns:'repeat(4,1fr)', gap:10}}>
        <Shortcut color={KITAMO.danger} bg="#FEE2E2" icon={I.send} label="Lançar gasto"/>
        <Shortcut color={KITAMO.success} bg="#D1FAE5" icon={I.recv} label="Lançar entrada"/>
        <Shortcut color={KITAMO.info} bg="#DBEAFE" icon={I.bolt} label="Pagar conta"/>
        <Shortcut color={KITAMO.muted} bg="#F1F5F9" icon={I.tag} label="Ver tudo"/>
      </div>

      {/* my accounts */}
      <SectionHeader title="Minhas contas" link="Ver todas →"/>
      <div style={{background:'#fff', borderRadius:18, padding:'4px 16px',
        boxShadow:'0 2px 8px rgba(15,23,42,0.04)'}}>
        <AccountRow color="#8A05BE" name="Nubank" sub="Conta · Conectado" amount="1.230,00"/>
        <AccountRow color="#EC7000" name="Itaú" sub="Conta poupança" amount="450,30"/>
        <AccountRow color="#11C76F" name="PicPay" sub="Carteira" amount="167,00" last/>
      </div>

      {/* upcoming bills */}
      <SectionHeader title="Próximas contas" link="Ver tudo →"/>
      <div style={{background:'#fff', borderRadius:18, padding:'4px 16px',
        boxShadow:'0 2px 8px rgba(15,23,42,0.04)'}}>
        <BillRow icon={I.bolt} color={KITAMO.warn} name="Conta de luz" date="vence dia 15" amount="180,00" tag="warn"/>
        <BillRow icon={I.house} color={KITAMO.info} name="Aluguel" date="vence dia 20" amount="950,00" tag="ok"/>
        <BillRow icon={I.card} color={KITAMO.danger} name="Fatura Nubank" date="atrasada · 2 dias" amount="320,00" tag="late" last/>
      </div>

      {/* tip */}
      <div style={{marginTop:18, padding:16, borderRadius:18,
        background: KITAMO.brandSoft, display:'flex', gap:14, alignItems:'flex-start'}}>
        <div style={{width:42, height:42, borderRadius:21, background:'#fff',
          display:'flex', alignItems:'center', justifyContent:'center', color: KITAMO.brandDark, flexShrink:0}}>
          {I.bulb({size:22})}
        </div>
        <div style={{flex:1}}>
          <div style={{fontSize:14, fontWeight:700, color: KITAMO.ink}}>Dica da Kit</div>
          <div style={{fontSize:14, color: KITAMO.ink2, marginTop:3, lineHeight:1.45}}>
            Você gastou <b style={{color: KITAMO.ink}}>R$ 340</b> em comida fora esse mês — uns R$ 80 a mais que o normal.
          </div>
          <a style={{fontSize:13, color: KITAMO.brandDark, fontWeight:700, marginTop:8, display:'inline-block'}}>Ver mais dicas →</a>
        </div>
      </div>
    </div>

    {/* premium chat shortcut */}
    <button data-nav="ia-chat" style={{
      position:'absolute', right:16, bottom:108,
      height:46, padding:'0 14px 0 6px', borderRadius:23, border:0,
      background:'#fff', color: KITAMO.brandDark, cursor:'pointer',
      display:'flex', alignItems:'center', gap:8, fontSize:13, fontWeight:700,
      boxShadow:'0 8px 24px rgba(15,23,42,0.18)',
    }}>
      <span style={{width:34, height:34, borderRadius:17,
        background:`linear-gradient(135deg, ${KITAMO.brand}, #2BC0B1)`,
        color:'#fff', display:'flex', alignItems:'center', justifyContent:'center'}}>
        {I.bot({size:18})}
      </span>
      Pergunta pra Kit
    </button>

    <TabBar active={active} onTab={onTab}/>
  </Screen>
);

const Shortcut = ({ color, bg, icon, label }) => (
  <button style={{
    background:'#fff', border:0, padding:'14px 6px 10px', borderRadius:16,
    cursor:'pointer', display:'flex', flexDirection:'column', alignItems:'center', gap:8,
    boxShadow:'0 2px 8px rgba(15,23,42,0.04)',
  }}>
    <div style={{width:42, height:42, borderRadius:14, background: bg, color,
      display:'flex', alignItems:'center', justifyContent:'center'}}>
      {icon({size:22})}
    </div>
    <span style={{fontSize:11, fontWeight:600, color: KITAMO.ink, textAlign:'center', lineHeight:1.2}}>{label}</span>
  </button>
);

const SectionHeader = ({ title, link }) => (
  <div style={{display:'flex', alignItems:'center', justifyContent:'space-between',
    margin:'24px 4px 12px'}}>
    <div style={{fontSize:17, fontWeight:800, color: KITAMO.ink, letterSpacing:-0.3}}>{title}</div>
    {link && <a style={{fontSize:13, color: KITAMO.brandDark, fontWeight:700}}>{link}</a>}
  </div>
);

const AccountRow = ({ color, name, sub, amount, last }) => (
  <div style={{display:'flex', alignItems:'center', gap:12, padding:'14px 0',
    borderBottom: last ? 'none' : `1px solid ${KITAMO.line2}`}}>
    <BankAvatar name={name} color={color}/>
    <div style={{flex:1, minWidth:0}}>
      <div style={{fontSize:15, fontWeight:700, color: KITAMO.ink}}>{name}</div>
      <div style={{fontSize:12, color: KITAMO.muted, marginTop:1}}>{sub}</div>
    </div>
    <div style={{fontSize:16, fontWeight:700, color: KITAMO.ink, fontVariantNumeric:'tabular-nums'}}>R$ {amount}</div>
  </div>
);

const BillRow = ({ icon, color, name, date, amount, tag, last }) => {
  const tagStyles = {
    warn: { bg:'#FEF3C7', fg: KITAMO.warn, label:'Próxima' },
    ok:   { bg:'#F1F5F9', fg: KITAMO.muted, label:'Em dia' },
    late: { bg:'#FEE2E2', fg: KITAMO.danger, label:'Atrasada' },
  }[tag];
  return (
    <div style={{display:'flex', alignItems:'center', gap:12, padding:'14px 0',
      borderBottom: last ? 'none' : `1px solid ${KITAMO.line2}`}}>
      <CatIcon icon={icon} color={color} size={40}/>
      <div style={{flex:1, minWidth:0}}>
        <div style={{fontSize:15, fontWeight:700, color: KITAMO.ink}}>{name}</div>
        <div style={{fontSize:12, color: KITAMO.muted, marginTop:1}}>{date}</div>
      </div>
      <div style={{textAlign:'right'}}>
        <div style={{fontSize:15, fontWeight:700, color: KITAMO.ink, fontVariantNumeric:'tabular-nums'}}>R$ {amount}</div>
        <div style={{
          display:'inline-block', marginTop:3,
          padding:'2px 8px', borderRadius:8, fontSize:10, fontWeight:700,
          background: tagStyles.bg, color: tagStyles.fg,
        }}>{tagStyles.label}</div>
      </div>
    </div>
  );
};

const ProjectionChart = () => (
  <div style={{height:80, marginTop:14, position:'relative'}}>
    <svg viewBox="0 0 320 80" width="100%" height="100%" preserveAspectRatio="none">
      <defs>
        <linearGradient id="projGrad" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor={KITAMO.brand} stopOpacity="0.3"/>
          <stop offset="100%" stopColor={KITAMO.brand} stopOpacity="0"/>
        </linearGradient>
      </defs>
      <line x1="0" y1="58" x2="320" y2="58" stroke={KITAMO.line} strokeWidth="1" strokeDasharray="4 4"/>
      <text x="2" y="55" fontSize="9" fill={KITAMO.muted}>R$ 0</text>
      <path d="M0,40 C40,38 60,30 90,28 C120,26 140,42 170,38 C200,34 220,20 250,18 C280,16 300,22 320,15 L320,80 L0,80 Z"
        fill="url(#projGrad)"/>
      <path d="M0,40 C40,38 60,30 90,28 C120,26 140,42 170,38 C200,34 220,20 250,18 C280,16 300,22 320,15"
        stroke={KITAMO.brand} strokeWidth="2.5" fill="none" strokeLinecap="round"/>
      <circle cx="0" cy="40" r="4" fill="#fff" stroke={KITAMO.brand} strokeWidth="2"/>
      <circle cx="320" cy="15" r="5" fill={KITAMO.brand}/>
      <circle cx="320" cy="15" r="9" fill={KITAMO.brand} opacity="0.2"/>
    </svg>
  </div>
);

Object.assign(window, {
  ScreenSplash, ScreenLogin, ScreenOnboarding, ScreenOnboardingConnect, ScreenHome,
  KitamoLogo, Input, Shortcut, SectionHeader, AccountRow, BillRow, ProjectionChart,
});
