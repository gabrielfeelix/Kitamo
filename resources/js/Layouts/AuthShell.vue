<script setup lang="ts"></script>

<template>
    <div
        class="min-h-screen bg-slate-50"
        style="--kitamo-accent: #14b8a6; --kitamo-accent-dark: #0f9f8f; --kitamo-ink: #0f172a; --kitamo-soft: #e6faf6;"
    >
        <div class="flex min-h-screen w-full items-stretch lg:p-6">
            <div class="flex w-full flex-col bg-slate-50 lg:grid lg:grid-cols-[1.1fr_0.9fr] lg:gap-6">
                <aside class="relative hidden overflow-hidden lg:flex lg:rounded-[36px] lg:bg-slate-950 lg:shadow-[0_35px_80px_-60px_rgba(15,23,42,0.55)]">
                    <div class="flex w-full p-6">
                        <div class="flex w-full overflow-hidden rounded-[28px]">
                            <slot name="aside" />
                        </div>
                    </div>
                </aside>

                <div class="relative flex flex-1 flex-col bg-slate-50 lg:rounded-[36px] lg:bg-white lg:shadow-[0_35px_80px_-60px_rgba(15,23,42,0.25)]">
                    <div class="pointer-events-none absolute -top-24 right-10 h-52 w-52 rounded-full bg-[radial-gradient(circle_at_center,rgba(20,184,166,0.16),rgba(255,255,255,0)_70%)] lg:hidden"></div>
                    <div class="pointer-events-none absolute -bottom-20 left-[-60px] h-52 w-52 rounded-full bg-[radial-gradient(circle_at_center,rgba(14,165,233,0.12),rgba(255,255,255,0)_70%)] lg:hidden"></div>

                    <div class="relative flex flex-1 flex-col px-6 pb-12 pt-10 sm:px-10 lg:px-12 lg:py-14">
                        <slot />
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>
