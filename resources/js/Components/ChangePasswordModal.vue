<script setup lang="ts">
import { ref, watch } from 'vue';
import { useForm } from '@inertiajs/vue3';

const props = defineProps<{
    open: boolean;
}>();

const emit = defineEmits<{
    (event: 'close'): void;
}>();

const close = () => emit('close');

const form = useForm({
    current_password: '',
    password: '',
    password_confirmation: '',
});

watch(
    () => props.open,
    (isOpen) => {
        if (!isOpen) return;
        form.reset();
        form.clearErrors();
    },
);

const submit = () => {
    form.put(route('password.update'), {
        preserveScroll: true,
        onSuccess: () => {
            close();
        },
    });
};

const showPassword = ref(false);
</script>

<template>
    <div v-if="open" class="fixed inset-0 z-[80]">
        <button class="absolute inset-0 bg-black/50 backdrop-blur-sm" type="button" @click="close" aria-label="Fechar"></button>

        <div class="absolute inset-x-0 bottom-0 h-[520px] max-h-[calc(100vh-220px)] w-full overflow-hidden rounded-t-[24px] bg-white shadow-[0_-4px_20px_rgba(0,0,0,0.25)]">
            <div class="flex h-full flex-col">
                <header class="relative flex h-14 items-center px-4">
                    <button class="h-10 w-10 rounded-full bg-slate-100 text-slate-500" type="button" @click="close" aria-label="Fechar">
                        <svg class="mx-auto h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M18 6L6 18" />
                            <path d="M6 6l12 12" />
                        </svg>
                    </button>
                    <div class="pointer-events-none absolute inset-0 flex items-center justify-center">
                        <div class="text-[16px] font-bold text-[#1F2937]">Trocar senha</div>
                    </div>
                </header>

                <div class="flex-1 overflow-y-auto px-6 pb-6">
                    <div class="space-y-4">
                        <div>
                            <div class="mb-2 text-sm font-bold text-[#374151]">Senha atual</div>
                            <input
                                v-model="form.current_password"
                                :type="showPassword ? 'text' : 'password'"
                                class="h-11 w-full rounded-lg border border-[#E5E7EB] bg-[#F9FAFB] px-3 text-base text-[#374151] focus:border-[#14B8A6] focus:outline-none focus:ring-0"
                                autocomplete="current-password"
                            />
                            <div v-if="form.errors.current_password" class="mt-1 text-xs font-semibold text-red-500">{{ form.errors.current_password }}</div>
                        </div>

                        <div>
                            <div class="mb-2 text-sm font-bold text-[#374151]">Nova senha</div>
                            <input
                                v-model="form.password"
                                :type="showPassword ? 'text' : 'password'"
                                class="h-11 w-full rounded-lg border border-[#E5E7EB] bg-[#F9FAFB] px-3 text-base text-[#374151] focus:border-[#14B8A6] focus:outline-none focus:ring-0"
                                autocomplete="new-password"
                            />
                            <div v-if="form.errors.password" class="mt-1 text-xs font-semibold text-red-500">{{ form.errors.password }}</div>
                        </div>

                        <div>
                            <div class="mb-2 text-sm font-bold text-[#374151]">Confirmar nova senha</div>
                            <input
                                v-model="form.password_confirmation"
                                :type="showPassword ? 'text' : 'password'"
                                class="h-11 w-full rounded-lg border border-[#E5E7EB] bg-[#F9FAFB] px-3 text-base text-[#374151] focus:border-[#14B8A6] focus:outline-none focus:ring-0"
                                autocomplete="new-password"
                            />
                            <div v-if="form.errors.password_confirmation" class="mt-1 text-xs font-semibold text-red-500">{{ form.errors.password_confirmation }}</div>
                        </div>

                        <button type="button" class="inline-flex items-center gap-2 text-sm font-semibold text-slate-500" @click="showPassword = !showPassword">
                            <span class="flex h-5 w-5 items-center justify-center rounded-md border border-slate-200 bg-white">
                                <svg v-if="showPassword" class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12Z" />
                                    <circle cx="12" cy="12" r="3" />
                                </svg>
                                <svg v-else class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M3 3l18 18" />
                                    <path d="M10.6 10.6a2 2 0 0 0 2.8 2.8" />
                                    <path d="M9 5.5A10.5 10.5 0 0 1 12 5c6 0 10 7 10 7a18.3 18.3 0 0 1-3.5 4.6" />
                                    <path d="M6.2 6.2A18.4 18.4 0 0 0 2 12s4 7 10 7c1.3 0 2.5-.2 3.6-.6" />
                                </svg>
                            </span>
                            {{ showPassword ? 'Ocultar senha' : 'Mostrar senha' }}
                        </button>
                    </div>
                </div>

                <footer class="px-6 pb-[calc(24px+env(safe-area-inset-bottom))] pt-3">
                    <button
                        type="button"
                        class="h-[52px] w-full rounded-xl bg-[#14B8A6] text-base font-bold text-white shadow-[0_2px_8px_rgba(20,184,166,0.25)] disabled:opacity-60"
                        :disabled="form.processing"
                        @click="submit"
                    >
                        Salvar
                    </button>
                </footer>
            </div>
        </div>
    </div>
</template>

