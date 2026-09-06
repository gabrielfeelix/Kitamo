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
reguladas que revendem esse acesso. Pluggy: a partir de R$ 2.500/mês.

**Consequência:** o caminho soberano e gratuito hoje é arquivo (OFX/CSV).
Agregador entra quando houver receita que o pague.

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
2. **Sem origem registrada.** Não dá para saber se um lançamento veio de OFX,
   Pluggy ou digitação — nem desfazer uma importação.
3. **OFX ignora o `FITID`**, que é o identificador único que o próprio padrão
   OFX fornece. É a solução do problema 1, de graça.
4. **`current_balance` recalculado por delta** (`+= netDelta`). Se o commit
   rodar duas vezes, o saldo desanda mesmo com dedup funcionando.

## Arquitetura

### Contrato `ProvedorDadosBancarios`

O núcleo do app nunca conhece "Pluggy" nem "OFX". Implementações trocáveis:

- `ArquivoProvider` (OFX/CSV) — soberano, grátis, hoje
- `PluggyProvider` — uso pessoal do Gabriel agora; produto quando houver receita
- futuro: qualquer agregador, ou Open Finance direto se a Kitamo for regulada

Trocar de fornecedor = escrever uma classe. Não refatorar o app.

### Identidade estável de lançamento

`transactions` ganha:
- `origem` — `manual` | `ofx` | `csv` | `pluggy`
- `origem_id` — id externo (FITID no OFX, transaction id no Pluggy)
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
3. **Contrato + `ArquivoProvider`** — extrair a lógica atual para trás do
   contrato, sem mudar comportamento.
4. **`PluggyProvider` (só user_id=1)** — comando artisan + botão, disparo manual.
   Não é feature de produto: é ferramenta do Gabriel, dentro do uso pessoal
   permitido pelo plano gratuito.

## Limitação conhecida do Pluggy (registrada para não reaprender)

O conector MeuPluggy **não aceita refresh via API** (`MeuPluggy item cant be
updated`). A sincronização parte do app meu.pluggy.ai, manualmente. Portanto
não existe "puxar sozinho" de verdade por esse caminho — o cron leria dados
velhos. Por isso o disparo é botão, não agendamento.
