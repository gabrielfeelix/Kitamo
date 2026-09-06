# Identidade visual — Kitamo "Quitar"

Data: 06/09/2026. Decidido com o Gabriel.
Referências: `refs/apps/`. Núcleo do produto: spec §3.

---

## 1. O personagem: joão-de-barro

**Decidido.** Resolve a peça que estava em aberto no spec §7.

Por que ele funciona sem precisar de explicação:

- Constrói **de pouco em pouco**, com barro, e a casa fica de pé. É
  literalmente o método: R$ 23 por dia até quitar.
- A casa dele é a coisa mais sólida que um passarinho faz. Quem está
  endividado quer solidez, não gráfico.
- É brasileiro, do quintal, não é mascote importado de fintech.
- Dá progresso visual de graça: a casa **vai sendo construída** conforme
  as parcelas caem. Última parcela = casa pronta.

### O que ele faz no app

| Momento | O que ele faz |
|---|---|
| Onboarding | Aparece em 2 das 6 telas. Não fala em todas |
| Carregando | Ele bota barro. Cabe o verbo da marca ("somando as parcelas…") |
| "Quitei essa" | Coloca mais um pedaço na casa |
| Última parcela | Casa pronta. Único momento de festa grande |
| Sobra negativa | **Não aparece.** Nessa hora ele sai da frente |

Regra dura: **o personagem nunca cobre o número.** Ele mora nas bordas,
nos vazios e nas comemorações. A tela principal é do número.

---

## 2. O marrom — como usar sem ficar feio

Sua preocupação é correta: marrom mal aplicado fica velho, fica "chato",
fica papelaria. O erro clássico é usar marrom como **fundo de tela** ou
como cor de texto corrido.

**A regra: o marrom é barro, não é parede.**

Marrom entra em três lugares e só:

1. **A casa/ninho** — ilustração, progresso, o próprio bicho.
2. **Acento de "conquista"** — o carimbo QUITADO, a moldura do que já
   foi pago. Marrom = coisa construída, terminada, sólida.
3. **Fundo escuro pontual** — cartão de destaque, tela de conquista.
   Nunca a tela inteira do dia a dia.

E o marrom escolhido não é o marrom de móvel velho. É **terracota** —
barro queimado, que é quente e moderno:

```
--kitamo-barro:       #B4552D   /* terracota — acento, carimbo, casa */
--kitamo-barro-claro: #E8B79C   /* barro seco — fundo de card, borda */
--kitamo-barro-escuro:#5C2E1A   /* barro molhado — texto sobre claro, fundo de conquista */
```

Terracota + teal é combinação complementar (laranja-avermelhado × ciano).
Por isso não briga com a marca — ela **realça**.

---

## 3. A paleta

Mantém o teal atual da marca (`#14B8A6`, já em `app.css`) e abre em cores
de estado, como nas refs — cada estado tem a **tela** dele, não só um ponto.

### Marca

```
--kitamo-brand        #14B8A6   teal (JÁ EXISTE, não muda)
--kitamo-brand-dark   #0F766E
--kitamo-brand-light  #99F6E4
```

### Barro (novo)

```
--kitamo-barro        #B4552D
--kitamo-barro-claro  #E8B79C
--kitamo-barro-escuro #5C2E1A
```

### Estados — cada um é uma tela inteira

Essas são as cores que tomam conta da tela, como no Freud Score.
Fundo na cor, texto branco ou tinta escura, cards brancos por cima.

```
tranquilo  #4C8C4A  fundo   / #EAF3E7 claro   — sobra boa, dia no azul
atenção    #E8A33D  fundo   / #FDF3E0 claro   — sobra apertada
aperto     #D4562F  fundo   / #FBEAE4 claro   — dia negativo
quitado    #5C2E1A  fundo   / #E8B79C claro   — dívida encerrada (barro!)
futuro     #7C6BC4  fundo   / #EFECFA claro   — projeção, meses à frente
```

Repare: **"aperto" não é vermelho de erro** (`#EF4444`). É um vermelho de
barro, mais quente. Dívida não é bug do sistema — é situação. O vermelho
puro fica só pra erro de verdade.

### Tinta e superfície

```
--kitamo-ink     #1C1917   quase-preto quente (não o slate azulado de hoje)
--kitamo-body    #57534E
--kitamo-surface #FFFFFF
--kitamo-bg      #FAF7F2   creme, não branco-azulado
```

Trocar o cinza-azulado (`#F8FAFC`) por creme (`#FAF7F2`) é a mudança de
uma linha que mais aquece o app inteiro.

---

## 4. Como as refs viram regra

O que aprender de `refs/apps/`, traduzido pra Kitamo:

**A cor é a informação.** No Freud Score o 88 é verde e o 41 é laranja —
você entende antes de ler. No horizonte da Kitamo, um mês apertado não é
uma linha com bolinha: é um **bloco na cor do aperto**.

**Número gigante, frase pequena embaixo.** "R$ 23" no tamanho do Freud
Score, e embaixo "é o seu diário pra quitar até janeiro". Nunca o
contrário.

**Cabeçalho colorido, cards brancos.** É o padrão das telas de Mood: o
topo carrega o estado, o resto é branco e legível. Resolve "colorido sem
cansar".

**O `+` é preto e redondo, flutuando.** Como nas refs. Não é um item de
barra — é um botão que existe por cima de tudo.

**Comemorar sem infantilizar.** O quiz roxo comemora com badge e streak.
A Kitamo comemora com **carimbo e contagem** ("7 de 10. Faltam 3") e com a
casa crescendo. Sem confete, sem "parabéns!!!", sem emoji de festa.

### O que NÃO copiar

- Fundo escuro como padrão (ref do game azul) — é o território do Pierre
- Ilustração em toda tela — cansa e atrasa. Ilustração é evento
- Gamificação com XP, nível, ranking — dívida não é jogo, e ranking de
  endividado é constrangedor

---

## 5. Tipografia e forma

- Fonte: **Plus Jakarta Sans** (já configurada). Serve — é redonda e
  moderna sem ser fofa.
- Número do dia: peso 800, tamanho grande de verdade (56–72px no mobile).
- Raio: 20px em card, 999px em chip e botão. Nada de canto vivo.
- Sombra: baixa e quente (`rgba(92,46,26,.08)`), nunca sombra cinza-azul.
- Legível a 60 anos (restrição do spec §7): mínimo 16px em texto corrido,
  contraste AA sempre, nunca texto claro sobre cor clara.

---

## 6. Aplicação por tela

| Tela | Cor |
|---|---|
| Início (dia ok) | Topo tranquilo, cards brancos, `+` preto |
| Início (dia apertado) | Topo aperto, mesma estrutura |
| Onboarding | Uma cor por pergunta, ciclando pela paleta. Tela cheia |
| Horizonte 12 meses | 12 blocos, cada um na cor do estado do mês |
| Quitei essa | Tela de barro escuro, carimbo, casa crescendo |
| Lançamentos | Creme, chips coloridos por tipo |
| Chat | Creme, balão da Kitamo em teal claro |
| Sobra negativa | Aperto, **sem personagem**, com caminho de saída |

---

## 7. O que ainda não está decidido

- Desenho do joão-de-barro (traço, se tem olho, quão realista)
- Se a casa é literal ou virou um símbolo mais abstrato
- Ícone do app

Nada do núcleo (spec §3) depende disso. Itens 0–2 do handoff são backend
puro e podem rodar antes.
