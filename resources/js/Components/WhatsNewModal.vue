<script setup lang="ts">
import { ref } from 'vue';
import { Dialog, DialogPanel, TransitionChild, TransitionRoot } from '@headlessui/vue';

const props = defineProps<{
    open: boolean;
}>();

const emit = defineEmits<{
    (e: 'close'): void;
}>();

const reactions = ref([
    { emoji: '👏', count: 5, active: false },
    { emoji: '❤️', count: 12, active: true },
    { emoji: '😢', count: 21, active: false },
]);

const toggleReaction = (index: number) => {
    // Desativa todas as outras reações
    reactions.value.forEach((r, i) => {
        if (i !== index && r.active) {
            r.active = false;
            r.count = Math.max(0, r.count - 1);
        }
    });
    
    // Toggle da reação clicada
    const reaction = reactions.value[index];
    if (reaction.active) {
        reaction.count--;
        reaction.active = false;
    } else {
        reaction.count++;
        reaction.active = true;
    }
};

const expanded = ref(false);
const showFeedbackInput = ref(false);
const feedbackText = ref('');
const sendingFeedback = ref(false);

const sendFeedback = async () => {
    if (!feedbackText.value.trim() || sendingFeedback.value) return;
    
    sendingFeedback.value = true;
    try {
        const newsItemId = 1; // TODO: passar como prop
        
        await window.axios.post(`/api/news/${newsItemId}/feedback`, {
            feedback: feedbackText.value
        });
        
        feedbackText.value = '';
        showFeedbackInput.value = false;
        alert('Feedback enviado com sucesso!');
    } catch (error) {
        console.error('Erro ao enviar feedback:', error);
        alert('Erro ao enviar feedback. Tente novamente.');
    } finally {
        sendingFeedback.value = false;
    }
};
</script>

<template>
    <TransitionRoot as="template" :show="open">
        <Dialog as="div" class="relative z-50" @close="emit('close')">
            <TransitionChild
                as="template"
                enter="ease-in-out duration-500"
                enter-from="opacity-0"
                enter-to="opacity-100"
                leave="ease-in-out duration-500"
                leave-from="opacity-100"
                leave-to="opacity-0"
            >
                <div class="fixed inset-0 bg-slate-900/50 transition-opacity" />
            </TransitionChild>

            <div class="fixed inset-0 overflow-hidden">
                <div class="absolute inset-0 overflow-hidden">
                    <div class="pointer-events-none fixed inset-y-0 right-0 flex max-w-full pl-10">
                        <TransitionChild
                            as="template"
                            enter="transform transition ease-in-out duration-500 sm:duration-700"
                            enter-from="translate-x-full"
                            enter-to="translate-x-0"
                            leave="transform transition ease-in-out duration-500 sm:duration-700"
                            leave-from="translate-x-0"
                            leave-to="translate-x-full"
                        >
                            <DialogPanel class="pointer-events-auto w-screen max-w-lg">
                                <div class="flex h-full flex-col overflow-y-scroll bg-[#F5F7FA] shadow-xl">
                                    <!-- Header -->
                                    <div class="sticky top-0 z-10 flex items-center justify-between border-b border-slate-200/60 bg-[#F5F7FA]/90 px-6 py-4 backdrop-blur-md">
                                        <div class="flex items-center gap-3">
                                            <button @click="emit('close')" type="button" class="-ml-2 rounded-xl p-2 text-slate-400 hover:bg-slate-200/50 hover:text-slate-600 transition-colors">
                                                <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                    <path d="M4 6h16M4 12h16M4 18h16" />
                                                </svg>
                                            </button>
                                            <h3 class="text-lg font-bold text-slate-800">Novidades do Kitamo</h3>
                                        </div>
                                        <button @click="emit('close')" type="button" class="-mr-2 rounded-xl p-2 text-slate-400 hover:bg-slate-200/50 hover:text-slate-600 transition-colors">
                                            <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <path d="M6 18L18 6M6 6l12 12" />
                                            </svg>
                                        </button>
                                    </div>

                                    <!-- Content -->
                                    <div class="flex-1 p-6">
                                        <div class="rounded-[1.5rem] bg-white p-6 shadow-sm ring-1 ring-slate-100">
                                            <div class="aspect-video w-full overflow-hidden rounded-2xl bg-slate-100 relative mb-6 group">
                                                 <img 
                                                    src="https://images.unsplash.com/photo-1611162617474-5b21e879e113?q=80&w=1000&auto=format&fit=crop" 
                                                    alt="New Feature" 
                                                    class="h-full w-full object-cover transition duration-700 group-hover:scale-105"
                                                />
                                                <div class="absolute inset-0 bg-gradient-to-t from-black/20 to-transparent"></div>
                                                <div class="absolute bottom-4 left-4">
                                                    <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-white/90 backdrop-blur shadow-lg">
                                                        <svg class="h-6 w-6 text-indigo-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                            <path d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z" />
                                                        </svg>
                                                    </div>
                                                </div>
                                            </div>
                                            
                                            <h2 class="text-xl font-bold leading-tight text-slate-900 tracking-tight">
                                                Seu Kitamo móvel: elegante, confortável e envolvente
                                            </h2>

                                            <div class="mt-3 flex items-center gap-3">
                                                <span class="rounded-lg bg-cyan-100 px-2.5 py-1 text-[10px] font-bold uppercase tracking-wide text-cyan-700">
                                                    COLABORAÇÃO
                                                </span>
                                                <span class="text-xs font-medium text-slate-400">14 horas atrás</span>
                                            </div>

                                            <div class="mt-4 text-sm leading-relaxed text-slate-600">
                                                <p>
                                                    Projete seu espaço de trabalho com estilo e conforto! 
                                                    Escolha seu tema e plano de fundo preferidos, personalize o menu inferior com apenas as seções que você precisa e ajuste a frequência das notificações.
                                                    <span v-if="!expanded">A nova atualização traz...</span>
                                                    <span v-else>
                                                        A nova atualização traz uma experiência totalmente renovada para o app mobile, focada em usabilidade e beleza. 
                                                        Agora você pode ver seus gastos por categoria com gráficos interativos e muito mais.
                                                    </span>
                                                </p>
                                                <button 
                                                    v-if="!expanded"
                                                    @click="expanded = true" 
                                                    class="mt-1 inline-flex items-center gap-1 text-sm font-semibold text-blue-600 hover:text-blue-700"
                                                >
                                                    Mais
                                                    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                        <path d="M19 9l-7 7-7-7" />
                                                    </svg>
                                                </button>
                                            </div>

                                            <hr class="my-6 border-slate-100" />

                                            <div class="flex items-center justify-between">
                                                <div class="flex items-center gap-4">
                                                    <button 
                                                        v-for="(reaction, idx) in reactions" 
                                                        :key="idx" 
                                                        @click="toggleReaction(idx)"
                                                        class="flex items-center gap-1.5 transition hover:scale-110 active:scale-95"
                                                    >
                                                        <span class="text-lg shadow-sm" :class="reaction.active ? 'scale-125' : 'grayscale opacity-70 hover:grayscale-0 hover:opacity-100'">{{ reaction.emoji }}</span>
                                                        <span class="text-xs font-bold" :class="reaction.active ? 'text-slate-900' : 'text-slate-400'">{{ reaction.count }}</span>
                                                    </button>
                                                </div>

                                                <div class="flex items-center gap-4">
                                                    <button 
                                                        @click="showFeedbackInput = !showFeedbackInput"
                                                        class="flex items-center gap-2 text-xs font-bold transition"
                                                        :class="showFeedbackInput ? 'text-teal-600' : 'text-slate-500 hover:text-slate-900'"
                                                    >
                                                        <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                            <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
                                                        </svg>
                                                        Feedback
                                                    </button>
                                                    <button class="rounded-xl border border-slate-200 bg-white px-4 py-2 text-xs font-bold text-slate-700 transition hover:bg-slate-50 hover:text-slate-900">
                                                        Saiba mais
                                                        <span class="ml-1 text-slate-400">↗</span>
                                                    </button>
                                                </div>
                                            </div>
                                            
                                            <!-- Feedback Input -->
                                            <div v-if="showFeedbackInput" class="mt-4 space-y-3 animate-in fade-in slide-in-from-top-2 duration-300">
                                                <label class="block">
                                                    <span class="text-xs font-semibold text-slate-700">Seu feedback</span>
                                                    <textarea 
                                                        v-model="feedbackText"
                                                        rows="3"
                                                        placeholder="Conte-nos o que você achou desta novidade..."
                                                        class="mt-2 w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-900 placeholder:text-slate-400 focus:border-teal-500 focus:outline-none focus:ring-2 focus:ring-teal-500/20"
                                                    ></textarea>
                                                </label>
                                                <div class="flex justify-end gap-2">
                                                    <button 
                                                        @click="showFeedbackInput = false; feedbackText = ''"
                                                        type="button"
                                                        class="rounded-xl px-4 py-2 text-xs font-semibold text-slate-600 hover:bg-slate-100 transition"
                                                    >
                                                        Cancelar
                                                    </button>
                                                    <button 
                                                        @click="sendFeedback"
                                                        :disabled="!feedbackText.trim() || sendingFeedback"
                                                        type="button"
                                                        class="rounded-xl bg-gradient-to-r from-emerald-500 to-teal-600 px-4 py-2 text-xs font-semibold text-white shadow-sm transition hover:to-teal-500 disabled:opacity-50 disabled:cursor-not-allowed"
                                                    >
                                                        {{ sendingFeedback ? 'Enviando...' : 'Enviar Feedback' }}
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <!-- Footer / Pagination -->
                                     <div class="border-t border-slate-200/60 bg-[#F5F7FA] px-6 py-8 flex flex-col items-center justify-center gap-4">
                                        <button class="flex h-12 w-12 items-center justify-center rounded-full bg-white text-emerald-500 shadow-xl shadow-emerald-500/10 ring-4 ring-white transition hover:-translate-y-1 hover:shadow-2xl hover:text-emerald-600">
                                            <svg class="h-6 w-6" viewBox="0 0 24 24" fill="currentColor">
                                                <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" />
                                            </svg>
                                        </button>
                                        <div class="text-center">
                                            <h3 class="text-sm font-bold text-slate-900">Isso é tudo que temos para hoje.</h3>
                                            <p class="mt-1 text-xs text-slate-500 max-w-xs mx-auto">
                                                Dê uma olhada nos recursos que lançamos anteriormente. Com certeza, você vai encontrar algo interessante.
                                            </p>
                                        </div>
                                        <button class="text-slate-400 hover:text-slate-600 transition">
                                            <svg class="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <path d="M6 9l12 12" /> <!-- Seta 'V' -->
                                                <path d="M6 9l6 6 6-6" />
                                            </svg>
                                        </button>
                                     </div>

                                </div>
                            </DialogPanel>
                        </TransitionChild>
                    </div>
                </div>
            </div>
        </Dialog>
    </TransitionRoot>
</template>
