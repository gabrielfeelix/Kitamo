<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import { Link, useForm, usePage } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopSettingsShell from '@/Layouts/DesktopSettingsShell.vue';
import { useIsMobile } from '@/composables/useIsMobile';

const isMobile = useIsMobile();
const page = usePage();
const userName = computed(() => page.props.auth?.user?.name ?? 'Gabriel Felix');
const userEmail = computed(() => page.props.auth?.user?.email ?? 'gab.feelix@gmail.com');
const userPhone = computed(() => page.props.auth?.user?.phone ?? '');

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
    <MobileShell v-if="isMobile" :show-nav="false">
        <div class="fixed inset-0 flex flex-col bg-[#14B8A6]">
            <!-- Header com perfil -->
            <div class="px-5 pb-6 pt-[calc(0.5rem+env(safe-area-inset-top))]">
                <Link :href="route('dashboard')" class="mb-4 flex h-9 w-9 items-center justify-center rounded-xl bg-white/20 text-white">
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M15 18l-6-6 6-6" />
                    </svg>
                </Link>

                <div class="text-center">
                    <div class="mx-auto flex h-20 w-20 items-center justify-center rounded-full bg-white/20 text-xl font-bold text-white">
                        {{ initials }}
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
                <div class="pb-[calc(12rem+env(safe-area-inset-bottom))] text-center text-[11px] font-semibold text-slate-300">
                    v1.0.2 (Build 8402)
                </div>
            </div>

            <!-- Navbar inferior -->
            <div class="fixed inset-x-0 bottom-0 z-40 border-t border-slate-200/70 bg-white">
                <nav class="mx-auto flex w-full max-w-md items-center justify-between px-6 pb-[env(safe-area-inset-bottom)] pt-2 md:max-w-2xl md:px-10">
                    <Link :href="route('dashboard')" class="flex flex-1 flex-col items-center justify-center gap-1 py-2 text-slate-400">
                        <span class="flex h-11 w-11 items-center justify-center">
                            <svg class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M3 10.5L12 3l9 7.5" />
                                <path d="M5 10v10h14V10" />
                            </svg>
                        </span>
                        <span class="text-[10px] font-semibold leading-none">Início</span>
                    </Link>

                    <Link :href="route('accounts.index')" class="flex flex-1 flex-col items-center justify-center gap-1 py-2 text-slate-400">
                        <span class="flex h-11 w-11 items-center justify-center">
                            <svg class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="5" width="18" height="14" rx="3" />
                                <path d="M3 10h18" />
                            </svg>
                        </span>
                        <span class="text-[10px] font-semibold leading-none">Lançamentos</span>
                    </Link>

                    <button type="button" class="mx-2 -mt-7 flex h-14 w-14 items-center justify-center rounded-full bg-emerald-500 text-white shadow-xl shadow-emerald-500/30 ring-8 ring-white" aria-label="Nova movimentação">
                        <svg class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M12 5v14" />
                            <path d="M5 12h14" />
                        </svg>
                    </button>

                    <Link :href="route('analysis')" class="flex flex-1 flex-col items-center justify-center gap-1 py-2 text-slate-400">
                        <span class="flex h-11 w-11 items-center justify-center">
                            <svg class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M12 3v9h9" />
                                <path d="M21 12a9 9 0 1 1-9-9" />
                            </svg>
                        </span>
                        <span class="text-[10px] font-semibold leading-none">Análise</span>
                    </Link>

                    <Link :href="route('settings')" class="flex flex-1 flex-col items-center justify-center gap-1 py-2 text-emerald-600">
                        <span class="flex h-11 w-11 items-center justify-center">
                            <svg class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M4 6h16" />
                                <path d="M4 12h16" />
                                <path d="M4 18h16" />
                            </svg>
                        </span>
                        <span class="text-[10px] font-semibold leading-none">Mais</span>
                    </Link>
                </nav>
            </div>
        </div>
    </MobileShell>

    <div v-else-if="false">
        <div class="rounded-[28px] border border-white/70 bg-white p-8 shadow-[0_20px_50px_-40px_rgba(15,23,42,0.4)]">
            <div class="text-sm font-semibold text-slate-900">Configurações (desktop/tablet)</div>
            <div class="mt-2 text-sm text-slate-500">Vamos adaptar essa tela depois da versão mobile.</div>
        </div>
    </div>

    <DesktopSettingsShell v-else>
        <div class="overflow-hidden rounded-3xl bg-white shadow-sm ring-1 ring-slate-200/60">
            <div class="px-10 py-9">
                <div class="flex items-center gap-6">
                    <div class="h-20 w-20 overflow-hidden rounded-2xl bg-slate-200 ring-4 ring-white shadow-sm">
                        <div class="flex h-full w-full items-center justify-center bg-slate-300 text-xl font-bold text-slate-700">
                            {{ initials }}
                        </div>
                    </div>
                    <div class="min-w-0">
                        <div class="truncate text-2xl font-semibold tracking-tight text-slate-900">{{ userName }}</div>
                        <div class="mt-1 text-sm font-semibold text-slate-400">Informações básicas de acesso à conta.</div>
                    </div>
                </div>

                <form class="mt-10 space-y-8" @submit.prevent="submitProfile">
                    <div class="grid grid-cols-2 gap-8">
                        <div>
                            <div class="text-[11px] font-bold uppercase tracking-wide text-slate-300">Nome completo</div>
                            <input
                                v-model="form.name"
                                type="text"
                                class="mt-3 h-12 w-full rounded-2xl bg-slate-50 px-4 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60 focus:outline-none focus:ring-2 focus:ring-emerald-200"
                            />
                            <div v-if="form.errors.name" class="mt-2 text-xs font-semibold text-red-500">{{ form.errors.name }}</div>
                        </div>

                        <div>
                            <div class="text-[11px] font-bold uppercase tracking-wide text-slate-300">Telefone</div>
                            <input
                                v-model="form.phone"
                                type="tel"
                                class="mt-3 h-12 w-full rounded-2xl bg-slate-50 px-4 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60 focus:outline-none focus:ring-2 focus:ring-emerald-200"
                            />
                        </div>
                    </div>

                    <div>
                        <div class="text-[11px] font-bold uppercase tracking-wide text-slate-300">E-mail de acesso</div>
                        <div class="mt-3 flex items-center gap-3 rounded-2xl bg-slate-50 px-4 ring-1 ring-slate-200/60">
                            <input
                                v-model="form.email"
                                type="email"
                                disabled
                                class="h-12 w-full cursor-not-allowed bg-transparent text-sm font-semibold text-slate-400 focus:outline-none"
                            />
                            <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="6" y="11" width="12" height="10" rx="2" />
                                <path d="M8 11V8a4 4 0 1 1 8 0v3" />
                            </svg>
                        </div>
                        <div class="mt-2 text-xs font-semibold text-slate-300">O e-mail não pode ser alterado para garantir a segurança da conta.</div>
                    </div>

                    <div class="pt-2">
                        <Link :href="route('password.request')" class="inline-flex items-center gap-2 text-sm font-semibold text-[#14B8A6]">
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M10 14 8 16a4 4 0 0 1-6-6l2-2a4 4 0 0 1 6 6Z" />
                                <path d="M14 10l2-2a4 4 0 0 1 6 6l-2 2a4 4 0 0 1-6-6Z" />
                                <path d="M8 16l8-8" />
                            </svg>
                            Esqueceu sua senha?
                        </Link>
                    </div>
                </form>
            </div>

            <div class="flex items-center justify-between border-t border-slate-100 px-10 py-7">
                <button type="button" class="text-sm font-semibold text-slate-400 hover:text-slate-500" @click="resetForm">Cancelar</button>
                <button
                    type="button"
                    class="inline-flex h-12 items-center justify-center rounded-2xl bg-[#14B8A6] px-8 text-sm font-semibold text-white shadow-lg shadow-emerald-500/20 disabled:opacity-60"
                    :disabled="form.processing"
                    @click="submitProfile"
                >
                    Guardar Alterações
                </button>
            </div>
        </div>

    </DesktopSettingsShell>
</template>
