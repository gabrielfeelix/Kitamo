import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'chave_do_banco.dart';
import 'tabelas.dart';

part 'banco.g.dart';

/// O banco local, cifrado com SQLite3MultipleCiphers (AES-256).
///
/// Cifrar em repouso importa porque o que a Kitamo guarda é constrangedor:
/// saber que alguém deve R$ 6.136 e está apertado é dado íntimo. Não gera
/// fraude, mas vaza reputação — e num aparelho com root qualquer app lê um
/// SQLite comum.
@DriftDatabase(tables: [Dividas, Perfis, Lancamentos])
class Banco extends _$Banco {
  Banco(super.e);

  /// Banco em memória, sem cifra, para teste.
  Banco.memoria() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Versionado desde a v1 de propósito: banco sem migration é
          // dívida que só aparece quando já existe usuário com dado dentro,
          // e aí não dá mais para recriar do zero.
          if (from < 2) {
            await m.createTable(lancamentos);
          }
          // v3: o cabeçalho do Início chama a pessoa pelo nome, como no
          // design. Coluna nova e anulável — quem já usava o app não perde
          // nada, só continua sem nome até dizer qual é.
          if (from < 3) {
            await m.addColumn(perfis, perfis.nome);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

/// Abre o banco cifrado no diretório privado do app.
Future<Banco> abrirBanco({ChaveDoBanco? chaveiro}) async {
  final chave = await (chaveiro ?? ChaveDoBanco()).obter();

  final executor = LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final arquivo = File(p.join(dir.path, 'kitamo.db'));

    return NativeDatabase(
      arquivo,
      setup: (db) {
        // A chave precisa vir antes de qualquer outra instrução.
        db.execute("PRAGMA key = '$chave'");

        // Prova que a build tem cifra. Sem esta checagem, uma build sem
        // SQLite3MultipleCiphers ignoraria o PRAGMA key em silêncio e
        // gravaria tudo em texto puro — a falha mais perigosa possível
        // aqui, porque não dá erro nenhum.
        // SQLite3MultipleCiphers responde `PRAGMA cipher` (ex.: chacha20).
        // `cipher_version` é do SQLCipher e volta vazio aqui — checar o
        // pragma errado deixaria passar uma build sem cifra.
        final r = db.select('PRAGMA cipher');
        if (r.isEmpty || r.first.values.first == null) {
          throw StateError(
            'Build sem suporte a cifra: o banco seria gravado em texto puro.',
          );
        }
      },
    );
  });

  return Banco(executor);
}
