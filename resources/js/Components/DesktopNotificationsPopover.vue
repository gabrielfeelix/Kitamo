<script setup lang="ts">
import { computed, watch, ref } from 'vue';
import { Link } from '@inertiajs/vue3';
import { requestJson } from '@/lib/kitamoApi';

type NotificationItem = {
    id: string;
    title: string;
    body: string;
    read_at: string | null;
    created_at: string;
};

const props = defineProps<{
    open: boolean;
}>();

const emit = defineEmits<{
    (e: 'close'): void;
    (e: 'unread', count: number): void;
}>();

const loading = ref(false);
const items = ref<NotificationItem[]>([]);

const unreadCount = computed(() => items.value.filter((n) => !n.read_at).length);
const preview = computed(() => items.value.slice(0, 6));

const load = async () => {
    loading.value = true;
    try {
        const response = await requestJson<{ notifications: NotificationItem[] }>(route('api.notifications.index'));
        items.value = response.notifications ?? [];
        emit('unread', unreadCount.value);
    } finally {
        loading.value = false;
    }
};

watch(
    () => props.open,
    (isOpen) => {
        if (!isOpen) return;
        load();
    },
);
</script>

<template>
    <Teleport to="body">
        <div v-if="open" class="fixed inset-0 z-[90]">
            <button class="absolute inset-0 bg-black/10" type="button" aria-label="Fechar" @click="emit('close')"></button>

            <section
                class="absolute right-8 top-[76px] w-[420px] overflow-hidden rounded-3xl bg-white shadow-[0_30px_90px_-45px_rgba(15,23,42,0.55)] ring-1 ring-slate-200/60"
                role="dialog"
                aria-modal="true"
            >
                <div class="flex items-center justify-between border-b border-slate-100 px-5 py-4">
                    <div>
                        <div class="text-sm font-semibold text-slate-900">Notificações</div>
                        <div class="mt-0.5 text-xs font-semibold text-slate-400">{{ unreadCount }} não lidas</div>
                    </div>

                    <div class="flex items-center gap-2">
                        <Link
                            :href="route('notifications.index')"
                            class="rounded-2xl bg-emerald-50 px-3 py-2 text-xs font-semibold text-emerald-700"
                            @click="emit('close')"
                        >
                            Ver todas
                        </Link>
                    </div>
                </div>

                <div class="max-h-[420px] overflow-y-auto px-5 py-4">
                    <div v-if="loading" class="rounded-2xl bg-slate-50 px-4 py-10 text-center text-sm font-semibold text-slate-500 ring-1 ring-slate-100">
                        Carregando…
                    </div>

                    <div v-else-if="preview.length === 0" class="rounded-2xl bg-slate-50 px-4 py-10 text-center ring-1 ring-slate-100">
                        <div class="text-sm font-semibold text-slate-900">Sem notificações</div>
                        <div class="mt-1 text-xs font-semibold text-slate-500">Quando algo importante acontecer, avisamos por aqui.</div>
                    </div>

                    <div v-else class="space-y-3">
                        <div
                            v-for="n in preview"
                            :key="n.id"
                            class="rounded-2xl bg-white px-4 py-3 ring-1 ring-slate-200/60"
                        >
                            <div class="flex items-start justify-between gap-3">
                                <div class="min-w-0">
                                    <div class="truncate text-sm font-semibold" :class="n.read_at ? 'text-slate-700' : 'text-slate-900'">
                                        {{ n.title }}
                                    </div>
                                    <div class="mt-1 line-clamp-2 text-xs font-semibold text-slate-500">{{ n.body }}</div>
                                </div>
                                <span v-if="!n.read_at" class="mt-1 h-2 w-2 shrink-0 rounded-full bg-red-500"></span>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </div>
    </Teleport>
</template>
