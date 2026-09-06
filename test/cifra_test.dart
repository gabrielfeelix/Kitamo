@TestOn('linux || mac-os || windows')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

/// A prova de que a cifra funciona.
///
/// Todo o resto da segurança em repouso depende disto. E a falha que este
/// teste caça é silenciosa: uma build sem SQLite3MultipleCiphers **ignora
/// o PRAGMA key sem dar erro** e grava tudo em texto puro. O app
/// funcionaria perfeitamente, e os dados estariam expostos.
void main() {
  late Directory tmp;

  setUp(() => tmp = Directory.systemTemp.createTempSync('kitamo_cifra'));
  tearDown(() => tmp.deleteSync(recursive: true));

  test('a build tem suporte a cifra', () {
    final db = sqlite3.openInMemory();
    addTearDown(db.close);

    // SQLite3MultipleCiphers responde `PRAGMA cipher` com o algoritmo
    // ativo. `cipher_version` é do SQLCipher e volta vazio nesta build.
    final r = db.select('PRAGMA cipher');

    expect(r, isNotEmpty,
        reason: 'Sem cifra, o banco seria gravado em texto puro.');
    expect(r.first.values.first, isNotNull);
  });

  test('o arquivo não expõe o conteúdo sem a chave', () {
    final caminho = '${tmp.path}/cifrado.db';

    final db = sqlite3.open(caminho);
    db.execute("PRAGMA key = 'chave-secreta-de-teste'");
    db.execute('CREATE TABLE dividas (nome TEXT, saldo INTEGER)');
    db.execute("INSERT INTO dividas VALUES ('Nubank', 613624)");
    db.close();

    final bytes = File(caminho).readAsBytesSync();
    final texto = String.fromCharCodes(bytes);

    // O nome do credor não pode aparecer em claro no arquivo.
    expect(texto.contains('Nubank'), isFalse,
        reason: 'O credor apareceu em texto puro dentro do arquivo.');

    // Nem o cabeçalho padrão do SQLite, que denuncia banco não cifrado.
    expect(texto.startsWith('SQLite format 3'), isFalse,
        reason: 'Cabeçalho SQLite em claro: o arquivo não foi cifrado.');
  });

  test('a chave errada não abre o banco', () {
    final caminho = '${tmp.path}/protegido.db';

    final certo = sqlite3.open(caminho);
    certo.execute("PRAGMA key = 'chave-certa'");
    certo.execute('CREATE TABLE dividas (nome TEXT)');
    certo.execute("INSERT INTO dividas VALUES ('Nubank')");
    certo.close();

    final errado = sqlite3.open(caminho);
    errado.execute("PRAGMA key = 'chave-errada'");

    expect(
      () => errado.select('SELECT * FROM dividas'),
      throwsA(isA<SqliteException>()),
      reason: 'Chave errada conseguiu ler os dados.',
    );

    errado.close();
  });

  test('sem chave nenhuma também não abre', () {
    final caminho = '${tmp.path}/protegido2.db';

    final certo = sqlite3.open(caminho);
    certo.execute("PRAGMA key = 'chave-certa'");
    certo.execute('CREATE TABLE dividas (nome TEXT)');
    certo.close();

    final semChave = sqlite3.open(caminho);

    expect(
      () => semChave.select('SELECT * FROM dividas'),
      throwsA(isA<SqliteException>()),
    );

    semChave.close();
  });
}
