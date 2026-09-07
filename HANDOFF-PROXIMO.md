# Handoff — Kitamo (Flutter)

Escrito em 07/09/2026, fim do segundo dia. **Leia a seção 1 e o
`TELAS.md` antes de escrever qualquer linha.**

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

## 2. Estado: 9 de 36 telas

**Prontas do HTML:** abertura, boas-vindas, as 6 perguntas do onboarding,
Início. Mais a barra de navegação.

**Faltam 27.** `TELAS.md` tem a lista com o arquivo de cada uma.

**164 testes passando.** Rode antes e depois de tudo:

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

**Se o design system deu nome a um componente, ele vira widget em
`lib/widgets/` — nunca desenhado dentro da tela.** Ainda faltam: célula de
saldo, linha de lançamento, aviso com faixa de 3px, segmentado e aba,
chave, teclado numérico, folha de ação, esqueleto, faixa de erro, carimbo
QUITADO, progresso de dívida, a casa em 5 fases.

---

## 3. O que o Gabriel pediu e ainda não foi feito

Em ordem de prioridade, tudo dito por ele nesta sessão:

1. **Login social + editar perfil.** Ele quer construir comunidade, não um
   app avulso: *"é interessante porque daí a gente guarda no banco de
   dados os dados de todos eles. se eles precisarem mudar de celular, não
   precisam ficar importando fatura"*.
   **Decisão dele em 07/09: só a tela, sem backend.** Login com Google (e
   talvez Facebook), tela de perfil com trocar nome e foto — visual, dado
   local. Servidor só depois que as 10 pessoas testarem.
   Existe no design: "Perfil" (#16) e "Editar perfil" (#24).

2. **Conectar bancos.** O design **não tem** esse fluxo — só a tela de
   gerenciar contas já conectadas (#26 "Contas conectadas"). Faltam:
   escolher banco numa lista, autorizar, esperando, deu certo/errado.
   **Mesma decisão: só o visual.** Open Finance de verdade precisa de
   servidor e conta paga, e a regra é não gerar custo antes de receita.

3. **Tela de avisos.** Ele tocou no sino e disse: *"a telinha que tem que
   aparecer é outra"*. Refazer a partir de "Notificações" (#20).

4. **As outras 24 telas**, pelo método da seção 1.

---

## 4. O que presta e não se toca

A lógica está testada e correta. `lib/services/` e `lib/repositories/`
ficam como estão:

| arquivo | o que faz |
|---|---|
| `diario_service.dart` | renda − fixas − parcelas ÷ dias |
| `horizonte_service.dart` | projeção diária e 12 meses |
| `dia_de_hoje.dart` | gasto real × diário planejado |
| `divida_repository.dart` | CRUD + `quitarParcela` idempotente |
| `banco.dart` | SQLite cifrado, migrations v1→v3 |

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

## 5. Como ver a tela (o emulador já está pronto)

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

Para pular o onboarding e olhar uma tela direto, crie um
`lib/seed_main.dart` com dados fixos e
`flutter build apk --debug --target=lib/seed_main.dart`. **Apague depois.**

`flutter test test/retrato_test.dart` gera PNG sem emulador, mas sem fonte
de verdade (texto vira caixinha). Serve pra estrutura, não pra tipografia.

---

## 6. Três bugs que só apareceram rodando no aparelho

Teste verde não pega nada disso. **Rode no emulador antes de dizer que
terminou.**

1. **`google_fonts` baixava as fontes da internet.** Sem rede o app caía no
   Roboto e perdia o design inteiro. Agora as fontes vão dentro do APK.
   *Não reintroduza a dependência.*
2. **`DateFormat('EEEE','pt_BR')` lança** se ninguém chamar
   `initializeDateFormatting`. A data do cabeçalho é escrita à mão.
3. **Overflow de 12px deixou um botão intocável.** O app abria e não
   deixava a pessoa sair da primeira tela. Todo layout novo tem teste em
   390×844, 360×640 e 320×568 (`test/boas_vindas_test.dart`).

Botão é `FilledButton`, não `Material`+`InkWell` na mão.

---

## 7. Decisões fechadas (não reabrir sozinho)

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

---

## 8. Como o Gabriel trabalha

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

## 9. Onde está cada coisa

```
/home/gabfelix/dev/kitamo-app/           o app
/home/gabfelix/dev/kitamo-app/apks/      APKs prontos
/home/gabfelix/dev/finance/design-joao/  O DESIGN (36 telas)
```

`flutter` não está no PATH: `export PATH="$HOME/flutter/bin:$PATH"`.

Documentos: `TELAS.md` (o placar das 36), `PLANO-EXECUCAO.md`,
`SEGURANCA.md`, `HANDOFF-DESIGN.md`.
