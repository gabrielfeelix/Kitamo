# Handoff — Kitamo (Flutter)

Escrito em 07/09/2026, ao fim de uma sessão que **errou o principal**.
Leia a seção 1 antes de qualquer outra coisa.

---

## 1. O erro que você tem que corrigir

**O design já estava pronto e não foi usado.**

O Gabriel contratou o Claude Design, que entregou **36 telas completas** em
`/home/gabfelix/dev/finance/design-joao/Kitamo App.dc.html` (210 KB de HTML
com CSS inline). Cada tela é um `<div>` de **390×844px** com layout inteiro
definido: paddings, raios, sombras, hierarquia, posição de cada elemento,
SVGs dos ícones, tamanhos de fonte exatos.

A sessão anterior abriu esse arquivo só para **extrair as cores e os nomes
das fontes** (`grep` de hex e `font-family`) e depois **inventou os
layouts em Flutter**. Nunca leu o markup das telas.

O resultado, na palavra do Gabriel:

> "ficou bem ruim as telas, imagem solta no meio da tela, as primeiras
> super desconexas"

Ele está certo, e a causa não é a compressão de imagens (essa só reduziu o
peso dos PNGs; conferi o `joao.png` depois e o traço está intacto). A causa
é que as telas foram desenhadas por mim, não pelo designer.

### O que fazer

**Para cada tela, leia o HTML correspondente antes de escrever Dart.**

```bash
cd /home/gabfelix/dev/finance/design-joao
python3 - <<'PY'
s = open('Kitamo App.dc.html', encoding='utf-8').read()
i = s.find('INÍCIO · DIA TRANQUILO')   # troque pelo título da tela
print(s[i:i+6000])
PY
```

Os títulos das 36 telas (use como índice):

```
ONBOARDING · UMA PERGUNTA POR TELA · CADA UMA NA SUA COR
FIM DO ONBOARDING · O NÚMERO
PRIMEIRA VEZ NO INÍCIO · PASSO 1 DE 3
INÍCIO · DIA TRANQUILO
HOJE · VOCÊ PASSOU R$ 14,56 DO DIA
BARRO ESCURO · O MESMO INÍCIO
A CONTA NÃO FECHA · ESCOLHER UM CAMINHO
COMO A CONTA É FEITA · A DÚVIDA MAIOR
MÊS · PODE GASTAR × GASTOU × SALDO
HORIZONTE · O ANO INTEIRO
HORIZONTE DE SALDOS · MESES LADO A LADO
ÚLTIMA PARCELA · A CASA FICA DE PÉ
DÍVIDAS · DENTRO DO PERFIL
NOVA DÍVIDA · O CADASTRO
LANÇAR · O QUE ACONTECEU
GASTEI · VALOR PRIMEIRO
DEPOIS DE SALVAR · O RETORNO
PRA ONDE VAI · MOSAICO DE WIDGETS
EXTRATO APLICADO · O PASSO 4
FALAR COM A GENTE · AÇÃO PRINCIPAL
AVISOS · UMA ANATOMIA SÓ
```

Leia também, inteiros:
- `Kitamo Design System.dc.html` (94 KB) — tokens, componentes, regras
- `NavBar.dc.html` — a barra de navegação
- `Kitamo Abertura.dc.html` — o splash

### Detalhes do design que o código atual ignora

Só do trecho da tela Início que li ao escrever este handoff:

- moldura de **390×844**, raio 44, sombra `0 22px 54px rgba(92,46,26,.18)`
- cabeçalho com raio `0 0 34px 34px`, padding `0 24px 26px`
- barra de status falsa com a hora
- **saudação "bom dia, Gabriel" + a data por extenso** — não existe no app
- sino com **ponto vermelho** (`#B23D1B`, borda branca) quando há aviso
- **avatar do joão (48px, redondo) no cabeçalho** — o app hoje joga
  `joao-avatar.png` solto no meio da tela, que é a "imagem solta" da
  reclamação
- ícones em **SVG inline**, não `Icons.` do Material

Isso é uma tela. Faltam 35.

### Como validar

Abra o `.dc.html` no navegador (é HTML puro, abre direto) e ponha lado a
lado com a tela em Flutter. Se não for parecido, não está pronto.

---

## 2. O que presta no que já existe

Não jogue tudo fora. **A lógica está testada e correta** — o problema é só
a camada visual.

`lib/services/` e `lib/repositories/` podem ficar como estão:

| arquivo | o que faz |
|---|---|
| `diario_service.dart` | o número: renda − fixas − parcelas ÷ dias |
| `horizonte_service.dart` | projeção diária nomeada e 12 meses |
| `dia_de_hoje.dart` | gasto real × diário planejado |
| `divida_repository.dart` | CRUD + `quitarParcela` idempotente |
| `banco.dart` | SQLite cifrado, migrations v1→v2 |

**122 testes passando.** Rode antes e depois de qualquer mudança:

```bash
export PATH="$HOME/flutter/bin:$PATH"
flutter test && flutter analyze
```

Regras que os testes guardam (não quebre):

- sobra negativa **não** vira "diário R$ 0" — diz quanto falta
- sobra exatamente zero **não** fecha
- vencimento dia 31 cai no dia 28 em fevereiro, senão a parcela some
- `quitarParcela` é idempotente: toque duplo não baixa duas
- dinheiro em **centavos (int)**, nunca double

---

## 3. Onde está cada coisa

```
/home/gabfelix/dev/kitamo-app/          o app Flutter
/home/gabfelix/dev/finance/design-joao/ O DESIGN (36 telas + design system)
/home/gabfelix/KITAMO-APP/              APKs prontos para instalar
/home/gabfelix/dev/finance/HANDOFF-DESIGN.md   a proposta, tela a tela
```

`flutter` não está no PATH: `export PATH="$HOME/flutter/bin:$PATH"`.

Documentos do projeto: `PLANO-EXECUCAO.md` (fases e decisões),
`SEGURANCA.md` (o que é cifrado e por quê).

---

## 4. Decisões fechadas (não reabrir)

- **Design do Claude Design é a fonte da verdade.** Inclusive a paleta
  escurecida (`barro #A34A24`, `teal #0C7468`, `verde #3F7A3D`), que é mais
  escura que a proposta original de propósito: garante contraste AA
- **Fontes:** Outfit (display/interface) e DM Mono (rótulos maiúsculos)
- **Sem servidor, sem login, sem nuvem.** Backup é arquivo exportado
- **Nunca pedir senha de banco, cartão ou CPF.** É app de projeção
- **Banco local cifrado** (SQLite3MultipleCiphers); chave no Keystore
- **Só mobile.** Web foi removida: SQLite nativo usa `dart:ffi`
- **Personagem:** joão-de-barro. Nunca cobre o número; **some quando a
  conta não fecha** (bicho fofo sobre má notícia é deboche)

---

## 5. Pendências reais

1. **Refazer as telas a partir do HTML** — é o item 1, e é o que importa
2. **Instalação falhou no celular do Gabriel** ("app não foi instalado",
   instalação limpa). Foi enviado um APK de 32 bits e outro de 23 MB via
   chat; a causa provável é arquitetura ou download truncado pelo
   WhatsApp, mas **não foi confirmado em aparelho**
3. **O app nunca rodou em celular.** Minify quebra em runtime, não no
   build — 122 testes verdes não provam que abre
4. Telas do design ainda sem equivalente: "primeira vez no Início"
   (passo 1 de 3), "como a conta é feita", "depois de salvar",
   "extrato aplicado"

---

## 6. Como o Gabriel trabalha

- Quer **ver tela**, não relatório. Vai instalar no celular e olhar
- Pediu commit sempre, com mensagem explicando **por quê**
- Áudio transcrito: "que estamos" = Kitamo; "p r"/"DAPR" = Pierre
- Vai testar com **10 pessoas endividadas** antes de qualquer loja
- Sem caixa: nada que gere custo mensal antes de receita

E o que ele disse nesta sessão, que resume o handoff inteiro:

> "a gente literalmente deixou um DESIGN SYSTEM no documento do claude
> design, vc usou? verificou o que era pra ser cada tela? pq lá já tem o
> visual PRONTO, é só criar"
