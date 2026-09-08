import 'package:drift/drift.dart';

import '../data/banco.dart';
import '../models/lancamento_registro.dart';
import 'dinheiro.dart';

/// Filtro da lista de lançamentos — os chips do topo.
enum FiltroLancamento { todos, entradas, saidas }

abstract interface class LancamentoRepository {
  Future<List<LancamentoRegistro>> listar({FiltroLancamento filtro});
  Stream<List<LancamentoRegistro>> observar({FiltroLancamento filtro});
  Future<void> salvar(LancamentoRegistro lancamento);
  Future<void> remover(String id);

  /// Quanto foi gasto num mês. Alimenta o "você passou R$ X do dia".
  Future<double> totalGastoNoMes(DateTime mes);
}

class LancamentoRepositoryDrift implements LancamentoRepository {
  LancamentoRepositoryDrift(this._banco);

  final Banco _banco;

  SimpleSelectStatement<$LancamentosTable, Lancamento> _consulta(
    FiltroLancamento filtro,
  ) {
    final q = _banco.select(_banco.lancamentos)
      ..orderBy([
        (t) => OrderingTerm(expression: t.data, mode: OrderingMode.desc),
      ]);

    switch (filtro) {
      case FiltroLancamento.entradas:
        q.where((t) => t.tipo.equals(TipoLancamento.entrada.name));
      case FiltroLancamento.saidas:
        q.where((t) => t.tipo.equals(TipoLancamento.gasto.name));
      case FiltroLancamento.todos:
        break;
    }

    return q;
  }

  @override
  Future<List<LancamentoRegistro>> listar({
    FiltroLancamento filtro = FiltroLancamento.todos,
  }) async =>
      (await _consulta(filtro).get()).map(_paraModelo).toList();

  @override
  Stream<List<LancamentoRegistro>> observar({
    FiltroLancamento filtro = FiltroLancamento.todos,
  }) =>
      _consulta(filtro).watch().map((l) => l.map(_paraModelo).toList());

  @override
  Future<void> salvar(LancamentoRegistro l) =>
      _banco.into(_banco.lancamentos).insertOnConflictUpdate(
            LancamentosCompanion.insert(
              id: l.id,
              descricao: l.descricao,
              valorCentavos: Dinheiro.paraCentavos(l.valor),
              tipo: l.tipo.name,
              data: l.data,
              categoria: Value(l.categoria),
            ),
          );

  @override
  Future<void> remover(String id) =>
      (_banco.delete(_banco.lancamentos)..where((t) => t.id.equals(id))).go();

  @override
  Future<double> totalGastoNoMes(DateTime mes) async {
    final inicio = DateTime(mes.year, mes.month, 1);
    // Primeiro instante do mês seguinte: evita perder lançamentos do
    // último dia por causa de hora.
    final fim = DateTime(mes.year, mes.month + 1, 1);

    final linhas = await (_banco.select(_banco.lancamentos)
          ..where((t) =>
              t.tipo.equals(TipoLancamento.gasto.name) &
              t.data.isBiggerOrEqualValue(inicio) &
              t.data.isSmallerThanValue(fim)))
        .get();

    final centavos = linhas.fold<int>(0, (s, l) => s + l.valorCentavos);
    return Dinheiro.paraReais(centavos);
  }

  LancamentoRegistro _paraModelo(Lancamento l) => LancamentoRegistro(
        id: l.id,
        descricao: l.descricao,
        valor: Dinheiro.paraReais(l.valorCentavos),
        tipo: TipoLancamento.values.firstWhere(
          (t) => t.name == l.tipo,
          orElse: () => TipoLancamento.gasto,
        ),
        data: l.data,
        categoria: l.categoria,
      );
}
