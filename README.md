# SORS - Sistema de Organização e Registro de Saldo

**Versão:** 1.0.0 (MVP)  
**Status:** Em desenvolvimento  
**Última atualização:** 08/01/2026

---

## 📋 VISÃO GERAL

Sistema de gestão financeira pessoal focado em **input manual confiável** e **projeção futura**.

**Diferencial:** Não promete automação via Open Finance. Foca em controle manual que funciona.

**4 Dores que resolve:**
1. ✅ Visibilidade de dívidas → "Quanto ainda devo?"
2. ✅ Compreensão de gastos → "No que estou gastando?"
3. ✅ Projeção de compromissos → "Quanto do cartão já está comprometido?"
4. ✅ Planejamento futuro → "Vou conseguir pagar as contas do mês que vem?"

---

## 🛠️ STACK TÉCNICA

### Backend
- **Framework:** Laravel 12.45.0
- **PHP:** 8.5.1
- **Autenticação:** Laravel Breeze + Inertia.js
- **Banco:** PostgreSQL (Supabase)
  - Host: `aws-1-sa-east-1.pooler.supabase.com`
  - Database: `postgres`
  - User: `postgres.ctzrzsuocdjpysdppcfx`

### Frontend
- **Framework:** Vue 3 (Composition API)
- **TypeScript:** 5.6.3
- **CSS:** Tailwind CSS 3.2.1
- **Build:** Vite 7.3.0
- **Router:** Inertia.js 2.0

### Infraestrutura
- **Container:** Laravel Sail (Docker)
- **Serviços:** MySQL 8.4 (local), Redis Alpine
- **Porta Laravel:** 8001
- **Porta Vite:** 5174

---

## 📁 ESTRUTURA DO PROJETO
```
sors/
├── app/
│   ├── Http/Controllers/      # Controllers (Auth já configurado)
│   ├── Models/                 # User.php (outros a criar)
│   └── Policies/               # Policies de autorização (a criar)
├── database/
│   ├── migrations/             # Migrations do SORS (a criar)
│   └── seeders/                # CategorySeeder (a criar)
├── resources/
│   ├── js/
│   │   ├── Components/         # Componentes Vue reutilizáveis
│   │   ├── Layouts/            # AuthenticatedLayout, GuestLayout
│   │   ├── Pages/              # Views Inertia (Dashboard, Auth, Profile)
│   │   └── app.ts              # Entry point
│   ├── css/app.css             # Tailwind imports
│   └── views/app.blade.php     # Template base Inertia
├── routes/
│   ├── web.php                 # Rotas principais
│   └── auth.php                # Rotas de autenticação (Breeze)
├── .env                        # Configurações (NÃO COMMITAR)
├── compose.yaml                # Docker Sail
└── vite.config.js              # Config Vite
```

---

## ⚙️ CONFIGURAÇÕES IMPORTANTES

### .env (Principais)
```env
APP_SERVICE=multi-tenant.sistema
APP_PORT=8001
VITE_PORT=5174

DB_CONNECTION=pgsql
DB_HOST=aws-1-sa-east-1.pooler.supabase.com
DB_PORT=5432
DB_DATABASE=postgres
DB_USERNAME=postgres.ctzrzsuocdjpysdppcfx
DB_PASSWORD="[SENHA_COM_ASPAS]"

CACHE_STORE=file              # NÃO usar database com Supabase
SESSION_DRIVER=file           # NÃO usar database com Supabase
```

### vite.config.js (Crítico)
```javascript
server: {
    host: '0.0.0.0',
    port: 5174,
    hmr: {
        host: 'localhost',  // NÃO usar multi-tenant.sistema.localhost
    },
}
```

---

## 🚀 COMANDOS ÚTEIS

### Sail (alias configurado: `sail = ./vendor/bin/sail`)
```bash
# Gerenciar containers
sail up -d                    # Iniciar
sail down                     # Parar
sail ps                       # Status

# Artisan
sail artisan migrate          # Rodar migrations
sail artisan migrate:fresh --seed  # Resetar banco
sail artisan config:clear     # Limpar cache config
sail artisan route:list       # Listar rotas

# NPM/Vite
sail npm run dev              # Dev server (HMR)
sail npm run build            # Build produção

# Banco
sail artisan tinker           # Console interativo
sail artisan db:seed          # Rodar seeders

# Logs
sail logs multi-tenant.sistema --tail=50
```

### Acesso

- **Laravel:** http://localhost:8001
- **Vite HMR:** http://localhost:5174

---

## 🏗️ ARQUITETURA DO SORS

### 4 Tabs Principais

| Tab | Objetivo | Frequência de Uso |
|-----|----------|-------------------|
| **📊 Visão** | Dashboard: status atual + projeção 30 dias | Diária |
| **💰 Contas** | Detalhe de C/C, Cartões, Parcelamentos | Semanal |
| **📈 Análise** | Gastos por categoria + histórico | Mensal |
| **⚙️ Config** | Gerenciar contas, categorias, perfil | Rara |

### Models e Relacionamentos (A CRIAR)
```php
// User (já existe via Breeze)
hasMany: accounts, categories, transactions

// Account
belongsTo: user
hasMany: transactions
Campos: name, type (enum), initial_balance, current_balance, credit_limit, closing_day, due_day

// Category  
belongsTo: user (nullable)
hasMany: transactions
Campos: name, type (enum: income/expense), color, icon, is_default

// Transaction
belongsTo: user, account, category
Campos: type (enum), amount, description, transaction_date, is_paid, is_recurring
```

### Categorias Padrão (7 categorias)

**Despesas:**
- 🍔 Alimentação (#27AE60)
- 🚗 Transporte (#3498DB)
- 🏠 Moradia (#9B59B6)
- 🎮 Lazer (#E67E22)
- 💊 Saúde (#E74C3C)

**Receitas:**
- 💰 Salário (#2ECC71)
- 📦 Outros (#95A5A6)

---

## 🎨 DESIGN GUIDELINES

### Identidade Visual

**Paleta de Cores:**
- **Primary:** #3498DB (Azul - confiança)
- **Success:** #27AE60 / #2ECC71 (Verde - positivo)
- **Danger:** #E74C3C (Vermelho - alerta)
- **Neutral:** #95A5A6, #1E1E1E, #FFFFFF

**Tipografia:**
- **Fonte:** DM Sans (ou Figtree/Inter)
- **Weights:** Regular (400), Medium (500), Semibold (600)

### Princípios

1. **Clareza > Beleza** → Informação clara primeiro
2. **Hierarquia Visual Forte** → Mais importante = mais espaço/contraste
3. **Cores Intencionais** → Verde = positivo, Vermelho = alerta, Neutro = info
4. **Mobile-First** → 90% do uso é mobile
5. **Acessibilidade** → Contraste WCAG AA, touch targets 44x44px

### Componentes Vue

**Criar em:** `resources/js/Components/`

**Padrão:**
```vue
<script setup lang="ts">
// Imports
import { ref, computed } from 'vue';

// Props/Emits
defineProps<{ /* tipos */ }>();
defineEmits<{ /* eventos */ }>();

// Estado/Lógica
</script>

<template>
  <!-- UI com Tailwind -->
</template>
```

---

## 🚨 REGRAS CRÍTICAS

### ❌ O QUE NÃO FAZER

1. **NÃO prometa Open Finance/automação bancária**
2. **NÃO use categorização IA** (manual simples)
3. **NÃO adicione 50 features** (MVP enxuto)
4. **NÃO cobre assinatura** antes de validar
5. **NÃO use notificações agressivas** (evitar ansiedade)
6. **NÃO use `CACHE_STORE=database`** com Supabase (lento)
7. **NÃO modifique migrations** após rodadas sem avisar

### ✅ O QUE FAZER

1. **✅ Foco em PROJEÇÃO** (não só histórico)
2. **✅ Input rápido** (3 campos: Valor, Categoria, Conta)
3. **✅ Começar simples**, evoluir depois
4. **✅ Design limpo** e hierarquia clara
5. **✅ Dados locais primeiro** (Supabase = backup)
6. **✅ LGPD compliance** (usuário controla dados)
7. **✅ Testar cada feature** antes de prosseguir

---

## 🎯 ROADMAP MVP

### Fase 1: Setup ✅ (CONCLUÍDO)
- [x] Laravel + Supabase configurado
- [x] Breeze + Inertia + Vue instalados
- [x] Docker Sail funcionando
- [x] Vite com HMR configurado

### Fase 2: Database (PRÓXIMO)
- [ ] Criar migrations (accounts, categories, transactions)
- [ ] Criar Models com relationships
- [ ] Criar Seeders (CategorySeeder)
- [ ] Criar Policies (AccountPolicy, TransactionPolicy)

### Fase 3: Backend
- [ ] Controllers (AccountController, TransactionController, CategoryController)
- [ ] Rotas API/Web
- [ ] Validação de dados
- [ ] Testes básicos

### Fase 4: Frontend (Tab por Tab)
- [ ] Layout base com 4 tabs
- [ ] Tab Visão (Dashboard)
- [ ] Tab Contas (Lista + Detalhes)
- [ ] Tab Análise (Gráficos)
- [ ] Tab Config (CRUD categorias)
- [ ] FAB (Floating Action Button) - Adicionar Transação

### Fase 5: Refinamento
- [ ] Projeção de 30 dias
- [ ] Parcelamentos inteligentes
- [ ] Gráficos (Chart.js ou Recharts)
- [ ] Testes com usuário real (Gabriel)

---

## 🐛 TROUBLESHOOTING

### Página branca no navegador
```bash
# 1. Verifica se Vite está rodando
sail npm run dev

# 2. Limpa caches
sail artisan config:clear
sail artisan cache:clear
sail artisan route:clear
sail artisan view:clear

# 3. Reinicia containers
sail down && sail up -d
```

### Erro de autenticação Supabase
```bash
# Verifica senha no .env (deve ter aspas duplas)
cat .env | grep DB_PASSWORD

# Se necessário, atualiza:
# DB_PASSWORD="SenhaComPontoFinal."
```

### Erro 500 no Laravel
```bash
# Vê logs detalhados
sail logs multi-tenant.sistema --tail=50

# Verifica permissões
sail exec multi-tenant.sistema chmod -R 775 storage bootstrap/cache

# Verifica .env
sail artisan config:show database
```

### Container não inicia
```bash
# Vê status
docker ps -a

# Vê logs
docker logs sors-multi-tenant.sistema-1

# Rebuild
sail build --no-cache
sail up -d
```

---

## 📚 REFERÊNCIAS

- **Documento do Projeto:** `/mnt/project/Documento_do_Projeto`
- **Pesquisa de Mercado:** `/mnt/project/Pesquisa_de_Apps_Financeiros_Pessoais`
- **Laravel Docs:** https://laravel.com/docs/12.x
- **Inertia Docs:** https://inertiajs.com
- **Vue 3 Docs:** https://vuejs.org
- **Tailwind Docs:** https://tailwindcss.com

---

## 👤 DESENVOLVEDOR

**Gabriel Felix**  
UX Designer @ Grupo MAIS  
**Objetivo:** Evoluir de Pleno → Sênior  
**Meta:** Portfólio completo (pesquisa → design → dev)

---

## 📝 NOTAS IMPORTANTES

1. **Este é um projeto real** sendo usado pelo desenvolvedor
2. **Decisões devem ser justificadas** (não apenas implementar)
3. **Priorizar funcionalidade sobre estética** no MVP
4. **Testar cada feature** antes de prosseguir
5. **Código limpo e comentado** (TypeScript types obrigatórios)

---

**Última build bem-sucedida:** 08/01/2026 01:29 BRT  
**Status do sistema:** ✅ Operacional  
**Próximo passo:** Criar migrations e Models
```

---

**Salva esse README e SEMPRE que começar a trabalhar com o agente, você faz:**
```
Leia o arquivo README.md na raiz do projeto antes de prosseguir.
