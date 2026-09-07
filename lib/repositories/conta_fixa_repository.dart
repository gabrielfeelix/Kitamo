import 'package:drift/drift.dart';

import '../data/banco.dart';
import '../models/conta_fixa.dart' as modelo;
import 'dinheiro.dart';

/// Acesso às contas que saem todo mês.
abstract interface class ContaFixaRepository {
  Future<List<modelo.ContaFixa>> todas();
  Stream<List<modelo.ContaFixa>> observar();
  Future<void> salvar(modelo.ContaFixa conta);
  Future<void> remover(String id);
}

class ContaFixaRepositoryDrift implements ContaFixaRepository {
  ContaFixaRepositoryDrift(this._banco);

  final Banco _banco;

  SimpleSelectStatement<$ContasFixasTable, ContasFixa> get _consulta =>
      _banco.select(_banco.contasFixas)
        ..orderBy([(t) => OrderingTerm(expression: t.dia)]);

  @override
  Future<List<modelo.ContaFixa>> todas() async =>
      (await _consulta.get()).map(_paraModelo).toList();

  @override
  Stream<List<modelo.ContaFixa>> observar() =>
      _consulta.watch().map((l) => l.map(_paraModelo).toList());

  @override
  Future<void> salvar(modelo.ContaFixa c) =>
      _banco.into(_banco.contasFixas).insertOnConflictUpdate(
            ContasFixasCompanion.insert(
              id: c.id,
              nome: c.nome,
              valorCentavos: Dinheiro.paraCentavos(c.valor),
              dia: Value(c.dia),
              ativa: Value(c.ativa),
            ),
          );

  @override
  Future<void> remover(String id) =>
      (_banco.delete(_banco.contasFixas)..where((t) => t.id.equals(id))).go();

  modelo.ContaFixa _paraModelo(ContasFixa l) => modelo.ContaFixa(
        id: l.id,
        nome: l.nome,
        valor: Dinheiro.paraReais(l.valorCentavos),
        dia: l.dia,
        ativa: l.ativa,
      );
}
