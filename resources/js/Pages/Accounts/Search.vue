<script setup lang="ts">
import { ref } from 'vue';
import { Head, Link } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import SorsLayout from '@/Layouts/SorsLayout.vue';
import { useMediaQuery } from '@/composables/useMediaQuery';

const isMobile = useMediaQuery('(max-width: 767px)');
const query = ref('');
const recent = ref(['Supermercado', 'Internet', 'Aluguel']);
</script>

<template>
    <Head title="Buscar" />

    <MobileShell v-if="isMobile" :show-nav="false">
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
                        class="w-full bg-transparent text-sm font-semibold text-slate-700 placeholder:text-slate-300 focus:outline-none"
                        aria-label="Buscar transações"
                    />
                </div>
            </div>
        </header>

        <div class="mt-8">
            <div class="text-sm font-bold text-slate-900">Buscas recentes</div>

            <div class="mt-4 space-y-4">
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
        </div>
    </MobileShell>

    <SorsLayout v-else title="Buscar" subtitle="Mobile-only por enquanto.">
        <div class="rounded-[28px] border border-white/70 bg-white p-8 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)]">
            <div class="text-sm font-semibold text-slate-900">Busca</div>
            <div class="mt-2 text-sm text-slate-500">Vamos adaptar essa tela depois da versão mobile.</div>
        </div>
    </SorsLayout>
</template>
