import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../design/medidas.dart';
import '../../design/tipografia.dart';
import '../../models/perfil_financeiro.dart';

/// "já tenho conta" — o login social.
///
/// **O design não tem esta tela.** As 36 do Kitamo App.dc.html vão da
/// abertura ao onboarding sem passar por conta nenhuma, porque "sem
/// servidor, sem login, sem nuvem" era decisão fechada. O Gabriel reabriu
/// em 07/09/2026: quer comunidade, e quer que a pessoa que troca de celular
/// não precise importar a fatura de novo.
///
/// Então esta tela foi montada com o vocabulário do design, não inventada
/// do zero: é a "01 Boas-vindas" por dentro — fundo #0F766E, o joão grande,
/// promessa em Outfit 30, botões de 52px com raio total. Assim ela não
/// destoa quando aparece logo depois da abertura.
///
/// **Não existe backend.** Tocar em Google ou Facebook só guarda o provedor
/// e um e-mail de exemplo no banco local e segue. Decisão do Gabriel: só a
/// tela, até as 10 pessoas testarem.
class EntrarPage extends StatelessWidget {
  const EntrarPage({
    super.key,
    required this.aoEntrar,
    this.aoVoltar,
    this.aoSeguirSemConta,
  });

  /// Recebe o provedor escolhido. Quem chama decide o que fazer com ele.
  final void Function(ProvedorDeLogin provedor) aoEntrar;

  final VoidCallback? aoVoltar;

  /// "entrar sem conta" — o caminho que sempre existiu, e que continua
  /// sendo o padrão do app.
  final VoidCallback? aoSeguirSemConta;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores.tealEscuro,
      body: SafeArea(
        // A tela rola quando o aparelho é curto: em 320x568 os botões
        // ficavam fora do alcance, que é o bug que já prendeu a pessoa na
        // primeira tela do app.
        child: LayoutBuilder(
          builder: (context, limites) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: limites.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed:
                              aoVoltar ?? () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.chevron_left, size: 26),
                          color: Cores.creme,
                          tooltip: 'voltar',
                        ),
                      ),
                      // O joão cede o espaço que faltar, como na
                      // boas-vindas: encolhe em vez de empurrar os botões
                      // para fora da tela.
                      Flexible(
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Image.asset(
                              'assets/images/joao-voando.png',
                              height: 170,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'entra com a sua conta,\no plano vem junto.',
                        style: Tipo.numero.copyWith(
                          fontSize: 30,
                          height: 1.18,
                          letterSpacing: -30 * 0.022,
                          color: Cores.creme,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: Text(
                          'trocou de celular, o seu plano continua. '
                          'a gente nunca pede senha de banco.',
                          style: Tipo.corpo.copyWith(
                            height: 1.6,
                            color: const Color(0xFFEAFBF7),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _BotaoDeProvedor(
                        provedor: ProvedorDeLogin.google,
                        aoTocar: () => aoEntrar(ProvedorDeLogin.google),
                      ),
                      const SizedBox(height: 10),
                      _BotaoDeProvedor(
                        provedor: ProvedorDeLogin.facebook,
                        aoTocar: () => aoEntrar(ProvedorDeLogin.facebook),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: aoSeguirSemConta,
                          style: TextButton.styleFrom(
                            minimumSize: const Size(double.infinity, 44),
                            foregroundColor: Cores.creme,
                          ),
                          child: Text(
                            'entrar sem conta',
                            style: Tipo.corpo.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Cores.creme,
                            ),
                          ),
                        ),
                      ),
                    ],
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

/// Botão de provedor: creme cheio, 52px, raio total, com a marca à
/// esquerda. Segue o "começar" da boas-vindas, que é o botão sobre acento
/// do design system.
class _BotaoDeProvedor extends StatelessWidget {
  const _BotaoDeProvedor({required this.provedor, required this.aoTocar});

  final ProvedorDeLogin provedor;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: FilledButton(
        onPressed: aoTocar,
        style: FilledButton.styleFrom(
          backgroundColor: Cores.creme,
          foregroundColor: Cores.tinta,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Medidas.raioPilula),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MarcaDoProvedor(provedor: provedor),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'continuar com ${provedor.nome}',
                style: Tipo.corpoForte.copyWith(color: Cores.tinta),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A marca desenhada, não baixada: o app não tem rede garantida e não
/// carrega SVG de fora. O G do Google em quatro cores e o f do Facebook.
class _MarcaDoProvedor extends StatelessWidget {
  const _MarcaDoProvedor({required this.provedor});

  final ProvedorDeLogin provedor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: provedor == ProvedorDeLogin.google
            ? _GoogleG()
            : _FacebookF(),
      ),
    );
  }
}

class _GoogleG extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // O G da marca: anel fino, aberto à direita, com a barra do meio
    // entrando até o centro. Em 20px o anel grosso vira bolinha, então o
    // traço fica em 22% do diâmetro e a abertura é larga o bastante pra se
    // ler como G, não como círculo.
    const pi = 3.1415926535897932;
    final traco = size.width * 0.22;
    final caixa = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (size.width - traco) / 2,
    );

    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = traco
      ..strokeCap = StrokeCap.butt;

    void arco(double de, double varre, Color cor) =>
        canvas.drawArc(caixa, de, varre, false, p..color = cor);

    // 0 rad = 3 horas, sentido horário. A abertura fica entre -18° e +8°,
    // onde entra a barra azul.
    arco(-pi * 0.10, -pi * 0.55, const Color(0xFFEA4335)); // vermelho, topo
    arco(-pi * 0.65, -pi * 0.60, const Color(0xFFFBBC05)); // amarelo, esquerda
    arco(pi * 0.75, pi * 0.50, const Color(0xFF34A853)); //   verde, base
    arco(pi * 0.30, pi * 0.45, const Color(0xFF4285F4)); //   azul, direita

    // A barra do G, do centro até a borda direita, na altura do meio.
    canvas.drawRect(
      Rect.fromLTRB(
        size.width * 0.50,
        size.height * 0.39,
        size.width * 0.96,
        size.height * 0.61,
      ),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FacebookF extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      centro,
      size.width / 2,
      Paint()..color = const Color(0xFF1877F2),
    );

    final l = size.width;
    final f = Path()
      ..moveTo(l * 0.56, l * 0.98)
      ..lineTo(l * 0.56, l * 0.55)
      ..lineTo(l * 0.68, l * 0.55)
      ..lineTo(l * 0.71, l * 0.40)
      ..lineTo(l * 0.56, l * 0.40)
      ..lineTo(l * 0.56, l * 0.32)
      ..cubicTo(l * 0.56, l * 0.26, l * 0.58, l * 0.24, l * 0.66, l * 0.24)
      ..lineTo(l * 0.72, l * 0.24)
      ..lineTo(l * 0.72, l * 0.10)
      ..cubicTo(l * 0.69, l * 0.09, l * 0.61, l * 0.08, l * 0.55, l * 0.08)
      ..cubicTo(l * 0.42, l * 0.08, l * 0.37, l * 0.17, l * 0.37, l * 0.30)
      ..lineTo(l * 0.37, l * 0.40)
      ..lineTo(l * 0.25, l * 0.40)
      ..lineTo(l * 0.25, l * 0.55)
      ..lineTo(l * 0.37, l * 0.55)
      ..lineTo(l * 0.37, l * 0.98)
      ..close();

    canvas.drawPath(f, Paint()..color = Cores.branco);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
