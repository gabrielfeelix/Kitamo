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

export const siteNavigation: SiteNavItem[] = [
    { label: 'Home', routeName: 'site.home' },
    { label: 'Produto', routeName: 'site.product' },
    { label: 'Funcionalidades', routeName: 'site.features' },
    { label: 'Segurança', routeName: 'site.security' },
    { label: 'Preços', routeName: 'site.pricing' },
    { label: 'Recursos', routeName: 'site.resources' },
    { label: 'Empresa', routeName: 'site.company' },
    { label: 'Contato', routeName: 'site.contact' },
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
        subtitle: 'Controle diário com visão clara do mês',
        monthly: 'R$ 0',
        features: ['Painel de visão mensal', 'Alertas básicos', 'Resumo por categorias'],
        ctaLabel: 'Começar grátis',
    },
    {
        name: 'Controle',
        subtitle: 'Para quem quer antecipar risco e agir cedo',
        monthly: 'R$ 29',
        features: ['Projeção avançada', 'Alertas inteligentes', 'Fluxo de decisão semanal'],
        ctaLabel: 'Testar plano Controle',
        highlighted: true,
    },
    {
        name: 'Pro',
        subtitle: 'Planejamento mais profundo para metas',
        monthly: 'R$ 59',
        features: ['Cenários completos', 'Priorização por objetivos', 'Suporte prioritário'],
        ctaLabel: 'Falar com time',
    },
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
