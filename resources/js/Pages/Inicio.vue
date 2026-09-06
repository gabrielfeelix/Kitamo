<script setup lang="ts">
/**
 * Início do "Quitar" — spec §3.1/§3.2.
 * Versão mínima: o número e o horizonte do mês. O item 4 do
 * HANDOFF-QUITAR.md expande (próxima parcela, card de voz, sino).
 */
import { computed } from 'vue';

type Diario = {
    diario: number;
    fecha: boolean;
    falta_por_mes: number;
    quitacao_label: string | null;
    tem_dividas: boolean;
};

type Dia = {
    data: string; dia: number; saldo: number;
    estado: 'tranquilo' | 'atencao' | 'aperto';
    motivo: string | null;
    lancamentos: Array<{ nome: string; valor: number; tipo: string }>;
};

const props = defineProps<{
    diario: Diario;
    mes: { dias: Dia[]; primeiro_dia_apertado: string | null; saldo_final: number };
}>();

const dinheiro = (v: number) =>
    v.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });

const frase = computed(() => {
    if (!props.diario.fecha) return 'hoje a conta não fecha';
    if (props.diario.quitacao_label) return `pra quitar até ${props.diario.quitacao_label}`;
    return 'pra hoje';
});
</script>

<template>
    <div class="inicio" :data-cor="diario.fecha ? 'tranquilo' : 'aperto'">
        <header class="topo">
            <p class="rotulo">{{ frase }}</p>

            <template v-if="diario.fecha">
                <p class="numero">{{ dinheiro(diario.diario) }}</p>
                <p class="apoio">é o seu diário</p>
            </template>
            <template v-else>
                <p class="numero">{{ dinheiro(diario.falta_por_mes) }}</p>
                <p class="apoio">é o que falta por mês pra fechar</p>
            </template>
        </header>

        <section class="corpo">
            <h2>Seu mês</h2>
            <ol class="dias">
                <li v-for="d in mes.dias" :key="d.data" class="dia" :data-estado="d.estado">
                    <span class="dia-num">{{ d.dia }}</span>
                    <span class="dia-txt">
                        <template v-if="d.lancamentos.length">
                            <b v-for="(l, i) in d.lancamentos" :key="i">{{ l.nome }}</b>
                        </template>
                        <i v-if="d.motivo">{{ d.motivo }}</i>
                    </span>
                    <span class="dia-saldo">{{ dinheiro(d.saldo) }}</span>
                </li>
            </ol>
        </section>
    </div>
</template>

<style scoped>
.inicio { min-height: 100dvh; background: var(--kitamo-bg, #FAF7F2); }

.topo {
    padding: 40px 24px 48px;
    background: var(--fundo);
    color: var(--sobre);
    border-radius: 0 0 24px 24px;
}

.inicio[data-cor='tranquilo'] .topo { --fundo: rgb(var(--kitamo-tranquilo)); --sobre: #fff; }
.inicio[data-cor='aperto'] .topo { --fundo: rgb(var(--kitamo-aperto)); --sobre: #fff; }

.rotulo { font-size: 15px; opacity: 0.9; margin: 0 0 4px; }
.numero { font-size: clamp(48px, 15vw, 72px); font-weight: 800; margin: 0; line-height: 1; }
.apoio { font-size: 16px; opacity: 0.9; margin: 8px 0 0; }

.corpo { padding: 24px; }
h2 { font-size: 18px; font-weight: 700; margin: 0 0 12px; color: #1C1917; }

.dias { list-style: none; margin: 0; padding: 0; }

.dia {
    display: grid;
    grid-template-columns: 32px 1fr auto;
    gap: 12px;
    align-items: baseline;
    padding: 10px 12px;
    border-radius: 12px;
    background: #fff;
    margin-bottom: 6px;
    font-size: 15px;
}

.dia[data-estado='atencao'] { background: rgb(var(--kitamo-atencao-claro)); }
.dia[data-estado='aperto'] { background: rgb(var(--kitamo-aperto-claro)); }

.dia-num { font-weight: 700; color: #57534E; }
.dia-txt { display: flex; flex-direction: column; gap: 2px; }
.dia-txt b { font-weight: 600; color: #1C1917; }
.dia-txt i { font-style: normal; font-size: 13px; color: #78716C; }
.dia-saldo { font-variant-numeric: tabular-nums; color: #57534E; }
</style>
