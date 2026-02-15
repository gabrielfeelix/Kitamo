# KITAMO - Sistema de Organização e Registro de Saldo

**Versão:** 1.0.0 (MVP)
**Status:** Em desenvolvimento
**Última atualização:** 14/02/2026

---

## 📋 VISÃO GERAL

Sistema de gestão financeira pessoal focado em **input manual confiável** e **projeção futura**.

**Diferencial:** Não promete automação via Open Finance. Foca em controle manual que funciona e prevê se "vai dar dinheiro até o fim do mês".

**4 Dores que resolve:**
1. ✅ Visibilidade de dívidas → "Quanto ainda devo?"
2. ✅ Compreensão de gastos → "No que estou gastando?"
3. ✅ Projeção de compromissos → "Quanto do cartão já está comprometido?"
4. ✅ Planejamento futuro → "Vou conseguir pagar as contas do mês que vem?"

---

## 🛠️ STACK TÉCNICA

- **Backend:** Laravel 12 + PHP 8.3
- **Frontend:** Vue 3 + TypeScript 5.6 + Inertia.js
- **CSS:** Tailwind CSS 3.2.1
- **Database:** SQLite (Local) / PostgreSQL (Produção via Supabase)
- **Build:** Vite 7.0
- **Deploy:** Hostinger via SSH

---

## 🤖 ESTRUTURA DE AGENTES (IA)

Este projeto utiliza uma estrutura padronizada para desenvolvimento assistido por IA.
Todos os contextos e regras estão em `.agent/`.

### Regras Globais
- **`.agent/rules/kitamo-core.md`**: Regras inegociáveis do produto e stack.

### Skills (Departamentos)
- **`.agent/skills/nova-feature/`**: Desenvolvimento Backend + Frontend.
  - Consulte `docs/inventario.md` para ver o que já existe.
- **`.agent/skills/design-system/`**: UX/UI e Tokens visuais.
  - Consulte `docs/tokens.md` para cores e tipografia.
- **`.agent/skills/regras-negocio/`**: Lógica financeira core (projeção, parcelamento).
  - Consulte `docs/conceitos.md` para definições.
- **`.agent/skills/deploy/`**: Infraestrutura e Deploy na Hostinger.
  - Consulte `docs/hostinger.md` para detalhes do servidor.

### Workflows Automatizados
- `/nova-feature`: Implementa feature completa.
- `/deploy`: Sobe para produção.
- `/review-ui`: Valida consistência visual.
- `/testar`: Roda suíte de testes.

---

## ⚙️ CONFIGURAÇÃO DE AMBIENTE

### 1. Requisitos
- PHP 8.3+
- Composer
- Node.js 20+
- SQLite (ou PostgreSQL)

### 2. Instalação
```bash
git clone <repo>
cd kitamo
cp .env.example .env
composer install
npm install --legacy-peer-deps
php artisan key:generate
php artisan migrate --seed
npm run dev
```

### 3. Variáveis de Ambiente (.env)
**NUNCA** commite o `.env` ou exponha senhas aqui.
Configure seu `.env` local com:

```env
APP_NAME=Kitamo
APP_ENV=local
APP_DEBUG=true

# Database Local (SQLite)
DB_CONNECTION=sqlite

# Database Produção (PostgreSQL/Supabase)
# Apenas no servidor de produção
# DB_CONNECTION=pgsql
# DB_HOST=aws-1-sa-east-1.pooler.supabase.com
# DB_PORT=5432
# DB_DATABASE=postgres
# DB_USERNAME=postgres.seu_user
# DB_PASSWORD="sua_senha_secreta"
```

---

## 🚀 DEPLOY (HOSTINGER)

O deploy é automatizado via script SSH.
**Não rode manualmente** se não souber o que está fazendo. Use o workflow `/deploy`.

### Variáveis de Deploy (Secrets)
As credenciais SSH (`SSH_HOST`, `SSH_USER`, `SSH_PORT`) devem ser configuradas nas variáveis de ambiente do CI/CD ou passadas na execução do script, nunca hardcoded no código.

Consulte `.agent/skills/deploy/docs/hostinger.md` para detalhes da infraestrutura.

---

## 🎨 DESIGN SYSTEM RESUMIDO

- **Primary (Teal):** #14B8A6
- **Success (Green):** #10B981
- **Danger (Red):** #EF4444
- **Warning (Yellow):** #F59E0B

Consulte `.agent/skills/design-system/docs/tokens.md` para o guia completo.
