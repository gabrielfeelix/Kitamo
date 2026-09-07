# Kitamo — plano de execução

App de finanças em Flutter. Escrito em 06/09/2026.
Fonte da verdade do design: o zip do Claude Design (36 telas) e
`HANDOFF-DESIGN.md`.

---

## 1. A conversa de segurança, antes de tudo

Você levantou o ponto certo: **é o dinheiro das pessoas.** Mas a decisão de
segurança mais importante deste app não é técnica, é de produto — e vale
decidir agora, porque muda tudo o que vem depois.

### O que a Kitamo NÃO guarda

A Kitamo é um app de **projeção**, não de banco. Ela precisa saber:

- quanto você deve, para quem, quanto é a parcela, que dia vence
- quanto entra por mês e que dia cai
- quanto sai no dia a dia

Ela **não precisa** de: senha de banco, número de cartão, CPF, saldo em
tempo real, acesso a conta. E não vai pedir.

Isso não é modéstia — é a decisão de segurança que mais reduz risco. Dado
que não existe não vaza, não é roubado e não precisa ser protegido. Um app
que não guarda credencial bancária não é alvo interessante.

> **Regra do projeto: nunca pedir senha de banco, número de cartão ou CPF.**
> Se algum dia a importação de extrato virar conexão automática, ela passa
> por Open Finance (consentimento revogável, sem senha), nunca por
> "digite sua senha do Nubank aqui".

### O que ela guarda, e o que isso significa

O que ela guarda ainda é sensível: **saber que alguém deve R$ 6.136 ao
Nubank e está apertado é informação constrangedora.** Não gera fraude
financeira direta, mas é dado íntimo, e vaza reputação.

Classificação honesta:

| Dado | Sensibilidade | Onde vive |
|---|---|---|
| Dívidas, renda, gastos | **Alta** — íntimo | Local cifrado + nuvem cifrada |
| E-mail (login) | Média — identifica | Provedor de auth |
| Senha | — | **Nunca tocamos** (só login social/OTP) |
| Dado bancário | — | **Não existe no app** |

### Offline ou online? A pergunta que você fez

Você perguntou e a resposta é: **os dois, e nessa ordem.**

O app funciona **offline por padrão**. É projeção — não precisa de rede para
calcular seu diário. Isso não é economia, é produto: quem está endividado
muitas vezes está sem dados no celular. Um app que só abre com internet
falha exatamente na hora que importa.

A nuvem entra como **sincronização opcional**, para não perder tudo ao
trocar de celular. Login social (Google/Apple) serve a isso — não para
"criar conta", mas para **recuperar seus dados**.

Consequência prática: **a v1 pode não ter login nenhum.** E deveria não ter.
Pedir login antes de mostrar valor é a maior fonte de abandono em onboarding
de app financeiro. A pessoa instala, responde 6 perguntas, vê o número. Só
quando quiser proteger é que aparece "quer não perder isso?".

---

## 2. Arquitetura de segurança

### Camadas

```
┌─ Tela ──────────── nada de regra de negócio aqui
├─ Serviço ───────── DiarioService, HorizonteService (puros, testáveis)
├─ Repositório ───── interface. A tela não sabe de onde vem o dado
└─ Fonte ─────────── local (Drift + SQLCipher) │ nuvem (fase 5)
```

O repositório como interface é o que permite começar offline e ligar a
nuvem depois **sem reescrever tela**.

### Decisões e o porquê

**Banco local cifrado — Drift + SQLCipher.**
`shared_preferences` guarda em texto puro; num celular com root, qualquer
app lê. SQLCipher cifra o arquivo inteiro (AES-256). A chave fica no
Keychain (iOS) / Keystore (Android) via `flutter_secure_storage`, que usa o
enclave de hardware quando existe.

**Sem segredo no código.** Chave de API em `--dart-define`, nunca em
arquivo versionado. Todo APK é descompilável: o que está no código é
público, ponto.

**Bloqueio por biometria opcional.** Ver que você deve R$ 6 mil não pode
estar a um deslize de distância se alguém pegar seu celular. Opcional
porque obrigatório trava quem tem celular sem biometria.

**Nada de log de valor.** `print('saldo: $x')` vaza para o logcat, que
outros apps leem. Regra: log nunca inclui valor, nome de credor ou renda.

**Sem analytics de terceiro na v1.** SDK de analytics é código de terceiro
com acesso total ao processo. Num app financeiro, o padrão é não instalar.

**Certificate pinning quando a nuvem entrar** (fase 5), não antes.

### O que fica de fora de propósito

- Pagamento dentro do app (v1)
- Conexão bancária automática — o Open Finance no Brasil exige instituição
  autorizada pelo BC; ou vira custo de agregador (Pluggy/Belvo), decisão
  já fechada como "não" no HANDOFF-QUITAR
- Compartilhamento social de progresso — "quitei!" público expõe dívida

---

## 3. Fases

Cada fase termina em **commit + testes verdes**. Nenhuma fase depende de
uma futura para funcionar.

### Fase 0 — fundação ✅ (feito)
Design system em Dart, modelos, `DiarioService`, tela de Início nas duas
faces. 17 testes.

### Fase 1 — persistência local cifrada ✅ (feito)
O app lembra do que você respondeu.

- Drift + SQLCipher, chave no secure storage
- Migrations versionadas desde o dia 1 (banco sem migration é dívida
  técnica que só aparece quando já tem usuário)
- Repositórios: `DividaRepository`, `PerfilRepository`
- Testes: CRUD, migration, e **o teste que importa** — o arquivo do banco
  não é legível sem a chave

### Fase 2 — onboarding ✅ (feito)
A porta de entrada. 6 telas, uma pergunta por tela, cada uma na sua cor.

- Fluxo com progresso, "pular" sempre visível
- Cada resposta pulada tem default explícito
- Tela final: o número, com o joão-de-barro
- Teste: pular tudo não quebra; responder gera o número certo

### Fase 3 — horizonte ✅ (feito)
As duas visões que são o produto.

- **Mês:** linha por dia, nome do lançamento, motivo da cor
- **12 meses:** blocos coloridos, o mês da quitação marcado
- `HorizonteService` portado do backend (já tem 1377 asserções lá)
- Teste: 24 meses × vencimento 1–31 × renda 1–31, cada lançamento aparece
  exatamente uma vez

### Fase 4 — "quitei essa" e lançamentos ✅ (feito)
O hábito.

- Marcar parcela paga → carimbo, contagem, casa crescendo
- Antecipou? a data de quitação recua
- Lançar gasto/entrada pelo `+`
- Lista com chips
- Teste: quitar altera saldo e data; desfazer volta ao estado anterior

### Fase 5 — backup ✅ (por arquivo; nuvem não foi feita — ver nota)
Só aqui entra rede.

- Login social (Google/Apple) **como recuperação**, não como porta
- Sync com resolução de conflito explícita
- Cifra em trânsito + pinning
- Exportar e apagar tudo (LGPD: é direito, não favor)
- Teste: funciona offline; sync não duplica; apagar apaga mesmo

### Fase 6 — endurecimento ✅ (feito; ver SEGURANCA.md)
- Bloqueio por biometria
- Auditoria de dependências
- Ofuscação no release
- Bloqueio de screenshot em telas de valor (opcional)
- Revisão de segurança completa antes da loja

---

## 4. Boas práticas, e a que mais importa

**Teste antes do commit.** Toda regra de negócio nasce com teste. Não é
disciplina — é que erro de cálculo em app de dívida faz alguém gastar
dinheiro que não tem.

**Commit atômico**, mensagem dizendo *por que*, não *o quê*.

**Nada de `print`.** Logger com nível, e nunca com valor.

**Dependência é superfície de ataque.** Cada pacote novo precisa de
justificativa. Preferir o que já vem no Flutter.

**Acessibilidade é requisito, não extra.** Mínimo 16px, contraste AA,
`Semantics` nos widgets de valor. O público inclui gente de 60 anos, e a
restrição já está no design.

---

## 5. Por onde começar, e por quê

**Fase 1 (persistência), depois Fase 2 (onboarding).**

Você disse que tanto faz, então decido: começar pelo banco.

O motivo é que a ordem inversa custa retrabalho. Se eu fizer o onboarding
antes da persistência, ele vai gravar em memória — e some ao fechar o app.
Aí, quando o banco chegar, todas as telas do onboarding precisam ser
reescritas para falar com repositório.

Fazendo o banco primeiro, o onboarding já nasce salvando de verdade. E a
Fase 1 é justamente onde mora a decisão de segurança mais séria do app
(cifra em repouso), que é melhor acertar antes de ter dado dentro.

---

## 5.2 Depois das 6 fases (06/09/2026)

Feito além do plano, para o app fechar de ponta a ponta:

- **Nova dívida / editar** — sem isso o app era via de mão única: a pessoa
  cadastrava no onboarding e nunca mais corrigia. Bloqueava o teste com 10
  pessoas
- **Importar OFX** — a oferta do passo 6 do onboarding apontava para uma
  tela que não existia
- **Chat** — determinístico, sem LLM. As perguntas que importam são sobre os
  números da própria pessoa, e para essas o cálculo exato é melhor que um
  modelo que pode errar
- **Nav com 5 itens** (Início · Lançamentos · + · Chat · Perfil)

Falta ainda: notificações ("vence amanhã"), "pra onde vai" (mosaico de
categorias) e **rodar em aparelho real** — minify quebra em runtime, não no
build.

## 5.0 Nota sobre a Fase 5 (06/09/2026)

Implementado **backup por arquivo**, não sincronização em nuvem. É a opção
recomendada no §6 e a que dispensa decisão pendente: sem servidor, sem
login, sem dado de dívida trafegando ou parado em infraestrutura nossa.

O arquivo sai em JSON legível de propósito — é a pessoa quem escolhe onde
guardar, e backup que ela não consegue abrir não é backup. A tela precisa
mostrar `BackupService.avisoDeExportacao`.

Falta, se a nuvem entrar depois: escolher a UI de arquivo (`file_picker` ou
`share_plus`) e a decisão do §6 sobre servidor.

## 5.1 Nota de plataforma (06/09/2026)

**A web saiu do projeto.** O SQLite nativo usa `dart:ffi`, que não existe no
navegador — o build quebra. Rodar na web exigiria a variante WASM do
sqlite3, uma segunda configuração de banco só para um alvo que não é o do
produto. O app é de celular.

`compileSdk` fixado em **37**: exigência do `flutter_secure_storage`, que é
onde mora a chave do banco.

## 6. O que eu preciso de você

Nada para começar a Fase 1. Mas duas decisões antes da Fase 5:

1. **Login social vale a pena?** Minha recomendação: sim, mas só como
   recuperação, depois de a pessoa já ver valor. Nunca como porta de entrada
2. **Conta na Apple Developer (US$ 99/ano)** — só se iOS entrar. Android e
   web não custam nada

E uma pergunta que muda a Fase 5: **você quer que os dados subam para
algum servidor seu, ou prefere que fiquem só no celular com backup manual
(exportar arquivo)?** A segunda é mais barata, mais privada e mais simples
— e para 10 pessoas testando, suficiente.
