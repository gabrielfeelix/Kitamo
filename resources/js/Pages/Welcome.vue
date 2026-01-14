<script setup lang="ts">
import { computed, ref } from 'vue';
import { Head, Link } from '@inertiajs/vue3';

defineProps<{
    canLogin?: boolean;
    canRegister?: boolean;
}>();

type Billing = 'monthly' | 'annual';
const billing = ref<Billing>('monthly');

const prices = computed(() => {
    const annualDiscount = 0.8;
    const multiplier = billing.value === 'annual' ? annualDiscount : 1;

    return {
        starter: Math.round(0 * multiplier),
        pro: +(19.9 * multiplier).toFixed(2),
        family: +(29.9 * multiplier).toFixed(2),
    };
});

function formatBRL(value: number) {
    if (value === 0) return 'R$ 0';
    return new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL',
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
    }).format(value);
}
</script>

<template>
    <Head title="Kitamo" />

    <div class="relative overflow-hidden bg-slate-50">
        <div class="pointer-events-none absolute inset-0 -z-10">
            <div
                class="blob -left-24 top-16 h-[420px] w-[420px] bg-teal-300"
            />
            <div
                class="blob -right-24 top-0 h-[520px] w-[520px] bg-blue-300"
            />
            <div
                class="blob left-1/2 top-[420px] h-[520px] w-[520px] -translate-x-1/2 bg-teal-200"
            />
        </div>

        <header class="sticky top-0 z-50">
            <div class="glass-nav">
                <div class="mx-auto max-w-7xl px-6">
                    <div class="flex h-16 items-center justify-between">
                        <a href="/" class="flex items-center gap-3">
                            <span
                                class="inline-flex h-9 w-9 items-center justify-center rounded-xl bg-teal-500 font-extrabold text-white"
                                >K</span
                            >
                            <span
                                class="text-lg font-extrabold tracking-tight text-slate-900"
                                >Kitamo</span
                            >
                        </a>

                        <nav
                            class="hidden items-center gap-8 text-sm font-bold text-slate-600 md:flex"
                        >
                            <a
                                class="transition hover:text-slate-900"
                                href="#vantagens"
                                >Vantagens</a
                            >
                            <a
                                class="transition hover:text-slate-900"
                                href="#quem-usa"
                                >Quem usa</a
                            >
                            <a
                                class="transition hover:text-slate-900"
                                href="#planos"
                                >Planos</a
                            >
                        </nav>

                        <div class="flex items-center gap-3">
                            <Link
                                v-if="canLogin"
                                href="/login"
                                class="hidden text-sm font-bold text-slate-600 transition hover:text-slate-900 sm:inline-flex"
                                >Entrar</Link
                            >
                            <Link
                                v-if="canRegister"
                                href="/login"
                                class="btn-primary px-5 py-2.5 text-sm"
                                >Entrar</Link
                            >
                        </div>
                    </div>
                </div>
            </div>
        </header>

        <main>
            <section class="mx-auto max-w-7xl px-6 py-20 md:py-28">
                <div class="grid items-center gap-14 lg:grid-cols-2">
                    <div
                        class="rounded-[32px] border border-white/70 bg-gradient-to-br from-teal-100 via-teal-50 to-sky-100 px-7 py-10 shadow-sm sm:p-10 lg:rounded-none lg:border-0 lg:bg-transparent lg:p-0 lg:shadow-none"
                    >
                        <div
                            class="inline-flex items-center gap-2 rounded-full border border-white/60 bg-white/70 px-4 py-2 text-xs font-bold uppercase tracking-wider text-slate-600 shadow-sm"
                        >
                            <span
                                class="inline-flex h-2 w-2 rounded-full bg-teal-400"
                            />
                            Novo app 2.0 disponível
                        </div>

                        <h1
                            class="mt-7 text-[44px] font-extrabold leading-[1.05] tracking-tight text-slate-900 sm:text-5xl lg:text-6xl"
                        >
                            O fim do mês não<br />
                            precisa ser um<br />
                            <span class="text-teal-500">filme de terror.</span>
                        </h1>

                        <p
                            class="mt-6 max-w-xl text-[15px] font-medium leading-relaxed text-slate-600"
                        >
                            Chega de suar frio no dia 20. O Kitamo organiza tua
                            grana, te avisa antes do boleto vencer e ainda te
                            mostra se vai sobrar pro churrasco.
                        </p>

                        <div class="mt-10 flex flex-col gap-4 sm:flex-row">
                            <Link
                                href="/register"
                                class="btn-primary w-full justify-center py-4 sm:w-auto"
                            >
                                <span
                                    class="inline-flex h-8 w-8 items-center justify-center rounded-xl bg-white/15"
                                >
                                    <svg
                                        width="16"
                                        height="16"
                                        viewBox="0 0 24 24"
                                        fill="none"
                                        xmlns="http://www.w3.org/2000/svg"
                                        class="text-white"
                                    >
                                        <path
                                            d="M21.35 11.1H12v2.9h5.35c-.8 2.35-3.05 3.9-5.35 3.9A6 6 0 1 1 12 6c1.53 0 2.92.57 3.98 1.5l2.02-2.02A9 9 0 1 0 21 12c0-.32-.03-.63-.08-.9Z"
                                            fill="currentColor"
                                        />
                                    </svg>
                                </span>
                                Cadastrar com Google
                            </Link>
                            <a
                                href="#vantagens"
                                class="btn-outline w-full justify-center py-4 sm:w-auto"
                            >
                                <span
                                    class="inline-flex h-8 w-8 items-center justify-center rounded-xl bg-slate-100"
                                >
                                    <svg
                                        width="16"
                                        height="16"
                                        viewBox="0 0 24 24"
                                        fill="none"
                                        xmlns="http://www.w3.org/2000/svg"
                                        class="text-slate-700"
                                    >
                                        <path
                                            d="M9 18V6l11 6-11 6Z"
                                            fill="currentColor"
                                        />
                                    </svg>
                                </span>
                                Ver como funciona
                            </a>
                        </div>

                        <div
                            class="mt-8 flex items-center gap-2 text-[11px] font-bold uppercase tracking-wider text-slate-400/80"
                        >
                            <svg
                                width="14"
                                height="14"
                                viewBox="0 0 24 24"
                                fill="none"
                                xmlns="http://www.w3.org/2000/svg"
                            >
                                <path
                                    d="M12 2 4 5v6c0 5 3.4 9.7 8 11 4.6-1.3 8-6 8-11V5l-8-3Z"
                                    stroke="currentColor"
                                    stroke-width="2"
                                    stroke-linejoin="round"
                                />
                            </svg>
                            Seus dados blindados & 100% seguros
                        </div>
                    </div>

                    <div class="relative hidden lg:block">
                        <div class="floaty">
                            <div class="mockup-phone">
                                <div
                                    class="relative h-full w-full overflow-hidden rounded-[34px] bg-white"
                                >
                                    <div class="px-6 pb-6 pt-12">
                                        <div
                                            class="flex items-center justify-between"
                                        >
                                            <div
                                                class="h-10 w-10 rounded-full bg-slate-100"
                                            />
                                            <div
                                                class="flex h-10 w-10 items-center justify-center rounded-full border border-slate-200"
                                            >
                                                <svg
                                                    width="18"
                                                    height="18"
                                                    viewBox="0 0 24 24"
                                                    fill="none"
                                                    xmlns="http://www.w3.org/2000/svg"
                                                    class="text-slate-400"
                                                >
                                                    <path
                                                        d="M12 22a2 2 0 0 0 2-2H10a2 2 0 0 0 2 2Zm6-6V11a6 6 0 1 0-12 0v5l-2 2v1h16v-1l-2-2Z"
                                                        fill="currentColor"
                                                    />
                                                </svg>
                                            </div>
                                        </div>

                                        <div class="mt-6">
                                            <p
                                                class="text-xs font-bold uppercase tracking-wider text-slate-400"
                                            >
                                                Saldo disponível
                                            </p>
                                            <p
                                                class="mt-1 text-3xl font-extrabold tracking-tight text-slate-900"
                                            >
                                                R$ 2.150
                                            </p>
                                        </div>

                                        <div class="mt-6 space-y-4">
                                            <div
                                                class="flex items-center gap-3 rounded-2xl border border-slate-100 bg-slate-50 p-4"
                                            >
                                                <div
                                                    class="flex h-10 w-10 items-center justify-center rounded-2xl bg-orange-100 text-orange-500"
                                                >
                                                    <svg
                                                        width="18"
                                                        height="18"
                                                        viewBox="0 0 24 24"
                                                        fill="none"
                                                        xmlns="http://www.w3.org/2000/svg"
                                                    >
                                                        <path
                                                            d="M7 18c-1.1 0-2-.9-2-2V6h2V4h2v2h6V4h2v2h2v10c0 1.1-.9 2-2 2H7Zm2.2-4h5.6l1.2-6H8l1.2 6Z"
                                                            fill="currentColor"
                                                        />
                                                    </svg>
                                                </div>
                                                <div class="flex-1">
                                                    <div
                                                        class="h-2 w-24 rounded-full bg-slate-200"
                                                    />
                                                    <div
                                                        class="mt-2 h-2 w-40 rounded-full bg-slate-100"
                                                    />
                                                </div>
                                            </div>

                                            <div
                                                class="flex items-center gap-3 rounded-2xl border border-slate-100 bg-slate-50 p-4"
                                            >
                                                <div
                                                    class="flex h-10 w-10 items-center justify-center rounded-2xl bg-blue-100 text-blue-500"
                                                >
                                                    <svg
                                                        width="18"
                                                        height="18"
                                                        viewBox="0 0 24 24"
                                                        fill="none"
                                                        xmlns="http://www.w3.org/2000/svg"
                                                    >
                                                        <path
                                                            d="M12 3 2 12h3v9h6v-6h2v6h6v-9h3L12 3Z"
                                                            fill="currentColor"
                                                        />
                                                    </svg>
                                                </div>
                                                <div class="flex-1">
                                                    <div
                                                        class="h-2 w-24 rounded-full bg-slate-200"
                                                    />
                                                    <div
                                                        class="mt-2 h-2 w-40 rounded-full bg-slate-100"
                                                    />
                                                </div>
                                            </div>
                                        </div>

                                        <div
                                            class="mt-7 rounded-2xl bg-teal-200/70 p-4 text-white shadow-[0_18px_35px_-15px_rgba(20,184,166,0.60)]"
                                        >
                                            <div
                                                class="text-xs font-extrabold uppercase tracking-wider text-teal-700"
                                            >
                                                Meta atingida
                                            </div>
                                            <div
                                                class="mt-1 flex items-center gap-2 text-sm font-extrabold text-teal-900"
                                            >
                                                <span
                                                    class="inline-flex h-5 w-5 items-center justify-center rounded-full bg-white/70 text-teal-700"
                                                >
                                                    <svg
                                                        width="14"
                                                        height="14"
                                                        viewBox="0 0 24 24"
                                                        fill="none"
                                                        xmlns="http://www.w3.org/2000/svg"
                                                    >
                                                        <path
                                                            d="m20 6-11 11-5-5"
                                                            stroke="currentColor"
                                                            stroke-width="3"
                                                            stroke-linecap="round"
                                                            stroke-linejoin="round"
                                                        />
                                                    </svg>
                                                </span>
                                                Reserva de Emergência
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <section class="border-y border-slate-100 bg-white">
                <div class="mx-auto max-w-7xl px-6 py-10">
                    <p
                        class="text-center text-xs font-extrabold uppercase tracking-[0.2em] text-slate-400"
                    >
                        A escolha de quem quer paz financeira
                    </p>
                    <div
                        class="mx-auto mt-6 grid max-w-sm grid-cols-2 gap-x-10 gap-y-4 text-sm font-extrabold text-slate-300 sm:max-w-none sm:grid-cols-4 sm:justify-items-center"
                    >
                        <span class="inline-flex items-center gap-2">
                            <svg
                                aria-hidden="true"
                                width="16"
                                height="16"
                                viewBox="0 0 24 24"
                                fill="none"
                                xmlns="http://www.w3.org/2000/svg"
                                class="text-slate-300"
                            >
                                <path
                                    d="M4 14c5-1 8-4 9-9 3 3 4 7 3 11l-1 3-3-1c-4-1-7-4-8-8Z"
                                    fill="currentColor"
                                    opacity="0.9"
                                />
                                <path
                                    d="M13 5c3 0 6 3 6 6"
                                    stroke="currentColor"
                                    stroke-width="2"
                                    stroke-linecap="round"
                                />
                            </svg>
                            StartupOne
                        </span>
                        <span class="inline-flex items-center gap-2">
                            <svg
                                aria-hidden="true"
                                width="16"
                                height="16"
                                viewBox="0 0 24 24"
                                fill="none"
                                xmlns="http://www.w3.org/2000/svg"
                                class="text-slate-300"
                            >
                                <path
                                    d="M13 2 3 14h7l-1 8 12-14h-7l-1-6Z"
                                    fill="currentColor"
                                    opacity="0.9"
                                />
                            </svg>
                            FastMoney
                        </span>
                        <span class="inline-flex items-center gap-2">
                            <svg
                                aria-hidden="true"
                                width="16"
                                height="16"
                                viewBox="0 0 24 24"
                                fill="none"
                                xmlns="http://www.w3.org/2000/svg"
                                class="text-slate-300"
                            >
                                <path
                                    d="M12 3 2 8l10 5 10-5-10-5Z"
                                    fill="currentColor"
                                    opacity="0.9"
                                />
                                <path
                                    d="M2 12l10 5 10-5"
                                    stroke="currentColor"
                                    stroke-width="2"
                                    stroke-linecap="round"
                                    opacity="0.9"
                                />
                                <path
                                    d="M2 16l10 5 10-5"
                                    stroke="currentColor"
                                    stroke-width="2"
                                    stroke-linecap="round"
                                    opacity="0.6"
                                />
                            </svg>
                            StackFin
                        </span>
                        <span class="inline-flex items-center gap-2">
                            <svg
                                aria-hidden="true"
                                width="16"
                                height="16"
                                viewBox="0 0 24 24"
                                fill="none"
                                xmlns="http://www.w3.org/2000/svg"
                                class="text-slate-300"
                            >
                                <path
                                    d="M12 22a10 10 0 1 0 0-20 10 10 0 0 0 0 20Z"
                                    stroke="currentColor"
                                    stroke-width="2"
                                    opacity="0.9"
                                />
                                <path
                                    d="M2 12h20"
                                    stroke="currentColor"
                                    stroke-width="2"
                                    opacity="0.6"
                                />
                                <path
                                    d="M12 2c3 3 4.5 7 4.5 10S15 19 12 22c-3-3-4.5-7-4.5-10S9 5 12 2Z"
                                    stroke="currentColor"
                                    stroke-width="2"
                                    opacity="0.6"
                                />
                            </svg>
                            GlobalBank
                        </span>
                    </div>
                </div>
            </section>

            <section id="vantagens" class="mx-auto max-w-7xl px-6 py-24">
                <div class="text-center">
                    <h2
                        class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl"
                    >
                        Menos planilha,<br class="sm:hidden" />
                        mais vida real.
                    </h2>
                    <p
                        class="mx-auto mt-4 max-w-2xl text-base font-medium leading-relaxed text-slate-600"
                    >
                        O Kitamo não é só um app de anotar gastos. É o teu
                        copiloto pra não deixar o dinheiro sumir
                        misteriosamente.
                    </p>
                </div>

                <div
                    class="mt-14 grid gap-6 md:grid-cols-3"
                >
                    <div class="card-kitamo card-kitamo-hover p-8">
                        <div
                            class="flex h-12 w-12 items-center justify-center rounded-2xl bg-teal-50 text-teal-600"
                        >
                            <svg
                                width="20"
                                height="20"
                                viewBox="0 0 24 24"
                                fill="none"
                                xmlns="http://www.w3.org/2000/svg"
                            >
                                <path
                                    d="M12 5c7 0 10 7 10 7s-3 7-10 7S2 12 2 12s3-7 10-7Zm0 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8Z"
                                    fill="currentColor"
                                />
                            </svg>
                        </div>
                        <h3
                            class="mt-6 text-lg font-extrabold tracking-tight text-slate-900"
                        >
                            Visão de Raio-X
                        </h3>
                        <p
                            class="mt-3 text-sm font-medium leading-relaxed text-slate-600"
                        >
                            Saiba exatamente pra onde foi aquele pix de ontem.
                            Categorias automáticas e gráficos simples.
                        </p>
                    </div>

                    <div class="card-kitamo card-kitamo-hover p-8">
                        <div
                            class="flex h-12 w-12 items-center justify-center rounded-2xl bg-amber-50 text-amber-500"
                        >
                            <svg
                                width="20"
                                height="20"
                                viewBox="0 0 24 24"
                                fill="none"
                                xmlns="http://www.w3.org/2000/svg"
                            >
                                <path
                                    d="M12 22a2 2 0 0 0 2-2H10a2 2 0 0 0 2 2Zm6-6V11a6 6 0 1 0-12 0v5l-2 2v1h16v-1l-2-2Z"
                                    fill="currentColor"
                                />
                            </svg>
                        </div>
                        <h3
                            class="mt-6 text-lg font-extrabold tracking-tight text-slate-900"
                        >
                            Notificações que Salvam
                        </h3>
                        <p
                            class="mt-3 text-sm font-medium leading-relaxed text-slate-600"
                        >
                            “Ei, o boleto da internet vence amanhã!”. A gente te
                            avisa antes dos juros chegarem.
                        </p>
                    </div>

                    <div class="card-kitamo card-kitamo-hover p-8">
                        <div
                            class="flex h-12 w-12 items-center justify-center rounded-2xl bg-purple-50 text-purple-500"
                        >
                            <svg
                                width="20"
                                height="20"
                                viewBox="0 0 24 24"
                                fill="none"
                                xmlns="http://www.w3.org/2000/svg"
                            >
                                <path
                                    d="M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20Zm0 4a6 6 0 1 1 0 12 6 6 0 0 1 0-12Z"
                                    fill="currentColor"
                                />
                                <path
                                    d="M12 9a3 3 0 1 0 0 6 3 3 0 0 0 0-6Z"
                                    fill="currentColor"
                                />
                            </svg>
                        </div>
                        <h3
                            class="mt-6 text-lg font-extrabold tracking-tight text-slate-900"
                        >
                            Metas Possíveis
                        </h3>
                        <p
                            class="mt-3 text-sm font-medium leading-relaxed text-slate-600"
                        >
                            Cria a meta, define quanto vai guardar e acompanha
                            a barra encher. Satisfatório demais.
                        </p>
                    </div>
                </div>
            </section>

            <section class="mx-auto max-w-7xl px-6 pb-24">
                <div class="text-left">
                    <h2
                        class="text-4xl font-extrabold tracking-tight text-slate-900 sm:text-5xl"
                    >
                        Tudo o que você precisa.<br />
                        <span class="text-teal-500">E um pouco mais.</span>
                    </h2>
                    <p
                        class="mt-4 max-w-2xl text-base font-medium leading-relaxed text-slate-600"
                    >
                        Centralize sua vida financeira e planeje o futuro sem
                        dor de cabeça.
                    </p>
                </div>

                <div class="mt-14 grid gap-6 lg:grid-cols-3">
                    <div
                        class="card-kitamo relative overflow-hidden bg-gradient-to-br from-slate-950 to-slate-900 p-10 text-white lg:col-span-1 lg:row-span-2"
                    >
                        <div
                            aria-hidden="true"
                            class="pointer-events-none absolute -right-10 top-10 hidden h-44 w-44 rounded-full bg-white/10 blur-2xl sm:block"
                        />
                        <div
                            aria-hidden="true"
                            class="pointer-events-none absolute -right-6 top-8 hidden opacity-60 sm:block"
                        >
                            <svg
                                width="160"
                                height="160"
                                viewBox="0 0 160 160"
                                fill="none"
                                xmlns="http://www.w3.org/2000/svg"
                            >
                                <path
                                    d="M64 30c-14 0-26 12-26 26 0 7 3 13 8 18-4 3-7 9-7 15 0 8 4 15 10 19-2 3-3 6-3 10 0 10 8 18 18 18h36c15 0 26-11 26-26 0-10-6-19-14-23 2-3 3-6 3-10 0-10-8-18-18-18h-1c-3-14-16-24-32-24Z"
                                    fill="white"
                                    opacity="0.12"
                                />
                                <path
                                    d="M54 66c4-6 13-10 22-10"
                                    stroke="white"
                                    stroke-width="6"
                                    stroke-linecap="round"
                                    opacity="0.12"
                                />
                                <path
                                    d="M52 96c6-6 16-10 28-10"
                                    stroke="white"
                                    stroke-width="6"
                                    stroke-linecap="round"
                                    opacity="0.10"
                                />
                            </svg>
                        </div>
                        <div
                            class="flex h-12 w-12 items-center justify-center rounded-2xl bg-teal-500/20 text-teal-200"
                        >
                            <svg
                                width="22"
                                height="22"
                                viewBox="0 0 24 24"
                                fill="none"
                                xmlns="http://www.w3.org/2000/svg"
                            >
                                <path
                                    d="M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20Zm1 14.5h-2V11h2v5.5Zm0-7.5h-2V7h2v2Z"
                                    fill="currentColor"
                                />
                            </svg>
                        </div>
                        <h3
                            class="mt-6 text-2xl font-extrabold tracking-tight"
                        >
                            IA que pensa por você
                        </h3>
                        <p class="mt-4 text-sm/relaxed text-white/80">
                            Nossa inteligência artificial analisa seus gastos e
                            sugere cortes inteligentes. “Ei Gabriel, se você
                            reduzir o iFood em 10%, sobra pra viagem.”
                        </p>

                        <div
                            class="mt-10 rounded-2xl border border-white/10 bg-white/5 p-5"
                        >
                            <div
                                class="flex items-center gap-2 text-xs font-extrabold uppercase tracking-wider text-emerald-300"
                            >
                                <span
                                    class="h-2 w-2 rounded-full bg-emerald-300"
                                />
                                Dica ativa
                            </div>
                            <p class="mt-3 text-sm text-white/85">
                                “Você gastou R$ 200 a menos em Uber esse mês.
                                Que tal investir essa sobra?”
                            </p>
                        </div>
                    </div>

                    <div class="card-kitamo card-kitamo-hover p-10">
                        <div
                            class="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-purple-50 text-purple-500"
                        >
                            <svg
                                width="20"
                                height="20"
                                viewBox="0 0 24 24"
                                fill="none"
                                xmlns="http://www.w3.org/2000/svg"
                            >
                                <path
                                    d="M7 11a4 4 0 1 1 8 0 4 4 0 0 1-8 0Zm-3 9a6 6 0 0 1 16 0H4Z"
                                    fill="currentColor"
                                />
                            </svg>
                        </div>
                        <h3
                            class="mt-6 text-center text-lg font-extrabold tracking-tight text-slate-900"
                        >
                            Rolê em Grupo
                        </h3>
                        <p
                            class="mx-auto mt-3 max-w-xs text-center text-sm font-medium leading-relaxed text-slate-600"
                        >
                            Planeje a viagem com a galera ou divida as contas de
                            casa sem briga.
                        </p>
                        <div class="mt-8 flex justify-center">
                            <div class="relative h-16 w-16">
                                <div
                                    class="absolute left-0 top-0 h-10 w-10 rounded-full bg-slate-200 ring-4 ring-white"
                                />
                                <div
                                    class="absolute left-6 top-6 h-10 w-10 rounded-full bg-slate-300 ring-4 ring-white"
                                />
                                <div
                                    class="absolute left-10 top-2 h-10 w-10 rounded-full bg-slate-100 ring-4 ring-white"
                                />
                            </div>
                        </div>
                        <div class="mt-6 flex justify-center">
                            <span
                                class="rounded-full border border-purple-100 bg-purple-50 px-4 py-2 text-xs font-extrabold text-purple-700"
                                >Churrasco: R$ 45,00 cada</span
                            >
                        </div>
                    </div>

                    <div class="grid gap-6">
                        <div class="card-kitamo card-kitamo-hover p-10">
                            <div
                                class="flex h-12 w-12 items-center justify-center rounded-2xl bg-blue-50 text-blue-500"
                            >
                                <svg
                                    width="20"
                                    height="20"
                                    viewBox="0 0 24 24"
                                    fill="none"
                                    xmlns="http://www.w3.org/2000/svg"
                                >
                                    <path
                                        d="M4 19V5h2v14H4Zm14-7a6 6 0 0 0-6 6h10a2 2 0 0 0 2-2V5h-2v7h-4Z"
                                        fill="currentColor"
                                    />
                                    <path
                                        d="M8 17a5 5 0 0 1 10 0H8Z"
                                        fill="currentColor"
                                    />
                                </svg>
                            </div>
                            <h3
                                class="mt-6 text-lg font-extrabold tracking-tight text-slate-900"
                            >
                                Relatórios
                            </h3>
                            <p
                                class="mt-3 text-sm font-medium leading-relaxed text-slate-600"
                            >
                                Gráficos que você entende em 3 segundos. Nada
                                de “economês”.
                            </p>
                        </div>

                        <div class="card-kitamo card-kitamo-hover p-10">
                            <div
                                class="flex h-12 w-12 items-center justify-center rounded-2xl bg-orange-50 text-orange-500"
                            >
                                <svg
                                    width="20"
                                    height="20"
                                    viewBox="0 0 24 24"
                                    fill="none"
                                    xmlns="http://www.w3.org/2000/svg"
                                >
                                    <path
                                        d="M7 6h14v2H7V6ZM3 7a2 2 0 1 0 0 .01V7Zm4 5h14v2H7v-2ZM3 13a2 2 0 1 0 0 .01V13Zm4 5h14v2H7v-2ZM3 19a2 2 0 1 0 0 .01V19Z"
                                        fill="currentColor"
                                    />
                                </svg>
                            </div>
                            <h3
                                class="mt-6 text-lg font-extrabold tracking-tight text-slate-900"
                            >
                                Gestão Total
                            </h3>
                            <p
                                class="mt-3 text-sm font-medium leading-relaxed text-slate-600"
                            >
                                Controle suas contas, cartões e metas em um
                                único lugar.
                            </p>
                        </div>
                    </div>
                </div>
            </section>

            <section id="quem-usa" class="mx-auto max-w-7xl px-6 py-24">
                <div class="flex items-start justify-between gap-6 sm:items-center">
                    <div>
                        <h2
                            class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl"
                        >
                            Quem usa, curte.
                        </h2>
                        <p
                            class="mt-3 max-w-xl text-base font-medium leading-relaxed text-slate-600"
                        >
                            Não é papo de vendedor. Olha o que a galera tá
                            falando.
                        </p>
                    </div>

                    <div class="flex items-center gap-3">
                        <button
                            type="button"
                            class="inline-flex h-10 w-10 items-center justify-center rounded-full border border-slate-200 bg-white text-slate-700 shadow-sm"
                        >
                            <span class="sr-only">Anterior</span>
                            <svg
                                width="18"
                                height="18"
                                viewBox="0 0 24 24"
                                fill="none"
                                xmlns="http://www.w3.org/2000/svg"
                            >
                                <path
                                    d="M15 18 9 12l6-6"
                                    stroke="currentColor"
                                    stroke-width="2.5"
                                    stroke-linecap="round"
                                    stroke-linejoin="round"
                                />
                            </svg>
                        </button>
                        <button
                            type="button"
                            class="inline-flex h-10 w-10 items-center justify-center rounded-full bg-slate-900 text-white shadow-sm"
                        >
                            <span class="sr-only">Próximo</span>
                            <svg
                                width="18"
                                height="18"
                                viewBox="0 0 24 24"
                                fill="none"
                                xmlns="http://www.w3.org/2000/svg"
                            >
                                <path
                                    d="m9 18 6-6-6-6"
                                    stroke="currentColor"
                                    stroke-width="2.5"
                                    stroke-linecap="round"
                                    stroke-linejoin="round"
                                />
                            </svg>
                        </button>
                    </div>
                </div>

                <div class="mt-12 grid gap-6 lg:grid-cols-2">
                    <div class="card-kitamo p-10">
                        <div class="flex items-center gap-1 text-amber-400">
                            <span>★</span><span>★</span><span>★</span
                            ><span>★</span><span>★</span>
                        </div>
                        <p
                            class="mt-6 text-lg font-medium italic leading-relaxed text-slate-900"
                        >
                            “Cara, eu sempre terminava o mês no vermelho. Com o
                            Kitamo eu vi que gastava R$ 400 só em café e Uber.
                            Ajustei isso e sobrou pra investir.”
                        </p>
                        <div class="mt-8 flex items-center gap-4">
                            <div
                                class="flex h-12 w-12 items-center justify-center rounded-full bg-slate-200 text-sm font-extrabold text-slate-700"
                            >
                                LM
                            </div>
                            <div>
                                <div
                                    class="text-sm font-extrabold text-slate-900"
                                >
                                    LUCAS MENDES
                                </div>
                                <div class="text-sm font-medium text-slate-500">
                                    Designer
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="card-kitamo p-10">
                        <div class="flex items-center gap-1 text-amber-400">
                            <span>★</span><span>★</span><span>★</span
                            ><span>★</span><span>★</span>
                        </div>
                        <p
                            class="mt-6 text-lg font-medium italic leading-relaxed text-slate-900"
                        >
                            “Interface limpa, direto ao ponto. O modo escuro é
                            lindo e a função de recuperação de senha foi a mais
                            rápida que já vi. Recomendo!”
                        </p>
                        <div class="mt-8 flex items-center gap-4">
                            <div
                                class="flex h-12 w-12 items-center justify-center rounded-full bg-rose-200 text-sm font-extrabold text-rose-900"
                            >
                                SF
                            </div>
                            <div>
                                <div
                                    class="text-sm font-extrabold text-slate-900"
                                >
                                    SARAH F.
                                </div>
                                <div class="text-sm font-medium text-slate-500">
                                    Dev Front-end
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <section id="planos" class="mx-auto max-w-7xl px-6 py-24">
                <div class="text-center">
                    <h2
                        class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl"
                    >
                        Investimento que se paga.
                    </h2>
                    <p
                        class="mx-auto mt-4 max-w-2xl text-base font-medium leading-relaxed text-slate-600"
                    >
                        Comece grátis e evolua conforme suas metas crescem.
                    </p>

                    <div
                        class="mx-auto mt-8 inline-flex rounded-2xl border border-slate-200 bg-white p-1 shadow-sm"
                    >
                        <button
                            type="button"
                            class="rounded-xl px-5 py-2 text-sm font-extrabold transition"
                            :class="
                                billing === 'monthly'
                                    ? 'bg-slate-100 text-slate-900'
                                    : 'text-slate-500 hover:text-slate-900'
                            "
                            @click="billing = 'monthly'"
                        >
                            Mensal
                        </button>
                        <button
                            type="button"
                            class="rounded-xl px-5 py-2 text-sm font-extrabold transition"
                            :class="
                                billing === 'annual'
                                    ? 'bg-slate-100 text-slate-900'
                                    : 'text-slate-500 hover:text-slate-900'
                            "
                            @click="billing = 'annual'"
                        >
                            Anual (-20%)
                        </button>
                    </div>
                </div>

                <div class="mt-14 grid gap-6 lg:grid-cols-3">
                    <div class="card-kitamo p-10">
                        <h3
                            class="text-lg font-extrabold tracking-tight text-slate-900"
                        >
                            Iniciante
                        </h3>
                        <div class="mt-4 flex items-end gap-2">
                            <div
                                class="text-4xl font-extrabold tracking-tight text-slate-900"
                            >
                                {{ formatBRL(prices.starter) }}
                            </div>
                            <div class="pb-1 text-sm font-bold text-slate-400">
                                /mês
                            </div>
                        </div>
                        <p class="mt-3 text-sm font-medium text-slate-600">
                            Para quem quer organizar a bagunça inicial.
                        </p>
                        <Link href="/register" class="btn-outline mt-8 w-full">
                            Começar Grátis
                        </Link>
                        <ul class="mt-8 space-y-3 text-sm font-medium">
                            <li class="flex items-center gap-3 text-slate-700">
                                <span class="text-teal-500">✓</span> Gestão de
                                gastos manual
                            </li>
                            <li class="flex items-center gap-3 text-slate-700">
                                <span class="text-teal-500">✓</span> 1 conta
                                bancária
                            </li>
                            <li class="flex items-center gap-3 text-slate-700">
                                <span class="text-teal-500">✓</span> Relatórios
                                básicos
                            </li>
                            <li class="flex items-center gap-3 text-slate-400">
                                <span class="text-slate-300">×</span> IA
                                financeira
                            </li>
                        </ul>
                    </div>

                    <div
                        class="card-kitamo overflow-hidden bg-gradient-to-br from-slate-950 to-slate-900 p-10 text-white"
                    >
                        <div
                            class="-mx-10 -mt-10 mb-8 flex justify-center bg-teal-500 py-2 text-xs font-extrabold uppercase tracking-[0.2em]"
                        >
                            Mais popular
                        </div>
                        <h3 class="text-lg font-extrabold tracking-tight">
                            Mestre da Grana
                        </h3>
                        <div class="mt-4 flex items-end gap-2">
                            <div class="text-4xl font-extrabold tracking-tight">
                                {{ formatBRL(prices.pro) }}
                            </div>
                            <div class="pb-1 text-sm font-bold text-white/60">
                                /mês
                            </div>
                        </div>
                        <p class="mt-3 text-sm font-medium text-white/70">
                            Para quem quer dominar o jogo e investir.
                        </p>
                        <Link
                            href="/register"
                            class="btn-primary mt-8 w-full !bg-teal-500 !hover:bg-teal-700"
                        >
                            Quero ser Pro
                        </Link>
                        <ul class="mt-8 space-y-3 text-sm font-medium">
                            <li class="flex items-center gap-3 text-white/85">
                                <span class="text-teal-300">✓</span> Tudo do
                                Free
                            </li>
                            <li class="flex items-center gap-3 text-white/85">
                                <span class="text-teal-300">✓</span> Contas
                                ilimitadas
                            </li>
                            <li class="flex items-center gap-3 text-white/85">
                                <span class="text-teal-300">✓</span> IA
                                Assistente Pessoal
                            </li>
                            <li class="flex items-center gap-3 text-white/85">
                                <span class="text-teal-300">✓</span> Planejamento
                                com Amigos
                            </li>
                        </ul>
                    </div>

                    <div class="card-kitamo p-10">
                        <h3
                            class="text-lg font-extrabold tracking-tight text-slate-900"
                        >
                            Família
                        </h3>
                        <div class="mt-4 flex items-end gap-2">
                            <div
                                class="text-4xl font-extrabold tracking-tight text-slate-900"
                            >
                                {{ formatBRL(prices.family) }}
                            </div>
                            <div class="pb-1 text-sm font-bold text-slate-400">
                                /mês
                            </div>
                        </div>
                        <p class="mt-3 text-sm font-medium text-slate-600">
                            Controle total para até 5 pessoas.
                        </p>
                        <Link href="/register" class="btn-outline mt-8 w-full">
                            Assinar Família
                        </Link>
                        <ul class="mt-8 space-y-3 text-sm font-medium">
                            <li class="flex items-center gap-3 text-slate-700">
                                <span class="text-teal-500">✓</span> Tudo do Pro
                            </li>
                            <li class="flex items-center gap-3 text-slate-700">
                                <span class="text-teal-500">✓</span> 5 Perfis
                                Independentes
                            </li>
                            <li class="flex items-center gap-3 text-slate-700">
                                <span class="text-teal-500">✓</span> Metas
                                Compartilhadas
                            </li>
                            <li class="flex items-center gap-3 text-slate-700">
                                <span class="text-teal-500">✓</span> Relatório
                                do Casal/Grupo
                            </li>
                        </ul>
                    </div>
                </div>
            </section>

            <section class="mx-auto max-w-7xl px-6 pb-24">
                <div
                    class="relative overflow-hidden rounded-[40px] bg-gradient-to-br from-slate-950 to-slate-900 px-8 py-16 text-center text-white md:px-16"
                >
                    <div class="pointer-events-none absolute inset-0 opacity-50">
                        <div
                            class="blob -left-20 -top-20 h-[420px] w-[420px] bg-teal-500"
                        />
                        <div
                            class="blob -right-24 -bottom-24 h-[520px] w-[520px] bg-blue-500"
                        />
                    </div>

                    <h2
                        class="relative text-3xl font-extrabold tracking-tight sm:text-4xl"
                    >
                        Bora botar ordem na casa?
                    </h2>
                    <p
                        class="relative mx-auto mt-4 max-w-2xl text-base font-medium leading-relaxed text-white/70"
                    >
                        Cria tua conta grátis em menos de 1 minuto. Sem cartão
                        de crédito, sem letras miúdas. Só lucro.
                    </p>
                    <div
                        class="relative mt-10 flex flex-wrap justify-center gap-4"
                    >
                        <Link href="/register" class="btn-primary">
                            Quero começar agora
                        </Link>
                        <a href="#quem-usa" class="btn-outline !bg-white/0 !text-white !border-white/15 hover:!bg-white/5">
                            Falar com a galera
                        </a>
                    </div>
                </div>
            </section>
        </main>

        <footer class="border-t border-slate-100 bg-white">
            <div class="mx-auto max-w-7xl px-6 py-14">
                <div class="grid gap-10 md:grid-cols-4">
                    <div>
                        <div class="flex items-center gap-3">
                            <span
                                class="inline-flex h-9 w-9 items-center justify-center rounded-xl bg-teal-500 font-extrabold text-white"
                                >K</span
                            >
                            <span
                                class="text-lg font-extrabold tracking-tight text-slate-900"
                                >Kitamo</span
                            >
                        </div>
                        <p
                            class="mt-4 max-w-xs text-sm font-medium leading-relaxed text-slate-500"
                        >
                            Feito com 💚 pra quem cansou de passar perrengue
                            financeiro.
                        </p>
                    </div>

                    <div>
                        <div
                            class="text-sm font-extrabold tracking-tight text-slate-900"
                        >
                            Produto
                        </div>
                        <ul class="mt-4 space-y-3 text-sm font-medium">
                            <li>
                                <a
                                    class="text-slate-500 hover:text-slate-900"
                                    href="#vantagens"
                                    >Funcionalidades</a
                                >
                            </li>
                            <li>
                                <a
                                    class="text-slate-500 hover:text-slate-900"
                                    href="#"
                                    >Segurança</a
                                >
                            </li>
                            <li>
                                <a
                                    class="text-slate-500 hover:text-slate-900"
                                    href="#"
                                    >App Mobile</a
                                >
                            </li>
                        </ul>
                    </div>

                    <div>
                        <div
                            class="text-sm font-extrabold tracking-tight text-slate-900"
                        >
                            Empresa
                        </div>
                        <ul class="mt-4 space-y-3 text-sm font-medium">
                            <li>
                                <a
                                    class="text-slate-500 hover:text-slate-900"
                                    href="#"
                                    >Sobre nós</a
                                >
                            </li>
                            <li>
                                <a
                                    class="text-slate-500 hover:text-slate-900"
                                    href="#"
                                    >Carreiras</a
                                >
                            </li>
                            <li>
                                <a
                                    class="text-slate-500 hover:text-slate-900"
                                    href="#"
                                    >Blog</a
                                >
                            </li>
                        </ul>
                    </div>

                    <div>
                        <div
                            class="text-sm font-extrabold tracking-tight text-slate-900"
                        >
                            Legal
                        </div>
                        <ul class="mt-4 space-y-3 text-sm font-medium">
                            <li>
                                <a
                                    class="text-slate-500 hover:text-slate-900"
                                    href="#"
                                    >Termos de Uso</a
                                >
                            </li>
                            <li>
                                <a
                                    class="text-slate-500 hover:text-slate-900"
                                    href="#"
                                    >Privacidade</a
                                >
                            </li>
                        </ul>
                    </div>
                </div>

                <div
                    class="mt-12 flex flex-col items-center justify-between gap-6 border-t border-slate-100 pt-8 text-sm font-medium text-slate-400 sm:flex-row"
                >
                    <div>© 2026 Kitamo Inc. Todos os direitos reservados.</div>
                    <div class="flex items-center gap-4 text-slate-400">
                        <a class="hover:text-slate-700" href="#" aria-label="Instagram">IG</a>
                        <a class="hover:text-slate-700" href="#" aria-label="Twitter">X</a>
                        <a class="hover:text-slate-700" href="#" aria-label="LinkedIn">IN</a>
                    </div>
                </div>
            </div>
        </footer>
    </div>
</template>
