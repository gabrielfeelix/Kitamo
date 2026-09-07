/// Uma dívida a quitar.
///
/// A fatura de cartão em aberto é uma dívida como as outras — o que muda é
/// só a origem.
class Divida {
  const Divida({
    required this.id,
    required this.nome,
    required this.saldoAtual,
    required this.valorParcela,
    required this.diaVencimento,
    required this.parcelasRestantes,
    required this.parcelasTotal,
    this.quitadaEm,
    this.cartaoId,
  });

  final String id;
  final String nome;
  final double saldoAtual;
  final double valorParcela;
  final int diaVencimento;
  final int parcelasRestantes;
  final int parcelasTotal;
  final DateTime? quitadaEm;

  /// O cartão em que esta compra está, ou nulo quando a dívida é solta
  /// (empréstimo, crediário, financiamento).
  final String? cartaoId;

  bool get estaQuitada => quitadaEm != null;

  /// Compra dentro de um cartão baixa junto com a fatura, não sozinha.
  bool get moraNumCartao => cartaoId != null;

  /// "7 de 10". Nunca negativo, mesmo com dado inconsistente.
  int get parcelasPagas {
    final pagas = parcelasTotal - parcelasRestantes;
    return pagas < 0 ? 0 : pagas;
  }

  /// O vencimento dentro de um mês, respeitando meses curtos: dia 31 em
  /// fevereiro vira 28 (ou 29).
  ///
  /// Sem isso a parcela sumiria da projeção justo no mês mais curto, e o
  /// app mostraria um mês folgado que não existe.
  DateTime vencimentoNoMes(int ano, int mes) {
    final ultimoDia = DateTime(ano, mes + 1, 0).day;
    return DateTime(ano, mes, diaVencimento < ultimoDia ? diaVencimento : ultimoDia);
  }

  /// Data prevista da última parcela — o "pra quitar até janeiro".
  DateTime? previsaoQuitacao([DateTime? apartirDe]) {
    if (parcelasRestantes < 1) return null;

    final base = apartirDe ?? DateTime.now();
    final hoje = DateTime(base.year, base.month, base.day);

    var primeira = vencimentoNoMes(hoje.year, hoje.month);
    if (primeira.isBefore(hoje)) {
      final prox = DateTime(hoje.year, hoje.month + 1, 1);
      primeira = vencimentoNoMes(prox.year, prox.month);
    }

    final ultima = DateTime(primeira.year, primeira.month + parcelasRestantes - 1, 1);
    return vencimentoNoMes(ultima.year, ultima.month);
  }

  Divida copyWith({
    int? parcelasRestantes,
    double? saldoAtual,
    DateTime? quitadaEm,
    String? cartaoId,
  }) =>
      Divida(
        id: id,
        nome: nome,
        saldoAtual: saldoAtual ?? this.saldoAtual,
        valorParcela: valorParcela,
        diaVencimento: diaVencimento,
        parcelasRestantes: parcelasRestantes ?? this.parcelasRestantes,
        parcelasTotal: parcelasTotal,
        quitadaEm: quitadaEm ?? this.quitadaEm,
        cartaoId: cartaoId ?? this.cartaoId,
      );
}
