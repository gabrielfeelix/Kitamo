<script setup lang="ts">
import { computed, watch, ref } from 'vue';
import DeleteUserForm from './Partials/DeleteUserForm.vue';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import ChangePasswordModal from '@/Components/ChangePasswordModal.vue';
import { Head, Link, router, useForm, usePage } from '@inertiajs/vue3';
import { useIsMobile } from '@/composables/useIsMobile';

defineProps<{
    mustVerifyEmail?: boolean;
    status?: string;
}>();

const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() =>
    isMobile.value
        ? { showNav: false }
        : {
              title: 'Minha Conta',
              subtitle: 'Gerenciar perfil e segurança',
              showSearch: false,
              showNewAction: false,
          },
);

const page = usePage();
const isGoogleAuth = computed(() => {
    const user = page.props.auth?.user as any;
    return user?.is_google_auth === true || user?.auth_provider === 'google';
});
const userName = computed(() => page.props.auth?.user?.name ?? '');
const userEmail = computed(() => page.props.auth?.user?.email ?? '');
const userPhone = computed(() => page.props.auth?.user?.phone ?? '');
const avatarUrl = computed(() => (page.props.auth?.user as any)?.avatar_url ?? (page.props.auth?.user as any)?.profile_photo_url ?? null);

const initials = computed(() => {
    const parts = String(userName.value).trim().split(/\s+/).filter(Boolean);
    const first = parts[0]?.[0] ?? 'G';
    const last = parts.length > 1 ? parts[parts.length - 1]?.[0] : 'F';
    return `${first}${last}`.toUpperCase();
});

const form = useForm({
    name: userName.value,
    email: userEmail.value,
    phone: userPhone.value,
    avatar: null as File | null,
});

watch(
    () => [userName.value, userEmail.value, userPhone.value],
    () => {
        form.name = userName.value;
        form.email = userEmail.value;
        form.phone = userPhone.value;
    },
);

const passwordOpen = ref(false);

const submitProfile = () => {
    form.patch(route('profile.update'), {
        preserveScroll: true,
        onSuccess: () => {
            if (isMobile.value) {
                 router.visit(route('settings'));
            }
        },
    });
};

const submitAvatar = () => {
    form.transform((data) => ({ ...data, _method: 'patch' })).post(route('profile.update'), {
        forceFormData: true,
        preserveScroll: true,
        onSuccess: () => {
            form.avatar = null;
        },
    });
};

const fileInput = ref<HTMLInputElement | null>(null);
const openFilePicker = () => fileInput.value?.click();

const onAvatarChange = (event: Event) => {
    const file = (event.target as HTMLInputElement).files?.[0] ?? null;
    if (!file) return;
    form.avatar = file;
    submitAvatar();
};
</script>

<template>
    <Head title="Perfil" />

    <component :is="Shell" v-bind="shellProps">
        <!-- Mobile Specific Header -->
        <header v-if="isMobile" class="relative flex items-center justify-center pt-2">
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

        <!-- Main Content -->
        <div :class="[isMobile ? 'pb-[calc(6rem+env(safe-area-inset-bottom))]' : 'mt-8 grid grid-cols-1 gap-8 items-start lg:grid-cols-12']">
            
            <!-- Profile Card (Left on Desktop) -->
            <div :class="[isMobile ? 'contents' : 'lg:col-span-8']">
                <div class="relative mt-8 rounded-3xl bg-white p-6 shadow-sm ring-1 ring-slate-200/60 md:mt-0">
                    
                    <!-- Avatar Section -->
                    <div class="flex flex-col items-center justify-center border-b border-slate-100 pb-8">
                        <div class="relative">
                            <div class="flex h-24 w-24 items-center justify-center overflow-hidden rounded-full bg-slate-200 text-xl font-bold text-slate-700 shadow-sm ring-4 ring-slate-50">
                                <img v-if="avatarUrl" :src="avatarUrl" alt="Foto do perfil" class="h-full w-full object-cover" />
                                <span v-else>{{ initials }}</span>
                            </div>
                            <button
                                type="button"
                                :disabled="isGoogleAuth"
                                class="absolute bottom-1 right-1 flex h-10 w-10 items-center justify-center rounded-full text-white shadow-lg transition hover:scale-105 active:scale-95"
                                :class="isGoogleAuth ? 'bg-slate-400 cursor-not-allowed' : 'bg-[#14B8A6] hover:bg-[#0D9488]'"
                                :aria-label="isGoogleAuth ? 'Foto gerenciada pelo Google' : 'Alterar foto'"
                                @click="openFilePicker"
                            >
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M4 7h4l2-2h4l2 2h4v12H4V7Z" />
                                    <circle cx="12" cy="13" r="3" />
                                </svg>
                            </button>
                            <input ref="fileInput" class="hidden" type="file" accept="image/*" @change="onAvatarChange" />
                        </div>
                        <div v-if="!isMobile" class="mt-4 text-center">
                            <h2 class="text-lg font-bold text-slate-900">{{ userName }}</h2>
                            <p class="text-sm font-medium text-slate-500">{{ userEmail }}</p>
                        </div>
                    </div>

                    <form class="mt-8 space-y-6" @submit.prevent="submitProfile">
                        <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
                            <div class="col-span-1 md:col-span-2">
                                <label class="mb-2 block text-sm font-semibold text-slate-700">Nome completo</label>
                                <input
                                    v-model="form.name"
                                    type="text"
                                    :disabled="isGoogleAuth"
                                    class="h-12 w-full rounded-2xl border border-slate-200 px-4 text-sm font-semibold transition focus:border-[#14B8A6] focus:outline-none focus:ring-4 focus:ring-[#14B8A6]/10"
                                    :class="isGoogleAuth ? 'cursor-not-allowed bg-slate-50 text-slate-500' : 'bg-white text-slate-900'"
                                />
                                <div v-if="isGoogleAuth" class="mt-2 flex items-center gap-2 text-xs font-semibold text-slate-400">
                                    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <circle cx="12" cy="12" r="10" />
                                        <path d="M12 16v-4" />
                                        <path d="M12 8h.01" />
                                    </svg>
                                    Gerenciado pelo Google
                                </div>
                                <div v-else-if="form.errors.name" class="mt-1 text-xs font-semibold text-red-500">{{ form.errors.name }}</div>
                            </div>

                            <div class="col-span-1">
                                <label class="mb-2 block text-sm font-semibold text-slate-700">E-mail</label>
                                <input
                                    v-model="form.email"
                                    type="email"
                                    disabled
                                    class="h-12 w-full cursor-not-allowed rounded-2xl border border-slate-200 bg-slate-50 px-4 text-sm font-semibold text-slate-500"
                                />
                                <div class="mt-2 flex items-center gap-2 text-xs font-semibold text-slate-400">
                                    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <rect x="6" y="11" width="12" height="10" rx="2" />
                                        <path d="M8 11V8a4 4 0 1 1 8 0v3" />
                                    </svg>
                                    Não pode ser alterado
                                </div>
                            </div>

                            <div class="col-span-1">
                                <label class="mb-2 block text-sm font-semibold text-slate-700">Telefone <span class="font-normal text-slate-400">(opcional)</span></label>
                                <input
                                    v-model="form.phone"
                                    type="tel"
                                    placeholder="(00) 00000-0000"
                                    class="h-12 w-full rounded-2xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-900 placeholder:text-slate-300 transition focus:border-[#14B8A6] focus:outline-none focus:ring-4 focus:ring-[#14B8A6]/10"
                                />
                            </div>
                        </div>

                        <!-- Mobile Save Button (Fixed) -->
                        <div v-if="isMobile">
                            <div class="fixed inset-x-0 bottom-0 z-10 bg-white px-5 pb-[calc(1rem+env(safe-area-inset-bottom))] pt-3 shadow-[0_-4px_20px_-4px_rgba(0,0,0,0.1)]">
                                <div class="mx-auto w-full max-w-md">
                                    <button
                                        type="submit"
                                        class="flex h-12 w-full items-center justify-center rounded-2xl bg-[#14B8A6] text-base font-bold text-white shadow-lg shadow-emerald-500/20 active:scale-[0.98] disabled:opacity-60"
                                        :disabled="form.processing"
                                    >
                                        <span v-if="form.processing">Salvando...</span>
                                        <span v-else>Salvar alterações</span>
                                    </button>
                                </div>
                            </div>
                        </div>

                        <!-- Desktop Save Button (Inline) -->
                        <div v-else class="flex justify-end pt-2">
                             <button
                                type="submit"
                                class="flex h-11 items-center justify-center rounded-xl bg-[#14B8A6] px-8 text-sm font-bold text-white shadow-lg shadow-emerald-500/20 transition hover:bg-[#0D9488] active:scale-[0.98] disabled:opacity-60"
                                :disabled="form.processing"
                            >
                                <span v-if="form.processing">Salvando...</span>
                                <span v-else>Salvar alterações</span>
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Right Column (Desktop) -->
            <div :class="[isMobile ? 'mt-8 px-5' : 'lg:col-span-4 space-y-6']">
                
                <!-- Security Card -->
                <div class="rounded-3xl bg-white p-6 shadow-sm ring-1 ring-slate-200/60">
                    <h3 class="flex items-center gap-2 text-lg font-bold text-slate-900">
                        <svg class="h-5 w-5 text-emerald-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
                            <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                        </svg>
                        Segurança
                    </h3>
                    <p class="mt-2 text-sm text-slate-500">Mantenha sua conta segura alterando sua senha periodicamente.</p>
                     
                    <button 
                        type="button" 
                        class="mt-6 flex w-full items-center justify-between rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm font-semibold text-slate-700 transition hover:bg-white hover:shadow-sm"
                        @click="passwordOpen = true"
                    >
                        <span>Alterar senha</span>
                        <svg class="h-4 w-4 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 18l6-6-6-6" />
                        </svg>
                    </button>
                </div>

                <!-- Delete Account (Simplificado para Mobile/Desktop) -->
                <!-- Note: The actual DeleteUserForm logic is quite complex with modals. We can wrap it in a cleaner UI container -->
                <div class="rounded-3xl bg-red-50 p-6 ring-1 ring-red-100">
                     <h3 class="flex items-center gap-2 text-lg font-bold text-red-700">
                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                             <circle cx="12" cy="12" r="10" />
                             <line x1="12" y1="8" x2="12" y2="12" />
                             <line x1="12" y1="16" x2="12" y2="16" />
                        </svg>
                        Zona de Perigo
                    </h3>
                    <div class="mt-4">
                        <DeleteUserForm />
                    </div>
                </div>
            </div>
        </div>

        <ChangePasswordModal :open="passwordOpen" @close="passwordOpen = false" />
    </component>
</template>
