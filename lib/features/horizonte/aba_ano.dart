import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../design/medidas.dart';
import '../../design/tipografia.dart';
import '../../services/horizonte_service.dart';
import '../../widgets/moeda.dart';

/// A aba "ano" (#11): os 12 meses somados num resumo.
///
/// O cartão barro diz quando a última parcela cai — é o prêmio da tela, e
/// o motivo de a pessoa abrir o app. Depois vêm as barras por mês e a
/// legenda de 4 cores.
class AbaAno extends StatelessWidget {
  const AbaAno({super.key, required this.meses});

  final List<MesResumo> meses;

  /// A maior barra define a escala. Sem isso, um mês de saldo alto
  /// achataria todos os outros.
  double get _maior {
    final valores = meses.map((m) => m.saldoFinal.abs());
    return valores.isEmpty ? 1 : valores.reduce((a, b) => a > b ? a : b);
  }

  MesResumo? get _quitacao {
    for (final m in meses) {
      if (m.ehQuitacao) return m;
    }
    return null;
  }

  /// O que sobra por mês depois que a última parcela cair.
  double get _sobraDepois {
    final q = _quitacao;
    if (q == null) return 0;
    final i = meses.indexOf(q);
    return i + 1 < meses.length ? meses[i + 1].saldoFinal : q.saldoFinal;
  }

  static const _porExtenso = [
    'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
    'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
  ];

  @override
  Widget build(BuildContext context) {
    final quitacao = _quitacao;

    return Column(
      children: [
        if (quitacao != null)
          _CartaoDaQuitacao(
            quando: '${_porExtenso[quitacao.mes.month - 1]}/'
                '${quitacao.mes.year.toString().substring(2)}',
            sobraDepois: _sobraDepois,
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(18, 2, 18, Medidas.espaco),
            itemCount: meses.length,
            itemBuilder: (_, i) => _Barra(
              mes: meses[i],
              proporcao: _maior == 0 ? 0 : meses[i].saldoFinal.abs() / _maior,
            ),
          ),
        ),
        const _Legenda(),
      ],
    );
  }
}

class _CartaoDaQuitacao extends StatelessWidget {
  const _CartaoDaQuitacao({required this.quando, required this.sobraDepois});

  final String quando;
  final double sobraDepois;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: Cores.barro,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SUA ÚLTIMA PARCELA CAI EM',
                  style: TextStyle(
                    fontFamily: Tipo.dmMono,
                    fontSize: 10.5,
                    letterSpacing: 10.5 * 0.1,
                    color: Cores.branco,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  quando,
                  style: const TextStyle(
                    fontFamily: Tipo.outfit,
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    letterSpacing: -30 * 0.025,
                    color: Cores.branco,
                  ),
                ),
                if (sobraDepois > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'depois dela sobram ${dinheiro(sobraDepois)} por mês',
                    style: const TextStyle(
                      fontFamily: Tipo.figtree,
                      fontSize: 13,
                      color: Cores.branco,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Image.asset(
            'assets/images/casa-5.png',
            height: 66,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _Barra extends StatelessWidget {
  const _Barra({required this.mes, required this.proporcao});

  final MesResumo mes;
  final double proporcao;

  /// A quarta cor da legenda: o mês em que a dívida acaba é barro, não
  /// verde. É conquista, não só saldo bom.
  Color get _cor => mes.ehQuitacao ? Cores.barro : mes.estado.cor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(
              mes.rotulo.split('/').first,
              style: const TextStyle(
                fontFamily: Tipo.dmMono,
                fontSize: 12,
                color: Color(0xFF4A423C),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: Cores.bege,
                borderRadius: BorderRadius.circular(Medidas.raioPilula),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                // Uma fatia mínima para o mês existir na tela mesmo com
                // saldo perto de zero.
                widthFactor: proporcao.clamp(0.04, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: _cor,
                    borderRadius: BorderRadius.circular(Medidas.raioPilula),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 86,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                dinheiro(mes.saldoFinal),
                style: TextStyle(
                  fontFamily: Tipo.figtree,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: mes.saldoFinal < 0 ? Cores.vermelho : Cores.tinta,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Legenda extends StatelessWidget {
  const _Legenda();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, Medidas.espaco),
      child: Wrap(
        spacing: 12,
        runSpacing: 6,
        children: const [
          _Item(cor: Cores.verde, texto: 'sobra boa'),
          _Item(cor: Cores.ambar, texto: 'apertado'),
          _Item(cor: Cores.vermelho, texto: 'no vermelho'),
          _Item(cor: Cores.barro, texto: 'quitado'),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.cor, required this.texto});

  final Color cor;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          texto,
          style: const TextStyle(
            fontFamily: Tipo.figtree,
            fontSize: 12.5,
            color: Color(0xFF4A423C),
          ),
        ),
      ],
    );
  }
}
