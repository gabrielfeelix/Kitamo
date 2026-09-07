import '../models/lancamento_registro.dart';

/// Como está o dia de hoje: o que podia gastar contra o que já gastou.
///
/// É a diferença entre o app prever e o app **acompanhar**. O design mostra
/// "você passou R$ 14,56 do dia" — sem comparar o real com o planejado,
/// isso não existe.
class DiaDeHoje {
  const DiaDeHoje({
    required this.podeGastar,
    required this.jaGastou,
  });

  final double podeGastar;
  final double jaGastou;

  double get sobra => podeGastar - jaGastou;

  bool get passou => jaGastou > podeGastar;

  /// Quanto passou do limite. Zero quando ainda está dentro.
  double get quantoPassou => passou ? jaGastou - podeGastar : 0;

  /// De 0 a 1, para a barra. Passa de 1 quando estourou — a barra deve
  /// tratar o excesso, não esconder.
  double get proporcao {
    if (podeGastar <= 0) return jaGastou > 0 ? 1 : 0;
    return jaGastou / podeGastar;
  }

  static DiaDeHoje calcular({
    required double diario,
    required List<LancamentoRegistro> lancamentos,
    DateTime? hoje,
  }) {
    final dia = hoje ?? DateTime.now();

    final gasto = lancamentos
        .where((l) =>
            !l.ehEntrada &&
            l.data.year == dia.year &&
            l.data.month == dia.month &&
            l.data.day == dia.day)
        .fold<double>(0, (soma, l) => soma + l.valor);

    return DiaDeHoje(
      podeGastar: diario,
      jaGastou: (gasto * 100).round() / 100,
    );
  }
}
