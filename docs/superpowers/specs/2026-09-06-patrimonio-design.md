# Módulo de Patrimônio — design

Data: 2026-09-06 · Status: aprovado para planejamento

## Problema

O Kitamo responde bem "quanto entrou e saiu". Não responde "quanto eu tenho".

Hoje "Investimentos" existe só como **categoria de transação**
(`TransactionModal.vue:594`, `NewCategoryModal.vue:39`): o usuário registra que
mandou dinheiro pra lá e o dinheiro some do sistema. Há um tipo `investimentos`
no cadastro de conta (`CreateAccountStep3.vue:43`), mas ele vira uma conta comum
de saldo fixo — sem posição, sem rendimento, sem preço de ativo.

Caso concreto: o Gabriel tem R$ 1.628,47 na caixinha do Mercado Pago. A API do
Pluggy não enxerga esse saldo, e o Kitamo não tem onde guardá-lo. Esse dinheiro
simplesmente não existe no app.

## Princípio: patrimônio ≠ fluxo de caixa

São perguntas diferentes, com dados diferentes, e misturá-las é a origem dos
bugs clássicos do setor.

- **Fluxo de caixa** (existente): transações, faturas, categorias. Movimento.
- **Patrimônio** (novo): posições que você detém. Estoque.

Por isso este módulo **não** reaproveita a tabela `accounts`. Uma posição em
Tesouro Direto não é uma conta: ela tem aporte, rendimento e — em renda variável
— quantidade e preço. Forçar isso em `accounts` reproduziria o erro do Organizze,
onde "conta de investimento" é só um número que o usuário digita.

## Pesquisa de mercado que informou o desenho

- **Pierre** (`pierre.finance`, CloudWalk): 4.8★/~6.9k avaliações, mas **não tem
  módulo de patrimônio real** — a API pública expõe só contas, saldos, transações
  e parcelas. A tela de investimentos é saldo por instituição. O que faz a Pierre
  crescer é ter eliminado a digitação, não a profundidade de carteira.
- **Organizze**: sem módulo de investimento. A própria central de ajuda orienta
  lançar aporte como receita/despesa manual.
- **Kinvo / Gorila**: têm carteira de verdade, mas não têm fluxo de caixa.

**A lacuna:** apps de fluxo de caixa não têm carteira; apps de carteira não têm
fluxo de caixa. O Kitamo já tem o fluxo de caixa maduro — é isso que torna o
módulo defensável.

Três lições do que dá errado no mercado, incorporadas ao desenho:

1. **Aporte vs rendimento é o elemento herói** (Kinvo). Separar "isso eu guardei"
   de "isso o mercado me deu" é a informação mais útil da tela.
2. **Toda informação sincronizada mostra sua idade.** A reclamação nº1 do setor
   é sync silenciosamente velho — usuários da Pierre relatam atraso de uma semana
   sem aviso.
3. **Edição manual sempre disponível, mesmo em ativo sincronizado.** O pior erro
   do Kinvo: usuário PRO vendo dado errado sem poder corrigir (aluguel de ações
   lido como venda corrompia a rentabilidade inteira).

## Decisão: Open Finance próprio está fora de alcance

Investigado a fundo porque foi pedido explicitamente. Conclusão registrada aqui
para não ser reaberta sem fato novo.

**Uma Ltda de software não pode ser participante do Open Finance Brasil.** A
Resolução Conjunta nº 1/2020, Art. 1º, delimita o regime a "instituições
financeiras, instituições de pagamento e demais instituições autorizadas a
funcionar pelo Banco Central". Participação voluntária (Art. 6º) é opção de quem
já é licenciado.

| Requisito | Valor |
|---|---|
| Capital mínimo (Res. Conj. 14/2025) | R$ 9,2M – R$ 32,8M |
| ITP especificamente | ~R$ 17M (~R$ 30M com PL) |
| Autorização BCB | 6–18 meses |
| Certificação FAPI (OIDF) | USD 1.000–5.000 |

Agravantes: não há sandbox oficial sem licença (o cadastro no Diretório exige
comprovação de autorização BCB até para homologação); e receber dados obriga a
transmitir (Art. 6º §3º).

**A Pluggy já é o trilho oficial.** Pluggy Brasil Instituição de Pagamento LTDA,
CNPJ 37.943.755/0001-30, licenciada como ITP. Os dados já importados *são* os
dados oficiais do Open Finance. Alternativas a cotar: Tecnospeed (R$ 1.500 +
R$ 540/mês), Belvo (~R$ 6.000/mês).

**Risco a acompanhar:** consulta BCB de março/2026 propõe regras para o modelo
"entidade parceira" — exatamente o arranjo Kitamo↔Pluggy. Ferramentas de gestão
financeira pessoal estão entre os afetados.

## Decisão: cotação automática só onde é legítima

| Classe | Automático? | Fonte | Observação |
|---|---|---|---|
| Cripto | Sim | Binance pública (`data-api.binance.vision`) | Sem chave, sem cláusula de uso pessoal, tempo real |
| CDI/SELIC/IPCA | Sim | BCB SGS | Open data oficial, sem chave |
| Ações / FIIs | **Não** | Manual | BRAPI custa ~R$100–117/mês; sem token não retorna FII |
| Caixinha, CDB, Tesouro | Manual | — | Valor informado pelo usuário |

Descartados por licença: **Finnhub** ("strictly for personal use... can't be used
by any business") e **CoinGecko** (uso comercial exige plano pago). Kitamo é SaaS
pago — usar seria violação contratual, não só limite técnico. Yahoo Finance
retornou HTTP 429 na primeira requisição de teste.

Como as fontes gratuitas não têm SLA, o desenho nunca as trata como palavra
final: último preço fica em cache com data visível, e o campo é editável por
cima. Se a Binance sair do ar, o módulo continua funcionando em modo manual.

## Modelo de dados

### `investments`
A posição.

| Campo | Tipo | Nota |
|---|---|---|
| `id` | ulid | |
| `user_id` | FK | |
| `name` | string | "Caixinha Mercado Pago" |
| `asset_class` | enum | `caixinha`, `cdb`, `tesouro`, `acao`, `fii`, `cripto`, `outro` |
| `institution` | string? | |
| `ticker` | string? | `BTC`, `PETR4` |
| `quantity` | decimal(18,8)? | renda variável |
| `current_value` | decimal(15,2) | valor atual da posição |
| `price_source` | enum | `manual`, `binance`, `bcb` |
| `price_updated_at` | timestamp? | alimenta o indicador de defasagem |
| `is_archived` | boolean | |
| `color`, `icon` | string? | consistente com `accounts`/`goals` |

`current_value` é sempre a verdade exibida. Para ativos sincronizados o job
atualiza; para manuais o usuário edita. Um só campo, uma só fonte de verdade.

### `investment_transactions`
Aportes e resgates — é isto que responde "aportei vs rendeu".

| Campo | Tipo | Nota |
|---|---|---|
| `id` | ulid | |
| `investment_id` | FK | |
| `kind` | enum | `aporte`, `resgate` |
| `amount` | decimal(15,2) | |
| `quantity` | decimal(18,8)? | |
| `unit_price` | decimal(18,8)? | |
| `occurred_on` | date | |
| `transaction_id` | FK? | liga à `Transaction` de caixa, quando houver |

### `investment_prices`
Cache de cotação. `ticker` + `quoted_on` únicos, `price`, `source`. Evita bater
na API a cada page load e preserva o último valor conhecido em caso de falha.

## Regras de negócio

**Rendimento** = `current_value − (Σ aportes − Σ resgates)`.

Derivado em tempo de leitura, nunca persistido — campo derivado no banco
dessincroniza, e a auditoria anterior já corrigiu esse padrão em outros pontos.

**Aporte e o fluxo de caixa.** Registrar um aporte cria a
`investment_transaction` e, com o checkbox "saiu da conta" marcado, também uma
`Transaction` de saída — marcada com a tag **`aporte-investimento`**.

Essa tag é obrigatória. Sem ela o aporte apareceria como despesa nos relatórios,
inventando um gasto que na verdade é dinheiro que continua sendo do usuário. É
exatamente o bug de "fatura contada em dobro" em outra roupa, e o sistema já
resolve o caso análogo com a tag `quitacao-fatura`. Os relatórios devem excluir
`aporte-investimento` do total de despesas, como já fazem com `transferencia`.

**Atomicidade.** Aporte que gera transação de caixa envolve duas escritas em
tabelas diferentes: obrigatoriamente dentro de `DB::transaction`. A auditoria
anterior encontrou perda de dinheiro determinística exatamente por falta disso
no `TransactionController`.

**Patrimônio total** = saldo das contas (`Account::scopeIncludedInNetWorth`, que
já existe) + soma de `current_value` dos investimentos não arquivados.

## Superfície

**Backend**
- `App\Models\Investment`, `InvestmentTransaction`, `InvestmentPrice`
- `App\Http\Controllers\InvestmentController` — CRUD + aporte/resgate
- `App\Services\Patrimonio\PriceProvider` (interface) com implementações
  `ManualPriceProvider`, `BinancePriceProvider`, `BcbPriceProvider`
- `App\Jobs\RefreshInvestmentPrices` — diário; falha não zera posição
- `App\Support\Patrimonio` — cálculo de patrimônio total e rendimento

**Frontend**
- `Pages/Patrimonio/Index.vue` — tela principal
- `Components/InvestmentModal.vue` — cadastro/edição
- `Components/AporteModal.vue` — aporte/resgate
- Card "Patrimônio total" no Dashboard

**Tela de patrimônio**, na ordem:
1. Patrimônio total (número herói)
2. **Aporte vs rendimento** — investido vs valor atual, ganho isolado
3. Composição por classe (donut)
4. Lista de posições, cada uma com valor, rendimento e **"atualizado há X"**

Evolução histórica fica de fora da primeira versão: exige série temporal que
ainda não existe. O job de preço começa a acumulá-la a partir do dia 1.

## Erros e degradação

- API de cotação fora do ar → mantém último preço, exibe a data, nunca zera
- Ticker inválido → posição vira `manual`, avisa o usuário
- Toda posição sincronizada permanece editável à mão
- Excluir investimento com aportes → confirmação explícita; as `Transaction` de
  caixa já geradas **não** são apagadas (são fatos do passado)

## Testes

Unitários (`tests/Unit/`, padrão do repo):
- `PatrimonioTest` — rendimento com aportes, resgates, posição zerada, valores
  negativos
- `AporteTest` — aporte com e sem transação de caixa; tag aplicada; rollback
- `PriceProviderTest` — falha de API preserva último preço
- `InvestmentPriceCacheTest` — não refaz requisição no mesmo dia

Verificação de que o relatório exclui `aporte-investimento` do total de despesas.

## Fora de escopo (v1)

- Evolução histórica do patrimônio (falta série temporal)
- Cotação de ações/FIIs (custo)
- Come-cotas, IR, dividendos
- Open Finance de investimentos (Fase 3/4) — entra como `PriceProvider` no dia
  que houver orçamento
- Meta vinculada a investimento — o gancho fica previsto, a ligação não
