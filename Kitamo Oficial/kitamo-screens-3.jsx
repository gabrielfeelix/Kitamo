// Kitamo Screens 9-11: Eu (Profile), Kitamo IA, Plans + extras

// ─── 9. EU (PROFILE) ───────────────────────────────────────
const ScreenEu = ({ active = 'eu', onTab }) => (
  <Screen bg={KITAMO.bg} label="10 Eu">
    {/* teal top */}
    <div style={{
      position:'absolute', top:0, left:0, right:0, height:200,
      background: KITAMO.brand,
      borderBottomLeftRadius:28, borderBottomRightRadius:28,
    }}/>
    <div style={{position:'relative', padding:'12px 22px 0', color:'#fff'}}>
      <div style={{fontSize:13, opacity:0.9, fontWeight:600}}>Perfil</div>
      <div style={{display:'flex', alignItems:'center', gap:14, marginTop:14}}>
        <div style={{width:64, height:64, borderRadius:32, background:'#fff',
          color: KITAMO.brandDark, display:'flex', alignItems:'center', justifyContent:'center',
          fontSize:28, fontWeight:800, boxShadow:'0 4px 12px rgba(0,0,0,0.12)'}}>M</div>
        <div style={{flex:1}}>
          <div style={{fontSize:20, fontWeight:800, letterSpacing:-0.4}}>Maria Silva</div>
          <div style={{fontSize:13, opacity:0.9, marginTop:2}}>maria.silva@gmail.com</div>
          <div style={{display:'inline-flex', alignItems:'center', gap:6, marginTop:6,
            padding:'3px 8px', borderRadius:10, background:'rgba(255,255,255,0.22)',
            fontSize:11, fontWeight:700}}>
            <span>★</span> Plano Grátis
          </div>
        </div>
      </div>
    </div>

    <div style={{padding:'24px 16px 120px', position:'relative'}}>
      {/* Premium upsell card */}
      <div style={{padding:18, borderRadius:18, background:'#fff',
        boxShadow:'0 8px 24px rgba(15,23,42,0.08)', position:'relative', overflow:'hidden'}}>
        <div style={{position:'absolute', right:-30, top:-30, width:120, height:120, borderRadius:60,
          background: KITAMO.brandSoft, opacity:0.6}}/>
        <div style={{position:'relative', display:'flex', gap:14, alignItems:'flex-start'}}>
          <div style={{width:48, height:48, borderRadius:24, background: KITAMO.brand,
            display:'flex', alignItems:'center', justifyContent:'center', color:'#fff', flexShrink:0}}>
            {I.bot({size:24})}
          </div>
          <div style={{flex:1}}>
            <div style={{fontSize:16, fontWeight:800, color: KITAMO.ink}}>Quer um ajudante de finanças?</div>
            <div style={{fontSize:13, color: KITAMO.ink2, marginTop:4, lineHeight:1.45}}>
              A <b style={{color: KITAMO.brandDark}}>Kitamo IA</b> olha seus gastos e te dá dicas práticas todo dia.
            </div>
          </div>
        </div>
        <button style={{
          width:'100%', height:46, marginTop:14, border:0, borderRadius:12,
          background: KITAMO.brand, color:'#fff', fontWeight:700, fontSize:14, cursor:'pointer',
          boxShadow:'0 4px 12px rgba(51,214,197,0.35)',
         }} data-nav="planos">Conhecer Kitamo+</button>
      </div>

      {/* menu */}
      <div style={{marginTop:20, background:'#fff', borderRadius:18, overflow:'hidden',
        boxShadow:'0 2px 8px rgba(15,23,42,0.04)'}}>
        <MenuRow icon={I.bot} color={KITAMO.brand} label="Kitamo IA" trail={<Pro/>} route="ia"/>
        <MenuRow icon={I.tag} color="#8B5CF6" label="Categorias" sub="Gerenciar suas categorias" route="categorias"/>
        <MenuRow icon={I.target} color={KITAMO.warn} label="Metas" sub="3 metas ativas" route="metas"/>
        <MenuRow icon={I.bell} color={KITAMO.info} label="Notificações" route="notif"/>
        <MenuRow icon={I.lock} color={KITAMO.ink} label="Segurança" sub="Senha e biometria" route="seguranca"/>
        <MenuRow icon={I.card} color={KITAMO.success} label="Meu Plano" route="planos" trail={<span style={{
          fontSize:11, fontWeight:700, color: KITAMO.muted}}>Grátis</span>}/>
      </div>

      <div style={{marginTop:14, background:'#fff', borderRadius:18, overflow:'hidden',
        boxShadow:'0 2px 8px rgba(15,23,42,0.04)'}}>
        <MenuRow icon={I.imp} color={KITAMO.muted} label="Importar dados"/>
        <MenuRow icon={I.exp} color={KITAMO.muted} label="Exportar dados"/>
        <MenuRow icon={I.help} color={KITAMO.muted} label="Ajuda"/>
        <MenuRow icon={I.info} color={KITAMO.muted} label="Sobre o Kitamo" last/>
      </div>

      <button style={{
        width:'100%', padding:16, marginTop:18, background:'transparent',
        border:0, color: KITAMO.danger, fontSize:15, fontWeight:700, cursor:'pointer',
      }}>Sair</button>

      <div style={{textAlign:'center', fontSize:11, color: KITAMO.muted, marginTop:6}}>
        Kitamo · v2.4.1
      </div>
    </div>
    <TabBar active={active} onTab={onTab}/>
  </Screen>
);

const Pro = () => (
  <span style={{
    padding:'2px 8px', borderRadius:8, background: KITAMO.brand,
    color:'#fff', fontSize:10, fontWeight:800, letterSpacing:0.3,
  }}>KITAMO+</span>
);

const MenuRow = ({ icon, color, label, sub, trail, last, route }) => (
  <div data-nav={route} style={{display:'flex', alignItems:'center', gap:14, padding:'14px 16px',
    cursor: route?'pointer':'default',
    borderBottom: last?'none':`1px solid ${KITAMO.line2}`}}>
    <div style={{width:36, height:36, borderRadius:10, background: color+'15', color,
      display:'flex', alignItems:'center', justifyContent:'center'}}>
      {icon({size:20})}
    </div>
    <div style={{flex:1}}>
      <div style={{fontSize:15, fontWeight:700, color: KITAMO.ink}}>{label}</div>
      {sub && <div style={{fontSize:12, color: KITAMO.muted, marginTop:1}}>{sub}</div>}
    </div>
    {trail || <span style={{color: KITAMO.line}}>{I.arrow({size:16})}</span>}
  </div>
);

// ─── 10. KITAMO IA ─────────────────────────────────────────
const ScreenIA = ({ active = 'eu', onTab }) => (
  <Screen bg={KITAMO.bg} label="11 Kitamo IA">
    {/* teal top */}
    <div style={{
      position:'absolute', top:0, left:0, right:0, height:230,
      background:`linear-gradient(180deg, ${KITAMO.brand} 0%, #2BC0B1 100%)`,
      borderBottomLeftRadius:28, borderBottomRightRadius:28,
    }}/>
    <div style={{position:'relative', padding:'8px 16px 0', color:'#fff'}}>
      <div style={{display:'flex', alignItems:'center', gap:8}}>
        <button style={{background:'rgba(255,255,255,0.2)', border:0, width:36, height:36, borderRadius:18,
          color:'#fff', cursor:'pointer', display:'flex', alignItems:'center', justifyContent:'center'}}>
          {I.back({size:18})}
        </button>
        <div style={{fontSize:15, fontWeight:700, flex:1, textAlign:'center'}}>Kitamo IA</div>
        <div style={{width:36}}/>
      </div>

      <div style={{padding:'24px 8px 0', display:'flex', alignItems:'center', gap:14}}>
        <div style={{width:60, height:60, borderRadius:30, background:'#fff',
          color: KITAMO.brandDark, display:'flex', alignItems:'center', justifyContent:'center',
          boxShadow:'0 4px 12px rgba(0,0,0,0.12)'}}>
          {I.bot({size:32})}
        </div>
        <div>
          <div style={{fontSize:20, fontWeight:800, letterSpacing:-0.4}}>Oi! Eu sou a Kit 🤟</div>
          <div style={{fontSize:13, opacity:0.9, marginTop:2}}>Sua ajudante de finanças</div>
        </div>
      </div>
    </div>

    {/* tabs */}
    <div style={{position:'relative', display:'flex', gap:6, padding:'18px 16px 0', zIndex:2}}>
      {[['Minhas dicas',true,null],['Conversar',false,'ia-chat']].map(([l,on,r])=>(
        <span key={l} data-nav={r||undefined} style={{
          padding:'8px 14px', borderRadius:14, fontSize:13, fontWeight:700,
          background: on ? '#fff' : 'rgba(255,255,255,0.25)',
          color: on ? KITAMO.brandDark : '#fff',
          boxShadow: on?'0 4px 12px rgba(0,0,0,0.08)':'none',
        }}>{l}</span>
      ))}
    </div>

    {/* insights */}
    <div style={{padding:'16px 16px 120px', position:'relative'}}>
      <div style={{fontSize:11, color: KITAMO.muted, fontWeight:700, letterSpacing:0.5, padding:'4px 4px 10px'}}>
        DICAS DE HOJE
      </div>
      <Insight color={KITAMO.warn} icon={I.bulb} title="Tá gastando mais com iFood"
        body="Você gastou 30% mais com iFood que mês passado. Quer colocar um limite de R$ 200?"
        action="Definir limite"/>
      <Insight color={KITAMO.success} icon={I.spark} title="Sobrou da semana 🎉"
        body="Sobrou R$ 200 do mercado essa semana. Que tal guardar pra fatura do cartão?"
        action="Guardar agora"/>
      <Insight color={KITAMO.danger} icon={I.bolt} title="Conta de luz subiu"
        body="Sua conta de luz veio R$ 50 mais cara que o mês passado. Confere se tá certo."
        action="Ver detalhes"/>

      <div style={{fontSize:11, color: KITAMO.muted, fontWeight:700, letterSpacing:0.5, padding:'18px 4px 10px'}}>
        PERGUNTAR PRA KIT
      </div>
      <div style={{display:'flex', gap:8, flexWrap:'wrap'}}>
        {['Quanto posso gastar hoje?','Tô no vermelho?','Como economizar mais?'].map(q => (
          <span key={q} style={{
            padding:'8px 12px', borderRadius:14, fontSize:12, fontWeight:600,
            background:'#fff', color: KITAMO.ink2,
            boxShadow:'0 1px 3px rgba(15,23,42,0.05)',
            border:`1px solid ${KITAMO.line}`,
          }}>{q}</span>
        ))}
      </div>
    </div>

    {/* chat input pinned */}
    <div style={{position:'absolute', left:16, right:16, bottom: 100,
      padding:'10px 14px', background:'#fff', borderRadius:24,
      display:'flex', alignItems:'center', gap:10, cursor:'pointer',
      boxShadow:'0 8px 24px rgba(15,23,42,0.10)', border:`1px solid ${KITAMO.line}`}} data-nav="ia-chat">
      <span style={{color: KITAMO.muted, fontSize:14}}>Pergunta pra Kit...</span>
      <div style={{flex:1}}/>
      <button style={{width:36, height:36, borderRadius:18, border:0,
        background: KITAMO.brand, color:'#fff', cursor:'pointer',
        display:'flex', alignItems:'center', justifyContent:'center'}}>
        {I.send({size:16})}
      </button>
    </div>

    <TabBar active={active} onTab={onTab}/>
  </Screen>
);

const Insight = ({ color, icon, title, body, action }) => (
  <div style={{padding:16, background:'#fff', borderRadius:18, marginBottom:10,
    boxShadow:'0 2px 8px rgba(15,23,42,0.05)',
    borderLeft:`3px solid ${color}`}}>
    <div style={{display:'flex', gap:12, alignItems:'flex-start'}}>
      <div style={{width:36, height:36, borderRadius:10, background: color+'15', color,
        display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0}}>
        {icon({size:18})}
      </div>
      <div style={{flex:1}}>
        <div style={{fontSize:14, fontWeight:800, color: KITAMO.ink}}>{title}</div>
        <div style={{fontSize:13, color: KITAMO.ink2, marginTop:4, lineHeight:1.45}}>{body}</div>
        <a style={{display:'inline-block', marginTop:10, fontSize:13, fontWeight:700,
          color: KITAMO.brandDark}}>{action} →</a>
      </div>
    </div>
  </div>
);

// ─── 11. PLANS ─────────────────────────────────────────────
const ScreenPlanos = () => (
  <Screen bg={KITAMO.bg} label="12 Planos">
    <div style={{padding:'8px 16px 0', display:'flex', alignItems:'center'}}>
      <button style={{background:'#fff', border:0, width:36, height:36, borderRadius:18, cursor:'pointer',
        display:'flex', alignItems:'center', justifyContent:'center', color: KITAMO.ink,
        boxShadow:'0 1px 3px rgba(15,23,42,0.05)'}}>
        {I.back({size:18})}
      </button>
    </div>

    <div style={{padding:'18px 22px 0'}}>
      <div style={{fontSize:30, fontWeight:800, letterSpacing:-0.6, lineHeight:1.1}}>
        Escolhe o teu<br/>plano
      </div>
      <div style={{fontSize:14, color: KITAMO.ink2, marginTop:8}}>
        Sem pegadinha, cancela quando quiser.
      </div>
    </div>

    <div style={{padding:'22px 16px 120px'}}>
      {/* free */}
      <div style={{padding:20, background:'#fff', borderRadius:20, marginBottom:14,
        boxShadow:'0 2px 8px rgba(15,23,42,0.04)'}}>
        <div style={{display:'flex', alignItems:'baseline', justifyContent:'space-between'}}>
          <div style={{fontSize:18, fontWeight:800, color: KITAMO.ink}}>Kitamo Grátis</div>
          <div style={{fontSize:24, fontWeight:800, color: KITAMO.ink}}>R$ 0</div>
        </div>
        <div style={{fontSize:13, color: KITAMO.muted, marginTop:4}}>O básico pra organizar a grana</div>
        <div style={{marginTop:14}}>
          <Bullet ok>Lançar gastos manuais</Bullet>
          <Bullet ok>Conectar 1 banco</Bullet>
          <Bullet ok>Ver projeção do mês</Bullet>
          <Bullet ok>Categorias básicas</Bullet>
          <Bullet>Sem Kitamo IA</Bullet>
        </div>
        <button style={{
          width:'100%', height:48, marginTop:14, border:`1.5px solid ${KITAMO.line}`, borderRadius:12,
          background:'#fff', color: KITAMO.ink, fontSize:14, fontWeight:700, cursor:'pointer',
        }}>Continuar grátis</button>
      </div>

      {/* premium */}
      <div style={{padding:20, background:'#fff', borderRadius:20, position:'relative',
        border:`2px solid ${KITAMO.brand}`,
        boxShadow:'0 12px 32px rgba(51,214,197,0.18)'}}>
        <div style={{
          position:'absolute', top:-12, left:20, padding:'5px 12px', borderRadius:10,
          background: KITAMO.brand, color:'#fff', fontSize:11, fontWeight:800, letterSpacing:0.5,
        }}>MAIS ESCOLHIDO</div>

        <div style={{display:'flex', alignItems:'baseline', justifyContent:'space-between', marginTop:6}}>
          <div style={{display:'flex', alignItems:'center', gap:8}}>
            <div style={{fontSize:20, fontWeight:800, color: KITAMO.ink}}>Kitamo+</div>
            {I.spark({size:18, stroke: KITAMO.brand})}
          </div>
          <div>
            <span style={{fontSize:24, fontWeight:800, color: KITAMO.ink}}>R$ 9,90</span>
            <span style={{fontSize:13, color: KITAMO.muted}}>/mês</span>
          </div>
        </div>
        <div style={{fontSize:13, color: KITAMO.muted, marginTop:4}}>Tudo do grátis +</div>
        <div style={{marginTop:14}}>
          <Bullet ok bold>Kitamo IA todo dia te ajudando</Bullet>
          <Bullet ok>Conectar bancos ilimitados</Bullet>
          <Bullet ok>Importar fatura por foto</Bullet>
          <Bullet ok>Metas e simulações</Bullet>
          <Bullet ok>Suporte rápido por WhatsApp</Bullet>
        </div>
        <button style={{
          width:'100%', height:52, marginTop:18, border:0, borderRadius:12,
          background: KITAMO.brand, color:'#fff', fontSize:15, fontWeight:800, cursor:'pointer',
          boxShadow:'0 6px 16px rgba(51,214,197,0.4)',
        }}>Começar grátis 7 dias</button>
        <div style={{textAlign:'center', fontSize:11, color: KITAMO.muted, marginTop:8}}>
          Cancela quando quiser, sem pegadinha
        </div>
      </div>
    </div>
  </Screen>
);

const Bullet = ({ children, ok, bold }) => (
  <div style={{display:'flex', alignItems:'center', gap:10, padding:'7px 0',
    fontSize: bold ? 14 : 14, fontWeight: bold ? 700 : 500,
    color: ok ? KITAMO.ink : KITAMO.muted}}>
    <div style={{width:20, height:20, borderRadius:10, flexShrink:0,
      background: ok ? KITAMO.brandSoft : KITAMO.line2,
      color: ok ? KITAMO.brandDark : KITAMO.muted,
      display:'flex', alignItems:'center', justifyContent:'center'}}>
      {ok ? I.check({size:12}) : I.close({size:12})}
    </div>
    {children}
  </div>
);

// ─── EXTRA: empty state, error, loading ─────────────────────
const ScreenEmpty = ({ active = 'gastos', onTab }) => (
  <Screen bg={KITAMO.bg} label="13 Estado vazio">
    <div style={{padding:'8px 22px 0'}}>
      <div style={{fontSize:26, fontWeight:800, letterSpacing:-0.6}}>Gastos</div>
    </div>
    <div style={{padding:'80px 32px 0', textAlign:'center'}}>
      <svg width="180" height="160" viewBox="0 0 200 160" style={{margin:'0 auto'}}>
        <ellipse cx="100" cy="135" rx="65" ry="8" fill={KITAMO.line2}/>
        <path d="M55 130 V70 a8 8 0 0 1 8 -8 h74 a8 8 0 0 1 8 8 v60 z"
          fill="#fff" stroke={KITAMO.brand} strokeWidth="2.5"/>
        <path d="M55 70 a8 8 0 0 1 8 -8 h74 a8 8 0 0 1 8 8 v8 H55z" fill={KITAMO.brandSoft} stroke={KITAMO.brand} strokeWidth="2.5"/>
        <circle cx="100" cy="100" r="14" fill="none" stroke={KITAMO.brandDark} strokeWidth="2.5"/>
        <path d="M93 100h14M100 93v14" stroke={KITAMO.brandDark} strokeWidth="2.5" strokeLinecap="round"/>
        <circle cx="160" cy="50" r="5" fill={KITAMO.warn}/>
        <circle cx="40" cy="90" r="4" fill={KITAMO.brand}/>
      </svg>
      <div style={{fontSize:22, fontWeight:800, marginTop:18, letterSpacing:-0.3}}>Cadê a grana?</div>
      <div style={{fontSize:14, color: KITAMO.ink2, marginTop:10, lineHeight:1.5}}>
        Bora começar lançando seu primeiro gasto. Em 10 segundos a Maria já tá entendendo pra onde vai a grana.
      </div>
      <button style={{
        marginTop:24, height:52, padding:'0 28px', border:0, borderRadius:14,
        background: KITAMO.brand, color:'#fff', fontSize:15, fontWeight:700, cursor:'pointer',
        boxShadow:'0 6px 16px rgba(51,214,197,0.35)',
      }}>Lançar agora</button>
    </div>
    <TabBar active={active} onTab={onTab}/>
  </Screen>
);

Object.assign(window, { ScreenEu, ScreenIA, ScreenPlanos, ScreenEmpty });
