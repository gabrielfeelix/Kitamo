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
| 09 | Mês dia a dia | **não** | aba "dias" do horizonte · `mes_page.dart` inventada |
| 10 | Horizonte de saldos | **não** | aba "meses" · **a tela que segura as 3 abas** |
| 11 | Horizonte | **não** | aba "ano" · `horizonte_page.dart` inventada |
| 12 | Última parcela | **não** | `quitar/` |
| 13 | Conta não fecha | **não** | `aperto/` inventada |
| 14 | Lançamentos | **não** | `lancamentos/` |
| 15 | Chat | **não** | `chat/` |
| 16 | Perfil | sim | `perfil/perfil_page.dart` |
| 17 | O número | **não** | — · **é a tela de RESULTADO das perguntas** |
| 18 | Lançar | **não** | `lancamentos/lancar_sheet.dart` |
| 19 | Gastei | **não** | idem |
| 20 | Notificações | sim | `avisos/avisos_page.dart` |
| 21 | Dívidas | **não** | `dividas/` |
| 22 | Pra onde vai | **não** | `lancamentos/pra_onde_vai.dart` |
| 23 | Vazio | **não** | — |
| 24 | Editar perfil | sim | `perfil/editar_perfil_page.dart` |
| 25 | Categorias | **não** | — |
| 26 | Contas conectadas | **não** | — |
| 27 | Importar extrato | **não** | `importar/` |
| 28 | Aparência | **não** | — |
| 29 | Sobre a Kitamo | **não** | — |
| 30 | Extrato aplicado | **não** | — |
| 31 | Barro escuro | **não** | — |
| 32 | Primeira vez | **não** | — · **é o onboarding de verdade, 1 de 3** |
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

## As três que são uma só

**#09, #10 e #11 não são três telas: são três abas da mesma.** O design
repete o segmentado `dias | meses | ano` no topo das três. Hoje o app tem
duas telas soltas (`mes_page.dart` e `horizonte_page.dart`, inventadas),
alcançadas por toques que ninguém adivinha — o mensal abre tocando no
cartão da casa. Decisão do Gabriel em 07/09: **juntar numa tela só com as
3 abas**, o "ano" somando os 12 meses.

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

Hoje o app pula do fim das perguntas direto pro Início: seco, sem o
número e sem ensinar nada. As duas telas que faltam são as marcadas.

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

Faltam, nomeados no design system:

célula de saldo · linha de lançamento · segmentado e aba · teclado
numérico · folha de ação · esqueleto · faixa de erro e offline · carimbo
QUITADO · progresso de dívida · a casa em 5 fases
