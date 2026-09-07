import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../design/medidas.dart';
import '../../design/tipografia.dart';
import '../../widgets/moeda.dart';
import 'quitacao_resultado.dart';

/// A conquista. Tela cheia em barro escuro — o único momento de festa.
///
/// Comemora sem infantilizar: carimbo e contagem, e a casa mais alta que
/// na última vez. Sem confete, sem "parabéns!!!".
class QuiteiEssaPage extends StatelessWidget {
  const QuiteiEssaPage({super.key, required this.resultado});

  final QuitacaoResultado resultado;

  static const _meses = [
    'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
    'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
  ];

  /// Antecipou quando a data de quitação recuou.
  bool get _antecipou {
    final antes = resultado.quitacaoAntes;
    final depois = resultado.quitacaoDepois;
    return antes != null && depois != null && depois.isBefore(antes);
  }

  @override
  Widget build(BuildContext context) {
    final d = resultado.divida;

    return Scaffold(
      backgroundColor: const Color(0xFF5C2E1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Medidas.margem),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              _Carimbo(),
              const SizedBox(height: Medidas.espacoGrande),
              Text(
                'parcela do ${d.nome}',
                style: Tipo.titulo.copyWith(color: Cores.branco),
              ),
              Text(
                dinheiro(d.valorParcela),
                style: Tipo.corpo.copyWith(color: Cores.barroClaro),
              ),
              const SizedBox(height: Medidas.espacoGrande),

              if (resultado.acabou)
                Text(
                  'acabou. Você quitou tudo.',
                  style: Tipo.numeroMedio.copyWith(color: Cores.branco),
                )
              else
                Text(
                  '${d.parcelasPagas} de ${d.parcelasTotal}. '
                  'Faltam ${d.parcelasRestantes}.',
                  style: Tipo.numeroMedio.copyWith(color: Cores.branco),
                ),

              if (_antecipou) ...[
                const SizedBox(height: Medidas.espaco),
                Text(
                  'você adiantou. Agora sua quitação é em '
                  '${_meses[resultado.quitacaoDepois!.month - 1]}.',
                  style: Tipo.corpo.copyWith(color: Cores.barroClaro),
                ),
              ],

              const Spacer(),
              Center(
                child: Image.asset(
                  resultado.caminhoDaCasa,
                  height: 160,
                  errorBuilder: (_, _, _) => const SizedBox(height: 160),
                ),
              ),
              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: Cores.branco,
                    foregroundColor: Cores.tinta,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Medidas.raioPilula),
                    ),
                  ),
                  child: Text('beleza', style: Tipo.corpoForte),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carimbo torto, como carimbo de verdade — não selo digital.
class _Carimbo extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Transform.rotate(
        angle: -0.06,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Cores.barroClaro, width: 3),
            borderRadius: BorderRadius.circular(Medidas.raioBarra),
          ),
          child: Text(
            'QUITADO',
            style: Tipo.rotulo.copyWith(
              color: Cores.barroClaro,
              fontSize: 20,
              letterSpacing: 3,
            ),
          ),
        ),
      );
}
