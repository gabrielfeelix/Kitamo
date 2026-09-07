import '../../models/divida.dart';
import '../../models/perfil_financeiro.dart';
import '../../services/diario_service.dart';
import '../../widgets/moeda.dart';

/// Uma pergunta que a Kitamo sabe responder.
class Pergunta {
  const Pergunta(this.texto, this.chave);
  final String texto;
  final String chave;
}

/// As respostas do chat.
///
/// **Determinístico, sem LLM.** Não é limitação de orçamento: as perguntas
/// que importam num app de dívida são sobre os números da própria pessoa, e
/// para essas um cálculo exato é melhor que um modelo que pode errar. Um
/// chat que erra o valor da parcela é pior que não ter chat.
class Respostas {
  const Respostas();

  static const sugestoes = [
    Pergunta('quanto falta pra quitar?', 'falta'),
    Pergunta('por que meu diário é esse?', 'diario'),
    Pergunta('dá pra antecipar?', 'antecipar'),
    Pergunta('qual a próxima parcela?', 'proxima'),
  ];

  String responder(
    String chave, {
    required PerfilFinanceiro? perfil,
    required List<Divida> dividas,
  }) {
    final abertas = dividas.where((d) => !d.estaQuitada).toList();
    final r = const DiarioService().calcular(perfil: perfil, dividas: abertas);

    return switch (chave) {
      'falta' => _falta(abertas, r),
      'diario' => _diario(r),
      'antecipar' => _antecipar(abertas, r),
      'proxima' => _proxima(abertas),
      _ => 'ainda não sei responder isso. Mas sei falar do seu diário, '
          'das suas parcelas e de quanto falta pra quitar.',
    };
  }

  String _falta(List<Divida> abertas, ResultadoDiario r) {
    if (abertas.isEmpty) return 'nada. Você não tem dívida cadastrada.';

    final parcelas = abertas.fold<int>(0, (s, d) => s + d.parcelasRestantes);
    final total = abertas.fold<double>(0, (s, d) => s + d.saldoAtual);

    final quando = r.quitacaoLabel == null
        ? ''
        : ' A última cai em ${r.quitacaoLabel}.';

    return 'faltam $parcelas ${parcelas == 1 ? 'parcela' : 'parcelas'}, '
        '${dinheiro(total)} no total.$quando';
  }

  String _diario(ResultadoDiario r) {
    if (!r.fecha) {
      return 'esse mês a conta não fecha: faltam '
          '${dinheiro(r.faltaPorMes)}. Suas parcelas somam '
          '${dinheiro(r.parcelasDoMes)} e as contas fixas '
          '${dinheiro(r.contasFixas)}.';
    }

    return 'você tem ${dinheiro(r.sobraMensal)} de sobra no mês, dividido '
        'por ${r.diasNoMes} dias. Dá ${dinheiro(r.diario)} por dia.';
  }

  String _antecipar(List<Divida> abertas, ResultadoDiario r) {
    if (abertas.isEmpty) return 'não tem o que antecipar. Você está livre.';

    if (!r.fecha) {
      return 'esse mês está apertado, então antecipar não é hora. '
          'Quando sobrar, cada parcela adiantada puxa sua quitação pra mais '
          'perto.';
    }

    final menor = abertas.reduce(
        (a, b) => a.valorParcela <= b.valorParcela ? a : b);

    return 'sobra ${dinheiro(r.sobraMensal)} no mês. A menor parcela é a do '
        '${menor.nome}, ${dinheiro(menor.valorParcela)}. se der pra pagar '
        'uma a mais, sua quitação anda um mês.';
  }

  String _proxima(List<Divida> abertas) {
    if (abertas.isEmpty) return 'não tem parcela pra vencer.';

    final proxima = abertas.reduce(
        (a, b) => a.diaVencimento <= b.diaVencimento ? a : b);

    return 'a do ${proxima.nome}, ${dinheiro(proxima.valorParcela)}, '
        'vence dia ${proxima.diaVencimento}.';
  }
}
