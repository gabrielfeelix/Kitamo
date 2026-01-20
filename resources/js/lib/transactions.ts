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
    remove_receipt: payload.removeReceipt ?? false,
    isRecorrente: payload.isRecorrente ?? false,
    periodicidade: payload.isRecorrente ? payload.periodicidade : null,
    intervalo_dias: payload.isRecorrente ? payload.intervalo_dias : null,
    data_fim: payload.isRecorrente ? payload.data_fim : null,
});

export const hasTransactionReceipt = (payload: TransactionModalPayload) => Boolean(payload.receiptFile);

export const buildTransactionFormData = (payload: TransactionModalPayload) => {
    const data = new FormData();

    data.set('kind', payload.kind);
    data.set('amount', String(payload.amount));
    data.set('description', payload.description);
    data.set('category', payload.category ?? '');
    data.set('account', payload.account ?? '');
    data.set('dateKind', payload.dateKind);
    if (payload.dateOther) data.set('dateOther', payload.dateOther);

    data.set('isPaid', payload.isPaid ? '1' : '0');
    data.set('isInstallment', payload.isInstallment ? '1' : '0');
    data.set('installmentCount', String(payload.installmentCount ?? 1));

    data.set('isRecorrente', payload.isRecorrente ? '1' : '0');
    if (payload.isRecorrente && payload.periodicidade) data.set('periodicidade', payload.periodicidade);
    if (payload.isRecorrente && payload.intervalo_dias != null) data.set('intervalo_dias', String(payload.intervalo_dias));
    if (payload.isRecorrente && payload.data_fim) data.set('data_fim', payload.data_fim);

    data.set('remove_receipt', payload.removeReceipt ? '1' : '0');

    for (const tag of payload.tags ?? []) {
        data.append('tags[]', tag);
    }

    if (payload.receiptFile) {
        data.set('receipt', payload.receiptFile);
    }

    return data;
};
