import 'package:drift/drift.dart';

import '../data/banco.dart';
import '../models/divida.dart' as modelo;
import 'dinheiro.dart';

/// Acesso às dívidas.
///
/// A tela conversa com esta interface, não com o Drift. É o que permite
/// ligar sincronização na nuvem depois sem mexer em nenhuma tela.
abstract interface class DividaRepository {
  Future<List<modelo.Divida>> todas();
  Future<List<modelo.Divida>> emAberto();
  Stream<List<modelo.Divida>> observarEmAberto();
  Future<void> salvar(modelo.Divida divida);
  Future<void> remover(String id);

  /// Marca uma parcela como paga. É o "quitei essa".
  ///
  /// Devolve a dívida atualizada, ou null se ela não existe.
  Future<modelo.Divida?> quitarParcela(String id, {DateTime? em});
}

class DividaRepositoryDrift implements DividaRepository {
  DividaRepositoryDrift(this._banco);

  final Banco _banco;

  @override
  Future<List<modelo.Divida>> todas() async =>
      (await _banco.select(_banco.dividas).get()).map(_paraModelo).toList();

  @override
  Future<List<modelo.Divida>> emAberto() async {
    final linhas = await (_banco.select(_banco.dividas)
          ..where((t) => t.quitadaEm.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.diaVencimento)]))
        .get();
    return linhas.map(_paraModelo).toList();
  }

  @override
  Stream<List<modelo.Divida>> observarEmAberto() => (_banco.select(_banco.dividas)
        ..where((t) => t.quitadaEm.isNull())
        ..orderBy([(t) => OrderingTerm(expression: t.diaVencimento)]))
      .watch()
      .map((linhas) => linhas.map(_paraModelo).toList());

  @override
  Future<void> salvar(modelo.Divida d) => _banco.into(_banco.dividas).insertOnConflictUpdate(
        DividasCompanion.insert(
          id: d.id,
          nome: d.nome,
          saldoCentavos: Value(Dinheiro.paraCentavos(d.saldoAtual)),
          parcelaCentavos: Value(Dinheiro.paraCentavos(d.valorParcela)),
          diaVencimento: Value(d.diaVencimento),
          parcelasRestantes: Value(d.parcelasRestantes),
          parcelasTotal: Value(d.parcelasTotal),
          quitadaEm: Value(d.quitadaEm),
          cartaoId: Value(d.cartaoId),
        ),
      );

  @override
  Future<void> remover(String id) =>
      (_banco.delete(_banco.dividas)..where((t) => t.id.equals(id))).go();

  @override
  Future<modelo.Divida?> quitarParcela(String id, {DateTime? em}) async {
    // Transação porque são duas decisões ligadas: baixar a parcela e, se
    // era a última, encerrar a dívida. Meio caminho deixaria uma dívida com
    // zero parcelas ainda aparecendo como aberta.
    return _banco.transaction(() async {
      final linha = await (_banco.select(_banco.dividas)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

      if (linha == null) return null;

      // Já quitada ou sem parcela: não faz nada. Toque duplo no botão não
      // pode zerar duas parcelas.
      if (linha.quitadaEm != null || linha.parcelasRestantes < 1) {
        return _paraModelo(linha);
      }

      final restantes = linha.parcelasRestantes - 1;
      final saldo = linha.saldoCentavos - linha.parcelaCentavos;

      await (_banco.update(_banco.dividas)..where((t) => t.id.equals(id))).write(
        DividasCompanion(
          parcelasRestantes: Value(restantes),
          // Saldo não fica negativo: a última parcela costuma ser diferente
          // dos centavos e deixaria "-R$ 0,03" na tela.
          saldoCentavos: Value(saldo < 0 ? 0 : saldo),
          quitadaEm: Value(restantes == 0 ? (em ?? DateTime.now()) : null),
        ),
      );

      final atualizada = await (_banco.select(_banco.dividas)
            ..where((t) => t.id.equals(id)))
          .getSingle();

      return _paraModelo(atualizada);
    });
  }

  modelo.Divida _paraModelo(Divida linha) => modelo.Divida(
        id: linha.id,
        nome: linha.nome,
        saldoAtual: Dinheiro.paraReais(linha.saldoCentavos),
        valorParcela: Dinheiro.paraReais(linha.parcelaCentavos),
        diaVencimento: linha.diaVencimento,
        parcelasRestantes: linha.parcelasRestantes,
        parcelasTotal: linha.parcelasTotal,
        quitadaEm: linha.quitadaEm,
        cartaoId: linha.cartaoId,
      );
}
