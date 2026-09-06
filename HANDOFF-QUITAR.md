# Handoff — pivô "Quitar"

Cole este arquivo numa sessão nova. Escrito em 06/09/2026 ao fim de uma
sessão de planejamento com Fable 5.1. **A sessão que ler isto executa; a que
escreveu só planejou.**

---

## Leia nesta ordem

1. `docs/superpowers/specs/2026-09-06-kitamo-quitar-design.md` — **o spec
   aprovado.** É a fonte da verdade do que construir.
2. `PROPOSTA-PIERRE.md` — análise do concorrente, identidade, IA sem caixa,
   bugs conhecidos.
3. `PLANO-INGESTAO.md` — por que não usar agregador (decisão fechada).
4. `docs/DESIGN-KITAMO.md` — personagem, paleta, como usar o marrom.
5. `refs/README.md` (concorrentes) e `refs/apps/README.md` (estilo).
6. `HANDOFF.md` — acesso ao servidor, MySQL (limite de 500 conexões/hora!),
   deploy manual. Continua válido.

## Decisões fechadas (não reabrir)

- **Sem agregador de dados bancários.** Nem Pluggy, nem Belvo, nem revenda.
  Ingestão é OFX/CSV que o usuário baixa do banco.
- **Foco da v1: sair da dívida.** Gestão financeira é segundo ato.
- **Núcleo aprovado:** onboarding 5 perguntas → diário pra quitar →
  horizonte com palavras → "quitei essa".
- **Nav:** Início · Lançamentos · + · Chat · Perfil.
- **IA:** insights determinísticos; LLM só no chat, Gemini free tier.
- **Versão antiga preservada:** tag `v1-gestao`.
- **Identidade:** joão-de-barro + teal da marca + barro/terracota + cores de
  estado em tela cheia. Detalhe em `docs/DESIGN-KITAMO.md`.

## Decisões em aberto (perguntar ao Gabriel quando chegar nelas)

- Desenho do joão-de-barro (traço, se tem olho, quão realista) e ícone do app
- `ImportInvoiceModal`: ligar no backend real ou remover (ele prefere ligar)

Personagem e paleta **foram decididos** em 06/09/2026 —
ver `docs/DESIGN-KITAMO.md`. Não reabrir.

## Estado do código

- `main` em `origin`, tag `v1-gestao` no commit anterior a este handoff.
- Importação OFX/CSV funcional com dedup por `FITID` (`73d7d70`), tela em
  `Settings/Importar` (`777a3e9`).
- `/api/ai/chat` e `/api/ai/tips` existem no backend, **sem tela**.
- `ImportInvoiceModal.vue` é fachada (progresso falso, sem API). Está no ar.
- Outro agente trabalhou no módulo de patrimônio nesta mesma data — commits
  `feat(patrimonio): …`. Working tree deve estar limpo ao começar; confira.
- Suíte: 30 erros pré-existentes por falta de `APP_KEY` local nos testes de
  site institucional. Não são regressão. Compare sempre contra a árvore
  limpa antes de concluir qualquer coisa.

## Ordem de execução sugerida

Cada item é um commit. `git add` por arquivo, nunca `-A`.

```
[ ] 0  Migration `dividas` + `perfil_financeiro` + models + factories
[ ] 1  DiarioService: cálculo do diário pra quitar + data de quitação
       (testes: sobra +/0/−, meses 28/30/31, múltiplas dívidas)
[ ] 2  ProjecaoService: projeção diária nomeada + motivo de cor
       (testes: 24 meses × vencimento 1–31 × renda 1–31)
[ ] 3  Onboarding: 6 telas, uma pergunta cada, pulável, voz da marca
[ ] 4  Início: número do dia + horizonte do mês + próxima parcela
[ ] 5  Horizonte 12 meses
[ ] 6  "Quitei essa": marcar parcela, carimbo, contagem
[ ] 7  Nav de 5 itens; Perfil absorve Settings/*
[ ] 8  Lançamentos com chips
[ ] 9  Chat consumindo /api/ai/chat com cache e cota
[ ] 10 Ligar ImportInvoiceModal no backend real
[ ] 11 Quebrar Dashboard.vue → componentes (pode ir junto com 4)
[ ] 12 Parsers por banco — quando os extratos chegarem
```

Itens 0–2 são backend puro com teste. Itens 3–8 aplicam a paleta de
`docs/DESIGN-KITAMO.md`. Item 9 não depende de nada.

## Como o Gabriel trabalha

- Áudio transcrito: "que estamos" = Kitamo; "p r" / "DAPR" = Pierre.
- Quer ver tela, não relatório. Prefere card clicável a aba.
- Vai testar com 10 pessoas antes de qualquer app nativo.
- Sem caixa: nada que gere custo mensal antes de receita.
- Pediu documentação de tudo e commit sempre. Push ao fim de cada bloco.
