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

## 8. O que você entrega

**Um app desenhado**, telas suficientes pra provar a proposta:

1. **Onboarding** — as 6 telas, cada uma na sua cor
2. **Início** — o número gigante + horizonte do mês
3. **Horizonte 12 meses** — onde a dívida acaba na tela
4. **"Quitei essa"** — o momento de conquista, com a casa crescendo
5. **Conta não fecha** — o estado difícil, sem personagem, com saída
6. **Lançamentos** e **Chat** — se sobrar fôlego

Mais o que a identidade pede: o **joão-de-barro** (traço definido, em
alguns estados), e a casa em fases de construção.

**Formato:** mobile primeiro. O app é de celular.

---

## 9. Restrições

- **Legível a 60 anos.** Mínimo 16px em texto corrido, contraste AA sempre.
  Nunca texto claro sobre fundo claro
- Fonte atual é **Plus Jakarta Sans** — redonda e moderna sem ser fofa.
  Troque se tiver motivo, mas tenha o motivo
- Raio: generoso (20px em card, 999px em chip/botão). Nada de canto vivo
- Sombra baixa e **quente** (`rgba(92,46,26,.08)`), nunca cinza-azulada
- Sem dark mode como padrão (território do Pierre)
- **Não pode parecer app de banco.** Nem app de planilha

---

## 10. O que já existe (contexto, não amarra)

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

## 11. A régua

O app vai ser mostrado pra **10 pessoas endividadas**. Sucesso se, em 7
dias, 6 completarem o onboarding e entenderem o número.

> Se o número do dia não fizer sentido pra elas em 90 segundos, o problema
> é o design, não o método.

E a pergunta que vale pra cada tela:

**Isso dá vontade de resolver, ou dá vontade de fechar o app?**

Um mês vermelho não devia ser uma linha com bolinha vermelha. Devia ser uma
tela que dá vontade de resolver.
