#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

DEPLOY_ENV_FILE="${HOSTINGER_DEPLOY_ENV:-${ROOT_DIR}/.hostinger.deploy.env}"
if [[ -f "${DEPLOY_ENV_FILE}" ]]; then
  # shellcheck disable=SC1090
  set -a
  source "${DEPLOY_ENV_FILE}"
  set +a
fi

SSH_TARGET="${SSH_TARGET:-}"
SSH_HOST="${SSH_HOST:-}"
SSH_USER="${SSH_USER:-}"
SSH_PORT="${SSH_PORT:-}"
SSH_KEY="${SSH_KEY:-${HOME}/.ssh/kitamo_deploy}"
PROJECT_DIR="${PROJECT_DIR:-~/domains/kitamo.com.br/public_html}"

if [[ -z "${SSH_TARGET}" && ( -z "${SSH_HOST}" || -z "${SSH_USER}" ) ]]; then
  echo "Uso:"
  echo "  scripts/hostinger-deploy-ssh.sh"
  echo ""
  echo "Configuração:"
  echo "  - Recomendada: SSH_TARGET=hostinger-kitamo (alias no ~/.ssh/config)"
  echo "  - Alternativa: SSH_HOST=... SSH_USER=... [SSH_PORT=22]"
  echo "  - Opcional: HOSTINGER_DEPLOY_ENV=.hostinger.deploy.env"
  echo ""
  echo "Exemplo:"
  echo "  SSH_TARGET=hostinger-kitamo scripts/hostinger-deploy-ssh.sh"
  exit 2
fi

if ! command -v ssh >/dev/null 2>&1 || ! command -v scp >/dev/null 2>&1; then
  echo "ssh/scp não encontrados. Rode este script no WSL/Linux/Git Bash." >&2
  exit 1
fi

if [[ -z "${SSH_TARGET}" && -z "${SSH_PORT}" ]]; then
  SSH_PORT="22"
fi

ssh_opts=()
scp_opts=()
if [[ -n "${SSH_PORT}" ]]; then
  ssh_opts+=(-p "${SSH_PORT}")
  scp_opts+=(-P "${SSH_PORT}")
fi
if [[ -f "${SSH_KEY}" ]]; then
  ssh_opts+=(-i "${SSH_KEY}")
  scp_opts+=(-i "${SSH_KEY}")
fi

echo "==> Gerando pacote Hostinger (zip)"
scripts/hostinger-package.sh

zip_path="$(ls -t kitamo-hostinger-backup-*.zip | head -n 1)"
if [[ -n "${SSH_TARGET}" ]]; then
  remote="${SSH_TARGET}"
else
  remote="${SSH_USER}@${SSH_HOST}"
fi
remote_zip="${PROJECT_DIR}/__deploy.zip"

echo "==> Upload do zip: ${zip_path} -> ${remote}:${remote_zip}"
scp "${scp_opts[@]}" "${zip_path}" "${remote}:${remote_zip}"

echo "==> Deploy remoto (sem sobrescrever .env / storage)"
ssh "${ssh_opts[@]}" "${remote}" "bash -lc '
set -euo pipefail
cd \"${PROJECT_DIR}\"

echo \"PWD: \$(pwd)\"
test -f artisan || { echo \"ERRO: artisan não encontrado em ${PROJECT_DIR}\"; exit 10; }
test -d public || { echo \"ERRO: pasta public não encontrada em ${PROJECT_DIR}\"; exit 10; }

tmp=\"\$(mktemp -d /tmp/kitamo_deploy.XXXXXX)\"
cleanup() { rm -rf \"\$tmp\" \"__deploy.zip\"; }
trap cleanup EXIT

if command -v unzip >/dev/null 2>&1; then
  unzip -q \"__deploy.zip\" -d \"\$tmp\"
elif command -v python3 >/dev/null 2>&1; then
  python3 -m zipfile -e \"__deploy.zip\" \"\$tmp\"
else
  echo \"ERRO: precisa de unzip ou python3 no servidor para extrair o zip\"
  exit 11
fi

if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete-after --delay-updates \\
    --exclude \".env\" \\
    --exclude \"storage/\" \\
    \"\$tmp/\" \"./\"
else
  echo \"AVISO: rsync não encontrado no servidor; fazendo replace por diretórios (mantendo .env e storage)\"
  for p in app bootstrap config database public resources routes vendor artisan composer.json composer.lock package.json package-lock.json vite.config.* postcss.config.* tailwind.config.* tsconfig.*; do
    if [ -e \"\$tmp/\$p\" ]; then
      rm -rf \"./\$p\"
      cp -a \"\$tmp/\$p\" \"./\$p\"
    fi
  done
fi

mkdir -p storage bootstrap/cache
chmod -R 775 storage bootstrap/cache 2>/dev/null || true

rm -f public/hot || true

# PHP 8.3 no Hostinger (php no PATH e 7.2 do sistema)
PHP_BIN=\"/opt/alt/php83/usr/bin/php\"
if [ ! -x \"\$PHP_BIN\" ]; then
  PHP_BIN=\"php\"
  echo \"AVISO: PHP 8.3 nao encontrado, usando php do PATH\"
fi

\$PHP_BIN artisan optimize:clear
\$PHP_BIN artisan config:cache
\$PHP_BIN artisan route:cache
\$PHP_BIN artisan view:cache

# Criar symlink de storage se nao existir
if [ ! -L public/storage ]; then
  mkdir -p storage/app/public
  ln -s ../storage/app/public public/storage
  echo \"Symlink public/storage criado\"
fi

echo \"OK: deploy finalizado\"
'"

echo "OK"
