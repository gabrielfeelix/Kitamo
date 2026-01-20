<script setup lang="ts">
import { computed, onMounted, ref } from 'vue';
import { Head, Link } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import { requestJson } from '@/lib/kitamoApi';
import { useIsMobile } from '@/composables/useIsMobile';

type NotificationItem = {
  id: string;
  title: string;
  body: string;
  type?: string;
  priority?: string;
  read_at: string | null;
  created_at: string;
  action?: { type?: string | null; url?: string | null } | null;
  metadata?: any;
};

const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() =>
  isMobile.value
    ? { showNav: false }
    : { title: 'Notificações', subtitle: 'Central de alertas', showSearch: false, showNewAction: false },
);
const loading = ref(false);
const items = ref<NotificationItem[]>([]);

const unreadCount = computed(() => items.value.filter((n) => !n.read_at).length);

const load = async () => {
  loading.value = true;
  try {
    const response = await requestJson<{ notifications: NotificationItem[] }>(route('api.notifications.index'));
    items.value = response.notifications ?? [];
  } finally {
    loading.value = false;
  }
};

const formatWhen = (iso: string) => {
  try {
    return new Intl.DateTimeFormat('pt-BR', { day: '2-digit', month: '2-digit', year: '2-digit', hour: '2-digit', minute: '2-digit' }).format(new Date(iso));
  } catch {
    return '';
  }
};

const iconForType = (type?: string) => {
  if (type === 'vencimento') return '⏰';
  if (type === 'alerta_saldo') return '⚠️';
  if (type === 'resumo_semanal') return '📊';
  return '🔔';
};

const markRead = async (id: string) => {
  await requestJson(route('api.notifications.read', id), { method: 'PATCH' });
  items.value = items.value.map((n) => (n.id === id ? { ...n, read_at: new Date().toISOString() } : n));
};

const markAllRead = async () => {
  await requestJson(route('api.notifications.read-all'), { method: 'POST' });
  const now = new Date().toISOString();
  items.value = items.value.map((n) => (n.read_at ? n : { ...n, read_at: now }));
};

const clearRead = async () => {
  await requestJson(route('api.notifications.clear-read'), { method: 'DELETE' });
  items.value = items.value.filter((n) => !n.read_at);
};

const removeNotification = async (id: string) => {
  await requestJson(route('api.notifications.delete', id), { method: 'DELETE' });
  items.value = items.value.filter((n) => n.id !== id);
};

onMounted(load);
</script>

<template>
  <Head title="Notificações" />

  <component :is="Shell" v-bind="shellProps">
    <header v-if="isMobile" class="flex items-center gap-3 pt-2">
      <Link
        :href="route('dashboard')"
        class="flex h-10 w-10 items-center justify-center rounded-2xl bg-white text-slate-600 shadow-sm ring-1 ring-slate-200/60"
        aria-label="Voltar"
      >
        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M15 18l-6-6 6-6" />
        </svg>
      </Link>
      <div class="flex-1">
        <div class="text-xl font-semibold tracking-tight text-slate-900">Notificações</div>
        <div class="text-xs font-semibold text-slate-400">{{ unreadCount }} não lidas</div>
      </div>
      <div class="flex items-center gap-2">
        <button type="button" class="rounded-2xl bg-slate-100 px-4 py-2 text-xs font-semibold text-slate-600 disabled:opacity-60" @click="markAllRead" :disabled="loading || unreadCount === 0">
          Marcar lidas
        </button>
        <button type="button" class="rounded-2xl bg-slate-100 px-4 py-2 text-xs font-semibold text-slate-600 disabled:opacity-60" @click="load" :disabled="loading">
          Atualizar
        </button>
      </div>
    </header>

    <div v-if="!isMobile" class="flex items-center justify-between">
      <div class="text-sm font-semibold text-slate-500">{{ unreadCount }} não lidas</div>
      <div class="flex items-center gap-2">
        <button type="button" class="rounded-2xl bg-slate-100 px-4 py-2 text-sm font-semibold text-slate-600 disabled:opacity-60" @click="markAllRead" :disabled="loading || unreadCount === 0">
          Marcar todas como lidas
        </button>
        <button type="button" class="rounded-2xl bg-slate-100 px-4 py-2 text-sm font-semibold text-slate-600 disabled:opacity-60" @click="clearRead" :disabled="loading || items.every((n) => !n.read_at)">
          Limpar lidas
        </button>
        <button type="button" class="rounded-2xl bg-slate-100 px-4 py-2 text-sm font-semibold text-slate-600 disabled:opacity-60" @click="load" :disabled="loading">
          Atualizar
        </button>
      </div>
    </div>

    <div v-if="!items.length && !loading" class="mt-8 rounded-3xl border border-dashed border-slate-200 bg-slate-50 px-5 py-10 text-center md:mx-auto md:max-w-2xl">
      <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-white text-slate-400">
        <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M15 17h5l-1.4-1.4A2 2 0 0 1 18 14V11a6 6 0 1 0-12 0v3a2 2 0 0 1-.6 1.6L4 17h5" />
          <path d="M9 17a3 3 0 0 0 6 0" />
        </svg>
      </div>
      <div class="mt-3 text-sm font-semibold text-slate-900">Sem notificações</div>
      <div class="mt-1 text-xs text-slate-500">Quando algo importante acontecer, avisamos por aqui.</div>
    </div>

    <div v-else class="mt-6 space-y-3 md:mx-auto md:max-w-2xl">
      <div v-for="n in items" :key="n.id" class="rounded-3xl bg-white px-5 py-4 shadow-sm ring-1 ring-slate-200/60">
        <div class="flex items-start justify-between gap-4">
          <div class="flex min-w-0 gap-3">
            <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-2xl bg-slate-50 ring-1 ring-slate-200/60">{{ iconForType(n.type) }}</div>
            <div class="min-w-0">
              <div class="truncate text-sm font-semibold" :class="n.read_at ? 'text-slate-700' : 'text-slate-900'">{{ n.title }}</div>
              <div class="mt-1 text-xs text-slate-500">{{ n.body }}</div>
              <div v-if="n.created_at" class="mt-2 text-[11px] font-semibold text-slate-400">{{ formatWhen(n.created_at) }}</div>
            </div>
          </div>
          <div class="flex items-center gap-2">
            <button
              v-if="!n.read_at"
              type="button"
              class="rounded-xl bg-slate-100 px-3 py-2 text-xs font-semibold text-slate-600"
              @click="markRead(n.id)"
            >
              Marcar lida
            </button>
            <button
              type="button"
              class="flex h-10 w-10 items-center justify-center rounded-xl bg-slate-100 text-slate-500"
              aria-label="Excluir"
              @click="removeNotification(n.id)"
            >
              <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M3 6h18" />
                <path d="M8 6V4h8v2" />
                <path d="M19 6l-1 16H6L5 6" />
                <path d="M10 11v6" />
                <path d="M14 11v6" />
              </svg>
            </button>
            <span v-if="!n.read_at" class="h-2 w-2 shrink-0 rounded-full bg-red-500"></span>
          </div>
        </div>
      </div>
    </div>
  </component>
</template>
