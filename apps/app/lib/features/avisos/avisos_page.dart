import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../design/medidas.dart';
import '../../design/tipografia.dart';
import '../../widgets/listas.dart';
import '../../widgets/topo_de_tela.dart';
import 'avisos.dart';

/// "Notificações" (#20) do Kitamo App.dc.html, que na tela se chama
/// **avisos**.
///
/// O Gabriel tocou no sino e disse que a telinha que aparecia era outra.
/// Esta é a do design: topo com voltar e "marcar lidos", as seções HOJE e
/// ANTES em rótulo mono, os cartões com a faixa de 3px, e o fecho
/// centralizado "SÓ ISSO. VOCÊ ESTÁ EM DIA."
///
/// "Uma anatomia só": todo aviso tem o mesmo desenho, o que muda é a cor da
/// faixa e da bolinha.
class AvisosPage extends StatefulWidget {
  const AvisosPage({super.key, required this.avisos, this.aoTocarAcao});

  final List<Aviso> avisos;

  /// O botão dentro do cartão. Null deixa o botão inerte, o que serve para
  /// teste de tela.
  final void Function(Aviso)? aoTocarAcao;

  @override
  State<AvisosPage> createState() => _AvisosPageState();
}

class _AvisosPageState extends State<AvisosPage> {
  /// Lido é estado de tela, não de banco: os avisos são recalculados a cada
  /// abertura, então guardar "lido" gravaria uma marca sobre um aviso que
  /// pode nem existir amanhã.
  var _lidos = false;

  @override
  Widget build(BuildContext context) {
    final hoje = widget.avisos.where((a) => a.deHoje).toList();
    final antes = widget.avisos.where((a) => !a.deHoje).toList();
    final vazio = widget.avisos.isEmpty;

    return Scaffold(
      backgroundColor: Cores.creme,
      body: SafeArea(
        child: Column(
          children: [
            TopoDeTela(
              titulo: 'avisos',
              acao: vazio || _lidos ? null : 'marcar lidos',
              aoTocarAcao: () => setState(() => _lidos = true),
            ),
            Expanded(
              child: vazio
                  ? const _Vazio()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        Medidas.margem,
                        0,
                        Medidas.margem,
                        Medidas.rodape,
                      ),
                      children: [
                        if (hoje.isNotEmpty) ...[
                          const _Secao('HOJE'),
                          for (final a in hoje) _cartao(a),
                        ],
                        if (antes.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          const _Secao('ANTES'),
                          for (final a in antes) _cartao(a),
                        ],
                        const SizedBox(height: 10),
                        const _Fecho(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartao(Aviso a) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: AvisoComFaixa(
          titulo: a.titulo,
          sub: a.detalhe,
          faixa: a.faixa,
          quando: a.quando,
          lido: _lidos,
          icone: _IconeDoAviso(aviso: a),
          acao: a.acao,
          aoTocarAcao: widget.aoTocarAcao == null
              ? null
              : () => widget.aoTocarAcao!(a),
        ),
      );
}

/// O tile de 38px: logo do banco ou a casa quando o aviso trouxe imagem,
/// senão o ícone do tipo, na cor da faixa.
class _IconeDoAviso extends StatelessWidget {
  const _IconeDoAviso({required this.aviso});

  final Aviso aviso;

  @override
  Widget build(BuildContext context) {
    final img = aviso.icone;
    if (img != null) {
      // A casa e o joão ocupam o tile inteiro; logo de banco fica a 19px,
      // como manda o design system.
      final grande = img.startsWith('casa') || img.startsWith('joao');
      return Padding(
        padding: EdgeInsets.all(grande ? 0 : 9),
        child: Image.asset(
          'assets/images/$img',
          fit: grande ? BoxFit.cover : BoxFit.contain,
          width: grande ? 38 : 20,
          height: grande ? 38 : null,
        ),
      );
    }

    return Icon(
      switch (aviso.tipo) {
        TipoAviso.vencimento => Icons.event_rounded,
        TipoAviso.descasamento => Icons.warning_amber_rounded,
        TipoAviso.conquista => Icons.home_rounded,
        TipoAviso.aperto => Icons.trending_down_rounded,
      },
      size: 20,
      color: aviso.faixa,
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          texto,
          style: Tipo.rotulo.copyWith(fontSize: 10.5, color: Cores.apoio),
        ),
      );
}

/// O fecho do design, centralizado e em mono: a lista termina com uma boa
/// notícia em vez de espaço em branco.
class _Fecho extends StatelessWidget {
  const _Fecho();

  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          'SÓ ISSO. VOCÊ ESTÁ EM DIA.',
          style: Tipo.rotulo.copyWith(fontSize: 10.5, color: Cores.apoio),
        ),
      );
}

/// Estado vazio: o joão inteiro, em pé. O arquivo de avatar é recorte
/// fechado no rosto, e ampliado vira zoom na cara do bicho.
class _Vazio extends StatelessWidget {
  const _Vazio();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/joao.png', height: 150),
            const SizedBox(height: Medidas.espaco),
            Text('nenhum aviso agora', style: Tipo.corpo),
            const SizedBox(height: 6),
            Text(
              'SÓ ISSO. VOCÊ ESTÁ EM DIA.',
              style: Tipo.rotulo.copyWith(fontSize: 10.5, color: Cores.apoio),
            ),
          ],
        ),
      );
}
