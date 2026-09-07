# O que está errado, por quê, e em que ordem consertar

Escrito em 07/09/2026, depois de o Gabriel usar o app instalado e listar
o que não fecha. **Cada item abaixo foi conferido no código**, não é
suposição — o arquivo e a linha estão citados.

O fio que liga quase tudo: **o app inventa dado que não perguntou, e
mostra o palpite com cara de fato.** Num app de dívida isso é o pior
defeito possível: a pessoa confere contra a fatura, vê número que não
bate, e para de confiar. Um número errado com confiança é pior que
nenhum número.

---

## PARTE 1 — Os cálculos e os dados inventados

### 1.1 O saldo diário está errado (o mais grave)

`services/horizonte_service.dart:116`

```dart
saldo = _duasCasas(saldo - diario);
```

O `diario` é **quanto ela PODE gastar**, e o código subtrai isso todo dia
como se ela tivesse gastado. Sem lançar nada, o saldo despenca o valor do
diário por dia: quem tem R$ 1.000/dia de limite vê −R$ 1.000, −R$ 2.000,
−R$ 3.000, e o mês inteiro no vermelho sem ter gasto um centavo.

Foi exatamente o que apareceu na tela e eu deixei passar: a coluna SALDO
descendo 23,33 por dia era isso.

**O certo:** o saldo do dia é `entradas − saídas reais`. O planejado é
uma **linha de referência**, não um débito:

- **dia que já passou** → usa o gasto real lançado
- **dia que ainda não chegou** → usa o planejado como *previsão*, e a
  tela precisa dizer que é previsão (hoje ela mistura os dois sem avisar)
- **dia sem lançamento nenhum no passado** → gasto zero, não "gastou o
  diário". Se ela não lançou, o app não sabe; supor o pior é inventar.

A coluna PODE GASTAR continua sendo o combinado. A coluna GASTOU só
mostra o que existe. O SALDO deixa de ser ficção.

### 1.2 "0 de 12 parcelas" numa dívida de 4 meses

`features/onboarding/onboarding_controller.dart:243-251`

```dart
nome: 'o que eu devo',
valorParcela: totalDevido! / 12,
parcelasRestantes: 12,
parcelasTotal: 12,
```

O app pergunta **só o total**, e inventa 12 parcelas. O comentário no
código chama de "chute honesto", mas na tela sai "0 de 12" — que a pessoa
lê como fato conferido.

**O certo:** perguntar. A pergunta #02 vira duas informações: quanto
deve e **em quantas vezes** (com "não sei" válido). Quando ela não sabe,
o app **não mostra contagem de parcela nenhuma** — mostra o total e o
que ela paga por mês. Melhor um campo vazio que um número falso.

### 1.3 "E se eu tiver mais de uma dívida?"

O modelo já aguenta (cartão com compras dentro, feito hoje), mas as
**perguntas iniciais** só coletam um total. Existe `rascunhos` no
controller para várias dívidas, e **nenhuma tela usa isso**.

**O certo:** depois de perguntar o total, oferecer "quer detalhar?" com
"+ adicionar dívida" (nome, parcela, quantas faltam, dia). Pular é
válido. É o mesmo princípio das contas fixas: o app pergunta, a pessoa
responde.

### 1.4 O app dá bom dia sem saber o nome

`features/inicio/cabecalho_do_inicio.dart:126` desenha "bom dia, Gabriel",
e o nome **nunca é perguntado** — só dá pra editar no Perfil, depois.

**O certo:** perguntar o nome. Vai na **entrada**, antes das perguntas de
dinheiro: é a pergunta mais fácil de responder e serve de aquecimento.
Sem nome, o cabeçalho diz só "bom dia" (já funciona assim).

---

## PARTE 2 — O fluxo depois das perguntas

### 2.1 A tela que pisca em 0,2s

`app.dart:157-161`: `aoConcluir` marca o onboarding como feito e cai
**direto no Início**. O que o Gabriel viu piscar é a última pergunta
desmontando. Não existe tela de resultado.

### 2.2 Falta a #17 "O número" (o RESULTADO)

Não existe no código. É a tela que fecha as perguntas: fundo teal, "PRA
QUITAR ATÉ JANEIRO", o número em Outfit 76, o resumo "você deve R$ X em N
dívidas, e entra R$ Y por mês", o aviso de que tudo foi chute, e os
botões "ver meu mês" e "revisar minhas respostas".

### 2.3 Falta a #32 "Primeira vez" (o ONBOARDING de verdade)

Também não existe. É o que **ensina a usar**, depois do resultado: véu
escuro sobre o Início já preenchido e três balões ("1 DE 3 · ESSE
NÚMERO") explicando de onde vem o número, o que é o diário, e onde lançar
gasto.

O fluxo inteiro, como o design desenhou:

```
entrada (frases do joão)  →  perguntas iniciais  →  RESULTADO (#17)
                                                        ↓
                                    Início  →  ONBOARDING (#32, 1 de 3)
```

### 2.4 A tela do extrato não tem botão

A pergunta #07 ("quer conferir com o seu extrato?") existe e **não faz
nada** — é uma tela que pergunta e não oferece ação.

**O certo:** essa tela passa a oferecer as **três formas** de trazer o
dinheiro pra dentro, que é o que o Gabriel pediu:

| forma | o que é | estado |
|---|---|---|
| **na mão** | ela lança o gasto quando acontece | já existe (`lancar_sheet`) |
| **importar extrato** | OFX do banco, lido no aparelho | parser existe (`ofx_parser.dart`), **falta tela** |
| **conectar o banco** | Open Finance | **só visual**, decisão do Gabriel: sem servidor não dá |

As três lado a lado, com a diferença dita em uma linha cada. "Conectar o
banco" leva ao fluxo visual e avisa que ainda está chegando — prometer o
que não funciona é pior que dizer que falta.

---

## PARTE 3 — Navegação: a tela principal está escondida

Hoje a barra é: **início · lançamentos · (+) · perfil**, e o histórico
dia a dia só aparece clicando em "ver o mês".

O Gabriel: *"essa tela é a tela principal da maioria dos sistemas de
gestão de dívida, e a gente está tratando ela como secundária"*. Ele tem
razão — é onde a pessoa passa o tempo em qualquer app de finança.

**O certo:** a segunda aba passa a ser o **histórico** (o horizonte com
dias/meses/ano, que já está pronto). Os lançamentos soltos viram um
caminho de dentro dele — um botão no topo, ou tocando o dia.

Ordem nova: **início · histórico · (+) · perfil**.

Isso não joga fora o que foi feito hoje: a tela do horizonte é a mesma,
só muda de lugar e deixa de depender de um toque que ninguém adivinha.

---

## PARTE 4 — Chat e login

### 4.1 O joão do chat está cortado

`features/chat/chat_page.dart:74,110` usa `joao-avatar.png`, que é
**330×330 e já vem cortado na cabeça** (conferido: é um close do rosto).
Esticado a 96px fica o zoom estranho que ele viu.

**O certo:** `joao.png` (897×937, o passarinho inteiro, o mesmo da
abertura) no estado vazio. O avatar pequeno da bolha pode continuar
redondo, mas a arte grande é o bicho inteiro.

### 4.2 O chat abre vazio

Abre com "pergunta aí" e nada mais. O `respostas.dart` **sabe responder**
(diário, parcela, quanto falta) e a pessoa não descobre isso sozinha.

**O certo:** abrir com uma fala do joão e **as perguntas prontas em
botão** ("quanto posso gastar hoje?", "quando eu quito?", "quanto falta
no Nubank?"). Chat sem sugestão é caixa de texto em branco: ninguém
digita.

### 4.3 O login social não faz nada

Hoje só guarda o nome do provedor e segue. O Gabriel quer **ver
funcionando**, mesmo sem servidor.

**O certo:** simular o fluxo inteiro — toca em Google, aparece a folha de
escolher conta, um "entrando...", e volta **com nome e e-mail
preenchidos**. Isso resolve de quebra o item 1.4: quem entra com conta
social já chega com nome, e o "bom dia, Gabriel" passa a ter dono.

Fica claro na tela que é demonstração. Simular sem avisar seria enganar
os 10 testadores.

---

## A ordem de execução

Primeiro o que faz o app **mentir**, depois o que faz ele **sumir com a
informação**, depois o resto.

| # | o quê | por que nessa posição |
|---|---|---|
| 1 | saldo diário (1.1) | o app mostra número errado agora |
| 2 | parcelas inventadas (1.2) + várias dívidas (1.3) | mesma raiz: inventar em vez de perguntar |
| 3 | nome (1.4) + login simulado (4.2) | um resolve o outro |
| 4 | RESULTADO #17 (2.2) | fecha as perguntas; hoje é seco |
| 5 | as três formas de trazer dinheiro (2.4) | destrava a tela que não faz nada |
| 6 | ONBOARDING #32 (2.3) | ensina a usar o que já existe |
| 7 | navegação (parte 3) | tira a tela principal do esconderijo |
| 8 | chat (4.1, 4.2) | o menor impacto dos oito |

Cada item entra com teste e é conferido **no aparelho** antes do commit —
os quatro bugs mais caros desta semana só apareceram rodando, e o do
saldo diário passou por 235 testes verdes sem ninguém notar.
