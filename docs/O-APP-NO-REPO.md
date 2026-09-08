# O app Flutter dentro deste repo

O app vive em **`apps/app`**. Antes ele morava solto em
`~/dev/kitamo-app`, **sem remote nenhum**: 44 commits que existiam só numa
máquina. Foi por isso que veio pra cá, em 07/09/2026.

Veio com `git subtree`, então o histórico dele está inteiro no grafo — os
commits do app aparecem no `git log` junto com os do site.

## Por que junto, e não dois repos

- App e site vão compartilhar contrato de API, regras de cálculo e texto
  quando o backend existir. Em dois repos isso vira sincronização na mão.
- É uma pessoa só trabalhando. Publicar um APK já mexe nos dois (o build
  do app, a página de download do site): em repos separados seriam dois
  commits e dois PRs pra uma coisa só.

O `apps/kitamo-app` (React Native/Expo) foi removido no mesmo dia: parou
em maio, quando o produto pivotou pro Flutter, e ficava ao lado do app de
verdade fazendo parecer que havia dois. O histórico continua no git.

## O deploy do site NÃO leva o app

Os dois workflows têm `--exclude='apps'`. Sem isso o rsync mandaria o
código-fonte do Flutter pro servidor web — megabytes que não têm nada a
ver com o Laravel e que crescem a cada build.

O app não tem deploy automático: ele vira APK e sobe pro site pela mão,
como descrito em `APK-NO-SITE.md`.

## A keystore não está no Git, e não pode estar

`apps/app/android/kitamo-release.jks` e `key.properties` estão no
`.gitignore` — chave de assinatura em repositório é chave pública. Por
isso elas **não vieram junto no subtree**: foram copiadas na mão.

**Se essa keystore for perdida, ninguém que já instalou consegue
atualizar** — o Android recusa uma atualização assinada com chave
diferente. Guarde uma cópia fora da máquina.

Conferir que uma build está assinada com ela:

```bash
cd apps/app
~/.local/opt/android-sdk/build-tools/36.0.0/apksigner verify \
  --print-certs build/app/outputs/flutter-apk/app-release.apk
# SHA-256 esperado: 0c5c1ec4dd974089559d841593dc5f80cfdb444ac5c8cf7cf39dd16a5ff3409a
```

## Rodar o app

```bash
cd apps/app
export PATH="$HOME/flutter/bin:$PATH"
flutter test && flutter analyze
flutter build apk --release
```

**Suba o `version:` do `pubspec.yaml` a cada APK publicado.** O número
depois do `+` é o versionCode: instalar por cima com o mesmo valor é
ignorado em silêncio pelo Android, que mantém o app antigo sem avisar.
