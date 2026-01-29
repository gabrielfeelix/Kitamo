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

const query = ref(props.q ?? '');
watch(
    () => props.q,
    (v) => (query.value = v ?? ''),
);

let debounceTimer: number | null = null;
const runSearch = () => {
    if (debounceTimer) window.clearTimeout(debounceTimer);
    debounceTimer = window.setTimeout(() => {
        router.get(route('admin.logs.index'), { q: query.value || undefined }, { preserveState: true, preserveScroll: true, replace: true });
    }, 250);
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
</script>

<template>
    <Head title="Administração · Logs" />

    <component :is="Shell" v-bind="shellProps">
        <AdminLayout title="Logs de Ações" description="Registro de ações (POST/PATCH/DELETE) no sistema.">
            <div class="rounded-2xl bg-slate-50 p-5 ring-1 ring-slate-200/60">
                <label class="text-xs font-semibold uppercase tracking-wide text-slate-400">Buscar</label>
                <div class="mt-3 flex items-center gap-3 rounded-2xl bg-slate-50 px-4 py-3 ring-1 ring-slate-200/60">
                    <svg class="h-5 w-5 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="11" cy="11" r="7" />
                        <path d="M21 21l-4.3-4.3" />
                    </svg>
                    <input
                        v-model="query"
                        type="text"
                        class="w-full appearance-none border-0 bg-transparent p-0 text-sm font-semibold text-slate-700 placeholder:text-slate-400 outline-none focus:outline-none focus-visible:outline-none"
                        placeholder="Ex: /api/contas, admin.users.update, email"
                        @input="runSearch"
                    />
                </div>
            </div>

            <div class="mt-4 rounded-2xl bg-slate-50 p-5 ring-1 ring-slate-200/60">
                <div class="flex items-center justify-between">
                    <div class="text-sm font-semibold text-slate-900">Logs</div>
                    <div class="text-xs font-semibold text-slate-400">{{ props.logs.data.length }} itens</div>
                </div>

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
                            <summary class="cursor-pointer text-xs font-semibold text-slate-500">Ver payload</summary>
                            <pre class="mt-2 overflow-x-auto rounded-xl bg-white p-3 text-[11px] text-slate-700 ring-1 ring-slate-200/60">{{ JSON.stringify(row.payload, null, 2) }}</pre>
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
