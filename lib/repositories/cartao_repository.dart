import 'package:drift/drift.dart';

import '../data/banco.dart';
import '../models/cartao.dart' as modelo;
import '../models/divida.dart' as modelo;
import 'dinheiro.dart';

/// Acesso aos cartões e ao que mora dentro deles.
abstract interface class CartaoRepository {
  /// Os cartões com as compras já dentro.
  Future<List<modelo.Cartao>> todos();
  Stream<List<modelo.Cartao>> observar();
  Future<void> salvar(modelo.Cartao cartao);

  /// Apaga o cartão e solta as compras que estavam dentro.
  ///
  /// As compras **não** são apagadas junto: a dívida continua existindo na
  /// vida real, e sumir com ela seria mentir o valor que falta.
  Future<void> remover(String id);

  /// Baixa uma parcela de **cada** compra em aberto do cartão. É o
  /// "paguei a fatura": uma fatura paga = um toque.
  ///
  /// Devolve o cartão atualizado, ou null se ele não existe.
  Future<modelo.Cartao?> quitarFatura(String cartaoId, {DateTime? em});
}

class CartaoRepositoryDrift implements CartaoRepository {
  CartaoRepositoryDrift(this._banco);

  final Banco _banco;

  @override
  Future<List<modelo.Cartao>> todos() async {
    final linhas = await (_banco.select(_banco.cartoes)
          ..orderBy([(t) => OrderingTerm(expression: t.diaVencimento)]))
        .get();
    final compras = await _banco.select(_banco.dividas).get();
    return linhas.map((c) => _montar(c, compras)).toList();
  }

  /// A tela precisa ver as duas coisas ao mesmo tempo: baixar uma parcela
  /// muda a fatura do cartão que a contém. Uma consulta só, com join, em
  /// vez de duas correntes que chegariam fora de hora.
  @override
  Stream<List<modelo.Cartao>> observar() {
    final consulta = _banco.select(_banco.cartoes).join([
      leftOuterJoin(
        _banco.dividas,
        _banco.dividas.cartaoId.equalsExp(_banco.cartoes.id),
      ),
    ])
      ..orderBy([OrderingTerm(expression: _banco.cartoes.diaVencimento)]);

    return consulta.watch().map((linhas) {
      final compras = linhas
          .map((l) => l.readTableOrNull(_banco.dividas))
          .whereType<Divida>()
          .toList();

      final cartoes = <String, Cartoe>{};
      for (final l in linhas) {
        final c = l.readTable(_banco.cartoes);
        cartoes[c.id] = c;
      }

      return cartoes.values.map((c) => _montar(c, compras)).toList();
    });
  }

  @override
  Future<void> salvar(modelo.Cartao c) =>
      _banco.into(_banco.cartoes).insertOnConflictUpdate(
            CartoesCompanion.insert(
              id: c.id,
              nome: c.nome,
              diaVencimento: Value(c.diaVencimento),
            ),
          );

  @override
  Future<void> remover(String id) => _banco.transaction(() async {
        // Solta as compras antes de apagar a caixa: elas continuam sendo
        // dívida, só deixam de estar num cartão.
        await (_banco.update(_banco.dividas)
              ..where((t) => t.cartaoId.equals(id)))
            .write(const DividasCompanion(cartaoId: Value(null)));
        await (_banco.delete(_banco.cartoes)..where((t) => t.id.equals(id)))
            .go();
      });

  @override
  Future<modelo.Cartao?> quitarFatura(String cartaoId, {DateTime? em}) {
    // Transação porque são N decisões ligadas: baixar a parcela de cada
    // compra e encerrar as que acabaram. Meio caminho deixaria a fatura
    // paga pela metade, e a pessoa não tem como saber quais baixaram.
    return _banco.transaction(() async {
      final cartao = await (_banco.select(_banco.cartoes)
            ..where((t) => t.id.equals(cartaoId)))
          .getSingleOrNull();

      if (cartao == null) return null;

      final compras = await (_banco.select(_banco.dividas)
            ..where((t) => t.cartaoId.equals(cartaoId)))
          .get();

      final quando = em ?? DateTime.now();

      for (final compra in compras) {
        // Já quitada ou sem parcela: não faz nada. Toque duplo no botão
        // não pode zerar duas parcelas — a mesma regra do quitarParcela.
        if (compra.quitadaEm != null || compra.parcelasRestantes < 1) continue;

        final restantes = compra.parcelasRestantes - 1;
        final saldo = compra.saldoCentavos - compra.parcelaCentavos;

        await (_banco.update(_banco.dividas)
              ..where((t) => t.id.equals(compra.id)))
            .write(DividasCompanion(
          parcelasRestantes: Value(restantes),
          // Saldo não fica negativo: a última parcela costuma diferir nos
          // centavos e deixaria "-R$ 0,03" na tela.
          saldoCentavos: Value(saldo < 0 ? 0 : saldo),
          quitadaEm: Value(restantes == 0 ? quando : null),
        ));
      }

      final atualizadas = await _banco.select(_banco.dividas).get();
      return _montar(cartao, atualizadas);
    });
  }

  modelo.Cartao _montar(Cartoe linha, List<Divida> compras) => modelo.Cartao(
        id: linha.id,
        nome: linha.nome,
        diaVencimento: linha.diaVencimento,
        compras: compras
            .where((d) => d.cartaoId == linha.id)
            .map(_paraDivida)
            .toList(),
      );

  modelo.Divida _paraDivida(Divida l) => modelo.Divida(
        id: l.id,
        nome: l.nome,
        saldoAtual: Dinheiro.paraReais(l.saldoCentavos),
        valorParcela: Dinheiro.paraReais(l.parcelaCentavos),
        diaVencimento: l.diaVencimento,
        parcelasRestantes: l.parcelasRestantes,
        parcelasTotal: l.parcelasTotal,
        quitadaEm: l.quitadaEm,
        cartaoId: l.cartaoId,
      );
}
