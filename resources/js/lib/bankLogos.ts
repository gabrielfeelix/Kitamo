// Mapping of bank names to SVG file paths
const bankLogoMap: Record<string, { svgFile: string | null; color: string }> = {
  'Nubank': { svgFile: 'nubank-logo-svg.png', color: '#8B10AE' },
  'Nu Pagamentos S.A': { svgFile: 'nubank-logo-svg.png', color: '#8B10AE' },
  'Banco Inter S.A': { svgFile: 'Banco Inter S.A/inter.svg', color: '#FF7A00' },
  'Banco Inter': { svgFile: 'Banco Inter S.A/inter.svg', color: '#FF7A00' },
  'Inter': { svgFile: 'Banco Inter S.A/inter.svg', color: '#FF7A00' },
  'Itaú': { svgFile: 'Itaú/itau.svg', color: '#EC7000' },
  'Itaú Unibanco': { svgFile: 'Itaú/itau.svg', color: '#EC7000' },
  'Itaú Unibanco S.A.': { svgFile: 'Itaú/itau.svg', color: '#EC7000' },
  'Banco Itaú': { svgFile: 'Itaú/itau.svg', color: '#EC7000' },
  'Itau': { svgFile: 'Itaú/itau.svg', color: '#EC7000' },
  'Bradesco': { svgFile: 'Bradesco S.A/bradesco com nome.svg', color: '#CC092F' },
  'Bradesco S.A': { svgFile: 'Bradesco S.A/bradesco com nome.svg', color: '#CC092F' },
  'Banco do Brasil': { svgFile: 'Banco do Brasil S.A/banco-do-brasil-com-fundo.svg', color: '#FFDD00' },
  'Banco do Brasil S.A': { svgFile: 'Banco do Brasil S.A/banco-do-brasil-com-fundo.svg', color: '#FFDD00' },
  'Caixa': { svgFile: 'Caixa Econômica Federal/caixa-economica-federal-1.svg', color: '#0066B3' },
  'Caixa Econômica Federal': { svgFile: 'Caixa Econômica Federal/caixa-economica-federal-1.svg', color: '#0066B3' },
  'Santander': { svgFile: 'Banco Santander Brasil S.A/banco-santander-logo.svg', color: '#EC0000' },
  'Banco Santander Brasil S.A': { svgFile: 'Banco Santander Brasil S.A/banco-santander-logo.svg', color: '#EC0000' },
  'Banco Santander': { svgFile: 'Banco Santander Brasil S.A/banco-santander-logo.svg', color: '#EC0000' },
  'C6 Bank': { svgFile: 'C6 Bank/c6-bank-logo-oficial-vector.png', color: '#000000' },
  'Banco C6 S.A': { svgFile: 'C6 Bank/c6-bank-logo-oficial-vector.png', color: '#000000' },
  'PicPay': { svgFile: 'PicPay/Logo-PicPay -nome .svg', color: '#21C25E' },
  'Neon': { svgFile: 'Neon/header-logo-neon.svg', color: '#00D9E1' },
  'Banco Safra S.A': { svgFile: 'Banco Safra S.A/logo-safra-nome.svg', color: '#EC7000' },
  'Banco Votorantim': { svgFile: 'Banco Votorantim/banco-bv-logo.svg', color: '#FFD700' },
  'Banco BTG Pacutal': { svgFile: 'Banco BTG Pacutal/btg-pactual-nome .svg', color: '#8B10AE' },
  'Banco Original S.A': { svgFile: 'Banco Original S.A/banco-original-logo-branco-nome.svg', color: '#7D3FF2' },
  'Banco Sofisa': { svgFile: 'Banco Sofisa/logo-banco-sofisa-verde.svg', color: '#FFB81C' },
  'Banco Mercantil do Brasil S.A': { svgFile: 'Banco Mercantil do Brasil S.A/banco-mercantil-novo-azul.svg', color: '#EA5F1A' },
  'Banco Daycoval': { svgFile: 'Banco Daycoval/logo-Daycoval- maior.svg', color: '#0066CC' },
  'Banco Paulista': { svgFile: 'Banco Paulista/banco-paulista-nome.svg', color: '#00AA00' },
  'BRB - Banco de Brasilia': { svgFile: 'BRB - Banco de Brasilia/brb-logo-abreviado.svg', color: '#0051BA' },
  'Banco da Amazônia S.A': { svgFile: 'Banco da Amazônia S.A/banco-da-amazonia.svg', color: '#009639' },
  'Banco do Nordeste do Brasil S.A': { svgFile: 'Banco do Nordeste do Brasil S.A/Logo_BNB.svg', color: '#E71930' },
};

const normalizeText = (value: string) =>
  value
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .trim();

const resolveBankKey = (bankName: string | null | undefined): string | null => {
  if (!bankName) return null;
  if (bankLogoMap[bankName]) return bankName;

  const text = normalizeText(String(bankName));
  if (!text) return null;

  // Common fuzzy matches for labels/nicknames
  const matchers: Array<{ token: string; key: string }> = [
    { token: 'nubank', key: 'Nubank' },
    { token: 'nu pagamentos', key: 'Nubank' },
    { token: 'inter', key: 'Banco Inter' },
    { token: 'itau', key: 'Itaú' },
    { token: 'itaucard', key: 'Itaú' },
    { token: 'bradesco', key: 'Bradesco' },
    { token: 'banco do brasil', key: 'Banco do Brasil' },
    { token: 'bb', key: 'Banco do Brasil' },
    { token: 'caixa', key: 'Caixa' },
    { token: 'santander', key: 'Santander' },
    { token: 'c6', key: 'C6 Bank' },
    { token: 'picpay', key: 'PicPay' },
    { token: 'neon', key: 'Neon' },
  ];

  for (const { token, key } of matchers) {
    if (text.includes(token) && bankLogoMap[key]) return key;
  }

  // Last resort: try exact normalized key match
  for (const key of Object.keys(bankLogoMap)) {
    if (normalizeText(key) === text) return key;
  }

  return null;
};

export const bankInstitutions = [
  { nome: 'Nubank', svgFile: bankLogoMap['Nubank']?.svgFile ?? null, color: bankLogoMap['Nubank']?.color ?? '#64748B' },
  { nome: 'Banco Inter', svgFile: bankLogoMap['Banco Inter']?.svgFile ?? null, color: bankLogoMap['Banco Inter']?.color ?? '#64748B' },
  { nome: 'Itaú', svgFile: bankLogoMap['Itaú']?.svgFile ?? null, color: bankLogoMap['Itaú']?.color ?? '#64748B' },
  { nome: 'Bradesco', svgFile: bankLogoMap['Bradesco']?.svgFile ?? null, color: bankLogoMap['Bradesco']?.color ?? '#64748B' },
  { nome: 'Banco do Brasil', svgFile: bankLogoMap['Banco do Brasil']?.svgFile ?? null, color: bankLogoMap['Banco do Brasil']?.color ?? '#64748B' },
  { nome: 'Caixa', svgFile: bankLogoMap['Caixa']?.svgFile ?? null, color: bankLogoMap['Caixa']?.color ?? '#64748B' },
  { nome: 'Santander', svgFile: bankLogoMap['Santander']?.svgFile ?? null, color: bankLogoMap['Santander']?.color ?? '#64748B' },
  { nome: 'C6 Bank', svgFile: bankLogoMap['C6 Bank']?.svgFile ?? null, color: bankLogoMap['C6 Bank']?.color ?? '#64748B' },
  { nome: 'PicPay', svgFile: bankLogoMap['PicPay']?.svgFile ?? null, color: bankLogoMap['PicPay']?.color ?? '#64748B' },
  { nome: 'Neon', svgFile: bankLogoMap['Neon']?.svgFile ?? null, color: bankLogoMap['Neon']?.color ?? '#64748B' },
  { nome: 'Outro', svgFile: null, color: '#64748B' },
] as const;

export const getBankLogo = (bankName: string | null | undefined): { svgFile: string | null; color: string } | null => {
  const key = resolveBankKey(bankName);
  if (!key) return null;
  return bankLogoMap[key] || null;
};

export const getBankSvgPath = (bankName: string | null | undefined): string | null => {
  const key = resolveBankKey(bankName);
  if (!key) return null;
  const logo = bankLogoMap[key];
  return logo?.svgFile || null;
};

export const getBankColor = (bankName: string | null | undefined): string | null => {
  const key = resolveBankKey(bankName);
  if (!key) return null;
  const logo = bankLogoMap[key];
  return logo?.color || null;
};
