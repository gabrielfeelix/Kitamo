<script setup lang="ts">
import { ref } from 'vue';
import { Head, Link } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopSettingsShell from '@/Layouts/DesktopSettingsShell.vue';
import ToggleSwitch from '@/Components/ToggleSwitch.vue';
import ChangePasswordModal from '@/Components/ChangePasswordModal.vue';
import { useIsMobile } from '@/composables/useIsMobile';

const isMobile = useIsMobile();

const biometric = ref(true);
const passwordOpen = ref(false);
</script>

<template>
    <Head title="Segurança e Privacidade" />

    <MobileShell v-if="isMobile" :show-nav="false">
        <header class="flex items-center gap-3 pt-2">
            <Link
                :href="route('settings')"
                class="flex h-10 w-10 items-center justify-center rounded-2xl bg-white text-slate-600 shadow-sm ring-1 ring-slate-200/60"
                aria-label="Voltar"
            >
                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M15 18l-6-6 6-6" />
                </svg>
            </Link>
            <div class="text-xl font-semibold tracking-tight text-slate-900">Segurança e Privacidade</div>
        </header>

        <div class="mt-8 space-y-6">
            <div>
                <div class="text-base font-semibold text-slate-900">Acesso</div>
                <div class="mt-3 overflow-hidden rounded-3xl bg-white shadow-sm ring-1 ring-slate-200/60">
                    <button type="button" class="flex w-full items-center justify-between gap-4 px-5 py-4 text-left" @click="passwordOpen = true">
                        <div class="flex items-center gap-4">
                            <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-100 text-slate-500">
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M12 7a4 4 0 0 1 4 4" />
                                    <path d="M8 11V9a4 4 0 1 1 8 0v2" />
                                    <rect x="6" y="11" width="12" height="10" rx="2" />
                                </svg>
                            </span>
                            <div class="text-sm font-semibold text-slate-900">Trocar senha</div>
                        </div>
                        <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 18l6-6-6-6" />
                        </svg>
                    </button>
                    <div class="border-t border-slate-100">
                        <div class="flex items-center justify-between gap-4 px-5 py-4">
                            <div class="flex items-center gap-4">
                                <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-100 text-slate-500">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M12 11a3 3 0 1 0-3-3" />
                                        <path d="M12 14v7" />
                                        <path d="M5 12c0-4 3-7 7-7s7 3 7 7" />
                                    </svg>
                                </span>
                                <div>
                                    <div class="text-sm font-semibold text-slate-900">Usar biometria</div>
                                    <div class="mt-1 text-xs font-semibold text-slate-400">Impressão digital ou Face ID</div>
                                </div>
                            </div>
                            <ToggleSwitch v-model="biometric" />
                        </div>
                    </div>
                </div>
            </div>

            <div>
                <div class="text-base font-semibold text-slate-900">Seus dados</div>
                <div class="mt-3 overflow-hidden rounded-3xl bg-white shadow-sm ring-1 ring-slate-200/60">
                    <Link :href="route('settings.backup')" class="flex w-full items-center justify-between gap-4 px-5 py-4 text-left">
                        <div class="flex items-center gap-4">
                            <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-100 text-slate-500">
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M20 17.5A4.5 4.5 0 0 0 18 9h-1.3A7 7 0 0 0 3 11.5" />
                                    <path d="M7 17a4 4 0 1 0 1.2 7.8" />
                                    <path d="M12 12v7" />
                                    <path d="M8 15l4-3 4 3" />
                                </svg>
                            </span>
                            <div>
                                <div class="text-sm font-semibold text-slate-900">Backup de dados</div>
                                <div class="mt-1 text-xs font-semibold text-slate-400">Status: Sincronizado</div>
                            </div>
                        </div>
                        <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 18l6-6-6-6" />
                        </svg>
                    </Link>
                    <div class="border-t border-slate-100">
                    <button type="button" class="flex w-full items-center justify-between gap-4 px-5 py-4 text-left">
                        <div class="flex items-center gap-4">
                            <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-100 text-slate-500">
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M12 3v12" />
                                    <path d="M8 11l4 4 4-4" />
                                    <path d="M4 21h16" />
                                </svg>
                            </span>
                            <div>
                                <div class="text-sm font-semibold text-slate-900">Exportar dados</div>
                                <div class="mt-1 text-xs font-semibold text-slate-400">Backup em formato JSON</div>
                            </div>
                        </div>
                        <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 18l6-6-6-6" />
                        </svg>
                    </button>
                    </div>
                    <div class="border-t border-slate-100">
                        <button type="button" class="flex w-full items-center justify-between gap-4 px-5 py-4 text-left">
                            <div class="flex items-center gap-4">
                                <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-100 text-slate-500">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M12 21V9" />
                                        <path d="M16 13l-4-4-4 4" />
                                        <path d="M4 3h16" />
                                    </svg>
                                </span>
                                <div>
                                    <div class="text-sm font-semibold text-slate-900">Importar dados</div>
                                    <div class="mt-1 text-xs font-semibold text-slate-400">Restaurar de um backup</div>
                                </div>
                            </div>
                            <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M9 18l6-6-6-6" />
                            </svg>
                        </button>
                    </div>
                </div>
            </div>

            <div>
                <div class="text-base font-semibold text-slate-900">Privacidade</div>
                <div class="mt-3 overflow-hidden rounded-3xl bg-white shadow-sm ring-1 ring-slate-200/60">
                    <button type="button" class="flex w-full items-center justify-between gap-4 px-5 py-4 text-left">
                        <div class="flex items-center gap-4">
                            <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-100 text-slate-500">
                                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M12 22s8-4 8-10V6l-8-4-8 4v6c0 6 8 10 8 10Z" />
                                </svg>
                            </span>
                            <div class="text-sm font-semibold text-slate-900">Política de privacidade</div>
                        </div>
                        <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 18l6-6-6-6" />
                        </svg>
                    </button>
                    <div class="border-t border-slate-100">
                        <button type="button" class="flex w-full items-center justify-between gap-4 px-5 py-4 text-left">
                            <div class="flex items-center gap-4">
                                <span class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-100 text-slate-500">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M7 4h10v16H7z" />
                                        <path d="M9 8h6" />
                                        <path d="M9 12h6" />
                                    </svg>
                                </span>
                                <div class="text-sm font-semibold text-slate-900">Termos de uso</div>
                            </div>
                            <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M9 18l6-6-6-6" />
                            </svg>
                        </button>
                    </div>
                </div>
            </div>

            <div>
                <div class="text-base font-semibold text-red-500">Zona de perigo</div>
                <div class="mt-3 overflow-hidden rounded-3xl bg-white shadow-sm ring-1 ring-slate-200/60">
                    <div class="px-5 py-5">
                        <button type="button" class="h-12 w-full rounded-2xl border border-red-200 bg-white text-sm font-semibold text-red-500">
                            Excluir minha conta
                        </button>
                        <div class="mt-3 text-center text-xs font-semibold text-slate-400">Esta ação não pode ser desfeita</div>
                    </div>
                </div>
            </div>
        </div>

        <ChangePasswordModal :open="passwordOpen" @close="passwordOpen = false" />
    </MobileShell>

    <DesktopSettingsShell v-else>
        <div class="space-y-8 pb-10">
            <div class="rounded-3xl bg-white px-10 py-9 shadow-sm ring-1 ring-slate-200/60">
                <div class="space-y-10">
                    <div>
                        <div class="text-[11px] font-bold uppercase tracking-wide text-slate-300">Acesso</div>
                        <div class="mt-5 overflow-hidden rounded-2xl bg-slate-50 ring-1 ring-slate-200/60">
                            <button type="button" class="flex w-full items-center justify-between gap-6 px-6 py-5 text-left" @click="passwordOpen = true">
                                <div class="flex items-center gap-4">
                                    <span class="flex h-11 w-11 items-center justify-center rounded-2xl bg-white text-slate-500 ring-1 ring-slate-200/60">
                                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M8 11V9a4 4 0 1 1 8 0v2" />
                                            <rect x="6" y="11" width="12" height="10" rx="2" />
                                        </svg>
                                    </span>
                                    <div class="text-sm font-semibold text-slate-900">Trocar senha</div>
                                </div>
                                <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M9 18l6-6-6-6" />
                                </svg>
                            </button>
                            <div class="border-t border-slate-200/70 px-6 py-5">
                                <div class="flex items-center justify-between gap-6">
                                    <div class="flex items-center gap-4">
                                        <span class="flex h-11 w-11 items-center justify-center rounded-2xl bg-white text-slate-500 ring-1 ring-slate-200/60">
                                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <path d="M12 11a3 3 0 1 0-3-3" />
                                                <path d="M12 14v7" />
                                                <path d="M5 12c0-4 3-7 7-7s7 3 7 7" />
                                            </svg>
                                        </span>
                                        <div>
                                            <div class="text-sm font-semibold text-slate-900">Usar biometria</div>
                                            <div class="mt-1 text-xs font-semibold text-slate-400">Impressão digital ou Face ID</div>
                                        </div>
                                    </div>
                                    <ToggleSwitch v-model="biometric" />
                                </div>
                            </div>
                        </div>
                    </div>

                    <div>
                        <div class="text-[11px] font-bold uppercase tracking-wide text-slate-300">Seus dados</div>
                        <div class="mt-5 overflow-hidden rounded-2xl bg-slate-50 ring-1 ring-slate-200/60">
                            <Link :href="route('settings.backup')" class="flex w-full items-center justify-between gap-6 px-6 py-5 text-left">
                                <div class="flex items-center gap-4">
                                    <span class="flex h-11 w-11 items-center justify-center rounded-2xl bg-white text-slate-500 ring-1 ring-slate-200/60">
                                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M20 17.5A4.5 4.5 0 0 0 18 9h-1.3A7 7 0 0 0 3 11.5" />
                                            <path d="M12 12v7" />
                                            <path d="M8 15l4-3 4 3" />
                                        </svg>
                                    </span>
                                    <div>
                                        <div class="text-sm font-semibold text-slate-900">Backup de dados</div>
                                        <div class="mt-1 text-xs font-semibold text-slate-400">Status: Sincronizado</div>
                                    </div>
                                </div>
                                <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M9 18l6-6-6-6" />
                                </svg>
                            </Link>
                        </div>
                    </div>

                    <div>
                        <div class="text-[11px] font-bold uppercase tracking-wide text-red-400">Zona de perigo</div>
                        <div class="mt-5 rounded-2xl bg-slate-50 px-6 py-6 ring-1 ring-slate-200/60">
                            <button type="button" class="h-12 w-full rounded-2xl border border-red-200 bg-white text-sm font-semibold text-red-500">Excluir minha conta</button>
                            <div class="mt-3 text-center text-xs font-semibold text-slate-400">Esta ação não pode ser desfeita</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <ChangePasswordModal :open="passwordOpen" @close="passwordOpen = false" />
    </DesktopSettingsShell>
</template>
