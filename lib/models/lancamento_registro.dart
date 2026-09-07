/// Um gasto ou entrada que já aconteceu.
///
/// Distinto de `Lancamento` do horizonte, que é **previsto**. Este é fato
/// consumado — o que a pessoa registrou pelo botão `+`.
enum TipoLancamento { gasto, entrada }

class LancamentoRegistro {
  const LancamentoRegistro({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.tipo,
    required this.data,
    this.categoria,
  });

  final String id;
  final String descricao;
  final double valor;
  final TipoLancamento tipo;
  final DateTime data;
  final String? categoria;

  bool get ehEntrada => tipo == TipoLancamento.entrada;

  /// Positivo para entrada, negativo para gasto. Simplifica somar uma
  /// lista misturada sem espalhar `if` por toda parte.
  double get valorComSinal => ehEntrada ? valor : -valor;
}
