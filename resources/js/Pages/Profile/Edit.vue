<script setup lang="ts">
import { computed, watch, ref } from 'vue';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import DeleteUserForm from './Partials/DeleteUserForm.vue';
import UpdatePasswordForm from './Partials/UpdatePasswordForm.vue';
import UpdateProfileInformationForm from './Partials/UpdateProfileInformationForm.vue';
import MobileShell from '@/Layouts/MobileShell.vue';
import ChangePasswordModal from '@/Components/ChangePasswordModal.vue';
import { Head, Link, useForm, usePage } from '@inertiajs/vue3';
import { useMediaQuery } from '@/composables/useMediaQuery';

defineProps<{
    mustVerifyEmail?: boolean;
    status?: string;
}>();

const isMobile = useMediaQuery('(max-width: 767px)');

const page = usePage();
const userName = computed(() => page.props.auth?.user?.name ?? 'Gabriel Felix');
const userEmail = computed(() => page.props.auth?.user?.email ?? 'gab.feelix@gmail.com');

const initials = computed(() => {
    const parts = String(userName.value).trim().split(/\s+/).filter(Boolean);
    const first = parts[0]?.[0] ?? 'G';
    const last = parts.length > 1 ? parts[parts.length - 1]?.[0] : 'F';
    return `${first}${last}`.toUpperCase();
});

const form = useForm({
    name: userName.value,
    email: userEmail.value,
    phone: '',
});

watch(
    () => [userName.value, userEmail.value],
    () => {
        form.name = userName.value;
        form.email = userEmail.value;
    },
);

const passwordOpen = ref(false);

const submit = () => {
    form.patch(route('profile.update'), {
        preserveScroll: true,
    });
};
</script>

<template>
    <Head title="Profile" />

    <MobileShell v-if="isMobile" :show-nav="false">
        <header class="relative flex items-center justify-center pt-2">
            <Link
                :href="route('settings')"
                class="absolute left-0 flex h-10 w-10 items-center justify-center rounded-2xl bg-white text-slate-600 shadow-sm ring-1 ring-slate-200/60"
                aria-label="Voltar"
            >
                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M15 18l-6-6 6-6" />
                </svg>
            </Link>
            <div class="text-xl font-semibold tracking-tight text-slate-900">Editar perfil</div>
        </header>

        <div class="mt-8 flex justify-center">
            <div class="relative">
                <div class="flex h-24 w-24 items-center justify-center rounded-full bg-slate-200 text-xl font-bold text-slate-700 shadow-sm ring-4 ring-white">
                    {{ initials }}
                </div>
                <button
                    type="button"
                    class="absolute bottom-1 right-1 flex h-10 w-10 items-center justify-center rounded-full bg-[#14B8A6] text-white shadow-lg shadow-black/10"
                    aria-label="Alterar foto"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M4 7h4l2-2h4l2 2h4v12H4V7Z" />
                        <circle cx="12" cy="13" r="3" />
                    </svg>
                </button>
            </div>
        </div>

        <form class="mt-8 space-y-5 pb-[calc(6rem+env(safe-area-inset-bottom))]" @submit.prevent="submit">
            <div>
                <div class="mb-2 text-sm font-semibold text-slate-700">Nome completo</div>
                <input
                    v-model="form.name"
                    type="text"
                    class="h-12 w-full rounded-2xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-700 focus:border-[#14B8A6] focus:outline-none focus:ring-0"
                    aria-label="Nome completo"
                />
                <div v-if="form.errors.name" class="mt-1 text-xs font-semibold text-red-500">{{ form.errors.name }}</div>
            </div>

            <div>
                <div class="mb-2 text-sm font-semibold text-slate-700">Email</div>
                <input
                    v-model="form.email"
                    type="email"
                    disabled
                    class="h-12 w-full cursor-not-allowed rounded-2xl border border-slate-200 bg-slate-100 px-4 text-sm font-semibold text-slate-500"
                    aria-label="Email"
                />
                <div class="mt-2 flex items-center gap-2 text-xs font-semibold text-slate-400">
                    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <rect x="6" y="11" width="12" height="10" rx="2" />
                        <path d="M8 11V8a4 4 0 1 1 8 0v3" />
                    </svg>
                    Não pode ser alterado
                </div>
            </div>

            <div>
                <div class="mb-2 text-sm font-semibold text-slate-700">Telefone (opcional)</div>
                <input
                    v-model="form.phone"
                    type="tel"
                    placeholder="(00) 00000-0000"
                    class="h-12 w-full rounded-2xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-700 placeholder:text-slate-300 focus:border-[#14B8A6] focus:outline-none focus:ring-0"
                    aria-label="Telefone"
                />
            </div>

            <div class="pt-2">
                <div class="border-t border-slate-200 pt-6">
                    <div class="text-base font-semibold text-slate-900">Segurança</div>
                    <button type="button" class="mt-3 inline-flex items-center gap-2 text-sm font-semibold text-[#14B8A6]" @click="passwordOpen = true">
                        Trocar senha
                        <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 18l6-6-6-6" />
                        </svg>
                    </button>
                </div>
            </div>
        </form>

        <div class="fixed inset-x-0 bottom-0 bg-white px-5 pb-[calc(1rem+env(safe-area-inset-bottom))] pt-3 shadow-[0_-18px_40px_-32px_rgba(15,23,42,0.45)]">
            <div class="mx-auto w-full max-w-md">
                <button
                    type="button"
                    class="h-[52px] w-full rounded-2xl bg-[#14B8A6] text-base font-bold text-white shadow-[0_2px_8px_rgba(20,184,166,0.25)] disabled:opacity-60"
                    :disabled="form.processing"
                    @click="submit"
                >
                    Salvar alterações
                </button>
            </div>
        </div>

        <ChangePasswordModal :open="passwordOpen" @close="passwordOpen = false" />
    </MobileShell>

    <AuthenticatedLayout v-else>
        <template #header>
            <h2
                class="text-xl font-semibold leading-tight text-gray-800"
            >
                Profile
            </h2>
        </template>

        <div class="py-12">
            <div class="mx-auto max-w-7xl space-y-6 sm:px-6 lg:px-8">
                <div
                    class="bg-white p-4 shadow sm:rounded-lg sm:p-8"
                >
                    <UpdateProfileInformationForm
                        :must-verify-email="mustVerifyEmail"
                        :status="status"
                        class="max-w-xl"
                    />
                </div>

                <div
                    class="bg-white p-4 shadow sm:rounded-lg sm:p-8"
                >
                    <UpdatePasswordForm class="max-w-xl" />
                </div>

                <div
                    class="bg-white p-4 shadow sm:rounded-lg sm:p-8"
                >
                    <DeleteUserForm class="max-w-xl" />
                </div>
            </div>
        </div>
    </AuthenticatedLayout>
</template>
