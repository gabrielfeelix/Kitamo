# Segurança — Kitamo

Estado em 06/09/2026. Complementa `PLANO-EXECUCAO.md` §2.

## O que o app NÃO guarda

Decisão de produto, e a que mais reduz risco: a Kitamo é app de **projeção**,
não de banco.

**Nunca pedir senha de banco, número de cartão ou CPF.** Dado que não existe
não vaza, não é roubado e não precisa ser protegido.

Se um dia a importação virar conexão automática, passa por Open Finance
(consentimento revogável, sem senha) — nunca por "digite sua senha aqui".

## O que guarda, e como

| Dado | Onde | Proteção |
|---|---|---|
| Dívidas, renda, gastos | banco local | SQLite3MultipleCiphers (AES/chacha20) |
| Chave do banco | Keychain / Keystore | enclave de hardware quando existe |
| Preferência de bloqueio | Keychain / Keystore | não em preferências comuns |
| Backup exportado | onde a pessoa escolher | **texto legível — avisado na tela** |

O backup sai em claro de propósito: quem guarda é a pessoa, e backup que
ela não consegue abrir não é backup. O aviso está em
`BackupService.avisoDeExportacao` e a tela precisa mostrá-lo.

## Verificações automatizadas

`test/cifra_test.dart` prova, a cada rodada:

- a build tem cifra (`PRAGMA cipher` responde)
- o nome do credor **não aparece em texto puro** no arquivo
- chave errada não abre o banco
- sem chave também não abre

A primeira existe porque a falha é silenciosa: uma build sem
SQLite3MultipleCiphers **ignora o `PRAGMA key` sem erro** e grava tudo em
claro. O app funcionaria perfeitamente, com os dados expostos.

> Atenção: `PRAGMA cipher_version` é do SQLCipher e volta vazio nesta
> build. Checar o pragma errado deixaria passar exatamente essa falha.

## Build de release

```bash
flutter build apk --release --obfuscate --split-debug-info=build/simbolos
```

- `--obfuscate` renomeia símbolos Dart
- `--split-debug-info` tira o mapa de símbolos do APK (guarde a pasta: sem
  ela não dá para ler crash report)
- ProGuard ativo (`isMinifyEnabled`), com regras em `proguard-rules.pro`
  preservando o que entra por JNI/reflexão — SQLite e biometria quebrariam
  só no release, onde é mais caro descobrir

**Pendência conhecida:** o build avisa que a lib ELF ainda carrega
informação DWARF. A flag `--strip` não existe em `build apk` (é de
`build aar`). Resolver antes da loja, provavelmente via `--split-per-abi`
ou App Bundle.

## Bloqueio por biometria

Opcional, ligável em Perfil. Obrigatório trancaria quem tem aparelho sem
biometria — pior que o risco que evita.

Só ativa se a pessoa autenticar **na hora**: ligar sem provar deixaria o app
trancado para o próprio dono se a biometria não funcionasse. Aceita PIN e
padrão do aparelho (`biometricOnly: false`), senão exclui quem não cadastrou
digital.

Quando ativo, roda **antes de qualquer dado aparecer**.

## Decisões deliberadas

- **Sem analytics de terceiro.** SDK de analytics é código com acesso total
  ao processo
- **Sem log de valor.** `print` vai para o logcat, que outros apps leem
- **Sem servidor.** Backup por arquivo: nenhum dado de dívida trafega ou
  fica parado em infraestrutura nossa
- **Web fora.** Não é decisão de segurança, mas de plataforma: SQLite
  nativo usa `dart:ffi`

## Antes da loja

- [ ] Resolver o DWARF no APK de release
- [ ] Auditar dependências (`flutter pub outdated`, CVEs)
- [ ] Testar o release ofuscado em aparelho real — minify quebra em
      runtime, não no build
- [ ] Política de privacidade dizendo que nada sai do aparelho
- [ ] Revisar permissões do AndroidManifest
