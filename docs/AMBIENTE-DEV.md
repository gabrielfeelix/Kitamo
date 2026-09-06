# Ambiente de desenvolvimento — dev.kitamo.com.br

Criado em 06/09/2026, quando o pivô "Quitar" começou. Decisão do Gabriel.

## Por que existe

O pivô mexe na navegação, no Dashboard e na home. Enquanto ele não estiver
pronto, **kitamo.com.br continua sendo a Kitamo antiga**, funcionando, com
os dados reais importados do Open Finance.

Antes disso, todo push em `main` ia direto para produção — inclusive as
migrations. Não havia onde ver o trabalho em andamento sem publicá-lo.

## Como está montado

```
branch  main    →  kitamo.com.br       →  banco u626119115_Kitamo
branch  quitar  →  dev.kitamo.com.br   →  banco u626119115_Kitamo_dev
```

| | Produção | Dev |
|---|---|---|
| Branch | `main` | `quitar` |
| Workflow | `.github/workflows/deploy.yml` | `.github/workflows/deploy-dev.yml` |
| Path no servidor | `~/domains/kitamo.com.br/public_html` | `~/domains/dev.kitamo.com.br/public_html` |
| Banco | `u626119115_Kitamo` | `u626119115_Kitamo_dev` |
| Dados | reais, do Open Finance | cópia dos reais |

Mesma conta de hospedagem, mesmo MySQL, bancos diferentes.

## As duas travas do workflow de dev

O `deploy-dev.yml` **aborta** em dois casos, de propósito:

1. **Se o `.env` não existir no servidor.** Sem `.env`, o Laravel usaria a
   configuração padrão e o `migrate --force` rodaria no banco de
   **produção**. Seria a forma mais fácil de destruir os dados reais.
2. **Se o `.env` não apontar para `u626119115_Kitamo_dev`.** Mesma razão,
   verificada de novo logo antes de migrar.

O `.env` do dev vive só no servidor e está no `--exclude` do rsync — o
deploy nunca o sobrescreve.

## Setup (uma vez)

> **Os passos 1 e 2 só saem pelo painel.** Foi testado em 06/09/2026, com
> SSH e as credenciais reais do MySQL em mãos:
>
> - `CREATE DATABASE u626119115_Kitamo_dev` roda **sem erro e sem efeito** —
>   o `SHOW DATABASES` seguinte não lista o banco. Em hospedagem
>   compartilhada quem registra o banco na conta e concede o GRANT é o
>   painel.
> - `mkdir ~/domains/dev.kitamo.com.br/public_html` funciona, mas cria só
>   uma pasta. Faltam o registro **DNS** e o **vhost**, que não moram no
>   filesystem — `dev.kitamo.com.br` não resolve (HTTP 000).
> - Não há CLI do painel na máquina (`hcli`, `hostinger-cli`).
>
> Os passos 3 e 4 são automatizáveis e podem ser feitos por SSH.

### 1. Criar o subdomínio — painel da Hostinger

`hPanel → Domínios → Subdomínios` → criar `dev` em `kitamo.com.br`.
Isso cria `~/domains/dev.kitamo.com.br/public_html`.

### 2. Criar o banco — painel da Hostinger

`hPanel → Bancos de dados → MySQL` → criar `u626119115_Kitamo_dev`,
marcando o usuário **`u626119115_gabriel`** — o mesmo do banco de
produção, para a senha continuar a mesma.

### 3. Copiar os dados de produção para o dev

Pelo SSH, num comando só (**atenção ao limite de 500 conexões/hora**):

```bash
ssh hostinger-kitamo
cd ~/domains/kitamo.com.br/public_html
mysqldump -h srv1722.hstgr.io -u USUARIO -p u626119115_Kitamo \
  | mysql -h srv1722.hstgr.io -u USUARIO -p u626119115_Kitamo_dev
```

### 4. Criar o `.env` do dev

```bash
cp ~/domains/kitamo.com.br/public_html/.env \
   ~/domains/dev.kitamo.com.br/public_html/.env
```

E editar **três** linhas:

```
APP_ENV=staging
APP_URL=https://dev.kitamo.com.br
DB_DATABASE=u626119115_Kitamo_dev
```

`APP_KEY` pode continuar a mesma — as sessões são independentes por domínio.

### 5. Apontar o document root

O Laravel serve de `public/`. Se o subdomínio servir a raiz do projeto,
o site não sobe. Mesma configuração que já existe em produção
(`.htaccess` ou o document root no painel).

### 6. Disparar o primeiro deploy

`Actions → Deploy DEV → Run workflow`, ou qualquer push em `quitar`.

## Fluxo de trabalho

```
trabalho em `quitar`  →  push  →  dev.kitamo.com.br  →  Gabriel olha
                                                        ↓
                              aprovado  →  merge em `main`  →  produção
```

Produção só muda por merge deliberado. Nunca por acidente.

## Enquanto o subdomínio não existir

O `deploy-dev.yml` falha no primeiro passo, com a mensagem apontando para
este arquivo. É de propósito: falhar é melhor que publicar no lugar errado.
O trabalho na branch continua normal — só não há link para ver.

## Estado em 06/09/2026

As tabelas `dividas` e `perfil_financeiro` (item 0) **já foram aplicadas em
produção** pelo CI, antes desta separação existir. Não há risco: são tabelas
novas, nenhuma tela as usa ainda, e nada existente foi alterado. Ficam lá,
vazias, até o pivô ser promovido.
