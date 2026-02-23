<script setup lang="ts">
import { computed, ref } from 'vue';
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

const hasMinLength = computed(() => form.password.length >= 8);
const hasUppercase = computed(() => /[A-Z]/.test(form.password));
const hasNumber = computed(() => /\d/.test(form.password));

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
            <div class="relative flex h-full w-full flex-col justify-between overflow-hidden bg-slate-950 px-10 py-10 text-white">
                <!-- Animated orbs -->
                <div class="pointer-events-none absolute -right-32 -top-32 h-[400px] w-[400px] rounded-full bg-teal-500/20 blur-[100px] animate-pulse"></div>
                <div class="pointer-events-none absolute -bottom-40 -left-20 h-[500px] w-[500px] rounded-full bg-cyan-500/10 blur-[120px]"></div>
                <div class="pointer-events-none absolute top-1/2 right-1/4 h-[300px] w-[300px] rounded-full bg-emerald-500/10 blur-[100px] animate-pulse" style="animation-delay: 1s; animation-duration: 4s;"></div>
                
                <!-- Noise texture -->
                <div class="pointer-events-none absolute inset-0 opacity-[0.03] mix-blend-overlay" style="background-image: url('data:image/svg+xml,%3Csvg viewBox=%220 0 200 200%22 xmlns=%22http://www.w3.org/2000/svg%22%3E%3Cfilter id=%22n%22%3E%3CfeTurbulence type=%22fractalNoise%22 baseFrequency=%220.9%22 numOctaves=%224%22 stitchTiles=%22stitch%22/%3E%3C/filter%3E%3Crect width=%22100%25%22 height=%22100%25%22 filter=%22url(%23n)%22/%3E%3C/svg%3E');"></div>
                
                <!-- Grid pattern overlay -->
                <div class="pointer-events-none absolute inset-0 opacity-[0.04]" style="background-image: linear-gradient(rgba(255,255,255,0.06) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.06) 1px, transparent 1px); background-size: 40px 40px;"></div>

                <div class="relative z-10 space-y-8">
                    <div class="flex items-center gap-3">
                        <div class="flex h-11 w-11 items-center justify-center rounded-xl bg-teal-500 text-slate-950 text-lg font-extrabold shadow-[0_0_30px_rgba(20,184,166,0.4)]">
                            K
                        </div>
                        <div class="text-lg font-extrabold tracking-wide text-white">kitamo<span class="text-teal-400">.</span></div>
                    </div>

                    <div class="space-y-4 mt-4">
                        <h2 class="text-4xl font-extrabold leading-[0.95] tracking-tight">
                            2 minutos<br>pra mudar seu<br><span class="text-teal-400">mês inteiro.</span>
                        </h2>
                        <p class="max-w-sm text-sm text-slate-400 font-medium leading-relaxed">
                            Crie sua conta, cadastre suas contas e comece a ver o futuro do seu bolso.
                        </p>
                    </div>
                </div>

                <!-- Steps preview -->
                <div class="relative z-10 mt-auto space-y-3">
                    <div class="flex items-center gap-4 rounded-2xl border border-white/[0.08] bg-white/[0.04] px-5 py-4 backdrop-blur-sm">
                        <div class="flex h-10 w-10 items-center justify-center rounded-xl bg-teal-500/10 text-teal-400 font-extrabold text-sm border border-teal-500/20">1</div>
                        <div>
                            <div class="text-sm font-extrabold text-white">Cria a conta</div>
                            <div class="text-[11px] text-slate-500 font-medium">E-mail ou Google · 30 segundos</div>
                        </div>
                    </div>
                    <div class="flex items-center gap-4 rounded-2xl border border-white/[0.08] bg-white/[0.04] px-5 py-4 backdrop-blur-sm">
                        <div class="flex h-10 w-10 items-center justify-center rounded-xl bg-cyan-500/10 text-cyan-400 font-extrabold text-sm border border-cyan-500/20">2</div>
                        <div>
                            <div class="text-sm font-extrabold text-white">Cadastra suas contas</div>
                            <div class="text-[11px] text-slate-500 font-medium">Nubank, Itaú, dívidas · 1 minuto</div>
                        </div>
                    </div>
                    <div class="flex items-center gap-4 rounded-2xl border border-white/[0.08] bg-white/[0.04] px-5 py-4 backdrop-blur-sm">
                        <div class="flex h-10 w-10 items-center justify-center rounded-xl bg-emerald-500/10 text-emerald-400 font-extrabold text-sm border border-emerald-500/20">3</div>
                        <div>
                            <div class="text-sm font-extrabold text-white">Vê o futuro</div>
                            <div class="text-[11px] text-slate-500 font-medium">30, 60, 90 dias · seu saldo previsto</div>
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
                        class="flex h-14 w-14 items-center justify-center rounded-2xl bg-teal-500 text-2xl font-extrabold text-slate-950 shadow-[0_18px_30px_-20px_rgba(20,184,166,0.85)] lg:hidden"
                    >
                        K
                    </div>
                    <h1 class="mt-5 text-2xl font-extrabold text-slate-900 lg:text-3xl tracking-tight">Cria sua conta grátis</h1>
                    <p class="mt-2 text-sm text-slate-500 font-medium">Vem pra família Kitamo e esquece o sufoco.</p>
                </div>

                <div class="mt-8">
                    <a
                        href="/auth/google"
                        class="flex w-full items-center justify-center gap-3 rounded-2xl border border-slate-200 bg-white px-4 py-3.5 text-sm font-bold text-slate-700 shadow-sm transition-all hover:bg-slate-50 hover:shadow-md hover:-translate-y-0.5 focus:outline-none focus-visible:ring-2 focus-visible:ring-teal-200"
                    >
                        <span class="flex h-10 w-10 items-center justify-center rounded-xl bg-slate-50">
                            <svg class="h-5 w-5" viewBox="0 0 48 48" aria-hidden="true">
                                <path fill="#FFC107" d="M43.6 20.1H42V20H24v8h11.3c-1.7 4.7-6.2 8-11.3 8-6.6 0-12-5.4-12-12s5.4-12 12-12c3 0 5.7 1.1 7.8 2.9l5.7-5.7C33.9 6.1 29.2 4 24 4 12.9 4 4 12.9 4 24s8.9 20 20 20c10 0 19-7.3 19-20 0-1.3-.1-2.6-.4-3.9z"/>
                                <path fill="#FF3D00" d="M6.3 14.7l6.6 4.8C14.7 16.1 19 12 24 12c3 0 5.7 1.1 7.8 2.9l5.7-5.7C33.9 6.1 29.2 4 24 4c-7.7 0-14.3 4.3-17.7 10.7z"/>
                                <path fill="#4CAF50" d="M24 44c5 0 9.7-1.9 13.1-4.9l-6.1-5c-2 1.4-4.4 2.1-7 2.1-5.1 0-9.4-3.3-11-7.9l-6.5 5C9.8 39.7 16.4 44 24 44z"/>
                                <path fill="#1976D2" d="M43.6 20.1H42V20H24v8h11.3c-.8 2.3-2.3 4.2-4.4 5.5l6.1 5C39.2 35.5 43 30.3 43 24c0-1.3-.1-2.6-.4-3.9z"/>
                            </svg>
                        </span>
                        <span>Continuar com Google</span>
                    </a>
                </div>

                <div class="mt-5 flex items-center gap-3">
                    <span class="h-px flex-1 bg-slate-200"></span>
                    <span class="text-xs font-bold uppercase tracking-wide text-slate-400">ou usa seu e-mail</span>
                    <span class="h-px flex-1 bg-slate-200"></span>
                </div>

                <form class="mt-5 space-y-5" @submit.prevent="submit">

                    <div>
                        <label for="name" class="text-xs font-bold text-slate-500">Como te chamamos?</label>
                        <input
                            id="name"
                            v-model="form.name"
                            type="text"
                            class="mt-2 w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3.5 text-sm font-semibold text-slate-700 placeholder:text-slate-400 focus:border-teal-300 focus:outline-none focus:ring-2 focus:ring-teal-100 transition-colors"
                            placeholder="Ex: Gabriel Silva"
                            required
                            autofocus
                            autocomplete="name"
                        />
                        <InputError class="mt-1" :message="form.errors.name" />
                    </div>

                    <div>
                        <label for="email" class="text-xs font-bold text-slate-500">Seu e-mail</label>
                        <input
                            id="email"
                            v-model="form.email"
                            type="email"
                            class="mt-2 w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3.5 text-sm font-semibold text-slate-700 placeholder:text-slate-400 focus:border-teal-300 focus:outline-none focus:ring-2 focus:ring-teal-100 transition-colors"
                            placeholder="seuemail@exemplo.com"
                            required
                            autocomplete="username"
                        />
                        <InputError class="mt-1" :message="form.errors.email" />
                    </div>

                    <div>
                        <label for="password" class="text-xs font-bold text-slate-500">Sua senha</label>
                        <div class="relative mt-2">
                            <input
                                id="password"
                                v-model="form.password"
                                :type="showPassword ? 'text' : 'password'"
                                class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3.5 pr-12 text-sm font-semibold text-slate-700 placeholder:text-slate-400 focus:border-teal-300 focus:outline-none focus:ring-2 focus:ring-teal-100 transition-colors"
                                placeholder="Mínimo 8 caracteres"
                                required
                                autocomplete="new-password"
                            />
                            <button
                                type="button"
                                class="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 transition-colors cursor-pointer"
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
                        <ul class="mt-3 space-y-1 text-xs font-bold text-slate-500">
                            <li class="flex items-center gap-2" :class="hasMinLength ? 'text-teal-600' : 'text-slate-500'">
                                <span class="inline-flex h-4 w-4 items-center justify-center">
                                    <svg v-if="hasMinLength" class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                                        <path d="M20 6 9 17l-5-5" />
                                    </svg>
                                    <span v-else class="h-2 w-2 rounded-full bg-slate-300"></span>
                                </span>
                                8+ caracteres
                            </li>
                            <li class="flex items-center gap-2" :class="hasUppercase ? 'text-teal-600' : 'text-slate-500'">
                                <span class="inline-flex h-4 w-4 items-center justify-center">
                                    <svg v-if="hasUppercase" class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                                        <path d="M20 6 9 17l-5-5" />
                                    </svg>
                                    <span v-else class="h-2 w-2 rounded-full bg-slate-300"></span>
                                </span>
                                1 letra maiúscula
                            </li>
                            <li class="flex items-center gap-2" :class="hasNumber ? 'text-teal-600' : 'text-slate-500'">
                                <span class="inline-flex h-4 w-4 items-center justify-center">
                                    <svg v-if="hasNumber" class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                                        <path d="M20 6 9 17l-5-5" />
                                    </svg>
                                    <span v-else class="h-2 w-2 rounded-full bg-slate-300"></span>
                                </span>
                                1 número
                            </li>
                        </ul>
                    </div>

                    <div>
                        <label for="password_confirmation" class="text-xs font-bold text-slate-500">Confirma a senha</label>
                        <div class="relative mt-2">
                            <input
                                id="password_confirmation"
                                v-model="form.password_confirmation"
                                :type="showConfirm ? 'text' : 'password'"
                                class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3.5 pr-12 text-sm font-semibold text-slate-700 placeholder:text-slate-400 focus:border-teal-300 focus:outline-none focus:ring-2 focus:ring-teal-100 transition-colors"
                                placeholder="Repete ela aqui"
                                required
                                autocomplete="new-password"
                            />
                            <button
                                type="button"
                                class="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 transition-colors cursor-pointer"
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
                        class="group flex h-14 w-full items-center justify-center gap-3 rounded-2xl bg-slate-950 text-sm font-extrabold text-white shadow-[0_20px_35px_-22px_rgba(15,23,42,0.7)] hover:bg-slate-800 hover:shadow-[0_20px_35px_-22px_rgba(15,23,42,0.9)] hover:-translate-y-0.5 transition-all duration-300"
                        :class="{ 'opacity-70': form.processing }"
                        :disabled="form.processing"
                    >
                        Criar minha conta agora
                        <span class="flex items-center text-teal-400 group-hover:translate-x-1 transition-transform">
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
                    <Link :href="route('login')" class="font-extrabold text-teal-600 hover:text-teal-500 transition-colors">Voltar pro login</Link>
                </div>
            </div>
        </div>
    </AuthShell>
</template>
