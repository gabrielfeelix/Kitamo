<script setup lang="ts">
import { computed } from 'vue';
import PickerSheet from '@/Components/PickerSheet.vue';
import AccountIcon from '@/Components/AccountIcon.vue';
import InstitutionAvatar from '@/Components/InstitutionAvatar.vue';
import { getBankSvgPath } from '@/lib/bankLogos';

export type AccountOption = {
    key: string;
    label: string;
    subtitle?: string;
    balance?: number;
    limit?: number;
    used?: number;
    available?: number;
    tone?: 'purple' | 'amber' | 'emerald' | 'slate';
    customColor?: string;
    icon?: string;
    type?: 'bank' | 'wallet' | 'credit_card';
};

const props = defineProps<{
    open: boolean;
    options: AccountOption[];
    title?: string;
}>();

const emit = defineEmits<{
    (e: 'close'): void;
    (e: 'select', key: string): void;
}>();

const toneClass = (tone?: AccountOption['tone']) => {
    if (tone === 'purple') return 'bg-purple-100 text-purple-600';
    if (tone === 'amber') return 'bg-amber-100 text-amber-600';
    if (tone === 'emerald') return 'bg-emerald-100 text-emerald-600';
    return 'bg-slate-200 text-slate-600';
};

const isWallet = (opt: AccountOption) => opt.type === 'wallet' || opt.icon === 'wallet';
const svgPathFor = (opt: AccountOption) => (isWallet(opt) ? null : getBankSvgPath(opt.label));

const formatBRL = (value: number) =>
    new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL', minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(value);

const isCreditCard = (opt: AccountOption) => opt.type === 'credit_card';

const saldoLabel = (opt: AccountOption) => {
    if (isCreditCard(opt)) {
        const available =
            opt.available ??
            (opt.limit != null ? Number(opt.limit) - Number(opt.used ?? 0) : null);
        if (available == null) return '';
        return `Disponível: ${formatBRL(Math.max(0, available))}`;
    }
    if (opt.balance == null) return '';
    return `Saldo: ${formatBRL(opt.balance)}`;
};

const bankAndWalletOptions = computed(() => props.options.filter((o) => o.type !== 'credit_card'));
const creditCardOptions = computed(() => props.options.filter((o) => o.type === 'credit_card'));

const normalizeLabel = (value: string) => String(value ?? '').trim().toLowerCase();
const creditCardOptionsDisplay = computed(() => {
    const counts = new Map<string, number>();
    for (const opt of creditCardOptions.value) {
        const key = normalizeLabel(opt.label);
        counts.set(key, (counts.get(key) ?? 0) + 1);
    }

    const seen = new Map<string, number>();
    return creditCardOptions.value.map((opt) => {
        const key = normalizeLabel(opt.label);
        const count = counts.get(key) ?? 0;
        if (count <= 1) return { opt, label: opt.label };

        const idx = (seen.get(key) ?? 0) + 1;
        seen.set(key, idx);
        return { opt, label: `${opt.label} (${idx})` };
    });
});
</script>

<template>
    <PickerSheet :open="open" :title="props.title ?? 'Pagar com'" @close="emit('close')">
        <div class="space-y-5 pb-2">
            <div v-if="bankAndWalletOptions.length">
                <div class="px-2 text-[10px] font-bold uppercase tracking-wide text-slate-400">CONTAS E CARTEIRAS</div>
                <div class="mt-2 space-y-3">
                    <button
                        v-for="opt in bankAndWalletOptions"
                        :key="opt.key"
                        type="button"
                        class="flex w-full items-center gap-4 rounded-2xl bg-slate-50 px-4 py-4 text-left ring-1 ring-slate-200/70"
                        @click="emit('select', opt.key)"
                    >
                        <InstitutionAvatar
                            v-if="!isWallet(opt)"
                            :institution="opt.label"
                            :svg-path="svgPathFor(opt)"
                            fallback-icon="account"
                            container-class="flex h-12 w-12 items-center justify-center overflow-hidden rounded-2xl bg-white ring-1 ring-slate-200/70"
                            img-class="h-10 w-10 object-contain"
                            fallback-icon-class="h-5 w-5 text-slate-600"
                        />
                        <span
                            v-else
                            class="flex h-12 w-12 items-center justify-center rounded-full text-lg font-semibold"
                            :class="opt.customColor ? '' : toneClass(opt.tone)"
                            :style="opt.customColor ? { backgroundColor: opt.customColor, color: 'white' } : {}"
                        >
                            <AccountIcon :type="opt.type" :icon="opt.icon" class="h-6 w-6" />
                        </span>
                        <div class="min-w-0 flex-1">
                            <div class="truncate text-base font-semibold text-slate-900">{{ opt.label }}</div>
                            <div class="mt-0.5 flex flex-wrap items-center gap-x-2 gap-y-1 text-xs font-semibold">
                                <span v-if="opt.subtitle" class="truncate text-slate-400">{{ opt.subtitle }}</span>
                                <span v-if="opt.subtitle && saldoLabel(opt)" class="text-slate-300">•</span>
                                <span v-if="saldoLabel(opt)" class="truncate text-slate-500">{{ saldoLabel(opt) }}</span>
                            </div>
                        </div>
                        <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                            <path d="M9 5l7 7-7 7" />
                        </svg>
                    </button>
                </div>
            </div>

            <div v-if="creditCardOptions.length">
                <div class="px-2 text-[10px] font-bold uppercase tracking-wide text-slate-400">CARTÕES DE CRÉDITO</div>
                <div class="mt-2 space-y-3">
                    <button
                        v-for="row in creditCardOptionsDisplay"
                        :key="row.opt.key"
                        type="button"
                        class="flex w-full items-center gap-4 rounded-2xl bg-slate-50 px-4 py-4 text-left ring-1 ring-slate-200/70"
                        @click="emit('select', row.opt.key)"
                    >
                        <InstitutionAvatar
                            :institution="row.opt.label"
                            :svg-path="getBankSvgPath(row.opt.label)"
                            fallback-icon="credit-card"
                            container-class="flex h-12 w-12 items-center justify-center overflow-hidden rounded-2xl bg-white ring-1 ring-slate-200/70"
                            img-class="h-10 w-10 object-contain"
                            fallback-icon-class="h-5 w-5 text-slate-600"
                        />
                        <div class="min-w-0 flex-1">
                            <div class="truncate text-base font-semibold text-slate-900">{{ row.label }}</div>
                            <div class="mt-0.5 flex flex-wrap items-center gap-x-2 gap-y-1 text-xs font-semibold">
                                <span v-if="row.opt.subtitle" class="truncate text-slate-400">{{ row.opt.subtitle }}</span>
                                <span v-if="row.opt.subtitle && saldoLabel(row.opt)" class="text-slate-300">•</span>
                                <span v-if="saldoLabel(row.opt)" class="truncate text-slate-500">{{ saldoLabel(row.opt) }}</span>
                            </div>
                        </div>
                        <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                            <path d="M9 5l7 7-7 7" />
                        </svg>
                    </button>
                </div>
            </div>
        </div>
    </PickerSheet>
</template>
