/// Uma conta que sai todo mês: aluguel, luz, consórcio, escola.
///
/// Era um número só, digitado de cabeça. Agora cada linha tem nome, valor
/// e dia, e o total é a **soma do que a pessoa cadastrou** — o app
/// pergunta, a pessoa responde.
class ContaFixa {
  const ContaFixa({
    required this.id,
    required this.nome,
    required this.valor,
    required this.dia,
    this.ativa = true,
  });

  final String id;
  final String nome;
  final double valor;

  /// O dia do mês em que sai.
  final int dia;

  /// Desligada continua cadastrada, mas não entra na soma. Apagar
  /// obrigaria a digitar tudo de novo no mês em que ela voltar.
  final bool ativa;

  ContaFixa copyWith({String? nome, double? valor, int? dia, bool? ativa}) =>
      ContaFixa(
        id: id,
        nome: nome ?? this.nome,
        valor: valor ?? this.valor,
        dia: dia ?? this.dia,
        ativa: ativa ?? this.ativa,
      );

  /// As sugestões comuns da tela #06 — **atalho, não catálogo**.
  ///
  /// Quem tem consórcio, pensão ou mensalidade de escola não pode ficar de
  /// fora: a tela mostra estas e mantém "+ adicionar conta" sempre visível.
  static const sugestoes = [
    'aluguel',
    'luz',
    'água',
    'internet',
    'telefone',
  ];
}
