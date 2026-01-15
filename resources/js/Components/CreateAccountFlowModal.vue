<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import { router } from '@inertiajs/vue3';
import { requestJson } from '@/lib/kitamoApi';
import CreateAccountStep1, { type BancoSelecionado } from '@/Components/CreateAccountStep1.vue';
import CreateAccountStep2 from '@/Components/CreateAccountStep2.vue';
import CreateAccountStep3, { type AccountPayload } from '@/Components/CreateAccountStep3.vue';

const props = defineProps<{
  open: boolean;
}>();

const emit = defineEmits<{
  (event: 'close'): void;
  (event: 'toast', message: string): void;
}>();

type Step = 1 | 2 | 3;
const step = ref<Step>(1);
const banco = ref<BancoSelecionado | null>(null);

watch(
  () => props.open,
  (isOpen) => {
    if (!isOpen) return;
    step.value = 1;
    banco.value = null;
  },
);

const close = () => emit('close');

const handleSelectBank = (value: BancoSelecionado) => {
  banco.value = value;
  step.value = 2;
};

const handleSelectMethod = (method: 'manual' | 'automatic') => {
  if (method === 'manual') step.value = 3;
};

const mapAccountType = (payload: AccountPayload) => {
  if (payload.tipo === 'dinheiro') return { type: 'wallet', icon: 'wallet' };
  return { type: 'bank', icon: 'bank' };
};

const buildName = (payload: AccountPayload) => {
  const base = payload.banco_nome;
  const suffix = payload.descricao ? ` - ${payload.descricao}` : '';
  return `${base}${suffix}`.trim();
};

const createAccount = async (payload: AccountPayload) => {
  const { type, icon } = mapAccountType(payload);
  const response = await requestJson<{ account: unknown }>('/api/contas', {
    method: 'POST',
    body: JSON.stringify({
      name: buildName(payload),
      type,
      icon,
      initial_balance: payload.saldo_inicial,
    }),
  });
  return response;
};

const handleSave = async (payload: AccountPayload, createNew: boolean) => {
  try {
    await createAccount(payload);
    emit('toast', '✅ Conta adicionada!');
    if (createNew) {
      step.value = 1;
      banco.value = null;
      router.reload();
      return;
    }
    router.reload();
    close();
  } catch {
    emit('toast', '❌ Não foi possível adicionar a conta');
  }
};

const openStep1 = computed(() => props.open && step.value === 1);
const openStep2 = computed(() => props.open && step.value === 2);
const openStep3 = computed(() => props.open && step.value === 3);
</script>

<template>
  <CreateAccountStep1 :open="openStep1" @close="close" @select="handleSelectBank" />
  <CreateAccountStep2
    :open="openStep2"
    :banco="banco"
    @close="close"
    @back="step = 1"
    @select-method="handleSelectMethod"
  />
  <CreateAccountStep3
    :open="openStep3"
    :banco="banco"
    @close="close"
    @back="step = 1"
    @save="handleSave"
  />
</template>

