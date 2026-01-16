<script setup lang="ts">
import { computed, onMounted, ref } from 'vue';
import { Head, Link } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import KitamoLayout from '@/Layouts/KitamoLayout.vue';
import { requestJson } from '@/lib/kitamoApi';
import { useIsMobile } from '@/composables/useIsMobile';

type NotificationItem = {
  id: string;
  title: string;
  body: string;
  read_at: string | null;
  created_at: string;
};

const isMobile = useIsMobile();
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

onMounted(load);
</script>

<template>
  <Head title="Notificações" />

  <MobileShell v-if="isMobile" :show-nav="false">
    <header class="flex items-center gap-3 pt-2">
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
      <button type="button" class="rounded-2xl bg-slate-100 px-4 py-2 text-xs font-semibold text-slate-600" @click="load" :disabled="loading">
        Atualizar
      </button>
    </header>

    <div v-if="!items.length && !loading" class="mt-8 rounded-3xl border border-dashed border-slate-200 bg-slate-50 px-5 py-10 text-center">
      <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-white text-slate-400">
        <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M15 17h5l-1.4-1.4A2 2 0 0 1 18 14V11a6 6 0 1 0-12 0v3a2 2 0 0 1-.6 1.6L4 17h5" />
          <path d="M9 17a3 3 0 0 0 6 0" />
        </svg>
      </div>
      <div class="mt-3 text-sm font-semibold text-slate-900">Sem notificações</div>
      <div class="mt-1 text-xs text-slate-500">Quando algo importante acontecer, avisamos por aqui.</div>
    </div>

    <div v-else class="mt-6 space-y-3">
      <div v-for="n in items" :key="n.id" class="rounded-3xl bg-white px-5 py-4 shadow-sm ring-1 ring-slate-200/60">
        <div class="flex items-start justify-between gap-4">
          <div class="min-w-0">
            <div class="truncate text-sm font-semibold" :class="n.read_at ? 'text-slate-700' : 'text-slate-900'">{{ n.title }}</div>
            <div class="mt-1 text-xs text-slate-500">{{ n.body }}</div>
          </div>
          <span v-if="!n.read_at" class="mt-1 h-2 w-2 shrink-0 rounded-full bg-red-500"></span>
        </div>
      </div>
    </div>
  </MobileShell>

  <KitamoLayout v-else title="Notificações" subtitle="Central de alertas">
    <div class="rounded-2xl bg-white p-7 shadow-sm ring-1 ring-slate-200/60">
      <div class="flex items-center justify-between">
        <div class="text-sm font-semibold text-slate-700">{{ unreadCount }} não lidas</div>
        <button type="button" class="rounded-xl border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-600 hover:bg-slate-50" @click="load">
          Atualizar
        </button>
      </div>

      <div v-if="!items.length && !loading" class="mt-6 rounded-2xl border border-dashed border-slate-200 bg-slate-50 px-6 py-10 text-center">
        <div class="text-sm font-semibold text-slate-900">Sem notificações</div>
      </div>

      <div v-else class="mt-6 divide-y divide-slate-100">
        <div v-for="n in items" :key="n.id" class="py-4">
          <div class="text-sm font-semibold" :class="n.read_at ? 'text-slate-700' : 'text-slate-900'">{{ n.title }}</div>
          <div class="mt-1 text-sm text-slate-500">{{ n.body }}</div>
        </div>
      </div>
    </div>
  </KitamoLayout>
</template>
