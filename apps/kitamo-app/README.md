# Kitamo App

Aplicativo nativo do Kitamo feito com Expo, React Native e TypeScript.

## Rodar localmente

```bash
cd apps/kitamo-app
npm install
npm start
```

Por padrão o app usa `http://localhost:8000/api/v1` no iOS/web e `http://10.0.2.2:8000/api/v1` no emulador Android. Para celular físico, ajuste `expo.extra.apiUrl` em `app.json` para o IP da máquina que roda o Laravel.

## API esperada

O backend Laravel precisa estar rodando a partir da raiz do projeto:

```bash
php artisan serve --host=0.0.0.0 --port=8000
```

Configure a IA no `.env`:

```env
GEMINI_API_KEY=
GEMINI_MODEL=gemini-3-flash-preview
```

## Telas principais

- Saldo geral e gastos do mês.
- Lançamentos simples de entrada e saída.
- Importação de OFX/CSV.
- Assistente financeiro com Gemini.
