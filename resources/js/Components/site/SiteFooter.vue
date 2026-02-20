<script setup lang="ts">
import { Link } from '@inertiajs/vue3';
import { siteNavigation } from '@/types/site';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();
</script>

<template>
    <footer class="relative z-10 border-t border-slate-200 bg-[#eef1ea]">
        <div class="mx-auto grid w-full max-w-[1240px] gap-8 px-5 py-12 md:grid-cols-12 md:px-6">
            <div class="md:col-span-4">
                <p class="text-2xl font-bold tracking-[-0.04em] text-slate-950">kitamo</p>
                <p class="mt-3 max-w-sm text-sm leading-relaxed text-slate-600">
                    Sistema de clareza financeira para quem quer decidir com antecedência, não no susto.
                </p>
            </div>

            <div class="md:col-span-5">
                <p class="text-xs font-bold uppercase tracking-[0.16em] text-slate-500">Navegação</p>
                <div class="mt-4 grid grid-cols-2 gap-x-6 gap-y-2">
                    <Link
                        v-for="item in siteNavigation"
                        :key="`foot-${item.routeName}`"
                        :href="route(item.routeName)"
                        class="text-sm font-semibold text-slate-700 transition hover:text-slate-950"
                    >
                        {{ item.label }}
                    </Link>
                </div>
            </div>

            <div class="md:col-span-3">
                <p class="text-xs font-bold uppercase tracking-[0.16em] text-slate-500">Legal</p>
                <div class="mt-4 grid gap-2">
                    <Link :href="route('site.privacy')" class="text-sm font-semibold text-slate-700 transition hover:text-slate-950">Privacidade</Link>
                    <Link :href="route('site.terms')" class="text-sm font-semibold text-slate-700 transition hover:text-slate-950">Termos</Link>
                    <Link v-if="canLogin" href="/login" class="text-sm font-semibold text-slate-700 transition hover:text-slate-950">Entrar</Link>
                </div>
            </div>
        </div>

        <div class="border-t border-slate-200/80 py-4">
            <div class="mx-auto flex w-full max-w-[1240px] items-center justify-between px-5 text-xs text-slate-500 md:px-6">
                <span>© {{ new Date().getFullYear() }} Kitamo</span>
                <span>Feito para organização financeira pessoal</span>
            </div>
        </div>
    </footer>
</template>
