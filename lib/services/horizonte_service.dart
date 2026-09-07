import '../models/divida.dart';
import '../models/perfil_financeiro.dart';
import '../design/cores.dart';

/// Um lançamento previsto num dia. Tem nome porque a tela fala:
/// "dia 4 · parcela do Nubank", não "4 · R$ 1.534".
class Lancamento {
  const Lancamento({
    required this.nome,
    required this.valor,
    required this.entrada,
  });

  final String nome;
  final double valor;
  final bool entrada;
}

/// Um dia do mês na projeção.
class DiaProjetado {
  const DiaProjetado({
    required this.data,
    required this.saldo,
    required this.estado,
    required this.lancamentos,
    this.motivo,
  });

  final DateTime data;
  final double saldo;
  final EstadoFinanceiro estado;
  final List<Lancamento> lancamentos;

  /// A frase que acompanha a cor. Null em dia tranquilo — vermelho e
  /// amarelo explicam, verde não precisa.
  final String? motivo;

  int get dia => data.day;
}

class MesProjetado {
  const MesProjetado({
    required this.dias,
    required this.saldoFinal,
    this.primeiroDiaApertado,
  });

  final List<DiaProjetado> dias;
  final double saldoFinal;
  final DateTime? primeiroDiaApertado;
}

/// Um mês no horizonte de 12.
class MesResumo {
  const MesResumo({
    required this.mes,
    required this.rotulo,
    required this.saldoFinal,
    required this.estado,
    required this.parcelas,
    required this.ehQuitacao,
  });

  final DateTime mes;
  final String rotulo;
  final double saldoFinal;
  final EstadoFinanceiro estado;
  final double parcelas;

  /// O mês em que a última parcela cai. É o prêmio visual da tela.
  final bool ehQuitacao;

  bool get temDivida => parcelas > 0;
}

/// O horizonte: a planilha do Breno, mas falando.
///
/// Duas diferenças que são o produto, não detalhe:
/// 1. cada linha tem nome
/// 2. toda cor vem com motivo — vermelho sem explicação é só um susto
class HorizonteService {
  const HorizonteService();

  /// Um mês, dia a dia.
  MesProjetado mes({
    required PerfilFinanceiro? perfil,
    required List<Divida> dividas,
    required double saldoInicial,
    DateTime? referencia,
  }) {
    final ref = referencia ?? DateTime.now();
    final diasNoMes = DateTime(ref.year, ref.month + 1, 0).day;
    final abertas = dividas.where((d) => !d.estaQuitada).toList();

    final diario = perfil?.gastoDiarioEstimado ?? 0;

    var saldo = saldoInicial;
    final dias = <DiaProjetado>[];
    DateTime? primeiroApertado;

    for (var d = 1; d <= diasNoMes; d++) {
      final dia = DateTime(ref.year, ref.month, d);
      final lancamentos = _lancamentosDoDia(dia, perfil, abertas);

      for (final l in lancamentos) {
        saldo += l.entrada ? l.valor : -l.valor;
      }

      // O gasto do dia a dia também consome saldo, senão a projeção
      // mostraria um mês folgado que não existe.
      saldo = _duasCasas(saldo - diario);

      final estado = _estado(saldo);
      if (estado == EstadoFinanceiro.aperto && primeiroApertado == null) {
        primeiroApertado = dia;
      }

      dias.add(DiaProjetado(
        data: dia,
        saldo: saldo,
        estado: estado,
        lancamentos: lancamentos,
        motivo: _motivo(estado, lancamentos, dia, perfil),
      ));
    }

    return MesProjetado(
      dias: dias,
      saldoFinal: saldo,
      primeiroDiaApertado: primeiroApertado,
    );
  }

  /// Doze meses em colunas. É onde a pessoa vê a dívida acabando.
  List<MesResumo> doze({
    required PerfilFinanceiro? perfil,
    required List<Divida> dividas,
    required double saldoInicial,
    DateTime? referencia,
  }) {
    final ref = referencia ?? DateTime.now();
    final abertas = dividas.where((d) => !d.estaQuitada).toList();

    final renda = perfil?.rendaMensal ?? 0;
    final fixas = perfil?.contasFixasEstimadas ?? 0;
    final diario = perfil?.gastoDiarioEstimado ?? 0;

    // O mês da última parcela de todas.
    final maiorRestante = abertas.isEmpty
        ? 0
        : abertas.map((d) => d.parcelasRestantes).reduce((a, b) => a > b ? a : b);

    var saldo = saldoInicial;
    final meses = <MesResumo>[];

    for (var i = 0; i < 12; i++) {
      final mesRef = DateTime(ref.year, ref.month + i, 1);
      final diasNoMes = DateTime(mesRef.year, mesRef.month + 1, 0).day;

      // Uma dívida só pesa enquanto tiver parcela naquele mês.
      final parcelas = abertas
          .where((d) => i < d.parcelasRestantes)
          .fold<double>(0, (soma, d) => soma + d.valorParcela);

      saldo = _duasCasas(saldo + renda - fixas - parcelas - (diario * diasNoMes));

      meses.add(MesResumo(
        mes: mesRef,
        rotulo: _rotuloCurto(mesRef),
        saldoFinal: saldo,
        estado: _estado(saldo),
        parcelas: _duasCasas(parcelas),
        ehQuitacao: maiorRestante > 0 && i == maiorRestante - 1,
      ));
    }

    return meses;
  }

  List<Lancamento> _lancamentosDoDia(
    DateTime dia,
    PerfilFinanceiro? perfil,
    List<Divida> dividas,
  ) {
    final itens = <Lancamento>[];

    final diaRenda = perfil?.diaRenda;
    if (diaRenda != null && _caiNesteDia(diaRenda, dia)) {
      itens.add(Lancamento(
        nome: 'salário',
        valor: perfil?.rendaMensal ?? 0,
        entrada: true,
      ));
    }

    for (final d in dividas) {
      if (d.parcelasRestantes > 0 && _caiNesteDia(d.diaVencimento, dia)) {
        itens.add(Lancamento(
          nome: 'parcela do ${d.nome}',
          valor: d.valorParcela,
          entrada: false,
        ));
      }
    }

    return itens;
  }

  /// Um vencimento dia 31 cai no último dia dos meses curtos.
  ///
  /// Sem isto a parcela **some** de fevereiro, e o app mostra um mês
  /// folgado que não existe — bem no mês em que a pessoa mais precisa da
  /// verdade.
  bool _caiNesteDia(int diaAlvo, DateTime dia) {
    final ultimoDia = DateTime(dia.year, dia.month + 1, 0).day;
    return dia.day == (diaAlvo < ultimoDia ? diaAlvo : ultimoDia);
  }

  EstadoFinanceiro _estado(double saldo) {
    if (saldo < 0) return EstadoFinanceiro.aperto;

    // Abaixo de R$ 100 ainda não é vermelho, mas avisar cedo é o ponto do
    // horizonte: dá tempo de agir antes de estourar.
    return saldo < 100 ? EstadoFinanceiro.atencao : EstadoFinanceiro.tranquilo;
  }

  String? _motivo(
    EstadoFinanceiro estado,
    List<Lancamento> lancamentos,
    DateTime dia,
    PerfilFinanceiro? perfil,
  ) {
    if (estado == EstadoFinanceiro.tranquilo) return null;

    final saidas = lancamentos.where((l) => !l.entrada).toList();

    if (saidas.isNotEmpty) {
      final nome = saidas.first.nome;
      final diaRenda = perfil?.diaRenda;

      // O caso que custou R$ 1.674 em 12 meses: a parcela vence antes de
      // a renda cair.
      if (diaRenda != null && dia.day < diaRenda) {
        return 'a $nome cai antes do salário do dia $diaRenda';
      }
      return 'aqui sai a $nome';
    }

    return estado == EstadoFinanceiro.aperto
        ? 'o saldo fica negativo neste dia'
        : 'o saldo fica baixo neste dia';
  }

  static const _mesesCurtos = [
    'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
    'jul', 'ago', 'set', 'out', 'nov', 'dez',
  ];

  String _rotuloCurto(DateTime d) =>
      '${_mesesCurtos[d.month - 1]}/${d.year.toString().substring(2)}';

  double _duasCasas(double v) => (v * 100).round() / 100;
}
