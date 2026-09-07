/// Um dinheiro que entra no mês, com o dia em que entra.
///
/// A lista substitui o par `rendaMensal` + `diaRenda`, que só cabia um
/// valor num dia só. Quem recebe R$ 600 dia 5 e R$ 400 dia 20 não
/// conseguia dizer isso, e o app prometia folga em dia sem dinheiro na
/// conta.
class Entrada {
  const Entrada({
    required this.id,
    required this.nome,
    required this.valor,
    required this.dia,
  });

  final String id;

  /// "salário", "bico", "pensão" — o nome que a pessoa deu.
  final String nome;

  final double valor;

  /// O dia do mês em que cai.
  final int dia;

  Entrada copyWith({String? nome, double? valor, int? dia}) => Entrada(
        id: id,
        nome: nome ?? this.nome,
        valor: valor ?? this.valor,
        dia: dia ?? this.dia,
      );
}
