import 'package:flutter/material.dart';

import '../design/cores.dart';
import '../design/tipografia.dart';
import 'moeda.dart';

/// A célula de saldo: fundo claro, texto escuro da mesma família.
///
/// Palavras do design system: *"É o único lugar onde as três cores
/// convivem."* Em toda outra tela vale a regra de um acento só.
class CelulaDeSaldo extends StatelessWidget {
  const CelulaDeSaldo({
    super.key,
    required this.valor,
    this.compacta = false,
  });

  final double valor;

  /// Na coluna de 3 meses o espaço é curto: o texto encolhe para caber.
  ///
  /// **Encolher, não cortar o centavo.** "R$ 2" sozinho parece número
  /// cortado — a regra é do `moeda.dart` e vale aqui também.
  final bool compacta;

  EstadoFinanceiro get _estado {
    if (valor < 0) return EstadoFinanceiro.aperto;
    return valor < 100 ? EstadoFinanceiro.atencao : EstadoFinanceiro.tranquilo;
  }

  /// Os pares fundo/tinta saem do design system, não de opacidade
  /// calculada: cada um foi escolhido para passar contraste.
  static const _fundos = {
    EstadoFinanceiro.tranquilo: Color(0xFFDCF0DB),
    EstadoFinanceiro.atencao: Color(0xFFFDF3E1),
    EstadoFinanceiro.aperto: Color(0xFFFBEAE3),
  };

  static const _tintas = {
    EstadoFinanceiro.tranquilo: Color(0xFF245C22),
    EstadoFinanceiro.atencao: Color(0xFF6B4E14),
    EstadoFinanceiro.aperto: Color(0xFF8E3F20),
  };

  @override
  Widget build(BuildContext context) {
    final estado = _estado;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: _fundos[estado],
        borderRadius: BorderRadius.circular(9),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: Text(
          dinheiro(valor),
          textAlign: TextAlign.right,
          maxLines: 1,
          style: TextStyle(
            fontFamily: Tipo.figtree,
            fontSize: compacta ? 12 : 13,
            fontWeight: FontWeight.w700,
            color: _tintas[estado],
          ),
        ),
      ),
    );
  }
}
