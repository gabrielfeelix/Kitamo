# Handoff — Kitamo

Sessão de 05–06/09/2026. Cole este arquivo numa sessão nova para continuar.

---

## Contexto em uma frase

Kitamo é um app de finanças pessoais (Laravel 12 + Vue 3 + Inertia + TS) em
kitamo.com.br. Nesta sessão os dados reais do Gabriel foram importados via Open
Finance e o sistema passou por uma auditoria completa — 19 achados críticos e
~12 altos, todos corrigidos em 16 commits.

O Gabriel vai continuar caçando bugs olhando a tela. Espere achados novos.

---

## Acesso

**Repositório:** `github.com/gabrielfeelix/kitamo` — clonado em
`/home/gabfelix/dev/kitamo-repo` (use este, não `/home/gabfelix/dev/kitamo`,
que é uma cópia parcial antiga e sem git).

**Servidor (Hostinger):**
```bash
ssh hostinger-kitamo      # já configurado em ~/.ssh/config
# path: /home/u626119115/domains/kitamo.com.br/public_html
# PHP:  /opt/alt/php83/usr/bin/php   (o `php` do PATH é 7.2 e NÃO funciona)
```

**Banco:** MySQL em `srv1722.hstgr.io`, base `u626119115_Kitamo`. Credenciais no
`.env` do servidor. O usuário do Gabriel é **user_id = 1**.

**Deploy:** há GitHub Actions (`.github/workflows`) que builda e faz deploy no
push para `main`. **Ele parou de entregar o frontend em algum momento desta
sessão** — o backend subia, os assets não. Deploy manual que funciona:

```bash
cd /home/gabfelix/dev/kitamo-repo
npm run build
rsync -az public/build/ hostinger-kitamo:/home/u626119115/domains/kitamo.com.br/public_html/public/build/
scp app/Http/Controllers/Foo.php hostinger-kitamo:/home/u626119115/domains/kitamo.com.br/public_html/app/Http/Controllers/Foo.php
ssh hostinger-kitamo 'cd /home/u626119115/domains/kitamo.com.br/public_html && /opt/alt/php83/usr/bin/php artisan optimize:clear'
```

> ⚠️ **Nunca use `rsync --delete` em `public/build/`.** Vale investigar o CI.

---

## Armadilha operacional: limite de conexões MySQL

O Hostinger corta em **500 conexões/hora**. Cada `artisan tinker` abre uma. Numa
sequência de testes isso derrubou o site inteiro com "Server Error" por ~1 hora.

**Agrupe todas as verificações num único `tinker --execute`.** Não teste uma
coisa por vez.

---

## Dados do usuário no sistema

Importados do Open Finance (Pluggy) — **não são fictícios**.

| Conta | id | Tipo | Situação |
|---|---|---|---|
| Itaú | 35 | bank | conta de passagem, saldo R$ 0 |
| Nubank Gold | 36 | credit_card | limite R$ 14.550, fecha 28, vence 4 |
| Mercado Pago | 37 | credit_card | limite R$ 5.800, fecha 2, vence 7 |

- **559 transações**, set/2025 a dez/2026
- 16 categorias em português, nenhuma transação órfã
- Salário: R$ 3.615/mês (fev–set/2026), com as saídas correspondentes
- Fatura de setembro: Nubank R$ 1.534,06 · Mercado Pago R$ 133,28
- Dívida total do Nubank: R$ 6.136,24 (4 parcelas de renegociação até jan/2027)

**Fatura ≠ dívida total.** Confundir os dois foi a origem de vários bugs.

### Origem dos dados (se precisar repuxar)

Credenciais Pluggy em `/home/gabfelix/dev/finance/.env` (chmod 600).

```bash
set -a && . ./.env && set +a
curl -s -X POST https://api.pluggy.ai/auth -H 'Content-Type: application/json' \
  -d "{\"clientId\":\"$PLUGGY_CLIENT_ID\",\"clientSecret\":\"$PLUGGY_CLIENT_SECRET\"}"
# apiKey dura 2h; use header X-API-KEY
```

Endpoints: `/accounts?itemId=`, `/bills?accountId=`, `/v2/transactions?accountId=&dateFrom=`
(o v1 está descontinuado; o v2 **não** aceita `pageSize` nem `from`).

Item IDs: Nubank `d6bdb2b1-ea5d-4aa0-897d-4cd427421bbf` · Mercado Pago
`ea9ee3da-c85c-4393-a72d-cc108e53df83`.

Limitações conhecidas: a API corta em **500 transações** (set–nov/2025 do Nubank
foram recuperados via `/bills` como lançamento consolidado); a **caixinha do
Mercado Pago é invisível** para a API (o Gabriel tinha R$ 1.628,47 lá — precisa
informar manualmente); e o conector MeuPluggy **não aceita refresh via API**
(`MeuPluggy item cant be updated`) — a sincronização parte do app meu.pluggy.ai.

---

## Decisões de arquitetura tomadas

Entender estas evita desfazer trabalho:

**1. `App\Support\InvoiceCycle` é a fonte única do ciclo de fatura.**
Havia duas implementações (PHP e TypeScript) divergindo em um mês inteiro. A
cópia em TS foi apagada; `CreditCards/Show.vue` recebe o período do servidor.
Coberto por `tests/Unit/InvoiceCycleTest.php` — 24 meses × closing_day 1–31.

**2. A "fatura de setembro" são as compras feitas em setembro**, não a que vence
em setembro. É a convenção do extrato do banco e o Gabriel foi explícito sobre
isso. O deslocamento é **constante por cartão** (`FECHAMENTO_CEDO = 5`): qualquer
heurística que dependa do tamanho do mês muda de decisão em fevereiro e cria
meses pulados e faturas duplicadas — foi exatamente o bug C1.

**3. Dívida de cartão nunca sai de `current_balance`.**
Esse campo é acumulador de caixa e fica negativo em cartões. Use
`InvoiceCycle::outstandingDebt($accountId)`, que deriva das transações pendentes.

**4. Transferências geram duas `Transaction` espelho**, com as tags
`transferencia` e `transferencia:<id>`. Relatórios excluem essas entradas —
dinheiro trocando de conta não é receita nem despesa.

**5. Pagamento de fatura usa a tag `quitacao-fatura`.** Sem isso a fatura conta
em dobro: as compras já são despesas.

**6. `status` significa:** `pending` = fatura em aberto · `paid` = já quitada.
O `getByMonth` soma o ciclo inteiro e expõe `esta_paga` separadamente.

---

## O que foi corrigido (16 commits, `8aee39a` → `7ab85de`)

Relatório completo em `AUDITORIA.md` no repo.

**19 CRÍTICOS** — ciclo de fatura pulando/duplicando meses · dupla
implementação PHP/TS · `limite_usado` sempre zero · projeção morta (466 linhas
corretas nunca chamadas) · barras com `Math.abs` (−5.000 idêntico a +5.000) ·
"Entrou/Saiu" somando todos os tempos · "próximas contas" mostrando as mais
atrasadas · preferências de notificação descartadas com resposta 200 · tela de
backup 100% mockup · restore com wipe sem confirmação · deletar categoria
orfanando o histórico · NaN% · depósito em meta não-atômico · form
sobrescrevendo a meta com placeholders · rota "limpar lidas" sempre 404 ·
marcar parcela renomeando para 1/12 · excluir conta deixando saldo fantasma ·
alerta falso de saldo negativo · PII do dev hardcoded em 5 arquivos + seed de
demo amarrado ao e-mail dele.

**~12 ALTOS** — zero `DB::transaction` no `TransactionController` (com um 422
*depois* do estorno, perdendo dinheiro deterministicamente) · `data_pagamento =
now()` colapsando histórico · dia da recorrência degradando (31 → 28 para
sempre) · fatura contada em dobro · limite não reduzido ao pagar · cartões
nunca recalculados · transferências invisíveis no extrato · seletor de período
travado · `hasTrendData` sempre true · legendas hardcoded · timezone jogando o
dia 1º no mês anterior · telas com promessa falsa (biometria, PRO, Appearance) ·
rotas órfãs servindo protótipos.

**Testes:** 10 testes, 1.712 asserções (`./vendor/bin/phpunit tests/Unit/`).

---

## O que NÃO foi feito

- **`/api/dashboard/insights`** existe no backend e não tem consumidor
- **Exports** (`ExportController`) idem
- **`CreditCards/Index.vue`** parece órfã — verifique antes de remover
- **Notifications**: o filtro de período opera sobre os 20 itens já truncados
  *por prioridade*, então "Hoje" pode vir vazio havendo notificações de hoje
- **`Dashboard.vue` tem 1.740 linhas** e 24 casts `any` — candidato a quebrar
  em componentes
- **CI do GitHub Actions** parou de entregar o frontend

---

## Como o Gabriel trabalha

Vale respeitar, poupa retrabalho:

- **Respostas curtas.** Ele reclamou de texto longo mais de uma vez.
- **Pesquise antes de afirmar que algo não existe.** Ele corrigiu isso também.
- **Não pergunte o que dá para descobrir.** Ele foi explícito: "vc ta perguntando
  coisa demais, ACELERA".
- **Ele confere os números na tela e acha erro.** Achou o card de fatura
  mostrando dívida total, achou o Itaú só com entradas. Se ele disser que um
  número está errado, ele provavelmente está certo — verifique antes de explicar.
- **Confirme antes de apagar dados.** Ele autoriza, mas quer ser perguntado.

---

## Primeiro comando numa sessão nova

```bash
cd /home/gabfelix/dev/kitamo-repo && git log --oneline -5 && git status --short
```
