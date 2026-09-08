# As 36 telas do design

Fonte da verdade: `/home/gabfelix/dev/finance/design-joao/Kitamo App.dc.html`.

**Como refazer uma tela** — leia o markup dela antes de escrever Dart:

```bash
cd /home/gabfelix/dev/finance/design-joao
python3 - <<'PY'
s = open('Kitamo App.dc.html', encoding='utf-8').read()
i = s.find('data-screen-label="Mês dia a dia"')   # troque o nome
print(s[i:i+6000])
PY
```

Monte a partir de `lib/widgets/` (pecas, campos, barra_de_navegacao) e
`lib/design/`. Não desenhe cartão nem botão na mão: se o design system deu
nome, o widget existe — e se não existir, crie lá, não na tela.

## Estado

| # | tela | feita do HTML | onde |
|---|---|---|---|
| 00 | Abertura | sim | `onboarding/abertura_page.dart` |
| 01 | Boas-vindas | sim | `onboarding/boas_vindas_page.dart` |
| 02 | Quanto deve | sim | `onboarding/onboarding_page.dart` |
| 03 | Quanto entra | sim | idem |
| 04 | Que dia cai | sim | idem |
| 05 | Dia a dia | sim | idem |
| 06 | Contas fixas | **refazer** | idem · virou campo único, o design pede lista |
| 07 | Oferta extrato | sim | idem |
| 08 | Início | sim | `inicio/` |
| 09 | Mês dia a dia | sim | aba "dias" · `horizonte/aba_dias.dart` |
| 10 | Horizonte de saldos | sim | aba "meses" · `horizonte/horizonte_page.dart` segura as 3 |
| 11 | Horizonte | sim | aba "ano" · `horizonte/aba_ano.dart` |
| 12 | Última parcela | **não** | `quitar/` |
| 13 | Conta não fecha | **não** | `aperto/` inventada |
| 14 | Lançamentos | **não** | `lancamentos/` · alcançada de dentro do histórico |
| 15 | Chat | sim | `chat/chat_page.dart` |
| 16 | Perfil | sim | `perfil/perfil_page.dart` |
| 17 | O número | sim | `resultado/resultado_page.dart` |
| 18 | Lançar | **não** | `lancamentos/lancar_sheet.dart` |
| 19 | Gastei | **não** | idem |
| 20 | Notificações | sim | `avisos/avisos_page.dart` |
| 21 | Dívidas | **não** | `dividas/` |
| 22 | Pra onde vai | **não** | `lancamentos/pra_onde_vai.dart` |
| 23 | Vazio | **não** | — |
| 24 | Editar perfil | sim | `perfil/editar_perfil_page.dart` |
| 25 | Categorias | **não** | — |
| 26 | Contas conectadas | **não** | — |
| 27 | Importar extrato | sim | `importar/importar_page.dart` |
| 28 | Aparência | **não** | — |
| 29 | Sobre a Kitamo | **não** | — |
| 30 | Extrato aplicado | **não** | — |
| 31 | Barro escuro | **não** | — |
| 32 | Primeira vez | sim | `primeira_vez/primeira_vez.dart` |
| 33 | Nova dívida | **não** | — |
| 34 | Gasto salvo | **não** | — |
| 35 | Como a conta é feita | **não** | — |

## A #06 está feita, mas está errada

A tela existe e passa nos testes, mas **não é a do design**. O design
manda lista com chave (aluguel, luz, internet), cada linha com nome, dia
e valor. O app tem **um campo de valor único**: a pessoa digita "R$ 900"
e ninguém sabe do que aquilo é feito.

E não basta copiar a lista do design, que é fixa: o Gabriel foi claro em
07/09 que **a pessoa é quem adiciona** — sugestões comuns como atalho,
mais "+ adicionar conta" com nome, valor e dia. Ver a seção 4 do
handoff.

O mesmo vale pra pergunta #04 ("que dia cai"), que hoje aceita **um dia
só** e precisa virar lista de entradas.

## As três que são uma só — FEITO em 07/09

**#09, #10 e #11 não são três telas: são três abas da mesma.** Agora são:
`horizonte/horizonte_page.dart` segura o segmentado e troca o corpo entre
`aba_dias.dart`, `aba_meses.dart` e `aba_ano.dart`. As duas telas
inventadas sumiram (`mes_page.dart` apagada).

Como se chega, agora que o caminho é dito na tela:

| toque | abre |
|---|---|
| "ver o mês", no cartão do mês | aba **dias** |
| o cartão barro da casa | aba **ano** (onde a última parcela aparece) |

O link dizia "ver 12 meses" e abria o mês: virou "ver o mês". A aba "ano"
soma os 12 meses de `HorizonteService.doze()`.

## A ordem das telas de entrada

O caminho completo, do jeito que o design desenhou:

```
Abertura (#00)
  └─ Boas-vindas (#01) ──"já tenho conta"── entrar (não existe no design)
       └─ as 6 perguntas iniciais (#02 a #07)
            └─ RESULTADO · "O número" (#17)      ← FALTA
                 └─ Início (#08)
                      └─ ONBOARDING · "Primeira vez" (#32)  ← FALTA
```

**Feito em 07/09.** O caminho inteiro existe: as perguntas terminam no
resultado (#17), e o Início abre com a #32 por cima, ensinando a usar.

A ordem das perguntas mudou: a primeira agora é o **nome**, porque o
Início dava "bom dia, Gabriel" a alguém que o app nunca perguntou como se
chama. E a última virou **como trazer os gastos**, com os três caminhos.

## Telas que o design não tem

O designer não desenhou o fluxo de **conectar** um banco — só a de
gerenciar as contas já conectadas (#26). Falta:

- escolher o banco numa lista
- autorizar
- esperando / lendo
- deu certo / deu errado

A tela de **entrar** (login social) também não existe no design. Foi
montada com o vocabulário da "01 Boas-vindas" (teal escuro, joão grande,
botão de 52px): `features/conta/entrar_page.dart`. O design já previa o
gancho, o "já tenho conta" da boas-vindas, que antes não levava a lugar
nenhum.

Decisão do Gabriel em 07/09/2026: **fazer só o visual, sem integração.**
Open Finance de verdade precisa de servidor e conta paga, e a regra do
projeto é não gerar custo mensal antes de receita. As telas servem pra
mostrar às 10 pessoas do teste e decidir se vale.

Quando aparecer outra tela que o design não cobre, anote aqui em vez de
inventar em silêncio.

## Componentes do design system

Prontos, em `lib/widgets/`:

Cartao · CartaoDeAcento · FalaDaKitamo · Rotulo · Tile · BotaoPrincipal ·
CampoDeValor · CampoDeTexto · Radio · Checkbox · BotaoSobreAcento ·
BotaoDeContorno · ProgressoDoOnboarding · BarraDeNavegacao ·
**AvisoComFaixa · Chave · LinhaDeLista · GrupoDeLinhas · SetaDeLinha ·
TopoDeTela**

Feitos em 07/09: **CelulaDeSaldo** (`celula_de_saldo.dart`),
**Segmentado** e **AbasDePeriodo** (`segmentado.dart`). O design system é
explícito: *"Pílula troca o modo. Aba com traço troca o período. Nunca as
duas iguais."* Por isso são dois widgets, não um com estilo diferente.

Faltam, nomeados no design system:

linha de lançamento · teclado numérico · folha de ação · esqueleto ·
faixa de erro e offline · carimbo QUITADO · progresso de dívida · a casa
em 5 fases
