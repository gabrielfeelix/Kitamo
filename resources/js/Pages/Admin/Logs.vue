<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import { Head, router } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import { useIsMobile } from '@/composables/useIsMobile';
import AdminLayout from '@/Components/AdminLayout.vue';

type Actor = { id: number; name: string; email: string };
type LogRow = {
    id: number;
    created_at: string | null;
    method: string;
    route_name: string | null;
    path: string;
    status_code: number | null;
    actor: Actor | null;
    payload: Record<string, unknown> | null;
};

const props = defineProps<{
    q: string;
    filters: {
        q?: string | null;
        actor_id?: number | null;
        method?: string | null;
        date?: string | null;
        start?: string | null;
        end?: string | null;
    };
    actors: Actor[];
    logs: {
        data: LogRow[];
        links: Array<{ url: string | null; label: string; active: boolean }>;
        meta?: any;
    };
}>();

const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() =>
    isMobile.value ? { showNav: false } : { title: 'Administração', showSearch: false, showNewAction: false },
);

const query = ref(props.filters?.q ?? props.q ?? '');
const actorId = ref<string>(props.filters?.actor_id ? String(props.filters.actor_id) : '');
const method = ref<string>(props.filters?.method ?? '');
const datePreset = ref<string>(props.filters?.date ?? 'today');
const start = ref<string>(props.filters?.start ?? '');
const end = ref<string>(props.filters?.end ?? '');

watch(
    () => props.filters,
    (f) => {
        query.value = f?.q ?? '';
        actorId.value = f?.actor_id ? String(f.actor_id) : '';
        method.value = f?.method ?? '';
        datePreset.value = f?.date ?? 'today';
        start.value = f?.start ?? '';
        end.value = f?.end ?? '';
    },
);

let debounceTimer: number | null = null;

const runFilters = () => {
    router.get(
        route('admin.logs.index'),
        {
            q: query.value || undefined,
            actor_id: actorId.value || undefined,
            method: method.value || undefined,
            date: datePreset.value || undefined,
            start: datePreset.value === 'custom' ? start.value || undefined : undefined,
            end: datePreset.value === 'custom' ? end.value || undefined : undefined,
        },
        { preserveState: true, preserveScroll: true, replace: true },
    );
};

const runSearch = () => {
    if (debounceTimer) window.clearTimeout(debounceTimer);
    debounceTimer = window.setTimeout(runFilters, 300);
};

const clearSearch = () => {
    query.value = '';
    runFilters();
};

const clearAll = () => {
    query.value = '';
    actorId.value = '';
    method.value = '';
    datePreset.value = 'today';
    start.value = '';
    end.value = '';
    runFilters();
};

const formatDateTime = (iso: string | null) => {
    if (!iso) return '';
    const d = new Date(iso);
    if (!Number.isFinite(d.getTime())) return String(iso);
    return d.toLocaleString('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' });
};

const methodTone = (method: string) => {
    const m = method.toUpperCase();
    if (m === 'DELETE') return 'bg-red-50 text-red-700';
    if (m === 'PATCH' || m === 'PUT') return 'bg-amber-50 text-amber-700';
    if (m === 'POST') return 'bg-emerald-50 text-emerald-700';
    return 'bg-slate-100 text-slate-700';
};

const resultLabel = computed(() => {
    const total = props.logs.meta?.total ?? props.logs.data.length;
    return `${total} registros`;
});

const exportUrl = computed(() =>
    route('admin.logs.export', {
        q: query.value || undefined,
        actor_id: actorId.value || undefined,
        method: method.value || undefined,
        date: datePreset.value || undefined,
        start: datePreset.value === 'custom' ? start.value || undefined : undefined,
        end: datePreset.value === 'custom' ? end.value || undefined : undefined,
    }),
);

const copiedId = ref<number | null>(null);
const copyPayload = async (row: LogRow) => {
    const payload = row.payload ?? {};
    const text = JSON.stringify(payload, null, 2);
    try {
        await navigator.clipboard.writeText(text);
        copiedId.value = row.id;
        window.setTimeout(() => (copiedId.value = null), 1200);
    } catch {
        // fallback
        const el = document.createElement('textarea');
        el.value = text;
        el.setAttribute('readonly', 'true');
        el.style.position = 'absolute';
        el.style.left = '-9999px';
        document.body.appendChild(el);
        el.select();
        document.execCommand('copy');
        document.body.removeChild(el);
        copiedId.value = row.id;
        window.setTimeout(() => (copiedId.value = null), 1200);
    }
};
</script>

<template>
    <Head title="Administração · Logs" />

    <component :is="Shell" v-bind="shellProps">
        <AdminLayout title="Logs de Ações" description="Registro de ações (POST/PATCH/DELETE) no sistema.">
            <div class="rounded-2xl bg-slate-50 p-6 ring-1 ring-slate-200/60">
                <div class="flex items-center justify-between">
                    <div class="text-sm font-semibold text-slate-900">Logs de Ações</div>
                    <div class="text-xs font-semibold text-slate-400">{{ resultLabel }}</div>
                </div>

                <div class="mt-4">
                    <div class="flex flex-wrap items-center gap-3">
                        <div class="flex w-full items-center gap-2 rounded-2xl bg-white px-4 py-3 ring-1 ring-slate-200/60 md:w-[60%]">
                            <input
                                v-model="query"
                                type="text"
                                class="w-full appearance-none border-0 bg-transparent p-0 text-sm font-semibold text-slate-700 placeholder:text-slate-400 outline-none"
                                placeholder="🔍 Buscar endpoint, email ou ação..."
                                @input="runSearch"
                            />
                            <button
                                type="button"
                                class="flex h-9 w-9 items-center justify-center rounded-xl bg-slate-50 text-slate-500 ring-1 ring-slate-200/60 hover:bg-slate-100"
                                aria-label="Limpar busca"
                                @click="clearSearch"
                            >
                                ↻
                            </button>
                        </div>

                        <div class="flex flex-1 items-center justify-between gap-3">
                            <button
                                type="button"
                                class="rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-700 hover:bg-slate-50"
                                @click="clearAll"
                            >
                                Limpar filtros
                            </button>
                            <a
                                :href="exportUrl"
                                class="rounded-xl bg-slate-900 px-4 py-3 text-sm font-semibold text-white shadow-lg shadow-slate-900/20"
                                target="_blank"
                                rel="noopener"
                            >
                                📥 Exportar CSV
                            </a>
                        </div>
                    </div>

                    <div class="mt-4 text-xs font-semibold uppercase tracking-wide text-slate-400">Filtrar por:</div>
                    <div class="mt-2 grid grid-cols-1 gap-3 md:grid-cols-3">
                        <div>
                            <label class="text-xs font-semibold text-slate-500">Usuário</label>
                            <select v-model="actorId" class="mt-2 h-11 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800" @change="runFilters">
                                <option value="">Todos</option>
                                <option v-for="a in props.actors" :key="a.id" :value="String(a.id)">{{ a.name }} · {{ a.email }}</option>
                            </select>
                        </div>
                        <div>
                            <label class="text-xs font-semibold text-slate-500">Método</label>
                            <select v-model="method" class="mt-2 h-11 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800" @change="runFilters">
                                <option value="">Todos</option>
                                <option value="GET">GET</option>
                                <option value="POST">POST</option>
                                <option value="PATCH_PUT">PATCH/PUT</option>
                                <option value="DELETE">DELETE</option>
                            </select>
                        </div>
                        <div>
                            <label class="text-xs font-semibold text-slate-500">Data</label>
                            <select v-model="datePreset" class="mt-2 h-11 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800" @change="runFilters">
                                <option value="today">Hoje</option>
                                <option value="yesterday">Ontem</option>
                                <option value="7d">Últimos 7 dias</option>
                                <option value="30d">Últimos 30 dias</option>
                                <option value="custom">Personalizado</option>
                            </select>
                        </div>
                    </div>

                    <div v-if="datePreset === 'custom'" class="mt-3 grid grid-cols-1 gap-3 md:grid-cols-2">
                        <div>
                            <label class="text-xs font-semibold text-slate-500">Início</label>
                            <input v-model="start" type="date" class="mt-2 h-11 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800" @change="runFilters" />
                        </div>
                        <div>
                            <label class="text-xs font-semibold text-slate-500">Fim</label>
                            <input v-model="end" type="date" class="mt-2 h-11 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800" @change="runFilters" />
                        </div>
                    </div>
                </div>
            </div>

            <div class="mt-4 rounded-2xl bg-slate-50 p-5 ring-1 ring-slate-200/60">
                <div class="mt-4 space-y-3">
                    <div
                        v-for="row in props.logs.data"
                        :key="row.id"
                        class="rounded-2xl bg-slate-50 p-4 ring-1 ring-slate-200/60"
                    >
                        <div class="flex flex-wrap items-center gap-2">
                            <span class="rounded-full px-3 py-1 text-xs font-semibold" :class="methodTone(row.method)">
                                {{ row.method }}
                            </span>
                            <span class="text-xs font-semibold text-slate-400">{{ formatDateTime(row.created_at) }}</span>
                            <span v-if="row.status_code" class="text-xs font-semibold text-slate-400">· {{ row.status_code }}</span>
                        </div>

                        <div class="mt-2 text-sm font-semibold text-slate-900">{{ row.path }}</div>
                        <div v-if="row.route_name" class="mt-1 text-xs font-semibold text-slate-400">{{ row.route_name }}</div>

                        <div v-if="row.actor" class="mt-3 text-xs font-semibold text-slate-500">
                            {{ row.actor.name }} · {{ row.actor.email }}
                        </div>

                        <details v-if="row.payload && Object.keys(row.payload).length" class="mt-3">
                            <summary class="cursor-pointer text-xs font-semibold text-slate-500">▸ Ver payload</summary>
                            <div class="mt-2 flex items-center justify-end">
                                <button
                                    type="button"
                                    class="rounded-xl bg-white px-3 py-2 text-xs font-semibold text-slate-700 ring-1 ring-slate-200/60 hover:bg-slate-50"
                                    @click.prevent="copyPayload(row)"
                                >
                                    {{ copiedId === row.id ? '✅ Copiado' : '📋 Copiar JSON' }}
                                </button>
                            </div>
                            <pre class="mt-2 overflow-x-auto rounded-xl bg-slate-900 p-3 text-[11px] text-slate-100 ring-1 ring-slate-800/60">{{ JSON.stringify(row.payload, null, 2) }}</pre>
                        </details>
                    </div>
                </div>

                <div v-if="props.logs.links?.length" class="mt-6 flex flex-wrap items-center justify-center gap-2">
                    <button
                        v-for="link in props.logs.links"
                        :key="link.label"
                        type="button"
                        class="rounded-full px-4 py-2 text-xs font-semibold ring-1"
                        :class="link.active ? 'bg-[#14B8A6] text-white ring-[#14B8A6]' : 'bg-white text-slate-600 ring-slate-200 hover:bg-slate-50'"
                        :disabled="!link.url"
                        v-html="link.label"
                        @click="link.url && router.visit(link.url)"
                    />
                </div>
            </div>
        </AdminLayout>
    </component>
</template>
