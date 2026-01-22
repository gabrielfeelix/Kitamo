# 📁 Estrutura de Deploy - Laravel na Hostinger

> **Status**: ✅ Produção estável
> **Última atualização**: 2026-01-22
> **Document Root**: `~/domains/kitamo.com.br/public_html/`

## 🎯 Arquitetura Atual

### Estrutura de Diretórios

```
~/domains/kitamo.com.br/public_html/
├── app/                    # Código da aplicação
├── bootstrap/              # Bootstrap do Laravel
├── config/                 # Configurações
├── database/              # Migrations e seeders
├── storage/               # Storage privado (logs, cache, sessions)
│   └── app/
│       └── public/        # Arquivos públicos (receipts, avatars)
├── vendor/                # Dependencies do Composer
├── .htaccess              # ⚠️ CRÍTICO: Rewrite para /public/
├── index.php              # Não usado (mantido por compatibilidade)
└── public/                # 🌐 WEBROOT REAL
    ├── index.php          # ✅ Entry point da aplicação
    ├── .htaccess          # Configuração Laravel padrão
    ├── build/             # Assets compilados pelo Vite
    │   ├── manifest.json
    │   └── assets/
    ├── favicon.ico
    ├── favicon.svg
    └── storage -> ../storage/app/public (symlink)
```

## 🔧 Como Funciona

### 1. Document Root e Rewrite

**Hostinger serve de**: `public_html/` (não de `public_html/public/`)

**Solução**: `.htaccess` na raiz redireciona tudo para `public/`

```apache
# public_html/.htaccess
<IfModule mod_dir.c>
    DirectoryIndex public/index.php
</IfModule>

<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_URI} !^/public/
    RewriteRule ^(.*)$ /public/$1 [L]
</IfModule>
```

**Fluxo de requisição**:
```
https://kitamo.com.br/accounts
    ↓ (LiteSpeed)
public_html/ (document root)
    ↓ (.htaccess rewrite)
public_html/public/index.php
    ↓ (Laravel router)
Aplicação
```

### 2. Entry Point

**Arquivo**: `public_html/public/index.php`

```php
<?php
// ✅ Caminhos relativos a public/
require __DIR__.'/../vendor/autoload.php';
$app = require_once __DIR__.'/../bootstrap/app.php';
$app->handleRequest(Request::capture());
```

**⚠️ IMPORTANTE**: Caminhos usam `__DIR__.'/../'` (um nível acima de `public/`)

### 3. Assets do Vite

**Localização**: `public_html/public/build/`

**Laravel procura por**: `public/build/manifest.json` (padrão)

**Servido via**: `https://kitamo.com.br/build/assets/*`

### 4. Storage de Arquivos

**Privado**: `storage/app/private/` (não acessível via web)
**Público**: `storage/app/public/` (acessível via symlink)

**Symlink**: `public/storage → ../storage/app/public`

**URLs**: `https://kitamo.com.br/storage/receipts/...`

## 🚀 Deploy Automático (GitHub Actions)

### Workflow: `.github/workflows/deploy.yml`

**Steps críticos**:

1. ✅ **Build**: `npm run build` (gera `public/build/`)
2. ✅ **Deploy**: `rsync` para `public_html/`
3. ✅ **Symlink**: Cria `public/storage → ../storage/app/public`
4. ✅ **Permissões**: `chmod 775 storage/ bootstrap/cache/`
5. ✅ **Cache**: `php artisan config:cache && route:cache`

**⚠️ NÃO FAZ MAIS**:
- ❌ Copiar `public/build/` para `build/` na raiz (removido em a6bad96)

## 🔍 Troubleshooting

### ❌ "Vite manifest not found"

**Causa**: Build não foi gerado ou está no lugar errado
**Solução**: Verificar que `public/build/manifest.json` existe

```bash
ssh ... 'test -f ~/domains/kitamo.com.br/public_html/public/build/manifest.json && echo OK'
```

### ❌ 404 em /storage/receipts/...

**Causa**: Symlink não existe ou está quebrado
**Solução**: Recriar symlink

```bash
cd ~/domains/kitamo.com.br/public_html
rm -f public/storage
ln -s ../storage/app/public public/storage
```

### ❌ 500 Internal Server Error

**Causa 1**: Caminhos errados no `index.php`
**Solução**: Verificar que usa `__DIR__.'/../'`

**Causa 2**: Cache corrompido
**Solução**: Limpar cache

```bash
php artisan optimize:clear
php artisan config:cache
php artisan route:cache
```

**Causa 3**: Permissões incorretas
**Solução**: Ajustar permissões

```bash
chmod -R 775 storage bootstrap/cache
```

## ✅ Validação

### Checklist Pós-Deploy

```bash
# 1. Homepage
curl -s -o /dev/null -w "%{http_code}" https://kitamo.com.br/
# Esperado: 200

# 2. Rota autenticada
curl -s -o /dev/null -w "%{http_code}" https://kitamo.com.br/accounts
# Esperado: 302 (redirect para /login)

# 3. Storage
curl -s https://kitamo.com.br/storage/test/ping.txt
# Esperado: conteúdo do arquivo

# 4. Assets
curl -s -o /dev/null -w "%{http_code}" https://kitamo.com.br/build/manifest.json
# Esperado: 200
```

## 🛡️ Segurança

### ✅ O que está protegido:

- `app/`, `config/`, `database/`, `vendor/` → Não acessíveis via web
- `storage/app/private/` → Não acessível via web
- `.env` → Não acessível via web (fora de `public/`)

### ✅ O que está acessível:

- `public/` → Entry point e assets
- `public/storage/` → Apenas via symlink para `storage/app/public/`

## 📚 Referências

- [Laravel Deployment Docs](https://laravel.com/docs/deployment)
- [Hostinger Laravel Guide](https://support.hostinger.com/en/articles/1583245-how-to-deploy-laravel-project)
- Commit de referência: `a6bad96` (estrutura corrigida)

---

**Mantenedores**: Se você precisa modificar a estrutura, documente aqui!
