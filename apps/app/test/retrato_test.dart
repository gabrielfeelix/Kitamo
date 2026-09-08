@Skip('gera PNG das telas; rode com: flutter test test/retrato_test.dart -x nada')
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitamo/features/inicio/inicio_page.dart';
import 'package:kitamo/models/divida.dart';
import 'package:kitamo/models/perfil_financeiro.dart';

/// Não é teste: é como eu olho a tela sem celular na mão. Gera PNG de
/// 390×844, a moldura do design, para pôr lado a lado com o .dc.html.
void main() {
  final nubank = Divida(
    id: '1',
    nome: 'Nubank',
    saldoAtual: 6136.24,
    valorParcela: 1534.06,
    diaVencimento: 4,
    parcelasRestantes: 4,
    parcelasTotal: 10,
  );

  Future<void> retratar(
    WidgetTester tester,
    String arquivo,
    PerfilFinanceiro perfil,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(RepaintBoundary(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: InicioPage(perfil: perfil, dividas: [nubank]),
      ),
    ));
    await tester.pumpAndSettle();

    final boundary = tester.firstRenderObject<RenderRepaintBoundary>(
      find.byType(RepaintBoundary),
    );
    final imagem = await boundary.toImage(pixelRatio: 3.0);
    final bytes = await imagem.toByteData(format: ui.ImageByteFormat.png);
    File(arquivo).writeAsBytesSync(bytes!.buffer.asUint8List());
  }

  const destino =
      '/tmp/claude-1000/-home-gabfelix-dev-finance/6898ed22-93d3-4dd4-bd51-5351037d9771/scratchpad';

  testWidgets('retrato do dia tranquilo', (tester) async {
    await retratar(tester, '$destino/inicio-tranquilo.png',
        const PerfilFinanceiro(
          nome: 'Gabriel',
          rendaMensal: 5000,
          diaRenda: 6,
          contasFixasEstimadas: 900,
        ));
  });

  testWidgets('retrato da conta que não fecha', (tester) async {
    await retratar(tester, '$destino/inicio-aperto.png',
        const PerfilFinanceiro(
          nome: 'Gabriel',
          rendaMensal: 2000,
          diaRenda: 6,
          contasFixasEstimadas: 900,
        ));
  });
}
