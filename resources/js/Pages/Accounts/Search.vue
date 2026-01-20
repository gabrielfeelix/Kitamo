<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, Link, usePage } from '@inertiajs/vue3';
import type { BootstrapData } from '@/types/kitamo';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import { useIsMobile } from '@/composables/useIsMobile';

const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() =>
    isMobile.value ? { showNav: false } : { title: 'Buscar', showSearch: false, showNewAction: false },
);
const query = ref('');
const page = usePage();
const bootstrap = computed(
    () => (page.props.bootstrap ?? { entries: [], goals: [], accounts: [], categories: [], tags: [] }) as BootstrapData,
);
const entries = computed(() => bootstrap.value.entries ?? []);

const normalizedQuery = computed(() => query.value.trim().toLowerCase());
const results = computed(() => {
    const term = normalizedQuery.value;
    if (!term) return [];
    return entries.value
        .filter((entry) => {
            const haystack = [
                entry.title,
                entry.subtitle,
                entry.categoryLabel,
                entry.accountLabel,
                entry.dateLabel,
                entry.dayLabel,
            ]
                .filter(Boolean)
                .join(' ')
                .toLowerCase();
            return haystack.includes(term);
        })
        .slice(0, 30);
});

const recent = computed(() => {
    const seen = new Set();
    const result = [];
    for (const entry of entries.value) {
        const term = String(entry.title ?? '').trim();
        if (!term || seen.has(term)) continue;
        seen.add(term);
        result.push(term);
        if (result.length >= 3) break;
    }
    return result;
});
</script>


<template>
    <Head title="Buscar" />

    <component :is="Shell" v-bind="shellProps">
        <header class="flex items-center gap-3 pt-2">
            <Link
                :href="route('accounts.index')"
                class="flex h-10 w-10 items-center justify-center rounded-2xl bg-white text-slate-600 shadow-sm ring-1 ring-slate-200/60"
                aria-label="Voltar"
            >
                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M15 18l-6-6 6-6" />
                </svg>
            </Link>

            <div class="flex-1">
                <div class="flex h-11 items-center gap-2 rounded-2xl bg-white px-4 shadow-sm ring-1 ring-slate-200/60">
                    <svg class="h-5 w-5 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="11" cy="11" r="7" />
                        <path d="M20 20l-3.5-3.5" />
                    </svg>
                    <input
                        v-model="query"
                        type="text"
                        placeholder="Buscar transações..."
                        class="w-full appearance-none border-0 bg-transparent text-sm font-semibold text-slate-700 placeholder:text-slate-300 outline-none focus:outline-none focus:ring-0 focus-visible:outline-none"
                        aria-label="Buscar transações"
                    />
                </div>
            </div>
        </header>

        <div class="mt-8">
            <div class="text-sm font-bold text-slate-900">Buscas recentes</div>

            <div v-if="recent.length" class="mt-4 space-y-4">
                <button v-for="term in recent" :key="term" type="button" class="flex items-center gap-3 text-left" @click="query = term">
                    <span class="flex h-8 w-8 items-center justify-center rounded-full bg-slate-100 text-slate-500">
                        <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M12 7v6l4 2" />
                            <circle cx="12" cy="12" r="9" />
                        </svg>
                    </span>
                    <div class="text-sm font-semibold text-slate-500">{{ term }}</div>
                </button>
            </div>
            <div v-else class="mt-4 rounded-2xl border border-dashed border-slate-200 bg-slate-50 px-4 py-6 text-center">
                <div class="text-sm font-semibold text-slate-900">Sem buscas recentes</div>
                <div class="mt-1 text-xs text-slate-500">Suas buscas vão aparecer aqui.</div>
            </div>
        </div>

        <div class="mt-8">
            <div class="flex items-center justify-between">
                <div class="text-sm font-bold text-slate-900">Resultados</div>
                <div class="text-xs font-semibold text-slate-400">{{ results.length }}</div>
            </div>

            <div v-if="!normalizedQuery" class="mt-4 rounded-2xl border border-dashed border-slate-200 bg-slate-50 px-4 py-6 text-center">
                <div class="text-sm font-semibold text-slate-900">Digite para buscar</div>
                <div class="mt-1 text-xs text-slate-500">Nome, categoria, conta ou data.</div>
            </div>

            <div v-else-if="results.length === 0" class="mt-4 rounded-2xl border border-dashed border-slate-200 bg-slate-50 px-4 py-6 text-center">
                <div class="text-sm font-semibold text-slate-900">Nada encontrado</div>
                <div class="mt-1 text-xs text-slate-500">Tente outro termo.</div>
            </div>

            <div v-else class="mt-4 space-y-3">
                <Link
                    v-for="entry in results"
                    :key="entry.id"
                    :href="`${route('accounts.index')}?open=${encodeURIComponent(entry.id)}`"
                    class="flex items-center justify-between gap-4 rounded-2xl bg-white px-4 py-4 shadow-sm ring-1 ring-slate-200/60"
                >
                    <div class="min-w-0 flex-1">
                        <div class="truncate text-sm font-semibold text-slate-900">{{ entry.title }}</div>
                        <div class="mt-1 flex flex-wrap items-center gap-x-3 gap-y-1 text-xs font-semibold text-slate-400">
                            <span>{{ entry.categoryLabel }}</span>
                            <span class="text-slate-200">•</span>
                            <span>{{ entry.accountLabel }}</span>
                            <span class="text-slate-200">•</span>
                            <span>{{ entry.dayLabel }}</span>
                        </div>
                    </div>
                    <div class="shrink-0 text-right">
                        <div class="text-sm font-semibold" :class="entry.kind === 'income' ? 'text-emerald-600' : 'text-red-500'">
                            {{ entry.kind === 'income' ? '+' : '-' }} R$ {{ entry.amount.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) }}
                        </div>
                        <div class="mt-1 text-[10px] font-semibold uppercase tracking-wide text-slate-300">Detalhes</div>
                    </div>
                </Link>
            </div>
        </div>
    </component>
</template>
