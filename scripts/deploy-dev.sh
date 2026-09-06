#!/usr/bin/env bash
# Deploy manual do dev.kitamo.com.br a partir da máquina local.
#
# Existe porque o Hostinger bloqueia o IP do runner do GitHub de forma
# intermitente (connection timed out na porta 65002). Daqui o SSH funciona.
#
# Uso:  ./scripts/deploy-dev.sh
set -euo pipefail

REMOTE="hostinger-kitamo"
DST="~/domains/dev.kitamo.com.br/public_html"
PHP="/opt/alt/php83/usr/bin/php"

echo "==> build"
npm run build

echo "==> rsync (preserva .env e o banco sqlite do dev)"
rsync -az --delete \
  --exclude='.git' --exclude='node_modules' --exclude='.env' \
  --exclude='database/dev.sqlite' --exclude='storage/logs/*' \
  ./ "$REMOTE:$DST/"

echo "==> migrate + cache"
ssh "$REMOTE" "set -e; cd $DST; \
  grep -q '^DB_CONNECTION=sqlite' .env || { echo 'ABORTADO: .env do dev não está em sqlite'; exit 1; }; \
  chmod -R 775 storage bootstrap/cache; \
  $PHP artisan migrate --force; \
  $PHP artisan optimize:clear; \
  echo 'deploy dev completo'"

echo "==> https://dev.kitamo.com.br"
