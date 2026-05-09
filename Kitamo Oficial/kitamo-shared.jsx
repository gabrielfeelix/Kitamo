// Kitamo — shared tokens, icons, primitives

const KITAMO = {
  brand: '#33d6c5',
  brandDark: '#1FB5A4',
  brandSoft: '#E0F9F5',
  brandTint: '#F1FBF9',
  success: '#10B981',
  danger:  '#EF4444',
  warn:    '#F59E0B',
  info:    '#3B82F6',
  ink:     '#0F172A',
  ink2:    '#475569',
  muted:   '#64748B',
  line:    '#E2E8F0',
  line2:   '#EEF2F6',
  bg:      '#F8FAFC',
  white:   '#FFFFFF',
};

// ── Icons (lucide-style stroke 2) ────────────────────────────
const IconBase = ({ size = 24, children, stroke = 'currentColor', fill = 'none' }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill={fill} stroke={stroke}
       strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">{children}</svg>
);
const I = {
  home:   (p) => <IconBase {...p}><path d="M3 11l9-8 9 8v10a1 1 0 0 1-1 1h-5v-7h-6v7H4a1 1 0 0 1-1-1z"/></IconBase>,
  bank:   (p) => <IconBase {...p}><path d="M3 21h18M5 21V10M19 21V10M3 10l9-6 9 6M9 21v-7M15 21v-7"/></IconBase>,
  chart:  (p) => <IconBase {...p}><path d="M3 3v18h18M7 14l4-4 3 3 5-6"/></IconBase>,
  user:   (p) => <IconBase {...p}><circle cx="12" cy="8" r="4"/><path d="M4 21c1-4 5-6 8-6s7 2 8 6"/></IconBase>,
  plus:   (p) => <IconBase {...p}><path d="M12 5v14M5 12h14"/></IconBase>,
  bell:   (p) => <IconBase {...p}><path d="M6 9a6 6 0 0 1 12 0c0 5 2 6 2 7H4c0-1 2-2 2-7zM10 20a2 2 0 0 0 4 0"/></IconBase>,
  eye:    (p) => <IconBase {...p}><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/></IconBase>,
  arrow:  (p) => <IconBase {...p}><path d="M5 12h14M13 5l7 7-7 7"/></IconBase>,
  check:  (p) => <IconBase {...p}><path d="M4 12l5 5L20 6"/></IconBase>,
  close:  (p) => <IconBase {...p}><path d="M6 6l12 12M18 6L6 18"/></IconBase>,
  back:   (p) => <IconBase {...p}><path d="M19 12H5M12 5l-7 7 7 7"/></IconBase>,
  down:   (p) => <IconBase {...p}><path d="M6 9l6 6 6-6"/></IconBase>,
  food:   (p) => <IconBase {...p}><path d="M3 11h18M5 11v8a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2v-8M8 7c0-2 2-4 4-4s4 2 4 4"/></IconBase>,
  car:    (p) => <IconBase {...p}><path d="M5 17h14l-2-7H7zM7 17v2M17 17v2"/><circle cx="8" cy="17" r="1.5"/><circle cx="16" cy="17" r="1.5"/></IconBase>,
  house:  (p) => <IconBase {...p}><path d="M3 11l9-7 9 7v9a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1z"/></IconBase>,
  health: (p) => <IconBase {...p}><path d="M12 5l-3 7h2v6l3-7h-2z"/><circle cx="12" cy="12" r="9"/></IconBase>,
  game:   (p) => <IconBase {...p}><rect x="2" y="7" width="20" height="10" rx="3"/><path d="M7 11v2M6 12h2M15 12h.01M18 12h.01"/></IconBase>,
  bolt:   (p) => <IconBase {...p}><path d="M13 2L4 14h7l-1 8 9-12h-7z"/></IconBase>,
  card:   (p) => <IconBase {...p}><rect x="2" y="6" width="20" height="13" rx="2"/><path d="M2 11h20"/></IconBase>,
  wallet: (p) => <IconBase {...p}><path d="M3 7a2 2 0 0 1 2-2h13a2 2 0 0 1 2 2v3"/><path d="M21 10v8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V7"/><circle cx="17" cy="14" r="1.2" fill="currentColor"/></IconBase>,
  send:   (p) => <IconBase {...p}><path d="M3 12l18-9-7 18-3-7z"/></IconBase>,
  recv:   (p) => <IconBase {...p}><path d="M21 12L3 21l7-18 3 7z"/></IconBase>,
  swap:   (p) => <IconBase {...p}><path d="M7 4v16M3 8l4-4 4 4M17 20V4M21 16l-4 4-4-4"/></IconBase>,
  tag:    (p) => <IconBase {...p}><path d="M3 12V4h8l10 10-8 8z"/><circle cx="7.5" cy="7.5" r="1.2" fill="currentColor" stroke="none"/></IconBase>,
  target: (p) => <IconBase {...p}><circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="5"/><circle cx="12" cy="12" r="1.5" fill="currentColor"/></IconBase>,
  lock:   (p) => <IconBase {...p}><rect x="4" y="11" width="16" height="10" rx="2"/><path d="M8 11V7a4 4 0 0 1 8 0v4"/></IconBase>,
  help:   (p) => <IconBase {...p}><circle cx="12" cy="12" r="9"/><path d="M9 9a3 3 0 0 1 6 0c0 2-3 2-3 4M12 17h.01"/></IconBase>,
  info:   (p) => <IconBase {...p}><circle cx="12" cy="12" r="9"/><path d="M12 8h.01M11 12h1v5h1"/></IconBase>,
  imp:    (p) => <IconBase {...p}><path d="M12 3v12M7 10l5 5 5-5M5 21h14"/></IconBase>,
  exp:    (p) => <IconBase {...p}><path d="M12 21V9M7 14l5-5 5 5M5 3h14"/></IconBase>,
  bot:    (p) => <IconBase {...p}><rect x="4" y="8" width="16" height="11" rx="3"/><path d="M12 4v4M9 14h.01M15 14h.01M9 17h6"/></IconBase>,
  spark:  (p) => <IconBase {...p}><path d="M12 3l2 5 5 2-5 2-2 5-2-5-5-2 5-2zM18 14l1 2 2 1-2 1-1 2-1-2-2-1 2-1z"/></IconBase>,
  bulb:   (p) => <IconBase {...p}><path d="M9 18h6M10 21h4M8 14a5 5 0 1 1 8 0c-1 1-1 2-1 4H9c0-2 0-3-1-4z"/></IconBase>,
  face:   (p) => <IconBase {...p}><circle cx="12" cy="12" r="9"/><circle cx="9" cy="10" r="0.8" fill="currentColor"/><circle cx="15" cy="10" r="0.8" fill="currentColor"/><path d="M9 15c1 1 2 1.5 3 1.5s2-.5 3-1.5"/></IconBase>,
  shield: (p) => <IconBase {...p}><path d="M12 3l8 3v6c0 5-4 8-8 9-4-1-8-4-8-9V6z"/><path d="M9 12l2 2 4-4"/></IconBase>,
  dots:   (p) => <IconBase {...p}><circle cx="6" cy="12" r="1.5" fill="currentColor"/><circle cx="12" cy="12" r="1.5" fill="currentColor"/><circle cx="18" cy="12" r="1.5" fill="currentColor"/></IconBase>,
  chat:   (p) => <IconBase {...p}><path d="M4 5a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2h-7l-5 4v-4H6a2 2 0 0 1-2-2z"/></IconBase>,
  google: (p) => <IconBase {...p} stroke="none" fill="currentColor"><path d="M21.6 12.2c0-.7-.1-1.4-.2-2H12v3.8h5.4c-.2 1.3-1 2.4-2 3.1v2.6h3.3c1.9-1.8 3-4.4 3-7.5z"/><path d="M12 22c2.7 0 5-1 6.6-2.4l-3.3-2.5c-.9.6-2 1-3.3 1-2.6 0-4.7-1.7-5.5-4H3.1v2.5C4.7 19.6 8.1 22 12 22z" opacity=".8"/><path d="M6.5 14.1A6 6 0 0 1 6.2 12c0-.7.1-1.4.3-2.1V7.3H3.1A10 10 0 0 0 2 12c0 1.6.4 3.2 1.1 4.6z" opacity=".6"/><path d="M12 6c1.5 0 2.8.5 3.8 1.5l2.9-2.9C17 3 14.7 2 12 2 8.1 2 4.7 4.4 3.1 7.3l3.4 2.6C7.3 7.7 9.4 6 12 6z" opacity=".9"/></IconBase>,
};

// ── Status bar (compact) ────────────────────────────────────
const StatusBar = ({ light = false }) => {
  const c = light ? '#fff' : KITAMO.ink;
  return (
    <div style={{height: 44, display:'flex', alignItems:'center', justifyContent:'space-between', padding:'0 22px', position:'relative', zIndex: 5}}>
      <div style={{fontSize: 15, fontWeight: 600, color: c, fontVariantNumeric:'tabular-nums'}}>9:41</div>
      <div style={{display:'flex', gap:5, alignItems:'center'}}>
        <svg width="17" height="11" viewBox="0 0 17 11"><rect x="0" y="7" width="3" height="4" rx="0.6" fill={c}/><rect x="4.5" y="5" width="3" height="6" rx="0.6" fill={c}/><rect x="9" y="2.5" width="3" height="8.5" rx="0.6" fill={c}/><rect x="13.5" y="0" width="3" height="11" rx="0.6" fill={c}/></svg>
        <svg width="24" height="11" viewBox="0 0 24 11"><rect x="0.5" y="0.5" width="20" height="10" rx="2.5" stroke={c} strokeOpacity="0.4" fill="none"/><rect x="2" y="2" width="17" height="7" rx="1.5" fill={c}/><path d="M22 4v3c.6-.2 1-.8 1-1.5S22.6 4.2 22 4z" fill={c} opacity="0.5"/></svg>
      </div>
    </div>
  );
};

// ── Bottom navbar ───────────────────────────────────────────
const TabBar = ({ active = 'home', onTab = () => {} }) => {
  const tab = (id, label, icon) => {
    const isOn = active === id;
    return (
      <button onClick={() => onTab(id)} style={{
        flex: 1, background:'none', border:0, padding:'8px 0', cursor:'pointer',
        display:'flex', flexDirection:'column', alignItems:'center', gap:4,
        color: isOn ? KITAMO.brandDark : KITAMO.muted,
      }}>
        {icon({ size: 22 })}
        <span style={{fontSize:11, fontWeight: isOn ? 700 : 500, letterSpacing:-0.1}}>{label}</span>
      </button>
    );
  };
  return (
    <div style={{
      position:'absolute', bottom:0, left:0, right:0, height:88,
      background:'#fff', borderTop:`1px solid ${KITAMO.line2}`,
      display:'flex', alignItems:'flex-start', paddingTop:8,
      boxShadow:'0 -2px 12px rgba(15,23,42,0.04)',
    }}>
      {tab('home', 'Início', I.home)}
      {tab('contas', 'Contas', I.bank)}
      <div style={{flex:1, display:'flex', justifyContent:'center', position:'relative'}}>
        <button onClick={() => onTab('add')} aria-label="Adicionar" style={{
          width:60, height:60, borderRadius:30, marginTop:-22,
          background: KITAMO.brand, border:'4px solid #fff',
          color:'#fff', cursor:'pointer', display:'flex', alignItems:'center', justifyContent:'center',
          boxShadow:'0 8px 20px rgba(51,214,197,0.4)',
        }}>{I.plus({ size: 28 })}</button>
      </div>
      {tab('gastos', 'Gastos', I.chart)}
      {tab('eu', 'Eu', I.user)}
    </div>
  );
};

// ── Common screen frame ─────────────────────────────────────
const Screen = ({ children, bg = '#fff', light = false, label }) => (
  <div data-screen-label={label} style={{
    width: 375, height: 812, background: bg, position:'relative',
    overflow:'hidden', borderRadius: 0,
    fontFamily:'"Inter", -apple-system, system-ui, sans-serif',
    color: KITAMO.ink, WebkitFontSmoothing:'antialiased',
  }}>
    <StatusBar light={light} />
    {children}
  </div>
);

// ── Bank / category visuals ─────────────────────────────────
const BankAvatar = ({ name, color, size = 40 }) => (
  <div style={{
    width:size, height:size, borderRadius:size/2, background: color,
    display:'flex', alignItems:'center', justifyContent:'center',
    color:'#fff', fontSize: size*0.42, fontWeight:700, flexShrink:0,
    boxShadow:'inset 0 0 0 1px rgba(255,255,255,0.15)',
  }}>{name[0]}</div>
);

const CatIcon = ({ icon, color, size = 40 }) => (
  <div style={{
    width:size, height:size, borderRadius: size/2.6, flexShrink: 0,
    background: color + '22', color: color,
    display:'flex', alignItems:'center', justifyContent:'center',
  }}>{icon({ size: size * 0.5 })}</div>
);

// Imagery for "look": placeholder hatched bg
const Hatch = ({ w = '100%', h = 80, label }) => (
  <div style={{
    width:w, height:h, borderRadius:12,
    background:`repeating-linear-gradient(45deg, ${KITAMO.line2} 0 6px, #fff 6px 12px)`,
    border:`1px dashed ${KITAMO.line}`, color: KITAMO.muted,
    display:'flex', alignItems:'center', justifyContent:'center',
    fontFamily:'"JetBrains Mono", ui-monospace, monospace', fontSize:11,
  }}>{label}</div>
);

Object.assign(window, { KITAMO, I, StatusBar, TabBar, Screen, BankAvatar, CatIcon, Hatch });
