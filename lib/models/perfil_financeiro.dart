/// As respostas do onboarding.
///
/// [origem] diz se os números vieram de chute ou de extrato — muda a
/// confiança que o app pode ter neles.
enum OrigemPerfil { feeling, ofx }

class PerfilFinanceiro {
  const PerfilFinanceiro({
    this.rendaMensal,
    this.diaRenda,
    this.gastoDiarioEstimado,
    this.contasFixasEstimadas,
    this.origem = OrigemPerfil.feeling,
  });

  final double? rendaMensal;
  final int? diaRenda;
  final double? gastoDiarioEstimado;
  final double? contasFixasEstimadas;
  final OrigemPerfil origem;

  bool get veioDeExtrato => origem == OrigemPerfil.ofx;

  PerfilFinanceiro copyWith({
    double? rendaMensal,
    int? diaRenda,
    double? gastoDiarioEstimado,
    double? contasFixasEstimadas,
    OrigemPerfil? origem,
  }) =>
      PerfilFinanceiro(
        rendaMensal: rendaMensal ?? this.rendaMensal,
        diaRenda: diaRenda ?? this.diaRenda,
        gastoDiarioEstimado: gastoDiarioEstimado ?? this.gastoDiarioEstimado,
        contasFixasEstimadas: contasFixasEstimadas ?? this.contasFixasEstimadas,
        origem: origem ?? this.origem,
      );
}
