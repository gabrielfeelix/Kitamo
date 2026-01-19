<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, Link } from '@inertiajs/vue3';
import MobileShell from '@/Layouts/MobileShell.vue';
import DesktopSettingsShell from '@/Layouts/DesktopSettingsShell.vue';
import { useIsMobile } from '@/composables/useIsMobile';
import PickerSheet from '@/Components/PickerSheet.vue';
import MobileToast from '@/Components/MobileToast.vue';
import { requestJson } from '@/lib/kitamoApi';

const isMobile = useIsMobile();

type CategoryType = 'expense' | 'income';
type IconKey = 'home' | 'food' | 'car' | 'game' | 'heart' | 'money' | 'trend';

interface Category {
    id: string;
    name: string;
    type: CategoryType;
    color: string;
    icon: IconKey;
    is_default: boolean;
}

const props = defineProps<{
    userCategories: Category[];
}>();

const categories = ref<Category[]>(props.userCategories || []);

const categoryType = ref<CategoryType>('expense');
const createCategoryOpen = ref(false);
const editCategoryOpen = ref(false);
const selectedCategory = ref<Category | null>(null);

const editCategoryName = ref('');
const editCategoryIcon = ref<IconKey>('home');
const editCategoryColor = ref('#6B7280');

const toastOpen = ref(false);
const toastMessage = ref('');

const showToast = (message: string) => {
    toastMessage.value = message;
    toastOpen.value = true;
};

const filteredCategories = computed(() =>
    categories.value.filter((c) => c.type === categoryType.value),
);

const iconOptions: IconKey[] = ['home', 'food', 'car', 'game', 'heart'];

const colorOptions = [
    '#6B7280', // slate
    '#EF4444', // red
    '#F59E0B', // amber
    '#10B981', // emerald
    '#3B82F6', // blue
    '#A855F7', // purple
];

const renderIcon = (icon: IconKey) => {
    const icons: Record<IconKey, string> = {
        home: 'M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z',
        food: 'M3 2v7c0 1.1 1 2 2 2h14c1 0 2-.9 2-2V2M7 2v4M12 2v4M17 2v4',
        car: 'M5 11l2-6h10l2 6M3 11h18v7H3zM7 15h2M15 15h2',
        game: 'M6 7h12a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V9a2 2 0 0 1 2-2zM8 13h2M14 13h2',
        heart: 'M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z',
        money: 'M2 7h20M2 17h20M6 2v20M18 2v20',
        trend: 'M3 17l6-6 4 4 8-8M17 7h4v4',
    };
    return icons[icon] || icons.home;
};

const openCreateCategory = () => {
    editCategoryName.value = '';
    editCategoryIcon.value = 'home';
    editCategoryColor.value = '#6B7280';
    selectedCategory.value = null;
    createCategoryOpen.value = true;
};

const openEditCategory = (category: Category) => {
    selectedCategory.value = category;
    editCategoryName.value = category.name;
    editCategoryIcon.value = category.icon;
    editCategoryColor.value = category.color;
    editCategoryOpen.value = true;
};

const saveCategory = async () => {
    if (!editCategoryName.value.trim()) {
        showToast('Nome da categoria é obrigatório');
        return;
    }

    try {
        if (selectedCategory.value) {
            // Update existing
            const response = await requestJson<Category>(`/api/categories/${selectedCategory.value.id}`, {
                method: 'PATCH',
                body: JSON.stringify({
                    name: editCategoryName.value.trim(),
                    icon: editCategoryIcon.value,
                    color: editCategoryColor.value,
                }),
            });

            const idx = categories.value.findIndex((c) => c.id === selectedCategory.value!.id);
            if (idx >= 0) {
                categories.value[idx] = response;
            }
            editCategoryOpen.value = false;
            showToast('Categoria atualizada com sucesso!');
        } else {
            // Create new
            const response = await requestJson<Category>('/api/categories', {
                method: 'POST',
                body: JSON.stringify({
                    name: editCategoryName.value.trim(),
                    type: categoryType.value,
                    icon: editCategoryIcon.value,
                    color: editCategoryColor.value,
                }),
            });

            categories.value.push(response);
            createCategoryOpen.value = false;
            showToast('Categoria criada com sucesso!');
        }
    } catch {
        showToast('Erro ao salvar categoria');
    }
};

const deleteCategory = async () => {
    if (!selectedCategory.value) return;

    try {
        await requestJson(`/api/categories/${selectedCategory.value.id}`, {
            method: 'DELETE',
        });

        categories.value = categories.value.filter((c) => c.id !== selectedCategory.value!.id);
        editCategoryOpen.value = false;
        showToast('Categoria excluída com sucesso!');
    } catch {
        showToast('Erro ao excluir categoria');
    }
};

const closeCreateModal = () => {
    createCategoryOpen.value = false;
    selectedCategory.value = null;
};

const closeEditModal = () => {
    editCategoryOpen.value = false;
    selectedCategory.value = null;
};
</script>

<template>
    <Head title="Categorias" />

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
                <div class="text-lg font-semibold text-slate-900">Categorias</div>
            </div>

            <button
                type="button"
                class="flex h-10 w-10 items-center justify-center rounded-2xl bg-[#14B8A6] text-white shadow-sm"
                aria-label="Criar categoria"
                @click="openCreateCategory"
            >
                <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M12 5v14" />
                    <path d="M5 12h14" />
                </svg>
            </button>
        </header>

        <!-- Type Tabs -->
        <div class="mt-6 flex gap-3 rounded-2xl bg-slate-100 p-1">
            <button
                type="button"
                class="flex-1 rounded-xl px-4 py-2.5 text-sm font-semibold transition"
                :class="
                    categoryType === 'expense'
                        ? 'bg-white text-slate-900 shadow-sm'
                        : 'bg-transparent text-slate-400'
                "
                @click="categoryType = 'expense'"
            >
                Despesas
            </button>
            <button
                type="button"
                class="flex-1 rounded-xl px-4 py-2.5 text-sm font-semibold transition"
                :class="
                    categoryType === 'income'
                        ? 'bg-white text-slate-900 shadow-sm'
                        : 'bg-transparent text-slate-400'
                "
                @click="categoryType = 'income'"
            >
                Receitas
            </button>
        </div>

        <!-- Create Category Modal -->
        <PickerSheet :open="createCategoryOpen" title="Nova Categoria" @close="closeCreateModal">
            <div class="space-y-4 pb-2">
                <!-- Preview Card -->
                <div class="flex justify-center pt-2">
                    <div class="rounded-3xl bg-white p-6 shadow-sm ring-1 ring-slate-200/60">
                        <div class="flex flex-col items-center gap-3">
                            <div
                                class="flex h-16 w-16 items-center justify-center rounded-2xl text-white shadow-md"
                                :style="{ backgroundColor: editCategoryColor }"
                            >
                                <svg class="h-8 w-8" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path :d="renderIcon(editCategoryIcon)" />
                                </svg>
                            </div>
                            <div class="text-sm font-semibold text-slate-900">
                                {{ editCategoryName || 'Nova...' }}
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Name Input -->
                <div>
                    <div class="mb-3 flex items-center gap-2 text-xs font-bold uppercase tracking-wide text-slate-300">
                        <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M4 7h16M10 3v4M14 3v4M4 11h16v8H4z" />
                        </svg>
                        <span>Nome da Categoria</span>
                    </div>
                    <input
                        v-model="editCategoryName"
                        type="text"
                        placeholder="Nome da Categoria"
                        class="h-12 w-full rounded-2xl bg-slate-50 px-4 text-sm font-semibold text-slate-900 placeholder:text-slate-400 ring-1 ring-slate-200/60 focus:outline-none focus:ring-2 focus:ring-[#14B8A6]"
                    />
                </div>

                <!-- Icon Selector -->
                <div>
                    <label class="block text-xs font-bold uppercase tracking-wide text-slate-300">Ícone</label>
                    <div class="mt-3 flex gap-2">
                        <button
                            v-for="icon in iconOptions"
                            :key="icon"
                            type="button"
                            class="flex h-12 w-12 items-center justify-center rounded-2xl bg-slate-800 text-white transition"
                            :class="editCategoryIcon === icon ? 'ring-2 ring-offset-2 ring-slate-900' : ''"
                            @click="editCategoryIcon = icon"
                        >
                            <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path :d="renderIcon(icon)" />
                            </svg>
                        </button>
                    </div>
                </div>

                <!-- Color Selector -->
                <div>
                    <label class="block text-xs font-bold uppercase tracking-wide text-slate-300">Cor</label>
                    <div class="mt-3 flex gap-2">
                        <button
                            v-for="cor in colorOptions"
                            :key="cor"
                            type="button"
                            class="h-10 w-10 rounded-full transition"
                            :style="{ backgroundColor: cor }"
                            :class="editCategoryColor === cor ? 'ring-2 ring-offset-2 ring-slate-900' : ''"
                            @click="editCategoryColor = cor"
                        />
                    </div>
                </div>

                <!-- Actions -->
                <div class="flex gap-3 pt-4">
                    <button
                        type="button"
                        class="flex-1 h-12 rounded-2xl bg-slate-100 text-sm font-semibold text-slate-600 transition hover:bg-slate-200"
                        @click="closeCreateModal"
                    >
                        Cancelar
                    </button>
                    <button
                        type="button"
                        class="flex-1 h-12 rounded-2xl bg-[#14B8A6] text-sm font-semibold text-white transition hover:bg-[#0D9488]"
                        @click="saveCategory"
                    >
                        Salvar
                    </button>
                </div>
            </div>
        </PickerSheet>

        <!-- Edit Category Modal -->
        <PickerSheet :open="editCategoryOpen" title="Editar Categoria" @close="closeEditModal">
            <div v-if="selectedCategory" class="space-y-4 pb-2">
                <!-- Preview Card -->
                <div class="flex justify-center pt-2">
                    <div class="rounded-3xl bg-white p-6 shadow-sm ring-1 ring-slate-200/60">
                        <div class="flex flex-col items-center gap-3">
                            <div
                                class="flex h-16 w-16 items-center justify-center rounded-2xl text-white shadow-md"
                                :style="{ backgroundColor: editCategoryColor }"
                            >
                                <svg class="h-8 w-8" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path :d="renderIcon(editCategoryIcon)" />
                                </svg>
                            </div>
                            <div class="text-sm font-semibold text-slate-900">
                                {{ editCategoryName || selectedCategory.name }}
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Name Input -->
                <div>
                    <div class="mb-3 flex items-center gap-2 text-xs font-bold uppercase tracking-wide text-slate-300">
                        <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M12 20h9" />
                            <path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z" />
                        </svg>
                        <span>{{ editCategoryName || selectedCategory.name }}</span>
                    </div>
                    <input
                        v-model="editCategoryName"
                        type="text"
                        class="h-12 w-full rounded-2xl bg-slate-50 px-4 text-sm font-semibold text-slate-900 ring-1 ring-slate-200/60 focus:outline-none focus:ring-2 focus:ring-[#14B8A6]"
                    />
                </div>

                <!-- Icon Selector -->
                <div>
                    <label class="block text-xs font-bold uppercase tracking-wide text-slate-300">Ícone</label>
                    <div class="mt-3 flex gap-2">
                        <button
                            v-for="icon in iconOptions"
                            :key="icon"
                            type="button"
                            class="flex h-12 w-12 items-center justify-center rounded-2xl bg-slate-800 text-white transition"
                            :class="editCategoryIcon === icon ? 'ring-2 ring-offset-2 ring-slate-900' : ''"
                            @click="editCategoryIcon = icon"
                        >
                            <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path :d="renderIcon(icon)" />
                            </svg>
                        </button>
                    </div>
                </div>

                <!-- Color Selector -->
                <div>
                    <label class="block text-xs font-bold uppercase tracking-wide text-slate-300">Cor</label>
                    <div class="mt-3 flex gap-2">
                        <button
                            v-for="cor in colorOptions"
                            :key="cor"
                            type="button"
                            class="h-10 w-10 rounded-full transition"
                            :style="{ backgroundColor: cor }"
                            :class="editCategoryColor === cor ? 'ring-2 ring-offset-2 ring-slate-900' : ''"
                            @click="editCategoryColor = cor"
                        />
                    </div>
                </div>

                <!-- Actions -->
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
                        @click="saveCategory"
                    >
                        Salvar
                    </button>
                </div>

                <button
                    type="button"
                    class="w-full py-2 text-center text-sm font-semibold text-red-500 transition hover:text-red-600"
                    @click="deleteCategory"
                >
                    Excluir Categoria
                </button>
            </div>
        </PickerSheet>

        <!-- Categories Grid -->
        <div v-if="filteredCategories.length > 0" class="mt-6 grid grid-cols-2 gap-3 pb-8">
            <button
                v-for="category in filteredCategories"
                :key="category.id"
                type="button"
                class="flex flex-col items-center gap-3 rounded-3xl bg-white px-4 py-6 shadow-sm ring-1 ring-slate-200/60 transition hover:shadow-md"
                @click="openEditCategory(category)"
            >
                <div
                    class="flex h-14 w-14 items-center justify-center rounded-2xl text-white shadow-sm"
                    :style="{ backgroundColor: category.color }"
                >
                    <svg class="h-7 w-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path :d="renderIcon(category.icon)" />
                    </svg>
                </div>
                <div class="text-sm font-semibold text-slate-900">{{ category.name }}</div>
            </button>

            <button
                type="button"
                class="flex flex-col items-center justify-center gap-3 rounded-3xl border-2 border-dashed border-slate-200 bg-white px-4 py-6 transition hover:border-slate-300"
                @click="openCreateCategory"
            >
                <div class="flex h-14 w-14 items-center justify-center text-slate-300">
                    <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M12 5v14" />
                        <path d="M5 12h14" />
                    </svg>
                </div>
                <div class="text-sm font-semibold text-slate-400">Nova {{ categoryType === 'expense' ? 'Despesa' : 'Receita' }}</div>
            </button>
        </div>

        <!-- Empty State -->
        <div v-else class="mt-8 rounded-3xl border border-dashed border-slate-200 bg-white px-5 py-8 text-center shadow-sm">
            <div class="mx-auto flex h-16 w-16 items-center justify-center rounded-2xl bg-slate-50 text-slate-400">
                <svg class="h-8 w-8" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M3 3h7l1 2h10v14H3z" />
                </svg>
            </div>
            <div class="mt-4 text-base font-semibold text-slate-900">Nenhuma categoria</div>
            <div class="mt-2 text-sm text-slate-500">Crie sua primeira categoria para começar.</div>
        </div>

        <MobileToast :show="toastOpen" :message="toastMessage" @dismiss="toastOpen = false" />
    </MobileShell>

    <DesktopSettingsShell v-else>
        <div class="overflow-hidden rounded-3xl bg-white shadow-sm ring-1 ring-slate-200/60">
            <div class="px-10 py-9">
                <div class="flex items-center justify-between">
                    <div class="text-lg font-semibold text-slate-900">Suas Categorias</div>
                    <button
                        type="button"
                        class="inline-flex h-11 items-center gap-2 rounded-xl bg-[#14B8A6] px-5 text-sm font-semibold text-white shadow-lg shadow-emerald-500/20"
                        @click="openCreateCategory"
                    >
                        <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M12 5v14" />
                            <path d="M5 12h14" />
                        </svg>
                        Nova Categoria
                    </button>
                </div>

                <div v-if="filteredCategories.length > 0" class="mt-8 grid grid-cols-2 gap-6">
                    <div
                        v-for="category in filteredCategories"
                        :key="category.id"
                        class="flex items-center gap-4 rounded-2xl bg-slate-50 px-6 py-5 ring-1 ring-slate-200/60 transition hover:bg-slate-100 cursor-pointer"
                        @click="openEditCategory(category)"
                    >
                        <div
                            class="flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-2xl text-white"
                            :style="{ backgroundColor: category.color }"
                        >
                            <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path :d="renderIcon(category.icon)" />
                            </svg>
                        </div>
                        <div class="flex-1">
                            <div class="text-sm font-semibold text-slate-900">{{ category.name }}</div>
                            <div class="mt-1 text-xs font-semibold text-slate-400">
                                {{ category.type === 'expense' ? 'Despesa' : 'Receita' }}
                            </div>
                        </div>
                        <svg class="h-5 w-5 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 18l6-6-6-6" />
                        </svg>
                    </div>
                </div>

                <div v-else class="mt-8 rounded-2xl border border-dashed border-slate-200 bg-slate-50 px-6 py-12 text-center">
                    <div class="text-sm text-slate-500">Nenhuma categoria criada ainda. Crie uma para começar!</div>
                </div>
            </div>
        </div>
    </DesktopSettingsShell>
</template>
