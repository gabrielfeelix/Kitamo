import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../design/medidas.dart';
import '../../design/tipografia.dart';
import '../../services/horizonte_service.dart';
import '../../widgets/celula_de_saldo.dart';
import '../../widgets/segmentado.dart';

/// A aba "meses" (#10): três meses lado a lado, uma célula por dia.
///
/// É a tela que dá nome ao conjunto: *"o vermelho anda pra frente até
/// janeiro, e some"*. Ver três meses juntos é o que deixa isso visível.
class AbaMeses extends StatefulWidget {
  const AbaMeses({super.key, required this.meses});

  final List<MesProjetado> meses;

  @override
  State<AbaMeses> createState() => _AbaMesesState();
}

class _AbaMesesState extends State<AbaMeses> {
  /// Qual coluna está em foco. As abas de mês trocam o período — é o outro
  /// componente do design system, com traço, nunca a pílula.
  int _emFoco = 0;

  static const _mesesCurtos = [
    'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
    'jul', 'ago', 'set', 'out', 'nov', 'dez',
  ];

  String _rotulo(MesProjetado m) {
    if (m.dias.isEmpty) return '';
    final d = m.dias.first.data;
    return '${_mesesCurtos[d.month - 1]}/${d.year.toString().substring(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
          child: AbasDePeriodo(
            rotulos: widget.meses.map(_rotulo).toList(),
            selecionada: _emFoco,
            aoTrocar: (i) => setState(() => _emFoco = i),
          ),
        ),
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(16, 0, 16, Medidas.espaco),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < widget.meses.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(
                    child: _Coluna(
                      mes: widget.meses[i],
                      // A coluna fora de foco fica mais apagada: três
                      // colunas com o mesmo peso viram parede de número.
                      emFoco: i == _emFoco,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Coluna extends StatelessWidget {
  const _Coluna({required this.mes, required this.emFoco});

  final MesProjetado mes;
  final bool emFoco;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: emFoco ? 1 : 0.45,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: mes.dias.length,
        separatorBuilder: (_, _) => const SizedBox(height: 3),
        itemBuilder: (_, i) {
          final dia = mes.dias[i];
          return Row(
            children: [
              SizedBox(
                width: 18,
                child: Text(
                  '${dia.dia}',
                  style: const TextStyle(
                    fontFamily: Tipo.dmMono,
                    fontSize: 11.5,
                    color: Cores.apoio,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(child: CelulaDeSaldo(valor: dia.saldo, compacta: true)),
            ],
          );
        },
      ),
    );
  }
}
