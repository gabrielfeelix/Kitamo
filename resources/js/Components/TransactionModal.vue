<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import { formatMoneyInputCentsShift, moneyInputToNumber, numberToMoneyInput } from '@/lib/moneyInput';
import { preventNonDigitKeydown } from '@/lib/inputGuards';
import { requestJson } from '@/lib/kitamoApi';
import type { UserTag } from '@/types/kitamo';
import DatePickerSheet from '@/Components/DatePickerSheet.vue';
import CategoryPickerSheet, { type CategoryOption } from '@/Components/CategoryPickerSheet.vue';
import AccountPickerSheet, { type AccountOption } from '@/Components/AccountPickerSheet.vue';
import NewCategoryModal from '@/Components/NewCategoryModal.vue';

type TransactionKind = 'expense' | 'income' | 'transfer';
type DateKind = 'today' | 'other';

export type TransactionModalPayload = {
    id?: string;
    kind: TransactionKind;
    amount: number;
    description: string;
    category: string;
    account: string;
    dateKind: DateKind;
    dateOther?: string;
    transactionDate?: string;
    editarEscopo?: 'este' | 'proximos' | 'todos';
    isInstallment: boolean;
    installmentCount: number;
    isPaid: boolean;
    tags?: string[];
    receiptFile?: File | null;
    receiptUrl?: string | null;
    receiptName?: string | null;
    removeReceipt?: boolean;
    transferFrom: string;
    transferTo: string;
    transferDescription: string;
    repetir?: boolean;
    repetirVezes?: number;
    repetirMeses?: number;
    despesaFixa?: boolean;
    recurrenceGroupId?: string | null;
    isFixed?: boolean;
    recurrenceEveryMonths?: number | null;
    recurrenceEndsAt?: string | null;
};

const props = defineProps<{
    open: boolean;
    kind: TransactionKind;
    initial?: TransactionModalPayload | null;
    categories?: CategoryOption[];
    accounts?: AccountOption[];
    tags?: UserTag[];
    lockKind?: boolean;
}>();

const emit = defineEmits<{
    (event: 'close'): void;
    (event: 'save', payload: TransactionModalPayload): void;
}>();

const close = () => {
    setReceiptFile(null);
    emit('close');
};

const localKind = ref<TransactionKind>(props.kind);
const initialId = ref<string | undefined>(undefined);
const amount = ref('');
const description = ref('');
const category = ref('Alimentação');
const account = ref('Carteira');
const transferFrom = ref('Banco Inter');
const transferTo = ref('Carteira');
const transferDescription = ref('');
const dateKind = ref<DateKind>('today');
const dateOther = ref<string>('');
const dateSheetOpen = ref(false);
const categorySheetOpen = ref(false);
const newCategoryOpen = ref(false);
const accountSheetOpen = ref(false);
const transferFromSheetOpen = ref(false);
const transferToSheetOpen = ref(false);
const isInstallment = ref(false);
const installmentCount = ref(1);
const isPaid = ref(false);
const despesaFixa = ref(false);
const repetir = ref(false);
const repetirVezes = ref(2);
const repetirMeses = ref(1);

const editScopeOpen = ref(false);
const pendingSubmitScope = ref<'este' | 'proximos' | 'todos' | null>(null);
const editScopeMessage = ref('');
const pendingPayload = ref<TransactionModalPayload | null>(null);

watch(isInstallment, (value) => {
    if (value) {
        despesaFixa.value = false;
        repetir.value = false;
    }
});

watch(despesaFixa, (value) => {
    if (value) {
        isInstallment.value = false;
        repetir.value = false;
    }
});

watch(repetir, (value) => {
    if (value) {
        isInstallment.value = false;
        despesaFixa.value = false;
    }
});

	const isExpense = computed(() => localKind.value === 'expense');
	const isTransfer = computed(() => localKind.value === 'transfer');
	const paidLabel = computed(() => (localKind.value === 'income' ? 'Recebido?' : 'Pago?'));
	const paidAriaLabel = computed(() => (localKind.value === 'income' ? 'Recebido' : 'Pago'));
const showAdvanced = ref(false);
const selectedTags = ref<string[]>([]);
const createTagOpen = ref(false);
const createTagName = ref('');
const createTagBusy = ref(false);
const createdTags = ref<UserTag[]>([]);
const receiptFile = ref<File | null>(null);
const receiptPreviewUrl = ref<string | null>(null);
const existingReceiptUrl = ref<string | null>(null);
const existingReceiptName = ref<string | null>(null);
const removeReceipt = ref(false);
const receiptFileInput = ref<HTMLInputElement | null>(null);
const receiptDropActive = ref(false);

const amountTextClass = computed(() => {
    if (localKind.value === 'expense') return 'text-[#EF4444]';
    if (localKind.value === 'transfer') return 'text-[#3B82F6]';
    return 'text-[#14B8A6]';
});

const amountInputClass = computed(() => {
    if (!amount.value) return 'text-slate-200';
    return 'text-slate-900';
});

const amountSizeClass = computed(() => {
    const len = String(amount.value ?? '').length;
    if (len <= 6) return 'text-[56px]';
    if (len <= 9) return 'text-[44px]';
    if (len <= 12) return 'text-[36px]';
    return 'text-[30px]';
});

const pillClass = (kind: TransactionKind) => {
    if (localKind.value !== kind) return 'bg-transparent text-[#9CA3AF] border border-[#E5E7EB]';
    if (kind === 'expense') return 'bg-[#FEE2E2] text-[#EF4444] border border-transparent';
    if (kind === 'transfer') return 'bg-[#DBEAFE] text-[#2563EB] border border-transparent';
    return 'bg-[#E6FFFB] text-[#14B8A6] border border-transparent';
};

const onAmountInput = (event: Event) => {
    const target = event.target as HTMLInputElement;
    amount.value = formatMoneyInputCentsShift(target.value);
};

const amountNumber = computed(() => {
    return moneyInputToNumber(amount.value);
});

const canSave = computed(() => {
    // Validações básicas
    if (amountNumber.value <= 0) return false;
    if (!description.value.trim()) return false;
    if (!category.value) return false;
    if (!account.value) return false;

    // Para transferências
    if (localKind.value === 'transfer') {
        if (!transferFrom.value) return false;
        if (!transferTo.value) return false;
        if (transferFrom.value === transferTo.value) return false;
    }

    return true;
});

const formatBRL2 = (value: number) =>
    new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL',
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
    }).format(value);

const formatBRDate = (date: Date) => {
    const dd = String(date.getDate()).padStart(2, '0');
    const mm = String(date.getMonth() + 1).padStart(2, '0');
    const yyyy = String(date.getFullYear());
    return `${dd}/${mm}/${yyyy}`;
};

const parseBRDate = (brDate: string) => {
    const match = String(brDate ?? '')
        .trim()
        .match(/^(\d{2})\/(\d{2})\/(\d{4})$/);
    if (!match) return null;
    const [, dd, mm, yyyy] = match;
    const date = new Date(Number(yyyy), Number(mm) - 1, Number(dd));
    if (Number.isNaN(date.getTime())) return null;
    return date;
};

const daysInMonth = (year: number, monthIndex: number) => new Date(year, monthIndex + 1, 0).getDate();

const addMonthsClamp = (date: Date, months: number) => {
    const baseDay = date.getDate();
    const baseMonth = date.getMonth();
    const baseYear = date.getFullYear();

    const rawTarget = baseMonth + months;
    const targetYear = baseYear + Math.floor(rawTarget / 12);
    const targetMonth = ((rawTarget % 12) + 12) % 12;
    const maxDay = daysInMonth(targetYear, targetMonth);
    return new Date(targetYear, targetMonth, Math.min(baseDay, maxDay));
};

const addDays = (date: Date, days: number) => new Date(date.getFullYear(), date.getMonth(), date.getDate() + days);

const installmentEach = computed(() => {
    const count = Math.max(1, Math.floor(installmentCount.value || 1));
    return amountNumber.value / count;
});

const baseDate = computed(() => {
    if (dateKind.value === 'other') {
        const parsed = parseBRDate(dateOther.value);
        if (parsed) return parsed;
    }
    const now = new Date();
    return new Date(now.getFullYear(), now.getMonth(), now.getDate());
});

const installmentPreview = computed(() => {
    const count = Math.max(1, Math.floor(installmentCount.value || 1));
    const limit = 5;
    const rowsCount = Math.min(count, limit);
    const rows = Array.from({ length: rowsCount }, (_, index) => ({
        date: formatBRDate(addMonthsClamp(baseDate.value, index)),
        amount: formatBRL2(installmentEach.value),
    }));

    return {
        count,
        total: formatBRL2(amountNumber.value),
        rows,
        hasMore: count > limit,
        remainingCount: Math.max(0, count - limit),
    };
});

const normalizeTagName = (raw: unknown) =>
    String(raw ?? '')
        .trim()
        .replace(/^#\s*/g, '')
        .slice(0, 50);

const setSelectedTags = (names: unknown[]) => {
    const map = new Map<string, string>();
    for (const name of names) {
        const normalized = normalizeTagName(name);
        if (!normalized) continue;
        const key = normalized.toLowerCase();
        if (!map.has(key)) map.set(key, normalized);
    }
    selectedTags.value = Array.from(map.values());
};

const selectedTagKeys = computed(() => new Set(selectedTags.value.map((t) => normalizeTagName(t).toLowerCase()).filter(Boolean)));

const toggleTag = (name: string) => {
    const normalized = normalizeTagName(name);
    if (!normalized) return;
    const key = normalized.toLowerCase();
    if (selectedTagKeys.value.has(key)) {
        setSelectedTags(selectedTags.value.filter((t) => normalizeTagName(t).toLowerCase() !== key));
        return;
    }
    setSelectedTags([...selectedTags.value, normalized]);
};

const tagOptions = computed<UserTag[]>(() => {
    const map = new Map<string, UserTag>();
    const add = (tag: UserTag) => {
        const nome = normalizeTagName(tag?.nome);
        if (!nome) return;
        const key = nome.toLowerCase();
        if (map.has(key)) return;
        map.set(key, { id: tag.id, nome, cor: tag.cor || '#64748B' });
    };

    for (const tag of props.tags ?? []) add(tag);
    for (const tag of createdTags.value) add(tag);

    for (const nome of selectedTags.value) {
        const normalized = normalizeTagName(nome);
        if (!normalized) continue;
        const key = normalized.toLowerCase();
        if (map.has(key)) continue;
        add({ id: `custom:${key}`, nome: normalized, cor: '#64748B' });
    }

    return Array.from(map.values()).sort((a, b) => a.nome.localeCompare(b.nome, 'pt-BR'));
});

const clearReceiptPreview = () => {
    if (!receiptPreviewUrl.value) return;
    URL.revokeObjectURL(receiptPreviewUrl.value);
    receiptPreviewUrl.value = null;
};

const setReceiptFile = (file: File | null) => {
    clearReceiptPreview();
    receiptFile.value = file;
    if (file && file.type.startsWith('image/')) {
        receiptPreviewUrl.value = URL.createObjectURL(file);
    }
    if (file) removeReceipt.value = false;
};

const hasReceipt = computed(() => Boolean(receiptFile.value) || (Boolean(existingReceiptUrl.value) && !removeReceipt.value));
const receiptLabel = computed(() => receiptFile.value?.name || existingReceiptName.value || 'Comprovante');
const receiptIsImage = computed(() => Boolean(receiptFile.value?.type?.startsWith('image/')));

const pickReceiptFile = () => receiptFileInput.value?.click();
const onReceiptChange = (event: Event) => {
    const target = event.target as HTMLInputElement;
    const file = target.files?.[0] ?? null;
    if (file && file.size > 10 * 1024 * 1024) {
        window.alert('Arquivo muito grande. Máximo 10MB.');
        target.value = '';
        return;
    }
    if (file && !(file.type === 'application/pdf' || file.type.startsWith('image/'))) {
        window.alert('Formato inválido. Envie PDF ou imagem.');
        target.value = '';
        return;
    }
    setReceiptFile(file);
    target.value = '';
};

const onReceiptDrop = (event: DragEvent) => {
    event.preventDefault();
    receiptDropActive.value = false;
    const file = event.dataTransfer?.files?.[0] ?? null;
    if (!file) return;
    if (file.size > 10 * 1024 * 1024) {
        window.alert('Arquivo muito grande. Máximo 10MB.');
        return;
    }
    if (!(file.type === 'application/pdf' || file.type.startsWith('image/'))) {
        window.alert('Formato inválido. Envie PDF ou imagem.');
        return;
    }
    setReceiptFile(file);
};

const removeReceiptNow = () => {
    if (receiptFile.value) {
        setReceiptFile(null);
        return;
    }
    if (existingReceiptUrl.value) {
        existingReceiptUrl.value = null;
        existingReceiptName.value = null;
        removeReceipt.value = true;
    }
};

const createTag = async () => {
    const nome = normalizeTagName(createTagName.value);
    if (!nome) return;

    const existing = tagOptions.value.find((t) => t.nome.toLowerCase() === nome.toLowerCase());
    if (existing) {
        setSelectedTags([...selectedTags.value, existing.nome]);
        createTagOpen.value = false;
        createTagName.value = '';
        return;
    }

    createTagBusy.value = true;
    try {
        const response = await requestJson<UserTag>('/api/tags', {
            method: 'POST',
            body: JSON.stringify({ nome, cor: '#64748B' }),
        });

        const created: UserTag = { id: response.id, nome: response.nome, cor: response.cor };
        createdTags.value = [...createdTags.value, created];
        setSelectedTags([...selectedTags.value, created.nome]);
        createTagOpen.value = false;
        createTagName.value = '';
    } catch {
        window.alert('Não foi possível criar a tag. Tente novamente.');
    } finally {
        createTagBusy.value = false;
    }
};

const toISODate = (brDate: string) => {
    const match = brDate.trim().match(/^(\d{2})\/(\d{2})\/(\d{4})$/);
    if (!match) return '';
    const [, dd, mm, yyyy] = match;
    return `${yyyy}-${mm}-${dd}`;
};

const toBRDate = (isoDate: string) => {
    const match = isoDate.trim().match(/^(\d{4})-(\d{2})-(\d{2})$/);
    if (!match) return isoDate;
    const [, yyyy, mm, dd] = match;
    return `${dd}/${mm}/${yyyy}`;
};

const parseISODate = (isoDate: string) => {
    const match = String(isoDate ?? '').trim().match(/^(\d{4})-(\d{2})-(\d{2})$/);
    if (!match) return null;
    const [, yyyy, mm, dd] = match;
    const date = new Date(Number(yyyy), Number(mm) - 1, Number(dd));
    return Number.isFinite(date.getTime()) ? date : null;
};

const reset = () => {
    const draft = props.initial ?? null;
    const draftInstallment = draft?.isInstallment ?? false;
    let draftFixa = Boolean(draft?.despesaFixa ?? draft?.isFixed ?? false);
    let draftRepetir = Boolean(draft?.repetir ?? (!draftFixa && Boolean(draft?.recurrenceEndsAt)));
    if (draftInstallment && (draftFixa || draftRepetir)) {
        draftFixa = false;
        draftRepetir = false;
    }

    initialId.value = draft?.id;
    localKind.value = draft?.kind ?? props.kind;
    amount.value = draft ? numberToMoneyInput(draft.amount) : '';
    description.value = draft?.description ?? '';
    category.value = draft?.category ?? 'Alimentação';
    {
        const fallbackAccount = accounts.value[0]?.key ?? '';
        const desired = (draft?.account ?? fallbackAccount).trim();
        account.value = accounts.value.some((a) => a.key === desired) ? desired : fallbackAccount;
    }
    dateKind.value = draft?.dateKind ?? 'today';
    dateOther.value = draft?.dateOther ? toBRDate(draft.dateOther) : '';
    isInstallment.value = draftInstallment;
    installmentCount.value = draft?.installmentCount ?? 1;
    isPaid.value = draft?.isPaid ?? false;
    setSelectedTags(draft?.tags ?? []);
    setReceiptFile(null);
    existingReceiptUrl.value = draft?.receiptUrl ?? null;
    existingReceiptName.value = draft?.receiptName ?? null;
    removeReceipt.value = false;
    showAdvanced.value = Boolean(
        draft?.isInstallment ||
            draftFixa ||
            draftRepetir ||
            (draft?.tags?.length ?? 0) ||
            Boolean(draft?.receiptUrl),
    );

    const availableTransfers = transferAccounts.value.map((a) => a.key);
    const defaultFrom = availableTransfers[0] ?? 'Carteira';
    const defaultTo = availableTransfers.find((k) => k !== defaultFrom) ?? defaultFrom;

    transferFrom.value = draft?.transferFrom ?? defaultFrom;
    transferTo.value = draft?.transferTo ?? defaultTo;
    if (transferTo.value === transferFrom.value) {
        transferTo.value = availableTransfers.find((k) => k !== transferFrom.value) ?? transferTo.value;
    }
    transferDescription.value = draft?.transferDescription ?? '';
    despesaFixa.value = !isTransfer.value && draftFixa;

    const rawIntervalMonths = Number(draft?.repetirMeses ?? draft?.recurrenceEveryMonths ?? 1);
    repetirMeses.value = Number.isFinite(rawIntervalMonths) && rawIntervalMonths > 0 ? Math.floor(rawIntervalMonths) : 1;

    const draftStartsAt = draft?.dateOther ?? null;
    const startIso = draftStartsAt && draftStartsAt !== '' ? draftStartsAt : null;
    const startDate = startIso ? parseISODate(startIso) : (draft?.transactionDate ? parseISODate(draft.transactionDate) : null);
    const endDate = draft?.recurrenceEndsAt ? parseISODate(draft.recurrenceEndsAt) : null;
    const monthsDiff =
        startDate && endDate
            ? (endDate.getFullYear() - startDate.getFullYear()) * 12 + (endDate.getMonth() - startDate.getMonth())
            : null;
    const computedTimes =
        monthsDiff != null ? Math.max(2, Math.floor(monthsDiff / Math.max(1, repetirMeses.value)) + 1) : 2;
    const rawTimes = Number(draft?.repetirVezes ?? computedTimes);
    repetirVezes.value = Number.isFinite(rawTimes) && rawTimes >= 2 ? Math.floor(rawTimes) : 2;

    repetir.value = !isTransfer.value && !despesaFixa.value && draftRepetir;

    dateSheetOpen.value = false;
    categorySheetOpen.value = false;
    accountSheetOpen.value = false;
    transferFromSheetOpen.value = false;
    transferToSheetOpen.value = false;
    newCategoryOpen.value = false;
    createTagOpen.value = false;
    createTagName.value = '';
    createTagBusy.value = false;
    clearReceiptPreview();
};

const openDateSheet = () => {
    dateSheetOpen.value = true;
};

const selectToday = () => {
    dateKind.value = 'today';
    dateOther.value = '';
};

const setDateOther = (br: string) => {
    dateKind.value = 'other';
    dateOther.value = br;
};

const clampInt = (value: unknown, min: number, max: number) => {
    const digits = String(value ?? '').replace(/[^\d]/g, '');
    if (!digits) return min;
    const parsed = Number(digits);
    if (!Number.isFinite(parsed)) return min;
    return Math.min(max, Math.max(min, parsed));
};

const onRepetirVezesInput = (event: Event) => {
    const target = event.target as HTMLInputElement;
    repetirVezes.value = clampInt(target.value, 2, 120);
};

const decInstallments = () => {
    installmentCount.value = Math.max(1, Math.floor(installmentCount.value || 1) - 1);
};

const incInstallments = () => {
    installmentCount.value = Math.min(999, Math.floor(installmentCount.value || 1) + 1);
};

const normalizeCategoryKind = (kind: unknown): CategoryOption['kind'] => {
    if (kind === 'expense' || kind === 'income') return kind;
    return undefined;
};

const mergeCategoryOptions = (options: CategoryOption[]) => {
    const map = new Map<string, CategoryOption>();
    for (const opt of options) {
        const current = map.get(opt.key);
        if (!current) {
            map.set(opt.key, { ...opt, kind: normalizeCategoryKind(opt.kind) });
            continue;
        }

        const nextKind = normalizeCategoryKind(opt.kind);
        const mergedKind =
            current.kind && nextKind && current.kind !== nextKind ? undefined : (current.kind ?? nextKind);

        map.set(opt.key, {
            ...current,
            ...opt,
            customColor: current.customColor ?? opt.customColor,
            tone: current.tone ?? opt.tone,
            icon: (current.icon && current.icon !== 'other' ? current.icon : opt.icon) ?? current.icon,
            kind: mergedKind,
        });
    }
    return Array.from(map.values());
};

const createdCategories = ref<CategoryOption[]>([]);

const categories = computed<CategoryOption[]>(() => {
    const fallback: CategoryOption[] = [
        { key: 'Alimentação', label: 'Alimentação', icon: 'food', tone: 'amber', kind: 'expense' },
        { key: 'Moradia', label: 'Moradia', icon: 'home', tone: 'blue', kind: 'expense' },
        { key: 'Transporte', label: 'Transporte', icon: 'car', tone: 'slate', kind: 'expense' },
        { key: 'Lazer', label: 'Lazer', icon: 'other', tone: 'purple', kind: 'expense' },
        { key: 'Saúde', label: 'Saúde', icon: 'other', tone: 'red', kind: 'expense' },
        { key: 'Estudos', label: 'Estudos', icon: 'other', tone: 'green', kind: 'expense' },
        { key: 'Salário', label: 'Salário', icon: 'other', tone: 'green', kind: 'income' },
        { key: 'Freelance', label: 'Freelance', icon: 'other', tone: 'blue', kind: 'income' },
        { key: 'Investimentos', label: 'Investimentos', icon: 'other', tone: 'purple', kind: 'income' },
        { key: 'Outros', label: 'Outros', icon: 'other', tone: 'slate' },
    ];
    const base = props.categories?.length ? props.categories : fallback;
    return mergeCategoryOptions([...base, ...createdCategories.value]);
});

const categoryKind = computed<CategoryOption['kind']>(() => {
    if (localKind.value === 'expense') return 'expense';
    if (localKind.value === 'income') return 'income';
    return undefined;
});

const categoriesForKind = computed(() => {
    if (!categoryKind.value) return [];
    return categories.value.filter((opt) => !opt.kind || opt.kind === categoryKind.value);
});

const accounts = computed<AccountOption[]>(() => {
    const fallback: AccountOption[] = [
        { key: 'Nubank', label: 'Nubank', subtitle: 'Conta Corrente', tone: 'purple' },
        { key: 'Inter', label: 'Inter', subtitle: 'Conta Digital', tone: 'amber' },
        { key: 'Dinheiro', label: 'Dinheiro', subtitle: 'Carteira Física', tone: 'emerald' },
    ];
    return props.accounts?.length ? props.accounts : fallback;
});

const transferAccounts = computed(() => accounts.value.filter((a) => a.type !== 'credit_card'));

const formatBRL = (value: number) =>
    new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL', minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(value);

const transferFromBalanceLabel = computed(() => {
    const opt = transferAccounts.value.find((a) => a.key === transferFrom.value) ?? null;
    if (!opt || opt.balance == null) return '';
    return `Saldo: ${formatBRL(Number(opt.balance) || 0)}`;
});

const transferToBalanceLabel = computed(() => {
    const opt = transferAccounts.value.find((a) => a.key === transferTo.value) ?? null;
    if (!opt || opt.balance == null) return '';
    return `Saldo: ${formatBRL(Number(opt.balance) || 0)}`;
});

const openTransferFromSheet = () => {
    transferFromSheetOpen.value = true;
};

const openTransferToSheet = () => {
    transferToSheetOpen.value = true;
};

const setTransferFrom = (key: string) => {
    transferFrom.value = key;
    transferFromSheetOpen.value = false;
    if (transferTo.value === key) {
        const fallback = transferAccounts.value.find((a) => a.key !== key)?.key ?? '';
        if (fallback) transferTo.value = fallback;
    }
};

const setTransferTo = (key: string) => {
    transferTo.value = key;
    transferToSheetOpen.value = false;
    if (transferFrom.value === key) {
        const fallback = transferAccounts.value.find((a) => a.key !== key)?.key ?? '';
        if (fallback) transferFrom.value = fallback;
    }
};

const openCategorySheet = () => {
    categorySheetOpen.value = true;
};

const openAccountSheet = () => {
    accountSheetOpen.value = true;
};

const openCreateCategory = () => {
    newCategoryOpen.value = true;
};

const createCategory = async (payload: { name: string; type: 'expense' | 'income'; icon: string }) => {
    const name = payload.name.trim();
    if (!name) return;

    try {
        const response = await requestJson<{
            id: string;
            name: string;
            type: 'expense' | 'income';
            icon?: string | null;
            color?: string | null;
        }>('/api/categories', {
            method: 'POST',
            body: JSON.stringify({
                name,
                type: payload.type,
                icon: payload.icon,
                color: '#6B7280',
            }),
        });

        createdCategories.value = mergeCategoryOptions([
            ...createdCategories.value,
            {
                key: response.name,
                label: response.name,
                icon: response.icon ?? payload.icon ?? 'other',
                customColor: response.color ?? undefined,
                kind: normalizeCategoryKind(response.type),
            },
        ]);

        category.value = response.name;
        newCategoryOpen.value = false;
    } catch {
        window.alert('Não foi possível criar a categoria. Tente novamente.');
    }
};

const buildPayload = (): TransactionModalPayload => {
    const dateOtherISO = dateKind.value === 'other' ? toISODate(dateOther.value) : '';
    return {
        id: initialId.value,
        kind: localKind.value,
        amount: amountNumber.value,
        description: description.value.trim(),
        category: category.value,
        account: account.value,
        dateKind: dateKind.value,
        dateOther: dateOtherISO,
        transactionDate: dateOtherISO || undefined,
        isInstallment: isInstallment.value,
        installmentCount: installmentCount.value,
        isPaid: isPaid.value,
        tags: selectedTags.value,
        receiptFile: receiptFile.value,
        removeReceipt: removeReceipt.value,
        transferFrom: transferFrom.value,
        transferTo: transferTo.value,
        transferDescription: transferDescription.value.trim(),
        repetir: !isTransfer.value && repetir.value,
        repetirVezes: !isTransfer.value && repetir.value ? clampInt(repetirVezes.value, 2, 120) : undefined,
        repetirMeses: !isTransfer.value && repetir.value ? clampInt(repetirMeses.value, 1, 120) : undefined,
        despesaFixa: !isTransfer.value && despesaFixa.value,
        recurrenceGroupId: props.initial?.recurrenceGroupId ?? null,
        isFixed: props.initial?.isFixed ?? false,
        recurrenceEveryMonths: props.initial?.recurrenceEveryMonths ?? null,
        recurrenceEndsAt: props.initial?.recurrenceEndsAt ?? null,
    };
};

const requiresEditScope = computed(() => Boolean(initialId.value) && Boolean(props.initial?.recurrenceGroupId) && !isTransfer.value);

const applyScopeAndSubmit = (scope: 'este' | 'proximos' | 'todos') => {
    if (!pendingPayload.value) return;
    emit('save', { ...pendingPayload.value, editarEscopo: scope });
    pendingPayload.value = null;
    editScopeOpen.value = false;
    close();
};

const save = () => {
    const payload = buildPayload();

    if (payload.repetir) {
        const vezes = clampInt(payload.repetirVezes ?? 2, 2, 120);
        const meses = clampInt(payload.repetirMeses ?? 1, 1, 120);
        if (!Number.isFinite(vezes) || vezes < 2 || !Number.isFinite(meses) || meses < 1) return;
    }

    if (requiresEditScope.value) {
        pendingPayload.value = payload;
        editScopeMessage.value =
            (props.initial?.isFixed ?? false)
                ? 'Essa é uma despesa/entrada fixa. Como você quer aplicar as alterações?'
                : 'Essa movimentação faz parte de uma repetição. Como você quer aplicar as alterações?';
        editScopeOpen.value = true;
        return;
    }

    emit('save', payload);
    close();
};

watch(
    [localKind, categoriesForKind],
    () => {
        if (localKind.value === 'transfer') return;
        if (!categoriesForKind.value.length) return;
        const exists = categoriesForKind.value.some((opt) => opt.key === category.value);
        if (!exists) category.value = categoriesForKind.value[0]!.key;
    },
    { immediate: true },
);

watch(localKind, (value) => {
    if (value === 'transfer') {
        isInstallment.value = false;
        despesaFixa.value = false;
        repetir.value = false;
    }
});

watch(
    () => props.open,
    (isOpen) => {
        if (!isOpen) return;
        reset();
    },
);
</script>

<template>
    <div
        v-if="open"
        class="transaction-modal fixed inset-0 z-[60] bg-white md:flex md:items-center md:justify-center md:bg-black/40 md:backdrop-blur-sm"
        role="dialog"
        aria-modal="true"
    >
        <div class="flex h-full flex-col md:h-auto md:max-h-[92vh] md:w-full md:max-w-[680px] md:overflow-hidden md:rounded-[28px] md:bg-white md:shadow-2xl md:ring-1 md:ring-slate-200/60">
                <header class="relative flex h-14 items-center px-4 pt-[env(safe-area-inset-top)] md:h-16 md:px-6 md:pt-0">
                    <button class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-50 text-[#6B7280]" type="button" @click="close" aria-label="Fechar">
                        <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M18 6L6 18" />
                            <path d="M6 6l12 12" />
                        </svg>
                    </button>

                    <div class="pointer-events-none absolute inset-0 flex items-center justify-center">
                        <div class="text-[18px] font-bold text-[#1F2937]">Nova movimentação</div>
                    </div>
                </header>

            <div class="flex-1 overflow-y-auto">
                <div class="px-5 pt-4 md:px-8">
                    <div class="rounded-2xl bg-slate-50 p-2 ring-1 ring-slate-200/70">
                        <div class="grid grid-cols-3 gap-2">
                            <button type="button" class="flex h-11 items-center justify-center rounded-xl text-sm font-semibold" :class="pillClass('expense')" @click="localKind = 'expense'">
                                Gasto
                            </button>
                            <button type="button" class="flex h-11 items-center justify-center rounded-xl text-sm font-semibold disabled:opacity-40 disabled:cursor-not-allowed" :class="pillClass('income')" :disabled="props.lockKind" @click="!props.lockKind && (localKind = 'income')">
                                Receita
                            </button>
	                            <button type="button" class="flex h-11 items-center justify-center rounded-xl text-sm font-semibold disabled:opacity-40 disabled:cursor-not-allowed" :class="pillClass('transfer')" :disabled="props.lockKind" @click="!props.lockKind && (localKind = 'transfer')">
	                                Transferência
	                            </button>
                        </div>
                    </div>
                </div>

                <div class="mt-6 px-5 md:px-8">
                    <div class="text-center text-xs font-bold uppercase tracking-wide text-slate-300">Valor da transação</div>
                    <div class="mt-2 flex items-center justify-center gap-3">
                        <div class="text-2xl font-bold" :class="amountTextClass">R$</div>
                        <input
                            class="amount-input w-full max-w-[340px] bg-transparent text-center font-bold leading-none tracking-tight placeholder:text-slate-200 focus:outline-none focus:ring-0"
                            :class="[amountInputClass, amountSizeClass]"
                            inputmode="numeric"
                            autocomplete="off"
                            spellcheck="false"
                            :value="amount"
                            @input="onAmountInput"
                            @keydown="preventNonDigitKeydown"
                            placeholder="0,00"
                            aria-label="Valor"
                        />
                    </div>
                </div>

                <div class="mt-6 space-y-4 px-5 md:px-8">
                    <div v-if="!isTransfer" class="rounded-2xl bg-slate-50 px-4 py-4 ring-1 ring-slate-200/70">
                        <div class="flex items-center gap-3">
                            <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-white text-slate-400 ring-1 ring-slate-200/60">
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M4 7h16" />
                                    <path d="M4 12h10" />
                                    <path d="M4 17h14" />
                                </svg>
                            </span>
                            <input
                                v-model="description"
                                type="text"
                                placeholder="Descrição (ex: Almoço de domingo)"
                                class="w-full appearance-none border-0 bg-transparent text-sm font-semibold text-slate-700 placeholder:text-slate-300 outline-none focus:outline-none focus:ring-0"
                            />
                        </div>
                    </div>

                    <div v-if="!isTransfer" class="grid grid-cols-2 gap-3">
                        <button type="button" class="rounded-2xl bg-slate-50 px-4 py-4 text-left ring-1 ring-slate-200/70" @click="openCategorySheet">
                            <div class="flex items-center gap-3">
                                <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-amber-100 text-amber-600">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M4 3v7" />
                                        <path d="M8 3v7" />
                                        <path d="M6 3v7" />
                                        <path d="M14 3v7c0 2 1 3 3 3v8" />
                                        <path d="M20 3v7" />
                                    </svg>
                                </span>
                                <div class="min-w-0 flex-1">
                                    <div class="text-[10px] font-bold uppercase tracking-wide text-slate-400">Categoria</div>
                                    <div class="truncate text-sm font-semibold text-slate-900">{{ category }}</div>
                                </div>
                                <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                                    <path d="M6 9l6 6 6-6" />
                                </svg>
                            </div>
                        </button>

                        <button type="button" class="rounded-2xl bg-slate-50 px-4 py-4 text-left ring-1 ring-slate-200/70" @click="openAccountSheet">
                            <div class="flex items-center gap-3">
                                <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-purple-100 text-purple-600">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M3 10h18" />
                                        <path d="M5 10V8l7-5 7 5v2" />
                                        <path d="M6 10v9" />
                                        <path d="M18 10v9" />
                                    </svg>
                                </span>
                                <div class="min-w-0 flex-1">
                                    <div class="text-[10px] font-bold uppercase tracking-wide text-slate-400">Conta</div>
                                    <div class="truncate text-sm font-semibold text-slate-900">{{ account }}</div>
                                </div>
                                <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                                    <path d="M6 9l6 6 6-6" />
                                </svg>
                            </div>
                        </button>
                    </div>

                    <div v-if="!isTransfer" class="grid grid-cols-2 gap-3">
                        <button type="button" class="rounded-2xl bg-slate-50 px-4 py-4 text-left ring-1 ring-slate-200/70" @click="openDateSheet">
                            <div class="flex items-center gap-3">
                                <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-200 text-slate-500">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <rect x="3" y="4" width="18" height="18" rx="3" />
                                        <path d="M8 2v4" />
                                        <path d="M16 2v4" />
                                        <path d="M3 10h18" />
                                    </svg>
                                </span>
                                <div class="min-w-0 flex-1">
                                    <div class="text-[10px] font-bold uppercase tracking-wide text-slate-400">Data</div>
                                    <div class="truncate text-sm font-semibold text-slate-900">{{ dateKind === 'today' ? 'Hoje' : dateOther || 'Selecione' }}</div>
                                </div>
                            </div>
                        </button>

	                        <div class="rounded-2xl bg-slate-50 px-4 py-4 ring-1 ring-slate-200/70">
	                            <div class="flex items-center justify-between gap-3">
	                                <div>
	                                    <div class="text-[10px] font-bold uppercase tracking-wide text-slate-400">{{ paidLabel }}</div>
	                                    <div class="text-sm font-semibold text-slate-900">{{ isPaid ? 'Sim' : 'Não' }}</div>
	                                </div>
	                                <button
	                                    type="button"
	                                    class="relative inline-flex h-7 w-12 items-center rounded-full transition"
	                                    :class="isPaid ? 'bg-[#14B8A6]' : 'bg-slate-300'"
	                                    @click="isPaid = !isPaid"
	                                    :aria-label="paidAriaLabel"
	                                >
	                                    <span
	                                        class="inline-block h-6 w-6 transform rounded-full bg-white transition"
	                                        :class="isPaid ? 'translate-x-5' : 'translate-x-1'"
	                                    ></span>
	                                </button>
	                            </div>
	                        </div>
                    </div>

	                    <button
	                        type="button"
	                        class="flex w-full items-center justify-between rounded-2xl bg-white px-4 py-4 text-left text-sm font-bold tracking-wide ring-1 ring-slate-200/60"
	                        :class="localKind === 'transfer' ? 'text-blue-600' : 'text-emerald-600'"
	                        @click="showAdvanced = !showAdvanced"
	                    >
	                        <span>OPÇÕES AVANÇADAS</span>
	                        <svg
	                            class="h-5 w-5 transition-transform"
	                            :class="showAdvanced ? 'rotate-180' : ''"
	                            viewBox="0 0 24 24"
	                            fill="none"
	                            stroke="currentColor"
	                            stroke-width="2"
	                            aria-hidden="true"
	                        >
	                            <path d="M6 9l6 6 6-6" />
	                        </svg>
                    </button>

                    <div v-if="showAdvanced" class="space-y-4 pb-4">
                        <div v-if="!isTransfer" class="rounded-2xl bg-white p-4 ring-1 ring-slate-200/60">
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-3">
                                    <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-100 text-slate-500" aria-hidden="true">📌</span>
                                    <div class="text-sm font-semibold text-slate-900">Despesa fixa</div>
                                </div>
                                <button
                                    type="button"
                                    class="relative inline-flex h-7 w-12 items-center rounded-full transition disabled:cursor-not-allowed disabled:opacity-60"
                                    :disabled="isInstallment || repetir"
                                    :class="despesaFixa ? 'bg-[#14B8A6]' : 'bg-slate-300'"
                                    @click="!(isInstallment || repetir) && (despesaFixa = !despesaFixa)"
                                    aria-label="Despesa fixa"
                                >
                                    <span class="inline-block h-6 w-6 transform rounded-full bg-white transition" :class="despesaFixa ? 'translate-x-5' : 'translate-x-1'"></span>
                                </button>
                            </div>
                            <div v-if="despesaFixa" class="mt-3 text-xs font-semibold text-slate-500">
                                Vai aparecer em todos os meses a partir desta data.
                            </div>
                        </div>

                        <div v-if="!isTransfer" class="rounded-2xl bg-white p-4 ring-1 ring-slate-200/60">
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-3">
                                    <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-100 text-slate-500">
                                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M12 2l7 7-7 7-7-7 7-7Z" />
                                            <path d="M12 16l7 7H5l7-7Z" />
                                        </svg>
                                    </span>
                                    <div class="text-sm font-semibold text-slate-900">Parcelamento</div>
                                </div>
                                <button
                                    type="button"
                                    class="relative inline-flex h-7 w-12 items-center rounded-full transition disabled:cursor-not-allowed disabled:opacity-60"
                                    :disabled="despesaFixa || repetir"
                                    :class="isInstallment ? 'bg-[#14B8A6]' : 'bg-slate-300'"
                                    @click="!(despesaFixa || repetir) && (isInstallment = !isInstallment)"
                                    aria-label="Parcelado"
                                >
                                    <span class="inline-block h-6 w-6 transform rounded-full bg-white transition" :class="isInstallment ? 'translate-x-5' : 'translate-x-1'"></span>
                                </button>
                            </div>

                            <div v-if="isInstallment" class="mt-4 grid grid-cols-2 gap-3">
                                <div>
                                    <div class="text-[10px] font-bold uppercase tracking-wide text-slate-400">Qtd.</div>
                                    <div class="mt-2 flex h-11 overflow-hidden rounded-xl bg-slate-50 ring-1 ring-slate-200/60">
                                        <input
                                            :value="installmentCount"
                                            type="text"
                                            inputmode="numeric"
                                            pattern="[0-9]*"
                                            class="w-full appearance-none border-0 bg-transparent px-4 text-center text-sm font-bold text-slate-900 outline-none focus:outline-none focus:ring-0 focus-visible:outline-none"
                                            @keydown="preventNonDigitKeydown"
                                            @input="(e) => { installmentCount = clampInt((e.target as HTMLInputElement).value, 1, 999) }"
                                            aria-label="Quantidade de parcelas"
                                        />
                                        <div class="grid w-12 grid-rows-2 border-l border-slate-200/70">
                                            <button type="button" class="flex items-center justify-center text-slate-500" aria-label="Aumentar" @click="incInstallments">
                                                <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                    <path d="M6 15l6-6 6 6" />
                                                </svg>
                                            </button>
                                            <button type="button" class="flex items-center justify-center text-slate-500" aria-label="Diminuir" @click="decInstallments">
                                                <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                    <path d="M6 9l6 6 6-6" />
                                                </svg>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                                <div>
                                    <div class="text-[10px] font-bold uppercase tracking-wide text-slate-400">Valor parcela</div>
                                    <div class="mt-2 flex h-11 items-center justify-center rounded-xl bg-slate-50 text-sm font-bold text-slate-400 ring-1 ring-slate-200/60">
                                        {{ formatBRL2(installmentEach) }}
                                    </div>
                                </div>
                            </div>

                            <div v-if="isInstallment" class="mt-4 rounded-xl bg-slate-50 p-3 text-slate-600 ring-1 ring-slate-200/60">
                                <div class="flex items-center gap-2 text-xs font-semibold">
                                    <span aria-hidden="true">📋</span>
                                    <span>Serão criadas {{ installmentPreview.count }} parcelas:</span>
                                </div>
                                <div class="mt-3 space-y-2 text-sm">
                                    <div v-for="row in installmentPreview.rows" :key="row.date" class="flex items-center justify-between gap-3 font-semibold">
                                        <span class="tabular-nums">{{ row.date }}</span>
                                        <span class="tabular-nums">{{ row.amount }}</span>
                                    </div>
                                    <div v-if="installmentPreview.hasMore" class="text-xs font-semibold text-slate-400">
                                        … +{{ installmentPreview.remainingCount }} parcelas
                                    </div>
                                    <div class="mt-2 border-t border-slate-200/70 pt-2">
                                        <div class="flex items-center justify-between gap-3 font-bold text-slate-700">
                                            <span>Total</span>
                                            <span class="tabular-nums">{{ installmentPreview.total }}</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="rounded-2xl bg-white p-4 ring-1 ring-slate-200/60">
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-3">
                                    <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-100 text-slate-500">
                                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M21 12a9 9 0 0 1-9 9" />
                                            <path d="M3 12a9 9 0 0 1 9-9" />
                                            <path d="M8 12h8" />
                                        </svg>
                                    </span>
                                    <div class="text-sm font-semibold text-slate-900">Repetir</div>
                                </div>
                                <button
                                    type="button"
                                    class="relative inline-flex h-7 w-12 items-center rounded-full transition disabled:cursor-not-allowed disabled:opacity-60"
                                    :disabled="isInstallment || despesaFixa || isTransfer"
                                    :class="repetir ? 'bg-[#14B8A6]' : 'bg-slate-300'"
                                    @click="!(isInstallment || despesaFixa || isTransfer) && (repetir = !repetir)"
                                    aria-label="Repetir"
                                >
                                    <span class="inline-block h-6 w-6 transform rounded-full bg-white transition" :class="repetir ? 'translate-x-5' : 'translate-x-1'"></span>
                                </button>
                            </div>

                            <div v-if="repetir" class="mt-4">
                                <div class="grid grid-cols-2 items-end gap-4">
                                    <div>
                                        <div class="text-[10px] font-bold uppercase tracking-wide text-slate-400">Vezes</div>
                                        <input
                                            :value="repetirVezes"
                                            type="text"
                                            inputmode="numeric"
                                            pattern="[0-9]*"
                                            class="mt-2 h-10 w-full border-b border-slate-200 bg-transparent text-left text-2xl font-semibold text-slate-900 outline-none focus:border-[#14B8A6]"
                                            @keydown="preventNonDigitKeydown"
                                            @input="onRepetirVezesInput"
                                            aria-label="Repetir vezes"
                                        />
                                    </div>
                                    <div>
                                        <div class="text-[10px] font-bold uppercase tracking-wide text-slate-400">Meses</div>
                                        <select
                                            v-model="repetirMeses"
                                            class="mt-2 h-10 w-full border-b border-slate-200 bg-transparent text-left text-lg font-semibold text-slate-900 outline-none focus:border-[#14B8A6]"
                                            aria-label="Intervalo em meses"
                                        >
                                            <option v-for="m in 24" :key="m" :value="m">{{ m }}</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="mt-3 text-xs font-semibold text-slate-500">
                                    Vai repetir a cada {{ repetirMeses }} {{ repetirMeses === 1 ? 'mês' : 'meses' }}.
                                </div>
                            </div>
                        </div>

                        <div v-if="!isTransfer" class="rounded-2xl bg-white p-4 ring-1 ring-slate-200/60">
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-3">
                                    <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-100 text-slate-500" aria-hidden="true">🏷️</span>
                                    <div class="text-sm font-semibold text-slate-900">Tags</div>
                                </div>
                                <button
                                    type="button"
                                    class="text-sm font-semibold text-slate-500 hover:text-slate-700 disabled:opacity-50"
                                    :disabled="createTagBusy"
                                    @click="createTagOpen = !createTagOpen"
                                >
                                    {{ createTagOpen ? '- Tag' : '+ Tag' }}
                                </button>
                            </div>

                            <div class="mt-4 flex flex-wrap gap-2">
                                <button
                                    v-for="tag in tagOptions"
                                    :key="tag.id"
                                    type="button"
                                    class="inline-flex items-center gap-2 rounded-full px-3 py-2 text-xs font-semibold ring-1 transition"
                                    :class="selectedTagKeys.has(tag.nome.toLowerCase()) ? 'bg-slate-900 text-white ring-slate-900' : 'bg-slate-50 text-slate-600 ring-slate-200/70 hover:bg-slate-100'"
                                    @click="toggleTag(tag.nome)"
                                >
                                    <span class="h-2 w-2 rounded-full" :style="{ backgroundColor: tag.cor }" aria-hidden="true"></span>
                                    <span># {{ tag.nome }}</span>
                                </button>
                                <div v-if="tagOptions.length === 0" class="text-xs font-semibold text-slate-400">Nenhuma tag ainda.</div>
                            </div>

                            <div v-if="createTagOpen" class="mt-4 rounded-xl bg-slate-50 p-3 ring-1 ring-slate-200/60">
                                <div class="text-[10px] font-bold uppercase tracking-wide text-slate-400">Nova tag</div>
                                <div class="mt-2 flex items-center gap-2">
                                    <input
                                        v-model="createTagName"
                                        type="text"
                                        maxlength="50"
                                        placeholder="Ex: Essencial"
                                        class="h-11 w-full rounded-xl bg-white px-4 text-sm font-semibold text-slate-900 ring-1 ring-slate-200/70 focus:outline-none"
                                        :disabled="createTagBusy"
                                        @keydown.enter.prevent="createTag"
                                    />
                                    <button
                                        type="button"
                                        class="inline-flex h-11 items-center justify-center rounded-xl bg-slate-900 px-4 text-sm font-semibold text-white disabled:opacity-50"
                                        :disabled="createTagBusy || !createTagName.trim()"
                                        @click="createTag"
                                    >
                                        Criar
                                    </button>
                                </div>
                            </div>
                        </div>

                        <div v-if="!isTransfer" class="rounded-2xl bg-white p-4 ring-1 ring-slate-200/60">
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-3">
                                    <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-100 text-slate-500" aria-hidden="true">📎</span>
                                    <div class="text-sm font-semibold text-slate-900">Comprovante</div>
                                </div>
                                <button v-if="hasReceipt" type="button" class="text-sm font-semibold text-slate-500 hover:text-slate-700" @click="pickReceiptFile">
                                    Trocar
                                </button>
                            </div>

                            <input ref="receiptFileInput" class="hidden" type="file" accept="application/pdf,image/*" @change="onReceiptChange" />

                            <div
                                v-if="!hasReceipt"
                                class="mt-4 rounded-2xl border-2 border-dashed bg-slate-50 px-4 py-6 text-center transition"
                                :class="receiptDropActive ? 'border-[#14B8A6] bg-[#E6FFFB]' : 'border-slate-200'"
                                role="button"
                                tabindex="0"
                                @click="pickReceiptFile"
                                @keydown.enter.prevent="pickReceiptFile"
                                @keydown.space.prevent="pickReceiptFile"
                                @dragenter.prevent="receiptDropActive = true"
                                @dragover.prevent="receiptDropActive = true"
                                @dragleave.prevent="receiptDropActive = false"
                                @drop="onReceiptDrop"
                                aria-label="Adicionar comprovante"
                            >
                                <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-white text-slate-500 ring-1 ring-slate-200/60">
                                    <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M12 16V4" />
                                        <path d="M8 8l4-4 4 4" />
                                        <path d="M4 20h16" />
                                    </svg>
                                </div>
                                <div class="mt-3 text-sm font-semibold text-slate-900">Arraste ou clique para adicionar</div>
                                <div class="mt-1 text-xs font-semibold text-slate-400">PDF ou imagem (até 10MB).</div>
                            </div>

                            <div v-else class="mt-4 overflow-hidden rounded-xl bg-slate-50 p-3 ring-1 ring-slate-200/60">
                                <div class="flex items-center justify-between gap-3">
                                    <div class="flex min-w-0 items-center gap-3">
                                        <div v-if="receiptIsImage && receiptPreviewUrl" class="h-12 w-12 overflow-hidden rounded-xl bg-white ring-1 ring-slate-200/60">
                                            <img :src="receiptPreviewUrl" alt="" class="h-full w-full object-cover" />
                                        </div>
                                        <div v-else class="flex h-12 w-12 items-center justify-center rounded-xl bg-white text-slate-400 ring-1 ring-slate-200/60">
                                            <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                                                <rect x="4" y="5" width="16" height="14" rx="2" />
                                                <path d="M8 9h8" />
                                                <path d="M8 13h6" />
                                            </svg>
                                        </div>
                                        <div class="min-w-0">
                                            <div class="truncate text-sm font-semibold text-slate-700">{{ receiptLabel }}</div>
                                            <div class="mt-0.5 text-xs font-semibold text-slate-400">
                                                {{ existingReceiptUrl && !receiptFile && !removeReceipt ? 'Salvo' : 'Será anexado ao salvar' }}
                                            </div>
                                        </div>
                                    </div>

                                    <div class="flex items-center gap-2">
                                        <a
                                            v-if="existingReceiptUrl && !receiptFile && !removeReceipt"
                                            :href="existingReceiptUrl"
                                            target="_blank"
                                            rel="noopener noreferrer"
                                            class="flex h-10 items-center justify-center rounded-xl bg-white px-4 text-xs font-semibold text-slate-600 ring-1 ring-slate-200/60"
                                        >
                                            Ver
                                        </a>
                                        <button
                                            type="button"
                                            class="flex h-10 w-10 items-center justify-center rounded-xl bg-white text-slate-500 ring-1 ring-slate-200/60"
                                            aria-label="Remover"
                                            @click="removeReceiptNow"
                                        >
                                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <path d="M3 6h18" />
                                                <path d="M8 6V4h8v2" />
                                                <path d="M19 6l-1 16H6L5 6" />
                                                <path d="M10 11v6" />
                                                <path d="M14 11v6" />
                                            </svg>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

		                <div v-if="isTransfer" class="mt-6 space-y-4 px-5 pb-6 md:px-8">
		                    <div class="space-y-3">
		                        <div>
		                            <div class="mb-2 text-sm font-bold text-[#374151]">De (Origem)</div>
		                            <button
		                                type="button"
		                                class="w-full rounded-2xl border border-slate-200 bg-white px-4 py-4 text-left shadow-sm"
		                                @click="openTransferFromSheet"
		                            >
		                                <div class="flex items-start gap-3">
		                                    <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-100 text-slate-600">
		                                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
		                                            <path d="M3 10h18" />
		                                            <path d="M5 10V8l7-5 7 5v2" />
		                                            <path d="M6 10v9" />
		                                            <path d="M18 10v9" />
		                                        </svg>
		                                    </span>
		                                    <div class="min-w-0">
		                                        <div class="truncate text-sm font-semibold text-slate-900">{{ transferFrom }}</div>
		                                        <div class="mt-1 text-xs font-semibold text-slate-400">{{ transferFromBalanceLabel || 'Saldo: -' }}</div>
		                                    </div>
		                                </div>
		                            </button>
		                        </div>

		                        <div class="flex items-center justify-center py-1 text-slate-300">
		                            <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
		                                <path d="M12 5v14" />
		                                <path d="M5 12l7 7 7-7" />
		                            </svg>
		                        </div>

		                        <div>
		                            <div class="mb-2 text-sm font-bold text-[#374151]">Para (Destino)</div>
		                            <button
		                                type="button"
		                                class="w-full rounded-2xl border border-slate-200 bg-white px-4 py-4 text-left shadow-sm"
		                                @click="openTransferToSheet"
		                            >
		                                <div class="flex items-start gap-3">
		                                    <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-amber-50 text-amber-600">
		                                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
		                                            <path d="M4 7h16v12H4z" />
		                                            <path d="M4 7V5h12v2" />
		                                            <path d="M16 12h4" />
		                                        </svg>
		                                    </span>
		                                    <div class="min-w-0">
		                                        <div class="truncate text-sm font-semibold text-slate-900">{{ transferTo }}</div>
		                                        <div class="mt-1 text-xs font-semibold text-slate-400">{{ transferToBalanceLabel || 'Saldo: -' }}</div>
		                                    </div>
		                                </div>
		                            </button>
		                        </div>
		                    </div>

                    <div>
                        <div class="mb-2 text-sm font-bold text-[#374151]">Descrição (opcional)</div>
                        <input
                            v-model="transferDescription"
                            type="text"
                            placeholder="Ex: Saque..."
                            class="h-11 w-full rounded-lg border border-[#E5E7EB] bg-[#F9FAFB] px-3 text-base text-[#374151] placeholder:text-[#9CA3AF] focus:border-[#3B82F6] focus:outline-none focus:ring-0"
                        />
                    </div>
                </div>
                </div>

            <footer class="px-6 pt-4 pb-[calc(24px+env(safe-area-inset-bottom))] md:px-8 md:pb-8">
                    <button
                        class="h-[52px] w-full rounded-xl text-base font-bold text-white transition-all"
                        :class="canSave
                            ? (localKind === 'transfer' ? 'bg-[#3B82F6] shadow-[0_2px_8px_rgba(59,130,246,0.25)]' : 'bg-[#14B8A6] shadow-[0_2px_8px_rgba(20,184,166,0.25)]')
                            : 'bg-slate-300 shadow-none cursor-not-allowed opacity-60'"
                        type="button"
                        :disabled="!canSave"
                        @click="save"
                    >
                        {{ localKind === 'transfer' ? 'Transferir' : 'Salvar' }}
                    </button>
            </footer>
        </div>
        <DatePickerSheet
            :open="dateSheetOpen"
            :model-value="dateKind === 'today' ? '' : dateOther"
            @close="dateSheetOpen = false"
            @select-today="() => { selectToday(); dateSheetOpen = false; }"
            @update:model-value="(v) => { setDateOther(v); dateSheetOpen = false; }"
        />

        <CategoryPickerSheet
            :open="categorySheetOpen"
            :options="categories"
            :kind="categoryKind"
            @close="categorySheetOpen = false"
            @select="(key) => { category = key; categorySheetOpen = false; }"
            @create="() => { categorySheetOpen = false; openCreateCategory(); }"
        />

        <NewCategoryModal
            :open="newCategoryOpen"
            :initial-type="categoryKind ?? 'expense'"
            @close="newCategoryOpen = false"
            @save="createCategory"
        />

	        <AccountPickerSheet
	            :open="accountSheetOpen"
	            :options="accounts"
	            @close="accountSheetOpen = false"
	            @select="(key) => { account = key; accountSheetOpen = false; }"
	        />

	        <AccountPickerSheet
	            :open="transferFromSheetOpen"
	            title="Transferir de"
	            :options="transferAccounts"
	            @close="transferFromSheetOpen = false"
	            @select="setTransferFrom"
	        />

	        <AccountPickerSheet
	            :open="transferToSheetOpen"
	            title="Transferir para"
	            :options="transferAccounts"
	            @close="transferToSheetOpen = false"
	            @select="setTransferTo"
	        />

            <div v-if="editScopeOpen" class="fixed inset-0 z-[90]">
                <button class="absolute inset-0 bg-black/50 backdrop-blur-sm" type="button" @click="editScopeOpen = false" aria-label="Fechar"></button>
                <div
                    class="absolute left-1/2 top-1/2 w-full max-w-sm -translate-x-1/2 -translate-y-1/2 rounded-2xl bg-white p-6 shadow-xl"
                    role="dialog"
                    aria-modal="true"
                >
                    <div class="text-center">
                        <div class="text-4xl">🧩</div>
                        <h2 class="mt-4 text-lg font-semibold text-slate-900">Aplicar alterações</h2>
                        <p class="mt-2 text-sm text-slate-600">{{ editScopeMessage }}</p>
                    </div>

                    <div class="mt-6 space-y-3">
                        <button
                            type="button"
                            class="w-full rounded-xl border border-slate-200 py-3 text-sm font-semibold text-slate-700 hover:bg-slate-50"
                            @click="applyScopeAndSubmit('este')"
                        >
                            Só esta movimentação
                        </button>
                        <button
                            type="button"
                            class="w-full rounded-xl border border-slate-200 py-3 text-sm font-semibold text-slate-700 hover:bg-slate-50"
                            @click="applyScopeAndSubmit('proximos')"
                        >
                            Esta e as próximas
                        </button>
                        <button
                            type="button"
                            class="w-full rounded-xl bg-[#14B8A6] py-3 text-sm font-semibold text-white shadow-lg shadow-teal-600/20"
                            @click="applyScopeAndSubmit('todos')"
                        >
                            Todas (antes e depois)
                        </button>
                    </div>
                </div>
            </div>
	    </div>
	</template>

<style scoped>
.amount-input {
    outline: none !important;
    box-shadow: none !important;
    border: 0 !important;
    background: transparent !important;
    -webkit-appearance: none;
    -webkit-text-stroke: 0 transparent;
    text-shadow: none !important;
}
.amount-input:focus,
.amount-input:focus-visible {
    outline: none !important;
    box-shadow: none !important;
    border: 0 !important;
}

.select-clean {
    background-image: none !important;
    -webkit-appearance: none !important;
    -moz-appearance: none !important;
    appearance: none !important;
}
</style>
