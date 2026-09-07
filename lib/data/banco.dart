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
@DriftDatabase(tables: [Dividas, Perfis, Lancamentos, Cartoes, Entradas, ContasFixas])
class Banco extends _$Banco {
  Banco(super.e);

  /// Banco em memória, sem cifra, para teste.
  Banco.memoria() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 5;

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
          // v4: o perfil ganhou passarinho e login social. As três colunas
          // são anuláveis pelo mesmo motivo do nome: quem já usava o app
          // continua sem nada disso até escolher.
          if (from < 4) {
            await m.addColumn(perfis, perfis.avatar);
            await m.addColumn(perfis, perfis.provedor);
            await m.addColumn(perfis, perfis.email);
          }
          // v5: a vida da pessoa não cabia no modelo. Renda virou lista de
          // entradas (cada uma com seu dia), contas fixas viraram lista, e
          // as compras passam a morar dentro de um cartão.
          //
          // **Migrar não é criar as tabelas: é não perder quem já usa.** O
          // valor único que a pessoa digitou vira a primeira linha da lista
          // — ela abre o app e vê o que já tinha, agora editável.
          if (from < 5) {
            await m.createTable(cartoes);
            await m.createTable(entradas);
            await m.createTable(contasFixas);
            await m.addColumn(dividas, dividas.cartaoId);
            await _converterPerfilEmListas();
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// O `rendaMensal`/`diaRenda` e o `contasFixasEstimadas` de quem já usava
  /// viram a primeira linha de cada lista.
  ///
  /// Sem isto a atualização apagaria as respostas do onboarding na cara da
  /// pessoa: ela abriria o app zerado, com o diário errado, sem ter feito
  /// nada. É o dado que ela confiou ao app.
  Future<void> _converterPerfilEmListas() async {
    final linha = await (select(perfis)..where((t) => t.id.equals(1)))
        .getSingleOrNull();
    if (linha == null) return;

    final renda = linha.rendaCentavos;
    if (renda != null && renda > 0) {
      await into(entradas).insert(EntradasCompanion.insert(
        id: 'entrada-migrada',
        nome: 'salário',
        valorCentavos: renda,
        // Sem dia declarado, o dia 5 é o mais comum de salário no Brasil;
        // ela troca na tela, e agora dá pra trocar.
        dia: linha.diaRenda ?? 5,
      ));
    }

    final fixas = linha.contasFixasCentavos;
    if (fixas != null && fixas > 0) {
      await into(contasFixas).insert(ContasFixasCompanion.insert(
        id: 'fixa-migrada',
        // Genérico de propósito: o app não sabe do que o número era feito,
        // e inventar "aluguel" seria decidir pela pessoa.
        nome: 'contas fixas',
        valorCentavos: fixas,
      ));
    }
  }
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
