import type { TransactionModalPayload } from '@/Components/TransactionModal.vue';

export const buildTransactionRequest = (payload: TransactionModalPayload) => ({
    kind: payload.kind,
    amount: payload.amount,
    description: payload.description,
    category: payload.category,
    account: payload.account,
    dateKind: payload.dateKind,
    dateOther: payload.dateOther,
    isPaid: payload.isPaid,
    isInstallment: payload.isInstallment,
    installmentCount: payload.installmentCount,
    tags: payload.tags ?? [],
    isRecorrente: payload.isRecorrente ?? false,
    periodicidade: payload.isRecorrente ? payload.periodicidade : null,
    intervalo_dias: payload.isRecorrente ? payload.intervalo_dias : null,
    data_fim: payload.isRecorrente ? payload.data_fim : null,
});
