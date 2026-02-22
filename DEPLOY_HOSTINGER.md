# Deploy Hostinger (KITAMO)

Projeto no servidor:

- `~/domains/<seu-dominio>/public_html`

## Configuracao segura (sem expor credenciais no comando)

1. Copie o arquivo de exemplo:

```bash
cp .hostinger.deploy.env.example .hostinger.deploy.env
```

2. Edite `.hostinger.deploy.env` com seus dados reais.

3. Opcional: configure um alias no `~/.ssh/config` e use `SSH_TARGET`.

Exemplo de `~/.ssh/config`:

```sshconfig
Host hostinger-kitamo
    HostName <HOST_OR_IP>
    User <SSH_USER>
    Port <SSH_PORT>
    IdentityFile ~/.ssh/kitamo_deploy
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

## Deploy recomendado (automatizado)

```bash
scripts/hostinger-deploy-ssh.sh
```

O script faz:

1. Build frontend local (`npm run build`)
2. Staging + `composer install --no-dev` em staging
3. Gera zip de deploy
4. Upload via SCP
5. Extrai/sincroniza no servidor preservando `.env` e `storage/`
6. Roda cache commands do Laravel

## Validar se deploy foi aplicado

```bash
# versao Laravel e commit atual
ssh hostinger-kitamo 'cd ~/domains/<seu-dominio>/public_html && php artisan --version && git rev-parse --short HEAD || true'

# assets atualizados
ssh hostinger-kitamo 'ls -lt ~/domains/<seu-dominio>/public_html/public/build/assets | head -10'
```

## Troubleshooting rapido

### `artisan não encontrado`

Confirme `PROJECT_DIR` no `.hostinger.deploy.env`.

### erro de permissao em cache/storage

```bash
ssh hostinger-kitamo 'cd ~/domains/<seu-dominio>/public_html && chmod -R 775 storage bootstrap/cache'
```

### migrations pendentes

```bash
ssh hostinger-kitamo 'cd ~/domains/<seu-dominio>/public_html && php artisan migrate --force'
```

## Seguranca

- Nao commitar `.hostinger.deploy.env`
- Nao passar `SSH_HOST=... SSH_USER=...` direto na linha de comando
- Se credenciais vazaram em chat/historico, rotacione senha/chave SSH no painel da Hostinger
