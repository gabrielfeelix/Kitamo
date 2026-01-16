<script setup lang="ts">
import { ref } from 'vue';
import { Head, Link } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import ToggleSwitch from '@/Components/ToggleSwitch.vue';
import DesktopSettingsShell from '@/Layouts/DesktopSettingsShell.vue';
import { useIsMobile } from '@/composables/useIsMobile';

const isMobile = useIsMobile();

const remindDue = ref(true);
const warnNegative = ref(true);
const confirmPaid = ref(false);

const weeklySummary = ref(true);
const warnOutlier = ref(true);

const goalProgress = ref(false);
</script>

<template>
    <Head title="Notificações" />

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
            <div class="text-xl font-semibold tracking-tight text-slate-900">Notificações</div>
        </header>

        <div class="mt-8 space-y-6">
            <div>
                <div class="text-base font-semibold text-slate-900">Contas e pagamentos</div>
                <div class="mt-3 overflow-hidden rounded-3xl bg-white shadow-sm ring-1 ring-slate-200/60">
                    <div class="flex items-center justify-between gap-4 px-5 py-4">
                        <div>
                            <div class="text-sm font-semibold text-slate-900">Lembrar contas a vencer</div>
                            <div class="mt-1 text-xs font-semibold text-slate-400">3 dias antes do vencimento</div>
                        </div>
                        <ToggleSwitch v-model="remindDue" />
                    </div>
                    <div class="border-t border-slate-100">
                        <div class="flex items-center justify-between gap-4 px-5 py-4">
                            <div>
                                <div class="text-sm font-semibold text-slate-900">Avisar quando saldo ficar negativo</div>
                            </div>
                            <ToggleSwitch v-model="warnNegative" />
                        </div>
                    </div>
                    <div class="border-t border-slate-100">
                        <div class="flex items-center justify-between gap-4 px-5 py-4">
                            <div>
                                <div class="text-sm font-semibold text-slate-900">Confirmar quando marcar como pago</div>
                            </div>
                            <ToggleSwitch v-model="confirmPaid" />
                        </div>
                    </div>
                </div>
            </div>

            <div>
                <div class="text-base font-semibold text-slate-900">Relatórios</div>
                <div class="mt-3 overflow-hidden rounded-3xl bg-white shadow-sm ring-1 ring-slate-200/60">
                    <div class="flex items-center justify-between gap-4 px-5 py-4">
                        <div>
                            <div class="text-sm font-semibold text-slate-900">Resumo semanal das finanças</div>
                            <div class="mt-1 text-xs font-semibold text-slate-400">Toda segunda-feira às 9h</div>
                        </div>
                        <ToggleSwitch v-model="weeklySummary" />
                    </div>
                    <div class="border-t border-slate-100">
                        <div class="flex items-center justify-between gap-4 px-5 py-4">
                            <div>
                                <div class="text-sm font-semibold text-slate-900">Avisar sobre gastos fora do padrão</div>
                            </div>
                            <ToggleSwitch v-model="warnOutlier" />
                        </div>
                    </div>
                </div>
            </div>

            <div>
                <div class="text-base font-semibold text-slate-900">Metas</div>
                <div class="mt-3 overflow-hidden rounded-3xl bg-white shadow-sm ring-1 ring-slate-200/60">
                    <div class="flex items-center justify-between gap-4 px-5 py-4">
                        <div>
                            <div class="text-sm font-semibold text-slate-900">Progresso das metas de economia</div>
                        </div>
                        <ToggleSwitch v-model="goalProgress" />
                    </div>
                </div>
            </div>
        </div>
    </MobileShell>

    <DesktopSettingsShell v-else>
        <div class="space-y-8 pb-10">
            <div class="rounded-3xl bg-white px-10 py-9 shadow-sm ring-1 ring-slate-200/60">
                <div class="space-y-10">
                    <div>
                        <div class="text-[11px] font-bold uppercase tracking-wide text-slate-300">Contas e pagamentos</div>
                        <div class="mt-5 space-y-4">
                            <div class="flex items-center justify-between gap-6 rounded-2xl bg-slate-50 px-6 py-5 ring-1 ring-slate-200/60">
                                <div>
                                    <div class="text-sm font-semibold text-slate-900">Lembrar contas a vencer</div>
                                    <div class="mt-1 text-xs font-semibold text-slate-400">3 dias antes do vencimento</div>
                                </div>
                                <ToggleSwitch v-model="remindDue" />
                            </div>
                            <div class="flex items-center justify-between gap-6 rounded-2xl bg-slate-50 px-6 py-5 ring-1 ring-slate-200/60">
                                <div>
                                    <div class="text-sm font-semibold text-slate-900">Avisar quando saldo ficar negativo</div>
                                </div>
                                <ToggleSwitch v-model="warnNegative" />
                            </div>
                            <div class="flex items-center justify-between gap-6 rounded-2xl bg-slate-50 px-6 py-5 ring-1 ring-slate-200/60">
                                <div>
                                    <div class="text-sm font-semibold text-slate-900">Confirmar quando marcar como pago</div>
                                </div>
                                <ToggleSwitch v-model="confirmPaid" />
                            </div>
                        </div>
                    </div>

                    <div>
                        <div class="text-[11px] font-bold uppercase tracking-wide text-slate-300">Relatórios</div>
                        <div class="mt-5 space-y-4">
                            <div class="flex items-center justify-between gap-6 rounded-2xl bg-slate-50 px-6 py-5 ring-1 ring-slate-200/60">
                                <div>
                                    <div class="text-sm font-semibold text-slate-900">Resumo semanal das finanças</div>
                                    <div class="mt-1 text-xs font-semibold text-slate-400">Toda segunda-feira às 9h</div>
                                </div>
                                <ToggleSwitch v-model="weeklySummary" />
                            </div>
                            <div class="flex items-center justify-between gap-6 rounded-2xl bg-slate-50 px-6 py-5 ring-1 ring-slate-200/60">
                                <div>
                                    <div class="text-sm font-semibold text-slate-900">Avisar sobre gastos fora do padrão</div>
                                </div>
                                <ToggleSwitch v-model="warnOutlier" />
                            </div>
                        </div>
                    </div>

                    <div>
                        <div class="text-[11px] font-bold uppercase tracking-wide text-slate-300">Metas</div>
                        <div class="mt-5 space-y-4">
                            <div class="flex items-center justify-between gap-6 rounded-2xl bg-slate-50 px-6 py-5 ring-1 ring-slate-200/60">
                                <div>
                                    <div class="text-sm font-semibold text-slate-900">Progresso das metas de economia</div>
                                </div>
                                <ToggleSwitch v-model="goalProgress" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="flex justify-end">
                <button type="button" class="inline-flex h-12 items-center justify-center rounded-2xl bg-[#14B8A6] px-8 text-sm font-semibold text-white shadow-lg shadow-emerald-500/20">
                    Guardar Alterações
                </button>
            </div>
        </div>
    </DesktopSettingsShell>
</template>
