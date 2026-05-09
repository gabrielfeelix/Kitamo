// Kitamo Screens 5-8: Contas, Add Transaction, Gastos, Detail Drawer

// ─── 5. CONTAS ──────────────────────────────────────────────
const ScreenContas = ({ tab = 'bancos', active = 'contas', onTab, onSubTab }) => (
  <Screen bg={KITAMO.bg} label="06 Contas">
    <div style={{padding:'8px 22px 0', display:'flex', alignItems:'center', justifyContent:'space-between'}}>
      <div style={{fontSize:26, fontWeight:800, letterSpacing:-0.6}}>Minhas contas</div>
      <button style={{
        height:36, padding:'0 14px', borderRadius:18, border:0,
        background: KITAMO.brand, color:'#fff', fontWeight:700, fontSize:13,
        display:'flex', alignItems:'center', gap:4, cursor:'pointer',
      }}>{I.plus({size:16})} Adicionar</button>
    </div>

    <div style={{display:'flex', gap:8, padding:'18px 22px 0'}}>
      {[
        ['bancos','Bancos'],
        ['cartoes','Cartões'],
        ['invest','Investimentos'],
      ].map(([id,label]) => {
        const on = tab === id;
        return <button key={id} onClick={() => onSubTab && onSubTab(id)} style={{
          padding:'9px 16px', borderRadius:20, border:0,
          background: on ? KITAMO.ink : '#fff',
          color: on ? '#fff' : KITAMO.ink2, fontWeight: on?700:600, fontSize:13,
          cursor:'pointer', boxShadow: on?'none':'0 1px 3px rgba(15,23,42,0.05)',
        }}>{label}</button>;
      })}
    </div>

    <div style={{padding:'18px 16px 120px'}}>
      {tab === 'bancos' && <ContasBancos/>}
      {tab === 'cartoes' && <ContasCartoes/>}
      {tab === 'invest' && <ContasInvest/>}
    </div>
    <TabBar active={active} onTab={onTab}/>
  </Screen>
);

const ContasBancos = () => (
  <div>
    <div style={{padding:'14px 16px', background:'#fff', borderRadius:16,
      boxShadow:'0 1px 3px rgba(15,23,42,0.04)', marginBottom: 12,
      display:'flex', alignItems:'center', justifyContent:'space-between'}}>
      <div>
        <div style={{fontSize:11, color: KITAMO.muted, fontWeight:600, letterSpacing:0.2}}>SALDO TOTAL</div>
        <div style={{fontSize:22, fontWeight:800, letterSpacing:-0.5, marginTop:2, fontVariantNumeric:'tabular-nums'}}>
          <span style={{fontSize:13, fontWeight:600, color: KITAMO.muted, marginRight:3}}>R$</span>1.847,30
        </div>
      </div>
      <div style={{fontSize:11, color: KITAMO.success, fontWeight:700, padding:'4px 8px',
        background:'#D1FAE5', borderRadius:8}}>● 3 contas</div>
    </div>

    <BankCard color="#8A05BE" name="Nubank" sub="Conta corrente" amount="1.230,00" updated="agora" connected/>
    <BankCard color="#EC7000" name="Itaú" sub="Poupança" amount="450,30" updated="há 1h" connected/>
    <BankCard color="#11C76F" name="PicPay" sub="Carteira" amount="167,00" updated="há 3h" manual/>

    <button style={{
      width:'100%', padding:'14px', marginTop:8, borderRadius:14,
      border:`1.5px dashed ${KITAMO.line}`, background: 'transparent',
      color: KITAMO.brandDark, fontSize:14, fontWeight:700, cursor:'pointer',
      display:'flex', alignItems:'center', justifyContent:'center', gap:8,
    }}>{I.plus({size:16})} Conectar outro banco</button>
  </div>
);

const BankCard = ({ color, name, sub, amount, updated, connected, manual }) => (
  <div style={{padding:'12px 14px', background:'#fff', borderRadius:14, marginBottom:6,
    boxShadow:'0 1px 3px rgba(15,23,42,0.04)',
    display:'flex', alignItems:'center', gap:11}}>
    <BankAvatar name={name} color={color} size={34}/>
    <div style={{flex:1, minWidth:0}}>
      <div style={{display:'flex', alignItems:'center', gap:6}}>
        <div style={{fontSize:13, fontWeight:700, color: KITAMO.ink}}>{name}</div>
        <div style={{
          padding:'1px 5px', borderRadius:4, fontSize:8.5, fontWeight:700, letterSpacing:0.2,
          background: connected ? '#D1FAE5' : '#F1F5F9',
          color: connected ? KITAMO.success : KITAMO.muted,
        }}>{connected ? 'CONECTADO' : 'MANUAL'}</div>
      </div>
      <div style={{fontSize:10.5, color: KITAMO.muted, marginTop:1}}>{sub} · {updated}</div>
    </div>
    <div style={{textAlign:'right'}}>
      <div style={{fontSize:14, fontWeight:700, color: KITAMO.ink, fontVariantNumeric:'tabular-nums', letterSpacing:-0.2}}>
        <span style={{fontSize:10, fontWeight:600, color: KITAMO.muted, marginRight:2}}>R$</span>{amount}
      </div>
    </div>
  </div>
);

const ContasCartoes = () => (
  <div>
    <CreditCard from="#8A05BE" to="#5B0286" name="Nubank Roxinho" digits="4242"
      bill="730,40" limit="3.500,00" used={0.62} status="Fatura aberta" closing="dia 28"/>
    <CreditCard from="#EC7000" to="#C75600" name="Itaú Personnalité" digits="0019"
      bill="1.245,00" limit="2.000,00" used={0.62} status="Fatura fechada" closing="venc. dia 10" warn/>
    <CreditCard from="#11C76F" to="#0A8E50" name="PicPay Card" digits="8821"
      bill="0,00" limit="500,00" used={0} status="Pago" closing="dia 5" paid/>

    <button style={{
      width:'100%', padding:'18px', marginTop:14, borderRadius:18,
      border:`1.5px dashed ${KITAMO.line}`, background:'transparent',
      color: KITAMO.brandDark, fontSize:15, fontWeight:700, cursor:'pointer',
      display:'flex', alignItems:'center', justifyContent:'center', gap:8,
    }}>{I.plus({size:18})} Adicionar cartão</button>
  </div>
);

const CreditCard = ({ from, to, name, digits, bill, limit, used, status, closing, warn, paid }) => (
  <div style={{marginBottom:14}}>
    <div style={{
      padding:18, height: 180, borderRadius:20,
      background: `linear-gradient(135deg, ${from} 0%, ${to} 100%)`,
      color:'#fff', position:'relative', overflow:'hidden',
      boxShadow:`0 8px 24px ${from}40`,
    }}>
      <div style={{position:'absolute', right:-30, top:-30, width:160, height:160, borderRadius:80,
        background:'rgba(255,255,255,0.08)'}}/>
      <div style={{position:'absolute', right:-60, bottom:-40, width:120, height:120, borderRadius:60,
        background:'rgba(255,255,255,0.05)'}}/>
      <div style={{display:'flex', alignItems:'center', justifyContent:'space-between', position:'relative'}}>
        <div style={{fontSize:13, fontWeight:700, opacity:0.9}}>{name}</div>
        {I.card({size:24, stroke:'#fff'})}
      </div>
      <div style={{position:'absolute', bottom:18, left:18, right:18}}>
        <div style={{fontSize:11, opacity:0.8}}>Fatura atual</div>
        <div style={{fontSize:28, fontWeight:800, fontVariantNumeric:'tabular-nums', letterSpacing:-0.5}}>R$ {bill}</div>
        <div style={{display:'flex', alignItems:'center', justifyContent:'space-between', marginTop:8, fontSize:12, opacity:0.85}}>
          <span>•••• {digits}</span>
          <span>{closing}</span>
        </div>
      </div>
    </div>
    <div style={{padding:'12px 16px 0'}}>
      <div style={{display:'flex', justifyContent:'space-between', fontSize:12, color: KITAMO.muted, marginBottom:6}}>
        <span style={{
          color: paid ? KITAMO.success : warn ? KITAMO.danger : KITAMO.brandDark,
          fontWeight:700,
        }}>● {status}</span>
        <span>Limite: R$ {limit}</span>
      </div>
      <div style={{height:6, background: KITAMO.line2, borderRadius:3, overflow:'hidden'}}>
        <div style={{
          width: `${used*100}%`, height:'100%',
          background: warn ? KITAMO.danger : KITAMO.brand,
        }}/>
      </div>
    </div>
  </div>
);

const ContasInvest = () => (
  <div>
    {/* hero card with mini chart */}
    <div style={{padding:'18px 18px 0', background:'linear-gradient(135deg, #0F172A 0%, #1E293B 100%)',
      borderRadius:18, color:'#fff', marginBottom:12, position:'relative', overflow:'hidden'}}>
      <div style={{display:'flex', justifyContent:'space-between', alignItems:'flex-start', position:'relative'}}>
        <div>
          <div style={{fontSize:11, opacity:0.6, fontWeight:600, letterSpacing:0.3}}>TOTAL INVESTIDO</div>
          <div style={{fontSize:28, fontWeight:800, letterSpacing:-1, fontVariantNumeric:'tabular-nums', marginTop:2}}>
            <span style={{fontSize:16, fontWeight:600, opacity:0.7, marginRight:3}}>R$</span>4.230,00
          </div>
          <div style={{display:'flex', alignItems:'center', gap:6, marginTop:6}}>
            <span style={{fontSize:12, color:'#34D399', fontWeight:700}}>↑ R$ 38,90 esse mês</span>
            <span style={{fontSize:11, opacity:0.5}}>+0,93%</span>
          </div>
        </div>
        <select style={{background:'rgba(255,255,255,0.1)', border:'1px solid rgba(255,255,255,0.15)',
          color:'#fff', borderRadius:8, padding:'4px 8px', fontSize:11, fontWeight:600}}>
          <option>30 dias</option>
        </select>
      </div>
      {/* sparkline */}
      <svg viewBox="0 0 320 60" width="100%" height="50" style={{marginTop:12, display:'block'}} preserveAspectRatio="none">
        <defs>
          <linearGradient id="investG" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stopColor="#34D399" stopOpacity="0.4"/>
            <stop offset="100%" stopColor="#34D399" stopOpacity="0"/>
          </linearGradient>
        </defs>
        <path d="M0,45 C30,42 50,38 80,35 C110,32 130,40 160,32 C190,24 210,28 240,18 C270,8 300,12 320,8 L320,60 L0,60 Z" fill="url(#investG)"/>
        <path d="M0,45 C30,42 50,38 80,35 C110,32 130,40 160,32 C190,24 210,28 240,18 C270,8 300,12 320,8" stroke="#34D399" strokeWidth="2" fill="none"/>
        <circle cx="320" cy="8" r="3" fill="#34D399"/>
      </svg>
    </div>

    {/* allocation */}
    <div style={{padding:14, background:'#fff', borderRadius:16, marginBottom:12,
      boxShadow:'0 1px 3px rgba(15,23,42,0.04)'}}>
      <div style={{fontSize:13, fontWeight:700, color: KITAMO.ink, marginBottom:10}}>Como tá distribuído</div>
      <div style={{display:'flex', height:10, borderRadius:5, overflow:'hidden', gap:2}}>
        <div style={{flex:0.515, background:'#3B82F6'}}/>
        <div style={{flex:0.355, background:'#8B5CF6'}}/>
        <div style={{flex:0.13,  background:'#10B981'}}/>
      </div>
      <div style={{display:'flex', justifyContent:'space-between', marginTop:10, fontSize:11}}>
        <div style={{display:'flex', alignItems:'center', gap:5}}>
          <div style={{width:8, height:8, borderRadius:4, background:'#3B82F6'}}/>
          <span style={{color: KITAMO.ink2, fontWeight:600}}>Tesouro <b style={{color: KITAMO.ink}}>52%</b></span>
        </div>
        <div style={{display:'flex', alignItems:'center', gap:5}}>
          <div style={{width:8, height:8, borderRadius:4, background:'#8B5CF6'}}/>
          <span style={{color: KITAMO.ink2, fontWeight:600}}>CDB <b style={{color: KITAMO.ink}}>35%</b></span>
        </div>
        <div style={{display:'flex', alignItems:'center', gap:5}}>
          <div style={{width:8, height:8, borderRadius:4, background:'#10B981'}}/>
          <span style={{color: KITAMO.ink2, fontWeight:600}}>Conta <b style={{color: KITAMO.ink}}>13%</b></span>
        </div>
      </div>
    </div>

    <div style={{fontSize:11, color: KITAMO.muted, fontWeight:700, letterSpacing:0.4, padding:'4px 4px 8px'}}>
      MEUS INVESTIMENTOS
    </div>

    <InvestRow color="#3B82F6" name="Tesouro Selic 2029" sub="Renda fixa · Tesouro" amount="2.180,00" yieldM="+ 22,40" yieldPct="+1,04%"/>
    <InvestRow color="#8B5CF6" name="CDB Nubank" sub="105% CDI · Vence 2027" amount="1.500,00" yieldM="+ 14,20" yieldPct="+0,95%"/>
    <InvestRow color="#10B981" name="Mercado Pago" sub="Conta remunerada · 100% CDI" amount="550,00" yieldM="+ 2,30" yieldPct="+0,42%"/>

    <button style={{
      width:'100%', padding:'14px', marginTop:8, borderRadius:14,
      border:`1.5px dashed ${KITAMO.line}`, background: 'transparent',
      color: KITAMO.brandDark, fontSize:14, fontWeight:700, cursor:'pointer',
      display:'flex', alignItems:'center', justifyContent:'center', gap:8,
    }} data-nav="add-invest">{I.plus({size:16})} Adicionar investimento</button>

    <div style={{marginTop:14, padding:'12px 14px', borderRadius:12, background: KITAMO.brandSoft,
      display:'flex', gap:10, alignItems:'flex-start'}}>
      {I.info({size:16, stroke: KITAMO.brandDark})}
      <div style={{fontSize:12, color: KITAMO.ink2, lineHeight:1.45}}>
        Investimentos não entram no seu <b style={{color: KITAMO.ink}}>dinheiro do dia a dia</b>. A gente separa pra não confundir.
      </div>
    </div>
  </div>
);

const InvestRow = ({ color, name, sub, amount, yieldM, yieldPct }) => (
  <div style={{display:'flex', alignItems:'center', gap:12, padding:'12px 14px',
    background:'#fff', borderRadius:14, marginBottom:8,
    boxShadow:'0 1px 3px rgba(15,23,42,0.03)'}}>
    <div style={{width:36, height:36, borderRadius:10, background: color+'18', color,
      display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0}}>
      {I.chart({size:18})}
    </div>
    <div style={{flex:1, minWidth:0}}>
      <div style={{fontSize:14, fontWeight:700, color: KITAMO.ink}}>{name}</div>
      <div style={{fontSize:11, color: KITAMO.muted, marginTop:1}}>{sub}</div>
    </div>
    <div style={{textAlign:'right'}}>
      <div style={{fontSize:14, fontWeight:800, color: KITAMO.ink, fontVariantNumeric:'tabular-nums', letterSpacing:-0.2}}>
        R$ {amount}
      </div>
      <div style={{fontSize:11, color: KITAMO.success, fontWeight:700, marginTop:1, fontVariantNumeric:'tabular-nums'}}>
        {yieldM} <span style={{opacity:0.7, fontWeight:600}}>{yieldPct}</span>
      </div>
    </div>
  </div>
);

// ─── 6. ADD TRANSACTION (modal fullscreen) ─────────────────
const ScreenAdd = ({ kind = 'out' }) => {
  const accentColor = kind==='in' ? KITAMO.success : kind==='out' ? KITAMO.danger : KITAMO.info;
  return (
  <Screen bg="#fff" label="07 Adicionar">
    <div style={{padding:'8px 16px 0', display:'flex', alignItems:'center', justifyContent:'space-between'}}>
      <button style={{background: KITAMO.line2, border:0, width:36, height:36, borderRadius:18,
        cursor:'pointer', display:'flex', alignItems:'center', justifyContent:'center', color: KITAMO.ink}}>
        {I.close({size:18})}
      </button>
      <div style={{fontSize:15, fontWeight:700}}>{kind==='mov' ? 'Transferir entre contas' : 'Nova transação'}</div>
      <div style={{width:36}}/>
    </div>

    {/* tabs */}
    <div style={{padding:'18px 16px 0', display:'grid', gridTemplateColumns:'1fr 1fr 1fr', gap:8}}>
      {[
        ['out','Saiu','💸', KITAMO.danger],
        ['in','Entrou','💰', KITAMO.success],
        ['mov','Transferi','🔄', KITAMO.info],
      ].map(([id,label,emoji,color]) => {
        const on = kind === id;
        return <div key={id} style={{
          padding:'12px 8px', borderRadius:14, textAlign:'center',
          background: on ? color+'15' : KITAMO.line2,
          border: on ? `1.5px solid ${color}` : `1.5px solid transparent`,
        }}>
          <div style={{fontSize:18}}>{emoji}</div>
          <div style={{fontSize:12, fontWeight:700, color: on ? color : KITAMO.ink2, marginTop:2}}>{label}</div>
        </div>;
      })}
    </div>

    {/* mega amount */}
    <div style={{padding:'28px 16px 16px', textAlign:'center'}}>
      <div style={{fontSize:13, color: KITAMO.muted, fontWeight:600}}>Valor</div>
      <div style={{
        fontSize:46, fontWeight:800, letterSpacing:-1.5, marginTop:4,
        color: accentColor,
        fontVariantNumeric:'tabular-nums',
      }}>
        <span style={{fontSize:22, fontWeight:600, opacity:0.7, marginRight:4}}>R$</span>{kind==='mov'?'200':'87'}<span style={{opacity:0.6}}>,{kind==='mov'?'00':'50'}</span>
      </div>
      <div style={{height:2, background: accentColor,
        width:120, margin:'6px auto 0', borderRadius:1, opacity:0.3}}/>
    </div>

    {kind === 'mov' ? <TransferFields/> : <NormalFields kind={kind}/>}

    <div style={{position:'absolute', left:16, right:16, bottom:24}}>
      <button style={{
        width:'100%', height:56, border:0, borderRadius:14,
        background: KITAMO.brand, color:'#fff', fontSize:17, fontWeight:700,
        cursor:'pointer', boxShadow:'0 6px 16px rgba(51,214,197,0.35)',
      }}>{kind==='mov' ? 'Transferir' : 'Salvar'}</button>
    </div>
  </Screen>
);};

const NormalFields = ({ kind }) => (
  <div style={{padding:'0 16px'}}>
    <Field label={kind==='in' ? 'O que entrou?' : 'O que foi?'} value={kind==='in'?'Salário':'Mercado da Esquina'}
      suggestions={kind==='in'?['Salário','Freela','Pix recebido','Vale']:['Mercado','Uber','Padaria','Aluguel']}/>
    <Field label={kind==='in' ? 'Caiu em qual conta?' : 'De qual conta?'} value="Nubank"
      trailing={<BankAvatar name="Nubank" color="#8A05BE" size={28}/>} chev/>
    <div style={{padding:'14px 0 6px'}}>
      <div style={{fontSize:12, color: KITAMO.muted, fontWeight:700, marginBottom:10}}>Categoria</div>
      <div style={{display:'flex', gap:10, overflowX:'auto', paddingBottom:6}}>
        <CatChip icon={I.food} label="Comida" color="#F59E0B" active/>
        <CatChip icon={I.car} label="Transporte" color={KITAMO.info}/>
        <CatChip icon={I.house} label="Casa" color="#8B5CF6"/>
        <CatChip icon={I.health} label="Saúde" color={KITAMO.success}/>
        <CatChip icon={I.game} label="Lazer" color="#EC4899"/>
        <CatChip icon={I.plus} label="Mais" color={KITAMO.muted}/>
      </div>
    </div>
    <ToggleRow label="Quando?" optionA="Hoje" optionB="Outro dia" valueA/>
    <ToggleRow label={kind==='in' ? 'Já caiu?' : 'Já paguei?'} optionA="Sim" optionB="Não" valueA/>
    <a style={{display:'block', textAlign:'center', padding:'14px 0', fontSize:14,
      color: KITAMO.brandDark, fontWeight:700}}>Mais opções ▾</a>
  </div>
);

const TransferFields = () => (
  <div style={{padding:'0 16px'}}>
    <div style={{position:'relative', background: KITAMO.bg, borderRadius:16, padding:6}}>
      <AccountPick kind="from" name="Nubank" sub="Conta corrente" amount="1.230,00" color="#8A05BE"/>
      <div style={{height:1, background: KITAMO.line2, margin:'2px 18px'}}/>
      <AccountPick kind="to" name="Itaú" sub="Poupança" amount="450,30" color="#EC7000"/>
      <button style={{
        position:'absolute', right:16, top:'50%', transform:'translateY(-50%)',
        width:34, height:34, borderRadius:17, border:`3px solid ${KITAMO.bg}`,
        background:'#fff', color: KITAMO.brandDark, cursor:'pointer',
        display:'flex', alignItems:'center', justifyContent:'center',
        boxShadow:'0 2px 6px rgba(15,23,42,0.10)',
      }}>{I.swap({size:14})}</button>
    </div>

    <div style={{padding:'14px 0 6px'}}>
      <div style={{fontSize:12, color: KITAMO.muted, fontWeight:700, marginBottom:8}}>Atalhos</div>
      <div style={{display:'flex', gap:8, overflowX:'auto', paddingBottom:4}}>
        <AcctChip name="PicPay" color="#11C76F"/>
        <AcctChip name="Carteira" color={KITAMO.muted}/>
        <AcctChip name="Mercado Pago" color={KITAMO.info}/>
        <AcctChip name="+" color={KITAMO.brand} plus/>
      </div>
    </div>

    <ToggleRow label="Quando?" optionA="Agora" optionB="Outro dia" valueA/>

    <div style={{marginTop:12, padding:'10px 12px', borderRadius:12, background: KITAMO.brandSoft,
      display:'flex', gap:8, alignItems:'center'}}>
      {I.info({size:14, stroke: KITAMO.brandDark})}
      <div style={{fontSize:12, color: KITAMO.ink2, fontWeight:600}}>
        Não conta como gasto — só muda de conta.
      </div>
    </div>
  </div>
);

const AccountPick = ({ kind, name, sub, amount, color }) => (
  <div style={{display:'flex', alignItems:'center', gap:12, padding:'12px 14px'}}>
    <div style={{width:32, height:32, borderRadius:16, flexShrink:0,
      background: kind==='from' ? '#FEE2E2' : '#D1FAE5',
      color: kind==='from' ? KITAMO.danger : KITAMO.success,
      display:'flex', alignItems:'center', justifyContent:'center'}}>
      {kind==='from' ? I.send({size:14}) : I.recv({size:14})}
    </div>
    <div style={{flex:1, minWidth:0}}>
      <div style={{fontSize:10, color: KITAMO.muted, fontWeight:700, letterSpacing:0.4}}>
        {kind==='from' ? 'DE' : 'PARA'}
      </div>
      <div style={{display:'flex', alignItems:'center', gap:8, marginTop:2}}>
        <BankAvatar name={name} color={color} size={20}/>
        <div style={{fontSize:14, fontWeight:700, color: KITAMO.ink}}>{name}</div>
        <span style={{fontSize:11, color: KITAMO.muted}}>· {sub}</span>
      </div>
      <div style={{fontSize:11, color: KITAMO.muted, marginTop:1, fontVariantNumeric:'tabular-nums'}}>
        Saldo R$ {amount}
      </div>
    </div>
    <span style={{color: KITAMO.muted}}>{I.down({size:16})}</span>
  </div>
);

const AcctChip = ({ name, color, plus }) => (
  <div style={{display:'flex', alignItems:'center', gap:8, flexShrink:0,
    padding:'8px 12px', borderRadius:12,
    background:'#fff', border:`1px solid ${KITAMO.line}`}}>
    {plus ?
      <div style={{width:20, height:20, borderRadius:10, background: color+'22', color,
        display:'flex', alignItems:'center', justifyContent:'center'}}>{I.plus({size:12})}</div>
      : <BankAvatar name={name} color={color} size={20}/>}
    <span style={{fontSize:12, fontWeight:600, color: KITAMO.ink}}>{name}</span>
  </div>
);

const Field = ({ label, value, suggestions, trailing, chev }) => (
  <div style={{padding:'14px 0', borderBottom:`1px solid ${KITAMO.line2}`}}>
    <div style={{fontSize:12, color: KITAMO.muted, fontWeight:700}}>{label}</div>
    <div style={{display:'flex', alignItems:'center', gap:10, marginTop:6}}>
      {trailing}
      <div style={{fontSize:17, fontWeight:600, color: KITAMO.ink, flex:1}}>{value}</div>
      {chev && <span style={{color: KITAMO.muted}}>{I.down({size:18})}</span>}
    </div>
    {suggestions && (
      <div style={{display:'flex', gap:6, marginTop:10, flexWrap:'wrap'}}>
        {suggestions.map(s => <span key={s} style={{
          padding:'4px 10px', borderRadius:12, fontSize:11, fontWeight:600,
          background: KITAMO.line2, color: KITAMO.ink2,
        }}>{s}</span>)}
      </div>
    )}
  </div>
);

const CatChip = ({ icon, label, color, active }) => (
  <div style={{display:'flex', flexDirection:'column', alignItems:'center', gap:4, flexShrink:0,
    padding:'8px 4px', minWidth:64,
    borderRadius:14, background: active ? color+'15' : 'transparent',
    border: active ? `1.5px solid ${color}` : `1.5px solid ${KITAMO.line2}`,
  }}>
    <div style={{width:36, height:36, borderRadius:18,
      background: color+'22', color, display:'flex', alignItems:'center', justifyContent:'center'}}>
      {icon({size:18})}
    </div>
    <span style={{fontSize:11, fontWeight:600, color: KITAMO.ink}}>{label}</span>
  </div>
);

const ToggleRow = ({ label, optionA, optionB, valueA }) => (
  <div style={{padding:'14px 0', borderBottom:`1px solid ${KITAMO.line2}`,
    display:'flex', alignItems:'center', justifyContent:'space-between'}}>
    <div style={{fontSize:14, fontWeight:700, color: KITAMO.ink}}>{label}</div>
    <div style={{display:'flex', background: KITAMO.line2, borderRadius:10, padding:3}}>
      {[optionA, optionB].map((o,i) => {
        const on = (valueA && i===0) || (!valueA && i===1);
        return <span key={o} style={{
          padding:'6px 14px', borderRadius:8, fontSize:13, fontWeight:700,
          background: on ? '#fff' : 'transparent',
          color: on ? KITAMO.ink : KITAMO.muted,
          boxShadow: on ? '0 1px 3px rgba(15,23,42,0.08)' : 'none',
        }}>{o}</span>;
      })}
    </div>
  </div>
);

// ─── 7. GASTOS ──────────────────────────────────────────────
const ScreenGastos = ({ active = 'gastos', onTab }) => (
  <Screen bg={KITAMO.bg} label="08 Gastos">
    <div style={{padding:'8px 22px 0', display:'flex', alignItems:'center', justifyContent:'space-between'}}>
      <div style={{fontSize:26, fontWeight:800, letterSpacing:-0.6}}>Gastos</div>
      <button style={{width:36, height:36, borderRadius:18, border:0, background:'#fff',
        boxShadow:'0 1px 3px rgba(15,23,42,0.05)', cursor:'pointer',
        display:'flex', alignItems:'center', justifyContent:'center', color: KITAMO.ink}}>
        {I.tag({size:18})}
      </button>
    </div>

    {/* month nav */}
    <div style={{display:'flex', alignItems:'center', justifyContent:'space-between',
      margin:'14px 22px 0', padding:'12px 14px', background:'#fff', borderRadius:14,
      boxShadow:'0 1px 3px rgba(15,23,42,0.04)'}}>
      <button style={{background:'none', border:0, color: KITAMO.muted, cursor:'pointer'}}>{I.back({size:18})}</button>
      <div style={{fontSize:15, fontWeight:700}}>Maio 2026</div>
      <button style={{background:'none', border:0, color: KITAMO.muted, cursor:'pointer', transform:'rotate(180deg)'}}>{I.back({size:18})}</button>
    </div>

    {/* summary */}
    <div style={{display:'grid', gridTemplateColumns:'1fr 1fr 1fr', gap:8, padding:'14px 16px 0'}}>
      <SumCard label="Entrou" amount="3.200" color={KITAMO.success}/>
      <SumCard label="Saiu" amount="2.180" color={KITAMO.danger}/>
      <SumCard label="Sobrou" amount="1.020" color={KITAMO.brandDark} highlight/>
    </div>

    {/* category bars (replaced pie) */}
    <div style={{margin:'14px 16px 0', padding:'16px 18px', background:'#fff', borderRadius:18,
      boxShadow:'0 2px 8px rgba(15,23,42,0.04)'}}>
      <div style={{display:'flex', alignItems:'baseline', justifyContent:'space-between', marginBottom: 14}}>
        <div style={{fontSize:13, fontWeight:700, color: KITAMO.ink}}>Onde foi sua grana?</div>
        <a style={{fontSize:11, color: KITAMO.brandDark, fontWeight:700}}>Ver detalhe →</a>
      </div>
      <div style={{display:'flex', height:8, borderRadius:4, overflow:'hidden', gap:2, marginBottom:14}}>
        <div style={{flex:0.32, background:'#F59E0B'}}/>
        <div style={{flex:0.22, background:'#3B82F6'}}/>
        <div style={{flex:0.20, background:'#8B5CF6'}}/>
        <div style={{flex:0.14, background:'#EC4899'}}/>
        <div style={{flex:0.12, background:'#94A3B8'}}/>
      </div>
      <div style={{display:'flex', flexDirection:'column', gap:10}}>
        <CatBar color="#F59E0B" label="Comida"     pct={0.32} amount="697"/>
        <CatBar color="#3B82F6" label="Transporte" pct={0.22} amount="479"/>
        <CatBar color="#8B5CF6" label="Casa"       pct={0.20} amount="436"/>
        <CatBar color="#EC4899" label="Lazer"      pct={0.14} amount="305"/>
        <CatBar color="#94A3B8" label="Outros"     pct={0.12} amount="263"/>
      </div>
    </div>

    {/* filter chips */}
    <div style={{display:'flex', gap:8, padding:'18px 16px 0', overflowX:'auto'}}>
      {[['Tudo',true],['Gastos',false],['Entradas',false],['Por categoria',false]].map(([l,on])=>(
        <span key={l} style={{
          padding:'7px 14px', borderRadius:18, fontSize:13, fontWeight:700, flexShrink:0,
          background: on ? KITAMO.ink : '#fff',
          color: on ? '#fff' : KITAMO.ink2,
          boxShadow: on?'none':'0 1px 3px rgba(15,23,42,0.05)',
        }}>{l}</span>
      ))}
    </div>

    {/* transactions */}
    <div style={{padding:'4px 16px 120px'}}>
      <DayHeader label="HOJE · 8 mai" total="-87,50"/>
      <TxItem icon={I.food} color="#F59E0B" name="Mercado da Esquina" cat="Comida · Nubank" amount="-87,50"/>
      <DayHeader label="ONTEM · 7 mai" total="-46,00"/>
      <TxItem icon={I.car} color={KITAMO.info} name="Uber pra casa" cat="Transporte · Nubank" amount="-22,00"/>
      <TxItem icon={I.food} color="#F59E0B" name="iFood — Burger" cat="Comida · Nubank" amount="-24,00"/>
      <DayHeader label="6 mai" total="+3.000,00"/>
      <TxItem icon={I.recv} color={KITAMO.success} name="Salário" cat="Renda · Itaú" amount="+3.000,00" income/>
      <DayHeader label="5 mai" total="-180,00"/>
      <TxItem icon={I.bolt} color={KITAMO.warn} name="Conta de luz" cat="Casa · Nubank" amount="-180,00"/>
    </div>

    <TabBar active={active} onTab={onTab}/>
  </Screen>
);

const SumCard = ({ label, amount, color, highlight }) => (
  <div style={{
    padding:'12px 12px', borderRadius:14,
    background: highlight ? color : '#fff',
    color: highlight ? '#fff' : KITAMO.ink,
    boxShadow:'0 2px 8px rgba(15,23,42,0.04)',
  }}>
    <div style={{fontSize:11, color: highlight ? 'rgba(255,255,255,0.85)' : KITAMO.muted, fontWeight:600}}>{label}</div>
    <div style={{fontSize:18, fontWeight:800, marginTop:3, fontVariantNumeric:'tabular-nums', letterSpacing:-0.4}}>
      <span style={{fontSize:11, opacity:0.7, marginRight:2}}>R$</span>{amount}
    </div>
  </div>
);

const CatBar = ({ color, label, pct, amount }) => (
  <div style={{fontSize:12}}>
    <div style={{display:'flex', alignItems:'center', justifyContent:'space-between', marginBottom:4}}>
      <div style={{display:'flex', alignItems:'center', gap:8}}>
        <div style={{width:8, height:8, borderRadius:4, background: color}}/>
        <span style={{color: KITAMO.ink, fontWeight:700, fontSize:13}}>{label}</span>
        <span style={{color: KITAMO.muted, fontWeight:600, fontSize:11}}>{Math.round(pct*100)}%</span>
      </div>
      <span style={{color: KITAMO.ink, fontWeight:700, fontVariantNumeric:'tabular-nums', fontSize:13}}>R$ {amount}</span>
    </div>
    <div style={{height:4, background: KITAMO.line2, borderRadius:2, overflow:'hidden'}}>
      <div style={{width:`${pct*100/0.32}%`, maxWidth:'100%', height:'100%', background:color, borderRadius:2}}/>
    </div>
  </div>
);

const DayHeader = ({ label, total }) => (
  <div style={{display:'flex', justifyContent:'space-between', alignItems:'center',
    padding:'18px 4px 8px'}}>
    <div style={{fontSize:11, color: KITAMO.muted, fontWeight:700, letterSpacing:0.4}}>{label}</div>
    <div style={{fontSize:12, color: KITAMO.muted, fontWeight:600, fontVariantNumeric:'tabular-nums'}}>R$ {total}</div>
  </div>
);

const TxItem = ({ icon, color, name, cat, amount, income }) => (
  <div style={{display:'flex', alignItems:'center', gap:12, padding:'12px 14px',
    background:'#fff', borderRadius:14, marginBottom:8,
    boxShadow:'0 1px 3px rgba(15,23,42,0.03)'}}>
    <CatIcon icon={icon} color={color} size={40}/>
    <div style={{flex:1, minWidth:0}}>
      <div style={{fontSize:15, fontWeight:700, color: KITAMO.ink}}>{name}</div>
      <div style={{fontSize:12, color: KITAMO.muted, marginTop:1}}>{cat}</div>
    </div>
    <div style={{fontSize:16, fontWeight:800, fontVariantNumeric:'tabular-nums',
      color: income ? KITAMO.success : KITAMO.ink}}>R$ {amount}</div>
  </div>
);

// ─── 8. DETAIL DRAWER (overlay variant of Gastos) ──────────
const ScreenDetail = ({ active = 'gastos', onTab }) => (
  <Screen bg={KITAMO.bg} label="09 Detalhe">
    {/* dimmed background of gastos */}
    <div style={{position:'absolute', top:44, left:0, right:0, bottom:0,
      background:'rgba(15,23,42,0.4)', zIndex:1}}/>
    <div style={{filter:'blur(0px)', opacity:0.6}}>
      <div style={{padding:'8px 22px 0', display:'flex', alignItems:'center', justifyContent:'space-between'}}>
        <div style={{fontSize:26, fontWeight:800, letterSpacing:-0.6}}>Gastos</div>
      </div>
    </div>

    {/* drawer */}
    <div style={{
      position:'absolute', left:0, right:0, bottom:0, zIndex:5,
      background:'#fff', borderTopLeftRadius:24, borderTopRightRadius:24,
      padding:'14px 20px 28px',
      boxShadow:'0 -10px 40px rgba(15,23,42,0.18)',
    }}>
      <div style={{width:40, height:4, background: KITAMO.line, borderRadius:2,
        margin:'0 auto 18px'}}/>

      <div style={{display:'flex', alignItems:'center', gap:14}}>
        <CatIcon icon={I.food} color="#F59E0B" size={56}/>
        <div style={{flex:1, minWidth:0}}>
          <div style={{fontSize:18, fontWeight:800, color: KITAMO.ink}}>Mercado da Esquina</div>
          <div style={{fontSize:13, color: KITAMO.muted, marginTop:1}}>Comida · Hoje, 18:42</div>
        </div>
        <span style={{padding:'4px 10px', borderRadius:8, fontSize:11, fontWeight:700,
          background:'#D1FAE5', color: KITAMO.success}}>● Pago</span>
      </div>

      <div style={{fontSize:42, fontWeight:800, marginTop:18, letterSpacing:-1.5,
        color: KITAMO.danger, fontVariantNumeric:'tabular-nums'}}>
        - R$ 87,50
      </div>

      <div style={{marginTop:18, padding:'4px 14px', background: KITAMO.bg, borderRadius:14}}>
        <Meta label="Categoria" value="🍔 Comida"/>
        <Meta label="Conta" value="Nubank"/>
        <Meta label="Pagamento" value="Pix"/>
        <Meta label="Observação" value='"Compras da semana"'/>
        <Meta label="Anexo" value="comprovante.jpg" link last/>
      </div>

      <div style={{display:'grid', gridTemplateColumns:'1fr 1fr 1fr', gap:8, marginTop:18}}>
        <DrawerBtn icon={I.tag} label="Editar"/>
        <DrawerBtn icon={I.swap} label="Duplicar"/>
        <DrawerBtn icon={I.close} label="Apagar" danger/>
      </div>
    </div>
  </Screen>
);

const Meta = ({ label, value, link, last }) => (
  <div style={{display:'flex', alignItems:'center', justifyContent:'space-between',
    padding:'12px 0', borderBottom: last?'none':`1px solid ${KITAMO.line2}`}}>
    <div style={{fontSize:13, color: KITAMO.muted, fontWeight:600}}>{label}</div>
    <div style={{fontSize:14, fontWeight:700, color: link ? KITAMO.brandDark : KITAMO.ink}}>{value}</div>
  </div>
);

const DrawerBtn = ({ icon, label, danger }) => (
  <button style={{
    padding:'12px 0', borderRadius:12, border:0,
    background: danger ? '#FEE2E2' : KITAMO.brandSoft,
    color: danger ? KITAMO.danger : KITAMO.brandDark,
    display:'flex', flexDirection:'column', alignItems:'center', gap:4,
    cursor:'pointer', fontSize:13, fontWeight:700,
  }}>
    {icon({size:20})} {label}
  </button>
);

Object.assign(window, {
  ScreenContas, ScreenAdd, ScreenGastos, ScreenDetail,
});
