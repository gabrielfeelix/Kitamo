import 'package:flutter/material.dart';

import '../design/cores.dart';
import '../design/medidas.dart';
import '../design/tipografia.dart';

/// Peças de lista e de aviso do "Kitamo Design System", seções 05 e 06.
/// O design deu nome a cada uma, então cada uma é widget — tela não desenha
/// cartão na mão.

/// LINHA DE LISTA — o item de "O QUE A GENTE ACOMPANHA" e de "AJUSTES" no
/// Perfil: tile opcional na esquerda, título e apoio no meio, valor à
/// direita e a seta.
///
/// Vem agrupada dentro de [GrupoDeLinhas], que é quem desenha o cartão
/// branco e as divisórias: no design as linhas dividem um cartão só, não um
/// cartão cada.
class LinhaDeLista extends StatelessWidget {
  const LinhaDeLista({
    super.key,
    required this.titulo,
    this.apoio,
    this.valor,
    this.tile,
    this.aoTocar,
    this.temSeta = true,
    this.alturaVertical = 15,
  });

  final String titulo;

  /// Segunda linha, sob o título.
  final String? apoio;

  /// Texto miúdo alinhado à direita, antes da seta.
  final String? valor;

  /// O círculo de 38px da esquerda. Null encosta o texto na margem.
  final Widget? tile;

  final VoidCallback? aoTocar;

  /// A seta só aparece onde o toque leva a algum lugar.
  final bool temSeta;

  final double alturaVertical;

  @override
  Widget build(BuildContext context) {
    final conteudo = Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: alturaVertical),
      child: Row(
        children: [
          if (tile != null) ...[
            tile!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titulo,
                  style: Tipo.corpoForte.copyWith(fontSize: 14.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (apoio != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    apoio!,
                    style: Tipo.apoio,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (valor != null) ...[
            const SizedBox(width: 12),
            // Flexible, não Text solto: numa tela de 320px o valor longo
            // empurrava a seta pra fora em vez de encurtar.
            Flexible(
              child: Text(
                valor!,
                style: Tipo.apoio,
                maxLines: 2,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          if (temSeta) ...[
            const SizedBox(width: 12),
            const SetaDeLinha(),
          ],
        ],
      ),
    );

    if (aoTocar == null) return conteudo;
    return InkWell(onTap: aoTocar, child: conteudo);
  }
}

/// A seta de 16px que fecha a linha de lista. Bege, nunca preta: ela indica
/// caminho, não chama atenção.
class SetaDeLinha extends StatelessWidget {
  const SetaDeLinha({super.key});

  @override
  Widget build(BuildContext context) => const Icon(
        Icons.chevron_right,
        size: 20,
        color: Color(0xFFC4B8AE),
      );
}

/// O cartão branco que segura várias [LinhaDeLista] com divisória de 1px
/// entre elas. É assim que o Perfil agrupa: um cartão por assunto.
class GrupoDeLinhas extends StatelessWidget {
  const GrupoDeLinhas({super.key, required this.linhas});

  final List<Widget> linhas;

  @override
  Widget build(BuildContext context) {
    final comDivisoria = <Widget>[];
    for (var i = 0; i < linhas.length; i++) {
      comDivisoria.add(linhas[i]);
      if (i != linhas.length - 1) {
        comDivisoria.add(const Divider(
          height: 1,
          thickness: 1,
          color: Color(0xFFF4EDE5),
        ));
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Cores.branco,
        borderRadius: BorderRadius.circular(Medidas.raioCartao),
        boxShadow: Medidas.sombraCartao,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(mainAxisSize: MainAxisSize.min, children: comDivisoria),
    );
  }
}

/// AVISO · FAIXA DE 3PX — seção 06 do design system.
///
/// "A cor mora só na faixa e na bolinha. Cartão branco sempre, anatomia
/// idêntica." Todo aviso tem o mesmo formato: o que muda entre um
/// vencimento e uma conquista é a cor da faixa, não o desenho.
class AvisoComFaixa extends StatelessWidget {
  const AvisoComFaixa({
    super.key,
    required this.titulo,
    required this.sub,
    required this.faixa,
    this.quando,
    this.lido = false,
    this.icone,
    this.acao,
    this.aoTocarAcao,
  });

  final String titulo;
  final String sub;

  /// A cor do estado: vermelho vence, âmbar avisa, verde acalma, barro
  /// comemora.
  final Color faixa;

  /// "1h", "ter", "2 set". Mono, à direita.
  final String? quando;

  /// Lido apaga a bolinha, não o cartão.
  final bool lido;

  /// Imagem de 38px no tile bege. Logo de banco, o joão, ou ícone.
  final Widget? icone;

  /// Botão de largura cheia embaixo. Só alguns avisos têm.
  final String? acao;
  final VoidCallback? aoTocarAcao;

  @override
  Widget build(BuildContext context) {
    final cabeca = Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF6F1EB),
            borderRadius: BorderRadius.circular(19),
          ),
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.center,
          child: icone,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                titulo,
                style: Tipo.corpoForte.copyWith(fontSize: 14.5, height: 1.3),
              ),
              const SizedBox(height: 2),
              Text(sub, style: Tipo.apoio.copyWith(height: 1.35)),
            ],
          ),
        ),
        if (quando != null) ...[
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                quando!,
                style: Tipo.rotulo.copyWith(
                  color: Cores.apoio,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  // Lido não apaga o aviso, apaga só a bolinha.
                  color: lido ? const Color(0xFFEDE5DB) : faixa,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: Cores.branco,
        borderRadius: BorderRadius.circular(Medidas.raioLinha),
        boxShadow: Medidas.sombraCartao,
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // A faixa de 3px: a única cor do cartão.
            Container(width: 3, color: faixa),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    cabeca,
                    if (acao != null) ...[
                      const SizedBox(height: 10),
                      _BotaoDoAviso(rotulo: acao!, aoTocar: aoTocarAcao),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// O botão de largura cheia dentro do aviso: bege, tinta escura, raio
/// total. Não é o botão principal da tela, então não é preto.
class _BotaoDoAviso extends StatelessWidget {
  const _BotaoDoAviso({required this.rotulo, this.aoTocar});

  final String rotulo;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 38,
        width: double.infinity,
        child: FilledButton(
          onPressed: aoTocar,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFF6F1EB),
            foregroundColor: Cores.tinta,
            disabledBackgroundColor: const Color(0xFFF6F1EB),
            disabledForegroundColor: Cores.tinta,
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Medidas.raioPilula),
            ),
          ),
          child: Text(
            rotulo,
            style: Tipo.corpoForte.copyWith(fontSize: 13, color: Cores.tinta),
          ),
        ),
      );
}

/// CHAVE — seção 05. Teal quando ligada, bege quando desligada, botão
/// branco de 22px correndo dentro de uma pista de 46x28.
class Chave extends StatelessWidget {
  const Chave({
    super.key,
    required this.ligada,
    required this.aoTrocar,
    this.rotuloSemantico,
  });

  final bool ligada;
  final ValueChanged<bool>? aoTrocar;
  final String? rotuloSemantico;

  @override
  Widget build(BuildContext context) {
    final ligavel = aoTrocar != null;
    return Semantics(
      label: rotuloSemantico,
      toggled: ligada,
      child: GestureDetector(
        onTap: ligavel ? () => aoTrocar!(!ligada) : null,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          // A pista tem 28px, mas o alvo de toque não pode ter: o design
          // manda 44px de mínimo em tudo que se toca.
          height: Medidas.alvoMinimo,
          width: Medidas.alvoMinimo + 2,
          child: Center(
            child: AnimatedContainer(
              duration: Medidas.toque,
              width: 46,
              height: 28,
              decoration: BoxDecoration(
                color: ligada ? Cores.teal : const Color(0xFFDCD2C8),
                borderRadius: BorderRadius.circular(Medidas.raioPilula),
              ),
              child: AnimatedAlign(
                duration: Medidas.toque,
                alignment:
                    ligada ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Cores.branco,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
