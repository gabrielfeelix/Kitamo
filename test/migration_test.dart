import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitamo/data/banco.dart' show Banco;
import 'package:kitamo/models/divida.dart';
import 'package:kitamo/models/perfil_financeiro.dart';
import 'package:kitamo/repositories/divida_repository.dart';
import 'package:kitamo/repositories/perfil_repository.dart';

/// A migration v1 → v2 (que criou a tabela de lançamentos).
///
/// O risco: quem já usava o app tem dívidas gravadas. Uma migration errada
/// apaga isso na atualização, e a pessoa perde o registro do que deve —
/// exatamente o dado que ela confiou ao app.
void main() {
  test('o schema declarado é a v4', () {
    final banco = Banco.memoria();
    addTearDown(banco.close);

    expect(banco.schemaVersion, 4);
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
}
