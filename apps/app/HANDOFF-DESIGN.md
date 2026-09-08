# Handoff — Kitamo, design do app novo

Para o **Claude Design**. Cole este arquivo inteiro numa sessão nova.

Você vai **desenhar um app do zero**. Não é redesign, não é ajuste de tela
existente. É uma proposta nova, e o design vem **antes** do sistema: o que
você desenhar vira a base do que será construído.

O Gabriel vai te mandar **muitas referências**. Olhe todas antes de começar.

---

## 1. O que é a Kitamo

Um app que **tira a pessoa da dívida** — e só depois cuida do que sobra.

Não é gestor financeiro. Não é dashboard. Não é "controle seus gastos".
É o app que faz a pessoa endividada ver a saída.

Posicionamento: **primeiro a gente quita, depois a gente cresce.**

KITAMO = "quitamo(s)". O nome é a promessa.

**Público:** os 85% de brasileiros adultos com dívida. Gente que já tentou
planilha, já desistiu de app de banco, e tem vergonha do assunto. Não é o
investidor. Não é quem quer otimizar carteira.

---

## 2. A fusão: Breno + Pierre

O produto nasce de duas referências reais, e a sua tarefa é fundir as duas.

### Do Breno (Escola do Breno) — o método
App + planilha, R$ 24,90/mês, sem banco, sem IA. Prova que o mercado paga
por **método**, não por conexão bancária. Três peças:

- **Um número:** o diário. "Você pode gastar R$ 23 hoje."
- **Uma tela:** saldo dia a dia, uma linha por dia, semáforo verde/amarelo/
  vermelho. E o **horizonte**: 12 meses lado a lado, onde a pessoa vê o mês
  em que fica no vermelho antes de chegar nele.
- **Um hábito:** check-in diário.

**Onde ele falha:** ícones de letra sem legenda, jargão do método, e uma
planilha de 31 linhas de número cru. Ótimo onboarding, depois abandona o
usuário numa tabela.

### Do Pierre (pierre.app) — a voz
Concorrente que cobra R$ 39/mês. Voz em primeira pessoa, personagem (gato)
em tudo, chat no centro, telas de espera narrativas, agentes com
personalidade.

**Onde ele falha:** é análise, não ação. E errou o básico — contou
transferência entre contas como gasto.

### A Kitamo
**Método do Breno + voz do Pierre + foco em dívida, que nenhum dos dois tem.**

Do Breno vem a estrutura. Do Pierre vem a alma. A dívida é nossa.

---

## 3. A identidade (decidida, não reabrir)

### Personagem: joão-de-barro

O pássaro que **constrói a casa de pouco em pouco, com barro**, e a casa
fica de pé. É literalmente o método: R$ 23 por dia até quitar.

Por que ele:
- Constrói aos poucos — igual quitar dívida
- A casa dele é a coisa mais sólida que um pássaro faz. Quem está endividado
  quer solidez, não gráfico
- É brasileiro, de quintal. Não é mascote importado de fintech
- **Dá progresso visual de graça: a casa vai sendo construída conforme as
  parcelas caem.** Última parcela = casa pronta

**Onde ele aparece:**

| Momento | O que faz |
|---|---|
| Onboarding | 2 das 6 telas. Não fala em todas |
| Carregando | Bota barro. Cabe verbo da marca ("somando as parcelas…") |
| Quitou parcela | Coloca mais um pedaço na casa |
| Última parcela | Casa pronta. Único momento de festa grande |
| Conta não fecha | **Não aparece. Sai da frente.** |

**Regras duras:**
- O personagem **nunca cobre o número**. Ele mora nas bordas e nos vazios
- Sem confete, sem "parabéns!!!", sem emoji de festa
- Quando a pessoa está no aperto, ele some. Bicho fofo em cima de má notícia
  é deboche

**O traço é com você.** Quão realista, se tem olho, se é geométrico ou
orgânico, se a casa é literal ou virou símbolo. Isso está em aberto de
propósito — é sua decisão de design.

### Cores

A marca já é **teal `#14B8A6`**. Mantenha.

O **barro/terracota** entra porque é joão-de-barro. Mas atenção — o Gabriel
foi explícito: *"marrom mal aplicado fica horrível"*. Ele tem razão. O erro
clássico é usar marrom como **parede** (fundo de tela, texto corrido). Aí
vira papelaria velha.

**A regra: o marrom é barro, não é parede.** Ele entra em três lugares:
1. A casa / o pássaro / ilustração
2. Acento de conquista — carimbo QUITADO, moldura do que já foi pago
3. Fundo escuro pontual — card de destaque, tela de conquista

E não é marrom de móvel: é **terracota**, barro queimado.

```
teal      #14B8A6   marca (já existe)
barro     #B4552D   terracota — acento, carimbo, casa
barro claro   #E8B79C
barro escuro  #5C2E1A
```

Terracota é o **complementar** do teal (laranja-avermelhado × ciano). Por
isso não briga com a marca — realça.

### Cores de estado — e aqui está o ponto

Cada estado tem uma cor que **toma a tela inteira**, não um pontinho:

```
tranquilo  #4C8C4A     sobra boa, dia no azul
atenção    #E8A33D     sobra apertada
aperto     #D4562F     dia negativo
quitado    #5C2E1A     dívida encerrada (barro!)
futuro     #7C6BC4     projeção, meses à frente
```

**"Aperto" não é vermelho de erro (#EF4444). É vermelho de barro.** Dívida
não é bug do sistema — é situação. O vermelho puro fica só pra erro real.

Fundo geral: **creme `#FAF7F2`**, nunca branco-azulado. Tinta: `#1C1917`,
quase-preto quente.

---

## 4. O que o Gabriel quer que você entenda das refs

Ele mandou refs de apps de saúde mental, quiz, educação infantil. O que ele
disse, na palavra dele:

> "elas são coloridas, não necessariamente precisamos ficar só no verde
> branco e marrom não, podemos fazer igual essas refs, cores de telas
> inteiras, parciais, componentes, em botões, em cards, perceba como tem
> **PERSONALIDADE** esses aplicativos, como tem **VIDA**!!"

A lição central dessas refs:

**A cor é a informação.** Num app de saúde mental que ele mandou, o score 88
é verde e o 41 é laranja — você entende antes de ler o número. Traduzindo
pra Kitamo: um mês apertado não é uma linha com bolinha vermelha. É um
**bloco na cor do aperto**.

Outras regras que saíram das refs:

- **Número gigante, frase pequena embaixo.** "R$ 23" enorme, e sob ele "é o
  seu diário pra quitar até janeiro". Nunca o contrário
- **Cabeçalho colorido, cards brancos.** O topo carrega o estado, o resto é
  branco e legível. Resolve "colorido sem cansar"
- **O `+` é preto, redondo, flutuante.** Não é item de barra
- **Comemorar sem infantilizar.** Carimbo e contagem ("7 de 10. Faltam 3"),
  e a casa crescendo

**O que NÃO copiar das refs:**
- Fundo escuro como padrão — é o território do Pierre
- Ilustração em toda tela — cansa. Ilustração é evento
- XP, nível, ranking — dívida não é jogo, e ranking de endividado é
  constrangedor

---

## 5. O que o app faz (as 4 peças)

### 5.1 O número: diário pra quitar
Não "quanto posso gastar", mas:

> pra quitar até **janeiro**, seu diário é **R$ 23**.

Se a conta não fecha, o app **não esconde**: "hoje a conta não fecha —
faltam R$ 434/mês". Nunca mostrar "R$ 0" — fingir que dá pra viver sem
gastar nada é mentira, e a pessoa sabe.

### 5.2 A tela: horizonte com palavras
A planilha do Breno, com duas mudanças:

1. **Cada linha fala.** Não "4 · R$ 1.534" mas "dia 4 · parcela do Nubank ·
   R$ 1.534"
2. **Semáforo explicado.** Vermelho vem com frase: *"a parcela do dia 4 cai
   antes do salário do dia 6"*

Duas visões: **mês** (1 linha por dia) e **horizonte** (12 meses em colunas,
só cor e saldo — é onde a pessoa vê a dívida acabando).

### 5.3 O onboarding: 5 perguntas + 1 oferta
Uma pergunta por tela, tela cheia, tudo pulável. Menos de 90 segundos.

1. Quanto você deve hoje? (pode ser "não sei")
2. Quanto entra por mês?
3. Que dia cai?
4. Quanto sai com o dia a dia? ("vai no feeling: mercado, padaria, iFood…")
5. Tem conta fixa?
6. **Oferta:** "quer que a gente leia seu extrato em vez de chutar?"

Ao fim: o número e o horizonte.

### 5.4 O hábito: "quitei essa"
Cada parcela paga é evento: carimbo QUITADO, contagem "7 de 10. Faltam 3",
e a data de quitação **recua** se antecipou.

---

## 6. Navegação

```
Início · Lançamentos · [+] · Chat · Perfil
```

O `+` no centro (do Breno), chat como destino (do Pierre).

| Item | O que mostra |
|---|---|
| **Início** | Número do dia, horizonte do mês, próxima parcela |
| **Lançamentos** | Lista com chips (Todos / Entradas / Saídas / Parcelas / Fixas) |
| **+** | Lançar gasto/entrada; marcar parcela paga |
| **Chat** | Conversa com a Kitamo |
| **Perfil** | Dívidas · Contas · Categorias · Importar · Aparência · Sobre |

---

## 7. Voz da marca

- **"A gente"**, nunca "o sistema"
- **Número na frente.** A frase explica o número, não o contrário
- Palavra do dia a dia. Zero jargão financeiro
- Comemora o que quitou
- Estados de espera com verbos da marca: "somando as parcelas…",
  "conferindo o que falta…"

Exemplos do tom:
- ✅ "pra quitar até janeiro, seu diário é R$ 23"
- ✅ "a parcela do Nubank cai antes do salário do dia 6"
- ✅ "7 de 10. Faltam 3."
- ❌ "Seu limite diário disponível é de R$ 23,00"
- ❌ "Análise de fluxo de caixa projetado"

---

## 8. As telas, uma a uma

Tudo abaixo é **conteúdo**, não layout. O arranjo é decisão sua — o que
está aqui é o que a tela precisa dizer, e o que não pode faltar.

Todo valor em reais no formato brasileiro: `R$ 1.534,06`.

---

### 8.1 Onboarding — 6 telas

Uma pergunta por tela, **tela cheia na cor do passo**, texto grande, campo
único. Barra de progresso fina no topo. Botão "continuar" e link "pular"
sempre visíveis — **pular nunca some**.

| # | Cor | Pergunta | Campo | Apoio |
|---|---|---|---|---|
| 1 | aperto `#D4562F` | **Quanto você deve hoje?** | credor, parcela, quantas faltam, dia do vencimento · "+ tenho outra" | "Cartão, empréstimo, crediário — o que estiver pesando." · caixa "não sei ainda" |
| 2 | tranquilo `#4C8C4A` | **Quanto entra por mês?** | valor | "Salário, pró-labore, o que for fixo." |
| 3 | futuro `#7C6BC4` | **Que dia cai?** | dia 1–31 | "Serve pra saber se alguma parcela vence antes." |
| 4 | atenção `#E8A33D` | **Quanto sai com o dia a dia?** | valor por dia | "Vai no feeling: mercado, padaria, iFood…" |
| 5 | barro `#B4552D` | **Tem alguma conta fixa?** | valor total | "Aluguel, luz, internet, assinatura. Some tudo." |
| 6 | tranquilo | **Quer que a gente leia seu extrato?** | botão "quero importar" | "Em vez de chutar, a gente lê o arquivo do seu banco. Dá pra fazer depois." |

**João-de-barro aparece em 2 telas** (sugestão: a 1, acolhendo, e a 6,
oferecendo). Nas outras, não.

**Tela final — o número.** Vem logo após a 6ª:
- Número gigante: `R$ 23`
- Frase: "é o seu diário pra quitar até **janeiro**"
- Botão: "ver meu mês"
- João-de-barro com a primeira bolinha de barro

---

### 8.2 Início

A tela que a pessoa abre todo dia. Três blocos.

**Bloco 1 — o topo colorido** (cor = estado do dia)
- Rótulo pequeno: "pra quitar até janeiro"
- **Número gigante**: `R$ 23`
- Frase embaixo: "é o seu diário"
- Sino de notificações no canto

**Se a conta não fecha, o topo inverte** (ver 8.6).

**Bloco 2 — próxima parcela** (card branco, sobreposto ao topo)
- "Próxima: **parcela do Nubank**"
- `R$ 1.534,06` · "vence dia 4 · faltam 6 dias"
- Botão: **"quitei essa"**
- Se vence antes da renda: aviso em atenção — "cai antes do salário do dia 6"

**Bloco 3 — o mês** (fundo creme)
- Título "Seu mês" + link "ver 12 meses"
- Lista de dias (ver 8.3), começando em hoje
- Cards opcionais no fim: **Guardar** (só quando sobra > 0) e **Patrimônio**

**Rodapé:** navegação de 5 itens com `+` preto flutuante no centro.

---

### 8.3 Horizonte do mês

Uma linha por dia. **É a tela do Breno, mas falando.**

Cada linha tem:
- **Dia** (número grande à esquerda)
- **O que acontece** — nome, não código: "parcela do Nubank", "salário"
- **O motivo**, quando há: "cai antes do salário do dia 6"
- **Saldo do dia** à direita, alinhado

**A cor do fundo da linha é o estado:** tranquilo (branco/creme), atenção
(`#FDF3E0`), aperto (`#FBEAE4`).

Dia sem nada acontecendo é linha discreta — só número e saldo.
**Dia tranquilo não leva frase.** Só o vermelho e o amarelo explicam.

Topo: seletor de mês (‹ setembro ›) e o saldo previsto pro fim do mês.
Hoje é destacado.

---

### 8.4 Horizonte 12 meses

**A tela mais importante do app** — é onde a pessoa vê a dívida acabando.

12 blocos, um por mês, cada um **inteiro na cor do estado**. Dentro de cada:
- Mês: "set/26"
- Saldo previsto do fim do mês
- Se tem parcela: um traço/ponto marcando

**O mês em que a dívida acaba é marcado** — barro escuro, com "livre" ou a
casa do joão-de-barro pronta. É o prêmio visual da tela.

Abaixo: frase-resumo — "sua última parcela é em **janeiro de 2027**. Depois
dela sobram R$ 2.059 por mês."

---

### 8.5 "Quitei essa" — a conquista

Tela cheia em **barro escuro `#5C2E1A`**. O único momento de festa.

- **Carimbo QUITADO** sobre o nome da parcela — carimbo mesmo, torto, com
  textura, não selo digital
- "parcela do Nubank · R$ 1.534,06"
- **Contagem: "7 de 10. Faltam 3."**
- **João-de-barro colocando mais um pedaço na casa** — e a casa visivelmente
  mais alta que na última vez
- Se antecipou: "você adiantou. Agora sua quitação é em **dezembro**, não
  janeiro." — a data recuando é a melhor notícia do app
- Botão: "beleza"

**Última parcela de todas:** casa pronta, joão-de-barro no telhado, e a
frase "acabou. Você quitou tudo." Só aqui a festa é grande.

---

### 8.6 Quando a conta não fecha

O estado difícil. **Precisa ser honesto sem ser cruel.**

Topo em aperto `#D4562F`:
- Rótulo: "hoje a conta não fecha"
- **Número gigante: `R$ 434`**
- "é o que falta por mês pra fechar"

**Sem joão-de-barro. Ele sai da frente.** Bicho fofo em cima de má notícia
é deboche.

Abaixo, o que fazer — em cards claros, sem tom de sermão:
- "**Onde estão seus R$ 2.448**" → contas fixas e parcelas listadas, maior
  primeiro
- "**A parcela do Nubank vence dia 4, o salário cai dia 6.**" → o
  descasamento que gera juros. Com ação: "pedir pra mudar o vencimento"
- "**Quer ver o que dá pra renegociar?**" (v2, mas o card existe)

Nunca mostrar `R$ 0,00` como diário. Fingir que dá pra viver sem gastar
nada é mentira, e a pessoa sabe.

---

### 8.7 Lançamentos

Lista do que entrou e saiu.

- **Chips no topo:** Todos · Entradas · Saídas · Parcelas · Fixas
- Agrupado por dia, com data por extenso ("hoje", "ontem", "4 de setembro")
- Cada item: ícone de categoria, nome, categoria, valor (entrada verde,
  saída escura)
- Parcela vem com selo — é dívida, não gasto comum
- Busca no topo
- **Vazio:** joão-de-barro, "nada lançado ainda" + botão

Seção "**Pra onde vai**": barras horizontais coloridas por categoria, do
maior pro menor, com valor e percentual. Sem pizza.

---

### 8.8 O botão `+`

Preto, redondo, flutuante. Abre folha de baixo com 3 opções grandes:

- **Gastei** → valor, categoria, conta, data
- **Recebi** → valor, de onde, conta, data
- **Paguei uma parcela** → escolhe a dívida, leva pro "quitei essa"

Teclado numérico grande. Valor primeiro, sempre.

---

### 8.9 Chat

A voz da Kitamo. Conversa, não formulário.

- Balões: Kitamo em teal claro, usuário em branco
- **Sugestões prontas** quando vazio: "dá pra antecipar uma parcela?" ·
  "por que meu diário caiu?" · "quanto falta pra quitar?"
- **Espera com verbo da marca**: "somando as parcelas…", "conferindo o que
  falta…" — com joão-de-barro botando barro
- Números aparecem em destaque dentro do balão, não perdidos no texto

---

### 8.10 Perfil

**Sem tela intermediária de "configurações".** Perfil já é a lista.

Topo: avatar, nome, e-mail. E uma linha de status:
"**faltam 3 parcelas · quitação em janeiro**"

Depois, itens agrupados:

**Minha dívida**
- **Dívidas** → lista de dívidas, cada uma com nome, saldo, parcela, "7 de
  10", data prevista. Toca pra editar. Botão "+ nova dívida". Quitadas ficam
  numa seção abaixo, com carimbo
- **Meu perfil financeiro** → as respostas do onboarding, editáveis. Mostra
  se veio de chute ou de extrato

**Dinheiro**
- **Contas e cartões** → saldo de cada, botão de nova
- **Categorias** · **Tags**

**Dados**
- **Importar extrato** → OFX/CSV, com passo a passo de como baixar no banco
- **Backup**

**App**
- **Aparência** · **Notificações** · **Sobre**

Cada item é uma linha com ícone, nome e seta. Agrupamento com respiro entre
os blocos, sem cabeçalho pesado.

---

### 8.11 Notificações

Sino no Início. Lista simples, não-lida com marca.

Tipos:
- **Vence amanhã:** "a parcela do Nubank vence amanhã · R$ 1.534,06"
- **Descasamento:** "essa parcela cai antes do seu salário"
- **Conquista:** "faltam 3 parcelas"
- **Diário mudou:** "seu diário subiu pra R$ 31"

---

### 8.12 Estados que faltam

Não são telas, mas o app quebra sem eles:

- **Carregando** — joão-de-barro botando barro + verbo da marca. Nunca
  spinner nu
- **Vazio** — cada lista tem o seu, com o pássaro e um botão. Nunca "nenhum
  registro encontrado"
- **Erro** — "não deu certo aqui" + o que fazer. Sem código de erro
- **Sem internet** — o app é de projeção, funciona offline; avisar sem
  bloquear

---

## 9. O que você entrega

Na ordem de prioridade:

1. **Onboarding** — as 6 telas + a tela do número (8.1)
2. **Início** (8.2)
3. **Horizonte 12 meses** (8.4) — a tela que vende o app
4. **"Quitei essa"** (8.5)
5. **Conta não fecha** (8.6)
6. **Perfil** (8.10) e **Lançamentos** (8.7)
7. **Chat** (8.9), **`+`** (8.8), estados (8.12)

Mais a identidade: o **joão-de-barro** com traço definido, em alguns
estados (acolhendo, botando barro, comemorando), e a **casa em fases de
construção** — vazia, meio feita, pronta.

**Formato:** mobile primeiro.

## 10. Restrições

- **Legível a 60 anos.** Mínimo 16px em texto corrido, contraste AA sempre.
  Nunca texto claro sobre fundo claro
- Fonte atual é **Plus Jakarta Sans** — redonda e moderna sem ser fofa.
  Troque se tiver motivo, mas tenha o motivo
- Raio: generoso (20px em card, 999px em chip/botão). Nada de canto vivo
- Sombra baixa e **quente** (`rgba(92,46,26,.08)`), nunca cinza-azulada
- Sem dark mode como padrão (território do Pierre)
- **Não pode parecer app de banco.** Nem app de planilha

---

## 11. O que já existe (contexto, não amarra)

O backend do núcleo está construído e testado (125 testes verdes):

- Cálculo do diário e data de quitação
- Projeção diária com lançamentos nomeados e motivo de cada cor
- Horizonte de 12 meses
- Onboarding salvando as respostas

**Isso não amarra seu design.** Se a sua proposta pedir outra estrutura de
tela, o backend se adapta. O design vem primeiro.

Ambiente de teste: `dev.kitamo.com.br` (produção `kitamo.com.br` é a versão
antiga e não deve ser tocada).

---

## 12. A régua

O app vai ser mostrado pra **10 pessoas endividadas**. Sucesso se, em 7
dias, 6 completarem o onboarding e entenderem o número.

> Se o número do dia não fizer sentido pra elas em 90 segundos, o problema
> é o design, não o método.

E a pergunta que vale pra cada tela:

**Isso dá vontade de resolver, ou dá vontade de fechar o app?**

Um mês vermelho não devia ser uma linha com bolinha vermelha. Devia ser uma
tela que dá vontade de resolver.
