---
description: Deploy completo do KITAMO para produção no Hostinger.
---
// turbo-all
1. Verificar git status (sem arquivos pendentes)
2. Rodar npm run build
3. Confirmar que /public/build está no .gitignore
4. Executar scripts/hostinger-deploy-ssh.sh
5. Checar kitamo.com.br após 2 minutos
