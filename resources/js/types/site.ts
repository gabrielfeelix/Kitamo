export type SiteNavItem = {
    label: string;
    routeName: string;
};

export type SiteExternalLink = {
    label: string;
    href: string;
    note?: string;
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

export const footerResources: SiteNavItem[] = [
    { label: 'Recursos', routeName: 'site.resources' },
    { label: 'Guias', routeName: 'site.resources' },
    { label: 'Newsletter', routeName: 'site.resources' },
];

export const footerLegal: SiteNavItem[] = [
    { label: 'Privacidade', routeName: 'site.privacy' },
    { label: 'Termos de Uso', routeName: 'site.terms' },
];

export const footerSocials: SiteExternalLink[] = [
    { label: 'Instagram', href: '#', note: 'TODO: @kitamo' },
    { label: 'LinkedIn', href: '#', note: 'TODO: /company/kitamo' },
    { label: 'X', href: '#', note: 'TODO: @kitamo' },
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
        subtitle: 'Ideal para começar: controle manual com projeção de 30 dias. Chega de tomar susto no fim do mês.',
        monthly: '0',
        features: [
            'Até 2 contas',
            '1 cartão de crédito',
            'Projeção de 30 dias',
            'Sem backup automático',
        ],
        ctaLabel: 'Testar',
    },
    {
        name: 'Pro',
        subtitle: 'O plano Pro custa R$ 19, mas nossos usuários economizam em média R$ 300 cortando assinaturas esquecidas.',
        monthly: '19',
        features: [
            'Teste o Pro por 14 dias. Cancele com 1 clique.',
            'Acesso gratuito para parceiro(a)',
            'Contas e cartões ilimitados',
            'Projeção de 90 dias',
            'Backup automático',
            'Despesas recorrentes',
        ],
        ctaLabel: 'Assinar',
        highlighted: true,
    },
    {
        name: 'Visionário',
        subtitle: 'Para planejamento avançado com visão de longo prazo.',
        monthly: '49',
        features: [
            'Acesso gratuito para 2 parceiros/familiares',
            'Tudo do Pro',
            'Projeção de até 5 anos',
            'Suporte prioritário via WhatsApp',
            'Estrutura completa sem limites',
        ],
        ctaLabel: 'Assinar Elite',
    },
];

export const pricingFeatureComparisons = [
    { name: "Controle de saldo ao vivo", status: ["Sim", "Sim", "Sim"] },
    { name: "Limite de contas", status: ["Até 2", "Ilimitado", "Ilimitado"] },
    { name: "Limite de cartões", status: ["Até 1", "Ilimitado", "Ilimitado"] },
    { name: "Projeção futura", status: ["30 dias", "90 dias", "5 anos"] },
    { name: "Despesas recorrentes", status: ["Não", "Sim", "Sim"] },
    { name: "Backup automático", status: ["Não", "Sim", "Sim"] },
    { name: "Suporte prioritário WhatsApp", status: ["Não", "Não", "Sim"] },
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
