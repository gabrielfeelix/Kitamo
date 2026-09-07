import 'package:flutter/material.dart';

import '../design/cores.dart';
import '../design/medidas.dart';
import '../design/tipografia.dart';

/// Os cinco itens da barra, na ordem do design.
enum AbaDaKitamo { inicio, lancamentos, chat, lancar, perfil }

/// A barra de navegação, montada a partir do NavBar.dc.html.
///
/// O joão no centro **é a ação principal: falar com a Kitamo**. Ele é o
/// único item ilustrado e o único que sobe acima da linha. Falar não é uma
/// aba escondida no canto — é o que a Kitamo faz.
///
/// "Lançar" fica ao lado, como ícone comum.
class BarraDeNavegacao extends StatelessWidget {
  const BarraDeNavegacao({
    super.key,
    required this.ativa,
    required this.aoTrocar,
    this.temRecado = true,
  });

  final AbaDaKitamo ativa;
  final ValueChanged<AbaDaKitamo> aoTrocar;

  /// O balão de três pontinhos em cima do joão.
  final bool temRecado;

  static const _ativo = Cores.teal;
  static const _inativo = Color(0xFF7A6E64);

  /// O rótulo do "falar" é mais escuro que os outros quando inativo: ele
  /// tem peso maior na barra.
  static const _falarInativo = Color(0xFF4A423C);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Medidas.alturaBarra,
      decoration: const BoxDecoration(
        color: Cores.branco,
        border: Border(top: BorderSide(color: Color(0xFFEFE5DA))),
      ),
      padding: const EdgeInsets.fromLTRB(6, 12, 6, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Item(
            rotulo: 'Início',
            icone: _CasaIcone(cor: _cor(AbaDaKitamo.inicio)),
            cor: _cor(AbaDaKitamo.inicio),
            aoTocar: () => aoTrocar(AbaDaKitamo.inicio),
          ),
          _Item(
            rotulo: 'Lançamentos',
            icone: _ListaIcone(cor: _cor(AbaDaKitamo.lancamentos)),
            cor: _cor(AbaDaKitamo.lancamentos),
            aoTocar: () => aoTrocar(AbaDaKitamo.lancamentos),
          ),
          _Falar(
            ativa: ativa == AbaDaKitamo.chat,
            temRecado: temRecado,
            cor: ativa == AbaDaKitamo.chat ? _ativo : _falarInativo,
            aoTocar: () => aoTrocar(AbaDaKitamo.chat),
          ),
          _Item(
            rotulo: 'Lançar',
            icone: _MaisIcone(cor: _cor(AbaDaKitamo.lancar)),
            cor: _cor(AbaDaKitamo.lancar),
            aoTocar: () => aoTrocar(AbaDaKitamo.lancar),
          ),
          _Item(
            rotulo: 'Perfil',
            icone: _PessoaIcone(cor: _cor(AbaDaKitamo.perfil)),
            cor: _cor(AbaDaKitamo.perfil),
            aoTocar: () => aoTrocar(AbaDaKitamo.perfil),
          ),
        ],
      ),
    );
  }

  Color _cor(AbaDaKitamo a) => ativa == a ? _ativo : _inativo;
}

class _Item extends StatelessWidget {
  const _Item({
    required this.rotulo,
    required this.icone,
    required this.cor,
    required this.aoTocar,
  });

  final String rotulo;
  final Widget icone;
  final Color cor;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        label: rotulo,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: aoTocar,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 25, height: 25, child: icone),
              const SizedBox(height: 5),
              Text(
                rotulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Tipo.chip.copyWith(fontSize: 10.5, color: cor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// O joão de 64px, subindo 20px acima da linha, com o balão de recado.
class _Falar extends StatelessWidget {
  const _Falar({
    required this.ativa,
    required this.temRecado,
    required this.cor,
    required this.aoTocar,
  });

  final bool ativa;
  final bool temRecado;
  final Color cor;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        label: 'falar com a Kitamo',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: aoTocar,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sobe acima da linha da barra: é o único item que faz isso.
              Transform.translate(
                offset: const Offset(0, -20),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Cores.barro,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x525C2E1A),
                              blurRadius: 22,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        // O joão preenche o círculo, como no design — nada
                        // de anel de fundo em volta. Uso a imagem inteira e
                        // não os arquivos de avatar, que são recortes com o
                        // bico cortado pela borda.
                        child: Transform.scale(
                          scale: 1.15,
                          child: Image.asset(
                            'assets/images/joao-voando.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (temRecado)
                        const Positioned(top: -3, right: -4, child: _Balao()),
                    ],
                  ),
                ),
              ),
              // O -20 do joão deixaria um buraco embaixo; isto recupera o
              // rótulo para a linha dos outros.
              Transform.translate(
                offset: const Offset(0, -16),
                child: Text(
                  'falar',
                  style: Tipo.chip.copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: cor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// O balão teal de três pontinhos: a Kitamo tem algo a dizer.
class _Balao extends StatelessWidget {
  const _Balao();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Cores.tealEscuro,
        borderRadius: BorderRadius.circular(Medidas.raioPilula),
        border: Border.all(color: Cores.branco, width: 2.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          3,
          (i) => Container(
            width: 3.5,
            height: 3.5,
            margin: EdgeInsets.only(left: i == 0 ? 0 : 2.5),
            decoration: BoxDecoration(
              color: Cores.branco,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}

// Os ícones são os SVGs do NavBar.dc.html, redesenhados em Path. O design
// pede SVG inline, não Icons. do Material.

class _CasaIcone extends StatelessWidget {
  const _CasaIcone({required this.cor});
  final Color cor;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _CasaPainter(cor));
}

class _CasaPainter extends CustomPainter {
  _CasaPainter(this.cor);
  final Color cor;

  @override
  void paint(Canvas canvas, Size size) {
    final e = size.width / 24;
    final p = Path()
      ..moveTo(12 * e, 3 * e)
      ..lineTo(21.2 * e, 10.6 * e)
      ..lineTo(21.2 * e, 21 * e)
      ..lineTo(14.6 * e, 21 * e)
      ..lineTo(14.6 * e, 15.2 * e)
      ..lineTo(9.4 * e, 15.2 * e)
      ..lineTo(9.4 * e, 21 * e)
      ..lineTo(2.8 * e, 21 * e)
      ..lineTo(2.8 * e, 10.6 * e)
      ..close();
    canvas.drawPath(p, Paint()..color = cor);
  }

  @override
  bool shouldRepaint(covariant _CasaPainter o) => o.cor != cor;
}

class _ListaIcone extends StatelessWidget {
  const _ListaIcone({required this.cor});
  final Color cor;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _ListaPainter(cor));
}

class _ListaPainter extends CustomPainter {
  _ListaPainter(this.cor);
  final Color cor;

  @override
  void paint(Canvas canvas, Size size) {
    final e = size.width / 24;
    final tinta = Paint()..color = cor;
    for (final (y, w) in [(5.4, 18.0), (10.6, 18.0), (15.8, 12.0)]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(3 * e, y * e, w * e, 2.8 * e),
          Radius.circular(1.4 * e),
        ),
        tinta,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ListaPainter o) => o.cor != cor;
}

class _MaisIcone extends StatelessWidget {
  const _MaisIcone({required this.cor});
  final Color cor;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _MaisPainter(cor));
}

class _MaisPainter extends CustomPainter {
  _MaisPainter(this.cor);
  final Color cor;

  @override
  void paint(Canvas canvas, Size size) {
    final e = size.width / 24;
    canvas.drawCircle(
      Offset(12 * e, 12 * e),
      10 * e,
      Paint()
        ..color = cor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2 * e,
    );
    final tinta = Paint()..color = cor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10.8 * e, 6.6 * e, 2.4 * e, 10.8 * e),
        Radius.circular(1.2 * e),
      ),
      tinta,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(6.6 * e, 10.8 * e, 10.8 * e, 2.4 * e),
        Radius.circular(1.2 * e),
      ),
      tinta,
    );
  }

  @override
  bool shouldRepaint(covariant _MaisPainter o) => o.cor != cor;
}

class _PessoaIcone extends StatelessWidget {
  const _PessoaIcone({required this.cor});
  final Color cor;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _PessoaPainter(cor));
}

class _PessoaPainter extends CustomPainter {
  _PessoaPainter(this.cor);
  final Color cor;

  @override
  void paint(Canvas canvas, Size size) {
    final e = size.width / 24;
    final tinta = Paint()..color = cor;
    canvas.drawCircle(Offset(12 * e, 8 * e), 4 * e, tinta);
    final p = Path()
      ..moveTo(4 * e, 21 * e)
      ..cubicTo(4 * e, 16.6 * e, 7.6 * e, 14 * e, 12 * e, 14 * e)
      ..cubicTo(16.4 * e, 14 * e, 20 * e, 16.6 * e, 20 * e, 21 * e)
      ..close();
    canvas.drawPath(p, tinta);
  }

  @override
  bool shouldRepaint(covariant _PessoaPainter o) => o.cor != cor;
}
