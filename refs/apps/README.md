# refs/apps — referências de interface

Aqui vão prints de apps cuja **aparência** interessa. Não são concorrentes
(esses ficam em `refs/`, análise no spec §2) — são referência de estilo.

## O que jogar aqui

Qualquer app que tenha **vida**. Dribbble, Behance, print de app real,
não importa. Se te deu vontade de olhar de novo, joga aqui.

Nome de arquivo livre. Se der, um prefixo ajuda a achar depois:

```
cor-*      paleta, tela inteira colorida, bloco de cor
card-*     jeito de montar card, sombra, raio, empilhamento
numero-*   como mostram O número grande da tela
onboard-*  telas de pergunta, uma por vez
vazio-*    estado vazio, carregando, erro
mascote-*  personagem, ilustração, bicho
nav-*      barra de baixo, botão +, menu
```

## O que já foi lido daqui (06/09/2026)

Sete referências enviadas na conversa. O que cada uma ensina:

| Ref | O que aproveitar |
|---|---|
| **Freud Score** (verde/laranja/roxo) | Tela **inteira** da cor do estado. Número gigante no meio de um anel. A cor *é* a informação — 88 verde, 41 laranja. É exatamente o semáforo do horizonte, só que sem medo de cor |
| **Mood / Stress** (amarelo, oliva, laranja) | Cada tela tem sua cor e mesmo assim são o mesmo app. Cabeçalho colorido + cards brancos embaixo. Botão `+` flutuante em preto, redondo |
| **Quiz roxo** | Progresso em blocos, badges, streak. Como comemorar sem infantilizar |
| **Education / Kidory** | Ilustração cheia e cor chapada. Bom pra estados vazios |
| **Game azul-escuro** | Prova que escuro também tem vida. Ainda assim: **não é o caminho da Kitamo** (é o território do Pierre) |
| **Mental Health** (laranja/verde/roxo) | Número gigante ("60%") com a frase logo abaixo. Barras coloridas em vez de gráfico cinza |

### A lição que essas refs trazem para o spec

O horizonte do Breno é uma planilha cinza com um pontinho colorido. Essas
refs fazem o contrário: **a cor toma a tela**. Um mês vermelho não devia ser
uma linha com bolinha vermelha — devia ser uma tela vermelha que dá vontade
de resolver.

Paleta que saiu disso: `docs/DESIGN-KITAMO.md`.
