---
name: deploy
description: Use quando o usuário pedir para fazer deploy, subir para
produção, publicar no servidor ou executar o script de hospedagem.
---

# Skill: Deploy KITAMO

## Consulte
Leia `docs/hostinger.md` para detalhes do servidor.

## Sequência de Deploy
1. Verificar que não há mudanças não commitadas
2. Rodar npm run build (compila assets)
3. Verificar que /public/build NÃO está no commit
4. Executar scripts/hostinger-deploy-ssh.sh
5. Verificar logs de erro após deploy
6. Confirmar que kitamo.com.br está respondendo

## Atenção
- Nunca subir com .env de desenvolvimento
- Preservar storage/ e .env no servidor
- Após migrations novas: rodar php artisan migrate no servidor
