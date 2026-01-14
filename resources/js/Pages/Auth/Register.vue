<script setup lang="ts">
import { ref } from 'vue';
import AuthShell from '@/Layouts/AuthShell.vue';
import InputError from '@/Components/InputError.vue';
import { Head, Link, useForm } from '@inertiajs/vue3';

const form = useForm({
    name: '',
    email: '',
    password: '',
    password_confirmation: '',
});

const showPassword = ref(false);
const showConfirm = ref(false);

const submit = () => {
    form.post(route('register'), {
        onFinish: () => {
            form.reset('password', 'password_confirmation');
        },
    });
};
</script>

<template>
    <AuthShell>
        <template #aside>
            <div class="relative flex h-full w-full flex-col justify-between overflow-hidden bg-[linear-gradient(160deg,#1ab7a6,#0b7f78)] px-10 py-10 text-white">
                <div class="pointer-events-none absolute -right-24 -top-20 h-80 w-80 rounded-full bg-white/10"></div>
                <div class="pointer-events-none absolute -bottom-40 -right-16 h-[520px] w-[520px] rounded-full bg-white/10"></div>
                <div class="pointer-events-none absolute -bottom-52 -left-28 h-[520px] w-[520px] rounded-full bg-white/10"></div>

                <div class="relative z-10 space-y-10">
                    <div class="flex items-center gap-3">
                        <div class="flex h-11 w-11 items-center justify-center rounded-xl bg-white text-[var(--kitamo-accent)] text-lg font-bold">
                            K
                        </div>
                        <div class="text-lg font-semibold tracking-wide">Kitamo</div>
                    </div>

                    <div class="space-y-5">
                        <h2 class="text-4xl font-semibold leading-tight">Vai sobrar ou vai faltar?</h2>
                        <p class="max-w-sm text-sm text-white/80">
                            A gente te mostra. Sem mistério, sem susto no saldo. É só lançar seus gastos e ver se o dinheiro aguenta até o próximo salário.
                        </p>
                    </div>
                </div>

                <div class="relative z-10 mt-10 max-w-md rounded-3xl border border-white/15 bg-white/10 p-6 backdrop-blur">
                    <div class="flex items-center gap-1 text-amber-300">
                        <svg v-for="star in 5" :key="star" class="h-4 w-4" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                            <path d="M12 2.5l2.9 6 6.6.9-4.8 4.6 1.2 6.5L12 17.8 6.1 20.5l1.2-6.5-4.8-4.6 6.6-.9L12 2.5Z" />
                        </svg>
                    </div>
                    <p class="mt-4 text-sm italic text-white/90">
                        "Antes eu ficava na agonia de nao saber se ia sobrar grana. Agora eu sei exatamente quando posso gastar e quando preciso segurar."
                    </p>
                    <div class="mt-6 flex items-center gap-3">
                        <div class="flex h-10 w-10 items-center justify-center rounded-full bg-white/20 text-sm font-semibold text-white">LM</div>
                        <div>
                            <div class="text-xs font-semibold uppercase tracking-wide text-white">Lucas Mendes</div>
                            <div class="text-[10px] text-white/70">28 anos</div>
                        </div>
                    </div>
                </div>
            </div>
        </template>

        <Head title="Criar conta" />

        <div class="flex flex-1 flex-col justify-center">
            <div class="mx-auto w-full max-w-md">
                <div class="flex flex-col items-center text-center lg:items-start lg:text-left">
                    <div
                        class="flex h-14 w-14 items-center justify-center rounded-2xl bg-[var(--kitamo-accent)] text-2xl font-bold text-white shadow-[0_18px_30px_-20px_rgba(20,184,166,0.85)] lg:hidden"
                    >
                        K
                    </div>
                    <h1 class="mt-5 text-2xl font-semibold text-[var(--kitamo-ink)] lg:text-3xl">Cria sua conta grátis</h1>
                    <p class="mt-2 text-sm text-slate-500">Vem pra familia Kitamo e esquece o sufoco.</p>
                </div>

                <div class="mt-8">
                    <a
                        href="/auth/google"
                        class="flex w-full items-center justify-between gap-3 rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-700 shadow-sm hover:bg-slate-50 transition-colors"
                    >
                        <span class="flex items-center gap-3">
                            <span class="flex h-10 w-10 items-center justify-center rounded-xl bg-slate-50">
                                <svg class="h-5 w-5" viewBox="0 0 48 48" aria-hidden="true">
                                    <path fill="#FFC107" d="M43.6 20.1H42V20H24v8h11.3c-1.7 4.7-6.2 8-11.3 8-6.6 0-12-5.4-12-12s5.4-12 12-12c3 0 5.7 1.1 7.8 2.9l5.7-5.7C33.9 6.1 29.2 4 24 4 12.9 4 4 12.9 4 24s8.9 20 20 20c10 0 19-7.3 19-20 0-1.3-.1-2.6-.4-3.9z"/>
                                    <path fill="#FF3D00" d="M6.3 14.7l6.6 4.8C14.7 16.1 19 12 24 12c3 0 5.7 1.1 7.8 2.9l5.7-5.7C33.9 6.1 29.2 4 24 4c-7.7 0-14.3 4.3-17.7 10.7z"/>
                                    <path fill="#4CAF50" d="M24 44c5 0 9.7-1.9 13.1-4.9l-6.1-5c-2 1.4-4.4 2.1-7 2.1-5.1 0-9.4-3.3-11-7.9l-6.5 5C9.8 39.7 16.4 44 24 44z"/>
                                    <path fill="#1976D2" d="M43.6 20.1H42V20H24v8h11.3c-.8 2.3-2.3 4.2-4.4 5.5l6.1 5C39.2 35.5 43 30.3 43 24c0-1.3-.1-2.6-.4-3.9z"/>
                                </svg>
                            </span>
                            <span>Cadastrar com Google <span class="text-slate-400">(mais rapido)</span></span>
                        </span>
                    </a>
                </div>

                <div class="mt-5 flex items-center gap-3">
                    <span class="h-px flex-1 bg-slate-200"></span>
                    <span class="text-xs font-semibold uppercase tracking-wide text-slate-400">ou usa seu e-mail</span>
                    <span class="h-px flex-1 bg-slate-200"></span>
                </div>

                <form class="mt-5 space-y-5" @submit.prevent="submit">

                    <div>
                        <label for="name" class="text-xs font-semibold text-slate-500">Como te chamamos?</label>
                        <input
                            id="name"
                            v-model="form.name"
                            type="text"
                            class="mt-2 w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm font-semibold text-slate-700 placeholder:text-slate-400 focus:border-emerald-200 focus:outline-none focus:ring-2 focus:ring-emerald-100"
                            placeholder="Ex: Gabriel Silva"
                            required
                            autofocus
                            autocomplete="name"
                        />
                        <InputError class="mt-1" :message="form.errors.name" />
                    </div>

                    <div>
                        <label for="email" class="text-xs font-semibold text-slate-500">Seu e-mail</label>
                        <input
                            id="email"
                            v-model="form.email"
                            type="email"
                            class="mt-2 w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm font-semibold text-slate-700 placeholder:text-slate-400 focus:border-emerald-200 focus:outline-none focus:ring-2 focus:ring-emerald-100"
                            placeholder="seuemail@exemplo.com"
                            required
                            autocomplete="username"
                        />
                        <InputError class="mt-1" :message="form.errors.email" />
                    </div>

                    <div>
                        <label for="password" class="text-xs font-semibold text-slate-500">Sua senha</label>
                        <div class="relative mt-2">
                            <input
                                id="password"
                                v-model="form.password"
                                :type="showPassword ? 'text' : 'password'"
                                class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 pr-12 text-sm font-semibold text-slate-700 placeholder:text-slate-400 focus:border-emerald-200 focus:outline-none focus:ring-2 focus:ring-emerald-100"
                                placeholder="Minimo 6 caracteres"
                                required
                                autocomplete="new-password"
                            />
                            <button
                                type="button"
                                class="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400"
                                :aria-label="showPassword ? 'Ocultar senha' : 'Mostrar senha'"
                                @click="showPassword = !showPassword"
                            >
                                <svg v-if="showPassword" class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7Z" />
                                    <circle cx="12" cy="12" r="3" />
                                </svg>
                                <svg v-else class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M3 3l18 18" />
                                    <path d="M10.5 10.5a2.5 2.5 0 0 0 3 3" />
                                    <path d="M6.3 6.3C4.3 7.7 2.9 9.7 2 12c0 0 3.5 7 10 7 2.1 0 4-.5 5.6-1.3" />
                                    <path d="M9.9 5.1C10.6 5 11.3 5 12 5c6.5 0 10 7 10 7a17 17 0 0 1-2.3 3.4" />
                                </svg>
                            </button>
                        </div>
                        <InputError class="mt-1" :message="form.errors.password" />
                    </div>

                    <div>
                        <label for="password_confirmation" class="text-xs font-semibold text-slate-500">Confirma a senha</label>
                        <div class="relative mt-2">
                            <input
                                id="password_confirmation"
                                v-model="form.password_confirmation"
                                :type="showConfirm ? 'text' : 'password'"
                                class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 pr-12 text-sm font-semibold text-slate-700 placeholder:text-slate-400 focus:border-emerald-200 focus:outline-none focus:ring-2 focus:ring-emerald-100"
                                placeholder="Repete ela aqui"
                                required
                                autocomplete="new-password"
                            />
                            <button
                                type="button"
                                class="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400"
                                :aria-label="showConfirm ? 'Ocultar senha' : 'Mostrar senha'"
                                @click="showConfirm = !showConfirm"
                            >
                                <svg v-if="showConfirm" class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7Z" />
                                    <circle cx="12" cy="12" r="3" />
                                </svg>
                                <svg v-else class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M3 3l18 18" />
                                    <path d="M10.5 10.5a2.5 2.5 0 0 0 3 3" />
                                    <path d="M6.3 6.3C4.3 7.7 2.9 9.7 2 12c0 0 3.5 7 10 7 2.1 0 4-.5 5.6-1.3" />
                                    <path d="M9.9 5.1C10.6 5 11.3 5 12 5c6.5 0 10 7 10 7a17 17 0 0 1-2.3 3.4" />
                                </svg>
                            </button>
                        </div>
                        <InputError class="mt-1" :message="form.errors.password_confirmation" />
                    </div>

                    <button
                        type="submit"
                        class="group flex h-14 w-full items-center justify-center gap-3 rounded-2xl bg-[var(--kitamo-accent)] text-sm font-semibold text-white shadow-[0_20px_35px_-22px_rgba(20,184,166,0.9)]"
                        :class="{ 'opacity-70': form.processing }"
                        :disabled="form.processing"
                    >
                        Criar minha conta agora
                        <span class="flex items-center gap-2 text-white">
                            <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M5 12h14" />
                                <path d="M13 5l6 7-6 7" />
                            </svg>
                        </span>
                    </button>
                </form>

                <div class="mt-8 flex items-center justify-center gap-2 text-sm text-slate-500">
                    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                        <path d="M15 18l-6-6 6-6" />
                    </svg>
                    <Link :href="route('login')" class="font-semibold text-[var(--kitamo-accent)]">Voltar pro login</Link>
                </div>
            </div>
        </div>
    </AuthShell>
</template>
