import '../models/conta_fixa.dart';
import '../models/divida.dart';
import '../models/entrada.dart';
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
    required this.gasto,
    required this.ehPrevisao,
    this.motivo,
  });

  final DateTime data;
  final double saldo;
  final EstadoFinanceiro estado;
  final List<Lancamento> lancamentos;

  /// O que saiu neste dia para o dia a dia.
  ///
  /// Em dia que já passou é **o que ela lançou** — zero se não lançou
  /// nada, porque o app não sabe o que não foi dito. Em dia futuro é o
  /// planejado, e aí [ehPrevisao] é true.
  final double gasto;

  /// true quando o número é palpite, não fato.
  ///
  /// A tela precisa dizer isso. Misturar previsão com o que aconteceu,
  /// sem marcar qual é qual, é o que fazia o saldo parecer real.
  final bool ehPrevisao;

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
  ///
  /// [gastos] é o que a pessoa **lançou**, por dia. É o que separa o que
  /// aconteceu do que a gente supõe:
  ///
  /// - **dia que já passou** usa o gasto lançado. Nada lançado é zero,
  ///   não o diário: o app não sabe o que ela não disse, e supor o pior
  ///   afundava o saldo de quem só não anotou.
  /// - **dia que ainda vem** usa o diário como previsão, e o dia sai
  ///   marcado com `ehPrevisao`.
  ///
  /// Antes o diário era subtraído **todo dia**, inclusive nos que já
  /// passaram sem gasto nenhum. Quem tinha R$ 1.000 por dia de limite via
  /// o saldo cair R$ 1.000 por dia e o mês inteiro no vermelho sem ter
  /// gasto um centavo. O diário é o combinado, não uma cobrança.
  MesProjetado mes({
    required PerfilFinanceiro? perfil,
    required List<Divida> dividas,
    required double saldoInicial,
    Map<int, double> gastos = const {},
    List<Entrada> entradas = const [],
    List<ContaFixa> contasFixas = const [],
    DateTime? referencia,
    DateTime? hoje,
  }) {
    final ref = referencia ?? DateTime.now();
    final agora = hoje ?? DateTime.now();
    final diasNoMes = DateTime(ref.year, ref.month + 1, 0).day;
    final abertas = dividas.where((d) => !d.estaQuitada).toList();

    final diario = perfil?.gastoDiarioEstimado ?? 0;

    var saldo = saldoInicial;
    final dias = <DiaProjetado>[];
    DateTime? primeiroApertado;

    for (var d = 1; d <= diasNoMes; d++) {
      final dia = DateTime(ref.year, ref.month, d);
      final lancamentos =
          _lancamentosDoDia(dia, perfil, abertas, entradas, contasFixas);

      for (final l in lancamentos) {
        saldo += l.entrada ? l.valor : -l.valor;
      }

      // Passado é fato; futuro é palpite. O dia de hoje conta como
      // passado: o que ela já lançou hoje é real, e o que falta do dia
      // ela ainda vai lançar.
      final passou = !dia.isAfter(DateTime(agora.year, agora.month, agora.day));
      final gasto = passou ? (gastos[d] ?? 0) : diario;

      saldo = _duasCasas(saldo - gasto);

      final estado = _estado(saldo);
      if (estado == EstadoFinanceiro.aperto && primeiroApertado == null) {
        primeiroApertado = dia;
      }

      dias.add(DiaProjetado(
        data: dia,
        saldo: saldo,
        estado: estado,
        lancamentos: lancamentos,
        gasto: gasto,
        ehPrevisao: !passou,
        motivo: _motivo(estado, lancamentos, dia, perfil, entradas),
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
    List<Entrada> entradas = const [],
    List<ContaFixa> contasFixas = const [],
    DateTime? referencia,
  }) {
    final ref = referencia ?? DateTime.now();
    final abertas = dividas.where((d) => !d.estaQuitada).toList();

    // No mês fechado o dia não muda o total, só a soma importa. Lista
    // vazia cai no par antigo, como no diário.
    final renda = entradas.isEmpty
        ? (perfil?.rendaMensal ?? 0)
        : entradas.fold<double>(0, (soma, e) => soma + e.valor);

    final fixas = contasFixas.isEmpty
        ? (perfil?.contasFixasEstimadas ?? 0)
        : contasFixas
            .where((c) => c.ativa)
            .fold<double>(0, (soma, c) => soma + c.valor);

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
    List<Entrada> entradas,
    List<ContaFixa> contasFixas,
  ) {
    final itens = <Lancamento>[];

    // Cada dinheiro entra **no seu dia**. Somar tudo num dia só prometia
    // folga em data que ainda não tinha dinheiro na conta — o erro que
    // fazia o diário mentir pra quem recebe partido.
    if (entradas.isNotEmpty) {
      for (final e in entradas.where((e) => _caiNesteDia(e.dia, dia))) {
        itens.add(Lancamento(nome: e.nome, valor: e.valor, entrada: true));
      }
    } else {
      final diaRenda = perfil?.diaRenda;
      if (diaRenda != null && _caiNesteDia(diaRenda, dia)) {
        itens.add(Lancamento(
          nome: 'salário',
          valor: perfil?.rendaMensal ?? 0,
          entrada: true,
        ));
      }
    }

    // A conta fixa também sai no dia dela, pelo mesmo motivo.
    for (final c in contasFixas) {
      if (c.ativa && _caiNesteDia(c.dia, dia)) {
        itens.add(Lancamento(nome: c.nome, valor: c.valor, entrada: false));
      }
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
    List<Entrada> entradas,
  ) {
    if (estado == EstadoFinanceiro.tranquilo) return null;

    final saidas = lancamentos.where((l) => !l.entrada).toList();

    if (saidas.isNotEmpty) {
      final nome = saidas.first.nome;

      // Com várias entradas, o que importa é a **próxima** que ainda vai
      // cair: dizer "antes do salário do dia 5" no dia 12 seria falso pra
      // quem também recebe dia 20.
      final proxima = _proximaEntrada(dia, perfil, entradas);

      // O caso que custou R$ 1.674 em 12 meses: a parcela vence antes de
      // o dinheiro cair.
      if (proxima != null) {
        return 'a $nome cai antes ${proxima.nome == 'salário' ? 'do salário' : 'da entrada'} do dia ${proxima.dia}';
      }
      return 'aqui sai a $nome';
    }

    return estado == EstadoFinanceiro.aperto
        ? 'o saldo fica negativo neste dia'
        : 'o saldo fica baixo neste dia';
  }

  /// A primeira entrada que ainda cai depois deste dia, no mesmo mês.
  Entrada? _proximaEntrada(
    DateTime dia,
    PerfilFinanceiro? perfil,
    List<Entrada> entradas,
  ) {
    final lista = entradas.isNotEmpty
        ? entradas
        : [
            if (perfil?.diaRenda != null)
              Entrada(
                id: 'perfil',
                nome: 'salário',
                valor: perfil?.rendaMensal ?? 0,
                dia: perfil!.diaRenda!,
              ),
          ];

    final adiante = lista.where((e) => e.dia > dia.day).toList()
      ..sort((a, b) => a.dia.compareTo(b.dia));

    return adiante.isEmpty ? null : adiante.first;
  }

  static const _mesesCurtos = [
    'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
    'jul', 'ago', 'set', 'out', 'nov', 'dez',
  ];

  String _rotuloCurto(DateTime d) =>
      '${_mesesCurtos[d.month - 1]}/${d.year.toString().substring(2)}';

  double _duasCasas(double v) => (v * 100).round() / 100;
}
