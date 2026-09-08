import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitamo/features/chat/chat_page.dart';
import 'package:kitamo/models/divida.dart';
import 'package:kitamo/models/perfil_financeiro.dart';

/// O chat abria com "pergunta aí" e uma caixa vazia, e a arte era um
/// recorte da cabeça do joão esticado — o Gabriel viu "a cara do
/// passarinho cortada".
void main() {
  const tamanhos = [Size(390, 844), Size(360, 640), Size(320, 568)];

  final nubank = Divida(
    id: '1',
    nome: 'Nubank',
    saldoAtual: 6136.24,
    valorParcela: 500,
    diaVencimento: 4,
    parcelasRestantes: 4,
    parcelasTotal: 10,
  );

  Future<void> em(WidgetTester tester, Size t, Widget tela) async {
    tester.view.physicalSize = t;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: tela));
    await tester.pumpAndSettle();
  }

  Widget tela({String? nome = 'Gabriel'}) => ChatPage(
        perfil: PerfilFinanceiro(
          nome: nome,
          rendaMensal: 3000,
          contasFixasEstimadas: 900,
        ),
        dividas: [nubank],
      );

  for (final t in tamanhos) {
    testWidgets('cabe em ${t.width.toInt()}x${t.height.toInt()}',
        (tester) async {
      await em(tester, t, tela());
      expect(tester.takeException(), equals(null));
    });
  }

  testWidgets('usa o joão inteiro, não o recorte da cabeça', (tester) async {
    await em(tester, tamanhos.first, tela());

    final imagens = tester
        .widgetList<Image>(find.byType(Image))
        .map((i) => (i.image as AssetImage).assetName)
        .toList();

    expect(imagens, isNotEmpty);
    expect(imagens.any((a) => a.contains('joao-avatar')), isFalse,
        reason: 'joao-avatar.png é um close de 330px: esticado vira zoom');
    expect(imagens.any((a) => a.endsWith('joao.png')), isTrue);
  });

  testWidgets('abre falando e mostra o que sabe responder', (tester) async {
    await em(tester, tamanhos.first, tela());

    // Caixa de texto em branco ninguém digita: as perguntas ficam à vista.
    expect(find.textContaining('oi, Gabriel'), findsOneWidget);
    expect(find.text('O QUE EU SEI RESPONDER'), findsOneWidget);
    expect(find.text('quanto falta pra quitar?'), findsWidgets);
  });

  testWidgets('sem nome, cumprimenta sem inventar um', (tester) async {
    await em(tester, tamanhos.first, tela(nome: null));

    expect(find.textContaining('oi. eu sei'), findsOneWidget);
  });

  testWidgets('tocar numa pergunta traz a resposta com número',
      (tester) async {
    await em(tester, tamanhos.first, tela());

    await tester.tap(find.text('quanto falta pra quitar?').first);
    await tester.pumpAndSettle();

    // Virou conversa: a pergunta e a resposta aparecem.
    expect(find.text('O QUE EU SEI RESPONDER'), findsNothing);
    expect(find.textContaining(r'R$'), findsWidgets);
  });
}
