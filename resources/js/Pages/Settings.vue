<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import { Link, useForm, usePage } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import { useIsMobile } from '@/composables/useIsMobile';

const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() =>
    isMobile.value ? { showNav: false } : { title: 'Configurações', showSearch: false, showNewAction: false },
);
const page = usePage();
const userName = computed(() => page.props.auth?.user?.name ?? 'Gabriel Felix');
const userEmail = computed(() => page.props.auth?.user?.email ?? 'gab.feelix@gmail.com');
const userPhone = computed(() => page.props.auth?.user?.phone ?? '');
const avatarUrl = computed(() => (page.props.auth?.user as any)?.avatar_url ?? (page.props.auth?.user as any)?.profile_photo_url ?? null);

const form = useForm({
    name: userName.value,
    email: userEmail.value,
    phone: userPhone.value,
});

watch(
    () => [userName.value, userEmail.value, userPhone.value],
    () => {
        form.name = userName.value;
        form.email = userEmail.value;
        form.phone = userPhone.value;
    },
);

const resetForm = () => {
    form.name = userName.value;
    form.email = userEmail.value;
    form.phone = userPhone.value;
    form.clearErrors();
};

const submitProfile = () => {
    form.patch(route('profile.update'), {
        preserveScroll: true,
    });
};

const initials = computed(() => {
    const parts = String(userName.value).trim().split(/\s+/).filter(Boolean);
    const first = parts[0]?.[0] ?? 'G';
    const last = parts.length > 1 ? parts[parts.length - 1]?.[0] : 'F';
    return `${first}${last}`.toUpperCase();
});
</script>


<template>
    <component :is="Shell" v-bind="shellProps">
        <div class="fixed inset-0 flex flex-col bg-[#14B8A6]">
            <!-- Header com perfil -->
            <div class="px-5 pb-6 pt-[calc(0.5rem+env(safe-area-inset-top))]">
                <Link :href="route('dashboard')" class="mb-4 flex h-9 w-9 items-center justify-center rounded-xl bg-white/20 text-white">
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M15 18l-6-6 6-6" />
                    </svg>
                </Link>

                <div class="text-center">
                    <div class="mx-auto flex h-20 w-20 items-center justify-center overflow-hidden rounded-full bg-white/20 text-xl font-bold text-white">
                        <img v-if="avatarUrl" :src="avatarUrl" alt="Foto do perfil" class="h-full w-full object-cover" />
                        <span v-else>{{ initials }}</span>
                    </div>
                    <div class="mt-3 text-lg font-bold text-white">{{ userName.split(' ')[0] }}</div>
                    <div class="mt-0.5 text-sm font-medium text-white/80">@{{ userEmail.split('@')[0] }}</div>
                    <div class="mt-2 inline-flex items-center gap-1 rounded-full bg-white/20 px-2.5 py-1 text-[11px] font-bold text-white">
                        <svg class="h-3.5 w-3.5" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M9 12l2 2 4-4m6 2a9 9 0 1 1-18 0 9 9 0 0 1 18 0z" />
                        </svg>
                        Membro PRO
                    </div>
                </div>
            </div>

            <!-- Card branco -->
            <div class="flex-1 rounded-t-[28px] bg-slate-50 px-5 pt-5">
                <Link
                    :href="route('profile.edit')"
                    class="mb-5 flex items-center gap-3 rounded-2xl bg-white px-4 py-3.5 shadow-sm ring-1 ring-slate-200/60"
                >
                    <div class="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-xl bg-teal-50">
                        <svg class="h-5 w-5 text-[#14B8A6]" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
                            <circle cx="12" cy="7" r="4" />
                        </svg>
                    </div>
                    <div class="min-w-0 flex-1">
                        <div class="text-sm font-bold text-slate-900">Meus Dados</div>
                        <div class="text-xs font-medium text-slate-400">Email, telefone e endereço</div>
                    </div>
                    <svg class="h-4 w-4 flex-shrink-0 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M9 18l6-6-6-6" />
                    </svg>
                </Link>

                <!-- Seção CONFIGURAÇÕES -->
                <div class="mb-2.5 text-[11px] font-bold uppercase tracking-wider text-slate-400">Configurações</div>

                <div class="space-y-2.5 pb-6">
                    <Link :href="route('settings.notifications')" class="flex items-center gap-3 rounded-2xl bg-white px-4 py-3.5 shadow-sm ring-1 ring-slate-200/60">
                        <div class="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-xl bg-amber-50">
                            <svg class="h-5 w-5 text-amber-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M15 17h5l-1.4-1.4a2 2 0 0 1-.6-1.4V11a6 6 0 1 0-12 0v3.2c0 .5-.2 1-.6 1.4L4 17h5" />
                                <path d="M9 17a3 3 0 0 0 6 0" />
                            </svg>
                        </div>
                        <div class="min-w-0 flex-1 text-sm font-bold text-slate-900">Notificações</div>
                        <svg class="h-4 w-4 flex-shrink-0 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 18l6-6-6-6" />
                        </svg>
                    </Link>

                    <Link :href="route('settings.security')" class="flex items-center gap-3 rounded-2xl bg-white px-4 py-3.5 shadow-sm ring-1 ring-slate-200/60">
                        <div class="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-xl bg-purple-50">
                            <svg class="h-5 w-5 text-purple-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M12 22s8-4 8-10V6l-8-4-8 4v6c0 6 8 10 8 10Z" />
                            </svg>
                        </div>
                        <div class="min-w-0 flex-1 text-sm font-bold text-slate-900">Segurança e Privacidade</div>
                        <svg class="h-4 w-4 flex-shrink-0 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 18l6-6-6-6" />
                        </svg>
                    </Link>

                    <Link :href="route('settings.support')" class="flex items-center gap-3 rounded-2xl bg-white px-4 py-3.5 shadow-sm ring-1 ring-slate-200/60">
                        <div class="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-xl bg-cyan-50">
                            <svg class="h-5 w-5 text-cyan-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M3 11h3a2 2 0 0 1 2 2v3a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-5a9 9 0 0 1 18 0v5a2 2 0 0 1-2 2h-1a2 2 0 0 1-2-2v-3a2 2 0 0 1 2-2h3" />
                            </svg>
                        </div>
                        <div class="min-w-0 flex-1 text-sm font-bold text-slate-900">Ajuda e Suporte</div>
                        <svg class="h-4 w-4 flex-shrink-0 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 18l6-6-6-6" />
                        </svg>
                    </Link>

                    <Link :href="route('settings.about')" class="flex items-center gap-3 rounded-2xl bg-white px-4 py-3.5 shadow-sm ring-1 ring-slate-200/60">
                        <div class="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-xl bg-slate-100">
                            <svg class="h-5 w-5 text-slate-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <circle cx="12" cy="12" r="9" />
                                <path d="M12 16v-4" />
                                <path d="M12 8h.01" />
                            </svg>
                        </div>
                        <div class="min-w-0 flex-1 text-sm font-bold text-slate-900">Sobre o APP</div>
                        <svg class="h-4 w-4 flex-shrink-0 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 18l6-6-6-6" />
                        </svg>
                    </Link>
                </div>

                <!-- Sair da conta -->
                <div class="pb-5 text-center">
                    <Link
                        :href="route('logout')"
                        method="post"
                        as="button"
                        class="text-sm font-bold text-red-500"
                    >
                        Sair da Conta
                    </Link>
                </div>

                <!-- Versão -->
                <div class="pb-8 text-center text-[11px] font-semibold text-slate-300">
                    v1.0.2 (Build 8402)
                </div>
            </div>
        </div>
    </component>

</template>
