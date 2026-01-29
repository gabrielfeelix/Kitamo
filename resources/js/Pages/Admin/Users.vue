<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, useForm } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopShell from '@/Layouts/DesktopShell.vue';
import { useIsMobile } from '@/composables/useIsMobile';
import AdminNav from '@/Components/AdminNav.vue';

const props = defineProps<{
    users: Array<{
        id: number;
        name: string;
        email: string;
        is_admin: boolean;
        created_at: string;
    }>;
}>();

const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() =>
    isMobile.value ? { showNav: false } : { title: 'Administração', showSearch: false, showNewAction: false },
);
const activeUserId = ref<number | null>(null);

const form = useForm({
    password: '',
    password_confirmation: '',
});

const toggleReset = (id: number) => {
    activeUserId.value = activeUserId.value === id ? null : id;
    form.reset();
    form.clearErrors();
};

const submitReset = (id: number) => {
    form.patch(route('admin.users.password', id), {
        preserveScroll: true,
        onSuccess: () => {
            form.reset();
            activeUserId.value = null;
        },
    });
};

const formatDate = (value: string) => new Date(value).toLocaleDateString('pt-BR');
</script>

<template>
    <Head title="Administração" />

    <component :is="Shell" v-bind="shellProps">
        <div class="space-y-4">
            <div class="rounded-3xl bg-white p-6 shadow-sm ring-1 ring-slate-200/60">
                <div class="text-xl font-semibold text-slate-900">Administração</div>
                <p class="mt-2 text-sm text-slate-500">Gerencie usuários e redefina senhas.</p>
                <div class="mt-5">
                    <AdminNav />
                </div>
            </div>

            <div class="space-y-4">
                <div
                    v-for="user in props.users"
                    :key="user.id"
                    class="rounded-3xl bg-white p-5 shadow-sm ring-1 ring-slate-200/60"
                >
                    <div class="flex items-start justify-between">
                        <div>
                            <div class="text-base font-semibold text-slate-900">{{ user.name }}</div>
                            <div class="text-sm text-slate-500">{{ user.email }}</div>
                        </div>
                        <span
                            class="rounded-full px-3 py-1 text-xs font-semibold"
                            :class="user.is_admin ? 'bg-emerald-50 text-emerald-700' : 'bg-slate-100 text-slate-500'"
                        >
                            {{ user.is_admin ? 'Admin' : 'Usuário' }}
                        </span>
                    </div>

                    <div class="mt-3 text-xs text-slate-400">Criado em {{ formatDate(user.created_at) }}</div>

                    <button
                        type="button"
                        class="mt-4 inline-flex items-center gap-2 rounded-2xl border border-emerald-100 bg-emerald-50 px-4 py-2 text-sm font-semibold text-emerald-700"
                        @click="toggleReset(user.id)"
                    >
                        Alterar senha
                    </button>

                    <form v-if="activeUserId === user.id" class="mt-4 space-y-3" @submit.prevent="submitReset(user.id)">
                        <div>
                            <label class="text-xs font-semibold text-slate-500">Nova senha</label>
                            <input
                                v-model="form.password"
                                type="password"
                                class="mt-2 w-full rounded-2xl border border-slate-200 px-4 py-3 text-sm font-semibold text-slate-700"
                                placeholder="Digite a nova senha"
                            />
                            <div v-if="form.errors.password" class="mt-1 text-xs text-red-500">{{ form.errors.password }}</div>
                        </div>
                        <div>
                            <label class="text-xs font-semibold text-slate-500">Confirmar senha</label>
                            <input
                                v-model="form.password_confirmation"
                                type="password"
                                class="mt-2 w-full rounded-2xl border border-slate-200 px-4 py-3 text-sm font-semibold text-slate-700"
                                placeholder="Repita a senha"
                            />
                        </div>
                        <button
                            type="submit"
                            class="inline-flex items-center justify-center rounded-2xl bg-slate-900 px-5 py-3 text-sm font-semibold text-white"
                            :disabled="form.processing"
                        >
                            Salvar
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </component>

</template>
