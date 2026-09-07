# Cole isto numa sessão nova do Claude Code

Sessão de 07/09/2026. O texto abaixo é pra colar inteiro na primeira
mensagem da conversa nova.

---

Leia `/home/gabfelix/dev/kitamo-app/HANDOFF-PROXIMO.md` e `TELAS.md`
antes de escrever qualquer linha. A regra que não se quebra está na
seção 1: **leia o HTML da tela no design antes de escrever Dart.** O
design tem as 36 telas prontas, com padding, raio, sombra e fonte
definidos, em `/home/gabfelix/dev/finance/design-joao/Kitamo App.dc.html`.

Estado: 12 de 36 telas feitas do HTML, 198 testes passando.

**A seção 4 do handoff ("A REALIDADE da pessoa") vale mais que a fila de
telas.** O modelo de dados de hoje não cabe a vida de quem vai usar:
supõe uma dívida plana e um salário só, num dia só. Isso faz o diário
sair errado, não é enfeite. Comece por lá.

## O que fazer, nesta ordem

**0. O modelo de dados, antes das telas.** Duas decisões do Gabriel em
07/09, detalhadas na seção 4 do handoff:

- **Cartão por fora, compras por dentro.** Hoje 3 cartões viram 3
  dívidas soltas e não dá pra saber o que tem dentro de cada fatura. O
  cartão vira uma caixa com as compras parceladas dentro, e ela marca
  **"paguei a fatura"** uma vez pra baixar as parcelas do mês juntas.
  Uma fatura paga = um toque.
- **Várias entradas, cada uma com seu dia.** Hoje é `rendaMensal` +
  `diaRenda`: um valor, um dia. Quem recebe R$ 600 dia 5 e R$ 400 dia 20
  não consegue dizer isso, e o app promete folga em dia sem dinheiro na
  conta. Vira uma lista de entradas (valor, dia, nome), com migration
  que preserva quem já usa.

`DiarioService` e `HorizonteService` passam a ler a lista. **Os testes
de `test/` são a rede: leia antes, e não afrouxe nenhuma regra da seção
7 do handoff** (sobra negativa, dia 31 em fevereiro, centavos em int,
idempotência).

**1. Horizonte numa tela só.** Hoje o app tem duas telas soltas
(`horizonte/mes_page.dart` e `horizonte/horizonte_page.dart`, as duas
inventadas por uma sessão antiga), e se chega nelas por caminhos que
ninguém adivinha: o mensal abre **tocando no cartão barro da casa** no
Início, e o anual num link "ver 12 meses".

No design é **uma tela só** com o segmentado `dias | meses | ano` no
topo. As três abas são três corpos da mesma tela:

- **#09 "Mês dia a dia"** — aba *dias*. Cabeçalho verde com setas de mês,
  o diário em Outfit 30, e a lista com colunas DIA / PODE GASTAR /
  GASTOU / SALDO. Rodapé barro com a média gasta.
- **#10 "Horizonte de saldos"** — aba *meses*. Três colunas de células de
  saldo, mês ao lado de mês, com as abas de mês acima.
- **#11 "Horizonte"** — aba *ano*. Cartão barro "SUA ÚLTIMA PARCELA CAI
  EM", barras horizontais por mês e a legenda de 4 cores no rodapé.

O dado já existe: `HorizonteService.mes()` e `.doze()`. Pro "ano",
some os 12 meses num resumo (decisão do Gabriel em 07/09). As duas telas
atuais somem. O segmentado é componente do design system ("segmentado e
aba") e ainda não existe em `lib/widgets/` — crie lá, não dentro da tela.

**2. Lançamentos (#14) e Pra onde vai (#22)**, do HTML. Decisão dele:
fazer junto com o horizonte, pra ver os gastos no visual certo.

**3. Tela de RESULTADO (#17 "O número").** Hoje, respondida a última
pergunta, o app cai seco no Início. Palavras dele: *"dps q eu respondo
todas as perguntas tem q ter uma tela de RESULTADO pra n ser muito
seco"*. Fundo teal, "PRA QUITAR ATÉ JANEIRO", o número em Outfit 76, o
resumo "você deve R$ X em N dívidas, e entra R$ Y por mês", o aviso de
que tudo foi chute, e os botões "ver meu mês" e "revisar minhas
respostas".

**4. ONBOARDING de verdade (#32 "Primeira vez").** O que ensina a usar o
app, depois do resultado: o Início já preenchido, véu escuro por cima e
balões "1 DE 3 · ESSE NÚMERO". Três passos.

**5. A entrada, a primeira vez que a pessoa abre.** Antes das perguntas,
umas frases com a arte do joão pra acalmar: *"uma dívida não é o fim, na
verdade, é só o começo. Assim como o João, que constrói sua casa de
pouco em pouco"*. **Decisão dele: rola sozinho, como um vídeo** — as
frases sobem com a animação e ela assiste sem tocar. **Com "pular"
visível**, porque nada pode prender a pessoa. Feito em Dart com as artes
que já existem; ele quer tentar criar um vídeo de verdade depois, então
deixe fácil de trocar. Seção 5 do handoff.

**6. O resto das telas**, pelo método da seção 1 do handoff.

## Vocabulário (ele corrigiu em 07/09, não erre)

- **perguntas iniciais** = as 6 telas que perguntam dívida, renda, dia,
  gasto, fixas, extrato. É o que está em `features/onboarding/`. O nome
  da pasta e o `OnboardingController` ficaram errados; não renomeie no
  meio de outra tarefa, mas **nunca chame isso de onboarding em texto de
  tela**.
- **resultado** = a #17, que fecha as perguntas com o número.
- **onboarding** = a #32, que ensina a usar, *depois* de tudo respondido.
- **entrada** = as frases do joão que rolam sozinhas, *antes* de tudo.

## Antes de dizer que terminou

```bash
export PATH="$HOME/flutter/bin:$PATH"
flutter test && flutter analyze
```

E **rode no emulador**, sempre. Teste verde não pega overflow, fonte que
não carrega, nem botão que não responde — os quatro bugs mais caros
desta semana só apareceram no aparelho. A seção 9 do handoff lista todos,
inclusive o de 07/09: campo público em ChangeNotifier não redesenha a
tela, e o toque parece quebrado.

Pra tocar num elemento, **não calcule a coordenada na mão** (isso me fez
caçar bug que não existia). Pergunte ao aparelho:

```bash
adb shell uiautomator dump /sdcard/ui.xml
adb shell cat /sdcard/ui.xml | tr '>' '\n' \
  | grep -oE 'content-desc="[^"]+"[^/]*bounds="[^"]+"'
```

## Como ele trabalha

Quer **ver tela**, não relatório. Instala no celular e olha. APK vai em
`kitamo-app/apks/` e copiado pra `/mnt/c/Users/gabfe/Downloads/`. Commit
sempre, explicando **por quê**. Ele revisa olhando a tela contra o
protótipo e cobra a diferença: se você não abriu o HTML daquela tela,
ele percebe.
