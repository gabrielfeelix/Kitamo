<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, Link, usePage } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopSettingsShell from '@/Layouts/DesktopSettingsShell.vue';
import { useIsMobile } from '@/composables/useIsMobile';
import PickerSheet from '@/Components/PickerSheet.vue';
import MobileToast from '@/Components/MobileToast.vue';
import { requestJson } from '@/lib/kitamoApi';

const isMobile = useIsMobile();
const page = usePage();

interface Tag {
    id: string;
    nome: string;
    cor: string;
}

const tags = ref<Tag[]>([
    { id: '1', nome: 'viagem-uruguai', cor: '#3B82F6' },
    { id: '2', nome: 'uber', cor: '#EF4444' },
    { id: '3', nome: 'reforma-casa', cor: '#F59E0B' },
    { id: '4', nome: 'freela', cor: '#10B981' },
    { id: '5', nome: 'mercado', cor: '#6B7280' },
]);

const editTagOpen = ref(false);
const selectedTag = ref<Tag | null>(null);

const newTagNome = ref('');
const editTagNome = ref('');
const editTagCor = ref('#3B82F6');

const toastOpen = ref(false);
const toastMessage = ref('');

const showToast = (message: string) => {
    toastMessage.value = message;
    toastOpen.value = true;
};

const corOptions = [
    '#3B82F6', // blue
    '#EF4444', // red
    '#F59E0B', // amber
    '#10B981', // emerald
    '#6B7280', // slate
    '#A855F7', // purple
];

const createTag = async () => {
    if (!newTagNome.value.trim()) {
        return;
    }

    try {
        const randomColor = corOptions[Math.floor(Math.random() * corOptions.length)];
        const response = await requestJson<{ id: string; nome: string; cor: string }>('/api/tags', {
            method: 'POST',
            body: JSON.stringify({
                nome: newTagNome.value.trim(),
                cor: randomColor,
            }),
        });

        tags.value.push(response);
        newTagNome.value = '';
        showToast('Tag criada com sucesso!');
    } catch {
        showToast('Erro ao criar tag');
    }
};

const openEditTag = (tag: Tag) => {
    selectedTag.value = tag;
    editTagNome.value = tag.nome;
    editTagCor.value = tag.cor;
    editTagOpen.value = true;
};

const saveTag = async () => {
    if (!editTagNome.value.trim() || !selectedTag.value) {
        showToast('Nome da tag é obrigatório');
        return;
    }

    try {
        // TODO: Implementar endpoint de update no backend
        const idx = tags.value.findIndex((t) => t.id === selectedTag.value!.id);
        if (idx >= 0) {
            tags.value[idx] = {
                ...tags.value[idx],
                nome: editTagNome.value.trim(),
                cor: editTagCor.value,
            };
        }
        editTagOpen.value = false;
        showToast('Tag atualizada com sucesso!');
    } catch {
        showToast('Erro ao salvar tag');
    }
};

const deleteTag = async () => {
    if (!selectedTag.value) return;

    try {
        // TODO: Implementar endpoint de delete no backend
        tags.value = tags.value.filter((t) => t.id !== selectedTag.value!.id);
        editTagOpen.value = false;
        showToast('Tag excluída com sucesso!');
    } catch {
        showToast('Erro ao excluir tag');
    }
};

const closeEditModal = () => {
    editTagOpen.value = false;
    selectedTag.value = null;
};
</script>

<template>
    <Head title="Tags" />

    <MobileShell v-if="isMobile" :show-nav="false">
        <header class="flex items-center justify-between pt-2">
            <Link
                :href="route('dashboard')"
                class="flex h-10 w-10 items-center justify-center rounded-2xl bg-white text-slate-600 shadow-sm ring-1 ring-slate-200/60"
                aria-label="Voltar"
            >
                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M15 18l-6-6 6-6" />
                </svg>
            </Link>

            <div class="text-center">
                <div class="text-lg font-semibold text-slate-900">Tags</div>
            </div>

            <div class="w-10"></div>
        </header>

        <!-- Input para criar tag -->
        <div class="mt-6 flex items-center gap-3">
            <div class="relative flex-1">
                <span class="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400">#</span>
                <input
                    v-model="newTagNome"
                    type="text"
                    placeholder="Criar nova tag..."
                    class="h-12 w-full rounded-2xl bg-white pl-10 pr-4 text-sm font-semibold text-slate-900 ring-1 ring-slate-200/60 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-[#14B8A6]"
                    @keyup.enter="createTag"
                />
            </div>
            <button
                type="button"
                class="flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-2xl bg-[#14B8A6] text-white shadow-sm"
                aria-label="Criar tag"
                @click="createTag"
            >
                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M12 5v14" />
                    <path d="M5 12h14" />
                </svg>
            </button>
        </div>

        <!-- Texto explicativo -->
        <div class="mt-2 text-xs font-semibold text-slate-400">
            Toque em uma tag para editar ou excluir.
        </div>

        <!-- Edit Tag Modal -->
        <PickerSheet :open="editTagOpen" title="Editar Tag" @close="closeEditModal">
            <div v-if="selectedTag" class="space-y-4 pb-2">
                <div class="flex justify-center pt-2">
                    <div
                        class="inline-flex items-center gap-2 rounded-full px-4 py-2.5 text-base font-semibold"
                        :style="{ backgroundColor: editTagCor + '20', color: editTagCor }"
                    >
                        <span class="text-lg">#</span>
                        <span>{{ editTagNome || selectedTag.nome }}</span>
                    </div>
                </div>

                <div>
                    <div class="mb-3 flex items-center gap-2 text-xs font-bold uppercase tracking-wide text-slate-300">
                        <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M12 20h9" />
                            <path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z" />
                        </svg>
                        <span>{{ editTagNome || selectedTag.nome }}</span>
                    </div>
                    <input
                        v-model="editTagNome"
                        type="text"
                        class="h-12 w-full rounded-2xl bg-slate-50 px-4 text-sm font-semibold text-slate-900 ring-1 ring-slate-200/60 focus:outline-none focus:ring-2 focus:ring-[#14B8A6]"
                    />
                </div>

                <div>
                    <label class="block text-xs font-bold uppercase tracking-wide text-slate-300">Cor da Tag</label>
                    <div class="mt-3 flex gap-2">
                        <button
                            v-for="cor in corOptions"
                            :key="cor"
                            type="button"
                            class="h-10 w-10 rounded-full transition"
                            :style="{ backgroundColor: cor }"
                            :class="editTagCor === cor ? 'ring-2 ring-offset-2 ring-slate-900' : ''"
                            @click="editTagCor = cor"
                        />
                    </div>
                </div>

                <div class="flex gap-3 pt-4">
                    <button
                        type="button"
                        class="flex-1 h-12 rounded-2xl bg-slate-100 text-sm font-semibold text-slate-600 transition hover:bg-slate-200"
                        @click="closeEditModal"
                    >
                        Cancelar
                    </button>
                    <button
                        type="button"
                        class="flex-1 h-12 rounded-2xl bg-[#14B8A6] text-sm font-semibold text-white transition hover:bg-[#0D9488]"
                        @click="saveTag"
                    >
                        Salvar
                    </button>
                </div>

                <button
                    type="button"
                    class="w-full py-2 text-center text-sm font-semibold text-red-500 transition hover:text-red-600"
                    @click="deleteTag"
                >
                    Excluir Tag
                </button>
            </div>
        </PickerSheet>

        <!-- Tags List -->
        <div v-if="tags.length > 0" class="mt-6 space-y-3 pb-8">
            <div class="text-xs font-bold uppercase tracking-wide text-slate-400">Suas Tags</div>
            <div class="flex flex-wrap gap-2">
                <button
                    v-for="tag in tags"
                    :key="tag.id"
                    type="button"
                    class="inline-flex items-center gap-1.5 rounded-full px-3 py-1.5 text-sm font-semibold transition hover:opacity-80"
                    :style="{ backgroundColor: tag.cor + '20', color: tag.cor }"
                    @click="openEditTag(tag)"
                >
                    <span class="text-base">#</span>
                    <span>{{ tag.nome }}</span>
                </button>
            </div>
        </div>

        <!-- Empty State -->
        <div v-else class="mt-8 rounded-3xl border border-dashed border-slate-200 bg-white px-5 py-8 text-center shadow-sm">
            <div class="mx-auto flex h-16 w-16 items-center justify-center rounded-2xl bg-slate-50 text-slate-400">
                <svg class="h-8 w-8" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M9 5H2v7l6.29 6.29c.94.94 2.48.94 3.42 0l3.58-3.58c.94-.94.94-2.48 0-3.42L9 5Z" />
                    <path d="M6 9.01V9" />
                    <path d="m15 5 6.3 6.3a2.4 2.4 0 0 1 0 3.4L17 19" />
                </svg>
            </div>
            <div class="mt-4 text-base font-semibold text-slate-900">Nenhuma tag criada</div>
            <div class="mt-2 text-sm text-slate-500">Crie sua primeira tag para organizar suas movimentações.</div>
        </div>

        <MobileToast :show="toastOpen" :message="toastMessage" @dismiss="toastOpen = false" />
    </MobileShell>

    <DesktopSettingsShell v-else>
        <div class="overflow-hidden rounded-3xl bg-white shadow-sm ring-1 ring-slate-200/60">
            <div class="px-10 py-9">
                <div class="flex items-center justify-between">
                    <div class="text-lg font-semibold text-slate-900">Suas Tags</div>
                </div>

                <div class="mt-6 flex items-center gap-3">
                    <div class="relative flex-1">
                        <span class="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400">#</span>
                        <input
                            v-model="newTagNome"
                            type="text"
                            placeholder="Criar nova tag..."
                            class="h-12 w-full rounded-2xl bg-slate-50 pl-10 pr-4 text-sm font-semibold text-slate-900 ring-1 ring-slate-200/60 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-[#14B8A6]"
                            @keyup.enter="createTag"
                        />
                    </div>
                    <button
                        type="button"
                        class="inline-flex h-12 items-center gap-2 rounded-xl bg-[#14B8A6] px-5 text-sm font-semibold text-white shadow-lg shadow-emerald-500/20"
                        @click="createTag"
                    >
                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M12 5v14" />
                            <path d="M5 12h14" />
                        </svg>
                        Criar Tag
                    </button>
                </div>

                <div v-if="tags.length > 0" class="mt-6 flex flex-wrap gap-3">
                    <button
                        v-for="tag in tags"
                        :key="tag.id"
                        type="button"
                        class="inline-flex items-center gap-2 rounded-full px-4 py-2 text-sm font-semibold transition hover:opacity-80"
                        :style="{ backgroundColor: tag.cor + '20', color: tag.cor }"
                        @click="openEditTag(tag)"
                    >
                        <span>#</span>
                        <span>{{ tag.nome }}</span>
                    </button>
                </div>

                <div v-else class="mt-8 rounded-2xl border border-dashed border-slate-200 bg-slate-50 px-6 py-12 text-center">
                    <div class="text-sm text-slate-500">Nenhuma tag criada ainda. Crie uma para começar!</div>
                </div>
            </div>
        </div>
    </DesktopSettingsShell>
</template>
