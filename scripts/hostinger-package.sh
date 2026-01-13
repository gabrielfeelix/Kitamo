#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v rsync >/dev/null 2>&1; then
  echo "rsync não encontrado. Instale o rsync para continuar." >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 não encontrado. Precisa de python3 para gerar o zip caso o comando zip não exista." >&2
  exit 1
fi

timestamp="$(date +%Y%m%d-%H%M%S)"
staging_dir="${ROOT_DIR}/.hostinger_staging"
zip_name="sors-hostinger-backup-${timestamp}.zip"
zip_path="${ROOT_DIR}/${zip_name}"

cleanup() {
  if [[ "${KEEP_STAGING:-0}" == "1" ]]; then
    echo "KEEP_STAGING=1 -> mantendo staging em: ${staging_dir}"
    return
  fi
  rm -rf "$staging_dir"
}
trap cleanup EXIT

echo "==> (1/4) Build Vite"
npm run build

echo "==> (2/4) Preparando staging: ${staging_dir}"
rm -rf "$staging_dir"
mkdir -p "$staging_dir"

rsync -a --delete \
  --exclude ".git/" \
  --exclude "node_modules/" \
  --exclude "tests/" \
  --exclude ".env" \
  --exclude ".env.*" \
  --exclude "storage/logs/" \
  --exclude "storage/framework/cache/" \
  --exclude "storage/framework/sessions/" \
  --exclude "storage/framework/views/" \
  --exclude "storage/framework/testing/" \
  --exclude "public/storage" \
  --exclude ".hostinger_staging/" \
  ./ "$staging_dir/"

mkdir -p \
  "$staging_dir/storage/logs" \
  "$staging_dir/storage/framework/cache" \
  "$staging_dir/storage/framework/sessions" \
  "$staging_dir/storage/framework/views" \
  "$staging_dir/storage/framework/testing" \
  "$staging_dir/bootstrap/cache"

echo "==> (3/4) Composer install (prod) dentro do staging"
rm -rf "$staging_dir/vendor"
(cd "$staging_dir" && composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist)

echo "==> (4/4) Gerando zip: ${zip_path}"
rm -f "$zip_path"
if command -v zip >/dev/null 2>&1; then
  (cd "$staging_dir" && zip -r "$zip_path" . >/dev/null)
else
  python3 - "$staging_dir" "$zip_path" <<'PY'
import os
import stat
import sys
import zipfile

staging_dir = sys.argv[1]
zip_path = sys.argv[2]

def add_file(zf: zipfile.ZipFile, abs_path: str, rel_path: str) -> None:
    st = os.lstat(abs_path)
    mode = stat.S_IMODE(st.st_mode)
    if stat.S_ISLNK(st.st_mode):
        target = os.readlink(abs_path)
        info = zipfile.ZipInfo(rel_path)
        info.create_system = 3
        info.external_attr = ((stat.S_IFLNK | mode) & 0xFFFF) << 16
        zf.writestr(info, target)
        return
    info = zipfile.ZipInfo(rel_path)
    info.create_system = 3
    info.external_attr = ((stat.S_IFREG | mode) & 0xFFFF) << 16
    with open(abs_path, "rb") as f:
        zf.writestr(info, f.read(), compress_type=zipfile.ZIP_DEFLATED, compresslevel=6)

with zipfile.ZipFile(zip_path, "w") as zf:
    for root, dirs, files in os.walk(staging_dir):
        rel_root = os.path.relpath(root, staging_dir)
        if rel_root == ".":
            rel_root = ""
        for d in dirs:
            abs_d = os.path.join(root, d)
            rel_d = os.path.join(rel_root, d).replace(os.sep, "/") + "/"
            st = os.lstat(abs_d)
            mode = stat.S_IMODE(st.st_mode)
            info = zipfile.ZipInfo(rel_d)
            info.create_system = 3
            info.external_attr = ((stat.S_IFDIR | mode) & 0xFFFF) << 16
            zf.writestr(info, b"")
        for f in files:
            abs_f = os.path.join(root, f)
            rel_f = os.path.join(rel_root, f).replace(os.sep, "/")
            add_file(zf, abs_f, rel_f)
PY
fi

echo "OK: ${zip_path}"
echo "Obs: o zip NÃO inclui .env. Use .env.example como base no servidor."
