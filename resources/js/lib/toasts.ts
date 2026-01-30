import { reactive } from 'vue';

export type ToastType = 'success' | 'error' | 'info';

export type Toast = {
    id: string;
    type: ToastType;
    message: string;
    dismissible: boolean;
    timeoutMs: number;
};

const state = reactive<{ items: Toast[] }>({ items: [] });

const remove = (id: string) => {
    state.items = state.items.filter((t) => t.id !== id);
};

const push = (type: ToastType, message: string, opts?: Partial<Pick<Toast, 'dismissible' | 'timeoutMs'>>) => {
    const id = `${Date.now()}-${Math.random().toString(16).slice(2)}`;
    const dismissible = opts?.dismissible ?? type === 'error';
    const timeoutMs =
        opts?.timeoutMs ??
        (type === 'error' ? 4000 : 3000);

    state.items.push({ id, type, message, dismissible, timeoutMs });

    if (timeoutMs > 0) {
        window.setTimeout(() => remove(id), timeoutMs);
    }
};

export const toasts = {
    state,
    remove,
    success: (message: string) => push('success', message, { dismissible: false, timeoutMs: 3000 }),
    info: (message: string) => push('info', message, { dismissible: false, timeoutMs: 3000 }),
    error: (message: string) => push('error', message, { dismissible: true, timeoutMs: 4000 }),
};

