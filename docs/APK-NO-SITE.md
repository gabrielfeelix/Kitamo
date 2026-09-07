# O APK no site

A página fica em **`/baixar`** (`dev.kitamo.com.br/baixar`). É de teste
fechado: não está no menu, e leva `noindex` para não cair em busca.

## Por que o APK não vai no Git

São ~66MB por versão. No Git isso incha o repositório para sempre (o
histórico guarda cada versão) e deixa o rsync do deploy lento. Então o
arquivo sobe **direto para o servidor por SSH**, e `public/downloads/*.apk`
está no `.gitignore`.

O rsync do deploy **não usa `--delete`**, então o APK sobrevive às
publicações. Se alguém acrescentar `--delete` ao workflow, o arquivo some
no deploy seguinte e a página passa a mostrar "versão nova sendo
preparada" — que é o aviso honesto, mas não é o que se quer.

## Publicar uma versão nova

```bash
# 1. Gerar o APK assinado (na pasta do app)
cd ~/dev/kitamo-app
export PATH="$HOME/flutter/bin:$PATH"
flutter build apk --release

# 2. Mandar pro servidor
scp -P 65002 build/app/outputs/flutter-apk/app-release.apk \
  hostinger-kitamo:~/domains/dev.kitamo.com.br/public_html/public/downloads/kitamo.apk
```

A página lê tamanho e data **do arquivo em disco**, então não há número
para atualizar à mão. Versão errada na tela faria o testador instalar o
APK velho e reportar bug já corrigido.

## Por que o APK universal, e não o de 28MB

`--split-per-abi` gera um APK de 28MB para arm64. Mas quem tiver um
celular mais antigo (armv7) recebe "app não instalado" sem entender o
motivo — e numa página onde a pessoa se serve sozinha não há como
entregar o arquivo certo para cada aparelho, que é justamente o que a
Play Store faria. Os 66MB compram "instala em qualquer Android".

O x86_64 fica de fora: só existe em emulador.

## A assinatura

O APK é assinado com `android/kitamo-release.jks` (alias `kitamo`, válida
até 2054), que **não está no Git** — as credenciais ficam em
`android/key.properties`, também fora.

Isso é o que permite **atualizar por cima**: o Android recusa uma
atualização assinada com chave diferente com
`INSTALL_FAILED_UPDATE_INCOMPATIBLE`, e o testador teria que desinstalar,
perdendo os dados do app.

**Se essa keystore for perdida, ninguém que já instalou consegue
atualizar.** Guarde uma cópia fora da máquina.

Conferir a assinatura de um APK:

```bash
~/.local/opt/android-sdk/build-tools/36.0.0/apksigner verify \
  --print-certs build/app/outputs/flutter-apk/app-release.apk
# SHA-256 esperado: 0c5c1ec4dd974089559d841593dc5f80cfdb444ac5c8cf7cf39dd16a5ff3409a
```

O `apksigner` diz `Verified using v1 scheme: false`, e está tudo certo:
os arquivos v1 estão no APK (`META-INF/CERT.RSA`), mas com o `minSdk`
atual ele valida a partir do v2.
