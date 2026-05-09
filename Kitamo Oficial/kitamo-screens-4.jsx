// Kitamo Screens 12-17: IA Chat, Notifications, Categorias, Metas, Segurança, Add Investment

// ─── 12. KITAMO IA — CHAT VIEW ─────────────────────────────
const ScreenIAChat = ({ active = 'eu', onTab }) => (
  <Screen bg={KITAMO.bg} label="13 Kit Chat">
    {/* compact teal header */}
    <div style={{
      background:`linear-gradient(180deg, ${KITAMO.brand} 0%, #2BC0B1 100%)`,
      padding:'8px 16px 14px', color:'#fff',
      borderBottomLeftRadius:20, borderBottomRightRadius:20,
    }}>
      <div style={{display:'flex', alignItems:'center', gap:10}}>
        <button data-back style={{background:'rgba(255,255,255,0.2)', border:0, width:34, height:34, borderRadius:17,
          color:'#fff', cursor:'pointer', display:'flex', alignItems:'center', justifyContent:'center'}}>
          {I.back({size:16})}
        </button>
        <div style={{width:38, height:38, borderRadius:19, background:'#fff',
          color: KITAMO.brandDark, display:'flex', alignItems:'center', justifyContent:'center'}}>
          {I.bot({size:20})}
        </div>
        <div style={{flex:1}}>
          <div style={{fontSize:15, fontWeight:800}}>Kit</div>
          <div style={{fontSize:11, opacity:0.85, display:'flex', alignItems:'center', gap:4}}>
            <span style={{width:6, height:6, borderRadius:3, background:'#5EEAD4', display:'inline-block'}}/>
            Online · responde em segundos
          </div>
        </div>
        <button style={{background:'rgba(255,255,255,0.2)', border:0, width:34, height:34, borderRadius:17,
          color:'#fff', cursor:'pointer', display:'flex', alignItems:'center', justifyContent:'center'}}>
          {I.dots({size:16})}
        </button>
      </div>
    </div>

    {/* chat messages */}
    <div style={{padding:'16px 14px 200px', display:'flex', flexDirection:'column', gap:10}}>
      <DayDivider label="HOJE · 8 mai"/>

      <KitMsg>Bom dia, Maria! Olhei aqui sua grana e tá tudo no eixo 👇</KitMsg>

      <KitCard>
        <div style={{fontSize:11, color: KITAMO.muted, fontWeight:700, letterSpacing:0.4}}>RESUMO DO DIA</div>
        <div style={{display:'flex', justifyContent:'space-between', marginTop:8}}>
          <div>
            <div style={{fontSize:11, color: KITAMO.muted}}>Pode gastar hoje</div>
            <div style={{fontSize:20, fontWeight:800, color: KITAMO.success, fontVariantNumeric:'tabular-nums'}}>R$ 62</div>
          </div>
          <div style={{width:1, background: KITAMO.line2}}/>
          <div>
            <div style={{fontSize:11, color: KITAMO.muted}}>Sobra do mês</div>
            <div style={{fontSize:20, fontWeight:800, color: KITAMO.brandDark, fontVariantNumeric:'tabular-nums'}}>R$ 230</div>
          </div>
        </div>
      </KitCard>

      <UserMsg>Posso pedir um iFood hoje?</UserMsg>

      <KitMsg>
        Pode sim, mas com cuidado. Você já gastou <b>R$ 312 com iFood esse mês</b> — uns R$ 80 a mais que a média.
      </KitMsg>

      <KitCard accent>
        <div style={{display:'flex', alignItems:'center', gap:10}}>
          <div style={{width:32, height:32, borderRadius:16, background: KITAMO.warn+'20',
            color: KITAMO.warn, display:'flex', alignItems:'center', justifyContent:'center'}}>
            {I.bulb({size:16})}
          </div>
          <div style={{flex:1}}>
            <div style={{fontSize:13, fontWeight:700, color: KITAMO.ink}}>Dica</div>
            <div style={{fontSize:12, color: KITAMO.ink2, marginTop:2}}>Define um teto de R$ 250/mês com iFood?</div>
          </div>
        </div>
        <div style={{display:'flex', gap:6, marginTop:10}}>
          <button style={{flex:1, padding:'8px', border:0, borderRadius:10,
            background: KITAMO.brand, color:'#fff', fontSize:12, fontWeight:700}}>Definir limite</button>
          <button style={{flex:1, padding:'8px', border:`1px solid ${KITAMO.line}`, borderRadius:10,
            background:'#fff', color: KITAMO.ink2, fontSize:12, fontWeight:700}}>Agora não</button>
        </div>
      </KitCard>

      <UserMsg>Beleza, define aí ✓</UserMsg>

      <KitMsg>
        Feito! Vou avisar quando passar de R$ 200 pra você não se assustar com a fatura. 🎯
      </KitMsg>

      {/* typing indicator */}
      <div style={{alignSelf:'flex-start', padding:'10px 14px', background:'#fff', borderRadius:16,
        borderTopLeftRadius:4, boxShadow:'0 1px 3px rgba(15,23,42,0.05)',
        display:'flex', gap:4}}>
        {[0,1,2].map(i => <span key={i} style={{
          width:6, height:6, borderRadius:3, background: KITAMO.muted, opacity: 0.3 + i*0.2
        }}/>)}
      </div>
    </div>

    {/* suggestion chips above input */}
    <div style={{position:'absolute', left:0, right:0, bottom:148,
      padding:'8px 14px', display:'flex', gap:6, overflowX:'auto'}}>
      {['Tô no vermelho?','Como economizar?','Onde gastei mais?'].map(q => (
        <span key={q} style={{
          padding:'7px 12px', borderRadius:14, fontSize:12, fontWeight:600,
          background:'#fff', color: KITAMO.ink2, flexShrink:0,
          border:`1px solid ${KITAMO.line}`, boxShadow:'0 1px 3px rgba(15,23,42,0.05)',
        }}>{q}</span>
      ))}
    </div>

    {/* input pinned */}
    <div style={{position:'absolute', left:14, right:14, bottom:96,
      padding:'8px 8px 8px 16px', background:'#fff', borderRadius:24,
      display:'flex', alignItems:'center', gap:8,
      boxShadow:'0 8px 24px rgba(15,23,42,0.10)', border:`1px solid ${KITAMO.line}`}}>
      <span style={{flex:1, fontSize:14, color: KITAMO.muted}}>Pergunta pra Kit...</span>
      <button style={{width:36, height:36, borderRadius:18, border:0,
        background: KITAMO.brand, color:'#fff', cursor:'pointer',
        display:'flex', alignItems:'center', justifyContent:'center'}}>
        {I.send({size:16})}
      </button>
    </div>

    <TabBar active={active} onTab={onTab}/>
  </Screen>
);

const DayDivider = ({ label }) => (
  <div style={{textAlign:'center', fontSize:10, color: KITAMO.muted, fontWeight:700,
    letterSpacing:0.5, padding:'6px 0'}}>{label}</div>
);

const KitMsg = ({ children }) => (
  <div style={{alignSelf:'flex-start', maxWidth:'82%',
    padding:'10px 14px', background:'#fff', color: KITAMO.ink,
    borderRadius:16, borderTopLeftRadius:4,
    fontSize:14, lineHeight:1.45, boxShadow:'0 1px 3px rgba(15,23,42,0.05)'}}>
    {children}
  </div>
);

const UserMsg = ({ children }) => (
  <div style={{alignSelf:'flex-end', maxWidth:'80%',
    padding:'10px 14px', background: KITAMO.brand, color:'#fff',
    borderRadius:16, borderTopRightRadius:4,
    fontSize:14, lineHeight:1.45, boxShadow:'0 1px 3px rgba(51,214,197,0.3)'}}>
    {children}
  </div>
);

const KitCard = ({ children, accent }) => (
  <div style={{alignSelf:'flex-start', maxWidth:'88%',
    padding:14, background:'#fff', borderRadius:16, borderTopLeftRadius:4,
    boxShadow:'0 2px 8px rgba(15,23,42,0.06)',
    borderLeft: accent ? `3px solid ${KITAMO.brand}` : 'none'}}>
    {children}
  </div>
);

// ─── 13. NOTIFICATIONS ─────────────────────────────────────
const ScreenNotif = ({ active = 'home', onTab }) => (
  <Screen bg={KITAMO.bg} label="14 Notificações">
    <div style={{padding:'8px 16px 0', display:'flex', alignItems:'center', gap:10}}>
      <button data-back style={{background:'#fff', border:0, width:36, height:36, borderRadius:18, cursor:'pointer',
        display:'flex', alignItems:'center', justifyContent:'center', color: KITAMO.ink,
        boxShadow:'0 1px 3px rgba(15,23,42,0.05)'}}>{I.back({size:18})}</button>
      <div style={{flex:1, fontSize:18, fontWeight:800, letterSpacing:-0.3}}>Avisos</div>
      <a style={{fontSize:12, color: KITAMO.brandDark, fontWeight:700}}>Marcar tudo</a>
    </div>

    {/* filter chips */}
    <div style={{display:'flex', gap:6, padding:'14px 16px 0', overflowX:'auto'}}>
      {[['Tudo',true,3],['Contas',false,2],['Kit IA',false,1],['Metas',false,0]].map(([l,on,n])=>(
        <span key={l} style={{
          padding:'7px 12px', borderRadius:18, fontSize:12, fontWeight:700, flexShrink:0,
          background: on ? KITAMO.ink : '#fff', color: on ? '#fff' : KITAMO.ink2,
          boxShadow: on?'none':'0 1px 3px rgba(15,23,42,0.05)',
          display:'flex', alignItems:'center', gap:5,
        }}>{l}{n>0 && <b style={{fontSize:10, padding:'1px 5px', borderRadius:6,
          background: on? 'rgba(255,255,255,0.2)' : KITAMO.brandSoft,
          color: on? '#fff' : KITAMO.brandDark}}>{n}</b>}</span>
      ))}
    </div>

    <div style={{padding:'14px 16px 120px'}}>
      <SectionLabel>HOJE</SectionLabel>

      <Notif unread color={KITAMO.danger} icon={I.bolt}
        title="Conta de luz vence amanhã"
        body="R$ 180,00 — toca pra pagar agora"
        time="agora"
        cta="Pagar"/>

      <Notif unread color={KITAMO.warn} icon={I.bulb}
        title="iFood passou do limite"
        body="Você já gastou R$ 215 dos R$ 250 que combinou com a Kit"
        time="11h32"/>

      <Notif unread color={KITAMO.success} icon={I.recv}
        title="Caiu salário no Itaú"
        body="+ R$ 3.000,00"
        time="08h14"/>

      <SectionLabel>ONTEM</SectionLabel>

      <Notif color={KITAMO.brandDark} icon={I.bot}
        title="Sua dica diária da Kit"
        body="Sobrou R$ 200 do mercado essa semana. Que tal guardar?"
        time="9h00"/>

      <Notif color={KITAMO.info} icon={I.swap}
        title="Nubank atualizado"
        body="3 transações novas sincronizadas"
        time="20h12"/>

      <SectionLabel>ESSA SEMANA</SectionLabel>

      <Notif color={KITAMO.muted} icon={I.target}
        title="Meta &quot;Viagem&quot; em 60%"
        body="Faltam R$ 800 pra completar — falta pouco!"
        time="seg"/>

      <Notif color={KITAMO.muted} icon={I.card}
        title="Fatura do PicPay fechou"
        body="R$ 134,00 — vence dia 12"
        time="dom"/>
    </div>

    <TabBar active={active} onTab={onTab}/>
  </Screen>
);

const SectionLabel = ({ children }) => (
  <div style={{fontSize:10, color: KITAMO.muted, fontWeight:700, letterSpacing:0.5,
    padding:'14px 4px 8px'}}>{children}</div>
);

const Notif = ({ unread, color, icon, title, body, time, cta }) => (
  <div style={{display:'flex', gap:12, padding:'12px 14px', background:'#fff',
    borderRadius:14, marginBottom:6, boxShadow:'0 1px 3px rgba(15,23,42,0.04)',
    position:'relative'}}>
    {unread && <div style={{position:'absolute', left:6, top:'50%', transform:'translateY(-50%)',
      width:6, height:6, borderRadius:3, background: KITAMO.brand}}/>}
    <div style={{width:36, height:36, borderRadius:10, background: color+'18', color,
      display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0}}>
      {icon({size:16})}
    </div>
    <div style={{flex:1, minWidth:0}}>
      <div style={{display:'flex', alignItems:'baseline', justifyContent:'space-between', gap:8}}>
        <div style={{fontSize:13, fontWeight: unread?800:700, color: KITAMO.ink}}>{title}</div>
        <div style={{fontSize:10, color: KITAMO.muted, fontWeight:600, flexShrink:0}}>{time}</div>
      </div>
      <div style={{fontSize:12, color: KITAMO.ink2, marginTop:2}}>{body}</div>
      {cta && <button style={{
        marginTop:8, padding:'6px 14px', border:0, borderRadius:10,
        background: KITAMO.brand, color:'#fff', fontSize:12, fontWeight:700, cursor:'pointer',
      }}>{cta}</button>}
    </div>
  </div>
);

// ─── 14. CATEGORIAS ────────────────────────────────────────
const ScreenCategorias = () => (
  <Screen bg={KITAMO.bg} label="15 Categorias">
    <div style={{padding:'8px 16px 0', display:'flex', alignItems:'center', gap:10}}>
      <button data-back style={{background:'#fff', border:0, width:36, height:36, borderRadius:18, cursor:'pointer',
        display:'flex', alignItems:'center', justifyContent:'center', color: KITAMO.ink,
        boxShadow:'0 1px 3px rgba(15,23,42,0.05)'}}>{I.back({size:18})}</button>
      <div style={{flex:1, fontSize:18, fontWeight:800}}>Categorias</div>
      <button style={{padding:'8px 12px', borderRadius:14, border:0,
        background: KITAMO.brand, color:'#fff', fontSize:12, fontWeight:700,
        display:'flex', alignItems:'center', gap:4, cursor:'pointer'}}>{I.plus({size:14})} Nova</button>
    </div>

    <div style={{padding:'14px 16px 0'}}>
      <div style={{display:'flex', gap:6}}>
        {[['Saídas',true],['Entradas',false]].map(([l,on])=>(
          <span key={l} style={{flex:1, textAlign:'center',
            padding:'8px 10px', borderRadius:12, fontSize:13, fontWeight:700,
            background: on ? '#fff' : 'transparent', color: on ? KITAMO.ink : KITAMO.muted,
            boxShadow: on?'0 1px 3px rgba(15,23,42,0.05)':'none',
          }}>{l}</span>
        ))}
      </div>
    </div>

    <div style={{padding:'8px 16px 120px'}}>
      <CatRow icon={I.food} color="#F59E0B" name="Comida" sub="32 lançamentos · R$ 697 esse mês" pct={0.32} budget="R$ 700"/>
      <CatRow icon={I.car}  color="#3B82F6" name="Transporte" sub="14 lançamentos · R$ 479" pct={0.22}/>
      <CatRow icon={I.house} color="#8B5CF6" name="Casa" sub="6 lançamentos · R$ 436" pct={0.20} budget="R$ 500"/>
      <CatRow icon={I.health} color="#10B981" name="Saúde" sub="2 lançamentos · R$ 89" pct={0.04}/>
      <CatRow icon={I.game} color="#EC4899" name="Lazer" sub="8 lançamentos · R$ 305" pct={0.14} budget="R$ 250" over/>
      <CatRow icon={I.bolt} color="#F59E0B" name="Contas fixas" sub="3 lançamentos · R$ 380" pct={0.18}/>
      <CatRow icon={I.tag}  color="#94A3B8" name="Outros" sub="11 lançamentos · R$ 263" pct={0.12}/>

      <div style={{marginTop:14, padding:'12px 14px', borderRadius:12, background: KITAMO.brandSoft,
        display:'flex', gap:10, alignItems:'flex-start'}}>
        {I.info({size:16, stroke: KITAMO.brandDark})}
        <div style={{fontSize:12, color: KITAMO.ink2, lineHeight:1.45}}>
          Toca numa categoria pra editar nome, ícone, cor ou definir um <b>limite mensal</b>.
        </div>
      </div>
    </div>
  </Screen>
);

const CatRow = ({ icon, color, name, sub, pct, budget, over }) => (
  <div style={{padding:'12px 14px', background:'#fff', borderRadius:14, marginBottom:6,
    boxShadow:'0 1px 3px rgba(15,23,42,0.04)'}}>
    <div style={{display:'flex', alignItems:'center', gap:12}}>
      <div style={{width:40, height:40, borderRadius:12, background: color+'18', color,
        display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0}}>
        {icon({size:18})}
      </div>
      <div style={{flex:1, minWidth:0}}>
        <div style={{display:'flex', alignItems:'center', gap:6}}>
          <div style={{fontSize:14, fontWeight:700, color: KITAMO.ink}}>{name}</div>
          {budget && <span style={{fontSize:9, fontWeight:700, padding:'1px 5px', borderRadius:5,
            background: over ? '#FEE2E2' : KITAMO.line2,
            color: over ? KITAMO.danger : KITAMO.muted, letterSpacing:0.2}}>
            {over ? 'PASSOU' : 'COM LIMITE'}</span>}
        </div>
        <div style={{fontSize:11, color: KITAMO.muted, marginTop:1}}>{sub}</div>
      </div>
      <span style={{color: KITAMO.line}}>{I.arrow({size:16})}</span>
    </div>
    {budget && (
      <div style={{marginTop:8, marginLeft:52}}>
        <div style={{height:4, background: KITAMO.line2, borderRadius:2, overflow:'hidden'}}>
          <div style={{width: over ? '120%' : `${Math.min(pct*100/0.32, 100)}%`,
            height:'100%', background: over ? KITAMO.danger : color, borderRadius:2}}/>
        </div>
        <div style={{fontSize:10, color: KITAMO.muted, fontWeight:600, marginTop:3}}>
          Limite {budget} · {over ? 'passou em R$ 55' : 'dentro do plano'}
        </div>
      </div>
    )}
  </div>
);

// ─── 15. METAS ─────────────────────────────────────────────
const ScreenMetas = () => (
  <Screen bg={KITAMO.bg} label="16 Metas">
    <div style={{padding:'8px 16px 0', display:'flex', alignItems:'center', gap:10}}>
      <button data-back style={{background:'#fff', border:0, width:36, height:36, borderRadius:18, cursor:'pointer',
        display:'flex', alignItems:'center', justifyContent:'center', color: KITAMO.ink,
        boxShadow:'0 1px 3px rgba(15,23,42,0.05)'}}>{I.back({size:18})}</button>
      <div style={{flex:1, fontSize:18, fontWeight:800}}>Metas</div>
    </div>

    {/* hero summary */}
    <div style={{margin:'14px 16px 0', padding:18, borderRadius:18,
      background:`linear-gradient(135deg, ${KITAMO.brand} 0%, #2BC0B1 100%)`,
      color:'#fff', position:'relative', overflow:'hidden'}}>
      <div style={{position:'absolute', right:-20, top:-20, width:120, height:120, borderRadius:60,
        background:'rgba(255,255,255,0.10)'}}/>
      <div style={{fontSize:11, opacity:0.85, fontWeight:700, letterSpacing:0.3}}>JUNTANDO PRO QUE IMPORTA</div>
      <div style={{fontSize:28, fontWeight:800, letterSpacing:-0.8, marginTop:4, fontVariantNumeric:'tabular-nums'}}>
        <span style={{fontSize:16, opacity:0.7, marginRight:3}}>R$</span>2.450
        <span style={{fontSize:14, opacity:0.7}}> / 6.000</span>
      </div>
      <div style={{fontSize:12, opacity:0.9, marginTop:4}}>3 metas ativas · 41% do total</div>
      <div style={{height:6, background:'rgba(255,255,255,0.2)', borderRadius:3, marginTop:12, overflow:'hidden'}}>
        <div style={{width:'41%', height:'100%', background:'#fff', borderRadius:3}}/>
      </div>
    </div>

    <div style={{padding:'14px 16px 120px'}}>
      <MetaCard emoji="✈️" name="Viagem pra Bahia" target="3.000,00" saved="1.800,00" pct={0.6}
        deadline="set/2026" sub="Faltam R$ 1.200 · economiza R$ 200/mês"/>
      <MetaCard emoji="📱" name="Trocar celular" target="2.000,00" saved="450,00" pct={0.225}
        deadline="dez/2026" sub="No ritmo certo pra fechar até dezembro"/>
      <MetaCard emoji="🎓" name="Reserva de emergência" target="1.000,00" saved="200,00" pct={0.20}
        deadline="sem prazo" sub="Tá no comecinho, mas não desiste!"/>

      <button style={{
        width:'100%', padding:'16px', marginTop:8, borderRadius:14,
        border:`1.5px dashed ${KITAMO.line}`, background:'transparent',
        color: KITAMO.brandDark, fontSize:14, fontWeight:700, cursor:'pointer',
        display:'flex', alignItems:'center', justifyContent:'center', gap:8,
      }}>{I.plus({size:16})} Criar nova meta</button>

      <div style={{marginTop:14, padding:14, borderRadius:14, background:'#fff',
        boxShadow:'0 1px 3px rgba(15,23,42,0.04)'}}>
        <div style={{display:'flex', alignItems:'center', gap:8}}>
          {I.spark({size:16, stroke: KITAMO.brandDark})}
          <div style={{fontSize:12, fontWeight:700, color: KITAMO.brandDark, letterSpacing:0.3}}>SUGESTÃO DA KIT</div>
        </div>
        <div style={{fontSize:13, color: KITAMO.ink2, marginTop:8, lineHeight:1.5}}>
          Você costuma sobrar uns <b style={{color: KITAMO.ink}}>R$ 230</b> no fim do mês. Que tal criar uma meta de <b style={{color: KITAMO.ink}}>"Reserva de Natal"</b>?
        </div>
        <a style={{display:'inline-block', marginTop:10, fontSize:13, fontWeight:700,
          color: KITAMO.brandDark}}>Criar meta sugerida →</a>
      </div>
    </div>
  </Screen>
);

const MetaCard = ({ emoji, name, target, saved, pct, deadline, sub }) => (
  <div style={{padding:14, background:'#fff', borderRadius:16, marginBottom:8,
    boxShadow:'0 1px 3px rgba(15,23,42,0.04)'}}>
    <div style={{display:'flex', alignItems:'center', gap:12}}>
      <div style={{width:42, height:42, borderRadius:12, background: KITAMO.line2,
        display:'flex', alignItems:'center', justifyContent:'center', fontSize:22}}>{emoji}</div>
      <div style={{flex:1, minWidth:0}}>
        <div style={{fontSize:14, fontWeight:700, color: KITAMO.ink}}>{name}</div>
        <div style={{fontSize:11, color: KITAMO.muted, marginTop:1}}>até {deadline}</div>
      </div>
      <div style={{textAlign:'right'}}>
        <div style={{fontSize:14, fontWeight:800, color: KITAMO.ink, fontVariantNumeric:'tabular-nums'}}>
          R$ {saved}
        </div>
        <div style={{fontSize:10, color: KITAMO.muted, fontVariantNumeric:'tabular-nums'}}>de R$ {target}</div>
      </div>
    </div>
    <div style={{marginTop:10, height:8, background: KITAMO.line2, borderRadius:4, overflow:'hidden', position:'relative'}}>
      <div style={{width:`${pct*100}%`, height:'100%',
        background:`linear-gradient(90deg, ${KITAMO.brand}, #2BC0B1)`, borderRadius:4}}/>
    </div>
    <div style={{display:'flex', justifyContent:'space-between', alignItems:'center', marginTop:8}}>
      <div style={{fontSize:11, color: KITAMO.ink2, fontWeight:600}}>{sub}</div>
      <div style={{fontSize:12, fontWeight:800, color: KITAMO.brandDark, fontVariantNumeric:'tabular-nums'}}>{Math.round(pct*100)}%</div>
    </div>
  </div>
);

// ─── 16. SEGURANÇA ─────────────────────────────────────────
const ScreenSeguranca = () => (
  <Screen bg={KITAMO.bg} label="17 Segurança">
    <div style={{padding:'8px 16px 0', display:'flex', alignItems:'center', gap:10}}>
      <button data-back style={{background:'#fff', border:0, width:36, height:36, borderRadius:18, cursor:'pointer',
        display:'flex', alignItems:'center', justifyContent:'center', color: KITAMO.ink,
        boxShadow:'0 1px 3px rgba(15,23,42,0.05)'}}>{I.back({size:18})}</button>
      <div style={{flex:1, fontSize:18, fontWeight:800}}>Segurança</div>
    </div>

    {/* status hero */}
    <div style={{margin:'14px 16px 0', padding:'18px 18px', background:'#fff',
      borderRadius:18, boxShadow:'0 2px 8px rgba(15,23,42,0.05)',
      display:'flex', alignItems:'center', gap:14}}>
      <div style={{width:54, height:54, borderRadius:14,
        background:`linear-gradient(135deg, ${KITAMO.success} 0%, #059669 100%)`,
        color:'#fff', display:'flex', alignItems:'center', justifyContent:'center'}}>
        {I.shield({size:26})}
      </div>
      <div style={{flex:1}}>
        <div style={{fontSize:11, color: KITAMO.muted, fontWeight:700, letterSpacing:0.3}}>SUA CONTA TÁ</div>
        <div style={{fontSize:18, fontWeight:800, color: KITAMO.success}}>Bem protegida ✓</div>
        <div style={{fontSize:11, color: KITAMO.muted, marginTop:1}}>3 de 4 proteções ativas</div>
      </div>
    </div>

    <div style={{padding:'18px 16px 120px'}}>
      <SectionLabel>ENTRAR NO APP</SectionLabel>

      <SecRow icon={I.face} color={KITAMO.success} name="Face ID" sub="Pra abrir o app rapidinho" toggle on/>
      <SecRow icon={I.lock} color={KITAMO.success} name="PIN de 4 dígitos" sub="Configurado" trail="Trocar PIN"/>
      <SecRow icon={I.eye}  color={KITAMO.warn}    name="Esconder saldo no app" sub="Aparece como ••• ao abrir" toggle/>

      <SectionLabel>SEUS DADOS</SectionLabel>

      <SecRow icon={I.lock} color={KITAMO.brandDark} name="Trocar senha" sub="Última troca há 3 meses" trail="Trocar"/>
      <SecRow icon={I.bot}  color={KITAMO.brandDark} name="Verificação em 2 etapas" sub="SMS no celular ••94" toggle on/>
      <SecRow icon={I.swap} color={KITAMO.brandDark} name="Sessões ativas" sub="3 dispositivos conectados" trail="Ver"/>

      <SectionLabel>AVISOS</SectionLabel>

      <SecRow icon={I.bell} color={KITAMO.info} name="Avisar entrada nova de dispositivo" sub="Recomendado" toggle on/>
      <SecRow icon={I.bell} color={KITAMO.info} name="Avisar transação acima de R$ 500" sub="" toggle/>

      <button style={{width:'100%', marginTop:18, padding:'16px',
        background:'transparent', border:0, color: KITAMO.danger,
        fontSize:14, fontWeight:700, cursor:'pointer'}}>
        Sair de todos os dispositivos
      </button>
    </div>
  </Screen>
);

const SecRow = ({ icon, color, name, sub, toggle, on, trail }) => (
  <div style={{padding:'14px 14px', background:'#fff', borderRadius:14, marginBottom:6,
    boxShadow:'0 1px 3px rgba(15,23,42,0.04)',
    display:'flex', alignItems:'center', gap:12}}>
    <div style={{width:36, height:36, borderRadius:10, background: color+'18', color,
      display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0}}>
      {icon({size:16})}
    </div>
    <div style={{flex:1, minWidth:0}}>
      <div style={{fontSize:13, fontWeight:700, color: KITAMO.ink}}>{name}</div>
      {sub && <div style={{fontSize:11, color: KITAMO.muted, marginTop:1}}>{sub}</div>}
    </div>
    {toggle ? (
      <div style={{width:42, height:24, borderRadius:12, padding:2,
        background: on ? KITAMO.brand : KITAMO.line2,
        display:'flex', alignItems:'center',
        justifyContent: on ? 'flex-end' : 'flex-start'}}>
        <div style={{width:20, height:20, borderRadius:10, background:'#fff',
          boxShadow:'0 1px 2px rgba(0,0,0,0.15)'}}/>
      </div>
    ) : trail ? (
      <span style={{fontSize:12, color: KITAMO.brandDark, fontWeight:700}}>{trail}</span>
    ) : (
      <span style={{color: KITAMO.line}}>{I.arrow({size:16})}</span>
    )}
  </div>
);

// ─── 17. ADD INVESTMENT (modal) ────────────────────────────
const ScreenAddInvest = () => (
  <Screen bg="#fff" label="18 Novo investimento">
    <div style={{padding:'8px 16px 0', display:'flex', alignItems:'center', justifyContent:'space-between'}}>
      <button data-back style={{background: KITAMO.line2, border:0, width:36, height:36, borderRadius:18,
        cursor:'pointer', display:'flex', alignItems:'center', justifyContent:'center', color: KITAMO.ink}}>
        {I.close({size:18})}
      </button>
      <div style={{fontSize:15, fontWeight:700}}>Novo investimento</div>
      <div style={{width:36}}/>
    </div>

    <div style={{padding:'18px 16px 0'}}>
      <div style={{fontSize:12, color: KITAMO.muted, fontWeight:700, marginBottom:10}}>QUE TIPO?</div>
      <div style={{display:'grid', gridTemplateColumns:'1fr 1fr', gap:8}}>
        <InvestTypePick color="#3B82F6" name="Renda fixa" sub="Tesouro, CDB, LCI" active/>
        <InvestTypePick color="#8B5CF6" name="Fundos" sub="Multi, DI, ações"/>
        <InvestTypePick color="#10B981" name="Poupança" sub="Conta poupança"/>
        <InvestTypePick color="#F59E0B" name="Outro" sub="Cripto, ações…"/>
      </div>
    </div>

    <div style={{padding:'24px 16px 0', textAlign:'center'}}>
      <div style={{fontSize:12, color: KITAMO.muted, fontWeight:600}}>QUANTO?</div>
      <div style={{fontSize:42, fontWeight:800, letterSpacing:-1.5, marginTop:4,
        color: KITAMO.brandDark, fontVariantNumeric:'tabular-nums'}}>
        <span style={{fontSize:20, fontWeight:600, opacity:0.7, marginRight:4}}>R$</span>500<span style={{opacity:0.6}}>,00</span>
      </div>
      <div style={{height:2, background: KITAMO.brand, width:120, margin:'4px auto 0',
        borderRadius:1, opacity:0.3}}/>
    </div>

    <div style={{padding:'14px 16px 0'}}>
      <Field label="Nome" value="Tesouro Selic 2029" suggestions={['Tesouro Selic','CDB Nubank','LCI Itaú']}/>
      <Field label="Onde tá?" value="Nubank" trailing={<BankAvatar name="Nubank" color="#8A05BE" size={28}/>} chev/>
      <Field label="Rendimento esperado" value="100% CDI · ~10% ao ano"/>
      <ToggleRow label="Tem prazo?" optionA="Tem" optionB="Sem prazo" valueA/>
    </div>

    <div style={{position:'absolute', left:16, right:16, bottom:24}}>
      <button style={{
        width:'100%', height:56, border:0, borderRadius:14,
        background: KITAMO.brand, color:'#fff', fontSize:17, fontWeight:700,
        cursor:'pointer', boxShadow:'0 6px 16px rgba(51,214,197,0.35)',
      }}>Adicionar</button>
    </div>
  </Screen>
);

const InvestTypePick = ({ color, name, sub, active }) => (
  <div style={{padding:'14px 12px', borderRadius:14,
    background: active ? color+'12' : '#fff',
    border: active ? `1.5px solid ${color}` : `1.5px solid ${KITAMO.line}`,
    boxShadow: active ? 'none' : '0 1px 3px rgba(15,23,42,0.03)'}}>
    <div style={{width:34, height:34, borderRadius:10, background: color+'20', color,
      display:'flex', alignItems:'center', justifyContent:'center'}}>
      {I.chart({size:16})}
    </div>
    <div style={{fontSize:13, fontWeight:700, color: KITAMO.ink, marginTop:8}}>{name}</div>
    <div style={{fontSize:10, color: KITAMO.muted, marginTop:1}}>{sub}</div>
  </div>
);

Object.assign(window, {
  ScreenIAChat, ScreenNotif, ScreenCategorias, ScreenMetas, ScreenSeguranca, ScreenAddInvest,
});
