import 'dart:async';

import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../design/tipografia.dart';

/// A tela de abertura, do "Kitamo Abertura.dc.html".
///
/// Fundo teal escuro, a casa subindo em fases enquanto carrega, e os
/// verbos no gerúndio trocando — "somando as parcelas…", "conferindo o que
/// falta…", "montando seu plano…". O rodapé traz PRIMEIRO A GENTE QUITA.
///
/// O design system manda o estado de carregamento mostrar "o joão em
/// movimento, verbo no gerúndio, barra de progresso". É isso.
class AberturaPage extends StatefulWidget {
  const AberturaPage({super.key, required this.aoTerminar});

  final VoidCallback aoTerminar;

  /// O design pede 6s. Quem abre o app todo dia não quer esse pedágio,
  /// mas o GIF tem cinco quadros e cortar antes do fim mostra casa pela
  /// metade: 3,2s deixa a construção terminar.
  static const duracao = Duration(milliseconds: 3200);

  @override
  State<AberturaPage> createState() => _AberturaPageState();
}

class _AberturaPageState extends State<AberturaPage>
    with SingleTickerProviderStateMixin {
  static const _verbos = [
    'somando as parcelas…',
    'conferindo o que falta…',
    'montando seu plano…',
  ];

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: AberturaPage.duracao,
  )..forward();

  Timer? _saida;

  @override
  void initState() {
    super.initState();
    _saida = Timer(AberturaPage.duracao, () {
      if (mounted) widget.aoTerminar();
    });
  }

  @override
  void dispose() {
    _saida?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores.tealEscuro,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            final verbo = _verbos[(t * 3).clamp(0, 2).floor()];

            return Column(
              children: [
                const Spacer(),
                Text(
                  'Kitamo',
                  style: Tipo.numero.copyWith(
                    fontSize: 34,
                    color: Cores.creme,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 40),
                // O GIF que veio com o design: cinco quadros da casa sendo
                // construída. Antes daqui eu animava isso em código, o que
                // era invenção minha — o arquivo do designer já existia.
                SizedBox(
                  height: 200,
                  child: Image.asset(
                    'assets/images/kitamo-carregando.gif',
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  verbo,
                  style: Tipo.corpo.copyWith(color: const Color(0xFFEAFBF7)),
                ),
                const SizedBox(height: 22),
                // A barra de progresso do estado "carregando".
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: t.clamp(0.06, 1),
                      minHeight: 4,
                      backgroundColor: Cores.branco.withValues(alpha: 0.25),
                      valueColor: const AlwaysStoppedAnimation(Cores.creme),
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 34),
                  child: Text(
                    'PRIMEIRO A GENTE QUITA',
                    style: Tipo.rotulo.copyWith(
                      letterSpacing: 11 * 0.14,
                      color: Cores.creme,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
