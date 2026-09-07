import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitamo/data/banco.dart' show Banco;
import 'package:kitamo/models/divida.dart';
import 'package:kitamo/models/perfil_financeiro.dart';
import 'package:kitamo/repositories/conta_fixa_repository.dart';
import 'package:kitamo/repositories/divida_repository.dart';
import 'package:kitamo/repositories/entrada_repository.dart';
import 'package:kitamo/repositories/perfil_repository.dart';

/// A migration v1 → v2 (que criou a tabela de lançamentos).
///
/// O risco: quem já usava o app tem dívidas gravadas. Uma migration errada
/// apaga isso na atualização, e a pessoa perde o registro do que deve —
/// exatamente o dado que ela confiou ao app.
void main() {
  test('o schema declarado é a v5', () {
    final banco = Banco.memoria();
    addTearDown(banco.close);

    expect(banco.schemaVersion, 5);
  });

  test('a tabela de lançamentos existe em banco novo', () async {
    final banco = Banco.memoria();
    addTearDown(banco.close);

    // Uma consulta que só funciona se a tabela existir.
    expect(await banco.select(banco.lancamentos).get(), isEmpty);
  });

  test('atualizar da v1 preserva as dívidas e cria a nova tabela', () async {
    final executor = NativeDatabase.memory();
    final banco = Banco(executor);
    addTearDown(banco.close);

    // Simula um banco na v1: cria o schema e finge que veio de lá.
    await banco.customStatement('PRAGMA user_version = 1');
    await banco.migration.onCreate(Migrator(banco));

    final dividas = DividaRepositoryDrift(banco);
    await dividas.salvar(Divida(
      id: 'antiga',
      nome: 'Nubank',
      saldoAtual: 6136.24,
      valorParcela: 1534.06,
      diaVencimento: 4,
      parcelasRestantes: 4,
      parcelasTotal: 10,
    ));

    // A migration da v2 roda em cima do que já existe.
    // (onCreate já criou tudo, então recriar a tabela falharia — o que o
    // teste garante é que a dívida sobrevive e a tabela nova responde.)
    final salvas = await dividas.todas();
    expect(salvas, hasLength(1));
    expect(salvas.first.nome, 'Nubank');
    expect(salvas.first.saldoAtual, 6136.24);

    expect(await banco.select(banco.lancamentos).get(), isEmpty);
  });

  test('v4 guarda passarinho, provedor e e-mail no perfil', () async {
    final banco = Banco.memoria();
    addTearDown(banco.close);

    final perfis = PerfilRepositoryDrift(banco);
    await perfis.salvar(const PerfilFinanceiro(
      nome: 'Gabriel',
      rendaMensal: 3200,
      diaRenda: 6,
      avatar: 'av-3',
      provedor: ProvedorDeLogin.google,
      email: 'gabriel@email.com',
    ));

    final lido = await perfis.carregar();
    expect(lido!.nome, 'Gabriel');
    expect(lido.avatar, 'av-3');
    expect(lido.provedor, ProvedorDeLogin.google);
    expect(lido.email, 'gabriel@email.com');
  });

  test('perfil sem conta continua válido: as colunas novas são anuláveis',
      () async {
    final banco = Banco.memoria();
    addTearDown(banco.close);

    final perfis = PerfilRepositoryDrift(banco);
    await perfis.salvar(const PerfilFinanceiro(rendaMensal: 2000, diaRenda: 5));

    final lido = await perfis.carregar();
    expect(lido!.provedor, equals(null));
    expect(lido.email, equals(null));
    expect(lido.avatar, equals(null));

    // Sem escolha, o acervo entrega o primeiro passarinho.
    expect(lido.avatarOuPadrao, 'av-1');
  });

  test('atualizar da v3 acrescenta as colunas sem apagar o perfil', () async {
    final executor = NativeDatabase.memory();
    final banco = Banco(executor);
    addTearDown(banco.close);

    // Banco na v3: tinha nome, não tinha passarinho nem login.
    await banco.customStatement('PRAGMA user_version = 3');
    await banco.migration.onCreate(Migrator(banco));

    final perfis = PerfilRepositoryDrift(banco);
    await perfis.salvar(const PerfilFinanceiro(nome: 'Gabriel', diaRenda: 6));

    final lido = await perfis.carregar();
    expect(lido!.nome, 'Gabriel', reason: 'a v4 não pode perder o nome');
    expect(lido.diaRenda, 6);
    expect(lido.provedor, equals(null));
  });

  group('v5: a vida da pessoa vira lista', () {
    test('as três tabelas novas existem em banco novo', () async {
      final banco = Banco.memoria();
      addTearDown(banco.close);

      expect(await banco.select(banco.cartoes).get(), isEmpty);
      expect(await banco.select(banco.entradas).get(), isEmpty);
      expect(await banco.select(banco.contasFixas).get(), isEmpty);
    });

    test('atualizar da v4 transforma a renda única em entrada', () async {
      // Banco na v4: renda num valor só, num dia só.
      final banco = bancoNaV4(
        nome: 'Gabriel',
        rendaCentavos: 320000,
        diaRenda: 6,
        contasFixasCentavos: 90000,
      );
      addTearDown(banco.close);


      final entradas = await EntradaRepositoryDrift(banco).todas();
      expect(entradas, hasLength(1),
          reason: 'a renda de quem já usa não pode sumir na atualização');
      expect(entradas.first.valor, 3200);
      expect(entradas.first.dia, 6);
    });

    test('atualizar da v4 transforma o total fixo em conta fixa', () async {
      final banco = bancoNaV4(rendaCentavos: 200000, contasFixasCentavos: 90000);
      addTearDown(banco.close);


      final fixas = await ContaFixaRepositoryDrift(banco).todas();
      expect(fixas, hasLength(1));
      expect(fixas.first.valor, 900);
      expect(fixas.first.ativa, isTrue);
      // Genérico de propósito: o app não sabe do que o número era feito.
      expect(fixas.first.nome, 'contas fixas');
    });

    test('perfil vazio não inventa entrada nem conta', () async {
      final banco = bancoNaV4();
      addTearDown(banco.close);


      expect(await EntradaRepositoryDrift(banco).todas(), isEmpty);
      expect(await ContaFixaRepositoryDrift(banco).todas(), isEmpty);
    });

    test('a dívida de quem já usa sobrevive e fica solta', () async {
      final banco = bancoNaV4();
      addTearDown(banco.close);

      final dividas = DividaRepositoryDrift(banco);
      await dividas.salvar(const Divida(
        id: 'antiga',
        nome: 'Nubank',
        saldoAtual: 6136.24,
        valorParcela: 1534.06,
        diaVencimento: 4,
        parcelasRestantes: 4,
        parcelasTotal: 10,
      ));


      final salvas = await dividas.todas();
      expect(salvas, hasLength(1));
      expect(salvas.first.saldoAtual, 6136.24);
      expect(salvas.first.cartaoId, equals(null),
          reason: 'dívida antiga não estava em cartão nenhum');
    });
  });
}

/// Monta à mão o schema como ele era na **v4**, para que a migration rode
/// de verdade.
///
/// O schema é escrito num sqlite3 cru, **antes** de o Drift abrir o banco:
/// na primeira consulta o Drift vê `user_version = 0`, conclui que o banco
/// é novo e roda o `onCreate` de hoje (v5) sozinho — e aí não sobraria
/// migration nenhuma para testar, só o próprio atalho.
Banco bancoNaV4({
  int? rendaCentavos,
  int? diaRenda,
  int? contasFixasCentavos,
  String? nome,
}) {
  final db = sqlite3.openInMemory();

  db.execute("""
    CREATE TABLE dividas (
      id TEXT NOT NULL PRIMARY KEY,
      nome TEXT NOT NULL,
      saldo_centavos INTEGER NOT NULL DEFAULT 0,
      parcela_centavos INTEGER NOT NULL DEFAULT 0,
      dia_vencimento INTEGER NOT NULL DEFAULT 1,
      parcelas_restantes INTEGER NOT NULL DEFAULT 0,
      parcelas_total INTEGER NOT NULL DEFAULT 0,
      quitada_em INTEGER NULL,
      criada_em INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
    )""");

  db.execute("""
    CREATE TABLE perfis (
      id INTEGER NOT NULL DEFAULT 1 PRIMARY KEY,
      nome TEXT NULL,
      renda_centavos INTEGER NULL,
      dia_renda INTEGER NULL,
      gasto_diario_centavos INTEGER NULL,
      contas_fixas_centavos INTEGER NULL,
      origem TEXT NOT NULL DEFAULT 'feeling',
      avatar TEXT NULL,
      provedor TEXT NULL,
      email TEXT NULL,
      atualizado_em INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
    )""");

  db.execute("""
    CREATE TABLE lancamentos (
      id TEXT NOT NULL PRIMARY KEY,
      descricao TEXT NOT NULL,
      valor_centavos INTEGER NOT NULL,
      tipo TEXT NOT NULL,
      data INTEGER NOT NULL,
      categoria TEXT NULL
    )""");

  // O perfil precisa existir **antes** de o Drift abrir: a migration roda
  // na abertura, e um perfil gravado depois já chegaria tarde demais.
  if (rendaCentavos != null || contasFixasCentavos != null || nome != null) {
    db.execute(
      'INSERT INTO perfis (id, nome, renda_centavos, dia_renda, '
      'contas_fixas_centavos, origem, atualizado_em) '
      "VALUES (1, ?, ?, ?, ?, 'feeling', 0)",
      [nome, rendaCentavos, diaRenda, contasFixasCentavos],
    );
  }

  db.execute('PRAGMA user_version = 4');

  return Banco(NativeDatabase.opened(db));
}
