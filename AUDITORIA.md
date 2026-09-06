# Auditoria Técnica — Kitamo

Data: 06/09/2026 · Escopo: todas as páginas em `resources/js/Pages/` e controllers correspondentes.

## Padrão de fundo

A mesma regra financeira está reimplementada em vários lugares e as cópias
divergiram: **dois** ciclos de fatura (PHP e TypeScript), dois motores de
recorrência, quatro cálculos de percentual de cartão, dois vocabulários de
status de meta, quatro fórmulas de saldo.

Em paralelo, há bastante backend correto que nunca foi conectado à UI.

## CRÍTICOS

| # | Local | Achado |
|---|---|---|
| C1 | `CreditCardController.php:77` | `ceil($monthDays/2)` faz o ciclo **pular e duplicar meses** (closing_day 13–15). Compras de 16/11–15/12 não aparecem em fatura nenhuma |
| C2 | `CreditCards/Show.vue:75-104` | Ciclo reimplementado em TS, divergindo **1 mês** do backend. Usuário vê dezembro, servidor quita janeiro |
| C3 | `TransactionController.php:614` + `CreditCardController.php:120` | Despesa faz `current_balance -= amount`; `limite_usado = current_balance` → **usado sempre R$ 0** |
| C4 | `Dashboard.vue:512` | `ProjecaoService` (466 linhas corretas) **nunca é chamado**. Widget "Projeção 30 dias" mostra histórico |
| C5 | `Dashboard.vue:238-250` | Barras com `Math.abs()` e paleta só-verde: **−R$ 5.000 é idêntico a +R$ 5.000** |
| C6 | `Dashboard.vue:131-136` | "Entrou"/"Saiu" somam **todos os tempos**, incluindo cartão e pendentes, sob um "Saldo Total" que é caixa-hoje |
| C7 | `Dashboard.vue:268-289` | "Próximas contas" ordena ascendente → mostra as **3 mais atrasadas** |
| C8 | `NotificationPreferencesController.php:26` | `fill()` descarta os 9 campos `notif_*` (fora do `$fillable`) e **responde 200 "salvo"** |
| C9 | `Settings/Backup.vue:20-44` | Tela **100% mockup**. "Sincronizado / Hoje às 14:30" é hardcoded |
| C10 | `BackupService.php:188-204` | `restaurarBackup` faz **wipe irreversível** sem confirmação |
| C11 | `CategoryController.php:88` | Deletar categoria **orfana o histórico** (`category_id = NULL`), sem undo |
| C12 | `Goals/Show.vue:41` | Divisão por zero → renderiza **"NaN%"** |
| C13 | `Goals/Show.vue:90-118` | Depósito e débito **não-atômicos**, `catch` vazio → meta creditada sem sair da conta |
| C14 | `Goals/Edit.vue:37-40` | Campos `ref` não-reativos → salvar **sobrescreve a meta** com placeholders |
| C15 | `routes/web.php:280-281` | Rota `{notification}` antes de `limpar-lidas` → **"Limpar lidas" sempre 404** |
| C16 | `Accounts/Index.vue:189-203` | Marcar parcela 7/12 como paga **a renomeia para "Parcela 1/12"** |
| C17 | `AccountController.php:159-184` | Excluir conta **não estorna transferências** → saldo fantasma na contraparte |
| C18 | `Accounts/Show.vue:173-177` | Alerta "gastou mais do que tinha" dispara com R$ 50.000 positivos |
| C19 | `Settings.vue:14-15` | Fallback de PII: `?? 'Gabriel Felix'` / `?? 'gab.feelix@gmail.com'` (7 arquivos) |

## ALTOS (seleção)

- `CreditCardController.php:395` — pagar fatura **não reduz o limite usado**
- `TransactionController.php` — **nenhum `DB::transaction`** apesar de mutar saldos; `return 422` na linha 437 acontece após o estorno → perde dinheiro
- `RecorrenciaScheduler.php:13` — `addMonthNoOverflow` **degrada o dia permanentemente** (31 → 28 e nunca volta)
- `TransactionController.php:216` — `data_pagamento = now()` → histórico importado colapsa no mês atual
- `RecalculateAccountBalances.php:20` — **cartões nunca são recalculados**, C3 é permanente
- `Analysis.vue:95` — período travado em `'month'`, lógica de 3 meses/ano é código morto
- `payInvoice` — cria nova despesa do total enquanto as compras originais permanecem → **fatura conta em dobro**
- **Transferências não geram `Transaction`** → invisíveis no extrato, mas mexem no saldo

## O que está bom

- **Zero IDOR** em toda a auditoria — todos os controllers checam `user_id`
- `TransferenciaController::executar` — atomicidade e locks exemplares
- `ProjecaoService`, `BackupService`, `ExportController`, `SyncGoalProgress`
- `Profile/Edit.vue` e `DeleteUserForm.vue` — melhor código do repositório
- `MobileShell`/`DesktopShell` cobertos em todas as páginas

## Ordem sugerida

**Bloqueiam uso real:** C1+C2 (unificar ciclo em PHP, teste 24 meses × closing_day 1–31) · C3 · C8 · C9/C10 · C11 · C12 · C15 · C19

**Alto impacto, baixo custo:** `DB::transaction` em `TransactionController` e `payInvoice` · `data_pagamento = $date` · extrair `parseISODate` para `lib/` · ligar ou remover o widget de projeção

**Estrutural:** materializar transferências como `Transaction` · recalcular saldo da fonte em vez de incrementar · eliminar implementações duplicadas · conectar ou remover backend órfão
