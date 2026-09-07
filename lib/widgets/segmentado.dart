import 'package:flutter/material.dart';

import '../design/cores.dart';
import '../design/medidas.dart';
import '../design/tipografia.dart';

/// A pílula que **troca o modo**: dias | meses | ano.
///
/// O design system é explícito: *"Pílula troca o modo. Aba com traço troca
/// o período. Nunca as duas iguais."* Por isso são dois componentes, e não
/// um só com estilo diferente — ver [AbasDePeriodo].
class Segmentado extends StatelessWidget {
  const Segmentado({
    super.key,
    required this.opcoes,
    required this.selecionada,
    required this.aoTrocar,
    this.sobreAcento = false,
  });

  final List<String> opcoes;
  final int selecionada;
  final ValueChanged<int> aoTrocar;

  /// Sobre cabeçalho colorido (a aba "dias" tem cabeçalho verde) a trilha
  /// vira véu escuro e o texto inativo vira branco.
  final bool sobreAcento;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: sobreAcento ? const Color(0x29000000) : Cores.bege,
        borderRadius: BorderRadius.circular(Medidas.raioPilula),
      ),
      child: Row(
        children: [
          for (var i = 0; i < opcoes.length; i++)
            Expanded(
              child: _Opcao(
                texto: opcoes[i],
                ativa: i == selecionada,
                sobreAcento: sobreAcento,
                aoTocar: () => aoTrocar(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _Opcao extends StatelessWidget {
  const _Opcao({
    required this.texto,
    required this.ativa,
    required this.sobreAcento,
    required this.aoTocar,
  });

  final String texto;
  final bool ativa;
  final bool sobreAcento;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    // A cor do texto ativo acompanha o acento da tela: sobre o verde da
    // aba "dias" o design pede o verde escuro, não a tinta.
    final tintaAtiva = sobreAcento ? const Color(0xFF2F5C2E) : Cores.tinta;
    final tintaInativa = sobreAcento ? Cores.branco : const Color(0xFF4A423C);

    return Semantics(
      button: true,
      selected: ativa,
      child: GestureDetector(
        onTap: aoTocar,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: Medidas.toque,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: ativa ? Cores.branco : Colors.transparent,
            borderRadius: BorderRadius.circular(Medidas.raioPilula),
            boxShadow: ativa && !sobreAcento
                ? const [
                    BoxShadow(
                      color: Color(0x1F5C2E1A),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            texto,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: Tipo.figtree,
              fontSize: 13,
              fontWeight: ativa ? FontWeight.w700 : FontWeight.w500,
              color: ativa ? tintaAtiva : tintaInativa,
            ),
          ),
        ),
      ),
    );
  }
}

/// A aba com traço que **troca o período**: set/26 · out/26 · nov/26.
///
/// Rótulo em DM Mono com um traço de 2.5px embaixo — o traço é o que a
/// separa da pílula. Ver [Segmentado].
class AbasDePeriodo extends StatelessWidget {
  const AbasDePeriodo({
    super.key,
    required this.rotulos,
    required this.selecionada,
    required this.aoTrocar,
  });

  final List<String> rotulos;
  final int selecionada;
  final ValueChanged<int> aoTrocar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < rotulos.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: Semantics(
              button: true,
              selected: i == selecionada,
              child: GestureDetector(
                onTap: () => aoTrocar(i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  children: [
                    Text(
                      rotulos[i],
                      style: TextStyle(
                        fontFamily: Tipo.dmMono,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: i == selecionada ? Cores.tinta : Cores.apoio,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: i == selecionada ? Cores.tinta : Cores.bege,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
