# Plano — Ingestão de dados bancários no Kitamo

Data: 2026-09-06

## Objetivo

O usuário quer clicar num botão e ver as faturas dele. Este documento registra
como chegar lá sem depender de licença regulatória que a Kitamo não tem.

## Restrição regulatória (pesquisada, não suposta)

Acesso direto às APIs do Open Finance Brasil exige ser **instituição autorizada
a funcionar pelo BCB** (Resolução Conjunta nº 1/2020, art. 6º). O Diretório de
Participantes exige comprovação dessa autorização — **inclusive no Sandbox**:

> "Não é possível efetuar o cadastro em Sandbox sem que a instituição seja uma
> instituição autorizada pelo BCB."

Não existe categoria de "desenvolvedor" ou "participante técnico". Além da
licença: certificação FAPI Brasil Advanced pela OpenID Foundation (US$ 1.000
membros / US$ 5.000 não-membros, validade 12 meses), certificados ICP-Brasil
(BRCAC transporte + BRSEAL assinatura) e contribuição de custeio rateada por PL.

Agregadores (Pluggy, Belvo, Klavi, Celcoin) são Instituições de Pagamento
reguladas que revendem esse acesso. Existem revendas mais baratas, mas todas
são pagas para uso multi-usuário — os planos gratuitos cobrem apenas dados
do próprio titular, o que não serve a um aplicativo.

## Decisão de produto (06/09/2026)

**O Kitamo não vai depender de agregador de terceiro.** Nem pago, nem no plano
gratuito. A ingestão é por arquivo que o próprio usuário baixa do banco dele:
nenhum intermediário vê os dados, não há credencial de banco trafegando, não há
custo recorrente por usuário e não há fornecedor que possa mudar preço ou
encerrar o serviço.

Isso é coerente com o posicionamento que o README já declara: *"Não promete
automação bancária. Foca em controle manual confiável."*

O que o usuário ganha: clica em importar, escolhe o arquivo, confere e confirma.

## Estado atual (o que já existe)

Descoberto na análise — mais adiantado do que parecia:

| Peça | Onde | Estado |
|---|---|---|
| Parser OFX | `app/Services/BankImportParser::parseOfx` | Funciona (regex sobre `<STMTTRN>`) |
| Parser CSV | `app/Services/BankImportParser::parseCsv` | Funciona, detecta separador e cabeçalho PT/EN |
| Preview | `Api/ImportController::preview` | Funciona |
| Commit | `Api/ImportController::commit` | Funciona, com dedup |
| Rotas | `routes/api.php:61-62` | Registradas |
| **Tela** | — | **Não existe. A API está órfã.** |

### Problemas do que existe

1. **Dedup por heurística frágil.** `commit` compara data + valor + descrição
   exata. Dois cafés de R$ 12 no mesmo dia viram um só (falso positivo, perde
   lançamento). Banco mudar a descrição duplica tudo (falso negativo).
2. **Sem origem registrada.** Não dá para saber se um lançamento veio de
   arquivo ou de digitação — nem desfazer uma importação.
3. **OFX ignora o `FITID`**, que é o identificador único que o próprio padrão
   OFX fornece. É a solução do problema 1, de graça.
4. **`current_balance` recalculado por delta** (`+= netDelta`). Se o commit
   rodar duas vezes, o saldo desanda mesmo com dedup funcionando.

## Arquitetura

### Formatos trocáveis

A ingestão é por arquivo. O que varia é o formato, não o fornecedor:

- **OFX/QFX** — traz `FITID`, permite reimportação idempotente. Preferido.
- **CSV** — sem identificador padronizado; dedup por conteúdo com contagem
  de ocorrências.

Se um dia a Kitamo for instituição autorizada pelo BCB, o Open Finance entra
como mais uma fonte, sem reescrever o núcleo.

### Identidade estável de lançamento

`transactions` ganha:
- `origem` — `manual` | `ofx` | `csv`
- `origem_id` — identificador do arquivo de origem (FITID, no OFX)
- índice único composto `(user_id, account_id, origem, origem_id)`

Com isso a reimportação vira *upsert* de verdade, não adivinhação.
Quando não houver id externo (CSV sem identificador), cai na heurística atual
como fallback — mas aí incluindo um contador de ocorrência, para não colapsar
duplicatas legítimas.

## Fases

1. **Fundação** — migration `origem`/`origem_id` + índice; `FITID` no parser OFX;
   dedup por id externo no commit; corrigir recálculo de saldo.
2. **Tela de importação** — a peça que falta para o botão existir. Upload,
   preview com seleção de conta, categorização, confirmação.
3. **Cobertura por banco** — OFX de bancos brasileiros foge do padrão. Cada
   banco que apresentar defeito ganha teste com amostra real e correção no
   parser.

## Notas técnicas apuradas

**Bancos BR emitem OFX fora do padrão.** Toda linguagem acabou mantendo um fork
por causa disso — em PHP, a biblioteca mais usada (`asgrim/ofxparser`, 211k
downloads) está **arquivada desde jul/2024**. O Kitamo tem parser próprio, o que
evita essa dependência morta. A contrapartida é que a robustez vem de teste com
arquivo real de cada banco.

**Encoding é a dor conhecida.** Bancos alternam entre ISO-8859-1 e UTF-8 sem
declarar corretamente no cabeçalho.

**Atrito de onboarding é o risco real do OFX**, não a parte técnica: cada banco
esconde o botão de exportar em um lugar. Mitigação prevista: instruções por
banco na própria tela de importação.
