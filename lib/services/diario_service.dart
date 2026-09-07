import '../models/divida.dart';
import '../models/perfil_financeiro.dart';

/// O resultado do cálculo do diário.
class ResultadoDiario {
  const ResultadoDiario({
    required this.diario,
    required this.sobraMensal,
    required this.parcelasDoMes,
    required this.contasFixas,
    required this.diasNoMes,
    required this.fecha,
    required this.faltaPorMes,
    required this.temDividas,
    this.quitacaoEm,
    this.quitacaoLabel,
  });

  final double diario;
  final double sobraMensal;
  final double parcelasDoMes;
  final double contasFixas;
  final int diasNoMes;

  /// false quando a sobra é zero ou negativa.
  final bool fecha;

  /// Quanto falta por mês para a conta fechar. Zero quando fecha.
  final double faltaPorMes;

  final bool temDividas;
  final DateTime? quitacaoEm;
  final String? quitacaoLabel;
}

/// O número da tela inicial: "pra quitar até janeiro, seu diário é R$ 23".
///
/// Determinístico, sem IA:
///   renda − fixas − parcelas = sobra
///   sobra ÷ dias do mês = diário
///
/// A regra que não pode ser quebrada: **sobra negativa não vira diário
/// R$ 0**. Mostrar zero fingiria que dá pra viver sem gastar nada, e quem
/// está endividado já sabe que não dá. O app diz quanto falta.
class DiarioService {
  const DiarioService();

  ResultadoDiario calcular({
    required PerfilFinanceiro? perfil,
    required List<Divida> dividas,
    DateTime? referencia,
  }) {
    final hoje = referencia ?? DateTime.now();
    final emAberto = dividas.where((d) => !d.estaQuitada).toList();

    final renda = perfil?.rendaMensal ?? 0;
    final fixas = perfil?.contasFixasEstimadas ?? 0;

    // Dívida sem parcela restante não pesa no diário.
    final parcelas = emAberto
        .where((d) => d.parcelasRestantes > 0)
        .fold<double>(0, (soma, d) => soma + d.valorParcela);

    final sobra = _duasCasas(renda - fixas - parcelas);
    final diasNoMes = DateTime(hoje.year, hoje.month + 1, 0).day;

    // Zero é o limite: não sobrou nada para o dia a dia, então não fecha.
    final fecha = sobra > 0;

    final quitacao = _previsaoQuitacao(emAberto, hoje);

    return ResultadoDiario(
      diario: fecha ? _duasCasas(sobra / diasNoMes) : 0,
      sobraMensal: sobra,
      parcelasDoMes: _duasCasas(parcelas),
      contasFixas: _duasCasas(fixas),
      diasNoMes: diasNoMes,
      fecha: fecha,
      faltaPorMes: fecha ? 0 : _duasCasas(sobra.abs()),
      temDividas: emAberto.isNotEmpty,
      quitacaoEm: quitacao,
      quitacaoLabel: quitacao == null ? null : _rotularMes(quitacao),
    );
  }

  /// A data de quitação é a **mais tardia** entre as dívidas: o app só
  /// promete "livre" quando a última parcela cair.
  DateTime? _previsaoQuitacao(List<Divida> dividas, DateTime hoje) {
    final datas = dividas
        .map((d) => d.previsaoQuitacao(hoje))
        .whereType<DateTime>()
        .toList();

    if (datas.isEmpty) return null;

    datas.sort();
    return datas.last;
  }

  static const _meses = [
    'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
    'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
  ];

  String _rotularMes(DateTime data) {
    final nome = _meses[data.month - 1];
    return data.year > DateTime.now().year + 1
        ? '$nome de ${data.year}'
        : nome;
  }

  double _duasCasas(double v) => (v * 100).round() / 100;
}
