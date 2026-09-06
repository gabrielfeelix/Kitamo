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

## Setup — JÁ FEITO (06/09/2026)

Tudo montado pela **API oficial da Hostinger**, sem painel. O token está em
`radar-ofertas/.env` (`HOSTINGER_TOKEN`).

```bash
# criar o subdomínio (cria vhost + DNS automaticamente)
curl -X POST https://developers.hostinger.com/api/hosting/v1/websites \
  -H "Authorization: Bearer $HOSTINGER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"domain":"dev.kitamo.com.br","order_id":1008401284}'
```

`order_id` sai de `GET /api/hosting/v1/websites`. Outros endpoints úteis:
`GET /api/domains/v1/portfolio`, `GET /api/dns/v1/zones/{dominio}`.

### O banco é SQLite, e por quê

Não há endpoint de banco na API, e o MySQL também não resolve: o usuário
`u626119115_gabriel` tem `GRANT ALL` só em `u626119115_Kitamo` e `USAGE`
global — sem `CREATE`. Por isso `CREATE DATABASE` é aceito e descartado em
silêncio.

SQLite dá o mesmo isolamento sem depender do painel:

```
DB_CONNECTION=sqlite
DB_DATABASE=/home/u626119115/domains/dev.kitamo.com.br/public_html/database/dev.sqlite
```

Verificado em 06/09/2026: dev em `sqlite` (0 registros), produção em `mysql`
(19 usuários, 606 transações) — intacta.

O banco do dev nasce **vazio**. Para popular, use seeders ou importe um OFX
pela própria tela.

## Deploy

O GitHub Actions **falha de forma intermitente**: o Hostinger bloqueia o IP
do runner (`ssh: connect to host 147.79.84.203 port 65002: Connection timed
out`). Da máquina local o SSH funciona.

```bash
./scripts/deploy-dev.sh
```

O script preserva `.env` e `database/dev.sqlite` no rsync — sem isso, cada
deploy apagaria a configuração e o banco do dev.

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
