<script setup lang="ts">
import { computed, onMounted, ref } from 'vue';
import { Link, router, usePage } from '@inertiajs/vue3';
import { requestFormData, requestJson } from '@/lib/kitamoApi';
import { buildTransactionFormData, buildTransactionRequest, executeTransfer, hasTransactionReceipt } from '@/lib/transactions';
import { getBankSvgPath } from '@/lib/bankLogos';
import type { BootstrapData, CreditCard, Entry, Goal } from '@/types/kitamo';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import TransactionModal, { type TransactionModalPayload } from '@/Components/TransactionModal.vue';
import TransactionDetailModal, { type TransactionDetail } from '@/Components/TransactionDetailModal.vue';
import type { AccountOption } from '@/Components/AccountPickerSheet.vue';
import type { CategoryOption } from '@/Components/CategoryPickerSheet.vue';
import MobileToast from '@/Components/MobileToast.vue';
import CreditCardModal, { type CreditCardModalPayload } from '@/Components/CreditCardModal.vue';
import OnboardingModal from '@/Components/OnboardingModal.vue';
import CreateAccountFlowModal from '@/Components/CreateAccountFlowModal.vue';
import CreateCreditCardFlowModal from '@/Components/CreateCreditCardFlowModal.vue';
import Modal from '@/Components/Modal.vue';
import HomeWidgetsManager from '@/Components/HomeWidgetsManager.vue';
import InstitutionMissingAlert from '@/Components/InstitutionMissingAlert.vue';
import FixInstitutionModal, { type PendingItem } from '@/Components/FixInstitutionModal.vue';
import InstitutionAvatar from '@/Components/InstitutionAvatar.vue';
import { useIsMobile } from '@/composables/useIsMobile';

type ProjecaoResponse = {
    projecao_diaria: Array<{
        data: string;
        saldo: number;
    }>;
    saldo_dia_30: number;
    primeiro_dia_negativo: string | null;
};

const page = usePage();
const userName = computed(() => page.props.auth?.user?.name ?? 'Gabriel');
const firstName = computed(() => String(userName.value).trim().split(/\s+/)[0] ?? userName.value);
const avatarUrl = computed(() => (page.props as any)?.auth?.user?.avatar_url ?? (page.props as any)?.auth?.user?.profile_photo_url ?? null);
const userEmail = computed(() => String((page.props as any)?.auth?.user?.email ?? '').toLowerCase());
const isAdminEmail = computed(() => userEmail.value === 'contato@kitamo.com.br');
const bootstrap = computed(
    () => (page.props.bootstrap ?? { entries: [], goals: [], accounts: [], categories: [], tags: [] }) as BootstrapData,
);

const isMobile = useIsMobile();

type HomeWidgetsState = {
    accounts: boolean;
    creditCards: boolean;
    projection: boolean;
    upcomingBills: boolean;
};
const HOME_WIDGETS_KEY = 'kitamo:home_widgets';
const homeWidgets = ref<HomeWidgetsState>({
    accounts: true,
    creditCards: true,
    projection: true,
    upcomingBills: true,
});

const loadHomeWidgets = () => {
    try {
        const raw = localStorage.getItem(HOME_WIDGETS_KEY);
        if (!raw) return;
        const parsed = JSON.parse(raw) as Partial<HomeWidgetsState>;
        homeWidgets.value = { ...homeWidgets.value, ...parsed };
    } catch {
        // ignore
    }
};

const unreadNotifications = ref(0);
const loadUnreadNotifications = async () => {
    try {
        const response = await requestJson<{ count: number }>(route('api.notifications.count-unread'));
        unreadNotifications.value = Number(response.count ?? 0);
    } catch {
        // ignore
    }
};

const showAccountsSection = computed(() => homeWidgets.value.accounts);
const showCreditCardsSection = computed(() => homeWidgets.value.creditCards);
const showProjectionSection = computed(() => homeWidgets.value.projection);
const showUpcomingBillsSection = computed(() => homeWidgets.value.upcomingBills);

const initials = computed(() => {
    const parts = String(userName.value).trim().split(/\s+/).filter(Boolean);
    const first = parts[0]?.[0] ?? 'G';
    const last = parts.length > 1 ? parts[parts.length - 1]?.[0] : 'F';
    return `${first}${last}`.toUpperCase();
});

const todayLabel = computed(() =>
    new Intl.DateTimeFormat('pt-BR', {
        day: 'numeric',
        month: 'long',
        year: 'numeric',
    }).format(new Date()),
);

const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() =>
    isMobile.value
        ? { showNav: true }
        : {
              title: 'Visão Geral',
              subtitle: todayLabel.value,
              searchPlaceholder: 'Buscar transação…',
              newActionLabel: 'Nova Transação',
          },
);

const formatBRL = (value: number) =>
    new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL',
    }).format(value);

const desktopEntries = ref<Entry[]>(bootstrap.value.entries ?? []);
const desktopGoals = ref<Goal[]>(bootstrap.value.goals ?? []);

const computeTotals = (items: Entry[]) => {
    let income = 0;
    let expense = 0;
    for (const entry of items) {
        if (entry.kind === 'income') income += entry.amount;
        else expense += entry.amount;
    }
    return { income, expense, balance: income - expense };
};

const saldoAtual = ref(0);
const receitas = ref(0);
const despesas = ref(0);
const hideValues = ref(false);
const homeWidgetsModalOpen = ref(false);
const accountMenuOpen = ref(false);
const shouldShowOnboarding = computed(() => {
    const user = (page.props as any)?.auth?.user ?? null;
    if (!user) return false;

    const completedAt = user.onboarding_completed_at;
    if (completedAt) return false;

    const createdAt = user.created_at;
    const created = createdAt ? new Date(createdAt) : null;
    const release = new Date('2026-01-29T00:00:00');

    // Compat: se a coluna não existe ainda (undefined), trate usuários antigos como já onboarded.
    if ((completedAt === undefined || completedAt === null) && created && Number.isFinite(created.getTime()) && created < release) {
        return false;
    }

    return completedAt == null;
});
const onboardingOpen = ref(shouldShowOnboarding.value);

const fixInstitutionModalOpen = ref(false);
const institutionAlertDismissed = ref(false);
const INSTITUTION_ALERT_KEY = 'kitamo:institution_alert_dismissed:v1';

const computeSaldoTotal = () => {
    return (bootstrap.value.accounts ?? [])
        .filter((a) => a.type !== 'credit_card')
        .filter((a) => a.incluir_soma ?? true)
        .reduce((sum, a) => sum + Number(a.current_balance ?? 0), 0);
};

const syncTotals = () => {
    const totals = computeTotals(desktopEntries.value);
    saldoAtual.value = computeSaldoTotal();
    receitas.value = totals.income;
    despesas.value = totals.expense;
};

syncTotals();

const formatBRLMasked = (value: number) => (hideValues.value ? 'R$ ••••' : formatBRL(value));

const setHideValues = (next: boolean) => {
    hideValues.value = next;
    try {
        localStorage.setItem('kitamo_hide_values', next ? '1' : '0');
    } catch {
        // ignore
    }
};

try {
    hideValues.value = localStorage.getItem('kitamo_hide_values') === '1';
} catch {
    // ignore
}

const parseISODateLocal = (iso?: string | null) => {
    if (!iso) return null;
    const parts = String(iso).split('-').map((v) => Number(v));
    if (parts.length !== 3) return null;
    const [yyyy, mm, dd] = parts;
    if (!Number.isFinite(yyyy) || !Number.isFinite(mm) || !Number.isFinite(dd)) return null;
    const date = new Date(yyyy, mm - 1, dd);
    return Number.isFinite(date.getTime()) ? date : null;
};

const cashflowSeries = computed(() => {
    const entries = desktopEntries.value;
    if (!entries.length) return [];

    const monthLabels = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    const now = new Date();
    const months = Array.from({ length: 6 }, (_, idx) => {
        const date = new Date(now.getFullYear(), now.getMonth() - (5 - idx), 1);
        return {
            key: `${date.getFullYear()}-${date.getMonth() + 1}`,
            label: monthLabels[date.getMonth()],
            total: 0,
            highlight: idx === 5,
        };
    });

    for (const entry of entries) {
        if (!entry.transactionDate) continue;
        const date = parseISODateLocal(entry.transactionDate) ?? new Date(entry.transactionDate);
        const key = `${date.getFullYear()}-${date.getMonth() + 1}`;
        const target = months.find((m) => m.key === key);
        if (!target) continue;
        target.total += entry.kind === 'income' ? entry.amount : -entry.amount;
    }

    const maxValue = Math.max(...months.map((m) => Math.abs(m.total)), 1);

    return months.map((month) => {
        const ratio = Math.abs(month.total) / maxValue;
        const height = Math.round(70 + ratio * 90);
        const tone = ratio > 0.66 ? 'bg-[#14B8A6]' : ratio > 0.33 ? 'bg-[#34D399]' : 'bg-[#A7F3D0]';
        return {
            label: month.label,
            height,
            amount: Math.abs(month.total),
            tone,
            highlight: month.highlight,
        };
    });
});

type UpcomingBill = {
    id: string;
    month: string;
    day: string;
    title: string;
    subtitle: string;
    amountLabel: string;
    paid: boolean;
};

const buildUpcomingBills = (entries: Entry[]): UpcomingBill[] => {
    const formatter = new Intl.DateTimeFormat('pt-BR', { month: 'short' });

    return entries
        .filter((entry) => entry.kind === 'expense')
        .filter((entry) => Boolean(entry.transactionDate))
        .filter((entry) => entry.status !== 'paid') // Excluir contas pagas
        .map((entry) => {
            const date = parseISODateLocal(entry.transactionDate) ?? new Date();
            const month = formatter.format(date).replace('.', '').toLowerCase();
            const day = String(date.getDate()).padStart(2, '0');
            return {
                id: entry.id,
                month,
                day,
                title: entry.title,
                subtitle: entry.categoryLabel,
                amountLabel: formatBRL(entry.amount),
                paid: entry.status === 'paid',
                // used only for sorting
                _date: date,
            };
        })
        .sort((a, b) => ((a as any)._date as Date).getTime() - ((b as any)._date as Date).getTime())
        .slice(0, 3);
};

const upcomingBills = computed(() => buildUpcomingBills(desktopEntries.value));

const recentEntries = computed(() => {
    return desktopEntries.value
        .filter((entry) => Boolean(entry.transactionDate))
        .sort((a, b) => {
            const dateA = parseISODateLocal(a.transactionDate) ?? new Date();
            const dateB = parseISODateLocal(b.transactionDate) ?? new Date();
            return dateB.getTime() - dateA.getTime();
        })
        .slice(0, 5);
});

const formatEntryDate = (date?: string) => {
    if (!date) return '';
    const entryDate = parseISODateLocal(date) ?? new Date(date);
    const today = new Date();
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);

    if (entryDate.toDateString() === today.toDateString()) return 'Hoje';
    if (entryDate.toDateString() === yesterday.toDateString()) return 'Ontem';

    return new Intl.DateTimeFormat('pt-BR', { day: '2-digit', month: '2-digit' }).format(entryDate);
};

const bankAccounts = computed(() =>
    (bootstrap.value.accounts ?? [])
        .filter((account) => account.type !== 'credit_card')
        .map((account) => {
            const institution = account.institution ?? null;
            const svgPath = (account as any).svgPath ?? null;
            const logoName = institution ?? account.name ?? null;
            return {
                id: account.id,
                label: account.name,
                subtitle: 'Saldo atual',
                amount: account.current_balance,
                color:
                    account.color ??
                    (account.type === 'wallet' ? '#14B8A6' : '#3B82F6'),
                institution,
                svgPath: svgPath ?? getBankSvgPath(logoName),
                type: account.type,
                icon: account.icon ?? (account.type === 'wallet' ? 'wallet' : 'bank'),
            };
        }),
);

const accountsCountLabel = computed(() => {
    const total = bankAccounts.value.length || 0;
    return `${total}\u00A0conta${total === 1 ? '' : 's'}`;
});

const creditCards = computed(() =>
    (bootstrap.value.accounts ?? [])
        .filter((account) => account.type === 'credit_card')
        .map((account) => {
            const institution = account.institution ?? null;
            const svgPath = (account as any).svgPath ?? null;
            const logoName = institution ?? account.name ?? null;
            return {
                id: account.id,
                label: account.name,
                brand: (account.card_brand ?? 'visa') as string,
                color: account.color ?? '#8B5CF6',
                limit: Number(account.credit_limit ?? 0),
                used: Math.max(0, Number(account.current_balance ?? 0)),
                closingDay: Number(account.closing_day ?? 0) || null,
                dueDay: Number(account.due_day ?? 0) || null,
                institution,
                svgPath: svgPath ?? (logoName ? getBankSvgPath(logoName) : null),
                is_primary: Boolean((account as any).is_primary ?? false),
            };
        }),
);

const creditCardsApi = ref<CreditCard[]>([]);
const loadCreditCardsApi = async () => {
    // Se já veio via bootstrap.accounts, não precisa
    if (creditCards.value.length > 0) return;
    try {
        const response = await requestJson<{ cartoes: CreditCard[] }>('/api/cartoes', { method: 'GET' });
        creditCardsApi.value = response.cartoes ?? [];
    } catch {
        creditCardsApi.value = [];
    }
};

type CreditCardTab = 'open' | 'closed';
type CreditCardTabV2 = 'all' | CreditCardTab;
const creditCardsTab = ref<CreditCardTabV2>('all');

const formatLongDate = (date: Date) =>
    new Intl.DateTimeFormat('pt-BR', { day: 'numeric', month: 'long', year: 'numeric' }).format(date);

const nextDateByDayOfMonth = (dayOfMonth: number, from: Date) => {
    const year = from.getFullYear();
    const month = from.getMonth();
    const todayDay = from.getDate();
    const targetMonth = todayDay <= dayOfMonth ? month : month + 1;
    // clamp para último dia do mês
    const lastDay = new Date(year, targetMonth + 1, 0).getDate();
    const day = Math.min(dayOfMonth, lastDay);
    return new Date(year, targetMonth, day);
};

const isInvoiceClosed = (closingDay: number | null, now: Date) => {
    if (!closingDay) return false;
    return now.getDate() > closingDay;
};

const creditCardsDisplay = computed(() => {
    const now = new Date();

    const source =
        creditCards.value.length > 0
            ? creditCards.value.map((c) => ({
                  id: c.id,
                  label: c.label,
                  brand: c.brand,
                  color: c.color,
                  limit: c.limit,
                  used: c.used,
                  closingDay: c.closingDay,
                  dueDay: c.dueDay,
                  institution: (c as any).institution ?? null,
                  svgPath: (c as any).svgPath ?? null,
                  is_primary: (c as any).is_primary ?? false,
              }))
            : creditCardsApi.value.map((c) => ({
                  id: c.id,
                  label: c.nome,
                  brand: c.bandeira,
                  color: c.cor,
                  limit: c.limite,
                  used: c.limite_usado ?? 0,
                  closingDay: c.dia_fechamento ?? null,
                  dueDay: c.dia_vencimento ?? null,
                  institution: (c as any).banco ?? null,
                  svgPath: (c as any).svgPath ?? null,
                  is_primary: c.is_primary ?? false,
              }));

    return source
        .map((card) => {
            const percent = card.limit > 0 ? Math.min(100, Math.max(0, (card.used / card.limit) * 100)) : 0;
            const available = card.limit > 0 ? Math.max(0, card.limit - card.used) : 0;
            const closed = isInvoiceClosed(card.closingDay, now);
            const closingDate = card.closingDay ? nextDateByDayOfMonth(card.closingDay, now) : null;
            return {
                ...card,
                percent,
                available,
                closed,
                closingDateLabel: closingDate ? formatLongDate(closingDate) : null,
                percentLabel: `${percent.toFixed(2)}%`,
                brandLabel: card.brand === 'mastercard' ? 'Mastercard' : card.brand === 'elo' ? 'Elo' : card.brand === 'amex' ? 'Amex' : 'Visa',
            };
        })
        .filter((card) => {
            if (creditCardsTab.value === 'all') return true;
            return creditCardsTab.value === 'open' ? !card.closed : card.closed;
        });
});

const creditCardsTotalCount = computed(() => {
    const fromBootstrap = creditCards.value.length > 0 ? creditCards.value.length : 0;
    const fromApi = creditCardsApi.value.length > 0 ? creditCardsApi.value.length : 0;
    return fromBootstrap > 0 ? fromBootstrap : fromApi;
});

const creditCardsCountLabel = computed(() => {
    const total = creditCardsTotalCount.value || 0;
    return `${total}\u00A0${total === 1 ? 'cartão' : 'cartões'}`;
});

const creditCardsTotalUsed = computed(() => creditCardsDisplay.value.reduce((sum, c) => sum + (c.used || 0), 0));

const mobileAccounts = computed(() =>
    (bootstrap.value.accounts ?? []).slice(0, 3).map((account) => ({
        id: account.id,
        name: account.name,
        subtitle: account.type === 'credit_card' ? 'Fatura aberta' : 'Saldo atual',
        amount: account.current_balance ?? 0,
        type: account.type,
    })),
);

const projecao = computed(() => ((page.props as unknown as { projecao?: ProjecaoResponse }).projecao ?? null) as ProjecaoResponse | null);

const hasProjection = computed(() => Boolean(projecao.value?.projecao_diaria?.length));

type ProjectionBar = {
    key: string;
    label: string;
    labelShort: string;
    saldo: number;
    tone: string;
    heightPx: number;
    topPx: number;
    showCriticalBadge: boolean;
};

const formatDDMM = (isoDate: string) => {
    const [yyyy, mm, dd] = isoDate.split('-');
    if (!yyyy || !mm || !dd) return isoDate;
    return `${dd}/${mm}`;
};

const formatDDMon = (isoDate: string) => {
    const [yyyy, mm, dd] = isoDate.split('-').map((part) => part.trim());
    const months = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
    const monthIdx = Number(mm) - 1;
    const month = months[monthIdx] ?? mm;
    return `${dd}/${month}`;
};

const monthNameFromDDMM = (ddmm: string) => {
    const match = String(ddmm ?? '').trim().match(/^(\d{2})\/(\d{2})$/);
    if (!match) return '';
    const [, dd, mm] = match;
    const monthIndex = Number(mm) - 1;
    if (!Number.isFinite(monthIndex) || monthIndex < 0 || monthIndex > 11) return '';
    const date = new Date(new Date().getFullYear(), monthIndex, Number(dd) || 1);
    const long = new Intl.DateTimeFormat('pt-BR', { month: 'long' }).format(date);
    return long ? long.charAt(0).toUpperCase() + long.slice(1) : '';
};

const negativeMonthLabel = computed(() => {
    const ddmm = projecao.value?.primeiro_dia_negativo;
    if (!ddmm) return '';
    return monthNameFromDDMM(ddmm);
});

const projectionSeries = computed(() => {
    if (!projecao.value) return null;
    const data = projecao.value.projecao_diaria ?? [];
    if (!data.length) return null;

    const desiredBars = 6;
    const indices =
        data.length <= desiredBars
            ? data.map((_, idx) => idx)
            : Array.from({ length: desiredBars }, (_, idx) => Math.round((idx * (data.length - 1)) / (desiredBars - 1)));

    const sampled = indices.map((idx) => data[idx]!).filter(Boolean);
    const saldos = sampled.map((row) => row.saldo);
    const posMax = Math.max(0, ...saldos);
    const negMin = Math.min(0, ...saldos);

    const chartHeight = 96;
    const baselinePx = posMax === 0 && negMin === 0 ? Math.round(chartHeight / 2) : Math.round((posMax / (posMax - negMin)) * chartHeight);
    const posScale = posMax > 0 ? baselinePx / posMax : 0;
    const negScale = negMin < 0 ? (chartHeight - baselinePx) / Math.abs(negMin) : 0;

    const criticalDDMM = projecao.value.primeiro_dia_negativo;

    const bars: ProjectionBar[] = sampled.map((row) => {
        const label = formatDDMM(row.data);
        const isCritical = Boolean(criticalDDMM && label === criticalDDMM);
        const saldo = row.saldo;
        const tone = saldo < 0 ? 'bg-[#EF4444]' : 'bg-[#14B8A6]';
        const barHeightPx = saldo >= 0 ? Math.round(saldo * posScale) : Math.round(Math.abs(saldo) * negScale);
        const topPx = saldo >= 0 ? Math.max(0, baselinePx - barHeightPx) : baselinePx;

        return {
            key: row.data,
            label,
            labelShort: formatDDMon(row.data),
            saldo,
            tone,
            heightPx: Math.max(2, barHeightPx),
            topPx,
            showCriticalBadge: isCritical,
        };
    });

    return {
        bars,
        baselinePx,
        chartHeight,
    };
});

const hasEntries = computed(() => desktopEntries.value.length > 0);
const hasGoals = computed(() => desktopGoals.value.length > 0);
const hasCashflow = computed(() => cashflowSeries.value.length > 0);
const hasUpcomingBills = computed(() => upcomingBills.value.length > 0);

const toastOpen = ref(false);
const toastMessage = ref('');
const showToast = (message: string) => {
    toastMessage.value = message;
    toastOpen.value = true;
};

const createAccountOpen = ref(false);

const creditCardModalOpen = ref(false);
const createCreditCardFlowOpen = ref(false);

const saveCreditCard = async (payload: CreditCardModalPayload) => {
    try {
        await requestJson('/api/cartoes', {
            method: 'POST',
            body: JSON.stringify({ ...payload, icone: 'credit-card' }),
        });
        showToast('Cartão adicionado com sucesso!');
        creditCardModalOpen.value = false;
        await loadCreditCardsApi();
        router.reload();
    } catch {
        showToast('Não foi possível adicionar o cartão');
    }
};

const handleCreateCreditCardFlowSave = async () => {
    // The actual save happens inside CreateCreditCardStep3, which emits 'save'
    // After the flow closes, reload to show the new card
    await loadCreditCardsApi();
    router.reload();
};

const isRecurringEntry = (entry: Entry) => Boolean(entry.isRecurring) && !Boolean(entry.installment);

const replaceEntry = (entry: Entry) => {
    const idx = desktopEntries.value.findIndex((item) => item.id === entry.id);
    if (idx >= 0) desktopEntries.value[idx] = entry;
    else desktopEntries.value.unshift(entry);
    syncTotals();
};

const removeEntry = (id: string) => {
    desktopEntries.value = desktopEntries.value.filter((entry) => entry.id !== id);
    syncTotals();
};

const entryToRequest = (entry: Entry) => ({
    kind: entry.kind,
    amount: entry.amount,
    description: entry.title,
    category: entry.categoryLabel,
    account: entry.accountLabel,
    dateKind: entry.transactionDate ? 'other' : 'today',
    dateOther: entry.transactionDate ?? '',
    isPaid: entry.status === 'paid' || entry.status === 'received',
    isInstallment: Boolean(entry.installment),
    installmentCount: entry.installment ? parseInstallmentCount(entry.installment) : undefined,
    tags: entry.tags ?? [],
});

const desktopDrawerOpen = ref(false);
const desktopSelectedEntry = ref<Entry | null>(null);

const mobileDetailOpen = ref(false);
const mobileSelectedEntry = ref<Entry | null>(null);

const formatDetailDate = (date?: string) => {
    if (!date) return '';
    const parsed = parseISODateLocal(date) ?? new Date(date);
    return new Intl.DateTimeFormat('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric' }).format(parsed);
};

const toAccountIcon = (label: string): TransactionDetail['accountIcon'] => {
    const normalized = label.toLowerCase();
    if (normalized.includes('carteira') || normalized.includes('wallet')) return 'wallet';
    if (normalized.includes('card') || normalized.includes('crédito') || normalized.includes('credito')) return 'card';
    return 'bank';
};

const toCategoryIcon = (entry: Entry): TransactionDetail['categoryIcon'] => {
    const icon = (entry.icon ?? '').toLowerCase();
    // Use icon directly if it's a known value
    if (['food', 'home', 'car', 'game', 'heart', 'briefcase', 'pill', 'money', 'trend', 'bolt', 'cart', 'shirt', 'gym', 'sparkles'].includes(icon)) {
        return icon as TransactionDetail['categoryIcon'];
    }
    // Fallback: try to match by name
    const label = (entry.categoryLabel ?? '').toLowerCase();
    if (label.includes('alimentação') || label.includes('comida')) return 'cart';
    if (label.includes('moradia') || label.includes('home')) return 'home';
    if (label.includes('transporte') || label.includes('carro')) return 'car';
    if (label.includes('lazer') || label.includes('game')) return 'sparkles';
    if (label.includes('saúde') || label.includes('health')) return 'heart';
    if (label.includes('salário') || label.includes('renda')) return 'money';
    if (label.includes('trabalho') || label.includes('freelance')) return 'briefcase';
    return 'bolt';
};

const pickerCategories = computed<CategoryOption[]>(() => {
    const mapTone = (label: string) => {
        const k = label.toLowerCase();
        if (k.includes('aliment')) return 'amber';
        if (k.includes('mora') || k.includes('casa')) return 'blue';
        if (k.includes('transp') || k.includes('uber') || k.includes('car')) return 'slate';
        if (k.includes('lazer')) return 'purple';
        if (k.includes('saúd') || k.includes('saude')) return 'red';
        if (k.includes('estud')) return 'green';
        return 'slate';
    };

    const unique = new Map<string, { label: string; icon: string; kind?: 'expense' | 'income'; customColor?: string; tone?: any }>();
    for (const c of bootstrap.value.categories ?? []) {
        const label = c.name;
        const icon = c.icon ?? 'other';
        const kind = c.type === 'income' ? 'income' : c.type === 'expense' ? 'expense' : undefined;
        const current = unique.get(label);
        const mergedKind = current?.kind && kind && current.kind !== kind ? undefined : (current?.kind ?? kind);

        unique.set(label, {
            label,
            icon: current?.icon && current.icon !== 'other' ? current.icon : icon,
            kind: mergedKind,
            customColor: current?.customColor ?? (c.color || undefined),
            tone: current?.tone ?? (!c.icon || /^[a-z]+$/.test(c.icon) ? mapTone(label) : undefined),
        });
    }
    if (!unique.size) return [];
    return Array.from(unique.values()).map((meta) => ({ 
        key: meta.label, 
        label: meta.label,
        icon: meta.icon,
        customColor: meta.customColor,
        tone: meta.tone,
        kind: meta.kind,
    }));
});

const pickerAccounts = computed<AccountOption[]>(() => {
    const accounts: AccountOption[] = [];

    // Add bank accounts and wallets
    for (const a of bootstrap.value.accounts ?? []) {
        if (a.type === 'credit_card') continue;

        accounts.push({
            key: a.name,
            label: a.name,
            subtitle: a.type === 'wallet' ? 'Dinheiro físico' : a.type === 'bank' ? 'Corrente' : 'Conta',
            balance: Number(a.current_balance ?? 0),
            icon: a.icon ?? undefined,
            customColor: (a as any).color,
            type: a.type as 'bank' | 'wallet',
        });
    }

    // Add credit cards
    for (const a of bootstrap.value.accounts ?? []) {
        if (a.type !== 'credit_card') continue;
        const limit = Number(a.credit_limit ?? 0);
        const used = Math.max(0, Number(a.current_balance ?? 0));

        accounts.push({
            key: a.name,
            label: a.name,
            subtitle: 'Cartão de Crédito',
            limit,
            used,
            available: limit - used,
            icon: a.icon ?? undefined,
            customColor: (a as any).color,
            type: 'credit_card',
        });
    }

    return accounts;
});

const mobileTransactionDetail = computed<TransactionDetail | null>(() => {
    const entry = mobileSelectedEntry.value;
    if (!entry) return null;
    const categoryMap = new Map((bootstrap.value.categories ?? []).map((c) => [`${(c.type ?? '')}|${String(c.name ?? '').toLowerCase()}`, c] as const));
    const type = entry.kind === 'income' ? 'income' : 'expense';
    const cat = categoryMap.get(`${type}|${String(entry.categoryLabel ?? '').toLowerCase()}`) ?? null;
    const acc = (bootstrap.value.accounts ?? []).find((a) => a.name === entry.accountLabel) ?? null;
    return {
        id: entry.id,
        title: entry.title,
        amount: entry.amount,
        kind: entry.kind,
        status: entry.status,
        categoryLabel: entry.categoryLabel,
        categoryIcon: (cat as any)?.icon ?? toCategoryIcon(entry),
        categoryColor: (cat as any)?.color ?? null,
        accountLabel: entry.accountLabel,
        accountIcon: toAccountIcon(entry.accountLabel),
        accountType: (acc?.type ?? null) as any,
        accountInstitution: (acc as any)?.institution ?? null,
        accountSvgPath: (acc as any)?.svgPath ?? null,
        accountColor: (acc as any)?.color ?? null,
        accountSystemIcon: (acc as any)?.icon ?? null,
        dateLabel: formatDetailDate(entry.transactionDate) || entry.dateLabel,
        installmentLabel: entry.installment ?? undefined,
        receiptUrl: entry.receiptUrl ?? null,
        receiptName: entry.receiptName ?? null,
    };
});

const transactionOpen = ref(false);
const transactionKind = ref<'expense' | 'income' | 'transfer'>('expense');
const transactionInitial = ref<TransactionModalPayload | null>(null);
const transactionLockKind = ref(false);
const openTransaction = (kind: 'expense' | 'income' | 'transfer') => {
    transactionKind.value = kind;
    transactionInitial.value = null;
    transactionLockKind.value = false;
    transactionOpen.value = true;
};

const openAddCardTransaction = (cardName: string) => {
    transactionKind.value = 'expense';
    transactionLockKind.value = true;
    const initial: TransactionModalPayload = {
        kind: 'expense',
        amount: 0,
        description: '',
        category: 'Alimentação',
        account: cardName,
        dateKind: 'today',
        dateOther: '',
        isInstallment: false,
        installmentCount: 1,
        isPaid: false,
        tags: [],
        receiptFile: null,
        receiptUrl: null,
        receiptName: null,
        removeReceipt: false,
        transferFrom: '',
        transferTo: '',
        transferDescription: '',
    };
    if (isMobile.value) {
        transactionInitial.value = initial;
        transactionOpen.value = true;
        return;
    }
    transactionInitial.value = initial;
    transactionOpen.value = true;
};

const openDesktopTransaction = () => openTransaction('expense');

const parseInstallmentCount = (installment?: string | null) => {
    if (!installment) return 3;
    const match = installment.match(/\/\s*(\d+)/);
    if (!match) return 3;
    const count = Number(match[1]);
    return Number.isFinite(count) && count > 0 ? count : 3;
};

const openEntryEdit = (entry: Entry) => {
    const transferChoices = (() => {
        const keys = pickerAccounts.value.filter((a) => a.type !== 'credit_card').map((a) => a.key);
        const from = keys[0] ?? entry.accountLabel ?? '';
        const to = keys.find((k) => k !== from) ?? from;
        return { from, to };
    })();

    transactionKind.value = entry.kind;
    const initial: TransactionModalPayload = {
        id: entry.id,
        kind: entry.kind,
        amount: entry.amount,
        description: entry.title,
        category: entry.categoryLabel,
        account: entry.accountLabel,
        dateKind: entry.transactionDate ? 'other' : 'today',
        dateOther: entry.transactionDate ?? '',
        transactionDate: entry.transactionDate ?? '',
        isInstallment: Boolean(entry.installment),
        installmentCount: parseInstallmentCount(entry.installment),
        isPaid: entry.status === 'paid' || entry.status === 'received',
        tags: entry.tags ?? [],
        receiptFile: null,
        receiptUrl: entry.receiptUrl ?? null,
        receiptName: entry.receiptName ?? null,
        removeReceipt: false,
        transferFrom: transferChoices.from,
        transferTo: transferChoices.to,
        transferDescription: '',
        despesaFixa: Boolean(entry.isFixed),
        repetir: Boolean(entry.isRecurring) && !Boolean(entry.isFixed),
        recurrenceGroupId: entry.recurrenceGroupId ?? null,
        isFixed: Boolean(entry.isFixed),
        recurrenceEveryMonths: entry.recurrenceEveryMonths ?? null,
        recurrenceEndsAt: entry.recurrenceEndsAt ?? null,
    };

    if (isMobile.value) {
        transactionInitial.value = initial;
        transactionOpen.value = true;
        return;
    }

    transactionInitial.value = initial;
    transactionOpen.value = true;
};

const openEntryDetail = (entry: Entry) => {
    if (isMobile.value) {
        mobileSelectedEntry.value = entry;
        mobileDetailOpen.value = true;
        return;
    }

    mobileSelectedEntry.value = entry;
    mobileDetailOpen.value = true;
    desktopSelectedEntry.value = entry;
    desktopDrawerOpen.value = true;
};

const handleDetailEdit = () => {
    const entry = isMobile.value ? mobileSelectedEntry.value : desktopSelectedEntry.value;
    if (!entry) return;
    desktopDrawerOpen.value = false;
    mobileDetailOpen.value = false;
    openEntryEdit(entry);
};

const handleDetailDelete = async () => {
    const target = isMobile.value ? mobileSelectedEntry.value : desktopSelectedEntry.value;
    if (!target) return;
    await requestJson(route('transactions.destroy', target.id), { method: 'DELETE' });
    removeEntry(target.id);
    desktopDrawerOpen.value = false;
    mobileDetailOpen.value = false;
    showToast('Lançamento excluído');
};

const handleDetailMarkPaid = async () => {
    if (!desktopSelectedEntry.value) return;
    if (desktopSelectedEntry.value.kind !== 'expense') return;
    const nextStatus: Entry['status'] = desktopSelectedEntry.value.status === 'paid' ? 'pending' : 'paid';
    const payload = { ...entryToRequest({ ...desktopSelectedEntry.value, status: nextStatus }), isPaid: nextStatus === 'paid' };
    const response = await requestJson<{ entry: Entry }>(route('transactions.update', desktopSelectedEntry.value.id), {
        method: 'PATCH',
        body: JSON.stringify(payload),
    });
    replaceEntry(response.entry);
    desktopSelectedEntry.value = response.entry;
    showToast(nextStatus === 'paid' ? 'Conta marcada como paga' : 'Conta marcada como pendente');
    router.reload({ only: ['bootstrap'] });
};

const onTransactionSave = async (payload: TransactionModalPayload) => {
    if (payload.kind === 'transfer') {
        try {
            await executeTransfer(payload);
            showToast('Transferência realizada');
            router.reload({ only: ['bootstrap'] });
        } catch {
            showToast('Não foi possível realizar a transferência');
        }
        return;
    }

    const url = payload.id ? route('transactions.update', payload.id) : route('transactions.store');
    const method = payload.id ? 'PATCH' : 'POST';

    const response = await (hasTransactionReceipt(payload) ? requestFormData : requestJson)<{ entry: Entry }>(url, {
        method,
        body: hasTransactionReceipt(payload) ? buildTransactionFormData(payload) : JSON.stringify(buildTransactionRequest(payload)),
    });

    replaceEntry(response.entry);
    showToast(payload.id ? 'Lançamento atualizado' : 'Lançamento criado');
};

const toggleBillPaid = async (id: string) => {
    const entry = desktopEntries.value.find((item) => item.id === id);
    if (!entry || entry.kind !== 'expense') return;
    const nextStatus: Entry['status'] = entry.status === 'paid' ? 'pending' : 'paid';
    const payload = { ...entryToRequest({ ...entry, status: nextStatus }), isPaid: nextStatus === 'paid' };

    const response = await requestJson<{ entry: Entry }>(route('transactions.update', entry.id), {
        method: 'PATCH',
        body: JSON.stringify(payload),
    });

    replaceEntry(response.entry);
    if (nextStatus === 'paid') showToast('Conta marcada como paga');
    router.reload({ only: ['bootstrap'] });
};

const openBillDetails = (id: string) => {
    const entry = desktopEntries.value.find((item) => item.id === id);
    if (!entry) return;

    openEntryDetail(entry);
};

const openProfileSettings = () => {
    router.visit(route('settings'));
};

const openAccountMenuOption = (option: 'bank' | 'wallet' | 'card') => {
    accountMenuOpen.value = false;
    if (option === 'bank') {
        createAccountOpen.value = true;
    } else if (option === 'wallet') {
        // Abre o fluxo de carteira
        createAccountOpen.value = true;
    } else if (option === 'card') {
        creditCardModalOpen.value = true;
    }
};

const itemsWithoutInstitution = computed<PendingItem[]>(() => {
    const items: PendingItem[] = [];

    // Check accounts
    for (const account of bootstrap.value.accounts ?? []) {
        if (account.type !== 'credit_card' && account.type !== 'wallet' && !account.institution) {
            items.push({
                id: account.id,
                name: account.name,
                type: 'account',
            });
        }
    }

    // Check credit cards
    for (const account of bootstrap.value.accounts ?? []) {
        if (account.type === 'credit_card' && !account.institution) {
            items.push({
                id: account.id,
                name: account.name,
                type: 'card',
            });
        }
    }

    return items;
});

const showInstitutionAlert = computed(() => {
    return itemsWithoutInstitution.value.length > 0 && !institutionAlertDismissed.value;
});

const openFixInstitutionModal = () => {
    fixInstitutionModalOpen.value = true;
};

const dismissInstitutionAlert = () => {
    institutionAlertDismissed.value = true;
    try {
        localStorage.setItem(INSTITUTION_ALERT_KEY, '1');
    } catch {
        // ignore
    }
};

const handleInstitutionUpdated = () => {
    router.reload();
};

onMounted(() => {
    loadHomeWidgets();
    loadCreditCardsApi();
    loadUnreadNotifications();
    try {
        // Compat: remove flag antigo (não é mais usado)
        localStorage.removeItem('kitamo:onboarding:v1');
    } catch {
        // ignore
    }
    try {
        institutionAlertDismissed.value = localStorage.getItem(INSTITUTION_ALERT_KEY) === '1';
    } catch {
        // ignore
    }
});
</script>

<template>
	    <component :is="Shell" v-bind="shellProps" @add="openTransaction('expense')">
	        <header v-if="isMobile" class="flex items-center justify-between pt-2">
	            <button type="button" @click="openProfileSettings" class="flex items-center gap-3" aria-label="Abrir perfil">
	                <span class="flex h-11 w-11 items-center justify-center overflow-hidden rounded-full bg-slate-200 text-sm font-semibold text-slate-700">
	                    <img v-if="avatarUrl" :src="avatarUrl" alt="" class="h-full w-full object-cover" />
	                    <span v-else>{{ initials }}</span>
	                </span>
	                <div class="leading-tight">
	                    <div class="text-xs font-semibold text-slate-400">OLÁ, {{ firstName.toUpperCase() }}</div>
	                    <div class="text-xl font-semibold tracking-tight text-slate-900">Visão Geral</div>
	                </div>
	            </button>

		            <div class="flex items-center gap-2">
		                <Link
		                    :href="route('accounts.search')"
		                    class="flex h-11 w-11 items-center justify-center rounded-full bg-white text-slate-600 shadow-sm ring-1 ring-slate-200/60 hover:bg-slate-50"
		                    aria-label="Buscar"
		                >
		                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
		                        <circle cx="11" cy="11" r="7" />
		                        <path d="M21 21l-4.3-4.3" />
		                    </svg>
		                </Link>
		                <Link
		                    :href="route('notifications.index')"
		                    class="relative flex h-11 w-11 items-center justify-center rounded-full bg-white text-slate-600 shadow-sm ring-1 ring-slate-200/60 hover:bg-slate-50"
		                    aria-label="Notificações"
		                >
                        <span
                            v-if="unreadNotifications > 0"
                            class="absolute -right-0.5 -top-0.5 inline-flex h-5 min-w-[20px] items-center justify-center rounded-full bg-red-500 px-1.5 text-[10px] font-bold text-white"
                        >
                            {{ unreadNotifications > 9 ? '9+' : unreadNotifications }}
                        </span>
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M6 8a6 6 0 0 1 12 0c0 7 3 7 3 7H3s3 0 3-7" />
                        <path d="M10 21a2 2 0 0 0 4 0" />
	                    </svg>
	                </Link>
		            </div>
		        </header>
            <div :class="[isMobile ? 'contents' : 'mt-8 grid grid-cols-1 lg:grid-cols-12 gap-8 items-start']">
                <div :class="[isMobile ? 'contents' : 'lg:col-span-8 flex flex-col']">            <section class="mt-6 rounded-3xl bg-gradient-to-br from-slate-950 via-slate-900 to-slate-800 p-5 shadow-lg ring-1 ring-slate-900/10">
                <div class="flex items-start justify-between gap-4">
                    <div>
                        <div class="text-[10px] font-semibold uppercase tracking-wide text-slate-300">Saldo Total</div>
                        <div class="mt-2 text-4xl font-semibold tracking-tight text-emerald-400">
                            {{ formatBRLMasked(saldoAtual) }}
                        </div>
                    </div>
                    <div class="flex items-center gap-2">
                        <button
                            type="button"
                            class="mt-1 inline-flex h-10 w-10 items-center justify-center rounded-full bg-white/10 text-white ring-1 ring-white/10"
                            :aria-label="hideValues ? 'Mostrar valores' : 'Ocultar valores'"
                            @click="setHideValues(!hideValues)"
                        >
                            <svg v-if="hideValues" class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12Z" />
                                <path d="M12 15a3 3 0 1 0 0-6" />
                                <path d="M4 4l16 16" />
                            </svg>
                            <svg v-else class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12Z" />
                                <circle cx="12" cy="12" r="3" />
                            </svg>
                        </button>
                    </div>
                </div>

                <div class="mt-4 grid grid-cols-2 gap-3">
                    <Link
                        :href="route('accounts.index', { kind: 'income' })"
                        class="rounded-2xl bg-white/5 p-4 ring-1 ring-white/10"
                        aria-label="Ver receitas"
                    >
                        <div class="flex items-center justify-between text-[10px] font-semibold uppercase tracking-wide text-emerald-300">
                            <span>Entrou</span>
                            <svg class="h-4 w-4 text-white/70" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M9 18l6-6-6-6" />
                            </svg>
                        </div>
                        <div class="mt-1 text-base font-semibold text-white">
                            {{ formatBRLMasked(receitas) }}
                        </div>
                    </Link>

                    <Link
                        :href="route('accounts.index', { kind: 'expense' })"
                        class="rounded-2xl bg-white/5 p-4 ring-1 ring-white/10"
                        aria-label="Ver despesas"
                    >
                        <div class="flex items-center justify-between text-[10px] font-semibold uppercase tracking-wide text-red-300">
                            <span>Saiu</span>
                            <svg class="h-4 w-4 text-white/70" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M9 18l6-6-6-6" />
                            </svg>
                        </div>
                        <div class="mt-1 text-base font-semibold text-white">
                            {{ formatBRLMasked(despesas) }}
                        </div>
                    </Link>
                </div>
            </section>

	        <!-- Alertas de saldo removidos do mobile -->

            <!-- Institution Missing Alert -->
            <section v-if="showInstitutionAlert" class="mt-5">
                <InstitutionMissingAlert
                    :items="itemsWithoutInstitution"
                    @fix-items="openFixInstitutionModal"
                    @dismiss="dismissInstitutionAlert"
                />
            </section>

	        <section v-if="showProjectionSection" class="mt-5 rounded-3xl bg-white p-4 shadow-sm ring-1 ring-slate-200/60">
	            <div class="flex items-center justify-between">
	                <div class="flex items-center gap-3">
	                    <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-emerald-50 text-emerald-600">
	                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M4 19V5" />
                            <path d="M10 19V9" />
                            <path d="M16 19v-4" />
                            <path d="M22 19V7" />
                        </svg>
	                    </span>
	                    <div class="text-base font-semibold text-slate-900">Projeção 30 dias</div>
	                </div>
	                <div
	                    v-if="projecao?.primeiro_dia_negativo"
	                    class="rounded-full bg-red-50 px-3 py-1 text-xs font-semibold text-red-500"
	                >
	                    ⚠️ {{ negativeMonthLabel || projecao.primeiro_dia_negativo }}
	                </div>
	                <div
	                    v-else-if="projecao && projecao.saldo_dia_30 > 0"
	                    class="rounded-full bg-emerald-50 px-3 py-1 text-xs font-semibold text-emerald-600"
	                >
	                    ✅ {{ formatBRL(Math.abs(projecao.saldo_dia_30)) }}
	                </div>
	            </div>

	            <div
	                v-if="projecao?.primeiro_dia_negativo"
	                class="mt-4 rounded-lg border-l-4 border-red-500 bg-red-50 p-4 flex items-start gap-3"
	            >
	                <div class="text-xl text-red-500">⚠️</div>
	                <div class="flex-1">
	                    <h3 class="mb-1 font-semibold text-red-900">
                            Atenção: Seu saldo pode ficar negativo em {{ negativeMonthLabel || 'breve' }}
                        </h3>
	                    <p class="text-sm text-red-700">
	                        No ritmo atual, seu saldo pode ficar negativo a partir do dia {{ projecao.primeiro_dia_negativo }}.
	                    </p>
	                    <Link :href="route('analysis')" class="mt-2 inline-flex text-sm font-medium text-red-600 hover:underline">
	                        Ver análise detalhada →
	                    </Link>
	                </div>
	            </div>

	            <div
	                v-else-if="projecao && projecao.saldo_dia_30 > 0"
	                class="mt-4 rounded-lg border-l-4 border-emerald-500 bg-emerald-50 p-4 flex items-start gap-3"
	            >
	                <div class="text-xl text-emerald-600">✅</div>
	                <div class="flex-1">
	                    <h3 class="mb-1 font-semibold text-emerald-900">Tá tranquilo!</h3>
	                    <p class="text-sm text-emerald-700">
	                        Você pode gastar até {{ formatBRL(Math.abs(projecao.saldo_dia_30)) }} até o fim do mês
	                    </p>
	                </div>
	            </div>

	            <div v-if="hasProjection && projectionSeries" class="mt-4">
	                <div class="relative mx-auto h-24">
	                    <div
	                        class="pointer-events-none absolute left-0 right-0 border-t-2 border-dashed border-[#EF4444]"
	                        :style="{ top: `${projectionSeries.baselinePx}px` }"
	                    ></div>
	                    <div class="pointer-events-none absolute right-0 -translate-y-1/2 text-[10px] font-semibold text-[#EF4444]" :style="{ top: `${projectionSeries.baselinePx}px` }">
	                        Saldo zero
	                    </div>

	                    <div class="grid h-24 grid-cols-6 items-end gap-3">
	                        <div v-for="bar in projectionSeries.bars" :key="bar.key" class="relative h-24 text-center">
	                            <div
	                                v-if="bar.showCriticalBadge"
	                                class="absolute left-1/2 -translate-x-1/2 rounded-full bg-red-50 px-2 py-1 text-[10px] font-semibold text-red-600"
	                                :style="{ top: `${Math.max(0, bar.topPx - 22)}px` }"
	                            >
	                                ⚠️ {{ bar.labelShort }}
	                            </div>
	                            <div
	                                class="mx-auto w-8 rounded-2xl"
	                                :class="bar.tone"
	                                :style="{ height: `${bar.heightPx}px`, position: 'absolute', left: '50%', transform: 'translateX(-50%)', top: `${bar.topPx}px` }"
	                            ></div>
	                            <div class="absolute bottom-0 left-1/2 -translate-x-1/2 translate-y-6 text-[10px] font-semibold text-slate-400">
	                                {{ bar.labelShort }}
	                            </div>
	                        </div>
	                    </div>
	                </div>
	            </div>
	            <div v-else-if="hasCashflow" class="mt-4">
	                <div class="grid grid-cols-6 items-end gap-3">
	                    <div v-for="bar in cashflowSeries" :key="bar.label" class="text-center">
	                        <div class="text-[10px] font-semibold text-slate-400">
	                            {{ hideValues ? '••••' : formatBRL(bar.amount).replace('R$', '').trim() }}
	                        </div>
	                        <div class="mx-auto mt-2 w-8 rounded-2xl" :class="bar.tone" :style="{ height: `${bar.height}px` }"></div>
	                        <div class="mt-2 text-[10px] font-semibold" :class="bar.highlight ? 'text-emerald-600' : 'text-slate-400'">{{ bar.label }}</div>
	                    </div>
	                </div>
	            </div>
            <div v-else class="mt-4 rounded-2xl border border-dashed border-slate-200 bg-slate-50 px-4 py-6 text-center">
                <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-white text-slate-400">
                    <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M4 19V5" />
                        <path d="M10 19V9" />
                        <path d="M16 19v-4" />
                        <path d="M22 19V7" />
                    </svg>
                </div>
                <div class="mt-3 text-sm font-semibold text-slate-900">Sem projeções ainda</div>
                <div class="mt-1 text-xs text-slate-500">Adicione seus primeiros lançamentos para ver o fluxo.</div>
            </div>
	        </section>
                </div>
                <div :class="[isMobile ? 'contents' : 'lg:col-span-4 flex flex-col']">

		        <section v-if="showAccountsSection" class="mt-6 rounded-3xl bg-white p-4 shadow-sm ring-1 ring-slate-200/60">
		            <div class="flex items-center justify-between">
		                <div>
                            <div class="text-lg font-semibold text-slate-900">Contas</div>
                            <div class="mt-0.5 text-xs font-semibold text-slate-400">{{ accountsCountLabel }}</div>
                        </div>
                        <Link :href="route('accounts.overview')" class="rounded-2xl px-3 py-2 text-sm font-semibold text-emerald-600 hover:bg-slate-50">
                            Ver todas
                        </Link>
		            </div>

	            <div v-if="bankAccounts.length === 0" class="mt-4 rounded-2xl border border-slate-200 bg-slate-50 px-4 py-6 text-center">
	                <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-white text-slate-400">
	                    <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
	                        <path d="M3 10h18" />
	                        <path d="M5 10V8l7-5 7 5v2" />
	                        <path d="M6 10v9" />
	                        <path d="M18 10v9" />
	                    </svg>
	                </div>
	                <div class="mt-3 text-sm font-semibold text-slate-900">Você ainda não possui contas cadastradas.</div>
	                <div class="mt-1 text-xs text-slate-500">Adicione uma conta para começar a planejar seu mês.</div>
	                <button type="button" class="mt-4 rounded-full bg-emerald-500 px-4 py-2 text-xs font-semibold text-white" @click="createAccountOpen = true">
	                    Adicionar contas
	                </button>
	            </div>

	            <div v-else class="mt-4 space-y-3">
	                <Link
	                    v-for="account in bankAccounts"
	                    :key="account.id"
	                    :href="route('accounts.show', { accountKey: account.id })"
	                    class="flex items-center justify-between rounded-2xl border border-slate-100 bg-white px-4 py-4 shadow-sm ring-1 ring-slate-200/60"
	                >
	                    <div class="flex items-center gap-3">
		                        <InstitutionAvatar
		                            :institution="account.institution ?? account.label"
		                            :svg-path="account.svgPath"
		                            :is-wallet="account.type === 'wallet' || account.icon === 'wallet'"
		                            :fallback-icon="account.type === 'wallet' || account.icon === 'wallet' ? 'wallet' : 'account'"
		                            container-class="flex h-11 w-11 items-center justify-center overflow-hidden rounded-2xl bg-white"
		                            img-class="h-8 w-8 object-contain"
	                            fallback-icon-class="h-5 w-5 text-white"
	                            :style="account.svgPath ? undefined : { backgroundColor: account.color }"
	                        />
	                        <div>
	                            <div class="text-sm font-semibold text-slate-900">{{ account.label }}</div>
	                            <div class="text-xs text-slate-500">{{ account.subtitle }}</div>
	                        </div>
	                    </div>
	                    <div class="text-sm font-semibold text-slate-900">
	                        {{ hideValues ? 'R$ ••••' : `R$ ${account.amount.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}` }}
	                    </div>
	                </Link>
	            </div>
	        </section>

		        <section v-if="showCreditCardsSection" class="mt-6 rounded-3xl bg-white p-4 shadow-sm ring-1 ring-slate-200/60">
		            <div class="flex items-center justify-between">
		                <div>
                            <div class="text-lg font-semibold text-slate-900">Cartões de crédito</div>
                            <div class="mt-0.5 text-xs font-semibold text-slate-400">{{ creditCardsCountLabel }}</div>
                        </div>
		                <Link :href="route('credit-cards.my-cards')" class="text-sm font-semibold text-emerald-600">Ver todas</Link>
		            </div>

                <div
                    v-if="creditCardsTotalCount > 0"
                    class="mt-4 inline-flex w-full rounded-full bg-slate-50 p-1 ring-1 ring-slate-200/70"
                >
                    <button
                        type="button"
                        class="flex-1 rounded-full px-4 py-2 text-xs font-semibold transition"
                        :class="creditCardsTab === 'all' ? 'bg-emerald-600 text-white shadow-sm' : 'text-slate-500'"
                        @click="creditCardsTab = 'all'"
                    >
                        Todas
                    </button>
                    <button
                        type="button"
                        class="flex-1 rounded-full px-4 py-2 text-xs font-semibold transition"
                        :class="creditCardsTab === 'open' ? 'bg-emerald-600 text-white shadow-sm' : 'text-slate-500'"
                        @click="creditCardsTab = 'open'"
                    >
                        Faturas abertas
                    </button>
                    <button
                        type="button"
                        class="flex-1 rounded-full px-4 py-2 text-xs font-semibold transition"
                        :class="creditCardsTab === 'closed' ? 'bg-emerald-600 text-white shadow-sm' : 'text-slate-500'"
                        @click="creditCardsTab = 'closed'"
                    >
                        Faturas fechadas
                    </button>
                </div>

	            <div v-if="creditCards.length === 0" class="mt-4 rounded-2xl border border-slate-200 bg-slate-50 px-4 py-6 text-center">
	                <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-white text-slate-400">
	                    <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
	                        <rect x="3" y="5" width="18" height="14" rx="3" />
	                        <path d="M3 10h18" />
	                    </svg>
	                </div>
	                <div class="mt-3 text-sm font-semibold text-slate-900">Você ainda não possui cartões cadastrados.</div>
	                <div class="mt-1 text-xs text-slate-500">Melhore seu controle financeiro agora!</div>
	                <button type="button" class="mt-4 rounded-full bg-emerald-500 px-4 py-2 text-xs font-semibold text-white" @click="createCreditCardFlowOpen = true">
	                    Adicionar cartões
	                </button>
	            </div>

		            <div v-else class="mt-4">
	                    <div
	                        v-if="creditCardsDisplay.length === 0"
	                        class="rounded-2xl border border-dashed border-slate-200 bg-slate-50 px-4 py-6 text-center"
	                    >
	                        <div class="text-sm font-semibold text-slate-900">Nada por aqui.</div>
	                        <div class="mt-1 text-xs text-slate-500">Quando houver cartões com esse status, eles aparecem aqui.</div>
	                    </div>

		                <div v-else class="flex gap-3 overflow-x-auto pb-2 scrollbar-hide">
	                        <Link
                            v-for="card in creditCardsDisplay"
                            :key="card.id"
                            :href="route('credit-cards.show', { account: card.id })"
                            class="relative shrink-0 overflow-hidden rounded-3xl p-5 shadow-lg transition hover:shadow-xl"
                            :style="{ backgroundColor: card.color, width: '320px' }"
                        >
                            <div class="relative z-10 flex h-full flex-col justify-between text-white" style="min-height: 180px">
                                <!-- Header -->
                                <div class="flex items-start justify-between">
                                    <div class="flex items-center gap-3">
	                                        <InstitutionAvatar
	                                            :institution="card.institution ?? card.label"
	                                            :svg-path="card.svgPath"
	                                            fallback-icon="credit-card"
	                                            container-class="flex h-11 w-11 items-center justify-center overflow-hidden rounded-2xl bg-white"
	                                            img-class="h-7 w-7 object-contain"
	                                            fallback-icon-class="h-5 w-5 text-slate-600"
	                                        />
                                        <span class="text-sm font-semibold">{{ card.label }}</span>
                                    </div>
                                    <span v-if="card.is_primary" class="rounded bg-white/20 px-2 py-0.5 text-[9px] font-bold uppercase tracking-wide">
                                        PRINCIPAL
                                    </span>
                                </div>

                                <!-- Body -->
                                <div class="mt-4">
                                    <div class="text-[10px] font-semibold uppercase tracking-wide opacity-90">FATURA ATUAL</div>
                                    <div class="mt-1 text-3xl font-bold tracking-tight">
                                        {{ hideValues ? 'R$ ••••' : formatBRL(card.used).replace('R$', 'R$') }}
                                    </div>

                                    <!-- Progress bar -->
                                    <div class="mt-4 h-1.5 overflow-hidden rounded-full bg-white/30">
                                        <div class="h-full rounded-full bg-white" :style="{ width: `${card.percent}%` }"></div>
                                    </div>

                                    <!-- Limite e Percentual -->
                                    <div class="mt-2 flex items-center justify-between text-[11px] font-semibold">
                                        <span class="opacity-90">
                                            Limite: {{ hideValues ? 'R$ ••••' : `R$ ${card.limit.toLocaleString('pt-BR', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}` }}
                                        </span>
                                        <span class="opacity-90">{{ Math.round(card.percent) }}%</span>
                                    </div>

                                    <!-- Vencimento -->
                                    <div v-if="card.dueDay" class="mt-3 flex items-center gap-1.5 text-[11px] font-semibold opacity-90">
                                        <svg class="h-3.5 w-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <rect x="3" y="4" width="18" height="18" rx="2" />
                                            <path d="M16 2v4" />
                                            <path d="M8 2v4" />
                                            <path d="M3 10h18" />
                                        </svg>
                                        <span>Vence dia {{ card.dueDay }}</span>
                                    </div>
                                </div>
                            </div>
                        </Link>
                    </div>

                    <div class="mt-4 rounded-2xl border border-slate-200 bg-slate-50 px-4 py-4 text-sm font-semibold text-slate-700">
                        <div class="flex items-center justify-between">
                            <span>Total (todos cartões)</span>
                            <span class="text-slate-900">
                                {{ hideValues ? 'R$ ••••' : `R$ ${creditCardsTotalUsed.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}` }}
                            </span>
                        </div>
                    </div>
	            </div>
		        </section>

		        <section v-if="showUpcomingBillsSection" class="mt-6">
	            <div class="flex items-center justify-between">
	                <div class="text-lg font-semibold text-slate-900">A Vencer</div>
                <Link :href="route('accounts.index')" class="text-sm font-semibold text-emerald-600">Ver todas</Link>
            </div>

            <div v-if="hasUpcomingBills" class="mt-4 space-y-3">
                <div
                    v-for="bill in upcomingBills"
                    :key="bill.id"
                    class="flex items-center gap-4 rounded-3xl bg-white px-4 py-4 shadow-sm ring-1 ring-slate-200/60 cursor-pointer hover:bg-slate-50 active:bg-slate-100 transition-colors"
                    @click="openBillDetails(bill.id)"
                >
                    <div class="flex h-14 w-14 flex-col items-center justify-center rounded-2xl bg-slate-50 text-slate-600 ring-1 ring-slate-200/70">
                        <div class="text-[10px] font-semibold uppercase text-slate-400">{{ bill.month }}</div>
                        <div class="text-base font-semibold">{{ bill.day }}</div>
                    </div>
                    <div class="min-w-0 flex-1">
                        <div class="truncate text-sm font-semibold text-slate-900">{{ bill.title }}</div>
                        <div class="truncate text-xs text-slate-400">{{ bill.subtitle }}</div>
                    </div>
                    <div class="flex flex-col items-end gap-2 text-right">
                        <div
                            class="text-sm font-semibold"
                            :class="bill.paid ? 'text-emerald-600 line-through' : 'text-red-500'"
                        >
                            - {{ bill.amountLabel }}
                        </div>
                        <button
                            type="button"
                            class="flex h-6 w-6 items-center justify-center rounded-full border-2"
                            :class="bill.paid ? 'border-emerald-500 bg-emerald-500' : 'border-slate-200 bg-white'"
                            :aria-label="bill.paid ? 'Marcar como não paga' : 'Marcar como paga'"
                            @click.stop="toggleBillPaid(bill.id)"
                        >
                            <svg v-if="bill.paid" class="h-4 w-4 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">
                                <path d="M20 6 9 17l-5-5" />
                            </svg>
                        </button>
                    </div>
                </div>
            </div>
		        </section>

            <section class="mt-6 rounded-3xl bg-white p-4 shadow-sm ring-1 ring-slate-200/60">
                <button
                    type="button"
                    class="flex w-full items-center justify-between rounded-2xl bg-slate-50 px-4 py-4 text-left ring-1 ring-slate-200/60"
                    @click="homeWidgetsModalOpen = true"
                >
                    <div class="flex items-center gap-4">
                        <span class="flex h-11 w-11 items-center justify-center rounded-2xl bg-white text-slate-500 ring-1 ring-slate-200/60">
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="3" width="8" height="8" rx="2" />
                                <rect x="13" y="3" width="8" height="5" rx="2" />
                                <rect x="13" y="10" width="8" height="11" rx="2" />
                                <rect x="3" y="13" width="8" height="8" rx="2" />
                            </svg>
                        </span>
                        <div>
                            <div class="text-sm font-semibold text-slate-900">Gerencie sua tela inicial aqui</div>
                            <div class="mt-1 text-xs font-semibold text-slate-400">Escolha o que aparece na Home.</div>
                        </div>
                    </div>
                    <svg class="h-5 w-5 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M9 18l6-6-6-6" />
                    </svg>
                </button>
            </section>
                </div>
            </div>

	        <TransactionModal
                :open="transactionOpen"
                :kind="transactionKind"
                :initial="transactionInitial"
                :categories="pickerCategories"
                :accounts="pickerAccounts"
                :tags="bootstrap.tags"
                :lock-kind="transactionLockKind"
                @close="transactionOpen = false"
                @save="onTransactionSave"
            />
	        <CreditCardModal :open="creditCardModalOpen" @close="creditCardModalOpen = false" @save="saveCreditCard" />
	        <CreateAccountFlowModal :open="createAccountOpen" @close="createAccountOpen = false" @toast="showToast" />
	        <CreateCreditCardFlowModal :open="createCreditCardFlowOpen" @close="createCreditCardFlowOpen = false" @save="handleCreateCreditCardFlowSave" />
	        <TransactionDetailModal
	            :open="mobileDetailOpen"
	            :transaction="mobileTransactionDetail"
	            @close="mobileDetailOpen = false"
            @edit="handleDetailEdit"
            @delete="handleDetailDelete"
            @duplicate="handleDetailEdit"
        />

        <Modal :show="homeWidgetsModalOpen" maxWidth="md" @close="homeWidgetsModalOpen = false">
            <div class="p-5">
                <div class="flex items-center justify-between">
                    <div class="text-lg font-semibold text-slate-900">Tela inicial</div>
                    <button
                        type="button"
                        class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-50 text-slate-600 ring-1 ring-slate-200/60"
                        aria-label="Fechar"
                        @click="homeWidgetsModalOpen = false"
                    >
                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M18 6 6 18" />
                            <path d="M6 6l12 12" />
                        </svg>
                    </button>
                </div>
                <div class="mt-4">
                    <HomeWidgetsManager />
                </div>
            </div>
        </Modal>

        <MobileToast :show="toastOpen" :message="toastMessage" @dismiss="toastOpen = false" />
        <OnboardingModal
            :open="onboardingOpen"
            @close="onboardingOpen = false"
            @done="onboardingOpen = false"
            @add-first-expense="openTransaction('expense')"
        />
        <FixInstitutionModal
            :open="fixInstitutionModalOpen"
            :items="itemsWithoutInstitution"
            @close="fixInstitutionModalOpen = false"
            @updated="handleInstitutionUpdated"
        />

	    </component>
</template>
