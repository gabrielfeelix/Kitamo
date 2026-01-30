<script setup lang="ts">
	import { computed, onUnmounted, ref, watch } from 'vue';
	import { Head, router, useForm } from '@inertiajs/vue3';
	import MobileShell from '@/Layouts/MobileShell.vue';
	import DesktopShell from '@/Layouts/DesktopShell.vue';
	import { useIsMobile } from '@/composables/useIsMobile';
	import Modal from '@/Components/Modal.vue';
	import AdminLayout from '@/Components/AdminLayout.vue';
	import RichTextEditor from '@/Components/RichTextEditor.vue';
	import { requestFormData } from '@/lib/kitamoApi';

type CampaignType = 'announcement' | 'newsletter';
type CampaignStatus = 'draft' | 'scheduled' | 'sent' | 'failed';

type CampaignRow = {
    id: number;
    type: CampaignType | string;
    title: string;
    subject: string | null;
    content?: string | null;
    audience: string;
    status: CampaignStatus | string;
    scheduled_at: string | null;
    sent_at: string | null;
    sent_count: number;
    last_error?: string | null;
    created_at: string | null;
};

const props = defineProps<{
    campaigns: CampaignRow[];
}>();

const isMobile = useIsMobile();
const Shell = computed(() => (isMobile.value ? MobileShell : DesktopShell));
const shellProps = computed(() => (isMobile.value ? { showNav: false } : { title: 'Administração', showSearch: false, showNewAction: false }));

const activeTab = ref<CampaignType>('announcement');
const campaignsByType = computed(() => props.campaigns.filter((c) => (c.type === 'newsletter' ? 'newsletter' : 'announcement') === activeTab.value));

const countAnnouncement = computed(() => props.campaigns.filter((c) => c.type !== 'newsletter').length);
const countNewsletter = computed(() => props.campaigns.filter((c) => c.type === 'newsletter').length);

const formatDateTime = (iso: string | null) => {
    if (!iso) return '';
    const d = new Date(iso);
    if (!Number.isFinite(d.getTime())) return String(iso);
    return d.toLocaleString('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' });
};

const badgeForStatus = (status: string) => {
    if (status === 'sent') return { label: 'Enviado', cls: 'bg-emerald-50 text-emerald-700' };
    if (status === 'scheduled') return { label: 'Agendado', cls: 'bg-amber-50 text-amber-700' };
    if (status === 'failed') return { label: 'Falhou', cls: 'bg-red-50 text-red-700' };
    return { label: 'Rascunho', cls: 'bg-slate-100 text-slate-700' };
};

	const modalOpen = ref(false);
	const editingId = ref<number | null>(null);
	const previewOpen = ref(false);
	const variableMenuOpen = ref(false);
	const templateMenuOpen = ref(false);
	const imageModalOpen = ref(false);
	const imageUrl = ref('');
	const imageFile = ref<File | null>(null);
	const uploadingImage = ref(false);
	const autosaveToast = ref(false);
	let autosaveTimer: number | null = null;
	let lastAutosaveHash = '';

	const form = useForm<{
	    type: CampaignType;
	    title: string;
	    subject: string;
    content: string;
    status: 'draft' | 'scheduled';
    scheduled_at: string;
	}>({
	    type: 'announcement',
	    title: '',
	    subject: '',
	    content: '',
	    status: 'draft',
	    scheduled_at: '',
	});

	const editorRef = ref<InstanceType<typeof RichTextEditor> | null>(null);

	const variables = [
	    { key: '{nome_usuario}', label: 'Nome do usuário' },
	    { key: '{email}', label: 'Email' },
	    { key: '{plano}', label: 'Plano' },
	    { key: '{saldo}', label: 'Saldo' },
	    { key: '{data_atual}', label: 'Data de hoje' },
	] as const;

	const templates = [
	    {
	        key: 'welcome',
	        label: '📧 Boas-vindas',
	        title: 'Bem-vindo ao Kitamo!',
	        subject: '{nome_usuario}, sua conta foi criada ✅',
	        content: `
<p>Olá {nome_usuario}!</p>
<p>Que bom ter você aqui no Kitamo! 🎉</p>
<p>Seu plano <strong>{plano}</strong> já está ativo e você pode começar a usar agora mesmo.</p>
<p><strong>Próximos passos:</strong></p>
<ol>
  <li>Adicione sua primeira conta bancária</li>
  <li>Cadastre uma despesa ou receita</li>
  <li>Veja sua projeção futura de saldo</li>
</ol>
<p>Qualquer dúvida, estamos aqui para ajudar!</p>
<p><a href="#" target="_blank" rel="noopener">Começar agora</a></p>
<p>Abraços,<br/>Equipe Kitamo</p>
`.trim(),
	    },
	    {
	        key: 'feature',
	        label: '🎉 Lançamento de feature',
	        title: 'Novidade no Kitamo 🎉',
	        subject: 'Novidade: uma nova funcionalidade chegou ✅',
	        content: `
<p>Olá {nome_usuario}!</p>
<p>Temos uma novidade no Kitamo: <strong>[NOME DA FEATURE]</strong> 🎉</p>
<p>Com ela, você consegue:</p>
<ul>
  <li>[benefício 1]</li>
  <li>[benefício 2]</li>
  <li>[benefício 3]</li>
</ul>
<p>Atualize e aproveite!</p>
<p>Equipe Kitamo</p>
`.trim(),
	    },
	    {
	        key: 'billing',
	        label: '💳 Lembrete de pagamento',
	        title: 'Lembrete de pagamento',
	        subject: 'Lembrete: sua fatura vence em breve 💳',
	        content: `
<p>Olá {nome_usuario}!</p>
<p>Passando para lembrar que há uma fatura com vencimento próximo.</p>
<p>Saldo atual: <strong>{saldo}</strong></p>
<p>Se precisar de ajuda, conte com a gente.</p>
<p>Equipe Kitamo</p>
`.trim(),
	    },
	    {
	        key: 'monthly',
	        label: '📊 Relatório mensal',
	        title: 'Seu resumo do mês no Kitamo 📊',
	        subject: 'Resumo mensal ({data_atual}) 📊',
	        content: `
<p>Olá {nome_usuario}!</p>
<p>Aqui vai um resumo do seu mês no Kitamo.</p>
<ul>
  <li>Saldo atual: <strong>{saldo}</strong></li>
  <li>Plano: <strong>{plano}</strong></li>
</ul>
<p>Quer ver mais detalhes? Abra o app e confira seus relatórios.</p>
<p>Equipe Kitamo</p>
`.trim(),
	    },
	    {
	        key: 'maintenance',
	        label: '⚠️ Manutenção programada',
	        title: 'Manutenção programada ⚠️',
	        subject: 'Aviso: manutenção programada no Kitamo ⚠️',
	        content: `
<p>Olá {nome_usuario}!</p>
<p>Vamos realizar uma manutenção programada para melhorar a estabilidade do Kitamo.</p>
<p><strong>Quando:</strong> {data_atual} (horário a confirmar)</p>
<p>Durante o período, o sistema pode ficar instável por alguns minutos.</p>
<p>Agradecemos a compreensão.</p>
<p>Equipe Kitamo</p>
`.trim(),
	    },
	    {
	        key: 'promo',
	        label: '🎁 Promoção/desconto',
	        title: 'Oferta especial 🎁',
	        subject: 'Oferta por tempo limitado 🎁',
	        content: `
<p>Olá {nome_usuario}!</p>
<p>Temos uma oferta especial por tempo limitado para você!</p>
<p><strong>[DESCREVER OFERTA]</strong></p>
<p><a href="#" target="_blank" rel="noopener">Aproveitar agora</a></p>
<p>Equipe Kitamo</p>
`.trim(),
	    },
	] as const;

	const insertVariable = (token: string) => {
	    editorRef.value?.insertText?.(token);
	};

	const applyTemplate = (key: (typeof templates)[number]['key']) => {
	    const tpl = templates.find((t) => t.key === key);
	    if (!tpl) return;
	    openCreate(activeTab.value);
	    form.title = tpl.title;
	    form.subject = tpl.subject;
	    form.content = tpl.content;
	    templateMenuOpen.value = false;
	};

	const sampleData = {
	    nome_usuario: 'Gabriel',
	    email: 'gabriel@kitamo.com.br',
	    plano: 'Free',
	    saldo: 'R$ 1.234,56',
	    data_atual: new Intl.DateTimeFormat('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric' }).format(new Date()),
	};

	const previewHtml = computed(() => {
	    const html = String(form.content ?? '');
	    return html
	        .replaceAll('{nome_usuario}', sampleData.nome_usuario)
	        .replaceAll('{email}', sampleData.email)
	        .replaceAll('{plano}', sampleData.plano)
	        .replaceAll('{saldo}', sampleData.saldo)
	        .replaceAll('{data_atual}', sampleData.data_atual);
	});

	const openImageModal = () => {
	    imageUrl.value = '';
	    imageFile.value = null;
	    imageModalOpen.value = true;
	};

	const insertImageFromUrl = () => {
	    const url = imageUrl.value.trim();
	    if (!url) return;
	    editorRef.value?.insertImage?.(url);
	    imageModalOpen.value = false;
	};

	const uploadAndInsertImage = async () => {
	    if (!imageFile.value) return;
	    uploadingImage.value = true;
	    try {
	        const fd = new FormData();
	        fd.append('image', imageFile.value);
	        const res = await requestFormData<{ url: string }>(route('admin.uploads.images'), {
	            method: 'POST',
	            body: fd,
	        });
	        if (res?.url) {
	            editorRef.value?.insertImage?.(res.url);
	            imageModalOpen.value = false;
	        }
	    } catch {
	        // ignore (errors appear in network console)
	    } finally {
	        uploadingImage.value = false;
	    }
	};

	const handleImageFileChange = (e: Event) => {
	    const file = (e.target as HTMLInputElement).files?.[0] ?? null;
	    imageFile.value = file;
	};

	const openCreate = (type: CampaignType) => {
	    editingId.value = null;
	    form.reset();
	    form.clearErrors();
	    form.type = type;
	    modalOpen.value = true;
	};

	const openEdit = (c: CampaignRow) => {
	    editingId.value = c.id;
	    form.reset();
	    form.clearErrors();
    form.type = (c.type === 'newsletter' ? 'newsletter' : 'announcement') as CampaignType;
    form.title = c.title;
    form.subject = c.subject ?? '';
    form.content = c.content ?? '';
    form.status = (c.status === 'scheduled' ? 'scheduled' : 'draft') as any;
    form.scheduled_at = c.scheduled_at ? c.scheduled_at.slice(0, 16) : '';
	    modalOpen.value = true;
	};

	const currentPayload = () => ({
	    type: form.type,
	    title: form.title,
	    subject: form.subject || null,
	    content: form.content || null,
	    status: 'draft' as const,
	    scheduled_at: form.scheduled_at || null,
	});

	const autosave = () => {
	    if (!modalOpen.value) return;
	    if (!editingId.value) return;
	    if (form.processing) return;
	    if (form.status !== 'draft') return;

	    const payload = currentPayload();
	    const nextHash = JSON.stringify(payload);
	    if (nextHash === lastAutosaveHash) return;
	    lastAutosaveHash = nextHash;

	    router.patch(route('admin.emails.update', editingId.value), payload, {
	        preserveScroll: true,
	        preserveState: true,
	        onSuccess: () => {
	            autosaveToast.value = true;
	            window.setTimeout(() => (autosaveToast.value = false), 1500);
	            router.reload({ only: ['campaigns'] });
	        },
	    });
	};

	watch(
	    () => modalOpen.value,
	    (isOpen) => {
	        if (autosaveTimer) window.clearInterval(autosaveTimer);
	        autosaveTimer = null;
	        lastAutosaveHash = '';
	        if (!isOpen) return;
	        if (!editingId.value) return;
	        lastAutosaveHash = JSON.stringify(currentPayload());
	        autosaveTimer = window.setInterval(autosave, 30_000);
	    },
	);

	onUnmounted(() => {
	    if (autosaveTimer) window.clearInterval(autosaveTimer);
	});

const save = () => {
    form.transform((data) => ({
        type: data.type,
        title: data.title,
        subject: data.subject || null,
        content: data.content || null,
        status: data.status,
        scheduled_at: data.scheduled_at || null,
    }));

    if (editingId.value) {
        form.patch(route('admin.emails.update', editingId.value), {
            preserveScroll: true,
            onSuccess: () => {
                modalOpen.value = false;
                router.reload({ only: ['campaigns'] });
            },
        });
        return;
    }

    form.post(route('admin.emails.store'), {
        preserveScroll: true,
        onSuccess: () => {
            modalOpen.value = false;
            router.reload({ only: ['campaigns'] });
        },
    });
};

const deleteId = ref<number | null>(null);
const deleteForm = useForm({});
const confirmDelete = (id: number) => {
    deleteForm.delete(route('admin.emails.destroy', id), {
        preserveScroll: true,
        onSuccess: () => {
            deleteId.value = null;
            router.reload({ only: ['campaigns'] });
        },
    });
};

const sendForm = useForm({});
const sendingId = ref<number | null>(null);
const sendNow = (id: number) => {
    sendingId.value = id;
    sendForm.post(route('admin.emails.send', id), {
        preserveScroll: true,
        onFinish: () => {
            sendingId.value = null;
            router.reload({ only: ['campaigns'] });
        },
    });
};
</script>

<template>
    <Head title="Administração · E-mails e Comunicados" />

    <component :is="Shell" v-bind="shellProps">
        <AdminLayout title="E-mails e Comunicados" description="Crie comunicados (todos os usuários) e newsletters (leads da landing page).">
            <div class="rounded-2xl bg-slate-50 p-6 ring-1 ring-slate-200/60">
                <div class="flex flex-wrap items-start justify-between gap-4">
                    <div>
                        <div class="text-sm font-semibold text-slate-900">Comunicados e Newsletter</div>
                        <div class="mt-1 text-xs font-semibold text-slate-400">Envios editoriais e anúncios do Kitamo</div>
                    </div>

                    <div class="flex flex-wrap items-center gap-2">
                        <button
                            type="button"
                            class="inline-flex items-center justify-center rounded-2xl px-4 py-2 text-sm font-semibold ring-1 transition"
                            :class="activeTab === 'announcement' ? 'bg-emerald-50 text-emerald-700 ring-emerald-100' : 'bg-white text-slate-600 ring-slate-200 hover:bg-slate-50'"
                            @click="activeTab = 'announcement'"
                        >
                            Comunicados
                            <span class="ml-2 rounded-full bg-white/60 px-2 py-0.5 text-xs font-bold text-slate-600 ring-1 ring-slate-200/60">{{ countAnnouncement }}</span>
                        </button>
                        <button
                            type="button"
                            class="inline-flex items-center justify-center rounded-2xl px-4 py-2 text-sm font-semibold ring-1 transition"
                            :class="activeTab === 'newsletter' ? 'bg-emerald-50 text-emerald-700 ring-emerald-100' : 'bg-white text-slate-600 ring-slate-200 hover:bg-slate-50'"
                            @click="activeTab = 'newsletter'"
                        >
                            Newsletter
                            <span class="ml-2 rounded-full bg-white/60 px-2 py-0.5 text-xs font-bold text-slate-600 ring-1 ring-slate-200/60">{{ countNewsletter }}</span>
                        </button>
                    </div>
                </div>

                <div class="mt-5 flex flex-wrap items-center justify-between gap-3">
                    <div class="relative flex flex-wrap items-center gap-2">
                        <button
                            type="button"
                            class="inline-flex items-center justify-center rounded-2xl bg-[#14B8A6] px-4 py-3 text-sm font-semibold text-white shadow-lg shadow-emerald-500/20"
                            @click="openCreate(activeTab)"
                        >
                            + {{ activeTab === 'newsletter' ? 'Nova newsletter' : 'Novo comunicado' }}
                        </button>

                        <button
                            type="button"
                            class="inline-flex items-center justify-center rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-700 hover:bg-slate-50"
                            @click="templateMenuOpen = !templateMenuOpen"
                        >
                            📋 Usar template
                            <svg class="ml-2 h-4 w-4 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M6 9l6 6 6-6" />
                            </svg>
                        </button>

                        <div
                            v-if="templateMenuOpen"
                            class="absolute left-0 top-[calc(100%+8px)] z-10 w-[280px] rounded-2xl bg-white p-2 shadow-lg ring-1 ring-slate-200/60"
                        >
                            <button
                                v-for="t in templates"
                                :key="t.key"
                                type="button"
                                class="flex w-full items-center justify-between rounded-xl px-3 py-2 text-left text-xs font-semibold text-slate-700 hover:bg-slate-50"
                                @click="applyTemplate(t.key)"
                            >
                                <span class="truncate">{{ t.label }}</span>
                            </button>
                        </div>
                    </div>
                    <div class="text-xs font-semibold text-slate-400">
                        {{ activeTab === 'newsletter' ? 'Newsletter vai para leads inscritos.' : 'Comunicados vão para todos os usuários ativos.' }}
                    </div>
                </div>

                <div v-if="campaignsByType.length === 0" class="mt-6 rounded-2xl border border-dashed border-slate-200 bg-slate-50 px-4 py-10 text-center">
                    <div class="text-sm font-semibold text-slate-900">Nenhum item ainda</div>
                    <div class="mt-2 text-xs font-semibold text-slate-500">Crie seu primeiro envio para aparecer aqui.</div>
                </div>

                <div v-else class="mt-6 space-y-3">
                    <div
                        v-for="c in campaignsByType"
                        :key="c.id"
                        class="rounded-2xl bg-slate-50 p-4 ring-1 ring-slate-200/60"
                    >
                        <div class="flex flex-wrap items-start justify-between gap-3">
                            <div class="min-w-0">
                                <div class="flex flex-wrap items-center gap-2">
                                    <div class="truncate text-base font-semibold text-slate-900">{{ c.title }}</div>
                                    <span class="inline-flex items-center rounded-full px-3 py-1 text-xs font-semibold" :class="badgeForStatus(c.status).cls">
                                        {{ badgeForStatus(c.status).label }}
                                    </span>
                                </div>
                                <div class="mt-1 text-xs font-semibold text-slate-500">
                                    <span v-if="c.sent_at">Enviado em {{ formatDateTime(c.sent_at) }} • {{ c.sent_count }} envios</span>
                                    <span v-else-if="c.scheduled_at">Agendado para {{ formatDateTime(c.scheduled_at) }}</span>
                                    <span v-else>Criado em {{ formatDateTime(c.created_at) }}</span>
                                </div>
                            </div>

                            <div class="flex flex-wrap items-center gap-2">
                                <button
                                    type="button"
                                    class="rounded-xl bg-white px-3 py-2 text-xs font-semibold text-slate-700 ring-1 ring-slate-200/60 hover:bg-slate-50"
                                    @click="openEdit(c)"
                                >
                                    Editar
                                </button>
                                <button
                                    v-if="c.status !== 'sent'"
                                    type="button"
                                    class="rounded-xl bg-emerald-600 px-3 py-2 text-xs font-semibold text-white shadow-lg shadow-emerald-500/20 disabled:opacity-60"
                                    :disabled="sendForm.processing && sendingId === c.id"
                                    @click="sendNow(c.id)"
                                >
                                    {{ sendingId === c.id ? 'Enviando…' : 'Enviar agora' }}
                                </button>
                                <button
                                    type="button"
                                    class="rounded-xl bg-red-50 px-3 py-2 text-xs font-semibold text-red-700 ring-1 ring-red-100 hover:bg-red-100"
                                    @click="deleteId = deleteId === c.id ? null : c.id"
                                >
                                    Excluir
                                </button>
                            </div>
                        </div>

                        <div v-if="deleteId === c.id" class="mt-3 rounded-xl bg-red-50 p-3 ring-1 ring-red-100">
                            <div class="text-xs font-semibold text-red-700">Tem certeza que deseja excluir?</div>
                            <div class="mt-2 flex justify-end gap-2">
                                <button type="button" class="px-3 py-2 text-xs font-semibold text-slate-600" @click="deleteId = null">Cancelar</button>
                                <button
                                    type="button"
                                    class="rounded-xl bg-red-600 px-3 py-2 text-xs font-semibold text-white disabled:opacity-60"
                                    :disabled="deleteForm.processing"
                                    @click="confirmDelete(c.id)"
                                >
                                    Excluir agora
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </AdminLayout>
    </component>

    <Modal :show="modalOpen" maxWidth="2xl" @close="modalOpen = false">
        <div class="p-6">
            <div class="flex items-start justify-between gap-4">
                <div>
                    <div class="text-lg font-semibold text-slate-900">
                        {{ editingId ? 'Editar' : 'Novo' }} {{ form.type === 'newsletter' ? 'newsletter' : 'comunicado' }}
                    </div>
                    <div class="mt-1 text-sm text-slate-500">Use nossa identidade visual e um texto direto.</div>
                </div>
                <button
                    type="button"
                    class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-50 text-slate-600 ring-1 ring-slate-200/60"
                    aria-label="Fechar"
                    @click="modalOpen = false"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M6 6l12 12" />
                        <path d="M18 6l-12 12" />
                    </svg>
                </button>
            </div>

            <div class="mt-5 grid gap-4 md:grid-cols-2">
                <label class="block md:col-span-2">
                    <div class="text-xs font-semibold text-slate-500">Título *</div>
                    <input
                        v-model="form.title"
                        type="text"
                        class="mt-2 h-11 w-full appearance-none rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800 placeholder:text-slate-400"
                        placeholder="Ex.: Novidades da semana"
                    />
                </label>
                <label class="block md:col-span-2">
                    <div class="text-xs font-semibold text-slate-500">Assunto (opcional)</div>
                    <input
                        v-model="form.subject"
                        type="text"
                        class="mt-2 h-11 w-full appearance-none rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800 placeholder:text-slate-400"
                        placeholder="Ex.: Atualizações do Kitamo"
                    />
                </label>

                <label class="block">
                    <div class="text-xs font-semibold text-slate-500">Status</div>
                    <select v-model="form.status" class="mt-2 h-11 w-full appearance-none rounded-xl border border-slate-200 bg-white px-4 pr-10 text-sm font-semibold text-slate-800">
                        <option value="draft">Rascunho</option>
                        <option value="scheduled">Agendado</option>
                    </select>
                </label>
                <label class="block">
                    <div class="text-xs font-semibold text-slate-500">Agendar para (opcional)</div>
                    <input
                        v-model="form.scheduled_at"
                        type="datetime-local"
                        class="mt-2 h-11 w-full appearance-none rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800"
                    />
                </label>

                <label class="block md:col-span-2">
                    <div class="text-xs font-semibold text-slate-500">Conteúdo</div>
                    <div class="mt-2 flex flex-wrap items-center justify-between gap-2">
                        <button
                            type="button"
                            class="inline-flex items-center gap-2 rounded-xl bg-white px-3 py-2 text-xs font-semibold text-slate-700 ring-1 ring-slate-200/60 hover:bg-slate-50"
                            @click="previewOpen = true"
                        >
                            👁 Ver preview
                        </button>
                        <div class="relative">
                            <button
                                type="button"
                                class="inline-flex items-center gap-2 rounded-xl bg-white px-3 py-2 text-xs font-semibold text-slate-700 ring-1 ring-slate-200/60 hover:bg-slate-50"
                                @click="variableMenuOpen = !variableMenuOpen"
                            >
                                ➕ Variável
                                <svg class="h-4 w-4 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M6 9l6 6 6-6" />
                                </svg>
                            </button>
                            <div
                                v-if="variableMenuOpen"
                                class="absolute right-0 top-[calc(100%+8px)] z-10 w-[240px] rounded-2xl bg-white p-2 shadow-lg ring-1 ring-slate-200/60"
                            >
                                <button
                                    v-for="v in variables"
                                    :key="v.key"
                                    type="button"
                                    class="flex w-full items-center justify-between rounded-xl px-3 py-2 text-left text-xs font-semibold text-slate-700 hover:bg-slate-50"
                                    @click="() => { insertVariable(v.key); variableMenuOpen = false; }"
                                >
                                    <span class="truncate">{{ v.label }}</span>
                                    <span class="ml-3 text-slate-400">{{ v.key }}</span>
                                </button>
                            </div>
                        </div>
                    </div>

                    <div class="mt-3">
                        <RichTextEditor ref="editorRef" v-model="form.content" placeholder="Escreva aqui o conteúdo do e-mail..." @request-image="openImageModal" />
                    </div>
                    <div v-if="autosaveToast" class="mt-2 text-xs font-semibold text-emerald-600">💾 Rascunho salvo</div>
                </label>
            </div>

            <div v-if="form.hasErrors" class="mt-4 rounded-2xl bg-red-50 p-4 text-sm font-semibold text-red-700">
                Não foi possível salvar. Verifique os campos.
            </div>

            <div class="mt-6 flex items-center justify-end gap-2">
                <button type="button" class="rounded-xl px-4 py-2 text-sm font-semibold text-slate-600" @click="modalOpen = false">Cancelar</button>
                <button
                    type="button"
                    class="rounded-xl bg-[#14B8A6] px-4 py-2 text-sm font-semibold text-white shadow-lg shadow-emerald-500/20 disabled:opacity-60"
                    :disabled="form.processing"
                    @click="save"
                >
                    {{ form.processing ? 'Salvando…' : 'Salvar' }}
                </button>
            </div>
        </div>
    </Modal>

    <Modal :show="previewOpen" maxWidth="full" @close="previewOpen = false">
        <div class="p-6">
            <div class="flex items-start justify-between gap-4">
                <div>
                    <div class="text-lg font-semibold text-slate-900">Preview do e-mail</div>
                    <div class="mt-1 text-sm text-slate-500">Variáveis substituídas com dados de exemplo.</div>
                </div>
                <button
                    type="button"
                    class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-50 text-slate-600 ring-1 ring-slate-200/60"
                    aria-label="Fechar"
                    @click="previewOpen = false"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M6 6l12 12" />
                        <path d="M18 6 6 18" />
                    </svg>
                </button>
            </div>

            <div class="mt-6 rounded-2xl bg-white p-6 ring-1 ring-slate-200/60">
                <div class="text-sm font-semibold text-slate-900">{{ form.subject || form.title || 'Sem assunto' }}</div>
                <div class="mt-4 prose max-w-none prose-slate" v-html="previewHtml"></div>
            </div>
        </div>
    </Modal>

    <Modal :show="imageModalOpen" maxWidth="lg" @close="imageModalOpen = false">
        <div class="p-6">
            <div class="flex items-start justify-between gap-4">
                <div>
                    <div class="text-lg font-semibold text-slate-900">Adicionar imagem</div>
                    <div class="mt-1 text-sm text-slate-500">JPG, PNG, GIF, WEBP (até 2MB).</div>
                </div>
                <button
                    type="button"
                    class="flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-50 text-slate-600 ring-1 ring-slate-200/60"
                    aria-label="Fechar"
                    @click="imageModalOpen = false"
                >
                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M6 6l12 12" />
                        <path d="M18 6 6 18" />
                    </svg>
                </button>
            </div>

            <div class="mt-6 space-y-4">
                <div class="rounded-2xl bg-slate-50 p-4 ring-1 ring-slate-200/60">
                    <div class="text-xs font-bold uppercase tracking-wide text-slate-400">Upload</div>
                    <input
                        type="file"
                        accept="image/*"
                        class="mt-3 block w-full text-sm font-semibold text-slate-700 file:mr-4 file:rounded-xl file:border-0 file:bg-white file:px-4 file:py-2 file:text-sm file:font-semibold file:text-slate-700 file:ring-1 file:ring-slate-200/60"
                        @change="handleImageFileChange"
                    />
                    <button
                        type="button"
                        class="mt-3 inline-flex items-center justify-center rounded-xl bg-[#14B8A6] px-4 py-2 text-sm font-semibold text-white shadow-lg shadow-emerald-500/20 disabled:opacity-60"
                        :disabled="uploadingImage || !imageFile"
                        @click="uploadAndInsertImage"
                    >
                        {{ uploadingImage ? 'Enviando…' : 'Enviar e inserir' }}
                    </button>
                </div>

                <div class="rounded-2xl bg-slate-50 p-4 ring-1 ring-slate-200/60">
                    <div class="text-xs font-bold uppercase tracking-wide text-slate-400">URL</div>
                    <input v-model="imageUrl" type="url" class="mt-3 h-11 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-800" placeholder="https://..." />
                    <button
                        type="button"
                        class="mt-3 inline-flex items-center justify-center rounded-xl bg-white px-4 py-2 text-sm font-semibold text-slate-700 ring-1 ring-slate-200/60 disabled:opacity-60"
                        :disabled="!imageUrl.trim()"
                        @click="insertImageFromUrl"
                    >
                        Inserir
                    </button>
                </div>
            </div>
        </div>
    </Modal>
</template>
