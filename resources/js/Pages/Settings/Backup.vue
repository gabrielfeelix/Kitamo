<script setup lang="ts">
import { computed, onMounted, ref } from 'vue';
import { Head, Link } from '@inertiajs/vue3';
import { useIsMobile } from '@/composables/useIsMobile';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import ToggleSwitch from '@/Components/ToggleSwitch.vue';
import MobileToast from '@/Components/MobileToast.vue';
import { requestJson } from '@/lib/kitamoApi';

const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() =>
    isMobile.value ? { showNav: false } : { title: 'Backup', showSearch: false, showNewAction: false },
);
// A tela era 100% mockup: histórico fixo e restoreBackup() só exibia um
// toast, afirmando ao usuário que os dados estavam salvos sem nada acontecer.
// Agora consome /api/backup/*, que já existia e não tinha consumidor.
const synced = ref(false);
const autoBackup = ref(true);
const frequency = ref<'Diário' | 'Semanal' | 'Mensal'>('Diário');
const provider = ref<'drive' | 'icloud'>('drive');

type BackupItem = { label: string; size: string; ok: boolean; filename?: string };
const history = ref<BackupItem[]>([]);
const loading = ref(false);

const formatSize = (bytes: number) => {
    if (!bytes) return '—';
    const mb = bytes / (1024 * 1024);
    return mb >= 1
        ? `${mb.toLocaleString('pt-BR', { maximumFractionDigits: 1 })} MB`
        : `${Math.max(1, Math.round(bytes / 1024))} KB`;
};

const loadHistory = async () => {
    loading.value = true;
    try {
        // O endpoint retorna o array direto, com size_bytes.
        const res = await requestJson<Array<{ filename: string; size_bytes: number; created_at: string }>>(
            '/api/backup/list',
            { method: 'GET' },
        );
        const items = Array.isArray(res) ? res : [];
        history.value = items.map((b) => {
            const d = new Date(b.created_at);
            const label = Number.isFinite(d.getTime())
                ? `${new Intl.DateTimeFormat('pt-BR', { day: '2-digit', month: 'short' }).format(d).replace('.', '')} ` +
                  new Intl.DateTimeFormat('pt-BR', { hour: '2-digit', minute: '2-digit' }).format(d)
                : b.filename;
            return { label, size: formatSize(Number(b.size_bytes ?? 0)), ok: true, filename: b.filename };
        });
        synced.value = history.value.length > 0;
    } catch (error) {
        console.error('Falha ao carregar backups', error);
        history.value = [];
        synced.value = false;
    } finally {
        loading.value = false;
    }
};

onMounted(loadHistory);

const toastOpen = ref(false);
const toastMessage = ref('');
const showToast = (message: string) => {
    toastMessage.value = message;
    toastOpen.value = true;
};

const runBackup = async () => {
    loading.value = true;
    try {
        await requestJson('/api/backup/create', { method: 'POST' });
        await loadHistory();
        showToast('Backup realizado');
    } catch (error) {
        console.error('Falha ao criar backup', error);
        showToast('Não foi possível criar o backup');
    } finally {
        loading.value = false;
    }
};

const restoreBackup = async (filename?: string) => {
    const alvo = filename ?? history.value[0]?.filename;
    if (!alvo) {
        showToast('Nenhum backup disponível para restaurar');
        return;
    }

    // A restauração apaga contas, transações e metas antes de reimportar,
    // e não há SoftDeletes: é irreversível. Confirma antes.
    const ok = window.confirm(
        'Restaurar este backup vai SUBSTITUIR todos os seus dados atuais ' +
            '(contas, transações e metas). Esta ação não pode ser desfeita.\n\nContinuar?',
    );
    if (!ok) return;

    loading.value = true;
    try {
        await requestJson('/api/backup/restore', {
            method: 'POST',
            body: JSON.stringify({ filename: alvo, confirm: true }),
        });
        showToast('Backup restaurado');
        window.location.reload();
    } catch (error) {
        console.error('Falha ao restaurar backup', error);
        showToast('Não foi possível restaurar o backup');
    } finally {
        loading.value = false;
    }
};
</script>

<template>
    <Head title="Backup automático" />

    <component :is="Shell" v-bind="shellProps">
        <header class="flex items-center gap-3 pt-2">
            <Link
                :href="route('settings.security')"
                class="flex h-10 w-10 items-center justify-center rounded-2xl bg-white text-slate-600 shadow-sm ring-1 ring-slate-200/60"
                aria-label="Voltar"
            >
                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M15 18l-6-6 6-6" />
                </svg>
            </Link>
            <div class="text-xl font-semibold tracking-tight text-slate-900">Backup automático</div>
        </header>

        <div class="mt-6 space-y-5 pb-[calc(7rem+env(safe-area-inset-bottom))]">
            <div class="rounded-3xl bg-white p-6 shadow-sm ring-1 ring-slate-200/60">
                <div class="flex justify-center">
                    <div class="flex h-16 w-16 items-center justify-center rounded-full bg-emerald-50 text-emerald-600">
                        <svg class="h-8 w-8" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M20 17.5A4.5 4.5 0 0 0 18 9h-1.3A7 7 0 0 0 3 11.5" />
                            <path d="M7 17a4 4 0 1 0 1.2 7.8" />
                            <path d="M12 12v7" />
                            <path d="M8 15l4-3 4 3" />
                        </svg>
                    </div>
                </div>

                <div class="mt-5 text-center">
                    <div class="inline-flex items-center gap-2 text-base font-semibold text-slate-900">
                        <span class="flex h-6 w-6 items-center justify-center rounded-md bg-emerald-50 text-emerald-600">
                            <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">
                                <path d="M20 6 9 17l-5-5" />
                            </svg>
                        </span>
                        Sincronizado
                    </div>
                    <div class="mt-1 text-sm font-semibold text-slate-400">Último backup: Hoje às 14:30</div>
                    <div class="mt-3 inline-flex rounded-full bg-slate-100 px-3 py-1 text-xs font-semibold text-slate-500">2,4 MB</div>
                </div>
            </div>

            <div class="rounded-3xl bg-white p-5 shadow-sm ring-1 ring-slate-200/60">
                <div class="flex items-center justify-between gap-4">
                    <div>
                        <div class="text-sm font-semibold text-slate-900">Backup automático</div>
                        <div class="mt-1 text-xs font-semibold text-slate-400">Salva seus dados diariamente</div>
                    </div>
                    <ToggleSwitch v-model="autoBackup" />
                </div>
            </div>

            <div>
                <div class="text-sm font-semibold text-slate-900">Frequência</div>
                <div class="mt-3 relative flex h-12 items-center rounded-2xl bg-white px-4 shadow-sm ring-1 ring-slate-200/60">
                    <select v-model="frequency" class="select-clean h-full w-full appearance-none bg-transparent text-sm font-semibold text-slate-900 focus:outline-none">
                        <option>Diário</option>
                        <option>Semanal</option>
                        <option>Mensal</option>
                    </select>
                    <span class="pointer-events-none absolute inset-y-0 right-4 flex items-center text-slate-300">
                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M6 9l6 6 6-6" />
                        </svg>
                    </span>
                </div>
            </div>

            <div>
                <div class="text-sm font-semibold text-slate-900">Salvar em</div>
                <div class="mt-3 grid grid-cols-2 gap-3">
                    <button
                        type="button"
                        class="flex h-12 items-center justify-center gap-2 rounded-2xl border bg-white text-sm font-semibold"
                        :class="provider === 'drive' ? 'border-[#14B8A6] text-[#14B8A6]' : 'border-slate-200 text-slate-600'"
                        @click="provider = 'drive'"
                    >
                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M8 3h8l5 9-5 9H8L3 12 8 3Z" />
                        </svg>
                        Drive
                    </button>
                    <button
                        type="button"
                        class="flex h-12 items-center justify-center gap-2 rounded-2xl border bg-white text-sm font-semibold"
                        :class="provider === 'icloud' ? 'border-[#14B8A6] text-[#14B8A6]' : 'border-slate-200 text-slate-600'"
                        @click="provider = 'icloud'"
                    >
                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M20 17.5A4.5 4.5 0 0 0 18 9h-1.3A7 7 0 0 0 3 11.5" />
                            <path d="M7 17a4 4 0 1 0 1.2 7.8" />
                        </svg>
                        iCloud
                    </button>
                </div>
            </div>

            <div>
                <div class="text-sm font-semibold text-slate-900">Histórico</div>
                <div class="mt-3 overflow-hidden rounded-3xl bg-white shadow-sm ring-1 ring-slate-200/60">
                    <div v-for="(h, idx) in history" :key="h.label" class="flex items-center justify-between px-5 py-4" :class="idx ? 'border-t border-slate-100' : ''">
                        <div class="text-sm font-semibold text-slate-900">{{ h.label }}</div>
                        <div class="flex items-center gap-3">
                            <div class="text-xs font-semibold text-slate-400">{{ h.size }}</div>
                            <span v-if="h.ok" class="flex h-6 w-6 items-center justify-center rounded-full bg-emerald-500 text-white">
                                <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">
                                    <path d="M20 6 9 17l-5-5" />
                                </svg>
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="fixed inset-x-0 bottom-0 bg-white px-5 pb-[calc(1rem+env(safe-area-inset-bottom))] pt-3 shadow-[0_-18px_40px_-32px_rgba(15,23,42,0.45)]">
            <div class="mx-auto flex w-full max-w-md gap-3">
                <button
                    type="button"
                    class="flex h-[52px] flex-1 items-center justify-center rounded-2xl border border-[#14B8A6] bg-white text-sm font-semibold text-[#14B8A6]"
                    @click="runBackup"
                >
                    Fazer backup
                </button>
                <button
                    type="button"
                    class="flex h-[52px] flex-1 items-center justify-center rounded-2xl bg-[#14B8A6] text-sm font-semibold text-white shadow-[0_2px_8px_rgba(20,184,166,0.25)]"
                    @click="restoreBackup()"
                >
                    Restaurar
                </button>
            </div>
        </div>

        <MobileToast :show="toastOpen" :message="toastMessage" @dismiss="toastOpen = false" />
    </component>

    
</template>
