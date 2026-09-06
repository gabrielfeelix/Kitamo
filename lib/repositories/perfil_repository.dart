import 'package:drift/drift.dart';

import '../data/banco.dart';
import '../models/perfil_financeiro.dart';
import 'dinheiro.dart';

/// Acesso ao perfil financeiro — as respostas do onboarding.
abstract interface class PerfilRepository {
  Future<PerfilFinanceiro?> carregar();
  Stream<PerfilFinanceiro?> observar();
  Future<void> salvar(PerfilFinanceiro perfil);

  /// true quando o onboarding ainda não foi respondido.
  Future<bool> precisaOnboarding();
}

class PerfilRepositoryDrift implements PerfilRepository {
  PerfilRepositoryDrift(this._banco);

  final Banco _banco;

  /// O perfil é linha única: id fixo em 1.
  static const _id = 1;

  @override
  Future<PerfilFinanceiro?> carregar() async {
    final linha = await (_banco.select(_banco.perfis)
          ..where((t) => t.id.equals(_id)))
        .getSingleOrNull();
    return linha == null ? null : _paraModelo(linha);
  }

  @override
  Stream<PerfilFinanceiro?> observar() => (_banco.select(_banco.perfis)
        ..where((t) => t.id.equals(_id)))
      .watchSingleOrNull()
      .map((linha) => linha == null ? null : _paraModelo(linha));

  @override
  Future<void> salvar(PerfilFinanceiro p) =>
      _banco.into(_banco.perfis).insertOnConflictUpdate(
            PerfisCompanion.insert(
              id: const Value(_id),
              rendaCentavos: Value(Dinheiro.paraCentavosNulo(p.rendaMensal)),
              diaRenda: Value(p.diaRenda),
              gastoDiarioCentavos:
                  Value(Dinheiro.paraCentavosNulo(p.gastoDiarioEstimado)),
              contasFixasCentavos:
                  Value(Dinheiro.paraCentavosNulo(p.contasFixasEstimadas)),
              origem: Value(p.origem.name),
              atualizadoEm: Value(DateTime.now()),
            ),
          );

  @override
  Future<bool> precisaOnboarding() async => (await carregar()) == null;

  PerfilFinanceiro _paraModelo(Perfi linha) => PerfilFinanceiro(
        rendaMensal: Dinheiro.paraReaisNulo(linha.rendaCentavos),
        diaRenda: linha.diaRenda,
        gastoDiarioEstimado: Dinheiro.paraReaisNulo(linha.gastoDiarioCentavos),
        contasFixasEstimadas: Dinheiro.paraReaisNulo(linha.contasFixasCentavos),
        origem: OrigemPerfil.values.firstWhere(
          (o) => o.name == linha.origem,
          orElse: () => OrigemPerfil.feeling,
        ),
      );
}
