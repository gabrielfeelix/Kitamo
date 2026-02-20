<script setup lang="ts">
import { computed, ref } from 'vue';
import { Link, router, usePage } from '@inertiajs/vue3';
import PickerSheet from '@/Components/PickerSheet.vue';
import { useIsMobile } from '@/composables/useIsMobile';

type NavItem = {
    section: 'USUÁRIOS' | 'SISTEMA' | 'MARKETING';
    label: string;
    href: string;
    active: boolean;
    icon: string;
};

const props = withDefaults(
    defineProps<{
        title: string;
        description?: string;
        meta?: string;
    }>(),
    {
        description: '',
        meta: '',
    },
);

const isMobile = useIsMobile();
const navSheetOpen = ref(false);

const page = usePage();
const userEmail = computed(() => String((page.props as any)?.auth?.user?.email ?? '').toLowerCase());
const isAdminEmail = computed(() => userEmail.value === 'contato@kitamo.com.br');

const items = computed<NavItem[]>(() => [
    {
        section: 'USUÁRIOS',
        label: 'Usuários',
        href: route('admin.users.index'),
        active: route().current('admin.users.*'),
        icon: '👥',
    },
    {
        section: 'USUÁRIOS',
        label: 'Permissões',
        href: route('admin.roles.index'),
        active: route().current('admin.roles.*'),
        icon: '🔐',
    },
    {
        section: 'USUÁRIOS',
        label: 'Planos',
        href: route('admin.plans.index'),
        active: route().current('admin.plans.*'),
        icon: '📊',
    },
    {
        section: 'SISTEMA',
        label: 'Logs',
        href: route('admin.logs.index'),
        active: route().current('admin.logs.*'),
        icon: '📋',
    },
    {
        section: 'SISTEMA',
        label: 'Notificações',
        href: route('admin.notifications.index'),
        active: route().current('admin.notifications.*'),
        icon: '🔔',
    },
    {
        section: 'MARKETING',
        label: 'E-mails',
        href: route('admin.emails.index'),
        active: route().current('admin.emails.*'),
        icon: '📧',
    },
    {
        section: 'MARKETING',
        label: 'Leads',
        href: route('admin.leads.index'),
        active: route().current('admin.leads.*'),
        icon: '🎯',
    },
    {
        section: 'MARKETING',
        label: 'Contatos',
        href: route('admin.inquiries.index'),
        active: route().current('admin.inquiries.*'),
        icon: '📨',
    },
    {
        section: 'MARKETING',
        label: 'Changelog',
        href: route('admin.news.index'),
        active: route().current('admin.news.*'),
        icon: '📢',
    },
]);

const grouped = computed(() => {
    const out: Record<string, NavItem[]> = {};
    for (const item of items.value) {
        out[item.section] ??= [];
        out[item.section].push(item);
    }
    return out as Record<NavItem['section'], NavItem[]>;
});

const selectNav = (href: string) => {
    navSheetOpen.value = false;
    router.visit(href);
};

const activeItem = computed(() => items.value.find((i) => i.active) ?? items.value[0]);

const breadcrumbLabel = computed(() => activeItem.value?.label ?? props.title);
</script>

<template>
    <div v-if="!isAdminEmail" class="rounded-3xl bg-white p-8 shadow-sm ring-1 ring-slate-200/60">
        <div class="text-lg font-semibold text-slate-900">Acesso restrito</div>
        <div class="mt-2 text-sm text-slate-500">Este painel é exclusivo para o administrador do KITAMO.</div>
    </div>

    <div v-else class="flex flex-col gap-4 md:flex-row md:gap-6">
        <!-- Mobile header -->
        <div class="flex items-center justify-between gap-3 rounded-3xl bg-white px-5 py-4 shadow-sm ring-1 ring-slate-200/60 md:hidden">
            <Link
                :href="route('dashboard')"
                class="inline-flex items-center gap-2 rounded-2xl bg-slate-50 px-3 py-2 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60"
                aria-label="Voltar para início"
            >
                <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M15 18l-6-6 6-6" />
                </svg>
                Início
            </Link>

            <button
                type="button"
                class="inline-flex items-center gap-2 rounded-2xl bg-slate-50 px-3 py-2 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60"
                aria-label="Abrir menu da administração"
                @click="navSheetOpen = true"
            >
                <span class="text-base">{{ activeItem?.icon }}</span>
                <span class="max-w-[150px] truncate">{{ activeItem?.label }}</span>
                <svg class="h-4 w-4 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M6 9l6 6 6-6" />
                </svg>
            </button>
        </div>

        <!-- Desktop sidebar -->
        <aside class="hidden w-[220px] shrink-0 border-r border-slate-200 bg-white py-6 md:block">
            <div class="sticky top-20 max-h-[calc(100vh-100px)] overflow-y-auto overscroll-contain">
                <div class="px-4 pb-2">
                    <div class="text-xs font-bold uppercase tracking-[0.5px] text-slate-500">Admin</div>
                </div>

                <div v-for="(sectionItems, section) in grouped" :key="section" class="mt-4">
                    <div class="px-4 text-[11px] font-semibold uppercase tracking-[0.5px] text-slate-500">
                        {{ section }}
                    </div>
                    <div class="mt-2">
                        <Link
                            v-for="item in sectionItems"
                            :key="item.href"
                            :href="item.href"
                            class="flex items-center gap-3 border-l-[3px] px-4 py-2.5 text-sm font-medium transition"
                            :class="
                                item.active
                                    ? 'border-[#14B8A6] bg-[#F0FDFA] text-[#14B8A6]'
                                    : 'border-transparent text-slate-600 hover:bg-slate-50 hover:text-slate-900'
                            "
                        >
                            <span class="text-[18px] leading-none">{{ item.icon }}</span>
                            <span>{{ item.label }}</span>
                        </Link>
                    </div>
                </div>
            </div>
        </aside>

        <!-- Content -->
        <section class="min-w-0 flex-1">
            <div class="mx-auto w-full max-w-[1200px]">
                <div class="rounded-xl bg-white p-6 shadow-sm ring-1 ring-slate-200/60 md:p-8">
                    <header class="mb-8">
                        <div class="mb-2 text-xs text-slate-500">
                            <Link :href="route('admin.index')" class="hover:text-slate-700">Administração</Link>
                            <span class="mx-1">›</span>
                            <span>{{ breadcrumbLabel }}</span>
                        </div>
                        <div class="flex items-start justify-between gap-4">
                            <div class="min-w-0">
                                <h1 class="text-2xl font-bold text-slate-900">{{ title }}</h1>
                                <p v-if="description" class="mt-2 text-sm font-medium text-slate-500">{{ description }}</p>
                            </div>
                            <div v-if="meta" class="shrink-0 text-sm font-medium text-slate-500">{{ meta }}</div>
                        </div>
                    </header>
                    <slot />
                </div>
            </div>
        </section>

        <PickerSheet :open="navSheetOpen" title="Administração" @close="navSheetOpen = false">
            <div class="space-y-4 pb-2">
                <div v-for="(sectionItems, section) in grouped" :key="section">
                    <div class="mb-2 px-1 text-[11px] font-semibold uppercase tracking-[0.5px] text-slate-500">{{ section }}</div>
                    <div class="space-y-1">
                        <button
                            v-for="item in sectionItems"
                            :key="item.href"
                            type="button"
                            class="flex w-full items-center gap-3 rounded-2xl px-4 py-3 text-left transition"
                            :class="item.active ? 'bg-[#F0FDFA] text-[#14B8A6]' : 'bg-white text-slate-700 hover:bg-slate-50'"
                            @click="selectNav(item.href)"
                        >
                            <span class="text-[18px] leading-none">{{ item.icon }}</span>
                            <span class="text-sm font-semibold">{{ item.label }}</span>
                        </button>
                    </div>
                </div>
            </div>
        </PickerSheet>
    </div>
</template>
