import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitamo/features/resultado/resultado_page.dart';
import 'package:kitamo/models/divida.dart';
import 'package:kitamo/models/perfil_financeiro.dart';
import 'package:kitamo/widgets/moeda.dart';

/// A #17 "O número" — o RESULTADO das perguntas iniciais.
///
/// Existe porque o app caía seco no Início: a pessoa respondia seis
/// perguntas e não recebia nada de volta. Não confundir com o onboarding
/// (#32), que ensina a usar depois.
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

  Widget tela({
    PerfilFinanceiro? perfil,
    List<Divida>? dividas,
    VoidCallback? aoVer,
    VoidCallback? aoRevisar,
  }) =>
      ResultadoPage(
        perfil: perfil ??
            const PerfilFinanceiro(rendaMensal: 3000, contasFixasEstimadas: 900),
        dividas: dividas ?? [nubank],
        aoVerMeuMes: aoVer ?? () {},
        aoRevisar: aoRevisar ?? () {},
      );

  for (final t in tamanhos) {
    testWidgets('cabe em ${t.width.toInt()}x${t.height.toInt()}',
        (tester) async {
      await em(tester, t, tela());
      expect(tester.takeException(), equals(null));
    });
  }

  testWidgets('mostra o número, o resumo e o aviso de que foi chute',
      (tester) async {
    await em(tester, tamanhos.first, tela());

    expect(find.textContaining('PRA QUITAR ATÉ'), findsOneWidget);
    expect(find.textContaining('em 1 dívida'), findsOneWidget);
    expect(find.textContaining('foi chute seu'), findsOneWidget);
  });

  testWidgets('os dois botões do design levam a algum lugar', (tester) async {
    var viu = false;
    var revisou = false;

    await em(tester, tamanhos.first,
        tela(aoVer: () => viu = true, aoRevisar: () => revisou = true));

    await tester.tap(find.text('ver meu mês'));
    await tester.tap(find.text('revisar minhas respostas'));

    expect(viu, isTrue);
    expect(revisou, isTrue, reason: 'quem errou a resposta precisa voltar');
  });

  testWidgets('quando a conta não fecha, não promete quitação', (tester) async {
    await em(
      tester,
      tamanhos.first,
      tela(
        perfil: const PerfilFinanceiro(
          rendaMensal: 1000,
          contasFixasEstimadas: 900,
        ),
        dividas: [nubank],
      ),
    );

    // Prometer "pra quitar até janeiro" a quem não fecha a conta seria
    // mentir na primeira tela que ela vê.
    expect(find.text('A CONTA NÃO FECHA'), findsOneWidget);
    expect(find.textContaining('PRA QUITAR'), findsNothing);
    expect(find.textContaining('quanto falta por mês'), findsOneWidget);
  });

  testWidgets('o joão some quando a conta não fecha', (tester) async {
    await em(
      tester,
      tamanhos.first,
      tela(
        perfil: const PerfilFinanceiro(
          rendaMensal: 1000,
          contasFixasEstimadas: 900,
        ),
      ),
    );

    // Bicho fofo sobre má notícia é deboche. É regra do design.
    final imagens = tester.widgetList<Image>(find.byType(Image));
    expect(imagens, isEmpty);
  });

  testWidgets('sem dívida nenhuma o resumo não fala de dívida',
      (tester) async {
    await em(
      tester,
      tamanhos.first,
      tela(dividas: const []),
    );

    expect(find.textContaining('você deve'), findsNothing);
    expect(find.textContaining('por mês.'), findsOneWidget);
  });

  testWidgets('todo valor sai com centavo', (tester) async {
    await em(tester, tamanhos.first, tela());

    // "R$ 2" sozinho parece número cortado. O valor vive dentro de um
    // TextSpan do resumo, então procura pelo texto renderizado.
    expect(find.textContaining(dinheiro(6136.24), findRichText: true),
        findsOneWidget);
  });
}
