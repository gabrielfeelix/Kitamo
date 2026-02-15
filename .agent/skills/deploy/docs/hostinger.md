# Infraestrutura Hostinger

## Servidor
- **Tipo**: VPS / Shared Hosting com acesso SSH
- **OS**: Linux (Ubuntu/Debian)
- **Web Server**: Apache/Nginx
- **PHP**: 8.3
- **Database**: PostgreSQL (Supabase externo)

## Estrutura de Diretórios
- `/home/u12345/domains/kitamo.com.br/public_html` -> Raiz do app
- `storage/` -> Persistente (logs, uploads)
- `.env` -> Persistente (configurações de produção)

## Deployment Script
O script `scripts/hostinger-deploy-ssh.sh` realiza:
1. Conexão SSH
2. `git pull origin main`
3. `composer install --no-dev`
4. `php artisan migrate --force`
5. `php artisan optimize`
6. `npm ci && npm run build` (se build for no servidor) ou upload de assets

## Supabase
- Banco de dados PostgreSQL hospedado externamente.
- Credenciais no `.env` de produção.
- Migrations devem ser compatíveis com Postgres (atenção a tipos específicos e case sensitivity).
