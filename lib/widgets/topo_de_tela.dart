import 'package:flutter/material.dart';

import '../design/cores.dart';
import '../design/medidas.dart';
import '../design/tipografia.dart';

/// O topo das telas internas: botão de voltar num quadrado branco de 36px
/// com sombra, e o título em Outfit 19 minúsculo.
///
/// Aparece igual em "Editar perfil" e em "Notificações" no
/// Kitamo App.dc.html, então é widget, não desenho repetido.
///
/// Não é `AppBar`: o design não tem barra, tem uma linha de conteúdo com
/// respiro de 20px, como todo o resto da tela.
class TopoDeTela extends StatelessWidget {
  const TopoDeTela({
    super.key,
    required this.titulo,
    this.aoVoltar,
    this.acao,
    this.aoTocarAcao,
  });

  final String titulo;

  /// Null usa o `Navigator.pop` da rota atual.
  final VoidCallback? aoVoltar;

  /// Texto miúdo à direita, tipo "marcar lidos".
  final String? acao;
  final VoidCallback? aoTocarAcao;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Medidas.margem, 4, Medidas.margem, 14),
      child: Row(
        children: [
          _BotaoDeVoltar(
            aoTocar: aoVoltar ?? () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 13),
          Expanded(child: Text(titulo, style: Tipo.titulo)),
          if (acao != null)
            TextButton(
              onPressed: aoTocarAcao,
              style: TextButton.styleFrom(
                minimumSize: const Size(0, Medidas.alvoMinimo),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                foregroundColor: Cores.apoio,
              ),
              child: Text(
                acao!,
                style: Tipo.corpoMiudo.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Cores.apoio,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BotaoDeVoltar extends StatelessWidget {
  const _BotaoDeVoltar({required this.aoTocar});

  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'voltar',
      child: GestureDetector(
        onTap: aoTocar,
        behavior: HitTestBehavior.opaque,
        // O quadrado desenhado tem 36px, o alvo de toque tem 44px.
        child: SizedBox(
          height: Medidas.alvoMinimo,
          width: Medidas.alvoMinimo,
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Cores.branco,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A5C2E1A),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chevron_left,
                size: 22,
                color: Cores.tinta,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
