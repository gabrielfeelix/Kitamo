<script setup lang="ts">
	import { computed, ref } from 'vue';
	import { Head, Link, router, usePage } from '@inertiajs/vue3';
	import type { BootstrapData, Entry } from '@/types/kitamo';
	import MobileShell from '@/Layouts/MobileShell.vue';
	import KitamoLayout from '@/Layouts/KitamoLayout.vue';
import MobileToast from '@/Components/MobileToast.vue';
import ConfirmationModal from '@/Components/ConfirmationModal.vue';
import NewAccountModal from '@/Components/NewAccountModal.vue';
import { requestJson } from '@/lib/kitamoApi';
import { useIsMobile } from '@/composables/useIsMobile';

type AccountType = 'wallet' | 'bank' | 'card';

const props = defineProps<{
    accountKey: string;
}>();

const isMobile = useIsMobile();
const page = usePage();
const bootstrap = computed(
    () => (page.props.bootstrap ?? { entries: [], goals: [], accounts: [], categories: [] }) as BootstrapData,
);

const account = computed(() => bootstrap.value.accounts.find((item) => item.id === props.accountKey));
const accountName = computed(() => account.value?.name ?? 'Conta');
const balance = computed(() => account.value?.current_balance ?? 0);
const entries = computed(() => bootstrap.value.entries ?? []);

const formatMoney = (value: number) =>
    new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL',
    }).format(value);

const formatDayLabel = (entry: Entry) => {
    const date = entry.transactionDate ? new Date(entry.transactionDate) : new Date();
    const day = String(date.getDate()).padStart(2, '0');
    const month = date
        .toLocaleString('pt-BR', { month: 'short' })
        .replace('.', '')
        .toUpperCase();
    return `${day} ${month}`;
};

const transactions = computed(() =>
    entries.value
        .filter((entry) => entry.accountLabel === accountName.value)
        .map((entry) => ({
            id: entry.id,
            day: formatDayLabel(entry),
            title: entry.title,
            amount: entry.amount,
            kind: entry.kind,
        })),
);

const toastOpen = ref(false);
	const toastMessage = ref('');
	const showToast = (message: string) => {
	    toastMessage.value = message;
	    toastOpen.value = true;
	};

	const actionsOpen = ref(false);
	const editOpen = ref(false);
	const deleteOpen = ref(false);

	const editInitial = computed(() => {
	    if (!account.value) return null;
	    const mappedType: AccountType = account.value.type === 'bank' ? 'bank' : account.value.type === 'wallet' ? 'wallet' : 'card';
	    return {
	        id: String(account.value.id),
	        name: account.value.name,
	        type: mappedType,
	        icon: account.value.icon ?? 'wallet',
	    };
	});

	const deleteMessage = computed(() => `Tem certeza que deseja excluir a conta "${accountName.value}"?`);
	const deleteWarningText = 'Isso irá excluir também todas as transações vinculadas a esta conta. Esta ação não pode ser desfeita.';

	const saveAccountEdit = async (payload: { id?: string; name: string; type: 'wallet' | 'bank' | 'card'; initialBalance: string; icon: string }) => {
	    if (!payload.id) return;
	    try {
	        await requestJson(`/api/contas/${payload.id}`, {
	            method: 'PATCH',
	            body: JSON.stringify({
	                name: payload.name,
	                type: payload.type,
	                icon: payload.icon,
	            }),
	        });
	        showToast('Conta atualizada');
	        editOpen.value = false;
	        router.reload();
	    } catch {
	        showToast('Não foi possível atualizar a conta');
	    }
	};

	const confirmDelete = async () => {
	    if (!account.value) return;
	    try {
	        await requestJson(`/api/contas/${account.value.id}`, { method: 'DELETE' });
	        showToast('Conta excluída');
	        router.visit(route('accounts.index'));
	    } catch {
	        showToast('Não foi possível excluir a conta');
	    } finally {
	        deleteOpen.value = false;
	    }
	};
</script>


<template>
    <Head :title="accountName" />

	    <MobileShell v-if="isMobile" :show-nav="false">
        <div class="-mx-5 -mt-2 overflow-hidden rounded-b-[36px] bg-[#14B8A6] px-5 pb-10 pt-[calc(1rem+env(safe-area-inset-top))] text-white">
            <div class="flex items-center justify-between">
                <Link
                    :href="route('settings')"
                    class="flex h-10 w-10 items-center justify-center rounded-full bg-white/20 text-white"
                    aria-label="Voltar"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M15 18l-6-6 6-6" />
                    </svg>
                </Link>

                <div class="text-base font-semibold">{{ accountName }}</div>

	                <div class="relative">
	                    <button type="button" class="flex h-10 w-10 items-center justify-center rounded-full bg-white/20" aria-label="Menu" @click="actionsOpen = !actionsOpen">
	                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
	                        <path d="M12 5h.01" />
	                        <path d="M12 12h.01" />
	                        <path d="M12 19h.01" />
	                    </svg>
	                    </button>
	                    <div v-if="actionsOpen" class="absolute right-0 mt-2 w-44 overflow-hidden rounded-xl bg-white text-slate-700 shadow-lg ring-1 ring-black/5">
	                        <button type="button" class="w-full px-4 py-3 text-left text-sm font-semibold hover:bg-slate-50" @click="editOpen = true; actionsOpen = false">
	                            Editar conta
	                        </button>
	                        <button type="button" class="w-full px-4 py-3 text-left text-sm font-semibold text-red-600 hover:bg-red-50" @click="deleteOpen = true; actionsOpen = false">
	                            Excluir conta
	                        </button>
	                    </div>
	                </div>
	            </div>

            <div class="mt-7 flex flex-col items-center">
                <div class="flex h-14 w-14 items-center justify-center rounded-2xl bg-white text-[#14B8A6] shadow-lg shadow-black/10">
                    <svg class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M3 10h18" />
                        <path d="M5 10V8l7-5 7 5v2" />
                        <path d="M6 10v9" />
                        <path d="M18 10v9" />
                    </svg>
                </div>

                <div class="mt-4 text-[11px] font-semibold tracking-wide opacity-80">SALDO ATUAL</div>
                <div class="mt-2 text-3xl font-bold tracking-tight">{{ formatMoney(balance).replace('R$', 'R$') }}</div>
                <div class="mt-2 flex items-center gap-2 text-xs font-semibold opacity-80">
                    <span class="h-2 w-2 rounded-full bg-white/80"></span>
                    Atualizado hoje
                </div>
            </div>
        </div>

        <div class="mt-6">
            <div class="flex items-center justify-between">
                <div class="text-base font-semibold text-slate-900">Transações desta conta</div>
                <Link :href="route('accounts.index')" class="text-xs font-semibold text-[#14B8A6]">Ver todas</Link>
            </div>

            <div class="mt-4 space-y-3">
                <div v-for="t in transactions" :key="t.id" class="flex items-center gap-3 rounded-2xl bg-white px-4 py-4 shadow-sm ring-1 ring-slate-200/60">
                    <div class="flex h-9 w-14 items-center justify-center rounded-xl bg-slate-50 text-[10px] font-bold text-slate-400 ring-1 ring-slate-200/60">
                        {{ t.day }}
                    </div>
                    <div class="flex-1 text-sm font-semibold text-slate-900">{{ t.title }}</div>
                    <div class="text-sm font-semibold" :class="t.kind === 'income' ? 'text-emerald-600' : 'text-red-500'">
                        {{ t.kind === 'income' ? '+' : '-' }}{{ formatMoney(t.amount).replace('R$', 'R$') }}
                    </div>
                </div>
            </div>
        </div>

        <div class="pb-[calc(5rem+env(safe-area-inset-bottom))]"></div>

	        <div class="fixed inset-x-0 bottom-0 bg-white px-5 pb-[calc(1rem+env(safe-area-inset-bottom))] pt-3 shadow-[0_-18px_40px_-32px_rgba(15,23,42,0.45)]">
	            <div class="mx-auto flex w-full max-w-md gap-3">
	                <button type="button" class="h-12 flex-1 rounded-xl border border-[#14B8A6] bg-white text-sm font-semibold text-[#14B8A6]" @click="editOpen = true">
	                    Editar conta
	                </button>
	                <button type="button" class="h-12 flex-1 rounded-xl border border-red-200 bg-white text-sm font-semibold text-red-500" @click="deleteOpen = true">
	                    Excluir conta
	                </button>
	            </div>
	        </div>

	        <MobileToast :show="toastOpen" :message="toastMessage" @dismiss="toastOpen = false" />
	        <NewAccountModal :open="editOpen" :initial="editInitial" @close="editOpen = false" @save="saveAccountEdit" />
	        <ConfirmationModal
	            :open="deleteOpen"
	            title="Excluir conta?"
	            :message="deleteMessage"
	            :warningText="deleteWarningText"
	            danger
	            confirmLabel="Excluir"
	            @close="deleteOpen = false"
	            @confirm="confirmDelete"
	        />
	    </MobileShell>

	    <KitamoLayout v-else :title="accountName" subtitle="Detalhes da conta">
	        <div class="space-y-8">
	            <div class="flex items-center justify-between">
	                <Link
	                    :href="route('accounts.index')"
	                    class="inline-flex h-11 w-11 items-center justify-center rounded-full border border-slate-200 bg-white text-slate-600 shadow-sm hover:bg-slate-50"
	                    aria-label="Voltar"
	                >
	                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
	                        <path d="M15 18l-6-6 6-6" />
	                    </svg>
	                </Link>

	                <div class="flex items-center gap-3">
	                    <button
	                        type="button"
	                        class="inline-flex h-11 items-center gap-2 rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-600 hover:bg-slate-50"
	                        @click="editOpen = true"
	                    >
	                        Editar
	                    </button>
	                    <button
	                        type="button"
	                        class="inline-flex h-11 items-center gap-2 rounded-xl border border-red-200 bg-white px-4 text-sm font-semibold text-red-600 hover:bg-red-50"
	                        @click="deleteOpen = true"
	                    >
	                        Excluir
	                    </button>
	                </div>
	            </div>

	            <div class="grid gap-6 xl:grid-cols-[420px_1fr]">
	                <div class="rounded-2xl bg-white p-7 shadow-sm ring-1 ring-slate-200/60">
	                    <div class="text-xs font-semibold uppercase tracking-wide text-slate-400">Saldo atual</div>
	                    <div class="mt-3 text-3xl font-bold tracking-tight text-slate-900">
	                        {{ formatMoney(balance).replace('R$', 'R$') }}
	                    </div>
	                    <div class="mt-6 rounded-2xl bg-slate-50 p-4 text-sm font-semibold text-slate-600">
	                        Tipo: {{ account?.type ?? '-' }}
	                    </div>
	                </div>

	                <div class="rounded-2xl bg-white p-7 shadow-sm ring-1 ring-slate-200/60">
	                    <div class="flex items-center justify-between">
	                        <div class="text-base font-semibold text-slate-900">Transações desta conta</div>
	                        <Link :href="route('accounts.index')" class="text-sm font-semibold text-[#14B8A6]">Ver todas</Link>
	                    </div>

	                    <div v-if="transactions.length" class="mt-6 space-y-3">
	                        <div v-for="t in transactions" :key="t.id" class="flex items-center justify-between rounded-2xl border border-slate-100 bg-white px-5 py-4">
	                            <div class="min-w-0">
	                                <div class="truncate text-sm font-semibold text-slate-900">{{ t.title }}</div>
	                                <div class="mt-1 text-xs font-semibold text-slate-400">{{ t.day }}</div>
	                            </div>
	                            <div class="text-sm font-semibold" :class="t.kind === 'income' ? 'text-emerald-600' : 'text-red-500'">
	                                {{ t.kind === 'income' ? '+' : '-' }}{{ formatMoney(t.amount).replace('R$', 'R$') }}
	                            </div>
	                        </div>
	                    </div>
	                    <div v-else class="mt-6 rounded-2xl border border-dashed border-slate-200 bg-slate-50 px-6 py-10 text-center">
	                        <div class="text-sm font-semibold text-slate-900">Sem lançamentos</div>
	                        <div class="mt-1 text-xs text-slate-500">Adicione movimentações para ver o extrato.</div>
	                    </div>
	                </div>
	            </div>
	        </div>

	        <NewAccountModal :open="editOpen" :initial="editInitial" @close="editOpen = false" @save="saveAccountEdit" />
	        <ConfirmationModal
	            :open="deleteOpen"
	            title="Excluir conta?"
	            :message="deleteMessage"
	            :warningText="deleteWarningText"
	            danger
	            confirmLabel="Excluir"
	            @close="deleteOpen = false"
	            @confirm="confirmDelete"
	        />
	        <MobileToast :show="toastOpen" :message="toastMessage" @dismiss="toastOpen = false" />
	    </KitamoLayout>
</template>
