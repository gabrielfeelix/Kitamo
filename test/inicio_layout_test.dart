import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitamo/features/inicio/cabecalho_do_inicio.dart';
import 'package:kitamo/features/inicio/inicio_page.dart';
import 'package:kitamo/models/divida.dart';
import 'package:kitamo/models/perfil_financeiro.dart';

/// A tela é desenhada para 390×844, a moldura do design. Estes testes
/// existem porque overflow não quebra o build — quebra na mão do Gabriel.
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

  Widget montar(PerfilFinanceiro perfil) => MaterialApp(
        home: InicioPage(perfil: perfil, dividas: [nubank]),
      );

  const fecha = PerfilFinanceiro(
    nome: 'Gabriel',
    rendaMensal: 5000,
    diaRenda: 6,
    contasFixasEstimadas: 900,
  );

  const naoFecha = PerfilFinanceiro(
    nome: 'Gabriel',
    rendaMensal: 2000,
    diaRenda: 6,
    contasFixasEstimadas: 900,
  );

  testWidgets('cabe em 390x844 quando a conta fecha', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(montar(fecha));
    expect(tester.takeException(), isNull);
  });

  testWidgets('cabe em 390x844 quando a conta não fecha', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(montar(naoFecha));
    expect(tester.takeException(), isNull);
  });

  testWidgets('cabe numa tela pequena de 360x640', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(montar(fecha));
    expect(tester.takeException(), isNull);
  });

  testWidgets('chama a pessoa pelo nome, e a data não depende do intl',
      (tester) async {
    await tester.pumpWidget(montar(fecha));

    expect(find.textContaining('Gabriel'), findsWidgets);
    expect(find.text(dataPorExtenso()), findsOneWidget);
  });

  testWidgets('sem nome, a saudação não fica pendurada numa vírgula',
      (tester) async {
    await tester.pumpWidget(montar(
      const PerfilFinanceiro(rendaMensal: 5000, diaRenda: 6),
    ));

    expect(find.text(saudacaoDaHora()), findsOneWidget);
  });

  testWidgets('o joão some quando a conta não fecha', (tester) async {
    await tester.pumpWidget(montar(naoFecha));

    final joao = find.byWidgetPredicate((w) =>
        w is Image &&
        w.image is AssetImage &&
        (w.image as AssetImage).assetName.endsWith('joao.png'));
    expect(joao, findsNothing);
  });

  testWidgets('o joão aparece no dia tranquilo, dentro do cabeçalho',
      (tester) async {
    await tester.pumpWidget(montar(fecha));

    final joao = find.byWidgetPredicate((w) =>
        w is Image &&
        w.image is AssetImage &&
        (w.image as AssetImage).assetName.endsWith('joao.png'));
    expect(joao, findsOneWidget);

    // "Dentro do cabeçalho" não é figura de linguagem: o bicho tem que
    // estar acima do fim do bloco colorido, senão vira imagem solta no meio
    // da tela — a reclamação que gerou esta reescrita.
    final cabecalho = tester.getRect(find.byType(CabecalhoDoInicio));
    expect(tester.getRect(joao).bottom, lessThanOrEqualTo(cabecalho.bottom));
  });

  testWidgets('a data por extenso sai em português', (tester) async {
    expect(dataPorExtenso(DateTime(2026, 9, 2)), 'quarta, 2 de setembro');
    expect(dataPorExtenso(DateTime(2026, 1, 5)), 'segunda, 5 de janeiro');
    expect(dataPorExtenso(DateTime(2026, 3, 8)), 'domingo, 8 de março');
  });

  testWidgets('a saudação segue a hora', (tester) async {
    expect(saudacaoDaHora(DateTime(2026, 9, 2, 8)), 'bom dia');
    expect(saudacaoDaHora(DateTime(2026, 9, 2, 14)), 'boa tarde');
    expect(saudacaoDaHora(DateTime(2026, 9, 2, 21)), 'boa noite');
  });
}
