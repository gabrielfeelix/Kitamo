import '../../models/divida.dart';

/// O que aconteceu ao marcar uma parcela como paga.
///
/// Guarda o "antes" para a tela poder dizer o que mudou — em especial a
/// data de quitação recuando, que é a melhor notícia que o app tem a dar.
class QuitacaoResultado {
  const QuitacaoResultado({
    required this.divida,
    required this.quitacaoAntes,
    required this.quitacaoDepois,
  });

  final Divida divida;
  final DateTime? quitacaoAntes;
  final DateTime? quitacaoDepois;

  bool get acabou => divida.estaQuitada;

  /// A casa tem 5 fases. Ela cresce conforme as parcelas caem, então a
  /// pessoa vê o progresso sem precisar ler número nenhum.
  int get faseDaCasa {
    if (divida.parcelasTotal <= 0) return 1;
    if (acabou) return 5;

    final progresso = divida.parcelasPagas / divida.parcelasTotal;
    final fase = (progresso * 5).ceil();

    return fase.clamp(1, 4); // a fase 5 é exclusiva de quem terminou
  }

  String get caminhoDaCasa => 'assets/images/casa-$faseDaCasa.png';
}
