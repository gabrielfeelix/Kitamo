import 'divida.dart';

/// Um cartão ou credor, com as compras parceladas dentro.
///
/// A vida real: "devo no Nubank" é uma coisa só, e a fatura chega junta —
/// geladeira, notebook e mercado numa linha só, num dia só. Três cartões
/// viravam três dívidas soltas e não dava pra saber o que tinha dentro de
/// cada fatura.
///
/// Quem está endividado não vai montar planilha: se marcar o que pagou der
/// trabalho, ela para de marcar e o app morre em duas semanas. Por isso
/// **uma fatura paga = um toque**.
class Cartao {
  const Cartao({
    required this.id,
    required this.nome,
    required this.diaVencimento,
    this.compras = const [],
  });

  final String id;
  final String nome;

  /// O dia em que a fatura vence. As compras dentro herdam este dia.
  final int diaVencimento;

  /// As compras parceladas dentro deste cartão.
  final List<Divida> compras;

  /// As que ainda têm parcela a pagar.
  List<Divida> get comprasEmAberto =>
      compras.where((c) => !c.estaQuitada && c.parcelasRestantes > 0).toList();

  /// O valor da fatura deste mês: a soma das parcelas em aberto.
  ///
  /// É o número que a pessoa confere contra a fatura que chegou, então sai
  /// da mesma conta que o diário usa — nunca de um total digitado.
  double get faturaDoMes =>
      comprasEmAberto.fold<double>(0, (soma, c) => soma + c.valorParcela);

  /// Quanto ainda falta no cartão inteiro.
  double get saldoTotal =>
      comprasEmAberto.fold<double>(0, (soma, c) => soma + c.saldoAtual);

  /// Sem compra em aberto, o cartão não pesa no mês e não pede toque.
  bool get temFatura => comprasEmAberto.isNotEmpty;

  Cartao copyWith({String? nome, int? diaVencimento, List<Divida>? compras}) =>
      Cartao(
        id: id,
        nome: nome ?? this.nome,
        diaVencimento: diaVencimento ?? this.diaVencimento,
        compras: compras ?? this.compras,
      );
}
