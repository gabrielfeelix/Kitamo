import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../design/tipografia.dart';
import '../../models/conta_fixa.dart';
import '../../models/divida.dart';
import '../../models/entrada.dart';
import '../../models/lancamento_registro.dart';
import '../../models/perfil_financeiro.dart';
import '../../services/horizonte_service.dart';
import '../../widgets/moeda.dart';
import '../../widgets/segmentado.dart';
import 'aba_ano.dart';
import 'aba_dias.dart';
import 'aba_meses.dart';

/// O horizonte inteiro numa tela só: **dias | meses | ano**.
///
/// Antes eram duas telas soltas, alcançadas por toques que ninguém
/// adivinhava — o mensal abria tocando no cartão da casa, e nada no cartão
/// avisava. O design sempre foi uma tela só: as três abas repetem o mesmo
/// segmentado no topo (#09, #10 e #11).
class HorizontePage extends StatefulWidget {
  const HorizontePage({
    super.key,
    required this.perfil,
    required this.dividas,
    this.entradas = const [],
    this.contasFixas = const [],
    this.lancamentos = const [],
    this.abaInicial = AbaDoHorizonte.dias,
    this.referencia,
  });

  final PerfilFinanceiro? perfil;
  final List<Divida> dividas;
  final List<Entrada> entradas;
  final List<ContaFixa> contasFixas;

  /// O que ela já gastou, para a coluna GASTOU da aba "dias".
  final List<LancamentoRegistro> lancamentos;

  final AbaDoHorizonte abaInicial;

  /// Só para teste: fixa o mês de referência.
  final DateTime? referencia;

  @override
  State<HorizontePage> createState() => _HorizontePageState();
}

enum AbaDoHorizonte { dias, meses, ano }

class _HorizontePageState extends State<HorizontePage> {
  late AbaDoHorizonte _aba = widget.abaInicial;

  /// Quantos meses andou a partir do mês de referência. A aba "dias" tem
  /// setas de mês no cabeçalho.
  int _deslocamento = 0;

  static const _servico = HorizonteService();

  DateTime get _base => widget.referencia ?? DateTime.now();

  DateTime get _mesAtual =>
      DateTime(_base.year, _base.month + _deslocamento, 1);

  /// O que ela lançou naquele mês, somado por dia.
  ///
  /// Sem isto o serviço não tem como saber o que aconteceu, e cairia de
  /// volta em supor que ela gastou o diário todo dia.
  Map<int, double> _gastosDe(DateTime quando) {
    final mapa = <int, double>{};
    for (final l in widget.lancamentos) {
      if (l.ehEntrada) continue;
      if (l.data.year != quando.year || l.data.month != quando.month) continue;
      mapa[l.data.day] = (mapa[l.data.day] ?? 0) + l.valor;
    }
    return mapa;
  }

  MesProjetado _mes(DateTime quando, {double saldoInicial = 0}) =>
      _servico.mes(
        perfil: widget.perfil,
        dividas: widget.dividas,
        saldoInicial: saldoInicial,
        gastos: _gastosDe(quando),
        entradas: widget.entradas,
        contasFixas: widget.contasFixas,
        referencia: quando,
      );

  /// Os três meses da aba "meses", **encadeados**: cada um começa onde o
  /// anterior fechou.
  ///
  /// Recomeçar do zero a cada mês faria as três colunas saírem idênticas,
  /// e a tela existe justamente para mostrar o contrário — *"o vermelho
  /// anda pra frente até janeiro, e some"*.
  List<MesProjetado> get _tresMeses {
    final meses = <MesProjetado>[];
    var saldo = 0.0;

    for (var i = 0; i < 3; i++) {
      final mes = _mes(
        DateTime(_base.year, _base.month + i, 1),
        saldoInicial: saldo,
      );
      meses.add(mes);
      saldo = mes.saldoFinal;
    }

    return meses;
  }

  List<MesResumo> get _doze => _servico.doze(
        perfil: widget.perfil,
        dividas: widget.dividas,
        saldoInicial: 0,
        entradas: widget.entradas,
        contasFixas: widget.contasFixas,
        referencia: _base,
      );

  @override
  Widget build(BuildContext context) {
    // A aba "dias" tem cabeçalho verde; as outras duas abrem em creme. É o
    // que o design desenhou, e muda a cor do segmentado junto.
    final emDias = _aba == AbaDoHorizonte.dias;

    return Scaffold(
      backgroundColor: Cores.creme,
      body: Column(
        children: [
          if (emDias)
            _CabecalhoVerde(
              mes: _mesAtual,
              diario: widget.perfil?.gastoDiarioEstimado ?? 0,
              aoVoltar: () => Navigator.of(context).maybePop(),
              aoTrocarMes: (passo) => setState(() => _deslocamento += passo),
              segmentado: _segmentado(sobreAcento: true),
            )
          else
            _CabecalhoClaro(
              titulo: _aba == AbaDoHorizonte.meses
                  ? 'horizonte de saldos'
                  : 'horizonte',
              periodo: _aba == AbaDoHorizonte.meses
                  ? _periodoTresMeses()
                  : _periodoDoze(),
              explicacao: _aba == AbaDoHorizonte.meses
                  ? 'o saldo de cada dia, mês ao lado de mês.'
                  : null,
              aoVoltar: () => Navigator.of(context).maybePop(),
              segmentado: _segmentado(sobreAcento: false),
            ),
          Expanded(child: _corpo()),
        ],
      ),
    );
  }

  Widget _segmentado({required bool sobreAcento}) => Segmentado(
        opcoes: const ['dias', 'meses', 'ano'],
        selecionada: _aba.index,
        sobreAcento: sobreAcento,
        aoTrocar: (i) => setState(() {
          _aba = AbaDoHorizonte.values[i];
          // Trocar de modo volta ao mês de hoje: manter o deslocamento
          // faria "meses" abrir num trecho que ela não pediu.
          _deslocamento = 0;
        }),
      );

  Widget _corpo() => switch (_aba) {
        AbaDoHorizonte.dias => AbaDias(
            mes: _mes(_mesAtual),
            lancamentos: widget.lancamentos,
            diario: widget.perfil?.gastoDiarioEstimado ?? 0,
          ),
        AbaDoHorizonte.meses => AbaMeses(meses: _tresMeses),
        AbaDoHorizonte.ano => AbaAno(meses: _doze),
      };

  String _periodoTresMeses() {
    final fim = DateTime(_base.year, _base.month + 2, 1);
    return '${_curto(_base)} → ${_curto(fim)}';
  }

  String _periodoDoze() {
    final fim = DateTime(_base.year, _base.month + 11, 1);
    return '${_curto(_base)}/${_ano(_base)} → ${_curto(fim)}/${_ano(fim)}';
  }

  static const _mesesCurtos = [
    'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
    'jul', 'ago', 'set', 'out', 'nov', 'dez',
  ];

  static String _curto(DateTime d) => _mesesCurtos[d.month - 1];
  static String _ano(DateTime d) => d.year.toString().substring(2);
}

/// O cabeçalho verde da aba "dias": setas de mês, o diário em Outfit 30 e
/// o segmentado por cima do véu escuro.
class _CabecalhoVerde extends StatelessWidget {
  const _CabecalhoVerde({
    required this.mes,
    required this.diario,
    required this.aoVoltar,
    required this.aoTrocarMes,
    required this.segmentado,
  });

  final DateTime mes;
  final double diario;
  final VoidCallback aoVoltar;
  final ValueChanged<int> aoTrocarMes;
  final Widget segmentado;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Cores.verde,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _BotaoRedondo(
                  icone: Icons.chevron_left,
                  rotulo: 'mês anterior',
                  aoTocar: () => aoTrocarMes(-1),
                ),
                Text(
                  '${_HorizontePageState._curto(mes)}/'
                  '${_HorizontePageState._ano(mes)}',
                  style: Tipo.titulo.copyWith(color: Cores.branco),
                ),
                _BotaoRedondo(
                  icone: Icons.chevron_right,
                  rotulo: 'próximo mês',
                  aoTocar: () => aoTrocarMes(1),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    dinheiro(diario),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: Tipo.outfit,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                      letterSpacing: -30 * 0.025,
                      color: Cores.branco,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // A frase também encolhe: a 320px o número em Outfit 30
                // mais o texto estouravam a linha por 2.3px, e o cabeçalho
                // é justamente onde a pessoa olha primeiro.
                const Flexible(
                  child: Text(
                    'por dia é o combinado',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: Tipo.figtree,
                      fontSize: 13,
                      color: Cores.branco,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            segmentado,
          ],
        ),
      ),
    );
  }
}

/// O cabeçalho creme das abas "meses" e "ano": voltar branco, título em
/// Outfit 19 e o período em DM Mono à direita.
class _CabecalhoClaro extends StatelessWidget {
  const _CabecalhoClaro({
    required this.titulo,
    required this.periodo,
    required this.aoVoltar,
    required this.segmentado,
    this.explicacao,
  });

  final String titulo;
  final String periodo;
  final String? explicacao;
  final VoidCallback aoVoltar;
  final Widget segmentado;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Semantics(
                  button: true,
                  label: 'voltar',
                  child: GestureDetector(
                    onTap: aoVoltar,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Cores.branco,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x1A5C2E1A),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.chevron_left,
                          size: 20, color: Cores.tinta),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(titulo, style: Tipo.titulo)),
                Text(
                  periodo,
                  style: const TextStyle(
                    fontFamily: Tipo.dmMono,
                    fontSize: 11,
                    color: Cores.apoio,
                  ),
                ),
              ],
            ),
            if (explicacao != null) ...[
              const SizedBox(height: 8),
              Text(
                explicacao!,
                style: const TextStyle(
                  fontFamily: Tipo.figtree,
                  fontSize: 13,
                  height: 1.45,
                  color: Color(0xFF4A423C),
                ),
              ),
            ],
            const SizedBox(height: 8),
            segmentado,
          ],
        ),
      ),
    );
  }
}

class _BotaoRedondo extends StatelessWidget {
  const _BotaoRedondo({
    required this.icone,
    required this.rotulo,
    required this.aoTocar,
  });

  final IconData icone;
  final String rotulo;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: rotulo,
      child: GestureDetector(
        onTap: aoTocar,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: Color(0x29000000),
            shape: BoxShape.circle,
          ),
          child: Icon(icone, size: 20, color: Cores.branco),
        ),
      ),
    );
  }
}
