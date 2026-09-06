# Proposta — o que trazer do Pierre para a Kitamo

Data: 2026-09-06. Base: 25 telas do Pierre (web, mobile web e app Android) e o
código atual da Kitamo em `main`.

---

## 1. Diagnóstico em uma frase

O Pierre não tem mais dados que a Kitamo. Ele tem **uma voz, um personagem e
um chat no centro de tudo** — e a Kitamo já tem o backend do chat pronto, sem
nenhuma tela usando.

O que a Kitamo tem e o Pierre também: contas, cartões, categorias, metas,
patrimônio (recém-construído), recorrências, widgets configuráveis, projeção,
relatórios, backup, dark mode, notificações. Em dados e regra de negócio a
Kitamo está no mesmo nível ou à frente (fatura ≠ dívida, aporte ≠ despesa,
ciclo de fatura com 24 meses de teste).

O que o Pierre tem e a Kitamo não:

| Pierre | Kitamo hoje |
|---|---|
| Chat em linguagem natural sobre os próprios dados | `/api/ai/chat` e `/api/ai/tips` existem, **nenhuma tela chama** |
| Personagem (gato) com voz própria em todo texto | Sem mascote, sem voz; textos neutros de sistema |
| Agentes com nome, personalidade e cadência | `RecurringTransaction`, job diário de cotação — a mesma mecânica, sem cara |
| Logos de marca em assinaturas e transações | Só ícone de categoria |
| Assinaturas como módulo (total/mês, projeção anual, próxima cobrança) | Recorrências existem, não há tela de "assinaturas" |
| Mapa de calor por dia da semana | Não há |
| Estabelecimentos principais (top merchants) | Não há |
| Telas de espera com narrativa | Spinner |
| Ilustração como fundo da home | Fundo sólido |
| WhatsApp como segundo canal | Não há |
| Biometria (app nativo) | Não há app nativo |
| Marketplace de agentes "da comunidade" | Não há |

---

## 2. Bugs e mockups — corrigir antes de qualquer feature

Encontrados no código, não nos prints.

### 2.1 `ImportInvoiceModal` é fachada (ALTO)

`resources/js/Components/ImportInvoiceModal.vue`, ligado em
`Accounts/Index.vue:1144`. Zero chamadas de API. Barra de progresso por
`setInterval`, lista de itens fabricada. Promete leitura de fatura por foto e
câmera. **Está no ar mentindo para o usuário.**

Correção: ligar no `/api/import/preview` + `/commit` reais (corrigidos em
`73d7d70`). Desabilitar câmera com aviso honesto até existir OCR.

### 2.2 APIs órfãs — backend pronto, sem consumidor

- `/api/ai/chat`, `/api/ai/tips` — o chat inteiro
- `/api/import/*` — resolvido em `777a3e9` (tela `Settings/Importar`)

Padrão do projeto: construir API e esquecer a tela. Vale uma varredura de
rotas × consumidores como teste automatizado.

### 2.3 Já corrigidos nesta sessão (registro)

- Dedup de importação colapsava duplicatas legítimas e ignorava `FITID`
- Compra importada em cartão gravava `paid` → fatura sumia
  (`InvoiceCycle::outstandingDebt` só soma `pending`)
- Saldo de cartão somado por delta desandava em reimportação

### 2.4 Pendente: parsers por banco

Aguardando os extratos reais (OFX/CSV) para testar. Riscos conhecidos: encoding
ISO-8859-1 sem declaração, tags fora do padrão, `FITID` ausente em alguns
bancos. Cada banco ganha fixture + teste.

---

## 3. Personalidade — design e comunicação

O Pierre é "lindo e ousado" por quatro decisões, não por acaso:

### 3.1 Um personagem

O gato aparece no logo, no loading, no chat vazio, na biometria, nos agentes,
no banner de upgrade. Cada agente é uma variação dele. **Tudo que fala com o
usuário tem rosto.**

Proposta: a Kitamo precisa de um personagem. Não precisa ser gato. Precisa
ter (a) uma forma reconhecível em 24px e em tela cheia, (b) variações de
expressão para loading / vazio / erro / sucesso, (c) nome. O nome vira a voz
do chat e dos agentes.

Decisão do Gabriel. O resto desta seção depende dela.

### 3.2 Uma voz

Pierre fala em primeira pessoa e fala com você:

- "Para eu encontrar oportunidades de economia, preciso ver como você gasta."
- "Ei, seu dinheiro tem algo a dizer hoje."
- "Gabriel, suas transferências subiram 324% e seu saldo tá negativo. Fica de olho!"
- "Isso te diz alguma coisa?"

Kitamo hoje: "Nenhum lançamento encontrado." / "Não foi possível carregar."

Proposta: um guia de voz de uma página (tom, pessoa gramatical, o que nunca
dizer) e reescrita dos textos de: home vazia, loading, erros, toasts, onboarding,
notificações. É trabalho de copy, custa pouco e muda a percepção inteira.

### 3.3 Dark-first com um acento

Preto `#0A0A0A`, cards `#141414`, um único acento (verde-limão `#C8F135`).
Tipografia grande nos números. Sem gradientes, sem sombras coloridas.

Kitamo: dark mode existe, mas o design é light-first (`--bg-page: #F8FAFC`)
com teal `#14B8A6`. Não precisa virar preto — mas precisa escolher **um** lado
como principal e polir. Hoje as duas paletas são "a mesma tela com cores
trocadas".

### 3.4 Ilustração como cenário

A home do app tem uma cena inteira atrás do "Bom dia, Gabriel". Os agentes
têm retratos. O upgrade tem banner ilustrado. É o que separa "produto" de
"planilha bonita".

Proposta: 6 a 8 ilustrações no mesmo estilo (home manhã/tarde/noite, vazio,
erro, upgrade, 2–3 personagens de agente). Geradas por IA no estilo escolhido
e revisadas — custo baixo, impacto alto.

---

## 4. Navegação — menos abas, mais tela

Levantamento real:

```
Páginas do app:  32
Nav mobile:       4 itens  (accounts, analysis, dashboard, settings)
Nav desktop:     10 itens  (+ overview, my-cards, goals, patrimonio, admin, notifs)
Dashboard.vue:   1.842 linhas
Accounts/Index:  1.153 linhas
```

O Pierre tem **3 destinos** (Fale com o Pierre / Agentes / Vision) e dentro do
Vision, chips horizontais (Visão geral / Transações / Parcelamentos /
Assinaturas / Categorias / Cartões). No app: 4 ícones no rodapé + o chat
flutuante.

O Gabriel está certo: muita coisa na Kitamo é aba que deveria ser card
clicável. O critério:

| Vira card no dashboard (clica e entra) | Continua na nav |
|---|---|
| Transações recentes → Transações | Início |
| Cartões → fatura do cartão | Atividades (transações) |
| Metas → metas | Chat |
| Patrimônio → patrimônio | Perfil/config |
| Categorias → análise por categoria | |
| Assinaturas → assinaturas | |

Proposta concreta:

1. **Nav mobile: 4 itens fixos** — Início · Atividades · [Chat] · Perfil.
   O chat é o botão central destacado, como o Pierre faz com "Pergunte ao
   Pierre" fixo no rodapé.
2. **Nav desktop: sidebar com os mesmos 4 + Admin** quando aplicável.
   Overview, MyCards, Goals, Patrimonio saem da sidebar e viram cards.
3. **Dashboard vira hub de cards clicáveis.** Já existe `HomeWidgetsManager`
   com 6 widgets. Cada widget ganha `>` no canto e leva para a tela cheia.
4. **Chips horizontais na tela de Atividades** (Todas / Entradas / Saídas /
   Parcelamentos / Assinaturas) em vez de páginas separadas.
5. **Quebrar `Dashboard.vue` (1.842 linhas)** em um componente por widget.
   Pré-requisito técnico para 3 e para não quebrar o que funciona.

---

## 5. Features do Pierre, por esforço

Tudo aqui funciona com os dados que a Kitamo já tem. Nada depende de
agregador.

### Baixo esforço (dias)

| Feature | Como |
|---|---|
| **Tela de chat** | Consumir `/api/ai/chat` que já existe. Bolhas, histórico, sugestões de pergunta. É o maior retorno da lista. |
| **Card de destaque com voz** | "Ei, seu dinheiro tem algo a dizer" + 1 insight gerado por `/api/ai/tips`. Topo do dashboard. |
| **Telas de espera narrativas** | Trocar spinner por personagem + texto por etapa. Importação e projeção. |
| **Chips de categoria coloridos** na lista de transações | Já há cor por categoria; é layout. |
| **Reescrita de copy** | Seção 3.2. |
| **Botão de chat flutuante** | Fixo no rodapé mobile; ícone na sidebar desktop. |

### Médio esforço (1–2 semanas)

| Feature | Como |
|---|---|
| **Assinaturas com logo** | Detectar recorrência por descrição+valor (a auditoria do `PLANO.md` fez isso à mão — automatizar). Logo via tabela local `descricao_normalizada → marca` (Netflix, Spotify, Claude, iFood, Uber… ~50 cobrem 90%). Total/mês, projeção anual, próxima cobrança. |
| **Logos nas transações** | Mesma tabela de marcas. Fallback: ícone da categoria. |
| **Mapa de calor semanal** | Agrupar gastos por dia da semana. SVG simples, sem lib. |
| **Top estabelecimentos** | Agrupar por descrição normalizada, ordenar por soma. |
| **Gráfico de ritmo (este mês × passado)** | Acumulado diário, duas linhas. A Kitamo já tem projeção — é o mesmo dado olhando para trás. |
| **Agentes = recorrências com personalidade** | Nome, retrato, tom, cadência, canal. Backend: `SystemNotificationRule` já existe. Front: galeria + "novo agente" em texto livre → LLM traduz para regra. |
| **Reestruturar navegação** | Seção 4. |

### Alto esforço (semanas+)

| Feature | Como |
|---|---|
| **WhatsApp como canal** | Meta Cloud API + webhook → `/api/ai/chat`. Custo por conversa. |
| **App nativo + biometria** | Capacitor sobre o Inertia atual, ou React Native. Biometria é plugin. |
| **Marketplace de agentes** | Só faz sentido com base de usuários. Adiar. |
| **OCR de fatura (foto)** | Gemini já está integrado (`GeminiClient`); vision resolve. Mas o OFX cobre o caso principal. |

---

## 6. O que NÃO copiar do Pierre

1. **O alarme "gastos dispararam 708%".** No print, R$ 954 dos R$ 1.457 são
   transferências entre contas do próprio usuário ("Dinheiro reservado Geral").
   Não é gasto. A Kitamo acabou de corrigir exatamente isso (`03c2b95`, aporte
   não é despesa). Insight que assusta com dado errado destrói confiança.
2. **Dependência de agregador.** Decidido em `PLANO-INGESTAO.md`. O Pierre
   usa Pluggy; a Kitamo usa arquivo do próprio usuário.
3. **Inconsistência entre telas.** Limite disponível aparece como R$ 5.604,85
   no web e R$ 5,12 no app. Fatura atual R$ 2.179,33 no app não bate com o web.
   A Kitamo já sofreu com isso; manter o `InvoiceCycle` como fonte única.

---

## 7. Ordem proposta

```
Fase 0  Corrigir ImportInvoiceModal (fachada no ar)          1 dia
Fase 1  Tela de chat + card de destaque com voz              3–5 dias
        └ maior retorno: liga o backend que já existe
Fase 2  Copy + personagem + loading narrativo                depende da decisão do personagem
Fase 3  Assinaturas com logo + logos nas transações          1 semana
Fase 4  Navegação: quebrar Dashboard, nav de 4 itens, cards  1–2 semanas
Fase 5  Mapa de calor, top estabelecimentos, ritmo           3–5 dias
Fase 6  Agentes (recorrências com cara)                      1–2 semanas
Fase 7  Parsers por banco (quando os extratos chegarem)      contínuo
```

Fases 1, 3 e 5 não dependem do personagem. Fase 2 e 6 dependem.

---

## 8. Decisões que só o Gabriel toma

1. **Personagem**: qual, e nome. Destrava fases 2 e 6.
2. **Dark-first ou light-first** como paleta principal.
3. **Fase 0**: ligar o modal no backend real (recomendado) ou remover.
4. **Nav mobile de 4 itens** com chat no centro — aprova?
