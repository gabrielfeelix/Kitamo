# Kitamo "Quitar" — spec de design

Data: 2026-09-06. Aprovado pelo Gabriel nesta data.
Versão anterior preservada na tag `v1-gestao` (`git checkout v1-gestao`).

---

## 1. O que muda

A Kitamo deixa de ser "mais um app de gestão financeira" e passa a ser
**o app que tira a pessoa da dívida** — e depois cuida do que sobra.

A gestão financeira construída até aqui não é descartada: vira o segundo
ato. Quem sai do vermelho quer ver o dinheiro crescer, e o módulo de
patrimônio já existe para isso.

Posicionamento em uma frase: **primeiro a gente quita, depois a gente cresce.**

### Por que esta direção (registro das razões)

1. **É o que o nome promete.** KITAMO = "quitamo(s)". O produto atual
   mostra saldo; não ajuda a quitar nada.
2. **É o que ninguém faz.** Pierre é análise (e errou: contou transferência
   como gasto). Breno é método de sobra. Nenhum é sobre sair da dívida.
3. **É o que funciona sem caixa.** Gestão diária exige sincronização
   bancária diária → agregador pago. Dívida muda uma vez por mês, na
   fatura. Um OFX por mês basta. Sem Open Finance, sem terceiro.
4. **É o que faltou ao próprio Gabriel.** O `PLANO.md` pessoal registra:
   descasamento de 2 dias entre salário (dia 5–6) e vencimento (dia 4)
   custou R$ 1.674 em encargos em 12 meses. Nenhum app avisou.
5. **85% dos brasileiros adultos têm dívida.** O mercado de "sair do
   vermelho" é maior que o de "gerir carteira".

---

## 2. Referências analisadas

### Pierre (pierre.app) — 25 telas
Voz em primeira pessoa, personagem (gato) em tudo, chat no centro,
agentes com personalidade, assinaturas com logo, mapa de calor, telas de
espera narrativas. Usa Pluggy por baixo (confirmado na tela de
consentimento do Mercado Pago). Cobra R$ 39/mês. Detalhe em
`PROPOSTA-PIERRE.md`.

### Escola do Breno — app + planilha, 22 telas em `refs/`
Método materializado numa tela. Três peças:

- **Um número: o diário.** Onboarding de 4 perguntas "no feeling" (comida,
  lazer, compras, saúde) → total mensal → dividido por 30. "Velocímetro de
  gastos": gastou menos hoje, acelera amanhã.
- **Uma tela: saldo dia a dia.** Uma linha por dia, diário descontando,
  saldo projetado em semáforo (verde/amarelo/vermelho). **Horizonte de
  saldos**: 12 meses lado a lado. A pessoa vê o dia em que fica vermelha
  antes de chegar nele.
- **Um hábito: check-in do dia.** Toca no dia para marcar "atualizei".

Tudo manual, zero banco, zero IA. R$ 24,90/mês — prova que o mercado paga
por método, não por conexão bancária.

**Onde falha para quem chega sem o curso:** ícones de letra (D, E, C) sem
legenda, jargão do método ("performance", "custo de vida"), planilha de 31
linhas de número. Ótimo onboarding, depois larga o usuário na tabela crua.

### O que a Kitamo junta
Breno tem método e tela. Pierre tem voz e chat. Nenhum é sobre dívida.
Kitamo = método do Breno calibrado pela dívida + voz do Pierre + OFX no
lugar do chute.

---

## 3. O núcleo (o que a primeira versão faz)

Quatro peças, nesta ordem de prioridade. Tudo manual + OFX. Sem banco.

### 3.1 O número: **diário pra quitar**

Não "quanto posso gastar por dia", mas:

> pra quitar até **janeiro**, seu diário é **R$ 23**.

Cálculo (determinístico, sem LLM):

```
renda_mensal
− contas_fixas (aluguel, luz, assinaturas…)
− parcelas_de_dívida do mês
= sobra_mensal
diário = sobra_mensal / dias_do_mês
```

Se `sobra_mensal ≤ 0`: o app não esconde. Diz "hoje a conta não fecha —
faltam R$ X/mês" e abre o caminho de renegociação/prioridade (fora do
escopo da v1, mas o estado precisa existir).

Data de quitação: a mais tardia entre as dívidas cadastradas. Cada dívida
tem: credor, saldo, parcela, vencimento (dia), parcelas restantes.

### 3.2 A tela: **horizonte com palavras**

A planilha vertical do Breno, com duas mudanças:

1. **Cada linha fala.** Não "4 · R$ 1.534" mas "dia 4 · parcela do Nubank ·
   R$ 1.534". Lançamentos previstos aparecem com nome.
2. **Semáforo explicado.** Vermelho vem com frase: "aqui o saldo fica
   negativo — a parcela do dia 4 cai antes do salário do dia 6".

Duas visões:
- **Mês**: 1 linha por dia, saldo projetado, diário do dia.
- **Horizonte**: 12 meses em colunas, só a cor e o saldo de fim de mês.
  É onde a pessoa vê a dívida acabando.

Motor: `App\Services\ProjecaoService` (já existe). Precisa expor projeção
diária com os lançamentos nomeados e o motivo de cada mudança de cor.

### 3.3 O onboarding: **5 perguntas + uma oferta**

Uma pergunta por tela, tela cheia, voz da marca. Pode pular tudo.

1. Quanto você deve hoje? (pode ser "não sei" → entra pela fatura depois)
2. Quanto entra por mês?
3. Que dia cai?
4. Quanto sai com o dia a dia? ("vai no feeling: mercado, padaria, iFood…")
5. Tem alguma conta fixa? (aluguel, luz, assinatura…)
6. **Oferta**: "quer que eu leia seu extrato em vez de chutar?" → importação
   OFX preenche 1, 4 e 5 com número real.

Ao fim: o número (3.1) e o horizonte (3.2). Menos de 90 segundos.

### 3.4 O hábito: **quitei essa**

Cada parcela paga é um evento:
- Marcar como paga (na linha do horizonte ou na notificação do dia)
- Carimbo "QUITADO" + a data de quitação recua se antecipou
- Contagem: "7 de 10. Faltam 3."

Substitui o "check-in" do Breno, que é sobre atualizar saldo. O da Kitamo é
sobre progresso.

---

## 4. Navegação

Cinco itens, `+` no centro (Breno), chat como destino (Pierre):

```
Início · Lançamentos · [+] · Chat · Perfil
```

| Item | O que mostra |
|---|---|
| **Início** | Número do dia, horizonte do mês, próxima parcela, card de voz |
| **Lançamentos** | Lista com chips (Todos / Entradas / Saídas / Parcelas / Fixas) |
| **+** | Lançar gasto/entrada; marcar parcela paga |
| **Chat** | `/api/ai/chat` (já existe no backend) |
| **Perfil** | Dívidas · Contas e cartões · Categorias · Tags · Importar · Aparência · Backup · Notificações · Sobre |

Sai da navegação principal: Overview, MyCards, Goals, Patrimônio, Análise,
Relatórios. Continuam existindo, acessíveis por card no Início (quando
fizer sentido) ou por Perfil.

Desktop: mesma estrutura em sidebar. Admin aparece só para `is_admin`.

---

## 5. O que acontece com as 32 telas atuais

| Tela atual | Destino |
|---|---|
| `Dashboard.vue` (1.842 linhas) | Vira `Inicio.vue`, quebrado em componentes. Widgets atuais viram cards opcionais |
| `Accounts/Index` (1.153 linhas) | Vira "Contas e cartões" em Perfil. `ImportInvoiceModal` (fachada) liga no backend real ou sai |
| `Accounts/Overview`, `Search`, `Show` | Absorvidas por Lançamentos |
| `CreditCards/*` | Fatura vira uma dívida como as outras. Tela de cartão fica em Perfil |
| `Goals/*` | Segundo ato. Card no Início quando sobra > 0 |
| `Patrimonio/Index` | Segundo ato. Card no Início quando sobra > 0 |
| `Analysis.vue`, `Analysis/Compare` | Vira seção "Pra onde vai" dentro de Lançamentos |
| `Settings/*` (9 telas) | Todas viram itens de Perfil, sem tela intermediária "Settings" |
| `Notifications/Index` | Sino no topo do Início |
| `Welcome.vue` | Substituído pelo onboarding (3.3) |

Nada é apagado. Tela que sai da navegação continua roteada até ser
absorvida. A tag `v1-gestao` guarda o estado completo.

---

## 6. Dados

### Novo: `dividas`

```
id, user_id, nome (credor), saldo_atual, valor_parcela, dia_vencimento,
parcelas_restantes, parcelas_total, taxa_juros (nullable),
account_id (nullable — quando é fatura de cartão), quitada_em (nullable)
```

Fatura de cartão em aberto **é uma dívida** com `account_id` apontando para
o cartão. `InvoiceCycle::outstandingDebt` alimenta `saldo_atual`.

### Novo: `perfil_financeiro` (respostas do onboarding)

```
user_id, renda_mensal, dia_renda, gasto_diario_estimado,
contas_fixas_estimadas, origem ('feeling' | 'ofx'), atualizado_em
```

### Existente que serve como está
`transactions` (com `origem`/`origem_id` de `73d7d70`), `accounts`,
`categories`, `recorrencia_grupos` (contas fixas), `parcelamento_grupos`.

---

## 7. Voz e identidade (resumo — detalhe em `PROPOSTA-PIERRE.md` §9)

- "A gente", nunca "o sistema". Número na frente. Palavra do dia a dia.
- Comemora o que quitou.
- Estados de espera com verbos da marca ("somando as parcelas…",
  "conferindo o que falta…") — sensação de feito à mão sem depender de
  ilustração.
- Personagem: **em aberto**. Candidatos: joão-de-barro (constrói de pouco
  em pouco), "Seu Kitamo" (quitandeiro nipo-brasileiro). Decisão do
  Gabriel. Nada do núcleo depende dele.
- Paleta: **em aberto**. Restrições: quente, sólida, legível a 60 anos.
  Não preto+neon (Pierre), não pichação.

---

## 8. IA

- Insights do Início: **determinísticos** (SQL + template). Zero custo.
- Chat: `/api/ai/chat` com Gemini free tier, cache diário, cota por
  usuário no plano grátis. Detalhe em `PROPOSTA-PIERRE.md` §10.
- Onboarding por OFX: parser existente (`BankImportParser`), sem LLM.

---

## 9. Fora de escopo da v1

- Renegociação assistida ("ligue pro banco e peça X")
- WhatsApp como canal
- App nativo / biometria (depois do site validado; Capacitor sobre o
  Inertia atual é o caminho mais barato)
- Agentes com personalidade (v2 — mecânica de `SystemNotificationRule` já
  existe)
- OCR de fatura por foto
- Marketplace de qualquer coisa

---

## 10. Como saber que funcionou

Mostrar para 10 pessoas endividadas. Sucesso se, em 7 dias:
- ≥ 6 completaram o onboarding e viram o número
- ≥ 4 marcaram pelo menos uma parcela como paga
- ≥ 3 abriram o app sem notificação

Se o número do dia não fizer sentido para elas em 90 segundos, o problema é
o onboarding, não o método.

---

## 11. Testes

- `ProjecaoService`: projeção diária com dívidas, 24 meses × dia de
  vencimento 1–31 × dia de renda 1–31 (mesmo rigor do `InvoiceCycleTest`)
- Cálculo do diário: sobra positiva, zero, negativa; mês de 28/30/31 dias
- Data de quitação: antecipação, atraso, múltiplas dívidas
- Onboarding: cada resposta pulada tem default explícito
- OFX preenchendo o perfil: fixture real de cada banco (pendente extratos)
