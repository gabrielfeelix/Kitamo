<script setup lang="ts">
import { computed, ref } from 'vue';
import { router, usePage } from '@inertiajs/vue3';
import type { CreditCard } from '@/types/kitamo';
import MobileShell from '@/Layouts/MobileShell.vue';
import KitamoLayout from '@/Layouts/KitamoLayout.vue';
import CreditCardModal, { type CreditCardModalPayload } from '@/Components/CreditCardModal.vue';
import ConfirmationModal from '@/Components/ConfirmationModal.vue';
import { useIsMobile } from '@/composables/useIsMobile';
import { requestJson } from '@/lib/kitamoApi';

const page = usePage();
const isMobile = useIsMobile();

// Data
const cardsList = ref<CreditCard[]>((page.props as any).creditCards || []);

// Modals
const createModalOpen = ref(false);
const deleteConfirmOpen = ref(false);
const selectedCard = ref<CreditCard | null>(null);
const toastOpen = ref(false);
const toastMessage = ref('');

// Toast
const showToast = (message: string) => {
  toastMessage.value = message;
  toastOpen.value = true;
};

// Create new card
const openCreateModal = () => {
  selectedCard.value = null;
  createModalOpen.value = true;
};

// Edit card
const openEditModal = (card: CreditCard) => {
  selectedCard.value = card;
  createModalOpen.value = true;
};

// Delete card
const openDeleteConfirm = (card: CreditCard) => {
  selectedCard.value = card;
  deleteConfirmOpen.value = true;
};

// Save card (create or update)
const saveCard = async (payload: CreditCardModalPayload) => {
  try {
    if (payload.id) {
      await requestJson(`/api/cartoes/${payload.id}`, {
        method: 'PATCH',
        body: JSON.stringify(payload),
      });
      showToast('✅ Cartão atualizado');
      router.reload();
    } else {
      await requestJson('/api/cartoes', {
        method: 'POST',
        body: JSON.stringify({ ...payload, icone: 'credit-card' }),
      });
      showToast('✅ Cartão adicionado com sucesso!');
      router.reload();
    }
  } catch (error) {
    console.error(error);
    showToast('❌ Erro ao salvar cartão');
  }
};

// Delete card
const deleteCard = async () => {
  if (!selectedCard.value) return;

  try {
    await requestJson(`/api/cartoes/${selectedCard.value.id}`, { method: 'DELETE' });
    deleteConfirmOpen.value = false;
    selectedCard.value = null;
    showToast('Cartão excluído');
    router.reload();
  } catch (error) {
    console.error(error);
    showToast('❌ Erro ao excluir cartão');
  }
};

// Formatting
const formatMoney = (value: number) =>
  new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL',
  }).format(value);

const percentuoUsado = (card: CreditCard) => {
  if (card.limite === 0) return 0;
  return Math.min(100, Math.max(0, Math.round((card.limite_usado / card.limite) * 100)));
};

const corProgresso = (card: CreditCard) => {
  const pct = percentuoUsado(card);
  if (pct < 50) return '#10B981'; // green
  if (pct < 80) return '#F59E0B'; // yellow
  return '#EF4444'; // red
};
</script>

<template>
  <MobileShell v-if="isMobile">
    <header class="flex items-center justify-between pt-2">
      <h1 class="text-xl font-semibold text-slate-900">Cartões</h1>
      <button
        @click="openCreateModal"
        class="flex h-10 w-10 items-center justify-center rounded-2xl bg-[#14B8A6] text-white shadow-lg shadow-teal-500/20 hover:bg-[#0D9488]"
        aria-label="Adicionar cartão"
      >
        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <line x1="12" y1="5" x2="12" y2="19"></line>
          <line x1="5" y1="12" x2="19" y2="12"></line>
        </svg>
      </button>
    </header>

    <div v-if="cardsList.length" class="mt-6 space-y-3">
      <div v-for="card in cardsList" :key="card.id" class="overflow-hidden rounded-2xl shadow-sm ring-1 ring-slate-200/60">
        <!-- Card -->
        <div
          class="aspect-video rounded-2xl bg-gradient-to-br from-white to-slate-50 p-5"
          :style="{ backgroundColor: card.cor, backgroundImage: 'none' }"
        >
          <div class="flex items-start justify-between">
            <div>
              <div class="text-sm font-semibold text-white/80">{{ card.bandeira.toUpperCase() }}</div>
              <div class="mt-2 text-lg font-bold text-white">{{ card.nome }}</div>
            </div>
            <button
              class="flex h-8 w-8 items-center justify-center rounded-full bg-white/20 text-white hover:bg-white/30"
              @click.stop="openEditModal(card)"
              aria-label="Mais opções"
            >
              <svg class="h-5 w-5" viewBox="0 0 24 24" fill="currentColor">
                <circle cx="12" cy="5" r="2"></circle>
                <circle cx="12" cy="12" r="2"></circle>
                <circle cx="12" cy="19" r="2"></circle>
              </svg>
            </button>
          </div>

          <div class="mt-auto pt-8">
            <div class="text-xs font-semibold text-white/70">Limite: {{ formatMoney(card.limite) }}</div>
          </div>
        </div>

        <!-- Info -->
        <div class="bg-white p-4">
          <div class="flex items-center justify-between text-sm">
            <span class="text-slate-600">Usado: {{ percentuoUsado(card) }}%</span>
            <span class="text-slate-600">Disponível: {{ formatMoney(card.limite - card.limite_usado) }}</span>
          </div>

          <div class="mt-3 h-2 overflow-hidden rounded-full bg-slate-200">
            <div
              class="h-full transition-all"
              :style="{ width: `${percentuoUsado(card)}%`, backgroundColor: corProgresso(card) }"
            ></div>
          </div>

          <div class="mt-4 flex gap-2 text-xs text-slate-500">
            <span>Fecha: {{ card.dia_fechamento }}</span>
            <span>•</span>
            <span>Vence: {{ card.dia_vencimento }}</span>
          </div>
        </div>
      </div>
    </div>

    <div v-else class="mt-8 rounded-2xl border border-dashed border-slate-200 bg-slate-50 p-8 text-center">
      <div class="text-sm font-semibold text-slate-900">Nenhum cartão cadastrado</div>
      <div class="mt-1 text-xs text-slate-500">Adicione seu primeiro cartão de crédito</div>
      <button
        @click="openCreateModal"
        class="mt-4 inline-flex rounded-xl bg-[#14B8A6] px-4 py-2 text-sm font-semibold text-white hover:bg-[#0D9488]"
      >
        Adicionar cartão
      </button>
    </div>
  </MobileShell>

  <KitamoLayout v-else title="Cartões de Crédito" subtitle="Gerencie seus cartões de crédito">
    <div class="mx-auto max-w-4xl">
      <header class="flex items-center justify-between py-6">
        <h1 class="text-2xl font-bold text-slate-900">Cartões de Crédito</h1>
        <button
          @click="openCreateModal"
          class="rounded-xl bg-[#14B8A6] px-6 py-2 font-semibold text-white shadow-lg shadow-teal-500/20 hover:bg-[#0D9488]"
        >
          + Adicionar Cartão
        </button>
      </header>

      <div v-if="cardsList.length" class="grid gap-4 sm:grid-cols-2">
        <div v-for="card in cardsList" :key="card.id" class="rounded-xl border border-slate-200 p-6">
          <div class="flex items-start justify-between">
            <div>
              <div class="text-sm text-slate-600">{{ card.bandeira.toUpperCase() }}</div>
              <div class="mt-2 text-lg font-semibold text-slate-900">{{ card.nome }}</div>
            </div>
            <button
              class="flex h-8 w-8 items-center justify-center rounded-lg text-slate-400 hover:bg-slate-100"
              @click.stop="openEditModal(card)"
              aria-label="Editar"
            >
              <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M12 5v14M5 12h14"></path>
              </svg>
            </button>
          </div>

          <div class="mt-4 space-y-2 text-sm">
            <div class="flex justify-between">
              <span class="text-slate-600">Limite:</span>
              <span class="font-semibold text-slate-900">{{ formatMoney(card.limite) }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-slate-600">Disponível:</span>
              <span class="font-semibold text-slate-900">{{ formatMoney(card.limite - card.limite_usado) }}</span>
            </div>
          </div>

          <div class="mt-4 flex items-center justify-between">
            <div class="h-2 flex-1 rounded-full bg-slate-200">
              <div
                class="h-full rounded-full transition-all"
                :style="{ width: `${percentuoUsado(card)}%`, backgroundColor: corProgresso(card) }"
              ></div>
            </div>
            <span class="ml-3 text-xs font-semibold text-slate-600">{{ percentuoUsado(card) }}%</span>
          </div>

          <div class="mt-4 flex gap-2 border-t border-slate-200 pt-4">
            <button
              @click="openEditModal(card)"
              class="flex-1 rounded-lg bg-slate-100 py-2 text-sm font-semibold text-slate-700 hover:bg-slate-200"
            >
              Editar
            </button>
            <button
              @click="openDeleteConfirm(card)"
              class="flex-1 rounded-lg bg-red-50 py-2 text-sm font-semibold text-red-600 hover:bg-red-100"
            >
              Excluir
            </button>
          </div>
        </div>
      </div>

      <div v-else class="rounded-xl border border-dashed border-slate-200 bg-slate-50 p-12 text-center">
        <div class="text-lg font-semibold text-slate-900">Nenhum cartão cadastrado</div>
        <div class="mt-2 text-slate-600">Adicione seu primeiro cartão de crédito para começar</div>
      </div>
    </div>
  </KitamoLayout>

  <!-- Modals -->
  <CreditCardModal
    :open="createModalOpen"
    :initial="
      selectedCard
        ? {
            id: selectedCard.id,
            nome: selectedCard.nome,
            bandeira: selectedCard.bandeira,
            limite: selectedCard.limite,
            dia_fechamento: selectedCard.dia_fechamento,
            dia_vencimento: selectedCard.dia_vencimento,
            cor: selectedCard.cor,
          }
        : null
    "
    @close="createModalOpen = false"
    @save="saveCard"
  />

  <ConfirmationModal
    :open="deleteConfirmOpen"
    :title="`Excluir cartão?`"
    :message="`Tem certeza que deseja excluir? Esta ação não pode ser desfeita.`"
    :danger="true"
    @confirm="deleteCard"
    @close="deleteConfirmOpen = false"
  />

  <!-- Toast -->
  <div v-if="toastOpen" class="fixed inset-x-5 bottom-20 z-[80] rounded-2xl bg-slate-900 px-4 py-3 shadow-2xl">
    <div class="text-sm font-semibold text-white">{{ toastMessage }}</div>
  </div>
</template>
