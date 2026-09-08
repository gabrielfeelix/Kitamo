import 'package:drift/drift.dart';

import '../data/banco.dart';
import '../models/entrada.dart' as modelo;
import 'dinheiro.dart';

/// Acesso ao que entra no mês.
abstract interface class EntradaRepository {
  Future<List<modelo.Entrada>> todas();
  Stream<List<modelo.Entrada>> observar();
  Future<void> salvar(modelo.Entrada entrada);
  Future<void> remover(String id);
}

class EntradaRepositoryDrift implements EntradaRepository {
  EntradaRepositoryDrift(this._banco);

  final Banco _banco;

  /// Ordenadas pelo dia: é como a pessoa pensa o mês, do começo ao fim.
  SimpleSelectStatement<$EntradasTable, Entrada> get _consulta =>
      _banco.select(_banco.entradas)
        ..orderBy([(t) => OrderingTerm(expression: t.dia)]);

  @override
  Future<List<modelo.Entrada>> todas() async =>
      (await _consulta.get()).map(_paraModelo).toList();

  @override
  Stream<List<modelo.Entrada>> observar() =>
      _consulta.watch().map((l) => l.map(_paraModelo).toList());

  @override
  Future<void> salvar(modelo.Entrada e) =>
      _banco.into(_banco.entradas).insertOnConflictUpdate(
            EntradasCompanion.insert(
              id: e.id,
              nome: e.nome,
              valorCentavos: Dinheiro.paraCentavos(e.valor),
              dia: e.dia,
            ),
          );

  @override
  Future<void> remover(String id) =>
      (_banco.delete(_banco.entradas)..where((t) => t.id.equals(id))).go();

  modelo.Entrada _paraModelo(Entrada l) => modelo.Entrada(
        id: l.id,
        nome: l.nome,
        valor: Dinheiro.paraReais(l.valorCentavos),
        dia: l.dia,
      );
}
