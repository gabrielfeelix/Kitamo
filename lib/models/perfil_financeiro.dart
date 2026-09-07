/// As respostas do onboarding.
///
/// [origem] diz se os números vieram de chute ou de extrato — muda a
/// confiança que o app pode ter neles.
enum OrigemPerfil { feeling, ofx }

class PerfilFinanceiro {
  const PerfilFinanceiro({
    this.nome,
    this.rendaMensal,
    this.diaRenda,
    this.gastoDiarioEstimado,
    this.contasFixasEstimadas,
    this.origem = OrigemPerfil.feeling,
  });

  /// Como a pessoa quer ser chamada. O design abre o Início com
  /// "bom dia, Gabriel" — sem isso o cabeçalho fica sem dono.
  /// Nulo é aceito: aí o app só diz "bom dia".
  final String? nome;

  final double? rendaMensal;
  final int? diaRenda;
  final double? gastoDiarioEstimado;
  final double? contasFixasEstimadas;
  final OrigemPerfil origem;

  bool get veioDeExtrato => origem == OrigemPerfil.ofx;

  PerfilFinanceiro copyWith({
    String? nome,
    double? rendaMensal,
    int? diaRenda,
    double? gastoDiarioEstimado,
    double? contasFixasEstimadas,
    OrigemPerfil? origem,
  }) =>
      PerfilFinanceiro(
        nome: nome ?? this.nome,
        rendaMensal: rendaMensal ?? this.rendaMensal,
        diaRenda: diaRenda ?? this.diaRenda,
        gastoDiarioEstimado: gastoDiarioEstimado ?? this.gastoDiarioEstimado,
        contasFixasEstimadas: contasFixasEstimadas ?? this.contasFixasEstimadas,
        origem: origem ?? this.origem,
      );
}
