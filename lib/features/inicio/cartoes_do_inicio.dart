import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../design/medidas.dart';
import '../../design/tipografia.dart';
import '../../models/divida.dart';
import '../../widgets/moeda.dart';
import '../../widgets/pecas.dart';

/// Os cartões brancos da tela de Início, na anatomia do design.

/// PRÓXIMA PARCELA — tile do banco, rótulo mono, valor em Outfit à direita,
/// faixa âmbar quando a parcela cai antes do salário, e a barra escura
/// "quitei essa" de 44px ocupando a largura do cartão.
class CartaoProximaParcela extends StatelessWidget {
  const CartaoProximaParcela({
    super.key,
    required this.divida,
    this.diaRenda,
    this.aoQuitar,
  });

  final Divida divida;
  final int? diaRenda;
  final VoidCallback? aoQuitar;

  @override
  Widget build(BuildContext context) {
    final caiAntes = diaRenda != null && divida.diaVencimento < diaRenda!;

    return Cartao(
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Tile(
                logo: _logoDoBanco(divida.nome),
                iniciais: _iniciais(divida.nome),
                fundo: _fundoDoTile(divida.nome),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Rotulo('próxima parcela'),
                    const SizedBox(height: 3),
                    Text(
                      'dia ${divida.diaVencimento} · ${divida.nome}',
                      style: Tipo.corpoForte,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(dinheiro(divida.valorParcela), style: Tipo.valor),
            ],
          ),
          if (caiAntes) ...[
            const SizedBox(height: 10),
            _FaixaDeAtencao(
              child: RichText(
                text: TextSpan(
                  style: Tipo.corpoMiudo.copyWith(color: const Color(0xFF4A423C)),
                  children: [
                    const TextSpan(text: 'ela cai '),
                    TextSpan(
                      text: 'antes',
                      style: Tipo.corpoMiudo.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4A423C),
                      ),
                    ),
                    TextSpan(text: ' do salário do dia $diaRenda'),
                  ],
                ),
              ),
            ),
          ],
          // A barra faz parte da anatomia do cartão no design, então ela
          // aparece sempre. Sem callback ela fica inerte — é o caso do
          // teste de tela, não um estado do app.
          const SizedBox(height: 10),
          BotaoPrincipal(
            rotulo: 'quitei essa',
            altura: Medidas.alvoMinimo,
            aoTocar: aoQuitar,
          ),
        ],
      ),
    );
  }

  static String? _logoDoBanco(String nome) {
    final n = nome.toLowerCase();
    if (n.contains('nubank') || n.contains('nu ')) return 'bank-nubank.png';
    if (n.contains('itaú') || n.contains('itau')) return 'bank-itau.png';
    if (n.contains('mercado')) return 'bank-mp.png';
    return null;
  }

  /// O tile do Nubank é lilás no design; os outros ficam no bege padrão.
  static Color? _fundoDoTile(String nome) =>
      _logoDoBanco(nome) == 'bank-nubank.png' ? const Color(0xFFF4EDFB) : null;

  static String _iniciais(String nome) {
    final partes = nome.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty || partes.first.isEmpty) return '?';
    if (partes.length == 1) {
      return partes.first.substring(0, partes.first.length >= 2 ? 2 : 1);
    }
    return '${partes[0][0]}${partes[1][0]}';
  }
}

/// Faixa âmbar interna: bolinha de 12px e texto. Raio 16, padding 11/14.
class _FaixaDeAtencao extends StatelessWidget {
  const _FaixaDeAtencao({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF3E1),
        borderRadius: BorderRadius.circular(Medidas.raioEscolha),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Cores.ambar,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// "setembro, dia a dia" — a linha de saldo do mês, com o ponto vermelho no
/// fundo do mês e a leitura embaixo da divisória.
class CartaoDoMes extends StatelessWidget {
  const CartaoDoMes({
    super.key,
    required this.titulo,
    required this.saldos,
    this.leitura,
    this.aoVerDoze,
  });

  final String titulo;

  /// Saldo projetado por dia do mês. O gráfico é uma leitura, não decoração.
  final List<double> saldos;
  final String? leitura;
  final VoidCallback? aoVerDoze;

  @override
  Widget build(BuildContext context) {
    return Cartao(
      raio: 24,
      padding: const EdgeInsets.fromLTRB(15, 12, 15, 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  titulo,
                  style: Tipo.corpoForte.copyWith(letterSpacing: -0.15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (aoVerDoze != null)
                GestureDetector(
                  onTap: aoVerDoze,
                  child: Text(
                    'ver 12 meses',
                    style: Tipo.corpoMiudo.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Cores.teal,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            width: double.infinity,
            child: CustomPaint(painter: _LinhaDeSaldo(saldos)),
          ),
          if (leitura != null) ...[
            const SizedBox(height: 7),
            Container(
              padding: const EdgeInsets.only(top: 7),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF1E8DE))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Cores.vermelho,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      leitura!,
                      style: Tipo.corpoMiudo.copyWith(
                        color: const Color(0xFF4A423C),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Traço de 2px, área a 10%, linha do zero pontilhada em bege, e um único
/// ponto vermelho no fundo do mês — as regras da seção 09 do design system.
class _LinhaDeSaldo extends CustomPainter {
  _LinhaDeSaldo(this.serie);

  final List<double> serie;

  @override
  void paint(Canvas canvas, Size size) {
    if (serie.length < 2) return;

    final min = serie.reduce((a, b) => a < b ? a : b);
    final max = serie.reduce((a, b) => a > b ? a : b);
    final span = (max - min).abs() < 0.01 ? 1.0 : max - min;

    double px(int i) => i * (size.width / (serie.length - 1));
    double py(double v) => size.height - ((v - min) / span) * (size.height - 9) - 4.5;

    // A linha é sempre verde, inclusive quando o mês afunda: no design a
    // série vai a −964 e o traço continua verde. O vermelho mora só no
    // ponto do fundo do mês, que é o que a pessoa precisa enxergar. Pintar
    // o mês inteiro de vermelho é o sermão que a Kitamo não dá.
    const cor = Cores.verde;

    final caminho = Path()..moveTo(px(0), py(serie[0]));
    for (var i = 1; i < serie.length; i++) {
      final x0 = px(i - 1);
      final x1 = px(i);
      final c = (x1 - x0) / 2;
      caminho.cubicTo(x0 + c, py(serie[i - 1]), x1 - c, py(serie[i]), x1, py(serie[i]));
    }

    final area = Path.from(caminho)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(area, Paint()..color = cor.withValues(alpha: 0.1));

    // Linha do zero, pontilhada, só quando o zero está no campo de visão.
    if (min < 0 && max > 0) {
      final y = py(0);
      final tracejado = Paint()
        ..color = const Color(0xFFE4D8CB)
        ..strokeWidth = 1.5;
      for (var x = 0.0; x < size.width; x += 8) {
        canvas.drawLine(Offset(x, y), Offset(x + 3, y), tracejado);
      }
    }

    canvas.drawPath(
      caminho,
      Paint()
        ..color = cor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // O fundo do mês: um ponto só, como manda o design.
    final iMin = serie.indexOf(min);
    final p = Offset(px(iMin), py(min));
    canvas.drawCircle(p, 6, Paint()..color = Cores.vermelho.withValues(alpha: 0.18));
    canvas.drawCircle(p, 3.2, Paint()..color = Cores.vermelho);
    canvas.drawCircle(p, 1.2, Paint()..color = Cores.branco);
  }

  @override
  bool shouldRepaint(covariant _LinhaDeSaldo old) => old.serie != serie;
}
