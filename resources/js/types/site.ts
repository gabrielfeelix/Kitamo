export type SiteNavItem = {
    label: string;
    routeName: string;
};

export type SiteFaqItem = {
    question: string;
    answer: string;
};

export type SitePricingPlan = {
    name: string;
    subtitle: string;
    monthly: string;
    features: string[];
    ctaLabel: string;
    highlighted?: boolean;
};

export const headerNavigation: SiteNavItem[] = [
    { label: 'Produto', routeName: 'site.product' },
    { label: 'Preços', routeName: 'site.pricing' },
    { label: 'Empresa', routeName: 'site.company' },
];

export const footerProduct: SiteNavItem[] = [
    { label: 'Tour', routeName: 'site.product' },
    { label: 'Preços', routeName: 'site.pricing' },
    { label: 'Segurança', routeName: 'site.security' },
];

export const footerCompany: SiteNavItem[] = [
    { label: 'Nossa Missão', routeName: 'site.company' },
    { label: 'Contato', routeName: 'site.contact' },
];

export const footerLegal: SiteNavItem[] = [
    { label: 'Privacidade', routeName: 'site.privacy' },
    { label: 'Termos de Uso', routeName: 'site.terms' },
];

export const homeTrustSignals: string[] = [
    'Projeção financeira diária',
    'Alertas de vencimento críticos',
    'Leitura por categorias e recorrências',
    'Prioridade de ação semanal',
    'Fluxo de decisão guiado',
    'Resumo rápido sem ruído',
];

export const institutionalFaq: SiteFaqItem[] = [
    {
        question: 'O Kitamo é para quem nunca organizou finanças?',
        answer: 'Sim. O fluxo foi desenhado para reduzir fricção: contexto claro, prioridade e próxima ação em sequência.'
    },
    {
        question: 'Preciso preencher tudo manualmente todos os dias?',
        answer: 'Não. O produto prioriza organização automatizada para você focar em decisões e não em tarefas repetitivas.'
    },
    {
        question: 'Consigo usar para planejar o próximo mês?',
        answer: 'Sim. A projeção considera compromissos, recorrências e cenários para antecipar riscos antes do fechamento.'
    },
];

export const pricingPlans: SitePricingPlan[] = [
    {
        name: 'Essencial',
        subtitle: 'Controle mensal básico e visão pura. Sem pegadinhas.',
        monthly: '0',
        features: [],
        ctaLabel: 'Testar',
    },
    {
        name: 'Pro',
        subtitle: 'Automatize sua vida e enxergue o seu trimestre de forma brutal.',
        monthly: '19',
        features: [],
        ctaLabel: 'Assinar',
        highlighted: true,
    },
    {
        name: 'Visionário',
        subtitle: 'Antecipação extrema de 5 anos com acompanhamento VIP no WhatsApp.',
        monthly: '49',
        features: [],
        ctaLabel: 'Assinar Elite',
    },
];

export const pricingFeatureComparisons = [
    { name: "Controle de Saldo ao Vivo", status: ["Sim", "Sim", "Sim"] },
    { name: "Lembrete de Vencimentos", status: ["Sim", "Sim", "Sim"] },
    { name: "Sincronização Bancária Open Finance", status: ["Apenas 2", "Ilimitado", "Ilimitado"] },
    { name: "Dias de Projeção Futura", status: ["Até dia 30.", "Trimestre", "Até 5 anos."] },
    { name: "Alerta de vazamento de assinaturas", status: ["Não", "Sim", "Sim"] },
    { name: "Gestor Dedicado no WhatsApp", status: ["Não", "Não", "Sim"] }
];

export const resourceCards = [
    {
        category: 'Fundamentos',
        title: 'Como sair do modo apagando incêndio financeiro',
        excerpt: 'Roteiro prático para transformar confusão em decisões semanais de baixo atrito.',
        readTime: '8 min',
    },
    {
        category: 'Planejamento',
        title: 'Como montar cenários sem planilha complexa',
        excerpt: 'Uma estrutura simples para testar impacto de escolhas antes de comprometer orçamento.',
        readTime: '10 min',
    },
    {
        category: 'Organização',
        title: 'Assinaturas invisíveis: como recuperar margem mensal',
        excerpt: 'Checklist para identificar cobranças recorrentes esquecidas e cortar desperdício real.',
        readTime: '6 min',
    },
    {
        category: 'Planejamento',
        title: 'Semana financeira: o ritual de 20 minutos',
        excerpt: 'Ritmo semanal para acompanhar risco, ajustar rota e manter constância no controle.',
        readTime: '7 min',
    },
    {
        category: 'Fundamentos',
        title: 'Primeiros 30 dias com um sistema financeiro pessoal',
        excerpt: 'Fases recomendadas para adoção gradual sem sobrecarga.',
        readTime: '9 min',
    },
    {
        category: 'Organização',
        title: 'Categorias que realmente ajudam a decidir',
        excerpt: 'Como organizar despesas para gerar ação, não só relatório.',
        readTime: '5 min',
    },
];
