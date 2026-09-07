# Handoff — Kitamo (Flutter)

Escrito em 07/09/2026, fim do segundo dia. **Leia as seções 1, 2 e 4 e o
`TELAS.md` antes de escrever qualquer linha.** A seção 4 é a que muda o
modelo de dados: ela vale mais que qualquer tela da fila.

---

## 1. A regra que não se quebra

**Leia o HTML da tela antes de escrever Dart.**

O design não é referência de cor: são **36 telas prontas**, cada uma um
`<div>` de 390×844 com layout inteiro definido — padding, raio, sombra,
posição de cada elemento, SVG dos ícones, tamanho de fonte exato.

```bash
cd /home/gabfelix/dev/finance/design-joao
python3 - <<'PY'
s = open('Kitamo App.dc.html', encoding='utf-8').read()
i = s.find('data-screen-label="Mês dia a dia"')   # troque o nome
print(s[i:i+6000])
PY
```

Os nomes das 36 telas e o placar de quais já foram feitas estão em
**`TELAS.md`**. Atualize esse arquivo a cada tela.

Uma sessão anterior fez `grep` de hex e `font-family` e inventou o resto.
O Gabriel resumiu assim: *"a gente literalmente deixou um DESIGN SYSTEM no
documento do claude design, vc usou? pq lá já tem o visual PRONTO, é só
criar"*. Não repita.

Leia inteiros, uma vez, antes de começar:
- `Kitamo Design System.dc.html` — tokens, componentes, voz, movimento
- `NavBar.dc.html`, `Kitamo Abertura.dc.html`

---

## 2. Como chamar as coisas (o Gabriel corrigiu em 07/09)

**O que a gente vinha chamando de "onboarding" não é onboarding.**

- **perguntas iniciais** — as 6 telas que perguntam dívida, renda, dia,
  gasto, contas fixas, extrato. É o que existe hoje em
  `features/onboarding/`. O nome da pasta e a classe `OnboardingController`
  ficaram errados; **não renomeie no meio de outra tarefa**, mas saiba que
  o texto de tela nunca deve chamar isso de onboarding.
- **resultado** — a tela que fecha as perguntas mostrando o número. É a
  **#17 "O número"** do design. **Não existe no app.**
- **onboarding de verdade** — o que ensina a usar o app *depois* de tudo
  respondido. É a **#32 "Primeira vez"**: véu escuro sobre o Início já
  preenchido, com balões "1 DE 3". **Não existe no app.**

Palavras dele: *"isso q a gente tá chamando de onboarding n é onboarding.
são as perguntas iniciais, onboarding é dps q eu respondi tudo oq vai me
ensinar a usar o app"*.

---

## 3. Estado: 12 de 36 telas

**Prontas do HTML:** abertura, boas-vindas, as 6 perguntas iniciais,
Início, **Perfil (#16), Editar perfil (#24), avisos (#20)**. Mais a barra
de navegação e a tela de **entrar**, que o design não tem.

**Faltam 24.** `TELAS.md` tem a lista com o arquivo de cada uma.

**198 testes passando.** Rode antes e depois de tudo:

```bash
export PATH="$HOME/flutter/bin:$PATH"
flutter test && flutter analyze
```

### Componentes prontos — use, não redesenhe

`lib/design/` — Cores, Tipo (54/32/19/14.5), Medidas (raio, sombra, duração)
`lib/widgets/pecas.dart` — Cartao, CartaoDeAcento, FalaDaKitamo, Rotulo,
Tile, BotaoPrincipal
`lib/widgets/campos.dart` — CampoDeValor, CampoDeTexto, Radio, Checkbox,
BotaoSobreAcento, BotaoDeContorno, ProgressoDoOnboarding
`lib/widgets/barra_de_navegacao.dart` — a barra com o joão no centro
`lib/widgets/moeda.dart` — dinheiro(), FormatadorDeDinheiro, lerDinheiro

`lib/widgets/listas.dart` — AvisoComFaixa (a faixa de 3px), Chave,
LinhaDeLista, GrupoDeLinhas, SetaDeLinha
`lib/widgets/topo_de_tela.dart` — o voltar de 36px com título, das telas
internas

**Se o design system deu nome a um componente, ele vira widget em
`lib/widgets/` — nunca desenhado dentro da tela.** Ainda faltam: célula de
saldo, linha de lançamento, segmentado e aba, teclado numérico, folha de
ação, esqueleto, faixa de erro, carimbo QUITADO, progresso de dívida, a
casa em 5 fases.

---

---

## 4. A REALIDADE da pessoa (o assunto mais importante, 07/09)

O Gabriel parou tudo pra dizer isto, e é a maior dívida técnica do
projeto. **O modelo de dados de hoje não cabe a vida de quem vai usar.**

Palavras dele: *"ela está endividada, mas e se a dívida é nos 3 cartões?
e se ela recebe em varios dias diferentes um pouquinho cada? como vou
marcar que paguei cada divida de cada cartão diferente?"*

### O que não cabe hoje

| a vida real | o que o app assume |
|---|---|
| dívida em 3 cartões, cada um com várias compras parceladas | `Divida` é plana: nome, parcela, um dia. 3 cartões viram 3 dívidas soltas, sem saber o que tem dentro |
| recebe R$ 600 dia 5, R$ 400 dia 20, bico dia 28 | `rendaMensal` + `diaRenda`: **um valor, um dia só** |
| "paguei a fatura do Nubank" | `quitarParcela(id)` baixa uma parcela da dívida inteira; não existe "esta compra dentro desta fatura" |
| aluguel, luz, internet, consórcio, cada um com seu dia | `contasFixasEstimadas`: **um número só**, digitado de cabeça |

Isso não é detalhe de tela: **o diário sai errado.** O
`DiarioService` divide o mês supondo que todo o dinheiro entra num dia
só. Pra quem recebe partido, o app promete folga em dia que ainda não
tem dinheiro na conta.

### As três decisões dele, em 07/09

**1. Cartão por fora, compras por dentro.** O cartão é uma caixa; as
compras parceladas moram dentro. Ela marca **"paguei a fatura"** uma vez
e todas as parcelas daquele mês baixam juntas — é como a fatura chega na
vida real, e é o que ela entende sem explicação.

```
Nubank · vence dia 4
  R$ 1.534,06   [paguei a fatura]
  ├─ geladeira   4/10
  ├─ notebook    2/12
  └─ mercado     1/3
```

Precisa de: uma entidade **cartão/credor** com dívidas dentro, e um
`quitarFatura(cartaoId, mes)` que baixe as parcelas do mês em transação
(idempotente, como o `quitarParcela` já é — não deixe meio caminho).
A tela #26 "Contas conectadas" e a #21 "Dívidas" do design são o lugar
disso.

**2. Várias entradas, cada uma com seu dia.** Ela cadastra quantas
quiser: salário dia 5, bico dia 20, pensão dia 15. O diário passa a
considerar **quando cada dinheiro entra**, não um dia só.

```
o que entra no seu mês
  salário   R$ 1.800   dia 5
  bico      R$ 600     dia 20
  pensão    R$ 400     dia 15
  [+ adicionar entrada]
```

Precisa de: tabela de **entradas** (valor, dia, nome), migration v5
mantendo `rendaMensal`/`diaRenda` de quem já usa (vira uma entrada só), e
o `DiarioService` e o `HorizonteService` lendo a lista em vez do par.
**Os testes que guardam o diário são a rede de segurança — leia
`test/` antes de mexer, e não afrouxe nenhuma regra da seção 5.**

A pergunta "que dia cai" (#04) vira uma tela de lista, não um número só.

**3. As contas fixas são dela, não da lista.** Ele foi direto:
*"n podemos só escolher pela pessoa, ela que vai escolhendo e
adicionando e colocando o valor do fixo (...) n podemos só setar por ela
ok?"*.

Hoje a pergunta #06 é **um campo de valor único**: ela digita "R$ 900" e
acabou. Não escolhe nada, não lista nada, e ninguém (nem ela) sabe do
que aquele número é feito. Quando o valor muda, ela tem que recalcular
de cabeça e digitar de novo.

O design manda **lista com chave**: aluguel, luz, internet, cada linha
com nome, dia e valor, ligando e desligando. *"marque o que sai todo mês
no mesmo dia."*

**Mas a lista do design é fixa, e só isso não basta.** Se as opções são
prontas, o app continua escolhendo por ela: quem tem consórcio, pensão,
mensalidade de escola ou plano de saúde fica de fora e volta a chutar um
total. Então:

- as sugestões comuns aparecem como atalho (aluguel, luz, água,
  internet, telefone) — **sugestão, não catálogo fechado**
- **"+ adicionar conta"** sempre visível, onde ela põe **nome, valor e
  dia** que quiser
- cada conta é uma linha editável e apagável depois, no Perfil
- o total é **soma do que ela cadastrou**, nunca um número digitado solto

Precisa de: tabela de **contas fixas** (nome, valor em centavos, dia),
migration preservando o `contasFixasEstimadas` de quem já usa (vira uma
conta só, "contas fixas", com o valor atual), e o `DiarioService`
somando a lista.

É o mesmo princípio das entradas e dos cartões: **o app pergunta, a
pessoa responde. O app não decide pela pessoa.**

### A interface tem que ser fácil nesse sentido

Palavras dele: *"a interface tem que ser fácil pra ele entender nesse
sentido"*. Quem está endividado não vai montar planilha: se marcar o que
pagou der trabalho, ela para de marcar e o app morre em duas semanas.
Uma fatura paga = **um toque**.

---

## 5. A primeira vez que a pessoa abre (07/09)

Antes das perguntas, ele quer acalmar. Palavras dele: *"seria legal
fazermos algo bem legal... talvez verticalmente umas frases bacanas com
imagens (...) uma dívida não é o fim, na verdade, é só o começo. Assim
como o João, que constrói sua casa de pouco em pouco"*.

**Decisão dele: rola sozinho, como um vídeo.** As frases sobem com a
animação e ela assiste sem tocar. **Ponha um "pular" visível** — quem já
quer começar não pode ficar preso, e isso é regra do design system
(nada que prenda a pessoa).

- Escrito em Dart, com as artes que já existem (`joao*.png`, `casa-1..5`)
- A casa subindo de fase é a metáfora inteira: dívida não é o fim, é o
  começo, e a casa se levanta de pouco em pouco
- Termina apresentando as perguntas: "pra montar seu plano, a gente
  precisa saber três coisas"
- Ele se ofereceu pra criar um vídeo de verdade depois. Deixe a versão
  em Dart pronta e fácil de trocar; vídeo pesa no APK e depende dele

Isto é a **entrada**, e vem antes das perguntas iniciais. Não confunda
com o **onboarding** (#32), que ensina a usar o app depois de tudo
respondido.

---

## 6. O que o Gabriel pediu e ainda não foi feito

Em ordem de prioridade, tudo dito por ele nesta sessão:

1. ~~**Login social + editar perfil.**~~ **FEITO em 07/09.** A tela de
   entrar (`features/conta/entrar_page.dart`) sai do "já tenho conta" da
   boas-vindas, com Google e Facebook e o caminho "entrar sem conta". O
   Perfil (#16) e o Editar perfil (#24) vieram do HTML.
   **Não há backend, como ele decidiu.** O provedor, o e-mail e o
   passarinho ficam no banco local (migration v4, colunas anuláveis).
   As marcas do Google e do Facebook são desenhadas em `CustomPainter`,
   não baixadas: sem rede o app não pode perder o botão.
   Quando o servidor existir, o gancho é `OnboardingController.entrouCom`
   e `PerfilRepository.salvar`.

2. **Conectar bancos.** O design **não tem** esse fluxo — só a tela de
   gerenciar contas já conectadas (#26 "Contas conectadas"). Faltam:
   escolher banco numa lista, autorizar, esperando, deu certo/errado.
   **Mesma decisão: só o visual.** Open Finance de verdade precisa de
   servidor e conta paga, e a regra é não gerar custo antes de receita.

3. ~~**Tela de avisos.**~~ **FEITA em 07/09**, do "Notificações" (#20):
   seções HOJE e ANTES, cartão com faixa de 3px, "marcar lidos" e o fecho
   "SÓ ISSO. VOCÊ ESTÁ EM DIA.". A lógica de `avisos.dart` continua a
   mesma (calculada na abertura, nunca guardada); ela só ganhou o que a
   tela precisa: faixa, quando, ícone e ação.

4. **O horizonte numa tela só.** Ele perguntou como chega nas telas de
   diário/mensal/anual, e tinha razão em estranhar. **Elas existem e estão
   ligadas, mas por caminhos que ninguém adivinha:**

   | tela | como se chega hoje |
   |---|---|
   | Horizonte (12 meses) | Início, link "ver 12 meses" no cartão do mês |
   | Mês dia a dia | Início, tocando **no cartão barro da casa** |
   | Pra onde vai | dentro da aba Lançamentos |

   O mensal abrir ao tocar na **casa** é o pior: nada no cartão avisa.

   **No design é uma tela só**: "horizonte de saldos" (#10) com o
   segmentado `dias | meses | ano` no topo. As três abas são três corpos
   da mesma tela: #09 (dias, cabeçalho verde, colunas DIA/PODE
   GASTAR/GASTOU/SALDO), #10 (meses lado a lado em 3 colunas) e #11 (ano,
   barras por mês + cartão barro "SUA ÚLTIMA PARCELA CAI EM").

   **Decisão dele em 07/09: fazer a tela única com as 3 abas**, e o "ano"
   soma os 12 meses num resumo. O dado já existe:
   `HorizonteService.mes()` e `.doze()`. As duas telas atuais
   (`horizonte_page.dart` e `mes_page.dart`, ambas inventadas) somem.

5. **Lançamentos (#14) e Pra onde vai (#22)**, do HTML. Decisão dele:
   fazer junto com o horizonte. O #22 tem o cartão grande de "parcelas de
   dívida" com % do que entra, quatro cartões de categoria em grade 2x2 e
   a fala do joão no rodapé.

6. **Tela de resultado (#17 "O número").** Hoje, respondida a última
   pergunta, o app cai seco no Início. Palavras dele: *"dps q eu respondo
   todas as perguntas tem q ter uma tela de RESULTADO pra n ser muito
   seco"*. Ele suspeitou que já existia no design, e **existe**: fundo
   teal, "PRA QUITAR ATÉ JANEIRO", o número em Outfit 76, o resumo "você
   deve R$ X em N dívidas, e entra R$ Y por mês", o aviso de que tudo foi
   chute, e dois botões: "ver meu mês" e "revisar minhas respostas".

7. **Onboarding de verdade (#32 "Primeira vez").** O que ensina a usar,
   depois do resultado: o Início já preenchido, véu escuro por cima e
   balões "1 DE 3 · ESSE NÚMERO" explicando de onde vem o número. Três
   passos.

8. **As outras telas**, pelo método da seção 1.

---

## 7. O que presta e não se toca

A lógica está testada e correta. `lib/services/` e `lib/repositories/`
ficam como estão:

| arquivo | o que faz |
|---|---|
| `diario_service.dart` | renda − fixas − parcelas ÷ dias |
| `horizonte_service.dart` | projeção diária e 12 meses |
| `dia_de_hoje.dart` | gasto real × diário planejado |
| `divida_repository.dart` | CRUD + `quitarParcela` idempotente |
| `banco.dart` | SQLite cifrado, migrations v1→v4 |

Regras que os testes guardam (não quebre):

- sobra negativa **não** vira "diário R$ 0" — diz quanto falta
- sobra exatamente zero **não** fecha
- vencimento dia 31 cai no dia 28 em fevereiro
- `quitarParcela` é idempotente
- dinheiro em **centavos (int)**, nunca double
- **sem travessão e sem emoji** em texto de tela (`test/voz_test.dart` lê
  o código-fonte e falha se voltar)
- **todo valor com centavo**: "R$ 2" parece número cortado

---

## 8. Como ver a tela (o emulador já está pronto)

```bash
export ANDROID_HOME=$HOME/.local/opt/android-sdk
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"
emulator -avd kitamo -no-window -no-audio -gpu swiftshader_indirect &
# espere: adb shell getprop sys.boot_completed  -> 1

cd /home/gabfelix/dev/kitamo-app
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb shell monkey -p br.com.kitamo.kitamo -c android.intent.category.LAUNCHER 1
adb exec-out screencap -p > /tmp/tela.png
```

**Armadilha de coordenada que me custou meia hora:** o screenshot vem
1080×2400, mas o leitor de imagem exibe a 2000px de altura. Para tocar num
elemento visto na imagem, **multiplique o y por 1,2**. Um botão em y=1720
da imagem está em y=2064 no aparelho. Eu achei que o botão estava quebrado
por causa disso.

**Não faça essa conta na mão.** Em 07/09 ela me fez tocar em "começar"
achando que era "já tenho conta", e eu quase saí caçando bug que não
existia. Pergunte a posição ao aparelho:

```bash
adb shell uiautomator dump /sdcard/ui.xml
adb shell cat /sdcard/ui.xml | tr '>' '\n' \
  | grep -oE 'content-desc="[^"]+"[^/]*bounds="[^"]+"'
```

Sai `bounds="[74,2127][1006,2253]"` — toque no centro. Se o dump devolver
`null root node`, o app está em transição: espere e repita.

Para pular o onboarding e olhar uma tela direto, crie um
`lib/seed_main.dart` com dados fixos e
`flutter build apk --debug --target=lib/seed_main.dart`. **Apague depois.**

`flutter test test/retrato_test.dart` gera PNG sem emulador, mas sem fonte
de verdade (texto vira caixinha). Serve pra estrutura, não pra tipografia.

---

## 9. Bugs que só apareceram rodando no aparelho

Teste verde não pega nada disso. **Rode no emulador antes de dizer que
terminou.**

1. **`google_fonts` baixava as fontes da internet.** Sem rede o app caía no
   Roboto e perdia o design inteiro. Agora as fontes vão dentro do APK.
   *Não reintroduza a dependência.*
2. **`DateFormat('EEEE','pt_BR')` lança** se ninguém chamar
   `initializeDateFormatting`. A data do cabeçalho é escrita à mão.
3. **Overflow de 12px deixou um botão intocável.** O app abria e não
   deixava a pessoa sair da primeira tela. Todo layout novo tem teste em
   390×844, 360×640 e 320×568 (`test/boas_vindas_test.dart` e
   `test/perfil_avisos_layout_test.dart`).
4. **`copyWith` com `??` não apaga campo.** Esvaziar o nome em "Editar
   perfil" não apagava nada: `nome: null` caía no valor antigo. Por isso
   existe `PerfilFinanceiro.copyWith(limparNome: true)`.
5. **Dinheiro formatado na mão sai errado.** O aviso mostrava
   "R$ 1534,06" sem o ponto de milhar. Use sempre `dinheiro()` de
   `widgets/moeda.dart`, nunca `toStringAsFixed`.
6. **Campo público em ChangeNotifier não redesenha a tela.** Tocar no dia
   do vencimento não pintava nada: `diaRenda` era campo solto, gravava o
   valor e não avisava ninguém. Pra quem usa, "o botão não funciona" —
   e nenhum teste de lógica pega, porque o valor chega no controller.
   Corrigido em 07/09 com setter + `notifyListeners`, e preso por teste
   em `test/onboarding_test.dart`. **Todo campo do controller que a tela
   desenha precisa de setter.** Confira os outros antes de confiar.

Botão é `FilledButton`, não `Material`+`InkWell` na mão.

---

## 10. Decisões fechadas (não reabrir sozinho)

- **O design é a fonte da verdade**, incluindo a paleta escurecida
  (`barro #A34A24`, `teal #0C7468`, `verde #3F7A3D`) — mais escura de
  propósito, garante contraste AA
- **Fontes:** Outfit (número e título), Figtree (interface), DM Mono
  (rótulo em caixa alta) — todas dentro do APK
- **Nunca pedir senha de banco, cartão ou CPF**
- **Banco local cifrado**, chave no Keystore
- **Só mobile.** Web foi removida: SQLite nativo usa `dart:ffi`
- **Personagem:** joão-de-barro. Nunca cobre o número; **some quando a
  conta não fecha** (bicho fofo sobre má notícia é deboche)
- **Sem caixa:** nada que gere custo mensal antes de receita
- "sem servidor, sem login, sem nuvem" era decisão fechada, mas o Gabriel
  **reabriu** em 07/09 pedindo login social. Por ora, só a tela
- **O ícone do app** sai de `assets/images/capa-app.png` (pedido dele em
  07/09): o joão no teal. As densidades em
  `android/app/src/main/res/mipmap-*` e o adaptativo em
  `mipmap-anydpi-v26/ic_launcher.xml`, com o fundo chapado `#04827F` e o
  bicho na camada da frente, porque o Android recorta a máscara sozinho.
  O nome sob o ícone é **Kitamo**, com maiúscula

---

## 11. Como o Gabriel trabalha

- Quer **ver tela**, não relatório. Instala no celular e olha
- **Não crie pasta nova.** APKs vão em `kitamo-app/apks/`, e ele pega em
  `C:\Users\gabfe\Downloads\` (copie pra lá — ele usa o Explorador do
  Windows e não acha caminho de WSL fora do projeto)
- Commit sempre, com mensagem explicando **por quê**
- Áudio transcrito: "que estamos" = Kitamo; "p r"/"DAPR" = Pierre
- Vai testar com **10 pessoas endividadas** antes de qualquer loja
- Ele revisa olhando a tela contra o protótipo, e cobra diferença. Se você
  não abriu o HTML daquela tela, ele percebe

---

## 12. Onde está cada coisa

```
/home/gabfelix/dev/kitamo-app/           o app
/home/gabfelix/dev/kitamo-app/apks/      APKs prontos
/home/gabfelix/dev/finance/design-joao/  O DESIGN (36 telas)
```

`flutter` não está no PATH: `export PATH="$HOME/flutter/bin:$PATH"`.

Documentos: `TELAS.md` (o placar das 36), `PLANO-EXECUCAO.md`,
`SEGURANCA.md`, `HANDOFF-DESIGN.md`.
