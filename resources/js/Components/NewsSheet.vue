<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import PickerSheet from '@/Components/PickerSheet.vue';
import { requestJson } from '@/lib/kitamoApi';

type ReactionKey = 'fire' | 'happy' | 'sad';

export type NewsItemRow = {
    id: number;
    title: string;
    category: string | null;
    type: string;
    published_at: string | null;
    content: string | null;
    image_url: string | null;
    cta_text: string | null;
    cta_url: string | null;
    reactions?: Record<ReactionKey, number>;
    my_reaction?: ReactionKey | null;
};

const props = defineProps<{
    open: boolean;
}>();

const emit = defineEmits<{
    (e: 'close'): void;
}>();

const loading = ref(false);
const items = ref<NewsItemRow[]>([]);
const expanded = ref<Record<number, boolean>>({});

const ensureLoaded = async () => {
    if (loading.value) return;
    if (items.value.length > 0) return;
    loading.value = true;
    try {
        const res = await requestJson<{ items: NewsItemRow[] }>(route('api.news.index'));
        items.value = (res.items ?? []) as NewsItemRow[];
    } catch {
        items.value = [];
    } finally {
        loading.value = false;
    }
};

watch(
    () => props.open,
    (isOpen) => {
        if (!isOpen) return;
        ensureLoaded();
    },
);

const toggleExpanded = (id: number) => {
    expanded.value = { ...expanded.value, [id]: !expanded.value[id] };
};

const reactionsFor = (item: NewsItemRow) => {
    const r = item.reactions ?? { fire: 0, happy: 0, sad: 0 };
    return { fire: Number(r.fire ?? 0), happy: Number(r.happy ?? 0), sad: Number(r.sad ?? 0) };
};

const setReaction = async (item: NewsItemRow, reaction: ReactionKey) => {
    const current = item.my_reaction ?? null;
    const next = current === reaction ? null : reaction;

    // optimistic update
    const currentCounts = reactionsFor(item);
    const updatedCounts: Record<ReactionKey, number> = { ...currentCounts };
    if (current) updatedCounts[current] = Math.max(0, updatedCounts[current] - 1);
    if (next) updatedCounts[next] = updatedCounts[next] + 1;
    item.my_reaction = next;
    item.reactions = updatedCounts;

    try {
        const res = await requestJson<{ reactions: Record<ReactionKey, number>; my_reaction: ReactionKey | null }>(route('api.news.react', item.id), {
            method: 'POST',
            body: JSON.stringify({ reaction: next }),
        });
        item.reactions = res.reactions ?? updatedCounts;
        item.my_reaction = (res.my_reaction ?? next) as any;
    } catch {
        // rollback (best effort): reload list on failure
        items.value = [];
        expanded.value = {};
        ensureLoaded();
    }
};

const formatWhen = (iso: string | null) => {
    if (!iso) return '';
    try {
        return new Intl.DateTimeFormat('pt-BR', { day: '2-digit', month: 'short', year: 'numeric' }).format(new Date(iso));
    } catch {
        return '';
    }
};

const contentPreview = (content: string | null) => {
    const text = String(content ?? '')
        .replace(/<[^>]*>/g, ' ')
        .replace(/\s+/g, ' ')
        .trim();
    return text;
};

const hasLongText = (text: string) => text.length > 220;

const activeCls = (item: NewsItemRow, key: ReactionKey) =>
    item.my_reaction === key ? 'bg-emerald-50 text-emerald-700 ring-emerald-100' : 'bg-white text-slate-600 ring-slate-200 hover:bg-slate-50';
</script>

<template>
    <PickerSheet :open="open" title="Novidades" @close="emit('close')">
        <div v-if="loading" class="rounded-2xl bg-slate-50 px-4 py-6 text-center text-sm font-semibold text-slate-500 ring-1 ring-slate-200/60">
            Carregando…
        </div>

        <div v-else-if="items.length === 0" class="rounded-2xl bg-slate-50 px-4 py-8 text-center ring-1 ring-slate-200/60">
            <div class="text-sm font-semibold text-slate-900">Sem novidades</div>
            <div class="mt-1 text-xs font-semibold text-slate-500">Quando algo novo entrar no ar, aparece por aqui.</div>
        </div>

        <div v-else class="space-y-3 pb-2">
            <article
                v-for="n in items"
                :key="n.id"
                class="overflow-hidden rounded-3xl bg-white shadow-sm ring-1 ring-slate-200/60"
            >
                <button type="button" class="w-full text-left" @click="toggleExpanded(n.id)">
                    <div class="px-5 pt-5">
                        <div class="flex items-start justify-between gap-3">
                            <div class="min-w-0">
                                <div class="flex flex-wrap items-center gap-2">
                                    <span v-if="n.category" class="rounded-full bg-slate-100 px-3 py-1 text-[11px] font-bold text-slate-600 ring-1 ring-slate-200/60">
                                        {{ n.category }}
                                    </span>
                                    <span v-if="n.type" class="rounded-full bg-slate-100 px-3 py-1 text-[11px] font-bold text-slate-600 ring-1 ring-slate-200/60">
                                        {{ n.type }}
                                    </span>
                                    <span v-if="n.published_at" class="text-[11px] font-semibold text-slate-400">
                                        {{ formatWhen(n.published_at) }}
                                    </span>
                                </div>
                                <h3 class="mt-3 line-clamp-2 text-base font-semibold text-slate-900">{{ n.title }}</h3>
                                <p
                                    v-if="contentPreview(n.content)"
                                    class="mt-2 text-sm font-medium text-slate-600"
                                    :class="expanded[n.id] ? '' : 'line-clamp-3'"
                                >
                                    {{ contentPreview(n.content) }}
                                </p>
                                <div v-if="!expanded[n.id] && hasLongText(contentPreview(n.content))" class="mt-2 text-xs font-semibold text-slate-400">
                                    Toque para ver mais…
                                </div>
                            </div>

                            <svg class="mt-1 h-5 w-5 flex-shrink-0 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path :d="expanded[n.id] ? 'M6 15l6-6 6 6' : 'M6 9l6 6 6-6'" />
                            </svg>
                        </div>
                    </div>

                    <div v-if="n.image_url" class="mt-4">
                        <img :src="n.image_url" alt="" class="h-44 w-full object-cover md:h-56" loading="lazy" />
                    </div>
                </button>

                <div class="px-5 pb-5 pt-4">
                    <div class="flex flex-wrap items-center gap-2">
                        <button
                            type="button"
                            class="inline-flex items-center gap-2 rounded-full px-3 py-2 text-xs font-semibold ring-1 transition"
                            :class="activeCls(n, 'fire')"
                            @click.stop="setReaction(n, 'fire')"
                            aria-label="Reagir com fogo"
                        >
                            🔥 <span class="tabular-nums">{{ reactionsFor(n).fire }}</span>
                        </button>
                        <button
                            type="button"
                            class="inline-flex items-center gap-2 rounded-full px-3 py-2 text-xs font-semibold ring-1 transition"
                            :class="activeCls(n, 'happy')"
                            @click.stop="setReaction(n, 'happy')"
                            aria-label="Reagir com feliz"
                        >
                            🙂 <span class="tabular-nums">{{ reactionsFor(n).happy }}</span>
                        </button>
                        <button
                            type="button"
                            class="inline-flex items-center gap-2 rounded-full px-3 py-2 text-xs font-semibold ring-1 transition"
                            :class="activeCls(n, 'sad')"
                            @click.stop="setReaction(n, 'sad')"
                            aria-label="Reagir com triste"
                        >
                            🙁 <span class="tabular-nums">{{ reactionsFor(n).sad }}</span>
                        </button>
                    </div>

                    <div v-if="n.cta_text && n.cta_url" class="mt-4">
                        <a
                            :href="n.cta_url"
                            target="_blank"
                            rel="noreferrer"
                            class="inline-flex items-center justify-center rounded-2xl bg-slate-50 px-4 py-3 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60 hover:bg-slate-100"
                        >
                            {{ n.cta_text }}
                        </a>
                    </div>
                </div>
            </article>
        </div>
    </PickerSheet>
</template>

