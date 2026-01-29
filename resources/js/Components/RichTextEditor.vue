<script setup lang="ts">
import { computed, ref } from 'vue';
import { QuillEditor } from '@vueup/vue-quill';
import '@vueup/vue-quill/dist/vue-quill.snow.css';

const props = withDefaults(
    defineProps<{
        modelValue: string;
        placeholder?: string;
        minHeightClass?: string;
    }>(),
    {
        placeholder: 'Escreva aqui...',
        minHeightClass: 'min-h-[220px]',
    },
);

const emit = defineEmits<{
    (e: 'update:modelValue', value: string): void;
    (e: 'request-image'): void;
}>();

const editorRef = ref<any>(null);

const modules = computed(() => ({
    toolbar: {
        container: '#kitamo-email-toolbar',
        handlers: {
            image: () => emit('request-image'),
            undo: () => editorRef.value?.getQuill?.()?.history?.undo?.(),
            redo: () => editorRef.value?.getQuill?.()?.history?.redo?.(),
        },
    },
    history: {
        delay: 600,
        maxStack: 100,
        userOnly: true,
    },
}) as any);

const onUpdate = (html: string) => {
    emit('update:modelValue', html ?? '');
};

const insertText = (text: string) => {
    const quill = editorRef.value?.getQuill?.();
    if (!quill) return;
    const range = quill.getSelection(true);
    const index = range?.index ?? quill.getLength();
    quill.insertText(index, text, 'user');
    quill.setSelection(index + text.length, 0, 'user');
};

const insertImage = (url: string) => {
    const quill = editorRef.value?.getQuill?.();
    if (!quill || !url) return;
    const range = quill.getSelection(true);
    const index = range?.index ?? quill.getLength();
    quill.insertEmbed(index, 'image', url, 'user');
    quill.setSelection(index + 1, 0, 'user');
};

defineExpose({ insertText, insertImage });
</script>

<template>
    <div class="rounded-2xl border border-slate-200 bg-white">
        <div id="kitamo-email-toolbar" class="flex flex-wrap items-center gap-2 border-b border-slate-200 bg-slate-50 px-3 py-2">
            <button class="ql-bold rounded-xl bg-white px-3 py-2 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60" aria-label="Negrito"></button>
            <button class="ql-italic rounded-xl bg-white px-3 py-2 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60" aria-label="Itálico"></button>
            <button class="ql-underline rounded-xl bg-white px-3 py-2 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60" aria-label="Sublinhado"></button>
            <span class="mx-1 h-6 w-px bg-slate-200"></span>
            <button class="ql-list rounded-xl bg-white px-3 py-2 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60" value="bullet" aria-label="Lista com bullets"></button>
            <button class="ql-list rounded-xl bg-white px-3 py-2 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60" value="ordered" aria-label="Lista numerada"></button>
            <span class="mx-1 h-6 w-px bg-slate-200"></span>
            <button class="ql-link rounded-xl bg-white px-3 py-2 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60" aria-label="Inserir link"></button>
            <button class="ql-image rounded-xl bg-white px-3 py-2 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60" aria-label="Adicionar imagem"></button>
            <span class="mx-1 h-6 w-px bg-slate-200"></span>
            <button class="ql-undo rounded-xl bg-white px-3 py-2 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60" aria-label="Desfazer">↩</button>
            <button class="ql-redo rounded-xl bg-white px-3 py-2 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60" aria-label="Refazer">↪</button>
            <span class="mx-1 h-6 w-px bg-slate-200"></span>
            <select class="ql-size rounded-xl bg-white px-3 py-2 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60" aria-label="Tamanho da fonte"></select>
            <select class="ql-color rounded-xl bg-white px-3 py-2 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60" aria-label="Cor do texto"></select>
        </div>

        <QuillEditor
            ref="editorRef"
            theme="snow"
            contentType="html"
            :content="modelValue"
            :placeholder="placeholder"
            :modules="modules"
            class="kitamo-quill"
            @update:content="onUpdate"
        />
    </div>
</template>

<style>
.kitamo-quill .ql-container {
    border: none;
}
.kitamo-quill .ql-editor {
    padding: 14px 16px;
}
.kitamo-quill .ql-editor:focus {
    outline: none;
}
</style>
