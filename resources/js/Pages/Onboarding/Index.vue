<script setup lang="ts">
/**
 * Onboarding do "Quitar" — spec §3.3.
 *
 * Uma pergunta por tela, tela cheia, cada passo na sua cor (paleta em
 * docs/DESIGN-KITAMO.md). Tudo pulável: quem pula chega no fim com um
 * número incompleto, não com o app travado.
 */
import { computed, ref, nextTick } from 'vue';
import { router } from '@inertiajs/vue3';

type Divida = {
    nome: string;
    saldo_atual: number | null;
    valor_parcela: number | null;
    dia_vencimento: number | null;
    parcelas_restantes: number | null;
};

const PASSOS = [
    { chave: 'divida', cor: 'aperto' },
    { chave: 'renda', cor: 'tranquilo' },
    { chave: 'dia_renda', cor: 'futuro' },
    { chave: 'gasto', cor: 'atencao' },
    { chave: 'fixas', cor: 'barro' },
    { chave: 'oferta', cor: 'tranquilo' },
] as const;

const passo = ref(0);
const enviando = ref(false);

const rendaMensal = ref<number | null>(null);
const diaRenda = ref<number | null>(null);
const gastoDiario = ref<number | null>(null);
const contasFixas = ref<number | null>(null);
const naoSeiQuantoDevo = ref(false);
const dividas = ref<Divida[]>([
    { nome: '', saldo_atual: null, valor_parcela: null, dia_vencimento: null, parcelas_restantes: null },
]);

const atual = computed(() => PASSOS[passo.value]);
const ultimo = computed(() => passo.value === PASSOS.length - 1);
const progresso = computed(() => ((passo.value + 1) / PASSOS.length) * 100);

const adicionarDivida = () => {
    dividas.value.push({
        nome: '', saldo_atual: null, valor_parcela: null,
        dia_vencimento: null, parcelas_restantes: null,
    });
};

const removerDivida = (i: number) => {
    dividas.value.splice(i, 1);
    if (dividas.value.length === 0) adicionarDivida();
};

const avancar = () => {
    if (ultimo.value) return finalizar();
    passo.value += 1;
    nextTick(() => document.getElementById('passo-titulo')?.focus());
};

const voltar = () => {
    if (passo.value > 0) passo.value -= 1;
};

const finalizar = () => {
    if (enviando.value) return;
    enviando.value = true;

    // Dívida sem nome é linha em branco que o usuário não preencheu —
    // não vira registro.
    const preenchidas = naoSeiQuantoDevo.value
        ? []
        : dividas.value.filter((d) => d.nome.trim() !== '');

    router.post('/onboarding', {
        renda_mensal: rendaMensal.value,
        dia_renda: diaRenda.value,
        gasto_diario_estimado: gastoDiario.value,
        contas_fixas_estimadas: contasFixas.value,
        dividas: preenchidas,
    }, {
        onFinish: () => { enviando.value = false; },
    });
};
</script>

<template>
    <div class="onb" :data-cor="atual.cor">
        <div class="barra" role="progressbar" :aria-valuenow="passo + 1" aria-valuemin="1" :aria-valuemax="PASSOS.length">
            <div class="barra-fill" :style="{ width: `${progresso}%` }" />
        </div>

        <main class="palco">
            <!-- 1. Quanto você deve -->
            <section v-if="atual.chave === 'divida'" class="passo">
                <h1 id="passo-titulo" tabindex="-1">Quanto você deve hoje?</h1>
                <p class="apoio">Cartão, empréstimo, crediário — o que estiver pesando.</p>

                <label class="checkbox">
                    <input v-model="naoSeiQuantoDevo" type="checkbox" />
                    <span>não sei ainda</span>
                </label>

                <div v-if="!naoSeiQuantoDevo" class="dividas">
                    <fieldset v-for="(d, i) in dividas" :key="i" class="divida">
                        <input v-model="d.nome" class="campo" type="text" placeholder="de quem? (Nubank, Itaú…)" />
                        <div class="dupla">
                            <input v-model.number="d.valor_parcela" class="campo" type="number" inputmode="decimal" placeholder="parcela R$" />
                            <input v-model.number="d.parcelas_restantes" class="campo" type="number" inputmode="numeric" placeholder="faltam quantas?" />
                        </div>
                        <input v-model.number="d.dia_vencimento" class="campo" type="number" inputmode="numeric" min="1" max="31" placeholder="vence dia" />
                        <button v-if="dividas.length > 1" type="button" class="link" @click="removerDivida(i)">remover</button>
                    </fieldset>
                    <button type="button" class="link" @click="adicionarDivida">+ tenho outra</button>
                </div>
            </section>

            <!-- 2. Renda -->
            <section v-else-if="atual.chave === 'renda'" class="passo">
                <h1 id="passo-titulo" tabindex="-1">Quanto entra por mês?</h1>
                <p class="apoio">Salário, pró-labore, o que for fixo.</p>
                <input v-model.number="rendaMensal" class="campo grande" type="number" inputmode="decimal" placeholder="R$ 0,00" />
            </section>

            <!-- 3. Dia -->
            <section v-else-if="atual.chave === 'dia_renda'" class="passo">
                <h1 id="passo-titulo" tabindex="-1">Que dia cai?</h1>
                <p class="apoio">Serve pra saber se alguma parcela vence antes.</p>
                <input v-model.number="diaRenda" class="campo grande" type="number" inputmode="numeric" min="1" max="31" placeholder="dia 5" />
            </section>

            <!-- 4. Gasto do dia a dia -->
            <section v-else-if="atual.chave === 'gasto'" class="passo">
                <h1 id="passo-titulo" tabindex="-1">Quanto sai com o dia a dia?</h1>
                <p class="apoio">Vai no feeling: mercado, padaria, iFood… por dia.</p>
                <input v-model.number="gastoDiario" class="campo grande" type="number" inputmode="decimal" placeholder="R$ 0,00" />
            </section>

            <!-- 5. Contas fixas -->
            <section v-else-if="atual.chave === 'fixas'" class="passo">
                <h1 id="passo-titulo" tabindex="-1">Tem alguma conta fixa?</h1>
                <p class="apoio">Aluguel, luz, internet, assinatura. Some tudo.</p>
                <input v-model.number="contasFixas" class="campo grande" type="number" inputmode="decimal" placeholder="R$ 0,00" />
            </section>

            <!-- 6. Oferta do OFX -->
            <section v-else class="passo">
                <h1 id="passo-titulo" tabindex="-1">Quer que a gente leia seu extrato?</h1>
                <p class="apoio">
                    Em vez de chutar, a gente lê o arquivo que o seu banco exporta
                    e preenche com número real. Dá pra fazer depois também.
                </p>
                <a class="botao secundario" href="/settings/importar">quero importar o extrato</a>
            </section>
        </main>

        <footer class="acoes">
            <button v-if="passo > 0" type="button" class="link" @click="voltar">voltar</button>
            <button type="button" class="link" @click="avancar">pular</button>
            <button type="button" class="botao" :disabled="enviando" @click="avancar">
                {{ ultimo ? 'ver meu número' : 'continuar' }}
            </button>
        </footer>
    </div>
</template>

<style scoped>
.onb {
    min-height: 100dvh;
    display: flex;
    flex-direction: column;
    background: var(--fundo);
    color: var(--sobre);
    transition: background-color var(--motion-base, 300ms) var(--motion-ease, ease);
}

/* Cada passo tem sua cor, como nas refs de app (refs/apps/README.md). */
.onb[data-cor='tranquilo'] { --fundo: rgb(var(--kitamo-tranquilo)); --sobre: #fff; }
.onb[data-cor='atencao']   { --fundo: rgb(var(--kitamo-atencao));   --sobre: #1C1917; }
.onb[data-cor='aperto']    { --fundo: rgb(var(--kitamo-aperto));    --sobre: #fff; }
.onb[data-cor='futuro']    { --fundo: rgb(var(--kitamo-futuro));    --sobre: #fff; }
.onb[data-cor='barro']     { --fundo: rgb(var(--kitamo-barro));     --sobre: #fff; }

.barra { height: 4px; background: rgb(255 255 255 / 0.25); }
.barra-fill { height: 100%; background: currentColor; transition: width 300ms ease; }

.palco {
    flex: 1;
    display: flex;
    align-items: center;
    padding: 24px;
}

.passo { width: 100%; max-width: 480px; margin: 0 auto; }

h1 {
    font-size: clamp(28px, 7vw, 40px);
    font-weight: 800;
    line-height: 1.15;
    margin: 0 0 12px;
    outline: none;
}

.apoio { font-size: 16px; opacity: 0.85; margin: 0 0 28px; }

.campo {
    width: 100%;
    padding: 16px;
    font-size: 18px;
    border: 0;
    border-radius: 16px;
    background: rgb(255 255 255 / 0.95);
    color: #1C1917;
    margin-bottom: 12px;
}

.campo.grande { font-size: 32px; font-weight: 700; padding: 20px; }
.campo::placeholder { color: #78716C; font-weight: 400; }

.dupla { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.divida { border: 0; padding: 0; margin: 0 0 20px; }
.checkbox { display: flex; align-items: center; gap: 10px; margin-bottom: 20px; font-size: 16px; }

.acoes {
    display: flex;
    align-items: center;
    gap: 16px;
    padding: 20px 24px calc(20px + env(safe-area-inset-bottom));
    max-width: 480px;
    margin: 0 auto;
    width: 100%;
}

.botao {
    margin-left: auto;
    padding: 14px 28px;
    font-size: 17px;
    font-weight: 700;
    border: 0;
    border-radius: 999px;
    background: #1C1917;
    color: #fff;
    cursor: pointer;
    text-decoration: none;
}

.botao.secundario { margin: 0; display: inline-block; }
.botao:disabled { opacity: 0.6; cursor: default; }

.link {
    background: none;
    border: 0;
    color: currentColor;
    opacity: 0.85;
    font-size: 16px;
    cursor: pointer;
    padding: 8px 0;
    text-decoration: underline;
}
</style>
