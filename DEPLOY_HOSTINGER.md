# Deploy Hostinger (KITAMO)

Projeto no servidor:

- `~/domains/kitamo.com.br/public_html`

## Deploy principal (GitHub Actions)

Cada push para `main` triggera o workflow `.github/workflows/deploy.yml` que:

1. Build frontend (`npm run build`)
2. `composer install`
3. `rsync` para o servidor
4. Fix permissoes e symlinks
5. Roda migrations e cache commands

## Deploy manual (SSH script)

```bash
scripts/hostinger-deploy-ssh.sh
```

Requer `.hostinger.deploy.env` configurado (veja `.hostinger.deploy.env.example`).

## Configuracao SSH

Configure no `~/.ssh/config`:

```sshconfig
Host hostinger-kitamo
    HostName 147.79.84.203
    User u626119115
    Port 65002
    IdentityFile ~/.ssh/kitamo_fix
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

## PHP no servidor

O `php` no PATH do SSH e PHP 7.2 (sistema). Para comandos artisan, usar:

```bash
/opt/alt/php83/usr/bin/php artisan migrate --force
/opt/alt/php83/usr/bin/php artisan optimize:clear
```

## Scheduler (cron no hPanel)

Os agendamentos de `routes/console.php` so rodam se existir cron chamando `schedule:run` a cada minuto.

Na Hostinger, configure no hPanel:

- **Comando**:

```bash
cd ~/domains/kitamo.com.br/public_html && /opt/alt/php83/usr/bin/php artisan schedule:run >> /dev/null 2>&1
```

- **Periodicidade**: `* * * * *` (todo minuto)

Observacao: neste servidor, o comando `crontab` nao esta disponivel via SSH, entao a configuracao deve ser feita no painel.

## Troubleshooting

### erro de permissao em cache/storage

```bash
ssh hostinger-kitamo 'cd ~/domains/kitamo.com.br/public_html && chmod -R 775 storage bootstrap/cache'
```

### extensoes PHP nao carregam (PDO not found, mbstring, etc)

Verificar phpinfo() — se "Additional .ini files parsed" estiver vazio, contatar suporte Hostinger para rodar `cagefsctl --rebuild-alt-php-ini` e `cagefsctl --force-update`.

### assets 404 / site em branco

O `.htaccess` da raiz redireciona requests para `public/`. Se estiver faltando ou incorreto, o site quebra. Esse arquivo vem do repositorio e e deployado automaticamente.

## Seguranca

- Nao commitar `.hostinger.deploy.env`
- Nao expor credenciais SSH em chat/historico
- Se credenciais vazaram, rotacione senha/chave SSH no painel da Hostinger
